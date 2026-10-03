using System.IO;
using System.Text.Json;

namespace Server
{

    public sealed class ServerSettings
    {
        public string GameName { get; set; } = "XtremeWorlds";
        public int Port { get; set; } = 7234;
        public int MaxPlayers { get; set; } = 100;
        public int MaxMessageSize { get; set; } = 1024 * 1024;
        public bool TcpNoDelay { get; set; } = true;
        public int TickRate { get; set; } = 60;
        public string Website { get; set; } = "https://example.com";
        public string SpacetimeUri { get; set; } = "http://127.0.0.1:3000";
        public string SpacetimeDatabase { get; set; } = "xtremeworlds";
        public string SpacetimeToken { get; set; } = "";
        public int SpacetimeConnectTimeoutSeconds { get; set; } = 3;
        public bool RequireSpacetimeDb { get; set; } = false;
        public bool ProbeSpacetimeOnStartup { get; set; } = false;

        public static ServerSettings Load(string path)
        {
            if (!File.Exists(path))
                return new ServerSettings();
            string json = File.ReadAllText(path);
            return JsonSerializer.Deserialize<ServerSettings>(json, new JsonSerializerOptions() { PropertyNameCaseInsensitive = true }) ?? new ServerSettings();
        }
    }
}