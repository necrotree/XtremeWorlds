using Server;
using System.Collections.Concurrent;
using System.Reflection;
using System.Text.Json;
using XtremeWorlds.Client.Engine.Graphics;

void Check(bool value, string message) { if (!value) throw new Exception(message); }
var items = new Dictionary<int, ItemDefinition> {
    [1] = new() { Type = 4, Data1 = 30, Pic = 2 },
    [2] = new() { Type = 0, LevelReq = 2 },
    [3] = new() { Type = 8, Data1 = 1 },
    [4] = new() { Type = 5, Data1 = int.MaxValue }
};
var spells = new Dictionary<int, SpellDefinition> {
    [1] = new() { Name = "Heal", Type = 1, Data1 = 30, MPReq = 10, Graphic = 2, CastRange = 5 },
    [2] = new() { Name = "Fire", Type = 0, Data1 = 20, MPReq = 5, Graphic = 3, CastRange = 1 }
};
var player = new PlayerCharacter { Name = "Caster", Map = 1, HP = 90, MP = 40, Level = 1,
    Inventory = new() { new() { Num = 1, Value = 2 }, new() { Num = 2, Value = 1 }, new() { Num = 3, Value = 2 }, new() { Num = 4, Value = 1 } } };
Check(GameplayRules.UseItem(player, 0, items, spells) is not null, "Invalid slots must be rejected.");
Check(GameplayRules.UseItem(player, 1, items, spells) is null && player.HP == 100 && player.Inventory[0].Value == 1, "Potion must clamp HP and consume once.");
Check(GameplayRules.UseItem(player, 1, items, spells) is not null && player.Inventory[0].Value == 1, "Full HP must not consume a potion.");
Check(GameplayRules.UseItem(player, 2, items, spells) is not null && player.WeaponSlot == 0, "Equipment level requirements must be checked.");
player.Level = 2;
Check(GameplayRules.UseItem(player, 2, items, spells) is null && player.WeaponSlot == 2, "Equip uses stable one-based slots.");
Check(GameplayRules.UseItem(player, 2, items, spells) is null && player.WeaponSlot == 0 && player.Inventory[1].Value == 1, "Unequip must not consume equipment.");
Check(GameplayRules.UseItem(player, 3, items, spells) is null && player.Spells.SequenceEqual(new[] { 1 }), "Books learn the defined spell.");
Check(GameplayRules.UseItem(player, 3, items, spells) is not null && player.Inventory[2].Value == 1, "Duplicate learning must not consume books.");
Check(GameplayRules.UseItem(player, 4, items, spells) is null && player.MP == 50, "Restoration must tolerate large values without overflow.");
player.MP = 0; player.HP = 50;
Check(GameplayRules.Cast(player, player, spells[1]) is not null && player.HP == 50, "Insufficient mana must not apply spell effects.");
player.MP = 30;
Check(GameplayRules.Cast(player, player, spells[1]) is null && player.HP == 80 && player.MP == 20, "Heal consumes mana and restores HP.");
var target = new PlayerCharacter { Name = "Target", Map = 1, X = 2, HP = 100 };
Check(GameplayRules.Cast(player, target, spells[2]) is not null && player.MP == 20, "Out-of-range cast must not consume mana.");
target.X = 1;
Check(GameplayRules.Cast(player, target, spells[2]) is null && target.HP == 80 && player.MP == 15, "Damage must affect the selected target.");
Check(GameplayRules.Cast(player, player, spells[2]) is not null, "Damage spells must not silently target self.");
var settings = new ServerSettings();
var network = new MirrorTcpHost(0, 4096, true);
using var db = new SpacetimeRepository(settings);
var sessions = new ConcurrentDictionary<int, PlayerSession>();
sessions[1] = new() { ConnectionId = 1, IsPlaying = true, Character = player };
sessions[2] = new() { ConnectionId = 2, IsPlaying = true, Character = target };
var router = new PacketRouter(settings, network, db, sessions);
void Set(string name, object value) => typeof(PacketRouter).GetField(name, BindingFlags.Instance | BindingFlags.NonPublic)!.SetValue(router, value);
Set("_items", items); Set("_spells", spells);
var mapCache = (ConcurrentDictionary<int, MapDefinition>)typeof(PacketRouter).GetField("_mapCache", BindingFlags.Instance | BindingFlags.NonPublic)!.GetValue(router)!;
mapCache[1] = new() { Moral = 1 };
async Task Dispatch(string command, params object[] values) => await router.HandleAsync(1, PacketCodec.Compose(command, values));
object Capture() => typeof(PacketRouter).GetMethod("CaptureGameplay", BindingFlags.Instance | BindingFlags.NonPublic)!.Invoke(router, new object[] { 1 })!;
await Dispatch("emote", 29);
var captured = ((object[] Items, object[] Spells, object[] Emotes, object[] ChatBubbles))Capture();
Check(captured.Emotes.Length == 1, "Valid emote must enter map snapshot.");
var emote = JsonSerializer.Deserialize<FnaSceneEmote>(JsonSerializer.Serialize(captured.Emotes[0]))!;
Check(emote.Picture == 29 && emote.RemainingSeconds > 0 && emote.PlayerName == "Caster", "Emote protocol must match client model.");
await Dispatch("emote", 30);
Check(((ValueTuple<object[], object[], object[], object[]>)Capture()).Item3.Length == 1, "Invalid emote must be rejected.");
sessions[1].IsMuted = true;
sessions[1].NextEmoteSeconds = 0;
await Dispatch("emote", 5);
Check(JsonSerializer.Deserialize<FnaSceneEmote>(JsonSerializer.Serialize(((ValueTuple<object[], object[], object[], object[]>)Capture()).Item3[0]))!.Picture == 29, "Muted users cannot send emotes.");
sessions[1].IsMuted = false;
await Dispatch("playersprite", 208); Check(player.Sprite == 208, "Last valid avatar must be selectable.");
await Dispatch("playersprite", 209); Check(player.Sprite == 208, "Out-of-bounds avatar must be rejected.");
await Dispatch("mapdropitem", 1);
Check(player.Inventory[0].Value == 0 && ((ValueTuple<object[], object[], object[], object[]>)Capture()).Item1.Length == 1, "Drop moves inventory to map.");
await Dispatch("mapgetitem");
Check(player.Inventory[0].Value == 1 && ((ValueTuple<object[], object[], object[], object[]>)Capture()).Item1.Length == 0, "Pickup restores item once.");
await Dispatch("mapgetitem"); Check(player.Inventory[0].Value == 1, "Repeated pickup must not duplicate items.");
player.Inventory.Add(new() { Num = 1, Value = 2 });
await Dispatch("mapdropitem", player.Inventory.Count);
await Dispatch("mapgetitem");
Check(player.Inventory[0].Value == 3 && player.Inventory.Last().Value == 0, "Compatible consumables must merge into an existing stack.");
player.Spells.Add(2);
await Dispatch("cast", 2, "Target"); Check(target.HP == 80, "Safe maps reject damage spells.");
mapCache[1].Moral = 0;
await Dispatch("cast", 2, "Target"); Check(target.HP == 60 && player.MP == 10, "Combat map allows validated damage.");
await Dispatch("cast", 2, "Target"); Check(target.HP == 60 && player.MP == 10, "Spell cooldown prevents repeated damage and mana consumption.");
sessions[1].SpellCooldowns.Clear(); target.HP = 10;
await Dispatch("cast", 2, "Target"); Check(target.HP == 100 && target.X == 0, "Defeated players must respawn alive.");
var effects = ((ValueTuple<object[], object[], object[], object[]>)Capture()).Item2;
var effect = JsonSerializer.Deserialize<FnaSceneSpell>(JsonSerializer.Serialize(effects[0]))!;
Check(effect.AgeSeconds is >= 0 && effect.Animation == 3 && FnaSceneSpell.FrameCount == 12, "Effects use server-relative age and supplied atlas frame count.");
player.Spells = Enumerable.Repeat(0, GameLimits.MaxPlayerSpells).ToList();
player.Inventory[2].Value = 1;
Check(GameplayRules.UseItem(player, 3, items, spells) is null && player.Spells[0] == 1 && player.Spells.Count == GameLimits.MaxPlayerSpells,
    "Learning must reuse a forgotten spell slot in a full book.");
