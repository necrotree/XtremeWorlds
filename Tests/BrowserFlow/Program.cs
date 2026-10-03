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
using var listener = new TcpListener(IPAddress.Loopback, 0);
listener.Start();
var port = ((IPEndPoint)listener.LocalEndpoint).Port;
var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
{
    ["GameServer:Host"] = "127.0.0.1", ["GameServer:Port"] = port.ToString()
}).Build();
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
    var chat = PacketCodec.Parse(await ReadPacket(stream));
    Check(chat[0] == "saymsg" && chat[1] == "hi", "Forward browser chat through the FNA input queue");
    await WritePacket(stream, PacketCodec.Build("saymsg", "Server reply"));
    await Task.Delay(1000);
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
await Until(() => session.InGame && renderer.Frame is not null, "Receive a native FNA frame after entering the world");
var frame = renderer.Frame!;
Check(frame.Length > 1000 && frame[0] == 137 && frame[1] == 80, "FNA encodes PNG frames");
if (args.Length > 0) await File.WriteAllBytesAsync(args[0], frame);
using (var competing = new BrowserFnaRenderer()) Check(!competing.Start(), "Reject simultaneous native Game loops in one host");
renderer.Key("h"); renderer.Key("i"); renderer.Key("Enter");
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
    Check(markup.Contains("assets/frmMainMenu/logo.png") && markup.Contains(">Login</button>") && markup.Contains(">Register</button>"), "The root Blazor page opens the main menu");
    Check(!markup.Contains("<canvas"), "Do not render frmMirage before entering the world");
}
Console.WriteLine("Browser login, character selection, native FNA frames, input, renderer isolation, logout and restart passed.");
