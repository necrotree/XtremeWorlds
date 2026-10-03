using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using Server;

static class MapRetrievalTest
{
    public static async Task Run()
    {
        var probe = new TcpListener(IPAddress.Loopback, 0);
        probe.Start();
        int port = ((IPEndPoint)probe.LocalEndpoint).Port;
        using var listener = probe;
        using var repository = new SpacetimeRepository(new ServerSettings
        {
            SpacetimeUri = $"http://127.0.0.1:{port}", SpacetimeDatabase = "test",
            SpacetimeConnectTimeoutSeconds = 5
        });
        var loaded = repository.GetContentAsync<MapDefinition>("map", 7);
        var request = await listener.AcceptTcpClientAsync().WaitAsync(TimeSpan.FromSeconds(5));
        string sql = await ReadRequest(request);
        if (!sql.Contains("kind = 'map' AND numeric_id = 7 LIMIT 1"))
            throw new Exception("Map lookup must select only the requested map.");
        // Imported JSON can use lowercase properties.
        await Respond(request, "[{\"rows\":[[\"{\\\"name\\\":\\\"Stored map\\\",\\\"tiles\\\":[{\\\"ground\\\":42}]}\"]]}]");
        var map = await loaded;
        if (map?.Name != "Stored map" || map.Tiles[0].Ground != 42)
            throw new Exception("Stored map JSON was not decoded.");
        var missing = repository.GetContentAsync<MapDefinition>("map", 8);
        request = await listener.AcceptTcpClientAsync().WaitAsync(TimeSpan.FromSeconds(5));
        await ReadRequest(request);
        await Respond(request, "[{\"rows\":[]}]");
        if (await missing is not null) throw new Exception("Absent map must return null.");
        var player = new PlayerCharacter { Map = 8, X = 1, Y = 1, Access = 1 };
        var sessions = new System.Collections.Concurrent.ConcurrentDictionary<int, PlayerSession>();
        sessions[1] = new PlayerSession { ConnectionId = 1, IsPlaying = true, IsLoggedIn = true, Character = player };
        var router = new PacketRouter(new ServerSettings(), new MirrorTcpHost(0, 65536, true), repository, sessions);
        async Task Dispatch(string packet)
        {
            var handling = router.HandleAsync(1, packet);
            var pending = await listener.AcceptTcpClientAsync().WaitAsync(TimeSpan.FromSeconds(5));
            await ReadRequest(pending);
            await Respond(pending, "[{\"rows\":[]}]");
            await handling;
        }
        await Dispatch(PacketCodec.Compose("playermove", 2));
        if (player.PixelX != 28 || player.X != 0 || player.Y != 1)
            throw new Exception("Pixel movement must floor the tile position when moving left.");
        await Dispatch(PacketCodec.Compose("warpto", 9, 3, 4));
        if (player.Map != 9 || player.X != 3 || player.Y != 4 || player.PixelX != 96 || player.PixelY != 128)
            throw new Exception("Teleport must reset pixel and tile positions together.");
        await Dispatch(PacketCodec.Compose("warptotile", 15, 11));
        if (player.Map != 9 || player.X != 15 || player.Y != 11 || player.PixelX != 480 || player.PixelY != 352)
            throw new Exception("Tile teleport must use the current map and reset pixel positions.");
        await router.HandleAsync(1, PacketCodec.Compose("warptotile", 16, 12));
        await router.HandleAsync(1, PacketCodec.Compose("warptotile", "invalid", 0));
        player.Access = 0;
        await router.HandleAsync(1, PacketCodec.Compose("warptotile", 0, 0));
        player.Access = 1;
        if (player.PixelX != 480 || player.PixelY != 352)
            throw new Exception("Invalid and unauthorized tile teleports must be rejected.");
        sessions[1].IsJailed = true;
        await router.HandleAsync(1, PacketCodec.Compose("playermove", 3));
        await router.HandleAsync(1, PacketCodec.Compose("warptotile", 0, 0));
        if (player.PixelX != 480 || player.PixelY != 352) throw new Exception("Jailed players must not move or teleport.");
        Console.WriteLine("Pixel movement, floor conversion, teleport and jail checks passed.");
        Console.WriteLine("Targeted map database retrieval checks passed.");
    }

    private static async Task<string> ReadRequest(TcpClient request)
    {
        var reader = new StreamReader(request.GetStream(), Encoding.UTF8, leaveOpen: true);
        int length = 0;
        string? line;
        while (!string.IsNullOrEmpty(line = await reader.ReadLineAsync()))
            if (line.StartsWith("Content-Length:", StringComparison.OrdinalIgnoreCase))
                length = int.Parse(line.Split(':')[1].Trim());
        var body = new char[length];
        int offset = 0;
        while (offset < length)
        {
            int count = await reader.ReadAsync(body.AsMemory(offset));
            if (count == 0) throw new EndOfStreamException();
            offset += count;
        }
        return new string(body);
    }

    private static async Task Respond(TcpClient request, string body)
    {
        byte[] bytes = Encoding.UTF8.GetBytes(body);
        var header = Encoding.ASCII.GetBytes($"HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: {bytes.Length}\r\nConnection: close\r\n\r\n");
        await request.GetStream().WriteAsync(header);
        await request.GetStream().WriteAsync(bytes);
        request.Dispose();
    }
}