Console.WriteLine("Gameplay rules, protocol, cooldown, safe-map, emote, avatar, pickup/drop, and respawn checks passed.");

var quest = new QuestDefinition { Name = "Supplies", Map = 1, X = 2, Y = 2, RequiredItem = 1, RequiredQuantity = 2, RewardItem = 4, RewardQuantity = 2, RewardExperience = 25 };
var adventurer = new PlayerCharacter { Name = "Adventurer", Level = 1, Map = 1, X = 15, Y = 11, Inventory = new() { new() { Num = 1, Value = 3 } } };
Check(QuestRules.Accept(adventurer, 1, quest) is not null && adventurer.Quests.Count == 0, "Remote quest acceptance must be rejected.");
adventurer.X = 2; adventurer.Y = 2;
Check(QuestRules.Accept(adventurer, 1, quest) is null && QuestRules.Status(adventurer, 1, quest) == "ready", "Acceptance must recognize objective items already collected.");
Check(QuestRules.Accept(adventurer, 1, quest) is not null, "A quest cannot be accepted twice.");
Check(QuestRules.Complete(adventurer, 1, quest, items) is null && adventurer.Inventory[0].Value == 1 && adventurer.Exp == 25
    && adventurer.Inventory.Any(i => i.Num == 4 && i.Value == 2) && adventurer.Quests[1].Completed, "Turn-in must consume objective items and grant rewards together.");
