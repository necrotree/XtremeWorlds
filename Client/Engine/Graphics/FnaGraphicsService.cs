using System.Buffers;
using System.Diagnostics;
using System.Runtime.InteropServices;
using XtremeWorlds.Networking;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using XtremeWorlds.Client.Engine.Runtime;

namespace XtremeWorlds.Client.Engine.Graphics;

public readonly record struct FnaSpriteCommand(
    string TexturePath,
    Rectangle Destination,
    Rectangle? Source,
    Color Tint,
    float LayerDepth = 0f);

public enum FnaWorldLayer
{
    MapGround,
    MapMask,
    MapItem,
    Npc,
    Player,
    Projectile,
    Animation,
    Fringe,
    Name
}

public readonly record struct FnaWorldCommand(
    FnaWorldLayer Layer,
    string TexturePath,
    Rectangle Destination,
    Rectangle? Source,
    Color Tint);

public readonly record struct FnaWorldTextCommand(
    string Text,
    int X,
    int Y,
    Color Color);

public enum FnaVital
{
    HP,
    MP,
    SP,
    XP
}

/// <summary>
/// FNA renderer for the current XtremeWorlds client.
///
/// The main game window, HUD, side panels, character stats, gauges and chat are rendered by FNA.
/// Eto remains available for standalone forms such as frmOptions and editors.
/// The logical UI remains the original 950x700 twinBASIC layout and is scaled
/// uniformly when the FNA window is resized.
/// </summary>
public sealed class FnaGraphicsService : IDisposable
{
    private readonly ConcurrentQueue<FnaWorldScene> _scenes = new();
    private readonly ConcurrentQueue<(int MapId, string? Json)> _editorMapChanges = new();
    private volatile bool _mapEditorActive;
    public bool MapEditorActive
    {
        get => _mapEditorActive;
        set => _mapEditorActive = value;
    }
    public void SetMapEditorPreview(int mapId, string? json) => _editorMapChanges.Enqueue((mapId, json));
    public ClientTickSynchronizer NetworkState { get; } = new();
    private FnaSceneMap? _networkMap;
    private int _networkMapId = -1;
    public bool SetWorldScene(FnaWorldScene scene)
    {
        if (scene.NetworkEpoch == null || scene.Player == null || scene.Players == null
            || scene.Players.Any(p => p == null || p.Name == null) || scene.Player.Name == null
            || (scene.Map != null && scene.Map.Tiles == null))
            throw new System.Text.Json.JsonException("Incomplete network scene.");
        if (scene.NetworkEpoch.Length == 0) { _scenes.Enqueue(scene); return true; }
        var poses = scene.Players.Append(scene.Player).Where(p => p.Name.Length > 0)
            .GroupBy(p => p.Name).ToDictionary(g => g.Key, g => {
                var p = g.Last();
                return new MovementState(scene.MapId, p.PixelX ?? p.X * 32.0, p.PixelY ?? p.Y * 32.0, p.Direction);
            });
        if (scene.NetworkEpoch.Length > 64 || scene.ServerTick < 0 || scene.AckInputSequence < 0
            || scene.TickRate is < 1 or > 240 || scene.Player.Name.Length == 0 || poses.Any(p => !p.Value.IsValid))
            throw new System.Text.Json.JsonException("Invalid tick snapshot.");
        if (!NetworkState.Receive(new(scene.NetworkEpoch, scene.ServerTick, scene.AckInputSequence, scene.TickRate,
            scene.Player.Name, poses, scene.NetworkFrozen), NetworkClock.Seconds))
        {
            var latest = NetworkState.Latest;
            // A map editor save can replace tiles without changing movement tick/sequence.
            if (scene.Map == null || latest == null || latest.Epoch != scene.NetworkEpoch
                || latest.Tick != scene.ServerTick || latest.AckSequence != scene.AckInputSequence
                || poses.Any(p => !p.Value.IsValid)) return false;
        }
        if (scene.Map != null) { RequestStreamKeyframe(); _networkMap = scene.Map; _networkMapId = scene.MapId; }
        else if (_networkMapId == scene.MapId) scene.Map = _networkMap;
        var collisionMap = scene.Map;
        NetworkState.CanMove = moved => collisionMap?.Tiles.ElementAtOrDefault((int)(moved.Y / 32) * 16 + (int)(moved.X / 32))?.Type != 1;
        _scenes.Enqueue(scene);
        while (_scenes.Count > 64) _scenes.TryDequeue(out _);
        return true;
    }
    public void ResetNetworkState()
    {
        NetworkState.Reset(); _networkMap = null; _networkMapId = -1;
        while (_scenes.TryDequeue(out _)) { }
    }
    private readonly ConcurrentQueue<(int X, int Y)> _browserClicks = new();
    private readonly ConcurrentQueue<string> _browserKeys = new();
    private readonly ConcurrentQueue<(string Key, bool Down)> _browserMovement = new();
    public void BrowserClick(int x, int y) => _browserClicks.Enqueue((x, y));
    public void BrowserKey(string key) => _browserKeys.Enqueue(key);
    public void BrowserMovement(string key, bool down) => _browserMovement.Enqueue((key, down));
    public void RequestStreamKeyframe() => _game?.RequestStreamKeyframe();
    public double StreamEncodeMilliseconds => _game?.StreamEncodeMilliseconds ?? 0;
    public const int StreamFrameRate = 60;
    public const int InterfaceWidth = 950;
    public const int InterfaceHeight = 700;
    private readonly ConcurrentQueue<FnaSpriteCommand> _commands = new();
    private readonly ConcurrentQueue<FnaWorldCommand> _worldCommands = new();
    private readonly ConcurrentQueue<FnaWorldTextCommand> _worldTextCommands = new();
    private readonly ConcurrentQueue<(string Channel, string Text)> _chat = new();
    private Thread? _thread;
    private FnaClientGame? _game;
    private volatile bool _stopRequested;

    public event EventHandler? Closed;
    public event EventHandler<Exception>? Failed;

    /// <summary>
    /// Raised on the FNA render thread when the HUD needs the client runtime to
    /// perform an action such as opening frmOptions, opening the website,
    /// logging out or sending chat.
    /// </summary>
    public event Action<string, object[]>? MainGameActionRequested;

    public bool IsRunning => _thread is { IsAlive: true };

    public void Start(int width = InterfaceWidth, int height = InterfaceHeight, Action<byte[]>? frameReady = null)
    {
        if (IsRunning) return;
        _stopRequested = false;
        _thread = new Thread(() =>
        {
            var failed = false;
            try
            {
                using var game = new FnaClientGame(
                    _scenes,
                    _editorMapChanges,
                    () => _mapEditorActive,
                    NetworkState,
                    _commands,
                    _worldCommands,
                    _worldTextCommands,
                    _chat,
                    width,
                    height,
                    () => _stopRequested,
                    RaiseMainGameAction, frameReady, _browserClicks, _browserKeys, _browserMovement);
                _game = game;
                game.Run();
            }
            catch (Exception error)
            {
                failed = true;
                Failed?.Invoke(this, error);
            }
            finally
            {
                _game = null;
                if (!failed && !_stopRequested) Closed?.Invoke(this, EventArgs.Empty);
            }
        })
        {
            IsBackground = true,
            Name = "FNA Render Thread"
        };
        _thread.Start();
    }

    public void Submit(FnaSpriteCommand command) => _commands.Enqueue(command);

