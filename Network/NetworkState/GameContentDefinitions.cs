namespace XtremeWorlds.Networking.Content
{
    public class ItemContent
    {
        public int AttackBonus { get; set; }
        public int DefenseBonus { get; set; }
        public string Name { get; set; } = "";
        public short Pic { get; set; }
        public byte Type { get; set; }
        public int Data1 { get; set; }
        public int Data2 { get; set; }
        public int Data3 { get; set; }
        public short ClassReq { get; set; }
        public short LevelReq { get; set; }
        public short GuildReq { get; set; }
        public short Sound { get; set; }
    }

    public class NpcContent
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
        public int DropItemValue { get; set; }
        public short Strength { get; set; }
        public short Defense { get; set; }
        public short Speed { get; set; }
        public short Magic { get; set; }
        public byte Stationary { get; set; }
    }


    public sealed class ContentSummary
    {
        public int Id { get; set; }
        public string Name { get; set; } = "";
    }
}
