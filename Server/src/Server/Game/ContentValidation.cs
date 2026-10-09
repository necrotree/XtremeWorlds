namespace Server;

public static class ContentValidation
{
    private static bool ValidName(string name) => !string.IsNullOrWhiteSpace(name) && name.Trim().Length <= 50 && !name.Any(char.IsControl);
    public static string? Item(ItemDefinition item, ServerSettings limits, IReadOnlyDictionary<int,SpellDefinition> spells)
    {
        if (!ValidName(item.Name)) return "Enter a name of 1 to 50 characters.";
        if (item.Pic is < 0 or >= 1500 || item.Type > 8) return "Choose a valid item graphic and type.";
        if (item.AttackBonus is < 0 or > 100000 || item.DefenseBonus is < 0 or > 100000) return "Equipment bonuses must be between 0 and 100000.";
        if (item.LevelReq < 0 || item.ClassReq < 0 || item.ClassReq > limits.MaxClasses || item.GuildReq < 0 || item.GuildReq > limits.MaxGuilds || item.Sound < 0)
            return "Invalid item requirements or sound.";
        if (item.Type is >= 4 and <= 6 && item.Data1 <= 0) return "Potions need a positive restoration amount.";
        if (item.Type == 8 && !spells.ContainsKey(item.Data1)) return "Choose an existing spell for this spell book.";
        return null;
    }
    public static string? Npc(NpcDefinition npc, IReadOnlyDictionary<int,ItemDefinition> items)
    {
        if (!ValidName(npc.Name)) return "Enter a name of 1 to 50 characters.";
        if (npc.Sprite is < 0 or >= 209 || npc.MaxHP is < 1 or > 1000000 || npc.SpawnSecs is < 1 or > 86400) return "Invalid NPC sprite, health, or respawn time.";
        if (npc.Strength < 0 || npc.Defense < 0 || npc.Speed < 0 || npc.Magic < 0 || npc.GiveEXP is < 0 or > 1000000
            || npc.Behavior > 5 || npc.Stationary > 1 || npc.Range > 32 || npc.ShopCall < 0) return "Invalid NPC stats or behavior.";
        if (npc.DropChance is < 0 or > 100 || npc.DropItemValue is < 0 or > 1000000 || npc.DropItem < 0
            || npc.DropItem > 0 && (!items.ContainsKey(npc.DropItem) || npc.DropItemValue < 1)) return "Choose an existing drop item, positive quantity, and a chance from 0 to 100.";
        if (npc.AttackSay is null || npc.AttackSay.Length > 240 || npc.AttackSay.Any(char.IsControl)) return "NPC battle text is too long or contains invalid characters.";
        return null;
    }
}
