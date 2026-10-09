using System.Text.Json;
using XtremeWorlds.Networking;

namespace Server;

public sealed partial class PacketRouter
{
    private readonly object _gameplayGate = new();
    private readonly List<GroundItem> _groundItems = new();
    private readonly List<SpellEffect> _spellEffects = new();
    private readonly Dictionary<int, EmoteEffect> _emotes = new();
    private int _nextGroundId;
    private Task _gameplaySave = Task.CompletedTask;
    private sealed record GroundItem(int Id, int Map, int X, int Y, int Num, int Value, short Durability, int SpawnIndex = -1);
    private sealed record SpellEffect(int Map, int X, int Y, int Animation, double Started);
    private sealed record EmoteEffect(int Map, string PlayerName, int Picture, double Started);

    private async Task SeedGameplayAsync()
    {
        if (_spells.Count == 0)
        {
            var spells = new Dictionary<int, SpellDefinition> {
                [1] = new() { Name = "Heal", Type = 1, Data1 = 30, MPReq = 10, Graphic = 2, LevelReq = 1 },
                [2] = new() { Name = "Firebolt", Type = 0, Data1 = 20, MPReq = 8, Graphic = 11, CastRange = 6, LevelReq = 1 }
            };
            foreach (var (id, spell) in spells) await _db.UpsertContentAsync("spell", id, spell.Name, spell);
            _spells = spells;
        }
        if (_items.Count == 0)
        {
            var items = new Dictionary<int, ItemDefinition> {
                [1] = new() { Name = "Health Potion", Type = 4, Data1 = 30, Pic = 0 },
                [2] = new() { Name = "Mana Potion", Type = 5, Data1 = 20, Pic = 1 },
                [3] = new() { Name = "Spell Book", Type = 8, Data1 = _spells.ContainsKey(2) ? 2 : _spells.Keys.Order().First(), Pic = 2 }
            };
            foreach (var (id, item) in items) await _db.UpsertContentAsync("item", id, item.Name, item);
            _items = items;
        }
    }

    private async Task HandleGameplayAsync(int id, string command, string[] fields)
    {
        if (!HandleGameplay(id, command, fields)) return;
        var changed = new List<(string Login, int Slot, PlayerCharacter Player)>();
        Task save;
        lock (_gameplayGate)
        {
            if (!_sessions.TryGetValue(id, out var actor)) return;
            var affected = new List<PlayerSession> { actor };
            if ((command == "cast" && fields.Length > 2) || (command == "attack" && fields.Length > 1))
            {
                var target = _sessions.Values.FirstOrDefault(s => s.IsPlaying && s.Character?.Map == actor.Character?.Map
                    && string.Equals(s.Character?.Name, fields[command == "attack" ? 1 : 2], StringComparison.OrdinalIgnoreCase));
                if (target is not null && !ReferenceEquals(target, actor)) affected.Add(target);
            }
            foreach (var session in affected) lock (session)
                if (session.Character is { } p && session.Login.Length > 0 && session.CharacterSlot > 0)
                    changed.Add((session.Login, session.CharacterSlot, JsonSerializer.Deserialize<PlayerCharacter>(JsonSerializer.Serialize(p))!));
            save = _gameplaySave = SaveGameplayAfterAsync(_gameplaySave, changed, id);
        }
        await save;
    }

    private async Task SaveGameplayAfterAsync(Task previous, List<(string Login, int Slot, PlayerCharacter Player)> changed, int id)
    {
        await previous;
        foreach (var change in changed)
            try { await _db.SaveCharacterAsync(change.Login, change.Slot, change.Player); }
            catch (Exception ex)
            {
                _log?.Invoke($"Gameplay save failed for {change.Player.Name}: {ex.Message}");
                _network.SendText(id, PacketCodec.Compose("playermsg", "The change was applied, but the database could not save it."));
            }
    }

