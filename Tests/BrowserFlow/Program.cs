using Microsoft.AspNetCore.Http;
using System.Net.WebSockets;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting.Server;
using Microsoft.AspNetCore.Hosting.Server.Features;
using System.IO.Compression;
using System.Text.Json;
using XtremeWorlds.Client.Engine.Graphics;
using System.Buffers.Binary;
using System.Net;
using System.Net.Sockets;
using System.Text;
using Client.Blazor.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Components.Web;
using XtremeWorlds.Client.Engine.Networking;

void Check(bool condition, string message)
{
    if (!condition) throw new Exception(message);
}
bool ColoredPngPixel(byte[] png, int x, int y)
{
    int width = BinaryPrimitives.ReadInt32BigEndian(png.AsSpan(16, 4));
    int height = BinaryPrimitives.ReadInt32BigEndian(png.AsSpan(20, 4));
    Check(width == 950 && height == 700 && png[24] == 8 && png[25] is 2 or 6, "Capture uses the native 950x700 RGB/RGBA surface");
    int channels = png[25] == 6 ? 4 : 3, stride = width * channels;
    using var compressed = new MemoryStream();
    for (int offset = 8; offset < png.Length;)
    {
        int length = BinaryPrimitives.ReadInt32BigEndian(png.AsSpan(offset, 4));
        if (Encoding.ASCII.GetString(png, offset + 4, 4) == "IDAT") compressed.Write(png, offset + 8, length);
        offset += length + 12;
    }
    compressed.Position = 0;
    using var zlib = new ZLibStream(compressed, CompressionMode.Decompress);
    var previous = new byte[stride]; var row = new byte[stride];
    for (int rowIndex = 0; rowIndex <= y; rowIndex++)
    {
        int filter = zlib.ReadByte();
        zlib.ReadExactly(row);
        for (int column = 0; column < stride; column++)
        {
            int left = column >= channels ? row[column - channels] : 0, up = previous[column];
            int upperLeft = column >= channels ? previous[column - channels] : 0;
            int prediction = left + up - upperLeft;
            int a = Math.Abs(prediction - left), b = Math.Abs(prediction - up), c = Math.Abs(prediction - upperLeft);
            row[column] = unchecked((byte)(row[column] + (filter switch {
                0 => 0, 1 => left, 2 => up, 3 => (left + up) / 2,
                4 => a <= b && a <= c ? left : b <= c ? up : upperLeft,
                _ => throw new Exception("Unsupported PNG filter")
            })));
        }
        if (rowIndex == y) return row[x * channels] + row[x * channels + 1] + row[x * channels + 2] > 30;
        (previous, row) = (row, previous);
    }
    return false;
}
async Task<string> ReadPacket(NetworkStream stream)
{
    var header = new byte[4];
    await stream.ReadExactlyAsync(header);
    var payload = new byte[BinaryPrimitives.ReadInt32BigEndian(header)];
    await stream.ReadExactlyAsync(payload);
    return Encoding.UTF8.GetString(payload);
}
async Task WritePacket(NetworkStream stream, string text)
{
    var bytes = Encoding.UTF8.GetBytes(text);
    var header = new byte[4];
    BinaryPrimitives.WriteInt32BigEndian(header, bytes.Length);
    await stream.WriteAsync(header);
    await stream.WriteAsync(bytes);
}
async Task VerifyStream(BrowserFnaRenderer activeRenderer)
{
    var builder = WebApplication.CreateBuilder();
    builder.Logging.ClearProviders();
    await using var app = builder.Build();
    app.UseWebSockets();
    app.MapGet("/game-frames/{id}", (HttpContext context, string id) => BrowserFrameStream.ServeAsync(context, id));
    app.Urls.Add("http://127.0.0.1:0");
    await app.StartAsync();
    string address = app.Services.GetRequiredService<IServer>().Features.Get<IServerAddressesFeature>()!.Addresses.Single();
    using var cancellation = new CancellationTokenSource(TimeSpan.FromSeconds(10));
    using var http = new HttpClient(new HttpClientHandler { UseProxy = false });
    Check((await http.GetAsync(address + "/game-frames/missing", cancellation.Token)).StatusCode == HttpStatusCode.NotFound,
        "Unknown stream cannot access another session");
    Check((await http.GetAsync(address + "/game-frames/" + activeRenderer.StreamId, cancellation.Token)).StatusCode == HttpStatusCode.BadRequest,
        "Frame endpoint requires WebSocket upgrade");
    using var socket = new ClientWebSocket();
    socket.Options.Proxy = null;
    await socket.ConnectAsync(new Uri(address.Replace("http:", "ws:") + "/game-frames/" + activeRenderer.StreamId), cancellation.Token);
    var frameClock = System.Diagnostics.Stopwatch.StartNew();
    var buffer = new byte[64 * 1024];
    for (int frameIndex = 0; frameIndex < 3; frameIndex++)
    {
        using var frame = new MemoryStream();
        WebSocketReceiveResult result;
        do
        {
            result = await socket.ReceiveAsync(buffer, cancellation.Token);
            Check(result.MessageType == WebSocketMessageType.Binary, "Stream sends binary frames");
            frame.Write(buffer, 0, result.Count);
        } while (!result.EndOfMessage);
        var encoded = frame.ToArray();
        if (encoded.Length >= 12 && BinaryPrimitives.ReadUInt32BigEndian(encoded) == 0x58575031)
        {
            int x = BinaryPrimitives.ReadInt32BigEndian(encoded.AsSpan(4,4));
            int y = BinaryPrimitives.ReadInt32BigEndian(encoded.AsSpan(8,4));
            int width = BinaryPrimitives.ReadInt32BigEndian(encoded.AsSpan(28,4));
            int height = BinaryPrimitives.ReadInt32BigEndian(encoded.AsSpan(32,4));
            Check(encoded[12] == 137 && encoded[13] == 80 && width > 0 && height > 0
                && x >= 0 && y >= 0 && x + width <= 950 && y + height <= 700, "WebSocket patches contain a PNG within the native surface");
        }
        else Check(ColoredPngPixel(encoded, 100, 100), "WebSocket delivers visible native keyframes without Blazor draw calls");
    }
    Console.WriteLine($"WebSocket delivered three native frames in {frameClock.Elapsed.TotalMilliseconds:F0} ms.");
    await socket.CloseOutputAsync(WebSocketCloseStatus.NormalClosure, "test complete", cancellation.Token);
    await app.StopAsync(cancellation.Token);
}
using var listener = new TcpListener(IPAddress.Loopback, 0);
listener.Start();
var port = ((IPEndPoint)listener.LocalEndpoint).Port;
var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
{
    ["GameServer:Host"] = "127.0.0.1", ["GameServer:Port"] = port.ToString()
}).Build();
var chargeOnWire = new TaskCompletionSource();
var chargeStoppedOnWire = new TaskCompletionSource();
var combatOnWire = new TaskCompletionSource();
var movedOnWire = new TaskCompletionSource(TaskCreationOptions.RunContinuationsAsynchronously);
using var renderer = new BrowserFnaRenderer();
using var session = new BrowserGameSession(config, renderer);
Check(!session.InGame && session.Characters.Length == 0, "Start in main menu");
session.Authenticate("", "", false);
Check(!session.Connected && session.Status.Contains("username"), "Reject empty credentials");
var server = Task.Run(async () =>
{
    using var client = await listener.AcceptTcpClientAsync();
    using var stream = client.GetStream();
    Check(PacketCodec.Parse(await ReadPacket(stream))[0] == "login", "Send login packet");
    await WritePacket(stream, PacketCodec.Build("allchars", "Hero", "Fighter", 1, 1, "", "", 0, 0, "", "", 0, 0));
    Check(PacketCodec.Parse(await ReadPacket(stream)).SequenceEqual(new[] { "usechar", "1" }), "Use one-based character slot");
    await WritePacket(stream, PacketCodec.Build("ingame"));
    await WritePacket(stream, PacketCodec.Build("playerdata", "Hero", 1, 1, 0, 0, 0));
    Check(PacketCodec.Parse(await ReadPacket(stream))[0] == "needmap", "Request the current map when entering the game");
    await WritePacket(stream, PacketCodec.Build("gameplaystate", JsonSerializer.Serialize(new FnaGameplayState {
        CanEditMap = true, HP = 45, MaxHP = 100, MP = 30, MaxMP = 50, SP = 80, MaxSP = 100,
        Quests = new() { new FnaQuestStatus { Id = 1, Name = "Supplies", Map = 1, X = 6, Y = 6, Status = "available" } }
    })));
    await WritePacket(stream, PacketCodec.Build("worldstate", JsonSerializer.Serialize(new FnaWorldScene {
        MapId = 1, ServerTick = 1, AckInputSequence = 0, NetworkEpoch = "browser-test", TickRate = 60,
        Map = new FnaSceneMap { Name = "Browser test map", Tileset = 1,
            Tiles = Enumerable.Range(0, 192).Select(_ => new FnaSceneTile { Ground = 1 }).ToList() },
        Player = new FnaScenePlayer { Name = "Hero", Sprite = 1, X = 1, Y = 1, Direction = 3 },
        Players = new() { new FnaScenePlayer { Name = "Hero", Sprite = 1, X = 1, Y = 1, Direction = 3 } },
        Npcs = new() { new FnaScenePlayer { TargetId = "npc:1:0", Name = "Dummy", Sprite = 3, X = 2, Y = 1, HP = 100, MaxHP = 100 } },
        ChatBubbles = new() { new FnaSceneChatBubble { PlayerName = "Hero", Text = "Hello there", RemainingSeconds = 5 } },
        QuestBlips = new() { new FnaSceneQuestBlip { QuestId = 1, Name = "Supplies", X = 6, Y = 6, Sprite = 2, Status = "available" } }
    })));
    IReadOnlyList<string> chat;
    do { chat = PacketCodec.Parse(await ReadPacket(stream)); } while (chat[0] == "netping");
    Check(chat[0] == "saymsg" && chat[1] == "hi", "Forward browser chat through the FNA input queue");
    await WritePacket(stream, PacketCodec.Build("saymsg", "Server reply"));
    IReadOnlyList<string> move;
    do { move = PacketCodec.Parse(await ReadPacket(stream)); } while (move[0] == "netping");
    Check(move[0] == "playermove" && move.Count == 7 && move[1] == "3" && move[2] == "1" && move[6] == "browser-test",
        "Browser arrows forward ticked movement with the current epoch");
    movedOnWire.SetResult();
    int attacks = 0; bool pickedUp = false;
    while (attacks < 2 || !pickedUp)
    {
        var combat = PacketCodec.Parse(await ReadPacket(stream));
        if (combat[0] == "attack") { Check(combat.Count == 2 && combat[1] == "npc:1:0", "Right-click attacks use the stable NPC target ID"); attacks++; }
        else if (combat[0] == "mapgetitem") pickedUp = true;
    }
    combatOnWire.SetResult();
    bool heldCharge = false;
    while (true)
    {
        var charge = PacketCodec.Parse(await ReadPacket(stream));
        if (charge[0] != "chargemana") continue;
        if (charge[1] == "1") { heldCharge = true; chargeOnWire.TrySetResult(); }
        if (charge[1] == "0" && heldCharge) { chargeStoppedOnWire.TrySetResult(); break; }
    }
    await Task.Delay(500);
});
session.Authenticate("test", "test-password", false);
async Task Until(Func<bool> done, string message)
{
    var end = DateTime.UtcNow.AddSeconds(15);
    while (!done() && DateTime.UtcNow < end)
    {
        session.Poll();
        if (renderer.Failure is not null) throw new Exception(renderer.Failure);
        await Task.Delay(50);
    }
    Check(done(), message);
}
await Until(() => session.Characters.Length == 3, "Receive character slots");
Check(!session.InGame && session.Characters[0] == "Hero", "Stay in menu before selecting a character");
session.SelectCharacter(0);
await Until(() => session.InGame && renderer.Frame is not null && renderer.NetworkState.Latest != null, "Receive a native FNA frame after entering the world");
renderer.Graphics.SelectTarget("Hero");
await Task.Delay(250);
session.Poll();
Check(renderer.NetworkState.Latest?.Players["Hero"].X == 32, "Browser submits world state to the shared FNA pipeline");
Check(session.Gameplay.HP == 45 && session.Gameplay.Quests.Count == 1, "Authoritative vitals and quest journal reach the browser session");
Check(session.SelectedTarget == "Hero", "Selected actor remains selected across native render updates");
var frame = renderer.Frame!;
Check(frame.Length > 1000 && frame[0] == 137 && frame[1] == 80, "FNA encodes PNG frames");
Check(ColoredPngPixel(frame, 100, 100), "Captured map contains textured pixels rather than a blank viewport");
Check(!ColoredPngPixel(frame, 690, 200), "The browser HUD is rendered by Blazor rather than baked into native frames");
if (args.Length > 0) await File.WriteAllBytesAsync(args[0], frame);
using (var competing = new BrowserFnaRenderer()) Check(!competing.Start(), "Reject simultaneous native Game loops in one host");
renderer.Key("h"); renderer.Key("i"); renderer.Key("Enter");
renderer.Movement("ArrowRight", true);
await Until(() => movedOnWire.Task.IsCompleted, "Browser movement reaches the server");
renderer.Movement("ArrowRight", false);
renderer.RightClick(98,66); renderer.Key("Pickup");
await Until(() => combatOnWire.Task.IsCompleted, "Right-click autoattack repeats and pickup reaches the server");
renderer.Key("StopAttack");
await Until(() => !renderer.Graphics.IsAutoAttacking, "Explicit stop ends autoattack");
renderer.Key("ChargeStart");
await Until(() => chargeOnWire.Task.IsCompleted, "Held Space forwards charge pulses to the server");
renderer.Key("ChargeStop");
await Until(() => chargeStoppedOnWire.Task.IsCompleted, "Released Space stops charging on the wire");
await VerifyStream(renderer);
await Until(() => server.IsCompleted, "Browser input reaches the server");
await server;
session.Disconnect();
Check(!session.InGame && !session.Connected && renderer.Frame is null, "Disconnect stops rendering and clears session");
Check(renderer.Start(), "Release renderer lease after disconnect");
var restartDeadline = DateTime.UtcNow.AddSeconds(10);
while (renderer.Frame is null && renderer.Failure is null && DateTime.UtcNow < restartDeadline) await Task.Delay(50);
Check(renderer.Failure is null && renderer.Frame is not null, "Restart FNA after returning to menu");
renderer.Stop();
var services = new ServiceCollection();
services.AddLogging();
services.AddSingleton<Microsoft.JSInterop.IJSRuntime, StaticRenderJsRuntime>();
services.AddSingleton<IConfiguration>(config);
services.AddScoped<BrowserFnaRenderer>();
services.AddScoped<BrowserGameSession>();
await using (var provider = services.BuildServiceProvider())
await using (var scope = provider.CreateAsyncScope())
await using (var html = new HtmlRenderer(scope.ServiceProvider, provider.GetRequiredService<ILoggerFactory>()))
{
    var markup = await html.Dispatcher.InvokeAsync(async () =>
        (await html.RenderComponentAsync<Client.Blazor.Components.Pages.Home>()).ToHtmlString());
    Check(markup.Contains("assets/frmMainMenu/logo.png") && markup.Contains(">Login</button>") && markup.Contains(">Register</button>"), "The root Blazor page opens the main menu");
    Check(!markup.Contains("<canvas"), "Do not render frmMirage before entering the world");
    var hudSession = scope.ServiceProvider.GetRequiredService<BrowserGameSession>();
    scope.ServiceProvider.GetRequiredService<BrowserFnaRenderer>().Graphics.GameplayState = new() {
        HP = 45, MaxHP = 100, MP = 30, MaxMP = 50, SP = 80, MaxSP = 100,
        Quests = new() { new() { Id = 1, Name = "Supplies", Status = "ready", Current = 1, Required = 1 } }
    };
    var vitals = await html.Dispatcher.InvokeAsync(async () =>
        (await html.RenderComponentAsync<Client.Blazor.Components.Forms.VitalBars>()).ToHtmlString());
    Check(vitals.Contains("aria-valuenow=\"45\"") && vitals.Contains("HP 45 / 100") && vitals.Contains("vital-fill"), "Vital HUD renders authoritative values with artwork fills");
    hudSession.HudTab = "quests";
    var quests = await html.Dispatcher.InvokeAsync(async () =>
        (await html.RenderComponentAsync<Client.Blazor.Components.Forms.InventorySpellHud>()).ToHtmlString());
    Check(quests.Contains("Supplies") && quests.Contains("Turn in quest") && quests.Contains("quest-blip ready"), "Quest HUD renders ready blips and turn-in controls");
    scope.ServiceProvider.GetRequiredService<BrowserFnaRenderer>().Graphics.GameplayState.CanEditMap=true;
    void EditorPacket(string kind,int id,object definition) => typeof(BrowserGameSession).GetMethod("HandlePacket",System.Reflection.BindingFlags.Instance|System.Reflection.BindingFlags.NonPublic)!
        .Invoke(hudSession,new object[] { new List<string> { "contentdefinition",kind,id.ToString(),JsonSerializer.Serialize(definition),JsonSerializer.Serialize(new[] { new XtremeWorlds.Networking.Content.ContentSummary { Id=id,Name="Fixture" } }) } });
    EditorPacket("item",1,new XtremeWorlds.Networking.Content.ItemContent { Name="Test sword",Type=0,Pic=3,AttackBonus=7 });
    var itemEditor=await html.Dispatcher.InvokeAsync(async()=>
        (await html.RenderComponentAsync<Client.Blazor.Components.Forms.ContentEditor>(Microsoft.AspNetCore.Components.ParameterView.FromDictionary(new Dictionary<string,object?> { ["Kind"]="item" }))).ToHtmlString());
    Check(itemEditor.Contains("Item editor") && itemEditor.Contains("Test sword") && itemEditor.Contains("Attack bonus") && itemEditor.Contains("Save item"),"Item editor renders its loaded draft, equipment fields, preview, and save control");
    EditorPacket("npc",2,new XtremeWorlds.Networking.Content.NpcContent { Name="Test NPC",Sprite=3,MaxHP=50,SpawnSecs=15 });
    var npcEditor=await html.Dispatcher.InvokeAsync(async()=>
        (await html.RenderComponentAsync<Client.Blazor.Components.Forms.ContentEditor>(Microsoft.AspNetCore.Components.ParameterView.FromDictionary(new Dictionary<string,object?> { ["Kind"]="npc" }))).ToHtmlString());
    Check(npcEditor.Contains("NPC editor") && npcEditor.Contains("Test NPC") && npcEditor.Contains("Drop chance") && npcEditor.Contains("Add saved NPC"),"NPC editor renders its draft, loot fields, and map placement control");
}
Console.WriteLine("Browser login, character selection, native FNA frames, input, renderer isolation, logout and restart passed.");

// HtmlRenderer omits browser lifecycle callbacks; unexpected JS calls should fail the test.
sealed class StaticRenderJsRuntime : Microsoft.JSInterop.IJSRuntime
{
    public ValueTask<TValue> InvokeAsync<TValue>(string identifier, object?[]? args) =>
        throw new InvalidOperationException("JavaScript cannot run during static rendering: " + identifier);
    public ValueTask<TValue> InvokeAsync<TValue>(string identifier, CancellationToken cancellationToken, object?[]? args) =>
        InvokeAsync<TValue>(identifier, args);
}