    public void SubmitWorld(FnaWorldCommand command) => _worldCommands.Enqueue(command);
    public void SubmitWorldText(FnaWorldTextCommand command) => _worldTextCommands.Enqueue(command);
    public void BltMap(string texturePath, Rectangle destination, Rectangle? source = null) => SubmitWorld(new(FnaWorldLayer.MapGround, texturePath, destination, source, Color.White));
    public void BltMask(string texturePath, Rectangle destination, Rectangle? source = null) => SubmitWorld(new(FnaWorldLayer.MapMask, texturePath, destination, source, Color.White));
    public void BltMapItem(string texturePath, Rectangle destination, Rectangle? source = null) => SubmitWorld(new(FnaWorldLayer.MapItem, texturePath, destination, source, Color.White));
    public void BltNpc(string texturePath, Rectangle destination, Rectangle? source = null) => SubmitWorld(new(FnaWorldLayer.Npc, texturePath, destination, source, Color.White));
    public void BltPlayer(string texturePath, Rectangle destination, Rectangle? source = null) => SubmitWorld(new(FnaWorldLayer.Player, texturePath, destination, source, Color.White));
    public void BltProjectile(string texturePath, Rectangle destination, Rectangle? source = null) => SubmitWorld(new(FnaWorldLayer.Projectile, texturePath, destination, source, Color.White));
    public void BltAnimation(string texturePath, Rectangle destination, Rectangle? source = null) => SubmitWorld(new(FnaWorldLayer.Animation, texturePath, destination, source, Color.White));
    public void BltFringe(string texturePath, Rectangle destination, Rectangle? source = null) => SubmitWorld(new(FnaWorldLayer.Fringe, texturePath, destination, source, Color.White));
    public void BltPlayerName(string text, int x, int y, Color? color = null) => SubmitWorldText(new(text, x, y, color ?? Color.White));
    public void BltNpcName(string text, int x, int y, Color? color = null) => SubmitWorldText(new(text, x, y, color ?? Color.White));
    public void BltWorldText(string text, int x, int y, Color? color = null) => SubmitWorldText(new(text, x, y, color ?? Color.White));

    public void AddChatMessage(string channel, string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return;
        _chat.Enqueue((channel ?? string.Empty, text));
    }

    public void SetVital(FnaVital vital, int current, int maximum)
    {
        _game?.SetVital(vital, current, maximum);
    }

    public void SetCharacterState(string className, int level, string guildName, int points,
        int hp, int maxHp, int mp, int maxMp, int sp, int maxSp, int exp, int nextExp,
        int strength, int defense, int speed, int magic)
    {
        _game?.SetCharacterState(className, level, guildName, points, hp, maxHp, mp, maxMp, sp, maxSp,
            exp, nextExp, strength, defense, speed, magic);
    }

    public void SetCharacterStats(int strength, int defense, int speed, int magic)
    {
        _game?.SetCharacterStats(strength, defense, speed, magic);
    }

    private void RaiseMainGameAction(string actionName, params object[] arguments)
    {
        MainGameActionRequested?.Invoke(actionName, arguments);
    }

    public void Stop()
    {
        _stopRequested = true;
        if (_thread is { IsAlive: true } && Thread.CurrentThread != _thread)
            _thread.Join();
        if (_thread is not { IsAlive: true }) _thread = null;
        while (_browserClicks.TryDequeue(out _)) { }
        while (_browserKeys.TryDequeue(out _)) { }
        while (_browserMovement.TryDequeue(out _)) { }
    }

    public void Dispose() => Stop();

    private enum MainGamePanel
    {
        None,
        Character,
        Inventory,
        Guild,
        Skills
    }

    private enum ChatChannel
    {
        Map,
        Global,
        Guild,
        PM
    }

    private readonly record struct MainGamePanelInfo(string AssetName, Rectangle Destination);

    private sealed class FnaClientGame : Game
    {
        private const int LogicalWidth = 950;
        private const int LogicalHeight = 700;
        private static readonly Rectangle GameViewport = new(18, 18, 640, 480);

        // Current Core/Forms/frmMainGame.cs coordinates, generated from the
        // twinBASIC frmMirage/frmMainGame layout.
        private static readonly Rectangle StatsButton = new(687, 179, 42, 42);
        private static readonly Rectangle InventoryButton = new(735, 179, 42, 42);
        private static readonly Rectangle GuildButton = new(781, 179, 42, 42);
        private static readonly Rectangle SkillsButton = new(827, 179, 42, 42);
        private static readonly Rectangle OptionsButton = new(875, 179, 42, 42);
        private static readonly Rectangle WebsiteButton = new(678, 650, 121, 44);
        private static readonly Rectangle LogoutButton = new(799, 650, 121, 44);

        private static readonly Rectangle ChatHistoryRect = new(18, 522, 640, 130);
        private static readonly Rectangle ChatInputRect = new(18, 658, 640, 24);
        private static readonly Rectangle MapChannelButton = new(455, 509, 49, 14);
        private static readonly Rectangle GlobalChannelButton = new(507, 509, 48, 14);
        private static readonly Rectangle GuildChannelButton = new(558, 509, 48, 14);
        private static readonly Rectangle PmChannelButton = new(608, 508, 48, 14);

        private static readonly Rectangle HpGaugeRect = new(696, 39, 211, 12);
        private static readonly Rectangle MpGaugeRect = new(696, 56, 211, 12);
        private static readonly Rectangle XpGaugeRect = new(696, 73, 211, 12);
        private static readonly Rectangle SpGaugeRect = new(696, 90, 211, 12);

        // Character-panel stat training. These sit beside the four trainable
        // stats and use a Rockwell-rendered texture generated by the patcher.
        private static readonly Rectangle TrainStrengthButton = new(814, 451, 14, 14);
        private static readonly Rectangle TrainDefenseButton = new(814, 471, 14, 14);
        private static readonly Rectangle TrainSpeedButton = new(814, 511, 14, 14);
        private static readonly Rectangle TrainMagicButton = new(814, 531, 14, 14);

        // Inventory artwork is a 5x7 grid. Slots are 38x38 with a 45px stride.
        private static readonly Rectangle InventorySlotArea = new(696, 305, 218, 308);
        private static readonly Rectangle[] SkillSlots =
        {
            new(698, 305, 105, 34),
            new(698, 344, 105, 34),
            new(698, 383, 105, 34),
            new(698, 422, 105, 34),
            new(698, 461, 105, 34),
            new(698, 500, 105, 34),
            new(698, 539, 105, 34),
            new(698, 578, 105, 34)
        };

        private static readonly IReadOnlyDictionary<MainGamePanel, MainGamePanelInfo> PanelInfo =
            new Dictionary<MainGamePanel, MainGamePanelInfo>
            {
                [MainGamePanel.Character] = new("character.jpg", new Rectangle(679, 281, 265, 354)),
                [MainGamePanel.Inventory] = new("Inventory.jpg", new Rectangle(673, 277, 265, 354)),
                [MainGamePanel.Guild] = new("guild.jpg", new Rectangle(679, 281, 265, 354)),
                [MainGamePanel.Skills] = new("skills.jpg", new Rectangle(677, 278, 265, 354))
            };

        private readonly GraphicsDeviceManager _graphics;
        private readonly ConcurrentQueue<FnaSpriteCommand> _incoming;
        private readonly ConcurrentQueue<FnaWorldCommand> _worldIncoming;
        private readonly ConcurrentQueue<FnaWorldTextCommand> _worldTextIncoming;
        private readonly ConcurrentQueue<(string Channel, string Text)> _chatIncoming;
        private readonly List<FnaSpriteCommand> _frame = new();
        private readonly List<FnaWorldCommand> _worldFrame = new();
        private readonly List<FnaWorldTextCommand> _worldTextFrame = new();
        private readonly List<(ChatChannel Channel, string Text)> _chatHistory = new();
        private readonly Dictionary<ChatChannel, bool> _visibleChannels = new();
        private readonly Dictionary<string, Texture2D> _textures = new(StringComparer.OrdinalIgnoreCase);
        private readonly Dictionary<FnaVital, (int Current, int Maximum)> _vitals = new();
        private readonly object _vitalsLock = new();
        private readonly object _characterLock = new();
        private string _characterClass = "Unknown";
        private int _characterLevel;
        private string _characterGuild = "None";
        private int _characterPoints;
        private int _strength;
        private int _defense;
        private int _speed;
        private int _magic;
        private readonly Func<bool> _shouldStop;
        private readonly Action<string, object[]> _action;

