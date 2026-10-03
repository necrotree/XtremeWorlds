using System.Collections.Generic;

namespace XtremeWorlds.Client.Engine.Graphics;

// Matches the map definition stored by the server, delivered as JSON in worldstate.
public sealed class FnaWorldScene
{
    public FnaSceneMap? Map { get; set; }
    public FnaScenePlayer Player { get; set; } = new();
}

public sealed class FnaSceneMap
{
    public string Name { get; set; } = string.Empty;
    public int Tileset { get; set; }
    public List<int> LayerTileset { get; set; } = new();
    public List<FnaSceneTile> Tiles { get; set; } = new();
}

public sealed class FnaSceneTile
{
    public int Ground { get; set; }
    public int Mask { get; set; }
    public int Mask2 { get; set; }
    public int Fringe { get; set; }
    public int Fringe2 { get; set; }
}

public sealed class FnaScenePlayer
{
    public string Name { get; set; } = string.Empty;
    public int Sprite { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public int Direction { get; set; }
}
