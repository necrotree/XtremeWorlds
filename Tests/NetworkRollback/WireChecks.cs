using System.Collections.Concurrent;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Text.Json;
using Server;
using XtremeWorlds.Client.Engine.Graphics;
using XtremeWorlds.Networking;

internal static class WireChecks
{
    public static async Task Run(Action<bool, string> check)
    {
        // A real local TCP connection exercises the production router and JSON wire format.
        var listener = new TcpListener(IPAddress.Loopback, 0);
        listener.Start(); int port = ((IPEndPoint)listener.LocalEndpoint).Port; listener.Stop();
        using var host = new MirrorTcpHost(port, 1024 * 1024, true);
        using var database = new SpacetimeRepository(new ServerSettings());
        var sessions = new ConcurrentDictionary<int, PlayerSession>();
        var settings = new ServerSettings { TickRate = 60, SnapshotRate = 20 };
        var router = new PacketRouter(settings, host, database, sessions);
        var maps = (ConcurrentDictionary<int, MapDefinition>)typeof(PacketRouter)
            .GetField("_mapCache", BindingFlags.Instance | BindingFlags.NonPublic)!.GetValue(router)!;
        maps[1] = new MapDefinition { Name = "Wire test", Tiles = Enumerable.Range(0, 192).Select(_ => new TileDefinition()).ToList() };
        int id = 0;
        host.Connected += (connectionId, _) => {
            id = connectionId;
            var player = new PlayerCharacter { Name = "self", Map = 1, X = 1, Y = 1, Direction = 3, Access = 4, HP = 42 };
            var session = new PlayerSession { ConnectionId = id, Character = player, IsPlaying = true, IsLoggedIn = true };
            session.NetworkState.Begin(new(1, 32, 32, 3), 0, NetworkClock.Seconds);
            sessions[id] = session;
        };
        var received = new Queue<(string Command, string Json)>();
        var client = new Telepathy.Client(1024 * 1024) { NoDelay = true };
        client.OnData = segment => {
            var packet = PacketCodec.SplitPacket(Encoding.UTF8.GetString(segment.AsSpan()));
            if (packet[0] is "worldstate" or "worldtick") received.Enqueue((packet[0], packet[1]));
        };
        host.Start();
        try
        {
            client.Connect("127.0.0.1", port);
            async Task PumpUntil(Func<bool> condition)
            {
                var end = DateTime.UtcNow.AddSeconds(5);
                while (!condition())
                {
                    host.Tick(); client.Tick(1000);
                    if (DateTime.UtcNow >= end) throw new TimeoutException("Loopback network test timed out.");
                    await Task.Delay(5);
                }
            }
            await PumpUntil(() => id != 0);
            var session = sessions[id];
            await router.HandleAsync(id, PacketCodec.Compose("needmap"));
            await PumpUntil(() => received.Count > 0);
            var full = received.Dequeue();
            var scene = JsonSerializer.Deserialize<FnaWorldScene>(full.Json)!;
            check(full.Command == "worldstate" && scene.Map?.Tiles.Count == 192 && scene.NetworkEpoch.Length == 32,
                "full map snapshot uses production client-compatible wire format");
            using var graphics = new FnaGraphicsService();
            check(graphics.SetWorldScene(scene) && graphics.NetworkState.IsActive, "production graphics accepts initial snapshot");
            var replacement = JsonSerializer.Deserialize<FnaWorldScene>(full.Json)!;
            replacement.Map!.Name = "Updated map";
            check(graphics.SetWorldScene(replacement), "map save at same tick is accepted");
            string epoch = scene.NetworkEpoch;
            await router.HandleAsync(id, PacketCodec.Compose("netping", epoch, scene.ServerTick, scene.AckInputSequence, 1));
            await router.HandleAsync(id, PacketCodec.Compose("playermove", 3, 1, 2, scene.ServerTick, scene.AckInputSequence, epoch));
            check(session.Character!.PixelX == 36, "router accepts ticked movement from cached map without database");
            await router.HandleAsync(id, PacketCodec.Compose("playermove", 3, 1, 2, scene.ServerTick, scene.AckInputSequence, epoch));
            check(session.Character.PixelX == 36, "router duplicate movement is idempotent");
            for (int tick = 0; tick < 3; tick++) router.Tick();
            await PumpUntil(() => received.Count > 0);
            var compact = received.Dequeue();
            var moved = JsonSerializer.Deserialize<FnaWorldScene>(compact.Json)!;
            check(compact.Command == "worldtick" && moved.Map == null && moved.AckInputSequence == 1 && moved.Player.PixelX == 36,
                "movement snapshots acknowledge inputs and omit map data");
            check(graphics.SetWorldScene(moved) && moved.Map?.Name == "Updated map", "compact snapshot reuses cached edited map");
            var invalidScene = JsonSerializer.Deserialize<FnaWorldScene>(compact.Json)!;
            invalidScene.Player.PixelX = -1;
            bool invalidRejected = false;
            try { graphics.SetWorldScene(invalidScene); } catch (JsonException) { invalidRejected = true; }
            check(invalidRejected, "production graphics rejects invalid network coordinates");
            graphics.NetworkState.Rollback();
            var delayed = JsonSerializer.Deserialize<FnaWorldScene>(compact.Json)!;
            delayed.ServerTick++;
            check(graphics.SetWorldScene(delayed) && !graphics.NetworkState.IsActive, "delayed graphics snapshot cannot resume a stalled epoch");
            check(compact.Json.Length < full.Json.Length / 4 && !compact.Json.Contains("Inventory"),
                "frequent snapshots avoid map and inventory bandwidth");
            await router.HandleAsync(id, PacketCodec.Compose("netping", epoch, moved.ServerTick, 1, 3));
            await router.HandleAsync(id, PacketCodec.Compose("playermove", 3, 2, 4, moved.ServerTick, 1, epoch));
            check(session.Character.PixelX == 40, "router accepts unconfirmed next movement");
            await router.HandleAsync(id, PacketCodec.Compose("playermove", 3, 4, 5, moved.ServerTick, 1, epoch));
            check(session.Character.PixelX == 36 && session.NetworkState.Frozen && session.NetworkState.Epoch != epoch,
                "improper sequence rolls movement back to acknowledged snapshot");
            check(session.Character.HP == 42 && session.Character.Access == 4, "network rollback preserves nonmovement state");
            await router.HandleAsync(id, PacketCodec.Compose("playermove", 3, 3, 6, moved.ServerTick, 1, epoch));
            check(session.Character.PixelX == 36, "router discards delayed movement from retired epoch");

            // A stall uses deterministic timestamps rather than waiting two seconds.
            session.NetworkState.Begin(new(1, 36, 32, 3), 3, NetworkClock.Seconds - 3);
            epoch = session.NetworkState.Epoch;
            session.NetworkState.Acknowledge(epoch, 3, 0, NetworkClock.Seconds - 3);
            session.Character.PixelX = 88;
            router.Tick();
            check(session.Character.PixelX == 36 && session.NetworkState.Frozen, "host tick rolls back inactive connection");
            string resumed = session.NetworkState.Epoch;
            long confirmedTick = session.NetworkState.Confirmed.Tick;
            await router.HandleAsync(id, PacketCodec.Compose("netping", resumed, confirmedTick, 0, 7));
            check(!session.NetworkState.Frozen, "heartbeat for restored epoch resumes connection");
            await router.HandleAsync(id, PacketCodec.Compose("warptotile", 5, 4));
            check(session.Character.PixelX == 160 && session.Character.PixelY == 128 && session.NetworkState.Epoch != resumed,
                "authoritative teleport starts a fresh network epoch");
            router.RollbackConnection(id);
            check(session.Character.PixelX == 160 && session.Character.PixelY == 128, "rollback cannot undo authoritative teleport");
            epoch = session.NetworkState.Epoch;
            confirmedTick = session.NetworkState.Confirmed.Tick;
            await router.HandleAsync(id, PacketCodec.Compose("netping", epoch, confirmedTick, 0, 8));
            await router.HandleAsync(id, PacketCodec.Compose("playermove", "broken", 1, 9, confirmedTick, 0, epoch));
            check(session.NetworkState.Frozen && session.Character.PixelX == 160, "malformed movement triggers bounded rollback");
            check(maps.Count == 1, "movement and map requests share cache");
        }
        finally { client.Disconnect(); host.Stop(); }
    }
}