        private SpriteBatch? _spriteBatch;
        private Texture2D? _pixel;
        private volatile bool _exitRequested;
        private MouseState _previousMouse;
        private KeyboardState _previousKeyboard;
        private MainGamePanel _activePanel;
        private string _chatInput = string.Empty;
        private double _nextMove;

        private readonly ConcurrentQueue<FnaWorldScene> _scenes;
        private readonly ConcurrentQueue<(int MapId, string? Json)> _editorMapChanges;
        private readonly Func<bool> _mapEditorActive;
        private FnaSceneMap? _editorMapPreview;
        private int _editorMapId = -1;
        private int _lastEditedX = -1, _lastEditedY = -1;
        private bool _lastEditedErase;
        private FnaWorldScene? _scene;
        private double _renderSeconds;

        private readonly ClientTickSynchronizer _networkState;
        private readonly Action<byte[]>? _frameReady;
        private readonly LatestPngEncoder? _frameEncoder;
        private readonly RasterizerState _worldRasterizer = new() { ScissorTestEnable = true };
        private readonly ConcurrentQueue<(int X, int Y)> _browserClicks;
        private readonly ConcurrentQueue<string> _browserKeys;
        private readonly ConcurrentQueue<(string Key, bool Down)> _browserMovement;
        private readonly HashSet<string> _heldBrowserKeys = new();
        private RenderTarget2D? _captureTarget;
        private TimeSpan _lastCapture;
        private bool _streamWindowHidden;
        [DllImport("SDL3", CallingConvention = CallingConvention.Cdecl)]
        [return: MarshalAs(UnmanagedType.I1)]
        private static extern bool SDL_HideWindow(IntPtr window);

        public FnaClientGame(
            ConcurrentQueue<FnaWorldScene> scenes,
            ConcurrentQueue<(int MapId, string? Json)> editorMapChanges,
            Func<bool> mapEditorActive,
            ClientTickSynchronizer networkState,
            ConcurrentQueue<FnaSpriteCommand> incoming,
            ConcurrentQueue<FnaWorldCommand> worldIncoming,
            ConcurrentQueue<FnaWorldTextCommand> worldTextIncoming,
            ConcurrentQueue<(string Channel, string Text)> chatIncoming,
            int width,
            int height,
            Func<bool> shouldStop,
            Action<string, object[]> action,
            Action<byte[]>? frameReady,
            ConcurrentQueue<(int X, int Y)> browserClicks,
            ConcurrentQueue<string> browserKeys,
            ConcurrentQueue<(string Key, bool Down)> browserMovement)
        {
            _scenes = scenes;
            _editorMapChanges = editorMapChanges;
            _mapEditorActive = mapEditorActive;
            _networkState = networkState;
            _shouldStop = shouldStop;
            _action = action;
            _frameReady = frameReady;
            if (frameReady != null) _frameEncoder = new LatestPngEncoder(LogicalWidth, LogicalHeight, frameReady);
            _browserClicks = browserClicks;
            _browserKeys = browserKeys;
            _browserMovement = browserMovement;
            _incoming = incoming;
            _worldIncoming = worldIncoming;
            _worldTextIncoming = worldTextIncoming;
            _chatIncoming = chatIncoming;

            foreach (ChatChannel channel in Enum.GetValues(typeof(ChatChannel)))
                _visibleChannels[channel] = true;

            _graphics = new GraphicsDeviceManager(this)
            {
                PreferredBackBufferWidth = Math.Max(width, 640),
                PreferredBackBufferHeight = Math.Max(height, 480),
                SynchronizeWithVerticalRetrace = true
            };

            IsFixedTimeStep = true;
            TargetElapsedTime = TimeSpan.FromMilliseconds(15);
            Window.Title = "XtremeWorlds";
            Window.AllowUserResizing = true;
            IsMouseVisible = true;
            if (frameReady != null)
            {
                Window.AllowUserResizing = false;
                InactiveSleepTime = TimeSpan.Zero;
            }
        }

        public void RequestStreamKeyframe() => _frameEncoder?.RequestKeyframe();
        public double StreamEncodeMilliseconds => _frameEncoder?.LastEncodeMilliseconds ?? 0;
        public void RequestExit() => _exitRequested = true;

        public void SetVital(FnaVital vital, int current, int maximum)
        {
            lock (_vitalsLock)
                _vitals[vital] = (Math.Max(0, current), Math.Max(0, maximum));
        }

        public void SetCharacterState(string className, int level, string guildName, int points,
            int hp, int maxHp, int mp, int maxMp, int sp, int maxSp, int exp, int nextExp,
            int strength, int defense, int speed, int magic)
        {
            lock (_characterLock)
            {
                _characterClass = string.IsNullOrWhiteSpace(className) ? "Unknown" : className.Trim();
                _characterLevel = Math.Max(0, level);
                _characterGuild = string.IsNullOrWhiteSpace(guildName) ? "None" : guildName.Trim();
                _characterPoints = Math.Max(0, points);
                _strength = Math.Max(0, strength);
                _defense = Math.Max(0, defense);
                _speed = Math.Max(0, speed);
                _magic = Math.Max(0, magic);
            }

            SetVital(FnaVital.HP, hp, maxHp);
            SetVital(FnaVital.MP, mp, maxMp);
            SetVital(FnaVital.SP, sp, maxSp);
            SetVital(FnaVital.XP, exp, nextExp);
        }

        public void SetCharacterStats(int strength, int defense, int speed, int magic)
        {
            lock (_characterLock)
            {
                _strength = Math.Max(0, strength);
                _defense = Math.Max(0, defense);
                _speed = Math.Max(0, speed);
                _magic = Math.Max(0, magic);
            }
        }

        protected override void Initialize()
        {
            base.Initialize();
            _previousMouse = Mouse.GetState();
            _previousKeyboard = Keyboard.GetState();
        }

        protected override void UnloadContent()
        {
            _captureTarget?.Dispose();
            _captureTarget = null;
            base.UnloadContent();
        }

        protected override void LoadContent()
        {
            _spriteBatch = new SpriteBatch(GraphicsDevice);
            _pixel = new Texture2D(GraphicsDevice, 1, 1);
            _pixel.SetData(new[] { Color.White });
            base.LoadContent();
        }