    private bool HandleGameplay(int id, string command, string[] fields)
    {
        if (!_sessions.TryGetValue(id, out var session) || !session.IsPlaying || session.Character is null) return false;
        lock (_gameplayGate)
        lock (session)
        {
            if (!session.IsPlaying || session.Character is not { } player) return false;
            double now = NetworkClock.Seconds;
            if (command is "attack" or "cast") StopManaCharge(session);
            if (command == "attack") return HandleNormalAttack(session, fields);
            if (command is "getinv" or "spells" or "quests") { SendGameplayState(session); return false; }
            if (command is "acceptquest" or "completequest")
            {
                string? questError = fields.Length >= 2 && int.TryParse(fields[1], out int questId) && _quests.TryGetValue(questId, out var quest)
                    ? command == "acceptquest" ? QuestRules.Accept(player, questId, quest) : QuestRules.Complete(player, questId, quest, _items)
                    : "Invalid quest.";
                if (questError is not null) _network.SendText(id, PacketCodec.Compose("playermsg", questError));
                else SendGameplayState(session);
                return questError is null;
            }
            if (command == "emote")
            {
                if (fields.Length != 2 || !int.TryParse(fields[1], out int picture) || picture is < 0 or >= 30 || now < session.NextEmoteSeconds) return false;
                _emotes[id] = new(player.Map, player.Name, picture, now);
                session.NextEmoteSeconds = now + .75;
                return false;
            }
            if (command == "playersprite")
            {
                if (fields.Length != 2 || !int.TryParse(fields[1], out int sprite) || sprite is < 0 or >= 209) return false;
                player.Sprite = (short)sprite;
                SendGameplayState(session);
                return true;
            }
            string? error = null;
            if (command == "mapgetitem")
            {
                EnsureMapEntities(player.Map);
                var drop = _groundItems.FirstOrDefault(d => d.Map == player.Map && d.X == player.X && d.Y == player.Y);
                if (drop is null) error = "There is no item here.";
                else
                {
                    var merge = _items.TryGetValue(drop.Num, out var definition) && definition.Type >= 4
                        ? player.Inventory.FirstOrDefault(i => i.Num == drop.Num && i.Value > 0
                            && i.Durability == drop.Durability && (long)i.Value + drop.Value <= int.MaxValue) : null;
                    var empty = player.Inventory.FindIndex(i => i.Num == 0 || i.Value == 0);
                    if (merge is not null) { merge.Value += drop.Value; RemoveGroundItem(drop, now); }
                    else if (empty < 0 && player.Inventory.Count >= GameLimits.MaxInventory) error = "Your inventory is full.";
                    else
                    {
                        var stack = new PlayerInventory { Num = drop.Num, Value = drop.Value, Durability = drop.Durability };
                        if (empty >= 0) player.Inventory[empty] = stack; else player.Inventory.Add(stack);
                        RemoveGroundItem(drop, now);
                    }
                }
            }
            else if (fields.Length < 2 || !int.TryParse(fields[1], out int slot) || slot < 1) return false;
            else if (command == "useitem")
            {
                if (now < session.NextItemSeconds) return false;
                error = GameplayRules.UseItem(player, slot, _items, _spells);
                if (error is null) session.NextItemSeconds = now + .25;
            }
            else if (command == "mapdropitem")
            {
                if (slot > player.Inventory.Count || player.Inventory[slot - 1].Value <= 0) error = "Invalid inventory slot.";
                else if (new[] { player.WeaponSlot, player.ArmorSlot, player.HelmetSlot, player.ShieldSlot }.Contains(slot)) error = "Unequip the item first.";
                else if (_groundItems.Count(d => d.Map == player.Map) >= GameLimits.MaxMapItems) error = "There are too many items on this map.";
                else
                {
                    var stack = player.Inventory[slot - 1];
                    _groundItems.Add(new(++_nextGroundId, player.Map, player.X, player.Y, stack.Num, stack.Value, stack.Durability));
                    stack.Num = 0; stack.Value = 0;
                }
            }
            else if (slot > player.Spells.Count || !_spells.TryGetValue(player.Spells[slot - 1], out var spell)) error = "Invalid spell slot.";
            else if (command == "forgetspell") player.Spells[slot - 1] = 0;
            else if (command == "cast")
            {
                int spellId = player.Spells[slot - 1];
                if (session.SpellCooldowns.GetValueOrDefault(spellId) > now) return false;
                string targetName = fields.ElementAtOrDefault(2) ?? player.Name;
                EnsureMapEntities(player.Map);
                if (_mapNpcs.ContainsKey(targetName)) return CastNpcSpell(session,spellId,spell,targetName,now);
                var target = _sessions.Values.FirstOrDefault(s => s.IsPlaying && s.Character?.Map == player.Map
                    && string.Equals(s.Character.Name, targetName, StringComparison.OrdinalIgnoreCase));
                if (target is null) error = "Target is unavailable.";
                else lock (target)
                {
                    if (target.Character is not { } victim || !target.IsPlaying) error = "Target is unavailable.";
                    else if (spell.Type is 0 or 2 && (!_mapCache.TryGetValue(player.Map, out var map) || map.Moral != 0)) error = "Combat spells cannot be used on a safe map.";
                    else
                    {
                        error = GameplayRules.Cast(player, victim, spell);
                        if (error is null)
                        {
                            session.SpellCooldowns[spellId] = now + Math.Clamp(double.IsFinite(spell.CooldownSeconds) ? spell.CooldownSeconds : 1, .25, 60);
                            _spellEffects.Add(new(player.Map, victim.X, victim.Y, spell.Graphic, now));
                            if (victim.HP == 0)
                            {
                                RespawnPlayer(target, now);
                            }
                            if (!ReferenceEquals(session, target)) SendGameplayState(target);
                        }
                    }
                }
            }
            if (error is not null) _network.SendText(id, PacketCodec.Compose("playermsg", error));
            else SendGameplayState(session);
            return error is null;
        }
    }

