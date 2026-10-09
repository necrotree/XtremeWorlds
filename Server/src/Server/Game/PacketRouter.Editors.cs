using System.Text.Json;
using XtremeWorlds.Networking.Content;

namespace Server;

public sealed partial class PacketRouter
{
    private readonly SemaphoreSlim _contentEditorGate = new(1,1);
    private bool CanEditContent(int id) => _sessions.TryGetValue(id,out var s) && s.IsPlaying && s.Character is { Access: >= 1 } && !s.IsJailed;
    private void EditorReply(int id,string kind,int definitionId,bool success,string message) =>
        _network.SendText(id,PacketCodec.Compose("contenteditorresult",kind,definitionId,success,message));
    private void SendContentDefinition(int id,string kind,int definitionId)
    {
        object value;
        ContentSummary[] catalog;
        lock (_gameplayGate)
        {
            if (kind == "item")
            {
                value = _items.TryGetValue(definitionId,out var item) ? item : new ItemDefinition();
                catalog = _items.OrderBy(i=>i.Key).Select(i=>new ContentSummary { Id=i.Key,Name=i.Value.Name }).ToArray();
            }
            else
            {
                value = _npcs.TryGetValue(definitionId,out var npc) ? npc : new NpcDefinition { MaxHP=10,SpawnSecs=15,Stationary=1,Range=1 };
                catalog = _npcs.OrderBy(i=>i.Key).Select(i=>new ContentSummary { Id=i.Key,Name=i.Value.Name }).ToArray();
            }
            _network.SendText(id,PacketCodec.Compose("contentdefinition",kind,definitionId,JsonSerializer.Serialize(value),JsonSerializer.Serialize(catalog)));
        }
    }
    private async Task HandleContentEditorAsync(int id,string command,string[] fields)
    {
        string kind = fields.ElementAtOrDefault(1) ?? "";
        int.TryParse(fields.ElementAtOrDefault(2),out int definitionId);
        if (!CanEditContent(id)) { EditorReply(id,kind,definitionId,false,"Only administrators can edit game definitions."); return; }
        if (command == "placemapnpc") { await PlaceMapNpcAsync(id,fields); return; }
        int maximum = kind == "item" ? _settings.MaxItems : kind == "npc" ? _settings.MaxNpcs : 0;
        if (definitionId < 1 || definitionId > maximum) { EditorReply(id,kind,definitionId,false,"Choose a valid definition ID."); return; }
        if (command == "requestcontenteditor") { SendContentDefinition(id,kind,definitionId); return; }
        if (fields.Length != 4 || fields[3].Length > 16384) { EditorReply(id,kind,definitionId,false,"Invalid definition data."); return; }
        await _contentEditorGate.WaitAsync();
        try
        {
            if (!CanEditContent(id)) { EditorReply(id,kind,definitionId,false,"Editor access is no longer available."); return; }
            object definition;
            string? error;
            try
            {
                if (kind == "item") { var item = JsonSerializer.Deserialize<ItemDefinition>(fields[3]) ?? throw new JsonException(); error = ContentValidation.Item(item,_settings,_spells); item.Name=item.Name?.Trim()??""; definition=item; }
                else { var npc = JsonSerializer.Deserialize<NpcDefinition>(fields[3]) ?? throw new JsonException(); error=ContentValidation.Npc(npc,_items); npc.Name=npc.Name?.Trim()??""; definition=npc; }
            }
            catch (JsonException) { EditorReply(id,kind,definitionId,false,"Invalid definition data."); return; }
            if (error is not null) { EditorReply(id,kind,definitionId,false,error); return; }
            string name = kind == "item" ? ((ItemDefinition)definition).Name : ((NpcDefinition)definition).Name;
            // Apply only after the database accepts the change, so failed saves preserve the live definition.
            try { await _db.UpsertContentAsync(kind,definitionId,name,definition); }
            catch (Exception ex) { _log?.Invoke($"Content editor save failed: {ex.Message}"); EditorReply(id,kind,definitionId,false,"The database could not save this definition. Your draft is still open."); return; }
            lock (_gameplayGate)
            {
                if (kind == "item") { var next=new Dictionary<int,ItemDefinition>(_items); next[definitionId]=(ItemDefinition)definition; _items=next; }
                else
                {
                    var next=new Dictionary<int,NpcDefinition>(_npcs); next[definitionId]=(NpcDefinition)definition; _npcs=next;
                    foreach (var runtime in _mapNpcs.Values.Where(n=>n.DefinitionId==definitionId))
                    {
                        var npc=(NpcDefinition)definition;
                        runtime.Actor.Name=npc.Name; runtime.Actor.Sprite=npc.Sprite; runtime.Actor.MaxHP=npc.MaxHP;
                        runtime.Actor.HP=Math.Min(runtime.Actor.HP,npc.MaxHP); runtime.Actor.Strength=npc.Strength; runtime.Actor.Defense=npc.Defense;
                        if (npc.Behavior==2) runtime.Aggressor=null;
                    }
                }
            }
            foreach (var session in _sessions.Values.Where(s=>s.IsPlaying)) SendGameplayState(session);
            EditorReply(id,kind,definitionId,true,$"{(kind=="item"?"Item":"NPC")} saved.");
            SendContentDefinition(id,kind,definitionId);
        }
        finally { _contentEditorGate.Release(); }
    }
    private async Task PlaceMapNpcAsync(int id,string[] fields)
    {
        // placemapnpc uses kind=npc and the definition ID as its two arguments.
        if (fields.Length!=3 || fields[1]!="npc" || !int.TryParse(fields[2],out int definitionId) || !_npcs.ContainsKey(definitionId))
        { EditorReply(id,"npc",0,false,"Save a valid NPC definition before placing it."); return; }
        await _contentEditorGate.WaitAsync();
        try
        {
            if (!CanEditContent(id)) return;
            var session=_sessions[id]; int mapId=session.Character!.Map;
            var map=await GetMapAsync(mapId);
            MapDefinition copy;
            lock (_gameplayGate)
            {
                if (map.Npcs.Count(n=>n>0)>=GameLimits.MaxMapNpcs) { EditorReply(id,"npc",definitionId,false,"This map already has ten NPC slots."); return; }
                copy=JsonSerializer.Deserialize<MapDefinition>(JsonSerializer.Serialize(map))!;
                int empty=copy.Npcs.FindIndex(n=>n<=0);
                if (empty>=0) copy.Npcs[empty]=definitionId; else copy.Npcs.Add(definitionId);
                copy.Revision++;
            }
            try { await _db.UpsertContentAsync("map",mapId,copy.Name,copy); }
            catch (Exception ex) { _log?.Invoke($"NPC placement save failed: {ex.Message}"); EditorReply(id,"npc",definitionId,false,"The database could not save this NPC placement."); return; }
            lock (_gameplayGate)
            {
                map.Npcs=copy.Npcs; map.Revision=copy.Revision;
                _initializedNpcMaps.Remove(mapId);
                foreach (var key in _mapNpcs.Where(n=>n.Value.Actor.Map==mapId).Select(n=>n.Key).ToArray()) _mapNpcs.Remove(key);
                EnsureMapEntities(mapId);
            }
            SendWorldSnapshot(mapId,map);
            EditorReply(id,"npc",definitionId,true,"NPC added to the current map.");
        }
        finally { _contentEditorGate.Release(); }
    }
}