        protected override void Update(GameTime gameTime)
        {
            if (_frameReady != null && !_streamWindowHidden)
            {
                if (!SDL_HideWindow(Window.Handle)) throw new InvalidOperationException("Unable to hide the streaming window.");
                _streamWindowHidden = true;
            }
            if (_exitRequested || _shouldStop())
            {
                Exit();
                return;
            }

            while (_scenes.TryDequeue(out var scene)) _scene = scene;
            while (_editorMapChanges.TryDequeue(out var change))
            {
                if (string.IsNullOrEmpty(change.Json))
                {
                    _editorMapPreview = null;
                    _editorMapId = -1;
                    continue;
                }
                try
                {
                    _editorMapPreview = System.Text.Json.JsonSerializer.Deserialize<FnaSceneMap>(change.Json);
                    _editorMapId = change.MapId;
                }
                catch (System.Text.Json.JsonException)
                {
                    _editorMapPreview = null;
                    _editorMapId = -1;
                }
            }
            if (_scene != null)
            {
                var poses = _networkState.Sample(NetworkClock.Seconds);
                foreach (var actor in _scene.Players.Append(_scene.Player))
                    if (poses.TryGetValue(actor.Name, out var pose))
                    {
                        actor.PixelX = pose.X; actor.PixelY = pose.Y;
                        actor.X = (int)(pose.X / 32); actor.Y = (int)(pose.Y / 32); actor.Direction = pose.Direction;
                    }
            }

            if (_incoming.TryDequeue(out var command))
            {
                _frame.Clear();
                _frame.Add(command);
                while (_incoming.TryDequeue(out command)) _frame.Add(command);
            }

            if (_worldIncoming.TryDequeue(out var worldCommand))
            {
                _worldFrame.Clear();
                _worldFrame.Add(worldCommand);
                while (_worldIncoming.TryDequeue(out worldCommand)) _worldFrame.Add(worldCommand);
            }

            if (_worldTextIncoming.TryDequeue(out var worldText))
            {
                _worldTextFrame.Clear();
                _worldTextFrame.Add(worldText);
                while (_worldTextIncoming.TryDequeue(out worldText)) _worldTextFrame.Add(worldText);
            }

            while (_chatIncoming.TryDequeue(out var line))
                AddChatLine(ParseChannel(line.Channel), line.Text);

            _renderSeconds = gameTime.TotalGameTime.TotalSeconds;
            while (_browserClicks.TryDequeue(out var click)) HandleLogicalClick(click.X, click.Y);
            while (_browserKeys.TryDequeue(out var key))
            {
                if (key == "Enter") SendChat();
                else if (key == "Escape")
                {
                    if (_activePanel != MainGamePanel.None) _activePanel = MainGamePanel.None;
                    else _action("Logout", Array.Empty<object>());
                }
                else if (key == "Backspace") { if (_chatInput.Length > 0) _chatInput = _chatInput[..^1]; }
                else if (key.Length == 1 && _chatInput.Length < 96) _chatInput += key;
            }
            while (_browserMovement.TryDequeue(out var input))
            {
                if (input.Down) _heldBrowserKeys.Add(input.Key);
                else _heldBrowserKeys.Remove(input.Key);
            }
            if (_frameReady != null && _scene?.Map != null && gameTime.TotalGameTime.TotalSeconds >= _nextMove)
            {
                int direction = _heldBrowserKeys.Contains("ArrowUp") ? 0 : _heldBrowserKeys.Contains("ArrowDown") ? 1
                    : _heldBrowserKeys.Contains("ArrowLeft") ? 2 : _heldBrowserKeys.Contains("ArrowRight") ? 3 : -1;
                if (direction >= 0) { _nextMove = gameTime.TotalGameTime.TotalSeconds + .03; _action("MovePlayer", new object[] { direction }); }
            }
            if (IsActive && _frameReady == null)
            {
                HandleMouse();
                HandleKeyboard();
                var keys = Keyboard.GetState();
                int direction = keys.IsKeyDown(Keys.Up) ? 0 : keys.IsKeyDown(Keys.Down) ? 1
                    : keys.IsKeyDown(Keys.Left) ? 2 : keys.IsKeyDown(Keys.Right) ? 3 : -1;
                if (!_mapEditorActive() && _scene?.Map != null && direction >= 0 && gameTime.TotalGameTime.TotalSeconds >= _nextMove)
                {
                    _nextMove = gameTime.TotalGameTime.TotalSeconds + 0.03;
                    _action("MovePlayer", new object[] { direction });
                }
            }

            base.Update(gameTime);
        }

        private void HandleMouse()
        {
            var mouse = Mouse.GetState();
            var leftPressed = mouse.LeftButton == ButtonState.Pressed &&
                              _previousMouse.LeftButton == ButtonState.Released;
            var rightPressed = mouse.RightButton == ButtonState.Pressed &&
                               _previousMouse.RightButton == ButtonState.Released;
            if (_mapEditorActive())
            {
                bool painting = mouse.LeftButton == ButtonState.Pressed;
                bool erasing = mouse.RightButton == ButtonState.Pressed;
                if ((painting || erasing) && TryScreenToLogical(mouse.X, mouse.Y, out var editX, out var editY)
                    && GameViewport.Contains(editX, editY))
                {
                    int tileX = (editX - GameViewport.X) / 32;
                    int tileY = (editY - GameViewport.Y) / 32;
                    bool erase = erasing;
                    if (tileX is >= 0 and < 16 && tileY is >= 0 and < 12 &&
                        (tileX != _lastEditedX || tileY != _lastEditedY || erase != _lastEditedErase))
                    {
                        _lastEditedX = tileX;
                        _lastEditedY = tileY;
                        _lastEditedErase = erase;
                        _action("PaintMapTile", new object[] { tileX, tileY, erase });
                    }
                }
                else
                {
                    _lastEditedX = -1;
                    _lastEditedY = -1;
                }
                _previousMouse = mouse;
                return;
            }
            _lastEditedX = -1;
            _lastEditedY = -1;
            var keyboard = Keyboard.GetState();
            if (rightPressed && (keyboard.IsKeyDown(Keys.LeftShift) || keyboard.IsKeyDown(Keys.RightShift)) &&
                _scene?.Map is not null && TryScreenToLogical(mouse.X, mouse.Y, out var mapX, out var mapY) &&
                GameViewport.Contains(mapX, mapY))
            {
                int tileX = (mapX - GameViewport.X) / 32;
                int tileY = (mapY - GameViewport.Y) / 32;
                if (tileX < 16 && tileY < 12)
                    _action("WarpToTile", new object[] { tileX, tileY });
            }

            if (rightPressed && TryScreenToLogical(mouse.X, mouse.Y, out var rightX, out var rightY) &&
                _activePanel == MainGamePanel.Skills &&
                TryGetSkillSlot(rightX, rightY, out var forgetSkillSlot))
            {
                _action("ForgetSpell", new object[] { forgetSkillSlot });
            }

            if (leftPressed && TryScreenToLogical(mouse.X, mouse.Y, out var x, out var y))
            {
                HandleLogicalClick(x, y);
            }

            _previousMouse = mouse;
        }

        private void HandleLogicalClick(int x, int y)
        {
                if (StatsButton.Contains(x, y)) TogglePanel(MainGamePanel.Character);
                else if (InventoryButton.Contains(x, y)) TogglePanel(MainGamePanel.Inventory);
                else if (GuildButton.Contains(x, y)) TogglePanel(MainGamePanel.Guild);
                else if (SkillsButton.Contains(x, y)) TogglePanel(MainGamePanel.Skills);
                else if (OptionsButton.Contains(x, y)) _action("ShowOptions", Array.Empty<object>());
                else if (WebsiteButton.Contains(x, y)) _action("OpenWebsite", Array.Empty<object>());
                else if (LogoutButton.Contains(x, y)) _action("Logout", Array.Empty<object>());
                else if (_activePanel == MainGamePanel.Inventory && TryGetInventorySlot(x, y, out var inventorySlot))
                    _action("UseInventoryItem", new object[] { inventorySlot });
                else if (_activePanel == MainGamePanel.Skills && TryGetSkillSlot(x, y, out var skillSlot))
                    _action("CastSpell", new object[] { skillSlot });
                else if (_activePanel == MainGamePanel.Character && CanTrain() && TrainStrengthButton.Contains(x, y)) _action("TrainStat", new object[] { 0 });
                else if (_activePanel == MainGamePanel.Character && CanTrain() && TrainDefenseButton.Contains(x, y)) _action("TrainStat", new object[] { 1 });
                else if (_activePanel == MainGamePanel.Character && CanTrain() && TrainMagicButton.Contains(x, y)) _action("TrainStat", new object[] { 2 });
                else if (_activePanel == MainGamePanel.Character && CanTrain() && TrainSpeedButton.Contains(x, y)) _action("TrainStat", new object[] { 3 });
                else if (MapChannelButton.Contains(x, y)) ToggleChatChannel(ChatChannel.Map);
                else if (GlobalChannelButton.Contains(x, y)) ToggleChatChannel(ChatChannel.Global);
                else if (GuildChannelButton.Contains(x, y)) ToggleChatChannel(ChatChannel.Guild);
                else if (PmChannelButton.Contains(x, y)) ToggleChatChannel(ChatChannel.PM);
        }

        private static bool TryGetInventorySlot(int x, int y, out int slot)
        {
            slot = -1;
            // Actual visible slot rectangles in Inventory.jpg.
            const int firstX = 696;
            const int firstY = 305;
            const int stride = 45;
            const int size = 38;
            for (var row = 0; row < 7; row++)
            {
                for (var col = 0; col < 5; col++)
                {
                    var rect = new Rectangle(firstX + col * stride, firstY + row * stride, size, size);
                    if (!rect.Contains(x, y)) continue;
                    slot = row * 5 + col;
                    return true;
                }
            }
            return false;
        }

