using System.Text;
using System.Text.Json;
using XtremeWorlds.Client.Engine.Graphics;
using XtremeWorlds.Networking;

namespace XtremeWorlds.Client.Engine.Networking;

/// <summary>Shared transport, world packets, prediction and recovery for desktop and browser clients.</summary>
public sealed class GameClientConnection : IDisposable
{
    private readonly FnaGraphicsService _graphics;
    private double _nextHeartbeat;
    private bool _resyncRequested;
    public MirrorTcpClient Transport { get; } = new();
    public event Action<IReadOnlyList<string>>? PacketReceived;
    public event Action<FnaWorldScene>? WorldSceneReceived;
    public Func<FnaWorldScene, FnaWorldScene>? WorldSceneTransform { get; set; }

    public GameClientConnection(FnaGraphicsService graphics)
    {
        _graphics = graphics;
        Transport.DataReceived += (_, packet) => Receive(PacketCodec.Parse(Encoding.UTF8.GetString(packet.Data)));
        Transport.Disconnected += (_, _) => _graphics.NetworkState.Rollback();
    }
    public void Receive(IReadOnlyList<string> fields)
    {
        if (fields.Count == 0) return;
        switch (fields[0].Trim().ToLowerInvariant())
        {
            case "worldstate":
            case "worldtick":
                try
                {
                    var scene = JsonSerializer.Deserialize<FnaWorldScene>(fields.Count > 1 ? fields[1] : "");
                    if (scene == null) throw new JsonException("Missing world state.");
                    if (WorldSceneTransform is not null) scene = WorldSceneTransform(scene);
                    if (_graphics.SetWorldScene(scene) && _graphics.NetworkState.IsActive) _resyncRequested = false;
                    WorldSceneReceived?.Invoke(scene);
                }
                catch (JsonException) { Resync(); }
                return;
            case "ingame":
                Reset();
                PacketReceived?.Invoke(fields);
                if (Transport.IsConnected) Transport.SendText(PacketCodec.Build("needmap"));
                return;
        }
        PacketReceived?.Invoke(fields);
    }
    public void Tick()
    {
        Transport.Tick(128);
        while (Transport.TryDequeue(out _)) { }
        double now = NetworkClock.Seconds;
        if (!Transport.IsConnected || _graphics.NetworkState.Latest == null) return;
        if (_graphics.NetworkState.IsInactive(now, 2)) Resync();
        if (now >= _nextHeartbeat) { _nextHeartbeat = now + .25; Control("netping"); }
    }
    public bool Move(int direction)
    {
        if (!Transport.IsConnected || _graphics.NetworkState.IsInactive(NetworkClock.Seconds, 2)
            || !_graphics.NetworkState.TryInput(direction, (long)(NetworkClock.Seconds * 60), out var input)) return false;
        Transport.SendText(PacketCodec.Build("playermove", input.Direction, input.Sequence, input.ClientTick,
            input.AckTick, input.AckSequence, input.Epoch));
        return true;
    }
    public bool HandleAction(string action, object[] arguments)
    {
        if (action == "MovePlayer") { if (arguments.Length > 0) Move(Convert.ToInt32(arguments[0])); return true; }
        string? command = action switch {
            "UseInventoryItem" => "useitem", "CastSpell" => "cast", "ForgetSpell" => "forgetspell",
            "TrainStat" => "usestatpoint", "ToggleInventory" => "getinv", "ToggleSpells" => "spells",
            "ToggleStats" or "ToggleTrain" => "getlivestats", "SendWhosOnline" => "whosonline", _ => null
        };
        if (command == null) return false;
        if (!Transport.IsConnected) return true;
        if (action is "UseInventoryItem" or "CastSpell" or "ForgetSpell")
            Transport.SendText(PacketCodec.Build(command, Convert.ToInt32(arguments[0]) + 1));
        else if (action == "TrainStat") Transport.SendText(PacketCodec.Build(command, arguments[0]));
        else Transport.SendText(PacketCodec.Build(command));
        return true;
    }
    private void Resync()
    {
        _graphics.NetworkState.Rollback();
        if (_resyncRequested || !Transport.IsConnected) return;
        _resyncRequested = true;
        Control("netresync");
    }
    private void Control(string command)
    {
        if (_graphics.NetworkState.Latest is not { } latest) return;
        Transport.SendText(PacketCodec.Build(command, latest.Epoch, latest.Tick, latest.AckSequence, (long)(NetworkClock.Seconds * 60)));
    }
    public void Reset() { _graphics.ResetNetworkState(); _resyncRequested = false; _nextHeartbeat = 0; }
    public void Dispose() { Transport.Dispose(); Reset(); }
}