Check(QuestRules.Complete(adventurer, 1, quest, items) is not null && adventurer.Exp == 25, "Completed quests cannot grant rewards twice.");
var full = new PlayerCharacter { Level = 1, Map = 1, X = 2, Y = 2,
    Inventory = Enumerable.Range(0,GameLimits.MaxInventory).Select(n => new PlayerInventory { Num = 1, Value = 3 }).ToList() };
Check(QuestRules.Accept(full, 1, quest) is null, "Quest must be accepted.");
Check(QuestRules.Complete(full, 1, quest, items) is not null && full.Inventory[0].Value == 3 && full.Exp == 0 && !full.Quests[1].Completed,
    "Full inventory must leave objective items and quest progress unchanged.");
var available = new PlayerCharacter { Level = 1, Map = 1, X = 2, Y = 2 };
Check(QuestRules.Accept(available, 1, quest) is null && QuestRules.Status(available, 1, quest) == "active", "Unfulfilled objectives must remain active.");
Check(QuestRules.Complete(available, 1, quest, items) is not null, "Unfulfilled quests cannot be completed.");
Check(JsonSerializer.Deserialize<PlayerCharacter>(JsonSerializer.Serialize(adventurer))!.Quests[1].Completed,
    "Completed quest progress must survive character JSON persistence.");
Set("_quests", new Dictionary<int,QuestDefinition> { [5] = quest });
player.X = 2; player.Y = 2;
await Dispatch("acceptquest", 5); Check(player.Quests.ContainsKey(5), "Quest acceptance packet must update the current player.");
sessions[1].IsJailed = true;
await Dispatch("completequest", 5); Check(!player.Quests[5].Completed, "Jailed players cannot claim quest rewards.");
sessions[1].IsJailed = false;
await Dispatch("completequest", 5); Check(player.Quests[5].Completed, "Quest completion packet must claim rewards exactly once.");
await Dispatch("saymsg", "Hello nearby players");
var bubbles = ((ValueTuple<object[],object[],object[],object[]>)Capture()).Item4;
Check(bubbles.Length == 1, "Map chat must create a speech bubble.");
var bubble = JsonSerializer.Deserialize<FnaSceneChatBubble>(JsonSerializer.Serialize(bubbles[0]))!;
Check(bubble.Text == "Hello nearby players" && bubble.PlayerName == player.Name && bubble.RemainingSeconds is > 0 and <= 5,
    "Speech bubble wire model must preserve the speaker, message, and finite lifetime.");
await Dispatch("globalmsg", "Global chat stays in the chat log");
Check(((ValueTuple<object[],object[],object[],object[]>)Capture()).Item4.Length == 1, "Global messages must not create local speech bubbles.");
sessions[1].IsMuted = true;
await Dispatch("saymsg", "Blocked");
Check(JsonSerializer.Deserialize<FnaSceneChatBubble>(JsonSerializer.Serialize(((ValueTuple<object[],object[],object[],object[]>)Capture()).Item4[0]))!.Text != "Blocked",
    "Muted messages must not create bubbles.");
Console.WriteLine("Quest requirements, atomic rewards, replay protection, character persistence, packet dispatch, and chat bubble checks passed.");