        private static bool TryGetSkillSlot(int x, int y, out int slot)
        {
            for (var i = 0; i < SkillSlots.Length; i++)
            {
                if (!SkillSlots[i].Contains(x, y)) continue;
                slot = i;
                return true;
            }
            slot = -1;
            return false;
        }

        private void HandleKeyboard()
        {
            var keyboard = Keyboard.GetState();
            var pressed = keyboard.GetPressedKeys();
            var shift = keyboard.IsKeyDown(Keys.LeftShift) || keyboard.IsKeyDown(Keys.RightShift);

            foreach (var key in pressed)
            {
                if (_previousKeyboard.IsKeyDown(key)) continue;

                if (key == Keys.F2)
                {
                    _action("ShowAdminPanel", Array.Empty<object>());
                    continue;
                }

                if (key == Keys.Escape)
                {
                    if (_activePanel != MainGamePanel.None)
                        _activePanel = MainGamePanel.None;
                    else
                        _action("Logout", Array.Empty<object>());
                    continue;
                }

                if (key == Keys.Enter)
                {
                    SendChat();
                    continue;
                }

                if (key == Keys.Back)
                {
                    if (_chatInput.Length > 0)
                        _chatInput = _chatInput[..^1];
                    continue;
                }

                if (_chatInput.Length >= 96) continue;
                var ch = KeyToChar(key, shift);
                if (ch.HasValue) _chatInput += ch.Value;
            }

            _previousKeyboard = keyboard;
        }

        private void SendChat()
        {
            var text = _chatInput.Trim();
            if (text.Length == 0) return;

            _action("SendChatChannel", new object[] { ChatChannel.Map.ToString(), text });
            AddChatLine(ChatChannel.Map, text);
            _chatInput = string.Empty;
        }

        private static char? KeyToChar(Keys key, bool shift)
        {
            if (key >= Keys.A && key <= Keys.Z)
            {
                var c = (char)('a' + ((int)key - (int)Keys.A));
                return shift ? char.ToUpperInvariant(c) : c;
            }

            if (key >= Keys.D0 && key <= Keys.D9)
            {
                var i = (int)key - (int)Keys.D0;
                if (!shift) return (char)('0' + i);
                return ")!@#$%^&*("[i];
            }

            if (key >= Keys.NumPad0 && key <= Keys.NumPad9)
                return (char)('0' + ((int)key - (int)Keys.NumPad0));

            return key switch
            {
                Keys.Space => ' ',
                Keys.OemPeriod => shift ? '>' : '.',
                Keys.OemComma => shift ? '<' : ',',
                Keys.OemMinus => shift ? '_' : '-',
                Keys.OemPlus => shift ? '+' : '=',
                Keys.OemQuestion => shift ? '?' : '/',
                Keys.OemSemicolon => shift ? ':' : ';',
                Keys.OemQuotes => shift ? '"' : '\'',
                _ => null
            };
        }

        private void AddChatLine(ChatChannel channel, string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return;
            _chatHistory.Add((channel, text.Trim()));
            while (_chatHistory.Count > 120) _chatHistory.RemoveAt(0);
        }

        private void ToggleChatChannel(ChatChannel channel)
        {
            _visibleChannels[channel] = !_visibleChannels[channel];
        }

        private static ChatChannel ParseChannel(string value)
        {
            return (value ?? string.Empty).Trim().ToLowerInvariant() switch
            {
                "global" or "globalmsg" or "broadcastmsg" => ChatChannel.Global,
                "guild" or "guildmsg" => ChatChannel.Guild,
                "pm" or "private" or "playermsg" => ChatChannel.PM,
                _ => ChatChannel.Map
            };
        }

        private void TogglePanel(MainGamePanel panel)
        {
            _activePanel = _activePanel == panel ? MainGamePanel.None : panel;
        }

        protected override void Draw(GameTime gameTime)
        {
            if (_frameReady != null)
            {
                _captureTarget ??= new RenderTarget2D(GraphicsDevice, LogicalWidth, LogicalHeight);
                GraphicsDevice.SetRenderTarget(_captureTarget);
            }
            GraphicsDevice.Clear(Color.Black);
            if (_spriteBatch is null) return;

            var transform = GetUiTransform();

            _spriteBatch.Begin(
                SpriteSortMode.Deferred,
                BlendState.AlphaBlend,
                SamplerState.PointClamp,
                null,
                null,
                null,
                transform);

            var background = GetMainGameTexture("game.jpg");
            if (background is not null)
                _spriteBatch.Draw(background, new Rectangle(0, 0, LogicalWidth, LogicalHeight), Color.White);

            if (_pixel is not null)
                _spriteBatch.Draw(_pixel, GameViewport, Color.Black);

            _spriteBatch.End();

            DrawWorld(transform);

            DrawLegacyWorldCommands(transform);

            _spriteBatch.Begin(
                SpriteSortMode.Deferred,
                BlendState.AlphaBlend,
                SamplerState.PointClamp,
                null,
                null,
                null,
                transform);

            DrawActivePanel();
            if (_activePanel == MainGamePanel.Character)
                DrawCharacterFields();
            DrawGauges();
            DrawChat();
            _spriteBatch.End();

            if (_captureTarget != null)
            {
                GraphicsDevice.SetRenderTarget(null);
                if (gameTime.TotalGameTime - _lastCapture >= TimeSpan.FromSeconds(1.0 / StreamFrameRate))
                {
                    int length = LogicalWidth * LogicalHeight * 4;
                    var pixels = ArrayPool<byte>.Shared.Rent(length);
                    try { _captureTarget.GetData<byte>(0, null, pixels, 0, length); }
                    catch { ArrayPool<byte>.Shared.Return(pixels); throw; }
                    _frameEncoder!.Submit(pixels);
                    // Keep the fractional remainder; the 15 ms simulation step is not an exact capture-rate divisor.
                    long intervalTicks = TimeSpan.FromSeconds(1.0 / StreamFrameRate).Ticks;
                    _lastCapture = TimeSpan.FromTicks(gameTime.TotalGameTime.Ticks - (gameTime.TotalGameTime.Ticks - _lastCapture.Ticks) % intervalTicks);
                }
            }
            base.Draw(gameTime);
        }

        private void DrawLegacyWorldCommands(Matrix transform)
        {
            if (_spriteBatch is null || _frame.Count == 0) return;

            // FnaSpriteCommand existed before the explicit FnaWorldCommand layers.
            // Those destinations are map-local coordinates, not whole-window HUD
            // coordinates. Keep backwards compatibility by drawing them into the
            // same clipped 640x480 picScreen viewport as the classic client.
            var oldScissor = GraphicsDevice.ScissorRectangle;
            var rasterizer = _worldRasterizer;
            GraphicsDevice.ScissorRectangle = GetViewportScissor();

            _spriteBatch.Begin(
                SpriteSortMode.FrontToBack,
                BlendState.AlphaBlend,
                SamplerState.PointClamp,
                null,
                rasterizer,
                null,
                transform);

            foreach (var command in _frame)
            {
                var texture = GetTexture(command.TexturePath);
                if (texture is null) continue;

                var destination = new Rectangle(
                    GameViewport.X + command.Destination.X,
                    GameViewport.Y + command.Destination.Y,
                    command.Destination.Width,
                    command.Destination.Height);

                _spriteBatch.Draw(
                    texture,
                    destination,
                    command.Source,
                    command.Tint,
                    0f,
                    Vector2.Zero,
                    SpriteEffects.None,
                    command.LayerDepth);
            }

            _spriteBatch.End();
            GraphicsDevice.ScissorRectangle = oldScissor;
        }

