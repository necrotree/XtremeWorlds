namespace Server;

public static class CombatRules
{
    public const double AttackInterval = .75;
    public static bool InRange(PlayerCharacter a, PlayerCharacter b) => a.Map == b.Map &&
        Math.Max(Math.Abs((a.PixelX ?? a.X * 32.0) - (b.PixelX ?? b.X * 32.0)),
                 Math.Abs((a.PixelY ?? a.Y * 32.0) - (b.PixelY ?? b.Y * 32.0))) <= 40;
    public static int Damage(int strength, int defense) => (int)Math.Clamp(2L + Math.Max(0,strength) - Math.Max(0,defense) / 2L, 1, 100000);
    public static int EquipmentBonus(PlayerCharacter player, IReadOnlyDictionary<int,ItemDefinition> items, bool attack)
    {
        var slots = attack ? new[] { player.WeaponSlot } : new[] { player.ArmorSlot,player.HelmetSlot,player.ShieldSlot };
        long result = 0;
        foreach (var slot in slots.Distinct())
            if (slot > 0 && slot <= player.Inventory.Count && player.Inventory[slot-1].Value > 0
                && items.TryGetValue(player.Inventory[slot-1].Num,out var item)) result += Math.Max(0, attack ? item.AttackBonus : item.DefenseBonus);
        return (int)Math.Clamp(result,0,100000);
    }
    public static void Face(PlayerCharacter player, PlayerCharacter target)
    {
        double dx = (target.PixelX ?? target.X*32.0) - (player.PixelX ?? player.X*32.0);
        double dy = (target.PixelY ?? target.Y*32.0) - (player.PixelY ?? player.Y*32.0);
        if (dx == 0 && dy == 0) return;
        player.Direction = (byte)(Math.Abs(dx) > Math.Abs(dy) ? dx < 0 ? 2 : 3 : dy < 0 ? 0 : 1);
    }
}
