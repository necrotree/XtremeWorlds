namespace Server;

public static class QuestRules
{
    public static long Count(PlayerCharacter player, QuestDefinition quest) => quest.RequiredItem <= 0 ? 0 :
        player.Inventory.Where(i => i.Num == quest.RequiredItem && i.Value > 0).Sum(i => (long)i.Value);
    public static string Status(PlayerCharacter player, int id, QuestDefinition quest) =>
        !player.Quests.TryGetValue(id, out var progress) ? "available" : progress.Completed ? "completed" :
        quest.RequiredItem <= 0 || Count(player, quest) >= quest.RequiredQuantity ? "ready" : "active";
    private static bool Near(PlayerCharacter player, QuestDefinition quest) => player.Map == quest.Map
        && Math.Max(Math.Abs(player.X - quest.X), Math.Abs(player.Y - quest.Y)) <= 2;
    public static string? Accept(PlayerCharacter player, int id, QuestDefinition quest)
    {
        if (!Near(player, quest)) return "Move closer to the quest giver.";
        if (player.Level < quest.LevelReq) return "Your level is too low for this quest.";
        if (player.Quests.ContainsKey(id)) return "You have already accepted this quest.";
        player.Quests[id] = new();
        return null;
    }
    public static string? Complete(PlayerCharacter player, int id, QuestDefinition quest, IReadOnlyDictionary<int, ItemDefinition> items)
    {
        if (!Near(player, quest)) return "Move closer to the quest giver.";
        if (Status(player, id, quest) != "ready") return "This quest is not ready to turn in.";
        if (quest.RequiredItem > 0 && quest.RequiredQuantity <= 0) return "This quest has an invalid objective.";
        if (quest.RewardItem > 0 && (!items.ContainsKey(quest.RewardItem) || quest.RewardQuantity <= 0)) return "This quest has an invalid reward.";
        // Prepare on a copy so a full inventory never consumes objective items without granting the reward.
        var inventory = player.Inventory.Select(i => new PlayerInventory { Num = i.Num, Value = i.Value, Durability = i.Durability }).ToList();
        int remaining = quest.RequiredItem > 0 ? quest.RequiredQuantity : 0;
        for (int n = 0; n < inventory.Count && remaining > 0; n++)
        {
            var stack = inventory[n];
            if (stack.Num != quest.RequiredItem || stack.Value <= 0 || new[] { player.WeaponSlot, player.ArmorSlot, player.HelmetSlot, player.ShieldSlot }.Contains(n + 1)) continue;
            int used = Math.Min(stack.Value, remaining); stack.Value -= used; remaining -= used;
            if (stack.Value == 0) stack.Num = 0;
        }
        if (remaining > 0) return "Unequip the objective items before turning them in.";
        if (quest.RewardItem > 0)
        {
            var merge = items[quest.RewardItem].Type >= 4 ? inventory.FirstOrDefault(i => i.Num == quest.RewardItem && i.Value > 0 && i.Durability == 0
                && (long)i.Value + quest.RewardQuantity <= int.MaxValue) : null;
            if (merge is not null) merge.Value += quest.RewardQuantity;
            else
            {
                int empty = inventory.FindIndex(i => i.Num == 0 || i.Value == 0);
                if (empty < 0 && inventory.Count >= GameLimits.MaxInventory) return "Make room in your inventory for the reward.";
                var reward = new PlayerInventory { Num = quest.RewardItem, Value = quest.RewardQuantity };
                if (empty >= 0) inventory[empty] = reward; else inventory.Add(reward);
            }
        }
        player.Inventory = inventory;
        player.Exp = (int)Math.Clamp((long)player.Exp + Math.Max(0,quest.RewardExperience), 0, int.MaxValue);
        player.Quests[id].Completed = true;
        return null;
    }
}