        private void DrawWorld(Matrix transform)
        {
            if (_spriteBatch is null) return;

            var oldScissor = GraphicsDevice.ScissorRectangle;
            var rasterizer = _worldRasterizer;
            GraphicsDevice.ScissorRectangle = GetViewportScissor();

            _spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.AlphaBlend, SamplerState.PointClamp, null, rasterizer, null, transform);
            var map = _mapEditorActive() && _scene?.MapId == _editorMapId && _editorMapPreview is not null
                ? _editorMapPreview : _scene?.Map;
            if (map is not null) DrawSceneLayers(map, false);
            BltMap();
            BltMask();
            DrawSceneItems();
            BltMapItems();
            DrawActors();
            BltProjectiles();
            DrawSceneSpells();
            BltAnimations();
            if (map is not null) DrawSceneLayers(map, true);
            BltFringe();
            DrawActorNames();
            BltNames();
            _spriteBatch.End();

            GraphicsDevice.ScissorRectangle = oldScissor;
        }

        private void DrawSceneLayers(FnaSceneMap map, bool upper)
        {
            bool animated = ((int)(_renderSeconds / 0.25) & 1) != 0;
            if (!upper)
            {
                DrawSceneLayer(map, 0, tile => (tile.Ground, 0), true);
                DrawSceneLayer(map, 1, tile => animated && tile.Anim > 0 ? (tile.Anim, 2) : (tile.DoorOpen ? 0 : tile.Mask, 1), false);
                DrawSceneLayer(map, 2, tile => animated && tile.M2Anim > 0 ? (tile.M2Anim, 4) : (tile.Mask2, 3), false);
            }
            else
            {
                DrawSceneLayer(map, 3, tile => animated && tile.FAnim > 0 ? (tile.FAnim, 6) : (tile.Fringe, 5), false);
                DrawSceneLayer(map, 4, tile => animated && tile.F2Anim > 0 ? (tile.F2Anim, 8) : (tile.Fringe2, 7), false);
            }
        }

        private void DrawSceneLayer(FnaSceneMap map, int layer, Func<FnaSceneTile, (int Tile, int SourceLayer)> select, bool ground)
        {
            int inherited = layer < map.LayerTileset.Count && map.LayerTileset[layer] > 0 ? map.LayerTileset[layer] : map.Tileset;
            for (int i = 0; i < Math.Min(map.Tiles.Count, 16 * 12); i++)
            {
                var cell = map.Tiles[i];
                var selected = select(cell);
                int tileset = selected.SourceLayer < cell.LayerTileset.Count && cell.LayerTileset[selected.SourceLayer] > 0
                    ? cell.LayerTileset[selected.SourceLayer] : inherited;
                if (tileset <= 0 || selected.Tile < 0 || (!ground && selected.Tile == 0)) continue;
                var texture = GetWorldTexture($"tiles{tileset}.png", ground ? null : Color.Black);
                DrawWorldSprite(texture, new Rectangle(i % 16 * 32, i / 16 * 32, 32, 32),
                    new Rectangle(selected.Tile % 12 * 32, selected.Tile / 12 * 32, 32, 32), Color.White);
            }
        }

        private void DrawSceneItems()
        {
            if (_scene is null) return;
            var texture = GetWorldTexture("items.png", Color.White);
            foreach (var item in _scene.Items)
                if (item.Picture >= 0)
                    DrawWorldSprite(texture, new Rectangle(item.X * 32, item.Y * 32, 32, 32),
                        new Rectangle(item.Picture % 6 * 32, item.Picture / 6 * 32, 32, 32), Color.White);
        }

        private void DrawActors()
        {
            var draws = new List<(int Y, Action Draw)>();
            if (_scene is not null)
            {
                var sprites = GetWorldTexture("sprites.png", Color.Black);
                foreach (var actor in _scene.ActorsInDrawOrder())
                {
                    if (actor.Sprite < 0) continue;
                    var current = actor;
                    draws.Add((actor.DrawY, () => DrawWorldSprite(sprites,
                        new Rectangle(current.DrawX - 8, current.DrawY - 32, 48, 64),
                        new Rectangle((Math.Clamp(current.Direction, 0, 3) * 3 + current.AnimationFrame(_renderSeconds)) * 48,
                            current.Sprite * 64, 48, 64), Color.White)));
                }
            }
            foreach (var command in _worldFrame.Where(c => c.Layer is FnaWorldLayer.Npc or FnaWorldLayer.Player))
            {
                var current = command;
                draws.Add((command.Destination.Bottom - 32, () => DrawWorldSprite(GetTexture(current.TexturePath),
                    current.Destination, current.Source, current.Tint)));
            }
            foreach (var draw in draws.OrderBy(d => d.Y)) draw.Draw();
        }

        private void DrawActorNames()
        {
            if (_scene is null) return;
            foreach (var actor in _scene.ActorsInDrawOrder())
            {
                if (string.IsNullOrEmpty(actor.Name)) continue;
                int x = Math.Clamp(GameViewport.X + actor.DrawX + 16 - actor.Name.Length * 3,
                    GameViewport.X, Math.Max(GameViewport.X, GameViewport.Right - actor.Name.Length * 6));
                int y = Math.Max(GameViewport.Y, GameViewport.Y + actor.DrawY - 42);
                DrawTinyText(actor.Name, x + 1, y + 1, Color.Black, 1, GameViewport.Right);
                DrawTinyText(actor.Name, x, y, Color.White, 1, GameViewport.Right);
            }
        }

        private void DrawSceneSpells()
        {
            if (_scene is null) return;
            var texture = GetWorldTexture("spells.png", Color.Black);
            foreach (var spell in _scene.Spells)
            {
                int frame = spell.Frame(_renderSeconds);
                if (spell.Animation < 0 || frame < 0 || frame > 13) continue;
                DrawWorldSprite(texture, new Rectangle(spell.X * 32, spell.Y * 32, 32, 32),
                    new Rectangle(frame * 32, spell.Animation * 32, 32, 32), Color.White);
            }
        }

        private void DrawWorldSprite(Texture2D? texture, Rectangle destination, Rectangle? source, Color tint)
        {
            if (texture is null || _spriteBatch is null) return;
            if (source is Rectangle rect && (rect.X < 0 || rect.Y < 0 || rect.Right > texture.Width || rect.Bottom > texture.Height)) return;
            destination.Offset(GameViewport.X, GameViewport.Y);
            _spriteBatch.Draw(texture, destination, source, tint);
        }

        private Texture2D? GetWorldTexture(string filename, Color? colorKey)
        {
            string path = Path.Combine(AppContext.BaseDirectory, "gfx", filename);
            if (colorKey is null) return GetTexture(path);
            string cacheKey = path + "#" + colorKey.Value.PackedValue;
            if (_textures.TryGetValue(cacheKey, out var cached)) return cached;
            if (!File.Exists(path)) return null;
            using var stream = File.OpenRead(path);
            var texture = Texture2D.FromStream(GraphicsDevice, stream);
            var pixels = new Color[texture.Width * texture.Height];
            texture.GetData(pixels);
            var key = colorKey.Value;
            for (int i = 0; i < pixels.Length; i++)
                if (pixels[i].R == key.R && pixels[i].G == key.G && pixels[i].B == key.B) pixels[i] = Color.Transparent;
            texture.SetData(pixels);
            _textures[cacheKey] = texture;
            return texture;
        }
        private void BltMap() => DrawWorldLayer(FnaWorldLayer.MapGround);
        private void BltMask() => DrawWorldLayer(FnaWorldLayer.MapMask);
        private void BltMapItems() => DrawWorldLayer(FnaWorldLayer.MapItem);
        private void BltNpcs() => DrawWorldLayer(FnaWorldLayer.Npc);
        private void BltPlayers() => DrawWorldLayer(FnaWorldLayer.Player);
        private void BltProjectiles() => DrawWorldLayer(FnaWorldLayer.Projectile);
        private void BltAnimations() => DrawWorldLayer(FnaWorldLayer.Animation);
        private void BltFringe() => DrawWorldLayer(FnaWorldLayer.Fringe);
        private void BltNames()
        {
            foreach (var command in _worldTextFrame)
                DrawTinyText(command.Text, GameViewport.X + command.X, GameViewport.Y + command.Y, command.Color, 1, GameViewport.Right - 4);
        }

