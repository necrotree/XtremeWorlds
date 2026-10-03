using System.Text;
using XtremeWorlds.Client.Engine.Networking;

namespace Client.Blazor.Services;

// Each browser circuit owns a transport without initializing desktop graphics/audio.
public sealed class BrowserGameSession(IConfiguration configuration) : IDisposable
{
    private readonly MirrorTcpClient network = new();
    public string Status { get; private set; } = "Disconnected";
    public string[] Characters { get; private set; } = [];
    public bool Connected => network.IsConnected;

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
        network.Tick();
        while (network.TryDequeue(out var packet))
        {
            var fields = PacketCodec.Parse(Encoding.UTF8.GetString(packet));
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
                    Status = "Character entered the world. Game rendering is currently available in the Windows client.";
                    break;
            }
        }
        if (!Connected && Status == "Waiting for the game server…") Status = "The game server disconnected.";
    }

    public void SelectCharacter(int slot)
    {
        if (!Connected || slot < 0 || slot >= Characters.Length || string.IsNullOrWhiteSpace(Characters[slot])) return;
        network.SendText(PacketCodec.Build("usechar", slot + 1));
        Status = "Entering the world…";
    }

    public void Disconnect()
    {
        network.Disconnect();
        Characters = [];
        Status = "Disconnected";
    }

    public void Dispose() => network.Dispose();
}
