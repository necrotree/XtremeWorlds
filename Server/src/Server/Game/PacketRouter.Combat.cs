using XtremeWorlds.Networking;
using System.Text.Json;

namespace Server;

public sealed partial class PacketRouter
{
    private sealed class MapNpc
    {
        public required string Id { get; init; }
        public required int DefinitionId { get; init; }
        public required PlayerCharacter Actor { get; init; }
        public int? Aggressor { get; set; }
        public double NextAttack { get; set; }
        public double RespawnAt { get; set; }
        public double AttackStarted { get; set; } = -1;
    }
    private readonly Dictionary<string,MapNpc> _mapNpcs = new();
    private readonly HashSet<int> _initializedNpcMaps = new();
    private readonly Dictionary<(int Map,int Index),double> _itemSpawnReady = new();

    private async Task SeedCombatWorldAsync()
    {
        bool seedNpc = _npcs.Count == 0;
        if (seedNpc)
        {
            var dummy = new NpcDefinition { Name = "Training Dummy", Sprite = 3, MaxHP = 40, Strength = 3, Defense = 1,
                GiveEXP = 10, SpawnSecs = 15, Stationary = 1, DropChance = 100, DropItem = 1, DropItemValue = 1 };
            await _db.UpsertContentAsync("npc",1,dummy.Name,dummy);
            _npcs = new Dictionary<int,NpcDefinition> { [1] = dummy };
        }
        foreach (var (id,map) in _mapCache.OrderBy(m => m.Key).Take(1))
        {
            // Populate only the untouched starter map, keeping imported maps intact.
            if (map.Name != $"Map {id}" || map.Tiles.Any(t => t.Ground != 0 || t.Mask != 0 || t.Type != 0)) continue;
            bool changed = false;
            if (seedNpc && map.Npcs.All(n => n <= 0)) { map.Npcs = new() { 1 }; changed = true; }
            if (map.ItemSpawns.Count == 0 && _items.TryGetValue(1,out var potion) && potion.Name == "Health Potion")
            { map.ItemSpawns.Add(new() { ItemId = 1, Quantity = 1, X = 1, Y = 1, RespawnSeconds = 30 }); changed = true; }
            if (changed) await _db.UpsertContentAsync("map",id,map.Name,map);
        }
    }
    private void EnsureMapEntities(int mapId)
    {
        lock (_gameplayGate)
        {
            if (!_mapCache.TryGetValue(mapId,out var map)) return;
            double now = NetworkClock.Seconds;
            if (_initializedNpcMaps.Add(mapId))
                for (int slot = 0; slot < Math.Min(map.Npcs.Count,GameLimits.MaxMapNpcs); slot++)
                {
                    int id = map.Npcs[slot];
                    if (!_npcs.TryGetValue(id,out var definition) || definition.MaxHP <= 0) continue;
                    int tile = (5 + slot % 5 * 2) + (5 + slot / 5 * 2) * 16;
                    if (tile >= map.Tiles.Count || map.Tiles[tile].Type == 1)
                        tile = map.Tiles.FindIndex(t => t.Type != 1);
                    if (tile < 0 || tile >= 192) continue;
                    string key = $"npc:{mapId}:{slot}";
                    _mapNpcs[key] = new() { Id = key, DefinitionId = id,
                        Actor = new() { Name = definition.Name, Sprite = definition.Sprite, Map = (short)mapId,
                            X = (byte)(tile%16), Y = (byte)(tile/16), Direction = 1, HP = definition.MaxHP, MaxHP = definition.MaxHP,
                            Strength = definition.Strength, Defense = definition.Defense } };
                }
            for (int index = 0; index < Math.Min(map.ItemSpawns.Count,GameLimits.MaxMapItems); index++)
            {
                var spawn = map.ItemSpawns[index];
                if (spawn.X is < 0 or > 15 || spawn.Y is < 0 or > 11 || spawn.Quantity <= 0 || !_items.ContainsKey(spawn.ItemId)
                    || map.Tiles.ElementAtOrDefault(spawn.Y*16+spawn.X)?.Type == 1
                    || _itemSpawnReady.GetValueOrDefault((mapId,index)) > now
                    || _groundItems.Any(i => i.Map == mapId && i.SpawnIndex == index)
                    || _groundItems.Count(i => i.Map == mapId) >= GameLimits.MaxMapItems) continue;
                _groundItems.Add(new(++_nextGroundId,mapId,spawn.X,spawn.Y,spawn.ItemId,spawn.Quantity,0,index));
            }
        }
    }
    private void RemoveGroundItem(GroundItem item,double now)
    {
        _groundItems.Remove(item);
        if (item.SpawnIndex >= 0 && _mapCache.TryGetValue(item.Map,out var map) && item.SpawnIndex < map.ItemSpawns.Count)
        {
            double delay = map.ItemSpawns[item.SpawnIndex].RespawnSeconds;
            _itemSpawnReady[(item.Map,item.SpawnIndex)] = now + Math.Clamp(double.IsFinite(delay) ? delay : 30,1,86400);
        }
    }
    private static double? AttackAge(PlayerSession session) => session.AttackStartedSeconds >= 0
        && NetworkClock.Seconds - session.AttackStartedSeconds < .35 ? NetworkClock.Seconds - session.AttackStartedSeconds : null;
    private object[] CaptureMapNpcs(int map)
    {
        lock (_gameplayGate)
            return _mapNpcs.Values.Where(n => n.Actor.Map == map && n.Actor.HP > 0).Select(n => (object)new {
                TargetId = n.Id, n.Actor.Name, n.Actor.Sprite, n.Actor.X, n.Actor.Y, n.Actor.Direction, n.Actor.HP,n.Actor.MaxHP,
                AttackAgeSeconds = n.AttackStarted >= 0 && NetworkClock.Seconds - n.AttackStarted < .35 ? (double?)(NetworkClock.Seconds-n.AttackStarted) : null
            }).ToArray();
    }
    private bool HandleNormalAttack(PlayerSession session,string[] fields)
    {
        var player = session.Character!;
        if (fields.Length != 2 || fields[1].Length == 0 || fields[1].Length > 64 || player.HP <= 0 || session.IsJailed || session.NetworkState.Frozen) return false;
        double now = NetworkClock.Seconds;
        if (now < session.NextAttackSeconds) return false;
        session.NextAttackSeconds = now + CombatRules.AttackInterval;
        string name = fields[1];
        void Stop(string message) => _network.SendText(session.ConnectionId,PacketCodec.Compose("combatresult",name,message,true));
        EnsureMapEntities(player.Map);
        if (_mapNpcs.TryGetValue(name,out var npc))
        {
            if (npc.Actor.Map != player.Map || npc.Actor.HP <= 0 || !_npcs.TryGetValue(npc.DefinitionId,out var definition) || definition.Behavior == 2)
            { Stop("That NPC cannot be attacked."); return false; }
            if (!CombatRules.InRange(player,npc.Actor)) { Stop("Move closer to attack."); return false; }
            CombatRules.Face(player,npc.Actor);
            session.AttackStartedSeconds = now;
            int damage = CombatRules.Damage((int)Math.Clamp((long)player.Strength + CombatRules.EquipmentBonus(player,_items,true),0,100000),npc.Actor.Defense);
            npc.Actor.HP = Math.Max(0,npc.Actor.HP-damage);
            npc.Aggressor = session.ConnectionId;
            if (npc.Actor.HP == 0)
            {
                DefeatNpc(session,npc,definition,now);
                Stop($"Defeated {npc.Actor.Name}. Press E on its loot to pick it up.");
            }
            SendGameplayState(session);
            return true;
        }
        var target = _sessions.Values.FirstOrDefault(s => s.IsPlaying && s.Character?.Map == player.Map && string.Equals(s.Character.Name,name,StringComparison.OrdinalIgnoreCase));
        if (target is null || ReferenceEquals(target,session)) { Stop("Choose another target."); return false; }
        lock (target)
        {
            if (!target.IsPlaying || target.Character is not { } victim || victim.HP <= 0 || target.IsJailed || target.NetworkState.Frozen)
            { Stop("That target is unavailable."); return false; }
            if (!_mapCache.TryGetValue(player.Map,out var map) || map.Moral != 0) { Stop("Normal attacks cannot be used against players on a safe map."); return false; }
            if (!CombatRules.InRange(player,victim)) { Stop("Move closer to attack."); return false; }
            CombatRules.Face(player,victim); session.AttackStartedSeconds = now;
            int strength = (int)Math.Clamp((long)player.Strength+CombatRules.EquipmentBonus(player,_items,true),0,100000);
            int defense = (int)Math.Clamp((long)victim.Defense+CombatRules.EquipmentBonus(victim,_items,false),0,100000);
            victim.HP = Math.Max(0,victim.HP-CombatRules.Damage(strength,defense));
            if (victim.HP == 0) { RespawnPlayer(target,now); Stop($"Defeated {victim.Name}."); }
            SendGameplayState(target); SendGameplayState(session);
            return true;
        }
    }
    private void DefeatNpc(PlayerSession session,MapNpc npc,NpcDefinition definition,double now)
    {
        var player = session.Character!;
        npc.Aggressor = null; npc.RespawnAt = now + Math.Clamp(definition.SpawnSecs,1,86400);
        player.Exp = (int)Math.Clamp((long)player.Exp+Math.Max(0,definition.GiveEXP),0,int.MaxValue);
        if (_items.ContainsKey(definition.DropItem) && definition.DropItemValue > 0
            && Random.Shared.Next(100) < Math.Clamp((int)definition.DropChance,0,100)
            && _groundItems.Count(i => i.Map == player.Map) < GameLimits.MaxMapItems)
            _groundItems.Add(new(++_nextGroundId,player.Map,npc.Actor.X,npc.Actor.Y,definition.DropItem,definition.DropItemValue,0));
    }
    private bool CastNpcSpell(PlayerSession session,int spellId,SpellDefinition spell,string key,double now)
    {
        var player = session.Character!;
        var npc = _mapNpcs[key];
        string? error = npc.Actor.Map != player.Map || npc.Actor.HP <= 0 || !_npcs.TryGetValue(npc.DefinitionId,out var definition) || definition.Behavior == 2
            ? "That NPC cannot be targeted." : GameplayRules.Cast(player,npc.Actor,spell);
        if (error is not null) { _network.SendText(session.ConnectionId,PacketCodec.Compose("playermsg",error)); return false; }
        session.SpellCooldowns[spellId] = now + Math.Clamp(double.IsFinite(spell.CooldownSeconds) ? spell.CooldownSeconds : 1,.25,60);
        _spellEffects.Add(new(player.Map,npc.Actor.X,npc.Actor.Y,spell.Graphic,now));
        if (spell.Type is 0 or 2) npc.Aggressor = session.ConnectionId;
        if (npc.Actor.HP == 0)
        {
            DefeatNpc(session,npc,_npcs[npc.DefinitionId],now);
            _network.SendText(session.ConnectionId,PacketCodec.Compose("combatresult",key,$"Defeated {npc.Actor.Name}. Press E on its loot to pick it up.",true));
        }
        SendGameplayState(session);
        return true;
    }
    private void RespawnPlayer(PlayerSession target,double now)
    {
        var victim = target.Character!;
        victim.HP = Math.Max(1,victim.MaxHP);
        victim.X = (byte)Math.Clamp(_mapCache.TryGetValue(victim.Map,out var map) && map.BootMap == victim.Map ? map.BootX : 0,0,15);
        victim.Y = (byte)Math.Clamp(map is not null && map.BootMap == victim.Map ? map.BootY : 0,0,11);
        victim.PixelX = victim.X*32.0; victim.PixelY = victim.Y*32.0;
        target.NetworkState.Begin(Pose(victim),System.Threading.Interlocked.Read(ref _serverTick),now);
        _network.SendText(target.ConnectionId,PacketCodec.Compose("combatresult","","You were defeated and respawned.",true));
    }
    private void TickCombatWorld()
    {
        lock (_gameplayGate)
        {
            foreach (var map in _sessions.Values.Where(s => s.IsPlaying && s.Character is not null).Select(s => (int)s.Character!.Map).Distinct()) EnsureMapEntities(map);
            double now = NetworkClock.Seconds;
            foreach (var npc in _mapNpcs.Values)
            {
                if (!_npcs.TryGetValue(npc.DefinitionId,out var definition)) continue;
                if (npc.Actor.HP <= 0)
                {
                    if (now >= npc.RespawnAt) { npc.Actor.HP = npc.Actor.MaxHP; npc.AttackStarted = -1; }
                    continue;
                }
                if (npc.Aggressor is not int id) continue;
                if (!_sessions.TryGetValue(id,out var target) || !target.IsPlaying || target.Character is null) { npc.Aggressor = null; continue; }
                lock (target)
                {
                    var player = target.Character;
                    if (player.HP <= 0 || target.IsJailed || target.NetworkState.Frozen || !CombatRules.InRange(npc.Actor,player)) { npc.Aggressor = null; continue; }
                    if (now < npc.NextAttack) continue;
                    npc.NextAttack = now + 1;
                    npc.AttackStarted = now; CombatRules.Face(npc.Actor,player);
                    int defense = (int)Math.Clamp((long)player.Defense+CombatRules.EquipmentBonus(player,_items,false),0,100000);
                    player.HP = Math.Max(0,player.HP-CombatRules.Damage(npc.Actor.Strength,defense));
                    if (player.HP == 0) { RespawnPlayer(target,now); npc.Aggressor = null; }
                    SendGameplayState(target);
                    if (target.Login.Length > 0 && target.CharacterSlot > 0)
                        _gameplaySave = SaveGameplayAfterAsync(_gameplaySave,new() { (target.Login,target.CharacterSlot,JsonSerializer.Deserialize<PlayerCharacter>(JsonSerializer.Serialize(player))!) },id);
                }
            }
        }
    }
    private async Task EditMapItemSpawnsAsync(int id,string command,string[] fields)
    {
        await _contentEditorGate.WaitAsync();
        try { await EditMapItemSpawnsCoreAsync(id,command,fields); }
        finally { _contentEditorGate.Release(); }
    }
    private async Task EditMapItemSpawnsCoreAsync(int id,string command,string[] fields)
    {
        if (!_sessions.TryGetValue(id,out var session) || !session.IsPlaying || session.Character is null || session.Character.Access < 1 || session.IsJailed)
        { _network.SendText(id,PacketCodec.Compose("playermsg","Only map administrators can edit item spawns.")); return; }
        int mapId = session.Character.Map;
        var map = await GetMapAsync(mapId);
        Task save;
        lock (_gameplayGate)
        lock (session)
        {
            if (!session.IsPlaying || session.Character?.Map != mapId || session.Character.Access < 1 || session.IsJailed) return;
            if (command == "spawnmapitem")
            {
                if (fields.Length != 6 || !int.TryParse(fields[1],out int item) || !_items.ContainsKey(item)
                    || !int.TryParse(fields[2],out int quantity) || quantity is < 1 or > 1000000
                    || !int.TryParse(fields[3],out int x) || x is < 0 or > 15
                    || !int.TryParse(fields[4],out int y) || y is < 0 or > 11
                    || !int.TryParse(fields[5],out int seconds) || seconds is < 1 or > 86400
                    || map.ItemSpawns.Count >= GameLimits.MaxMapItems || map.Tiles.ElementAtOrDefault(y*16+x)?.Type == 1)
                { _network.SendText(id,PacketCodec.Compose("playermsg","Choose a valid item, quantity, walkable tile, and respawn time. A map supports 20 item spawns.")); return; }
                map.ItemSpawns.Add(new() { ItemId = item, Quantity = quantity, X = x, Y = y, RespawnSeconds = seconds });
            }
            else
            {
                if (fields.Length != 2 || !int.TryParse(fields[1],out int index) || index < 0 || index >= map.ItemSpawns.Count) return;
                map.ItemSpawns.RemoveAt(index);
                _groundItems.RemoveAll(i => i.Map == mapId && i.SpawnIndex >= 0);
                foreach (var key in _itemSpawnReady.Keys.Where(k => k.Map == mapId).ToArray()) _itemSpawnReady.Remove(key);
            }
            map.Revision++;
            var snapshot = JsonSerializer.Deserialize<MapDefinition>(JsonSerializer.Serialize(map))!;
            save = _gameplaySave = SaveMapItemsAfterAsync(_gameplaySave,id,mapId,snapshot);
        }
        SendWorldSnapshot(mapId,map);
        await save;
    }
    private async Task SaveMapItemsAfterAsync(Task previous,int id,int mapId,MapDefinition map)
    {
        await previous;
        try { await _db.UpsertContentAsync("map",mapId,map.Name,map); _network.SendText(id,PacketCodec.Compose("playermsg","Map item spawns saved.")); }
        catch (Exception ex) { _log?.Invoke($"Map item spawn save failed: {ex.Message}"); _network.SendText(id,PacketCodec.Compose("playermsg","Item spawns changed, but the database could not save them.")); }
    }

}