        private void DrawWorldLayer(FnaWorldLayer layer)
        {
            if (_spriteBatch is null) return;
            foreach (var command in _worldFrame.Where(command => command.Layer == layer))
            {
                var texture = GetTexture(command.TexturePath);
                if (texture is null) continue;
                var destination = new Rectangle(
                    GameViewport.X + command.Destination.X,
                    GameViewport.Y + command.Destination.Y,
                    command.Destination.Width,
                    command.Destination.Height);
                _spriteBatch.Draw(texture, destination, command.Source, command.Tint);
            }
        }

        private Rectangle GetViewportScissor()
        {
            if (_frameReady != null) return GameViewport;
            var bounds = Window.ClientBounds;
            var scale = Math.Min(bounds.Width / (float)LogicalWidth, bounds.Height / (float)LogicalHeight);
            if (scale <= 0f) scale = 1f;
            var offsetX = (bounds.Width - LogicalWidth * scale) * 0.5f;
            var offsetY = (bounds.Height - LogicalHeight * scale) * 0.5f;
            return new Rectangle(
                (int)Math.Floor(offsetX + GameViewport.X * scale),
                (int)Math.Floor(offsetY + GameViewport.Y * scale),
                Math.Max(1, (int)Math.Ceiling(GameViewport.Width * scale)),
                Math.Max(1, (int)Math.Ceiling(GameViewport.Height * scale)));
        }

        private Matrix GetUiTransform()
        {
            if (_frameReady != null) return Matrix.Identity;
            var bounds = Window.ClientBounds;
            var scale = Math.Min(bounds.Width / (float)LogicalWidth, bounds.Height / (float)LogicalHeight);
            if (scale <= 0f) scale = 1f;
            var offsetX = (bounds.Width - LogicalWidth * scale) * 0.5f;
            var offsetY = (bounds.Height - LogicalHeight * scale) * 0.5f;
            return Matrix.CreateScale(scale, scale, 1f) * Matrix.CreateTranslation(offsetX, offsetY, 0f);
        }

        private bool TryScreenToLogical(int screenX, int screenY, out int x, out int y)
        {
            var bounds = Window.ClientBounds;
            var scale = Math.Min(bounds.Width / (float)LogicalWidth, bounds.Height / (float)LogicalHeight);
            if (scale <= 0f)
            {
                x = y = 0;
                return false;
            }

            var offsetX = (bounds.Width - LogicalWidth * scale) * 0.5f;
            var offsetY = (bounds.Height - LogicalHeight * scale) * 0.5f;
            var logicalX = (screenX - offsetX) / scale;
            var logicalY = (screenY - offsetY) / scale;
            if (logicalX < 0 || logicalX >= LogicalWidth || logicalY < 0 || logicalY >= LogicalHeight)
            {
                x = y = 0;
                return false;
            }

            x = (int)logicalX;
            y = (int)logicalY;
            return true;
        }

        private void DrawActivePanel()
        {
            if (_spriteBatch is null || _activePanel == MainGamePanel.None) return;
            if (!PanelInfo.TryGetValue(_activePanel, out var info)) return;

            var texture = GetMainGameTexture(info.AssetName);
            if (texture is not null)
                _spriteBatch.Draw(texture, info.Destination, Color.White);
        }

        private void DrawCharacterFields()
        {
            if (_spriteBatch is null) return;

            string className, guildName;
            int level, points, strength, defense, speed, magic;
            lock (_characterLock)
            {
                className = _characterClass;
                level = _characterLevel;
                guildName = _characterGuild;
                points = _characterPoints;
                strength = _strength;
                defense = _defense;
                speed = _speed;
                magic = _magic;
            }

            var hp = VitalText(FnaVital.HP);
            var mp = VitalText(FnaVital.MP);
            var sp = VitalText(FnaVital.SP);
            var xp = VitalText(FnaVital.XP);

            DrawTinyText(className, 789, 315, Color.White, 1);
            DrawTinyText(level.ToString(), 789, 335, Color.White, 1);
            DrawTinyText(guildName, 789, 355, Color.White, 1);
            DrawTinyText(hp, 789, 375, Color.White, 1);
            DrawTinyText(mp, 789, 395, Color.White, 1);
            DrawTinyText(xp, 789, 415, Color.White, 1);

            // Skill Points are not a separate stored field in the current server yet.
            // Display the requested explicit zero rather than N/A.
            DrawNumericValueBox(0, new Rectangle(768, 432, 34, 13));
            DrawNumericValueBox(points, new Rectangle(884, 432, 34, 13));
            DrawNumericValueBox(strength, new Rectangle(786, 452, 26, 13));
            DrawNumericValueBox(defense, new Rectangle(786, 472, 26, 13));
            DrawTinyText(sp, 789, 495, Color.White, 1);
            DrawNumericValueBox(speed, new Rectangle(786, 512, 26, 13));
            DrawNumericValueBox(magic, new Rectangle(786, 532, 26, 13));
            DrawTinyText("N/A", 789, 555, Color.White, 1);

            DrawTrainButton(TrainStrengthButton);
            DrawTrainButton(TrainDefenseButton);
            DrawTrainButton(TrainSpeedButton);
            DrawTrainButton(TrainMagicButton);
        }

        private string VitalText(FnaVital vital)
        {
            lock (_vitalsLock)
            {
                if (!_vitals.TryGetValue(vital, out var value)) return "0 / 0";
                return $"{value.Current} / {value.Maximum}";
            }
        }

        private void DrawNumericValueBox(int value, Rectangle box)
        {
            if (_spriteBatch is null || _pixel is null) return;
            _spriteBatch.Draw(_pixel, box, Color.White);
            var text = value.ToString();
            var textWidth = text.Length * 6 - 1;
            var x = box.X + Math.Max(2, (box.Width - textWidth) / 2);
            var y = box.Y + 3;
            DrawTinyText(text, x, y, Color.Black, 1);
        }

        private bool CanTrain()
        {
            lock (_characterLock)
                return _characterPoints > 0;
        }

        private void DrawTrainButton(Rectangle destination)
        {
            if (_spriteBatch is null) return;
            var enabled = CanTrain();
            var tint = enabled ? Color.LimeGreen : Color.Red;
            var texture = GetMainGameTexture("train-plus.png");
            if (texture is not null)
            {
                _spriteBatch.Draw(texture, destination, tint);
                return;
            }

            // Fallback only if the Rockwell plus asset could not be generated.
            DrawTinyText("+", destination.X + 5, destination.Y + 5, tint, 1);
        }

        private void DrawGauges()
        {
            DrawGauge(FnaVital.HP, "hp.JPG", HpGaugeRect);
            DrawGauge(FnaVital.MP, "mp.JPG", MpGaugeRect);
            DrawGauge(FnaVital.XP, "xp.JPG", XpGaugeRect);
            DrawGauge(FnaVital.SP, "sp.JPG", SpGaugeRect);
        }

        private void DrawGauge(FnaVital vital, string fileName, Rectangle destination)
        {
            if (_spriteBatch is null) return;
            var texture = GetGaugeTexture(fileName);
            if (texture is null) return;

            float ratio = 1f;
            lock (_vitalsLock)
            {
                if (_vitals.TryGetValue(vital, out var value) && value.Maximum > 0)
                    ratio = Math.Clamp(value.Current / (float)value.Maximum, 0f, 1f);
            }

            var sourceWidth = Math.Max(1, (int)Math.Round(texture.Width * ratio));
            var destinationWidth = Math.Max(1, (int)Math.Round(destination.Width * ratio));
            var source = new Rectangle(0, 0, sourceWidth, texture.Height);
            var clipped = new Rectangle(destination.X, destination.Y, destinationWidth, destination.Height);
            _spriteBatch.Draw(texture, clipped, source, Color.White);
        }

