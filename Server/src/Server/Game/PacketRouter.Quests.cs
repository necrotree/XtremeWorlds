using XtremeWorlds.Networking;
namespace Server;

public sealed partial class PacketRouter
{
    private sealed record ChatBubble(int Map, string PlayerName, string Text, double Started);
    private readonly Dictionary<int, ChatBubble> _chatBubbles = new();
    private void RecordChatBubble(int id, int map, string player, string text)
    {
        lock (_gameplayGate) _chatBubbles[id] = new(map, player, text, NetworkClock.Seconds);
    }
    private async Task SeedQuestAsync()
    {
        if (_quests.Count != 0 || !_items.TryGetValue(1, out var health) || health.Name != "Health Potion"
            || !_items.TryGetValue(2, out var mana) || mana.Name != "Mana Potion") return;
        var quest = new QuestDefinition { Name = "Supplies for the healer", Description = "Bring one Health Potion to the healer. You will receive two Mana Potions and 25 experience.",
            Map = _mapCache.Keys.Order().FirstOrDefault(1), X = 2, Y = 2, Sprite = 2, RequiredItem = 1, RequiredQuantity = 1,
            RewardItem = 2, RewardQuantity = 2, RewardExperience = 25 };
        await _db.UpsertContentAsync("quest", 1, quest.Name, quest);
        _quests = new Dictionary<int, QuestDefinition> { [1] = quest };
    }
    private object[] QuestJournalFor(PlayerCharacter player) => _quests.OrderBy(q => q.Key).Select(q => (object)new {
        Id = q.Key, q.Value.Name, q.Value.Description, q.Value.Map, q.Value.X, q.Value.Y,
        Status = QuestRules.Status(player, q.Key, q.Value),
        Current = QuestRules.Status(player,q.Key,q.Value) == "completed" ? Math.Max(0,q.Value.RequiredQuantity) : Math.Min(QuestRules.Count(player,q.Value), Math.Max(0,q.Value.RequiredQuantity)),
        Required = q.Value.RequiredItem > 0 ? Math.Max(0,q.Value.RequiredQuantity) : 0, q.Value.RewardExperience
    }).ToArray();
    private object[] QuestBlipsFor(PlayerCharacter player) => _quests.Where(q => q.Value.Map == player.Map
        && q.Value.X is >= 0 and <= GameLimits.MaxMapX && q.Value.Y is >= 0 and <= GameLimits.MaxMapY)
        .Select(q => (object)new { QuestId = q.Key, q.Value.X, q.Value.Y, q.Value.Sprite, q.Value.Name,
            Status = QuestRules.Status(player, q.Key, q.Value) }).ToArray();
}
