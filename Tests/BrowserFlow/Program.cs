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
        Check(ColoredPngPixel(frame.ToArray(), 100, 100), "WebSocket delivers visible native frames without Blazor draw calls");
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
    await WritePacket(stream, PacketCodec.Build("worldstate", JsonSerializer.Serialize(new FnaWorldScene {
        MapId = 1, ServerTick = 1, AckInputSequence = 0, NetworkEpoch = "browser-test", TickRate = 60,
        Map = new FnaSceneMap { Name = "Browser test map", Tileset = 1,
            Tiles = Enumerable.Range(0, 192).Select(_ => new FnaSceneTile { Ground = 1 }).ToList() },
        Player = new FnaScenePlayer { Name = "Hero", Sprite = 1, X = 1, Y = 1, Direction = 3 },
        Players = new() { new FnaScenePlayer { Name = "Hero", Sprite = 1, X = 1, Y = 1, Direction = 3 } }
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
await Task.Delay(250);
session.Poll();
Check(renderer.NetworkState.Latest?.Players["Hero"].X == 32, "Browser submits world state to the shared FNA pipeline");
var frame = renderer.Frame!;
Check(frame.Length > 1000 && frame[0] == 137 && frame[1] == 80, "FNA encodes PNG frames");
Check(ColoredPngPixel(frame, 100, 100), "Captured map contains textured pixels rather than a blank viewport");
Check(ColoredPngPixel(frame, 690, 200), "Captured HUD artwork is visible");
if (args.Length > 0) await File.WriteAllBytesAsync(args[0], frame);
using (var competing = new BrowserFnaRenderer()) Check(!competing.Start(), "Reject simultaneous native Game loops in one host");
await VerifyStream(renderer);
renderer.Key("h"); renderer.Key("i"); renderer.Key("Enter");
renderer.Movement("ArrowRight", true);
await Until(() => movedOnWire.Task.IsCompleted, "Browser movement reaches the server");
renderer.Movement("ArrowRight", false);
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
services.AddSingleton<IConfiguration>(config);
services.AddScoped<BrowserFnaRenderer>();
services.AddScoped<BrowserGameSession>();
await using (var provider = services.BuildServiceProvider())
await using (var scope = provider.CreateAsyncScope())
await using (var html = new HtmlRenderer(scope.ServiceProvider, provider.GetRequiredService<ILoggerFactory>()))
{
    var markup = await html.Dispatcher.InvokeAsync(async () =>
        (await html.RenderComponentAsync<Client.Blazor.Components.Pages.Home>()).ToHtmlString());
    Check(markup.Contains("assets/frmMainMenu/imgLogo.png") && markup.Contains("aria-label=\"Login\"") && markup.Contains("aria-label=\"Register\""), "The root Blazor page opens the main menu");
    Check(!markup.Contains("<canvas"), "Do not render frmMirage before entering the world");
}
Console.WriteLine("Browser login, character selection, native FNA frames, input, renderer isolation, logout and restart passed.");
