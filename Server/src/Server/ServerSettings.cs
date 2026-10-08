using System.IO;
using System.Text.Json;

namespace Server
{

    public sealed class ServerSettings
    {
        public string GameName { get; set; } = "XtremeWorlds";
        public int Port { get; set; } = 7234;
        public int MaxPlayers { get; set; } = 50;
        public int MaxMaps { get; set; } = 50;
        public int MaxItems { get; set; } = 255;
        public int MaxShops { get; set; } = 255;
        public int MaxSpells { get; set; } = 255;
        public int MaxSigns { get; set; } = 255;
        public int MaxNpcs { get; set; } = 255;
        public int MaxGuilds { get; set; } = 255;
        public int MaxGuildMembers { get; set; } = 255;
        public int MaxQuests { get; set; } = 255;
        public int MaxBooks { get; set; } = 255;
        public int MaxEmotes { get; set; } = 100;
        public int MaxArrows { get; set; } = 100;
        public int MaxClasses { get; set; } = 50;
        public int MaxQuestPlayers { get; set; } = 255;
        public int MaxMessageSize { get; set; } = 1024 * 1024;
        public bool TcpNoDelay { get; set; } = true;
        public int TickRate { get; set; } = 60;
        public string Website { get; set; } = "https://xtremeworlds.com";
        public string SpacetimeUri { get; set; } = "http://127.0.0.1:3000";
        public string SpacetimeDatabase { get; set; } = "xtremeworlds";
        public string SpacetimeToken { get; set; } = "";
        public string SpacetimeUsername { get; set; } = "";
        public string SpacetimePassword { get; set; } = "";
        public string SpacetimeCliPath { get; set; } = "";
        public string SpacetimeDotNetPath { get; set; } = "";
        public string SpacetimeModulePath { get; set; } = "spacetimedb";
        public bool AutoCreateSpacetimeDatabase { get; set; } = true;
        public int SpacetimeConnectTimeoutSeconds { get; set; } = 3;
        public bool RequireSpacetimeDb { get; set; } = false;
        public bool ProbeSpacetimeOnStartup { get; set; } = true;
        public bool AutoStartSpacetimeDb { get; set; } = true;
        public int SpacetimeStartupTimeoutSeconds { get; set; } = 15;

        public static ServerSettings Load(string path)
        {
            if (!File.Exists(path))
                return new ServerSettings();
            string json = File.ReadAllText(path);
            return JsonSerializer.Deserialize<ServerSettings>(json, new JsonSerializerOptions() { PropertyNameCaseInsensitive = true }) ?? new ServerSettings();
        }
    }
}