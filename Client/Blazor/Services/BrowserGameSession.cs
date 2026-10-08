using System.Text.Json;
using XtremeWorlds.Networking;
using XtremeWorlds.Client.Engine.Graphics;
using System.Text;
using XtremeWorlds.Client.Engine.Networking;

namespace Client.Blazor.Services;

// Each circuit owns its transport and leases the host's native FNA renderer.
public sealed class BrowserGameSession : IDisposable
{
    private readonly IConfiguration configuration;
    private readonly BrowserFnaRenderer renderer;
    private readonly GameClientConnection connection;
    private MirrorTcpClient network => connection.Transport;
    public BrowserGameSession(IConfiguration configuration, BrowserFnaRenderer renderer)
    {
        this.configuration = configuration;
        this.renderer = renderer;
        connection = new GameClientConnection(renderer.Graphics);
        connection.PacketReceived += HandlePacket;
    }
    public FnaWorldScene? LatestWorld { get; private set; }
    public string Status { get; private set; } = "Disconnected";
    public string[] Characters { get; private set; } = [];
    public bool Connected => network.IsConnected;
    public bool InGame { get; private set; }
    public BrowserFnaRenderer Renderer => renderer;
    public event Action? Changed;

    public void Authenticate(string username, string password, bool register)
    {
        if (string.IsNullOrWhiteSpace(username) || string.IsNullOrEmpty(password))
        {
            Status = "Enter a username and password.";
            return;
        }
        if (username.IndexOfAny(['\0', (char)237]) >= 0 || password.IndexOfAny(['\0', (char)237]) >= 0)
        {
            Status = "Credentials contain unsupported characters.";
            return;
        }
        if (!network.ConnectAndWait(configuration["GameServer:Host"] ?? "127.0.0.1",
            configuration.GetValue("GameServer:Port", 7234), TimeSpan.FromSeconds(3)))
        {
            Disconnect();
            Status = "Unable to connect to the game server.";
            return;
        }
        network.SendText(register
            ? PacketCodec.Build("newaccount", username.Trim(), password, string.Empty)
            : PacketCodec.Build("login", username.Trim(), password, 1, 0, 0, string.Empty));
        Status = "Waiting for the game server…";
    }

    public void Poll()
    {
        connection.Tick();
        renderer.Update();
        while (renderer.TryAction(out var action))
        {
            if (connection.HandleAction(action.Action, action.Args)) continue;
            switch (action.Action)
            {
                case "Logout": Disconnect(); break;
                case "SendChatChannel": network.SendText(PacketCodec.Build("saymsg", action.Args[1])); break;
                case "ShowOptions": Status = "Use your browser's zoom and display settings."; break;
                case "OpenWebsite": Status = "Website: https://www.xtremeworlds.com"; break;
            }
        }
        if (InGame && (renderer.Failure is not null || !Connected))
        {
            var error = renderer.Failure ?? "The game server disconnected.";
            Disconnect();
            Status = error;
        }
        else if (InGame && renderer.Frame is not null && Status == "Starting the game renderer...") Status = "Connected";
        if (!Connected && Status == "Waiting for the game server…") Status = "The game server disconnected.";
    }

    private void HandlePacket(IReadOnlyList<string> fields)
    {
            switch (fields[0].ToLowerInvariant())
            {
                case "worldstate":
                case "worldtick":
                    if (fields.Count > 1)
                    {
                        try { var world = JsonSerializer.Deserialize<FnaWorldScene>(fields[1]); if (world?.Map is not null) LatestWorld = world; }
                        catch (JsonException) { }
                    }
                    break;
            }
            switch (fields[0].ToLowerInvariant())
            {
                case "alertmsg":
                    Status = fields.Count > 1 ? fields[1] : "Server alert";
                    break;
                case "chars":
                    Characters = fields.Skip(1).ToArray();
                    Status = "Choose a character.";
                    break;
                case "allchars":
                    Characters = Enumerable.Range(0, 3).Select(slot =>
                        fields.Count > 1 + slot * 4 ? fields[1 + slot * 4] : string.Empty).ToArray();
                    Status = "Choose a character.";
                    break;
                case "ingame":
                    InGame = renderer.Start();
                    Status = InGame ? "Starting the game renderer..." : renderer.Failure ?? "Unable to start the renderer.";
                    if (!InGame) network.Disconnect();
                    Changed?.Invoke();
                    break;
                case "playerdata":
                    if (fields.Count >= 3 && int.TryParse(fields[2], out var level)) renderer.Character(fields[1], level);
                    break;
                case "saymsg":
                case "globalmsg":
                case "broadcastmsg":
                case "guildmsg":
                case "playermsg":
                    if (fields.Count > 1) renderer.Chat(fields[0], fields[1]);
                    break;
            }
    }

    public bool CreateCharacter(string name, int sex, int classId, int slot)
    {
        name = name.Trim();
        if (!Connected || slot < 0 || slot >= Characters.Length || !string.IsNullOrWhiteSpace(Characters[slot])) return false;
        if (name.Length < 3 || name.Length > 20 || name.Any(c => !char.IsLetterOrDigit(c) && c != '_' && c != ' '))
        {
            Status = "Use a character name with 3–20 letters, numbers, spaces or underscores.";
            return false;
        }
        network.SendText(PacketCodec.Build("addchar", name, sex, classId, slot + 1));
        Status = "Creating character...";
        return true;
    }
    public void DeleteCharacter(int slot)
    {
        if (!Connected || slot < 0 || slot >= Characters.Length || string.IsNullOrWhiteSpace(Characters[slot])) return;
        network.SendText(PacketCodec.Build("delchar", slot + 1));
        Status = "Deleting character...";
    }
    public void SelectCharacter(int slot)
    {
        if (!Connected || slot < 0 || slot >= Characters.Length || string.IsNullOrWhiteSpace(Characters[slot])) return;
        network.SendText(PacketCodec.Build("usechar", slot + 1));
        Status = "Entering the world…";
    }

    public void Disconnect()
    {
        InGame = false;
        LatestWorld = null;
        connection.Reset();
        renderer.Stop();
        network.Disconnect();
        while (network.TryDequeue(out _)) { }
        Characters = [];
        Status = "Disconnected";
        Changed?.Invoke();
    }

    public void Dispose() { renderer.Stop(); connection.Dispose(); }
}