// Normal melee and NPC/map-item lifecycle tests exercise the real packet router.
sessions[1].IsMuted = false; sessions[1].IsJailed = false; sessions[2].IsJailed = false;
player.HP = 100; player.Strength = 10; player.Defense = 0; player.Map = 1; player.X = 4; player.Y = 5; player.PixelX = null; player.PixelY = null;
target.Map = 1; target.X = 5; target.Y = 5; target.PixelX = null; target.PixelY = null; target.HP = 100;
var combatMap = new MapDefinition { Moral = 0, Tiles = Enumerable.Range(0,192).Select(_ => new TileDefinition()).ToList(), Npcs = new() { 1 },
    ItemSpawns = new() { new MapItemSpawn { ItemId = 1, Quantity = 1, X = 4, Y = 5, RespawnSeconds = 30 } } };
mapCache[1] = combatMap;
Set("_npcs", new Dictionary<int,NpcDefinition> { [1] = new() { Name = "Dummy", Sprite = 3, MaxHP = 15, Strength = 3, DropItem = 1, DropItemValue = 2, DropChance = 100, GiveEXP = 10, SpawnSecs = 1 } });
((HashSet<int>)typeof(PacketRouter).GetField("_initializedNpcMaps",BindingFlags.Instance|BindingFlags.NonPublic)!.GetValue(router)!).Clear();
sessions[1].NextAttackSeconds = 0;
await Dispatch("attack", "Target"); Check(target.HP == 88 && player.MP == 5, "Normal attacks deal strength-based damage without consuming mana.");
await Dispatch("attack", "Target"); Check(target.HP == 88, "Repeated packets cannot bypass the server attack interval.");
sessions[1].NextAttackSeconds = 0; target.X = 6;
await Dispatch("attack", "Target"); Check(target.HP == 88, "Melee must reject distant targets.");
target.X = 5; sessions[1].NextAttackSeconds = 0; combatMap.Moral = 1;
await Dispatch("attack", "Target"); Check(target.HP == 88, "Safe maps must block player melee combat.");
combatMap.Moral = 0; sessions[1].IsJailed = true; sessions[1].NextAttackSeconds = 0;
await Dispatch("attack", "Target"); Check(target.HP == 88, "Jail must block normal attacks.");
sessions[1].IsJailed = false; sessions[1].NextAttackSeconds = 0;
await Dispatch("attack", "npc:1:0");
object[] Npcs() => (object[])typeof(PacketRouter).GetMethod("CaptureMapNpcs",BindingFlags.Instance|BindingFlags.NonPublic)!.Invoke(router,new object[] { 1 })!;
Check(Npcs().Length == 1 && JsonSerializer.Deserialize<FnaScenePlayer>(JsonSerializer.Serialize(Npcs()[0]))!.HP == 3,
    "Melee must damage a server-owned NPC selected by stable target ID.");
router.Tick(); Check(player.HP == 95, "An attacked nearby NPC must retaliate at its own attack interval.");
var groundBefore = ((ValueTuple<object[],object[],object[],object[]>)Capture()).Item1;
Check(groundBefore.Any(i => JsonSerializer.Deserialize<FnaSceneItem>(JsonSerializer.Serialize(i))!.Quantity == 1), "Map item templates spawn authoritative quantities.");
int countBefore = player.Inventory.Where(i => i.Num == 1).Sum(i => i.Value);
await Dispatch("mapgetitem");
Check(player.Inventory.Where(i => i.Num == 1).Sum(i => i.Value) == countBefore + 1, "Pickup at the player's feet transfers a map item into inventory.");
router.Tick(); Check(((ValueTuple<object[],object[],object[],object[]>)Capture()).Item1.Length == 0, "Spawned items must wait for their respawn timer after pickup.");
var spawnTimers = (Dictionary<(int Map,int Index),double>)typeof(PacketRouter).GetField("_itemSpawnReady",BindingFlags.Instance|BindingFlags.NonPublic)!.GetValue(router)!;
spawnTimers[(1,0)] = 0;
router.Tick(); Check(((ValueTuple<object[],object[],object[],object[]>)Capture()).Item1.Length == 1, "Configured map items respawn after their delay.");
int expBefore = player.Exp; sessions[1].NextAttackSeconds = 0;
await Dispatch("attack", "npc:1:0");
Check(Npcs().Length == 0 && player.Exp == expBefore + 10 && ((ValueTuple<object[],object[],object[],object[]>)Capture()).Item1.Length == 2,
    "Defeating an NPC removes it, grants experience, and drops visible loot.");
