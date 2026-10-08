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
    public string[] AvailableGraphics { get; private set; } = [];
    public void RequestGraphicsList()
    {
        if (!InGame || !network.IsConnected) throw new InvalidOperationException("Enter the world to browse graphics.");
        GraphicsError = null;
        network.SendText(PacketCodec.Build("gfxlist"));
    }
    public string? GraphicsError { get; private set; }
    public string? GraphicsSaved { get; private set; }
    public string? DownloadedGraphicsName { get; private set; }
    public byte[]? DownloadedGraphics { get; private set; }
    public void UploadGraphic(string name, byte[] png)
    {
        if (!InGame || !network.IsConnected) throw new InvalidOperationException("Enter the world before managing graphics.");
        if (png.Length > 4194304) throw new ArgumentException("PNG exceeds 4 MiB.");
        GraphicsSaved = GraphicsError = null;
        network.SendText(PacketCodec.Build("gfxput", name, Convert.ToBase64String(png)));
    }
    public void DownloadGraphic(string name)
    {
        if (!InGame || !network.IsConnected) throw new InvalidOperationException("Enter the world before managing graphics.");
        DownloadedGraphicsName = null;
        DownloadedGraphics = null;
        GraphicsError = null;
        network.SendText(PacketCodec.Build("gfxget", name));
    }
    public string ServerHost { get; private set; } = "127.0.0.1";
    public int ServerPort { get; private set; } = 7234;
    public void ConfigureServer(string host, int port)
    {
        if (string.IsNullOrWhiteSpace(host) || host.Length > 253 || host.Any(char.IsWhiteSpace))
            throw new ArgumentException("Enter a valid server IP or hostname.");
        if (port is < 1 or > 65535) throw new ArgumentException("Invalid port.");
        if (network.IsConnected || InGame) throw new InvalidOperationException("Disconnect before changing servers.");
        ServerHost = host.Trim();
        ServerPort = port;
        Changed?.Invoke();
    }
    public BrowserGameSession(IConfiguration configuration, BrowserFnaRenderer renderer)
    {
        this.configuration = configuration;
        ServerHost = configuration["GameServer:Host"] ?? "127.0.0.1";
        ServerPort = configuration.GetValue("GameServer:Port", 7234);
        this.renderer = renderer;
        connection = new GameClientConnection(renderer.Graphics);
        connection.PacketReceived += HandlePacket;
        connection.WorldSceneReceived += world =>
        {
            if (world.Map is { Tiles.Count: 192 })
            {
                if (!string.IsNullOrWhiteSpace(editedMapName) && world.Map is not null)
                    world.Map.Name = editedMapName;
                LatestWorld = world;
                MapLoaded = true;
                if (InGame) Changed?.Invoke();
            }
            else if (world.Map is null && LatestWorld is not null)
            {
                world.Map = LatestWorld.Map;
                LatestWorld = world;
            }
        };
        connection.WorldSceneTransform = ApplyEditorMap;
    }
    private string? editedMapName;
    public string CurrentMapName => editedMapName ?? LatestWorld?.Map?.Name ?? "Map";
    public FnaWorldScene? LatestWorld { get; private set; }
    public bool MapLoaded { get; private set; }
    public bool GameReady => InGame && MapLoaded;
    private EditorMapPatch? editorPatch;
    public void ApplyMapDraft(string json)
    {
        var patch = JsonSerializer.Deserialize<EditorMapPatch>(json) ?? throw new JsonException("Invalid map.");
        if (patch.Tiles is null || patch.Width != 16 || patch.Height != 12 || patch.Tiles.Count != 192)
            throw new ArgumentException("Current game world expects a 16 x 12 map.");
        editorPatch = patch;
        if (!string.IsNullOrWhiteSpace(patch.Name)) editedMapName = patch.Name.Trim();
        if (LatestWorld is { } world) renderer.World(ApplyEditorMap(world));
        Changed?.Invoke();
    }
    private FnaWorldScene ApplyEditorMap(FnaWorldScene scene)
    {
        if (editorPatch is not { } patch || scene.Map is not { } map || patch.Tiles is null || patch.Tiles.Count != map.Tiles.Count) return scene;
        if (!string.IsNullOrWhiteSpace(editedMapName)) map.Name = editedMapName;
        for (int i = 0; i < map.Tiles.Count; i++)
        {
            var t = map.Tiles[i]; var p = patch.Tiles[i];
            t.Ground=p.Ground; t.Mask=p.Mask; t.Fringe=p.Fringe; t.Type=p.Blocked?1:0;
            t.LayerTileset ??= new List<int>();
            while(t.LayerTileset.Count<9)t.LayerTileset.Add(Math.Max(1,map.Tileset));
            t.LayerTileset[0]=p.GroundTileset;
            t.LayerTileset[1]=p.MaskTileset;
            t.LayerTileset[5]=p.FringeTileset;
        }
        return scene;
    }
    public sealed class EditorMapPatch
    {
        public string Name { get; set; } = string.Empty;
        public int Width {get;set;}
        public int Height {get;set;}
        public List<EditorTilePatch>? Tiles {get;set;}
    }
    public sealed class EditorTilePatch
    {
        public int Ground {get;set;}
        public int Mask {get;set;}
        public int Fringe {get;set;}
        public int GroundTileset {get;set;}=1;
        public int MaskTileset {get;set;}=1;
        public int FringeTileset {get;set;}=1;
        public bool Blocked {get;set;}
    }
    public string Status { get; private set; } = "Disconnected";
    public string[] Characters { get; private set; } = [];
    public bool Connected => OfflineMode || network.IsConnected;
    public bool OfflineMode { get; private set; }
    public void StartOffline()
    {
        if (InGame) return;
        OfflineMode = true;
        var scene = new FnaWorldScene {
            MapId = 0,
            Map = new FnaSceneMap { Name = "Local World", Tileset = 1,
                Tiles = Enumerable.Range(0, 16 * 12).Select(_ => new FnaSceneTile()).ToList() },
            Player = new FnaScenePlayer { Name = "Adventurer", Sprite = 0, X = 8, Y = 6, Direction = 0 }
        };
        LatestWorld = scene;
        MapLoaded = true;
        InGame = renderer.Start();
        if (InGame) renderer.World(scene);
        Status = InGame ? "Offline world" : renderer.Failure ?? "Unable to start renderer.";
        Changed?.Invoke();
    }
    public bool InGame { get; private set; }
    public BrowserFnaRenderer Renderer => renderer;
    public event Action? Changed;

    public void Authenticate(string username, string password, bool register)
    {
        OfflineMode = false;
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
        if (!network.ConnectAndWait(ServerHost, ServerPort, TimeSpan.FromSeconds(3)))
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
        if (InGame && (renderer.Failure is not null || (!OfflineMode && !network.IsConnected)))
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
                case "gfxlist":
                    AvailableGraphics = fields.Count > 1 && !string.IsNullOrEmpty(fields[1])
                        ? fields[1].Split(',', StringSplitOptions.RemoveEmptyEntries) : [];
                    Changed?.Invoke();
                    break;
                case "gfxsaved":
                    GraphicsSaved = fields.Count > 1 ? fields[1] : "Graphic saved.";
                    Changed?.Invoke();
                    break;
                case "gfxerror":
                    GraphicsError = fields.Count > 1 ? fields[1] : "Graphic operation failed.";
                    Changed?.Invoke();
                    break;
                case "gfxdata":
                    if (fields.Count > 2)
                    {
                        try
                        {
                            DownloadedGraphics = Convert.FromBase64String(fields[2]);
                            DownloadedGraphicsName = fields[1];
                            Changed?.Invoke();
                        }
                        catch (FormatException) { GraphicsError = "Invalid graphic data received."; Changed?.Invoke(); }
                    }
                    break;
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
                    MapLoaded = false;
                    LatestWorld = null;
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
        OfflineMode = false;
        LatestWorld = null;
        MapLoaded = false;
        editedMapName = null;
        editorPatch = null;
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