        private void DrawChat()
        {
            if (_spriteBatch is null) return;

            // The FNA window is the actual main-game window, so the old Eto
            // txtMyTextBox is not visible here. Draw a real-looking input field
            // in the same location and let HandleKeyboard own text entry.
            if (_pixel is not null)
            {
                _spriteBatch.Draw(_pixel, ChatInputRect, Color.White);
                _spriteBatch.Draw(_pixel, new Rectangle(ChatInputRect.X, ChatInputRect.Y, ChatInputRect.Width, 1), Color.Black);
                _spriteBatch.Draw(_pixel, new Rectangle(ChatInputRect.X, ChatInputRect.Bottom - 1, ChatInputRect.Width, 1), Color.Black);
                _spriteBatch.Draw(_pixel, new Rectangle(ChatInputRect.X, ChatInputRect.Y, 1, ChatInputRect.Height), Color.Black);
                _spriteBatch.Draw(_pixel, new Rectangle(ChatInputRect.Right - 1, ChatInputRect.Y, 1, ChatInputRect.Height), Color.Black);
            }

            var enabledLines = _chatHistory
                .Where(line => _visibleChannels.TryGetValue(line.Channel, out var enabled) && enabled)
                .ToList();
            var visible = enabledLines.Skip(Math.Max(0, enabledLines.Count - 7));

            var y = ChatHistoryRect.Y + 5;
            foreach (var line in visible)
            {
                DrawTinyText(line.Text, ChatHistoryRect.X + 6, y, Color.Black, 1, ChatHistoryRect.Right - 8);
                y += 16;
            }

            DrawTinyText(_chatInput + "_", ChatInputRect.X + 5, ChatInputRect.Y + 5, Color.Black, 1, ChatInputRect.Right - 8);
        }

        private void DrawTinyText(string text, int x, int y, Color color, int scale, int maxX = LogicalWidth - 8)
        {
            if (_spriteBatch is null || _pixel is null || string.IsNullOrEmpty(text)) return;

            var cursor = x;
            foreach (var raw in text)
            {
                var ch = char.ToUpperInvariant(raw);
                if (!TinyFont.TryGetValue(ch, out var rows))
                    rows = TinyFont['?'];

                for (var row = 0; row < rows.Length; row++)
                {
                    var bits = rows[row];
                    for (var col = 0; col < 5; col++)
                    {
                        if ((bits & (1 << (4 - col))) == 0) continue;
                        _spriteBatch.Draw(_pixel,
                            new Rectangle(cursor + col * scale, y + row * scale, scale, scale), color);
                    }
                }
                cursor += 6 * scale;
                if (cursor > maxX) break;
            }
        }

        private Texture2D? GetMainGameTexture(string assetName)
        {
            var original = GetTexture(Path.Combine(AppContext.BaseDirectory, "Assets", "frmMainGame", assetName));
            if (original != null) return original;
            string? current = assetName.ToLowerInvariant() switch {
                "game.jpg" => "frmMainGame.jpg", "character.jpg" => "imgCharacter.jpg",
                "inventory.jpg" => "imgInventory.jpg", "skills.jpg" => "imgSkills.jpg",
                "train-plus.png" => "imgTraining.png", _ => null
            };
            return current == null ? null : GetTexture(Path.Combine(AppContext.BaseDirectory, "Assets", "frmMainGame", current));
        }

        private Texture2D? GetGaugeTexture(string assetName) =>
            GetTexture(Path.Combine(AppContext.BaseDirectory, "gfx", "Gauges", assetName));

        private Texture2D? GetTexture(string path)
        {
            if (_textures.TryGetValue(path, out var texture)) return texture;
            if (string.IsNullOrWhiteSpace(path) || !File.Exists(path)) return null;

            using var stream = File.OpenRead(path);
            texture = Texture2D.FromStream(GraphicsDevice, stream);
            _textures[path] = texture;
            return texture;
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _frameEncoder?.Dispose();
                _worldRasterizer.Dispose();
                _pixel?.Dispose();
                _spriteBatch?.Dispose();
                foreach (var texture in _textures.Values) texture.Dispose();
                _textures.Clear();
            }
            base.Dispose(disposing);
        }

        // 5x7 ASCII bitmap font used by the FNA chat box. This avoids adding a
        // content-pipeline SpriteFont dependency to the migrated client.
        private static readonly IReadOnlyDictionary<char, byte[]> TinyFont = new Dictionary<char, byte[]>
        {
            [' '] = new byte[] {0,0,0,0,0,0,0},
            ['?'] = new byte[] {14,17,1,2,4,0,4},
            ['!'] = new byte[] {4,4,4,4,4,0,4},
            ['.'] = new byte[] {0,0,0,0,0,0,4},
            [','] = new byte[] {0,0,0,0,0,4,8},
            [':'] = new byte[] {0,4,0,0,4,0,0},
            [';'] = new byte[] {0,4,0,0,4,8,0},
            ['-'] = new byte[] {0,0,0,31,0,0,0},
            ['_'] = new byte[] {0,0,0,0,0,0,31},
            ['/'] = new byte[] {1,2,2,4,8,8,16},
            ['\\'] = new byte[] {16,8,8,4,2,2,1},
            ['\''] = new byte[] {4,4,0,0,0,0,0},
            ['"'] = new byte[] {10,10,0,0,0,0,0},
            ['('] = new byte[] {2,4,8,8,8,4,2},
            [')'] = new byte[] {8,4,2,2,2,4,8},
            ['+'] = new byte[] {0,4,4,31,4,4,0},
            ['='] = new byte[] {0,0,31,0,31,0,0},
            ['>'] = new byte[] {16,8,4,2,4,8,16},
            ['<'] = new byte[] {1,2,4,8,4,2,1},
            ['#'] = new byte[] {10,31,10,10,31,10,0},
            ['@'] = new byte[] {14,17,23,21,23,16,14},
            ['0'] = new byte[] {14,17,19,21,25,17,14},
            ['1'] = new byte[] {4,12,4,4,4,4,14},
            ['2'] = new byte[] {14,17,1,2,4,8,31},
            ['3'] = new byte[] {30,1,1,14,1,1,30},
            ['4'] = new byte[] {2,6,10,18,31,2,2},
            ['5'] = new byte[] {31,16,16,30,1,1,30},
            ['6'] = new byte[] {14,16,16,30,17,17,14},
            ['7'] = new byte[] {31,1,2,4,8,8,8},
            ['8'] = new byte[] {14,17,17,14,17,17,14},
            ['9'] = new byte[] {14,17,17,15,1,1,14},
            ['A'] = new byte[] {14,17,17,31,17,17,17},
            ['B'] = new byte[] {30,17,17,30,17,17,30},
            ['C'] = new byte[] {14,17,16,16,16,17,14},
            ['D'] = new byte[] {30,17,17,17,17,17,30},
            ['E'] = new byte[] {31,16,16,30,16,16,31},
            ['F'] = new byte[] {31,16,16,30,16,16,16},
            ['G'] = new byte[] {14,17,16,23,17,17,15},
            ['H'] = new byte[] {17,17,17,31,17,17,17},
            ['I'] = new byte[] {14,4,4,4,4,4,14},
            ['J'] = new byte[] {7,2,2,2,2,18,12},
            ['K'] = new byte[] {17,18,20,24,20,18,17},
            ['L'] = new byte[] {16,16,16,16,16,16,31},
            ['M'] = new byte[] {17,27,21,21,17,17,17},
            ['N'] = new byte[] {17,25,21,19,17,17,17},
            ['O'] = new byte[] {14,17,17,17,17,17,14},
            ['P'] = new byte[] {30,17,17,30,16,16,16},
            ['Q'] = new byte[] {14,17,17,17,21,18,13},
            ['R'] = new byte[] {30,17,17,30,20,18,17},
            ['S'] = new byte[] {15,16,16,14,1,1,30},
            ['T'] = new byte[] {31,4,4,4,4,4,4},
            ['U'] = new byte[] {17,17,17,17,17,17,14},
            ['V'] = new byte[] {17,17,17,17,17,10,4},
            ['W'] = new byte[] {17,17,17,21,21,21,10},
            ['X'] = new byte[] {17,17,10,4,10,17,17},
            ['Y'] = new byte[] {17,17,10,4,4,4,4},
            ['Z'] = new byte[] {31,1,2,4,8,16,31}
        };
    }
}
