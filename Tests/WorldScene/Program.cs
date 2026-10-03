using System.Text.Json;
using XtremeWorlds.Client.Engine.Graphics;

var map = new Server.MapDefinition
{
    Name = "Test map", Tileset = 2,
    LayerTileset = new() { 1, 2, 3, 4, 5 },
    Tiles = Enumerable.Range(0, 192).Select(i => new Server.TileDefinition
    {
        Ground = (short)i, Mask = 17, Mask2 = 18, Fringe = 19, Fringe2 = 20
    }).ToList()
};
var player = new Server.PlayerCharacter { Name = "Player", Sprite = 4, X = 15, Y = 11, Direction = 3 };
var packet = Server.PacketCodec.Compose("worldstate", JsonSerializer.Serialize(new { Map = map, Player = player }));
var fields = XtremeWorlds.Client.Engine.Networking.PacketCodec.Parse(packet);
if (XtremeWorlds.Client.Engine.Networking.PacketCodec.Parse(Server.PacketCodec.Compose("ingame"))[0] != "ingame"
    || XtremeWorlds.Client.Engine.Networking.PacketCodec.Parse("ingame" + (char)237)[0] != "ingame")
    throw new Exception("Both current and legacy packet terminators must be accepted.");
var scene = JsonSerializer.Deserialize<FnaWorldScene>(fields[1])!;
if (fields[0] != "worldstate" || scene.Map?.Tiles.Count != 192 || scene.Map.Tiles[191].Ground != 191
    || scene.Map.LayerTileset[4] != 5 || scene.Map.Tiles[0].Fringe2 != 20
    || scene.Player.Sprite != 4 || scene.Player.X != 15 || scene.Player.Y != 11 || scene.Player.Direction != 3)
    throw new Exception("Server world snapshot did not survive client packet decoding.");
var missing = JsonSerializer.Deserialize<FnaWorldScene>(JsonSerializer.Serialize(new { Map = (Server.MapDefinition?)null, Player = player }))!;
if (missing.Map is not null || missing.Player.Name != "Player")
    throw new Exception("Missing maps must preserve the player and remain explicit.");
Console.WriteLine("World scene protocol checks passed.");
await MapRetrievalTest.Run();
