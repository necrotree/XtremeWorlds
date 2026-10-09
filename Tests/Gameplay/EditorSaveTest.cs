using Server;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using System.Reflection;
using System.Collections.Concurrent;

static class EditorSaveTest
{
    public static async Task Run()
    {
        using var listener=new TcpListener(IPAddress.Loopback,0); listener.Start();
        int port=((IPEndPoint)listener.LocalEndpoint).Port;
        var settings=new ServerSettings { SpacetimeUri=$"http://127.0.0.1:{port}",SpacetimeDatabase="editor-test",SpacetimeConnectTimeoutSeconds=3 };
        using var db=new SpacetimeRepository(settings);
        var sessions=new ConcurrentDictionary<int,PlayerSession>();
        sessions[1]=new() { ConnectionId=1,IsPlaying=true,Character=new() { Name="Admin",Access=1,Map=1,HP=100 } };
        var router=new PacketRouter(settings,new MirrorTcpHost(0,65536,true),db,sessions);
        void Set(string name,object value)=>typeof(PacketRouter).GetField(name,BindingFlags.Instance|BindingFlags.NonPublic)!.SetValue(router,value);
        object Get(string name)=>typeof(PacketRouter).GetField(name,BindingFlags.Instance|BindingFlags.NonPublic)!.GetValue(router)!;
        Set("_items",new Dictionary<int,ItemDefinition> { [1]=new() { Name="Original",Type=4,Data1=10 } });
        Set("_npcs",new Dictionary<int,NpcDefinition> { [1]=new() { Name="Original NPC",Sprite=1,MaxHP=10,SpawnSecs=10 } });
        var map=new MapDefinition { Name="Test map",Npcs=new() { 1 },Tiles=Enumerable.Range(0,192).Select(_=>new TileDefinition()).ToList() };
        ((ConcurrentDictionary<int,MapDefinition>)Get("_mapCache"))[1]=map;
        typeof(PacketRouter).GetMethod("EnsureMapEntities",BindingFlags.Instance|BindingFlags.NonPublic)!.Invoke(router,new object[] { 1 });
        async Task<string> Request(string command,bool success,params object[] args)
        {
            var handling=router.HandleAsync(1,PacketCodec.Compose(command,args));
            using var socket=await listener.AcceptTcpClientAsync().WaitAsync(TimeSpan.FromSeconds(5));
            var stream=socket.GetStream(); using var reader=new StreamReader(stream,Encoding.UTF8,leaveOpen:true);
            int length=0; string? line;
            while(!string.IsNullOrEmpty(line=await reader.ReadLineAsync())) if(line.StartsWith("Content-Length:",StringComparison.OrdinalIgnoreCase)) length=int.Parse(line.Split(':')[1]);
            var buffer=new char[length]; int offset=0;
            while(offset<length) { int count=await reader.ReadAsync(buffer.AsMemory(offset)); if(count==0) throw new EndOfStreamException(); offset+=count; }
            var reply=Encoding.ASCII.GetBytes($"HTTP/1.1 {(success?"200 OK":"500 Internal Server Error")}\r\nContent-Length: 0\r\nConnection: close\r\n\r\n");
            await stream.WriteAsync(reply); socket.Close(); await handling.WaitAsync(TimeSpan.FromSeconds(5));
            return new string(buffer);
        }
        var item=new ItemDefinition { Name="Saved Potion",Type=4,Data1=30,Pic=2 };
        await Request("savecontentdefinition",false,"item",1,JsonSerializer.Serialize(item));
        if(((IReadOnlyDictionary<int,ItemDefinition>)Get("_items"))[1].Name!="Original") throw new Exception("Failed editor saves must preserve the live cache.");
        string body=await Request("savecontentdefinition",true,"item",1,JsonSerializer.Serialize(item));
        using(var json=JsonDocument.Parse(body)) if(json.RootElement[1].GetString()!="item" || !json.RootElement[4].GetString()!.Contains("Saved Potion")) throw new Exception("Item save must persist its definition JSON.");
        if(((IReadOnlyDictionary<int,ItemDefinition>)Get("_items"))[1].Data1!=30) throw new Exception("Successful item saves must update live gameplay.");
        var npc=new NpcDefinition { Name="Saved NPC",Sprite=3,MaxHP=50,Strength=12,SpawnSecs=15,DropItem=1,DropItemValue=1,DropChance=100 };
        await Request("savecontentdefinition",true,"npc",1,JsonSerializer.Serialize(npc));
        var runtime=((System.Collections.IDictionary)Get("_mapNpcs")).Values.Cast<object>().Single();
        var actor=(PlayerCharacter)runtime.GetType().GetProperty("Actor")!.GetValue(runtime)!;
        if(actor.Name!="Saved NPC" || actor.Strength!=12 || actor.MaxHP!=50 || actor.HP!=10) throw new Exception("NPC edits must update live stats while preserving existing damage.");
        await Request("placemapnpc",false,"npc",1);
        if(map.Npcs.Count!=1) throw new Exception("Failed map saves must not place an NPC.");
        await Request("placemapnpc",true,"npc",1);
        if(map.Npcs.Count!=2 || ((System.Collections.IDictionary)Get("_mapNpcs")).Count!=2) throw new Exception("NPC placement must persist and spawn the map's NPC slots.");
        Console.WriteLine("Editor database failure handling, JSON saves, live definition updates, and persistent NPC placement checks passed.");
    }
}
