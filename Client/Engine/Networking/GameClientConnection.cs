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
            case "combatresult":
                if (fields.Count > 3 && bool.TryParse(fields[3],out var stop) && stop
                    && (fields[1].Length == 0 || string.Equals(fields[1],_graphics.SelectedTarget,StringComparison.OrdinalIgnoreCase))) _graphics.StopAutoAttack();
                if (fields.Count > 2) _graphics.AddChatMessage("Map",fields[2]);
                PacketReceived?.Invoke(fields);
                return;
            case "gameplaystate":
                try { _graphics.GameplayState = JsonSerializer.Deserialize<FnaGameplayState>(fields.Count > 1 ? fields[1] : "") ?? new(); }
                catch (JsonException) { Resync(); }
                PacketReceived?.Invoke(fields);
                return;
            case "worldstate":
            case "worldtick":
                try
                {
                    var scene = JsonSerializer.Deserialize<FnaWorldScene>(fields.Count > 1 ? fields[1] : "");
                    if (scene == null) throw new JsonException("Missing world state.");
                    if (WorldSceneTransform is not null) scene = WorldSceneTransform(scene);
                    if (_graphics.SetWorldScene(scene))
                    {
                        if (_graphics.NetworkState.IsActive) _resyncRequested = false;
                        WorldSceneReceived?.Invoke(scene);
                    }
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
    public bool HandleGameplayChat(string text)
    {
        var parts = text.Trim().Split(' ', 3, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length == 0) return false;
        string? action = parts[0].ToLowerInvariant() switch {
            "/quests" => "RequestQuests", "/acceptquest" => "AcceptQuest", "/completequest" => "CompleteQuest", "/emote" => "SendEmote", "/sprite" => "SelectSprite", "/pickup" => "PickUpItem",
            "/use" => "UseInventoryItem", "/drop" => "DropInventoryItem", "/cast" => "CastSpell", _ => null
        };
        if (action is null) return false;
        if (action is "PickUpItem" or "RequestQuests") { HandleAction(action, Array.Empty<object>()); return true; }
        if (parts.Length < 2 || !int.TryParse(parts[1], out int number)
            || (action == "SelectSprite" ? number is < 0 or >= 209 : number < 1))
        {
            _graphics.AddChatMessage("Map", "Use a valid number after " + parts[0] + ". Slots and emotes start at 1; sprites start at 0.");
            return true;
        }
        int index = action is "SelectSprite" or "AcceptQuest" or "CompleteQuest" ? number : number - 1;
        HandleAction(action, action == "CastSpell" && parts.Length > 2 ? new object[] { index, parts[2] } : new object[] { index });
        return true;
    }

    public bool HandleAction(string action, object[] arguments)
    {
        if (action == "SendChatChannel" && arguments.Length > 1 && HandleGameplayChat(Convert.ToString(arguments[1]) ?? "")) return true;
        if (action == "MovePlayer") { if (arguments.Length > 0) Move(Convert.ToInt32(arguments[0])); return true; }
        string? command = action switch {
            "ChargeMana" => "chargemana", "AddMapItemSpawn" => "spawnmapitem", "RemoveMapItemSpawn" => "removemapitemspawn", "AttackTarget" => "attack", "RequestQuests" or "OpenQuest" => "quests", "AcceptQuest" => "acceptquest", "CompleteQuest" => "completequest", "SendEmote" => "emote", "SelectSprite" => "playersprite", "PickUpItem" => "mapgetitem", "DropInventoryItem" => "mapdropitem", "UseInventoryItem" => "useitem", "CastSpell" => "cast", "ForgetSpell" => "forgetspell",
            "TrainStat" => "usestatpoint", "ToggleInventory" => "getinv", "ToggleSpells" => "spells",
            "ToggleStats" or "ToggleTrain" => "getlivestats", "SendWhosOnline" => "whosonline", _ => null
        };
        if (command == null) return false;
        if (!Transport.IsConnected) return true;
        if (action is "AddMapItemSpawn" or "RemoveMapItemSpawn") Transport.SendText(PacketCodec.Build(command,arguments));
        else if (action is "UseInventoryItem" or "CastSpell" or "ForgetSpell" or "DropInventoryItem")
        {
            if (arguments.Length == 0 || !int.TryParse(Convert.ToString(arguments[0]), out int slot) || slot < 0) return true;
            if (action == "CastSpell" && arguments.Length > 1 && !string.IsNullOrWhiteSpace(Convert.ToString(arguments[1])))
                Transport.SendText(PacketCodec.Build(command, slot + 1, arguments[1]));
            else Transport.SendText(PacketCodec.Build(command, slot + 1));
        }
        else if (action is "ChargeMana" or "AttackTarget" or "SendEmote" or "SelectSprite" or "AcceptQuest" or "CompleteQuest")
        {
            if (arguments.Length > 0) Transport.SendText(PacketCodec.Build(command, arguments[0]));
        }
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
    public void Reset() { _graphics.StopManaCharging(); _graphics.StopAutoAttack(); _graphics.SelectTarget(""); _graphics.GameplayState = new(); _graphics.ResetNetworkState(); _resyncRequested = false; _nextHeartbeat = 0; }
    public void Dispose() { Transport.Dispose(); Reset(); }
}
