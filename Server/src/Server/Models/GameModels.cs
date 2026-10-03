using System.Collections.Generic;

namespace Server
{

    public static class GameLimits
    {
        public const int NameLength = 50;
        public const int MaxCharacters = 3;
        public const int MaxInventory = 75;
        public const int MaxPlayerSpells = 40;
        public const int MaxMapX = 15;
        public const int MaxMapY = 11;
        public const int MaxMapNpcs = 10;
        public const int MaxMapItems = 20;
        public const int MaxTrades = 8;
    }

    public class PlayerInventory
    {
        public int Num { get; set; }
        public int Value { get; set; }
        public short Durability { get; set; }
    }

    public class PlayerCharacter
    {
        public string Name { get; set; } = "";
        public byte Sex { get; set; }
        public byte ClassId { get; set; }
        public short Sprite { get; set; }
        public int Level { get; set; }
        public int Exp { get; set; }
        public byte Access { get; set; }
        public byte PK { get; set; }
        public int Guild { get; set; }
        public int HP { get; set; }
        public int MP { get; set; }
        public int SP { get; set; }
        public int Strength { get; set; }
        public int Defense { get; set; }
        public int Speed { get; set; }
        public int Magic { get; set; }
        public int Points { get; set; }
        public int ArmorSlot { get; set; }
        public int WeaponSlot { get; set; }
        public int HelmetSlot { get; set; }
        public int ShieldSlot { get; set; }
        public List<PlayerInventory> Inventory { get; set; } = new List<PlayerInventory>();
        public List<int> Spells { get; set; } = new List<int>();
        public short Map { get; set; }
        public byte X { get; set; }
        public byte Y { get; set; }
        public byte Direction { get; set; }
        public double? PixelX { get; set; }
        public double? PixelY { get; set; }
    }

    public class TileDefinition
    {
        public short Ground { get; set; }
        public short Mask { get; set; }
        public short Anim { get; set; }
        public short Mask2 { get; set; }
        public short M2Anim { get; set; }
        public short Fringe { get; set; }
        public short FAnim { get; set; }
        public short Fringe2 { get; set; }
        public short F2Anim { get; set; }
        public byte Type { get; set; }
        public short Data1 { get; set; }
        public short Data2 { get; set; }
        public short Data3 { get; set; }
    }

    public class MapDefinition
    {
        public string Name { get; set; } = "";
        public int Revision { get; set; }
        public byte Moral { get; set; }
        public short Up { get; set; }
        public short Down { get; set; }
        public short Left { get; set; }
        public short Right { get; set; }
        public short Music { get; set; }
        public short BootMap { get; set; }
        public byte BootX { get; set; }
        public byte BootY { get; set; }
        public int Shop { get; set; }
        public byte Indoors { get; set; }
        public byte Respawn { get; set; }
        public byte Tileset { get; set; }
        public List<TileDefinition> Tiles { get; set; } = new List<TileDefinition>();
        public List<int> Npcs { get; set; } = new List<int>();
        public List<byte> LayerTileset { get; set; } = new List<byte>();
    }

    public class ClassDefinition
    {
        public string Name { get; set; } = "";
        public short MaleSprite { get; set; }
        public short FemaleSprite { get; set; }
        public byte Strength { get; set; }
        public byte Defense { get; set; }
        public byte Speed { get; set; }
        public byte Magic { get; set; }
        public short Map { get; set; }
        public byte X { get; set; }
        public byte Y { get; set; }
    }

    public class ItemDefinition
    {
        public string Name { get; set; } = "";
        public short Pic { get; set; }
        public byte Type { get; set; }
        public short Data1 { get; set; }
        public short Data2 { get; set; }
        public short Data3 { get; set; }
        public short ClassReq { get; set; }
        public short LevelReq { get; set; }
        public short GuildReq { get; set; }
        public short Sound { get; set; }
    }

    public class NpcDefinition
    {
        public string Name { get; set; } = "";
        public string AttackSay { get; set; } = "";
        public int MaxHP { get; set; }
        public int GiveEXP { get; set; }
        public int ShopCall { get; set; }
        public short Sprite { get; set; }
        public int SpawnSecs { get; set; }
        public byte Behavior { get; set; }
        public byte Range { get; set; }
        public short DropChance { get; set; }
        public int DropItem { get; set; }
        public short DropItemValue { get; set; }
        public short Strength { get; set; }
        public short Defense { get; set; }
        public short Speed { get; set; }
        public short Magic { get; set; }
        public byte Stationary { get; set; }
    }

    public class ShopTrade
    {
        public int GiveItem { get; set; }
        public int GiveValue { get; set; }
        public int GiveItem2 { get; set; }
        public int GiveValue2 { get; set; }
        public int GetItem { get; set; }
        public int GetValue { get; set; }
    }

    public class ShopDefinition
    {
        public string Name { get; set; } = "";
        public string JoinSay { get; set; } = "";
        public string LeaveSay { get; set; } = "";
        public byte FixesItems { get; set; }
        public List<ShopTrade> Trades { get; set; } = new List<ShopTrade>();
    }

    public class SpellDefinition
    {
        public string Name { get; set; } = "";
        public byte ClassReq { get; set; }
        public short LevelReq { get; set; }
        public int MPReq { get; set; }
        public byte Type { get; set; }
        public short Data1 { get; set; }
        public short Data2 { get; set; }
        public short Data3 { get; set; }
        public short Graphic { get; set; }
        public short Sound { get; set; }
    }

    public class SignDefinition
    {
        public string Name { get; set; } = "";
        public string Line1 { get; set; } = "";
        public string Line2 { get; set; } = "";
        public string Line3 { get; set; } = "";
        public byte Background { get; set; }
    }

    public class GuildDefinition
    {
        public string Name { get; set; } = "";
        public string Founder { get; set; } = "";
        public string Abbreviation { get; set; } = "";
        public List<string> Members { get; set; } = new List<string>();
    }

    public class QuestDefinition
    {
        public string Name { get; set; } = "";
        public List<string> Players { get; set; } = new List<string>();
    }

    public class ArrowDefinition
    {
        public string Name { get; set; } = "";
        public int Sprite { get; set; }
        public int Range { get; set; }
    }

    public class BanDefinition
    {
        public string BannedIP { get; set; } = "";
        public string BannedCharacter { get; set; } = "";
        public string BannedBy { get; set; } = "";
        public string BannedHardwareId { get; set; } = "";
    }
}