sessions[1].NextAttackSeconds = 0; await Dispatch("attack", "npc:1:0"); Check(player.Exp == expBefore+10, "A dead NPC cannot grant rewards twice.");
var npcState = ((System.Collections.IDictionary)typeof(PacketRouter).GetField("_mapNpcs",BindingFlags.Instance|BindingFlags.NonPublic)!.GetValue(router)!).Values.Cast<object>().Single();
npcState.GetType().GetProperty("RespawnAt")!.SetValue(npcState,0d);
router.Tick(); Check(Npcs().Length == 1 && JsonSerializer.Deserialize<FnaScenePlayer>(JsonSerializer.Serialize(Npcs()[0]))!.HP == 15, "NPC respawn restores health once its timer expires.");
Check(CombatRules.Damage(int.MaxValue,0) == 100000 && CombatRules.Damage(0,int.MaxValue) == 1, "Melee arithmetic must be bounded and always deal minimum damage.");
var equipped = new PlayerCharacter { WeaponSlot = 1, Inventory = new() { new() { Num = 9, Value = 1 } } };
Check(CombatRules.EquipmentBonus(equipped,new Dictionary<int,ItemDefinition> { [9] = new() { AttackBonus = 5 } },true) == 5,
    "Equipped weapons contribute their configured attack bonus.");
Console.WriteLine("Melee timing, range, safe maps, NPC combat, retaliation, loot, rewards, map-item pickup, and respawn checks passed.");

// New map-item editor packets must remain server-authorized.
player.Access = 0;
int spawnCount = combatMap.ItemSpawns.Count;
await Dispatch("spawnmapitem", 1, 1, 3, 3, 30);
await Dispatch("removemapitemspawn", 0);
Check(combatMap.ItemSpawns.Count == spawnCount, "Players cannot edit map item spawn definitions.");
player.Access = 1;
await Dispatch("spawnmapitem", 1, 1, 99, 3, 30);
Check(combatMap.ItemSpawns.Count == spawnCount, "Invalid spawn coordinates must not mutate map definitions.");
player.Access = 0; player.MP = 50; player.Spells = new() { 2 }; sessions[1].SpellCooldowns.Clear();
await Dispatch("cast", 1, "npc:1:0");
Check(Npcs().Length == 0 && player.MP == 45, "Damage spells must work with the same selected NPC target and consume mana.");
Console.WriteLine("Map-item editor permission and NPC spell integration checks passed.");

// Drive the server charge clock directly so the recovery-rate test does not sleep.
player.HP = 100; player.MP = 0; player.MaxMP = 50; player.X = 0; player.Y = 0; player.PixelX = null; player.PixelY = null;
sessions[1].IsJailed = false;
await Dispatch("chargemana",1);
Check(sessions[1].IsChargingMana && player.MP == 0, "Holding Space starts a channel without granting instant mana.");
for (int n=0;n<20;n++) await Dispatch("chargemana",1);
Check(player.MP == 0, "Repeated charge packets must not grant mana.");
void ChargeTick()
{
    sessions[1].LastManaChargeSeconds = XtremeWorlds.Networking.NetworkClock.Seconds-.25;
    sessions[1].ManaChargeExpires = XtremeWorlds.Networking.NetworkClock.Seconds+1;
    typeof(PacketRouter).GetMethod("TickManaCharging",BindingFlags.Instance|BindingFlags.NonPublic)!.Invoke(router,null);
}
for (int n=0;n<4;n++) ChargeTick();
Check(player.MP == 5 && sessions[1].IsChargingMana, "One second of server charge time restores ten percent of maximum mana.");
await Dispatch("chargemana",0);
Check(!sessions[1].IsChargingMana, "Releasing Space stops the channel.");
int manaAtRelease = player.MP;
ChargeTick(); Check(player.MP == manaAtRelease, "Released channels cannot continue regenerating.");
await Dispatch("chargemana",1); player.X = 1;
ChargeTick(); Check(!sessions[1].IsChargingMana && player.MP == manaAtRelease, "Moving interrupts charging without granting extra mana.");
await Dispatch("chargemana",1);
sessions[1].ManaChargeExpires = 0;
typeof(PacketRouter).GetMethod("TickManaCharging",BindingFlags.Instance|BindingFlags.NonPublic)!.Invoke(router,null);
Check(!sessions[1].IsChargingMana, "An expired held-key lease must stop after focus or connection loss.");
player.MP = 49; await Dispatch("chargemana",1); ChargeTick();
Check(player.MP == 50 && !sessions[1].IsChargingMana, "Charging stops at maximum mana without overflow.");
player.MP = 0; sessions[1].IsJailed = true;
await Dispatch("chargemana",1); Check(!sessions[1].IsChargingMana && player.MP == 0, "Jailed players cannot charge mana.");
sessions[1].IsJailed = false; player.HP = 0;
await Dispatch("chargemana",1); Check(!sessions[1].IsChargingMana, "Dead players cannot charge mana.");
player.HP = 100;
await Dispatch("chargemana",2); Check(!sessions[1].IsChargingMana, "Malformed charge flags must be rejected.");
Console.WriteLine("Mana charge clock, rate, packet spam, release, movement, expiry, maximum, and eligibility checks passed.");

