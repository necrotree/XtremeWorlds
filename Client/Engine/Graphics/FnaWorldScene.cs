using System.Collections.Generic;
using System.Linq;

namespace XtremeWorlds.Client.Engine.Graphics;

// Matches the map definition stored by the server, delivered as JSON in worldstate.
public sealed class FnaWorldScene
{
    public int MapId { get; set; }
    public long ServerTick { get; set; }
    public long AckInputSequence { get; set; }
    public int TickRate { get; set; } = 60;
    public string NetworkEpoch { get; set; } = string.Empty;
    public bool NetworkFrozen { get; set; }
    public FnaSceneMap? Map { get; set; }
    public FnaScenePlayer Player { get; set; } = new();
    public List<FnaScenePlayer> Players { get; set; } = new();
    public List<FnaScenePlayer> Npcs { get; set; } = new();
    public List<FnaSceneItem> Items { get; set; } = new();
    public List<FnaSceneChatBubble> ChatBubbles { get; set; } = new();
    public List<FnaSceneQuestBlip> QuestBlips { get; set; } = new();
    public List<FnaSceneEmote> Emotes { get; set; } = new();
    public List<FnaSceneSpell> Spells { get; set; } = new();
    public IEnumerable<FnaScenePlayer> ActorsInDrawOrder() =>
        Players.Where(p => p.Name != Player.Name)
            .Concat(string.IsNullOrEmpty(Player.Name) ? System.Array.Empty<FnaScenePlayer>() : new[] { Player })
            .Concat(Npcs).OrderBy(p => p.DrawY);
}

public sealed class FnaSceneMap
{
    public List<FnaMapItemSpawn> ItemSpawns { get; set; } = new();
    public string Name { get; set; } = string.Empty;
    public int Tileset { get; set; }
    public List<int> LayerTileset { get; set; } = new();
    public List<FnaSceneTile> Tiles { get; set; } = new();
}

public sealed class FnaSceneTile
{
    public List<int> LayerTileset { get; set; } = new();
    public int Type { get; set; }
    public int Anim { get; set; }
    public int M2Anim { get; set; }
    public int FAnim { get; set; }
    public int F2Anim { get; set; }
    public bool DoorOpen { get; set; }
    public int Ground { get; set; }
    public int Mask { get; set; }
    public int Mask2 { get; set; }
    public int Fringe { get; set; }
    public int Fringe2 { get; set; }
}

public sealed class FnaScenePlayer
{
    public string TargetId { get; set; } = "";
    public string TargetKey => TargetId.Length > 0 ? TargetId : Name;
    public int HP { get; set; } = 1;
    public int MaxHP { get; set; } = 1;
    public double? AttackAgeSeconds { get; set; }
    public string Name { get; set; } = string.Empty;
    public int Sprite { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public int Direction { get; set; }
    public bool Attacking { get; set; }
    public double AttackStartedSeconds { get; set; }
    public int AnimationFrame(double seconds)
    {
        if (Attacking && seconds >= AttackStartedSeconds && seconds - AttackStartedSeconds < 0.5) return 2;
        int offsetX = (DrawX % 32 + 32) % 32;
        int offsetY = (DrawY % 32 + 32) % 32;
        return ((offsetX + offsetY) / 8) % 3;
    }
    public double? PixelX { get; set; }
    public double? PixelY { get; set; }
    public int DrawX => (int)System.Math.Floor(PixelX ?? X * 32.0);
    public int DrawY => (int)System.Math.Floor(PixelY ?? Y * 32.0);
}

public sealed class FnaSceneItem
{
    public string Name { get; set; } = "";
    public int ItemId { get; set; }
    public int Quantity { get; set; }
    public int Id { get; set; }
    public int Picture { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
}

public sealed class FnaSceneSpell
{
    public int Animation { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public double? AgeSeconds { get; set; }
    public double StartedSeconds { get; set; }
    public const int FrameCount = 12;
    public const int FrameWidth = 96;
    public const int FrameHeight = 128;
    public int Frame(double seconds) => seconds < StartedSeconds ? -1 : (int)((seconds - StartedSeconds) / 0.075);
}

public sealed class FnaSceneEmote
{
    public string PlayerName { get; set; } = "";
    public int Picture { get; set; }
    public double RemainingSeconds { get; set; }
    public double ReceivedSeconds { get; set; }
}

public sealed class FnaSceneChatBubble
{
    public string PlayerName { get; set; } = "";
    public string Text { get; set; } = "";
    public double RemainingSeconds { get; set; }
    public double ReceivedSeconds { get; set; }
}
public sealed class FnaSceneQuestBlip
{
    public int QuestId { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public int Sprite { get; set; }
    public string Name { get; set; } = "";
    public string Status { get; set; } = "available";
}

public sealed class FnaMapItemSpawn
{
    public int ItemId { get; set; }
    public int Quantity { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public double RespawnSeconds { get; set; }
}
