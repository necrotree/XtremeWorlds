namespace Server;

// Legacy IDs: weapon, armor, helmet, shield, HP/MP/SP potion, currency, spell book.
public static class GameplayRules
{
    public static string? UseItem(PlayerCharacter player, int slot, IReadOnlyDictionary<int, ItemDefinition> items,
        IReadOnlyDictionary<int, SpellDefinition> spells)
    {
        if (slot < 1 || slot > player.Inventory.Count) return "Invalid inventory slot.";
        var stack = player.Inventory[slot - 1];
        if (stack.Value <= 0 || !items.TryGetValue(stack.Num, out var item)) return "That slot is empty.";
        if (player.Level < item.LevelReq || (item.ClassReq > 0 && player.ClassId != item.ClassReq)
            || (item.GuildReq > 0 && player.Guild != item.GuildReq)) return "You do not meet this item's requirements.";
        if (item.Type <= 3)
        {
            switch (item.Type)
            {
                case 0: player.WeaponSlot = player.WeaponSlot == slot ? 0 : slot; break;
                case 1: player.ArmorSlot = player.ArmorSlot == slot ? 0 : slot; break;
                case 2: player.HelmetSlot = player.HelmetSlot == slot ? 0 : slot; break;
                case 3: player.ShieldSlot = player.ShieldSlot == slot ? 0 : slot; break;
            }
            return null;
        }
        switch (item.Type)
        {
            case 4:
                if (item.Data1 <= 0 || player.HP >= player.MaxHP) return "Health is already full.";
                player.HP = Restore(player.HP, item.Data1, player.MaxHP); break;
            case 5:
                if (item.Data1 <= 0 || player.MP >= player.MaxMP) return "Mana is already full.";
                player.MP = Restore(player.MP, item.Data1, player.MaxMP); break;
            case 6:
                if (item.Data1 <= 0 || player.SP >= player.MaxSP) return "Stamina is already full.";
                player.SP = Restore(player.SP, item.Data1, player.MaxSP); break;
            case 8:
                if (!spells.TryGetValue(item.Data1, out var spell)) return "This book has no valid spell.";
                if (player.Spells.Contains(item.Data1)) return "You already know this spell.";
                if (player.Spells.Count >= GameLimits.MaxPlayerSpells && !player.Spells.Contains(0)) return "Your spell book is full.";
                if (player.Level < spell.LevelReq || (spell.ClassReq > 0 && spell.ClassReq != player.ClassId))
                    return "You do not meet this spell's requirements.";
                int emptySpell = player.Spells.IndexOf(0);
                if (emptySpell >= 0) player.Spells[emptySpell] = item.Data1; else player.Spells.Add(item.Data1);
                break;
            default: return "This item cannot be used.";
        }
        stack.Value--;
        if (stack.Value == 0) stack.Num = 0;
        return null;
    }
    public static string? Cast(PlayerCharacter caster, PlayerCharacter target, SpellDefinition spell)
    {
        if (caster.HP <= 0 || target.HP <= 0) return "The caster and target must be alive.";
        if (caster.Level < spell.LevelReq || (spell.ClassReq > 0 && spell.ClassReq != caster.ClassId))
            return "You do not meet this spell's requirements.";
        if (spell.MPReq < 0 || caster.MP < spell.MPReq) return "Not enough mana.";
        if (caster.Map != target.Map || Math.Max(Math.Abs(caster.X - target.X), Math.Abs(caster.Y - target.Y)) > Math.Clamp(spell.CastRange, 0, 32))
            return "Target is out of range.";
        if (spell.Data1 <= 0 || spell.Type > 3) return "This spell has no supported effect.";
        if (ReferenceEquals(caster, target) && spell.Type is 0 or 2) return "Choose another player as the target.";
        // Spend mana first so a self mana-restoration spell cannot exceed MaxMP.
        caster.MP -= spell.MPReq;
        switch (spell.Type)
        {
            case 0: target.HP = (int)Math.Max(0L, (long)target.HP - spell.Data1); break;
            case 1: target.HP = Restore(target.HP, spell.Data1, target.MaxHP); break;
            case 2: target.MP = (int)Math.Max(0L, (long)target.MP - spell.Data1); break;
            case 3: target.MP = Restore(target.MP, spell.Data1, target.MaxMP); break;
        }
        return null;
    }
    private static int Restore(int value, int amount, int maximum) =>
        (int)Math.Clamp((long)value + amount, 0, Math.Max(0, maximum));
}