await Dispatch("chargemana",1);
router.EndManaChargeOnDisconnect(1);
Check(!sessions[1].IsChargingMana, "Disconnect must end the channel and queue the final recovered mana save.");

var validItem = new ItemDefinition { Name="Editor Potion", Type=4, Data1=20, Pic=1499 };
Check(ContentValidation.Item(validItem,new ServerSettings(),spells) is null,"Item editor accepts a valid definition.");
validItem.Pic=1500; Check(ContentValidation.Item(validItem,new ServerSettings(),spells) is not null,"Item editor rejects an out-of-sheet graphic.");
validItem.Pic=0; validItem.Data1=0; Check(ContentValidation.Item(validItem,new ServerSettings(),spells) is not null,"Potion restoration must be positive.");
validItem.Type=8; validItem.Data1=999; Check(ContentValidation.Item(validItem,new ServerSettings(),spells) is not null,"Spell books require an existing spell.");
validItem.Type=0; validItem.Name="Bad\0Name"; Check(ContentValidation.Item(validItem,new ServerSettings(),spells) is not null,"Control characters are rejected in definition names.");
var validNpc = new NpcDefinition { Name="Editor NPC", Sprite=208, MaxHP=50, SpawnSecs=10, DropItem=1, DropItemValue=1, DropChance=100 };
Check(ContentValidation.Npc(validNpc,items) is null,"NPC editor accepts valid health, sprite, and loot.");
validNpc.DropChance=101; Check(ContentValidation.Npc(validNpc,items) is not null,"Drop chance cannot exceed 100 percent.");
validNpc.DropChance=50; validNpc.DropItem=999; Check(ContentValidation.Npc(validNpc,items) is not null,"NPC loot requires an existing item.");
validNpc.DropItem=1; validNpc.Sprite=209; Check(ContentValidation.Npc(validNpc,items) is not null,"NPC editor rejects out-of-sheet sprites.");
validNpc.Sprite=3; validNpc.MaxHP=0; Check(ContentValidation.Npc(validNpc,items) is not null,"NPC health must be positive.");
var shared = JsonSerializer.Deserialize<XtremeWorlds.Networking.Content.ItemContent>(JsonSerializer.Serialize(new ItemDefinition { Name="Shared", AttackBonus=12, Data2=7, Sound=3 }))!;
Check(shared.AttackBonus==12 && shared.Data2==7 && shared.Sound==3,"Shared editor definitions must retain legacy fields during serialization.");
player.Access=0;
await Dispatch("savecontentdefinition","item",1,JsonSerializer.Serialize(new ItemDefinition { Name="Unauthorized",Type=4,Data1=20 }));
Check(!((IReadOnlyDictionary<int,ItemDefinition>)typeof(PacketRouter).GetField("_items",BindingFlags.Instance|BindingFlags.NonPublic)!.GetValue(router)!)[1].Name.Equals("Unauthorized"),"Non-admin editor saves must not mutate definitions.");
player.Access=1;
await Dispatch("savecontentdefinition","item",1,"{malformed}");
await Dispatch("savecontentdefinition","npc",1,JsonSerializer.Serialize(new NpcDefinition { Name="Invalid",MaxHP=0 }));
Check(((IReadOnlyDictionary<int,NpcDefinition>)typeof(PacketRouter).GetField("_npcs",BindingFlags.Instance|BindingFlags.NonPublic)!.GetValue(router)!)[1].Name=="Dummy","Invalid NPC editor saves must preserve live definitions.");
await Dispatch("requestcontenteditor","item",1);
await Dispatch("requestcontenteditor","npc",1);
player.Access=0;
Console.WriteLine("Editor model compatibility, validation, graphic bounds, references, and packet authorization checks passed.");

await EditorSaveTest.Run();
