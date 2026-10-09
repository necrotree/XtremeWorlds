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
scene.Player.PixelY = 64;
scene.Players.Add(new FnaScenePlayer { Name = "Other", PixelY = 96 });
scene.Players.Add(scene.Player);
scene.Npcs.Add(new FnaScenePlayer { Name = "NPC", PixelY = 32 });
if (!scene.ActorsInDrawOrder().Select(p => p.Name).SequenceEqual(new[] { "NPC", "Player", "Other" }))
    throw new Exception("Players and NPCs must share stable Y order without duplicating the local player.");
var walking = new FnaScenePlayer { PixelX = -4, PixelY = 0 };
if (walking.AnimationFrame(0) != 0) throw new Exception("Negative movement must use positive pixel remainders.");
walking.PixelX = 8;
if (walking.AnimationFrame(0) != 1) throw new Exception("Walking frame must advance every eight pixels.");
walking.Attacking = true;
walking.AttackStartedSeconds = 10;
if (walking.AnimationFrame(10.25) != 2 || walking.AnimationFrame(11) != 1)
    throw new Exception("Attack animation must expire.");
var effect = new FnaSceneSpell { StartedSeconds = 10 };
if (effect.Frame(9) != -1 || effect.Frame(10) != 0 || effect.Frame(10.91) < FnaSceneSpell.FrameCount)
    throw new Exception("Spell effects must start at frame zero and expire after twelve frames.");
var animatedTile = JsonSerializer.Deserialize<FnaSceneTile>(JsonSerializer.Serialize(new Server.TileDefinition
    { Anim = 21, M2Anim = 22, FAnim = 23, F2Anim = 24 }))!;
if (animatedTile.Anim != 21 || animatedTile.M2Anim != 22 || animatedTile.FAnim != 23 || animatedTile.F2Anim != 24)
    throw new Exception("Animated map layers must survive the snapshot.");
Console.WriteLine("Actor depth order, movement animation, spell lifetime and animated tile checks passed.");
await MapRetrievalTest.Run();