    private void SendGameplayState(PlayerSession session)
    {
        lock (session)
        {
            if (session.Character is not { } p || !session.IsPlaying) return;
            var inventory = p.Inventory.Select((i, index) => new {
                Slot = index + 1, ItemId = i.Num, Quantity = i.Value,
                Name = _items.TryGetValue(i.Num, out var item) ? item.Name : "", Picture = item?.Pic ?? -1,
                Equipped = new[] { p.WeaponSlot, p.ArmorSlot, p.HelmetSlot, p.ShieldSlot }.Contains(index + 1)
            }).ToArray();
            var spells = p.Spells.Select((n, index) => new {
                Slot = index + 1, SpellId = n, Name = _spells.TryGetValue(n, out var spell) ? spell.Name : "",
                Animation = spell?.Graphic ?? -1, ManaCost = spell?.MPReq ?? 0
            }).ToArray();
            _network.SendText(session.ConnectionId, PacketCodec.Compose("gameplaystate", JsonSerializer.Serialize(new {
                session.IsChargingMana, CanEditMap = p.Access >= 1, p.HP, p.MP, p.SP, p.MaxHP, p.MaxMP, p.MaxSP, Inventory = inventory, KnownSpells = spells,
                Quests = QuestJournalFor(p)
            })));
        }
    }

    private (object[] Items, object[] Spells, object[] Emotes, object[] ChatBubbles) CaptureGameplay(int map)
    {
        lock (_gameplayGate)
        {
            double now = NetworkClock.Seconds;
            foreach (var id in _chatBubbles.Where(e => now - e.Value.Started >= 5 || !_sessions.ContainsKey(e.Key)).Select(e => e.Key).ToArray()) _chatBubbles.Remove(id);
            _spellEffects.RemoveAll(e => now - e.Started >= .9);
            foreach (var id in _emotes.Where(e => now - e.Value.Started >= 3 || !_sessions.ContainsKey(e.Key)).Select(e => e.Key).ToArray()) _emotes.Remove(id);
            return (
                _groundItems.Where(d => d.Map == map && _items.ContainsKey(d.Num)).Select(d => (object)new { d.Id, d.X, d.Y, ItemId = d.Num, Quantity = d.Value, Name = _items[d.Num].Name, Picture = _items[d.Num].Pic }).ToArray(),
                _spellEffects.Where(e => e.Map == map).Select(e => (object)new { e.X, e.Y, e.Animation, AgeSeconds = now - e.Started }).ToArray(),
                _emotes.Values.Where(e => e.Map == map).Select(e => (object)new { e.PlayerName, e.Picture, RemainingSeconds = 3 - (now - e.Started) }).ToArray(),
                _chatBubbles.Values.Where(e => e.Map == map).Select(e => (object)new { e.PlayerName, e.Text, RemainingSeconds = 5 - (now - e.Started) }).ToArray());
        }
    }
}
