namespace XtremeWorlds.Client.Engine.Graphics;

public sealed class FnaGameplayState
{
    public bool IsChargingMana { get; set; }
    public bool CanEditMap { get; set; }
    public int UnlockedBags { get; set; } = 1;
    public List<FnaQuestStatus> Quests { get; set; } = new();
    public int HP { get; set; }
    public int MP { get; set; }
    public int SP { get; set; }
    public int MaxHP { get; set; } = 100;
    public int MaxMP { get; set; } = 50;
    public int MaxSP { get; set; } = 100;
    public List<FnaInventorySlot> Inventory { get; set; } = new();
    public List<FnaKnownSpell> KnownSpells { get; set; } = new();
}
public sealed class FnaInventorySlot
{
    public int Slot { get; set; }
    public int ItemId { get; set; }
    public int Quantity { get; set; }
    public string Name { get; set; } = "";
    public int Picture { get; set; }
    public bool Equipped { get; set; }
}
public sealed class FnaKnownSpell
{
    public int Slot { get; set; }
    public int SpellId { get; set; }
    public string Name { get; set; } = "";
    public int Animation { get; set; }
    public int ManaCost { get; set; }
}

public sealed class FnaQuestStatus
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public string Status { get; set; } = "available";
    public int Map { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public int Current { get; set; }
    public int Required { get; set; }
    public int RewardExperience { get; set; }
}
