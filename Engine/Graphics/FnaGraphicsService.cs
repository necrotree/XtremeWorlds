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
/// The main game window, HUD, side panels, gauges and chat are rendered by FNA.
/// Eto remains available for standalone forms such as frmOptions and editors.
/// The logical UI remains the original 950x700 twinBASIC layout and is scaled
/// uniformly when the FNA window is resized.
/// </summary>
public sealed class FnaGraphicsService : IDisposable
{
    private readonly ConcurrentQueue<FnaSpriteCommand> _commands = new();
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

    public void Start(int width = 950, int height = 700, ModGameLogic? logic = null)
    {
        if (IsRunning) return;
        _stopRequested = false;
        _thread = new Thread(() =>
        {
            var failed = false;
            try
            {
                using var game = new FnaClientGame(
                    _commands,
                    _chat,
                    width,
                    height,
                    logic,
                    () => _stopRequested,
                    RaiseMainGameAction);
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
                logic?.GameDestroy();
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

    public void AddChatMessage(string channel, string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return;
        _chat.Enqueue((channel ?? string.Empty, text));
    }

    public void SetVital(FnaVital vital, int current, int maximum)
    {
        _game?.SetVital(vital, current, maximum);
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
    }

    public void Dispose() => Stop();

    private enum MainGamePanel
    {
        None,
        Character,
        Inventory,
        Guild,
        Skills,
        Training,
        Notes,
        Who
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

        // Current Core/Forms/frmMainGame.cs coordinates, generated from the
        // twinBASIC frmMirage/frmMainGame layout.
        private static readonly Rectangle StatsButton = new(687, 179, 42, 42);
        private static readonly Rectangle InventoryButton = new(735, 179, 42, 42);
        private static readonly Rectangle GuildButton = new(781, 179, 42, 42);
        private static readonly Rectangle SkillsButton = new(827, 179, 42, 42);
        private static readonly Rectangle OptionsButton = new(875, 179, 42, 42);
        private static readonly Rectangle TrainingButton = new(745, 118, 35, 36);
        private static readonly Rectangle NotesButton = new(782, 119, 35, 36);
        private static readonly Rectangle WhoButton = new(708, 119, 35, 36);
        private static readonly Rectangle WebsiteButton = new(678, 665, 121, 29);
        private static readonly Rectangle LogoutButton = new(799, 665, 121, 29);

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

        private static readonly IReadOnlyDictionary<MainGamePanel, MainGamePanelInfo> PanelInfo =
            new Dictionary<MainGamePanel, MainGamePanelInfo>
            {
                [MainGamePanel.Character] = new("character.jpg", new Rectangle(679, 281, 265, 354)),
                [MainGamePanel.Inventory] = new("Inventory.jpg", new Rectangle(673, 277, 265, 382)),
                [MainGamePanel.Guild] = new("guild.jpg", new Rectangle(679, 281, 265, 354)),
                [MainGamePanel.Skills] = new("skills.jpg", new Rectangle(677, 278, 265, 382)),
                [MainGamePanel.Training] = new("training.png", new Rectangle(677, 280, 248, 266)),
                [MainGamePanel.Notes] = new("note.png", new Rectangle(676, 280, 248, 266)),
                [MainGamePanel.Who] = new("who.png", new Rectangle(677, 280, 248, 266))
            };

        private readonly GraphicsDeviceManager _graphics;
        private readonly ConcurrentQueue<FnaSpriteCommand> _incoming;
        private readonly ConcurrentQueue<(string Channel, string Text)> _chatIncoming;
        private readonly List<FnaSpriteCommand> _frame = new();
        private readonly Dictionary<string, Texture2D> _textures = new(StringComparer.OrdinalIgnoreCase);
        private readonly Dictionary<ChatChannel, List<string>> _chatHistory = new();
        private readonly Dictionary<FnaVital, (int Current, int Maximum)> _vitals = new();
        private readonly object _vitalsLock = new();
        private readonly ModGameLogic? _logic;
        private readonly Func<bool> _shouldStop;
        private readonly Action<string, object[]> _action;

        private SpriteBatch? _spriteBatch;
        private Texture2D? _pixel;
        private volatile bool _exitRequested;
        private MouseState _previousMouse;
        private KeyboardState _previousKeyboard;
        private MainGamePanel _activePanel;
        private ChatChannel _activeChatChannel = ChatChannel.Map;
        private string _chatInput = string.Empty;

        public FnaClientGame(
            ConcurrentQueue<FnaSpriteCommand> incoming,
            ConcurrentQueue<(string Channel, string Text)> chatIncoming,
            int width,
            int height,
            ModGameLogic? logic,
            Func<bool> shouldStop,
            Action<string, object[]> action)
        {
            _logic = logic;
            _shouldStop = shouldStop;
            _action = action;
            _incoming = incoming;
            _chatIncoming = chatIncoming;

            foreach (ChatChannel channel in Enum.GetValues(typeof(ChatChannel)))
                _chatHistory[channel] = new List<string>();

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
        }

        public void RequestExit() => _exitRequested = true;

        public void SetVital(FnaVital vital, int current, int maximum)
        {
            lock (_vitalsLock)
                _vitals[vital] = (Math.Max(0, current), Math.Max(0, maximum));
        }

        protected override void Initialize()
        {
            base.Initialize();
            _previousMouse = Mouse.GetState();
            _previousKeyboard = Keyboard.GetState();
            _logic?.GameInit();
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
            if (_exitRequested || _shouldStop())
            {
                Exit();
                return;
            }

            _logic?.GameLoop(gameTime.TotalGameTime, IsActive);
            if (_logic is { InGame: false })
            {
                Exit();
                return;
            }

            if (_incoming.TryDequeue(out var command))
            {
                _frame.Clear();
                _frame.Add(command);
                while (_incoming.TryDequeue(out command)) _frame.Add(command);
            }

            while (_chatIncoming.TryDequeue(out var line))
                AddChatLine(ParseChannel(line.Channel), line.Text);

            if (IsActive)
            {
                HandleMouse();
                HandleKeyboard();
            }

            base.Update(gameTime);
        }

        private void HandleMouse()
        {
            var mouse = Mouse.GetState();
            var leftPressed = mouse.LeftButton == ButtonState.Pressed &&
                              _previousMouse.LeftButton == ButtonState.Released;

            if (leftPressed && TryScreenToLogical(mouse.X, mouse.Y, out var x, out var y))
            {
                if (StatsButton.Contains(x, y)) TogglePanel(MainGamePanel.Character);
                else if (InventoryButton.Contains(x, y)) TogglePanel(MainGamePanel.Inventory);
                else if (GuildButton.Contains(x, y)) TogglePanel(MainGamePanel.Guild);
                else if (SkillsButton.Contains(x, y)) TogglePanel(MainGamePanel.Skills);
                else if (TrainingButton.Contains(x, y)) TogglePanel(MainGamePanel.Training);
                else if (NotesButton.Contains(x, y)) TogglePanel(MainGamePanel.Notes);
                else if (WhoButton.Contains(x, y)) TogglePanel(MainGamePanel.Who);
                else if (OptionsButton.Contains(x, y)) _action("ShowOptions", Array.Empty<object>());
                else if (WebsiteButton.Contains(x, y)) _action("OpenWebsite", Array.Empty<object>());
                else if (LogoutButton.Contains(x, y)) _action("Logout", Array.Empty<object>());
                else if (MapChannelButton.Contains(x, y)) _activeChatChannel = ChatChannel.Map;
                else if (GlobalChannelButton.Contains(x, y)) _activeChatChannel = ChatChannel.Global;
                else if (GuildChannelButton.Contains(x, y)) _activeChatChannel = ChatChannel.Guild;
                else if (PmChannelButton.Contains(x, y)) _activeChatChannel = ChatChannel.PM;
            }

            _previousMouse = mouse;
        }

        private void HandleKeyboard()
        {
            var keyboard = Keyboard.GetState();
            var pressed = keyboard.GetPressedKeys();
            var shift = keyboard.IsKeyDown(Keys.LeftShift) || keyboard.IsKeyDown(Keys.RightShift);

            foreach (var key in pressed)
            {
                if (_previousKeyboard.IsKeyDown(key)) continue;

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

            _action("SendChatChannel", new object[] { _activeChatChannel.ToString(), text });
            AddChatLine(_activeChatChannel, "> " + text);
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
            var list = _chatHistory[channel];
            list.Add(text.Trim());
            while (list.Count > 80) list.RemoveAt(0);
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

            _spriteBatch.End();

            if (_frame.Count > 0)
            {
                _spriteBatch.Begin(
                    SpriteSortMode.FrontToBack,
                    BlendState.AlphaBlend,
                    SamplerState.PointClamp,
                    null,
                    null,
                    null,
                    transform);

                foreach (var command in _frame)
                {
                    var texture = GetTexture(command.TexturePath);
                    if (texture is null) continue;
                    _spriteBatch.Draw(texture, command.Destination, command.Source, command.Tint,
                        0f, Vector2.Zero, SpriteEffects.None, command.LayerDepth);
                }
                _spriteBatch.End();
            }

            _spriteBatch.Begin(
                SpriteSortMode.Deferred,
                BlendState.AlphaBlend,
                SamplerState.PointClamp,
                null,
                null,
                null,
                transform);

            DrawActivePanel();
            DrawGauges();
            DrawChat();
            _spriteBatch.End();

            _logic?.PresentGameFrame(gameTime.TotalGameTime);
            base.Draw(gameTime);
        }

        private Matrix GetUiTransform()
        {
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
            if (_spriteBatch is null || _pixel is null) return;

            _spriteBatch.Draw(_pixel, ChatHistoryRect, new Color(0, 0, 0, 130));
            _spriteBatch.Draw(_pixel, ChatInputRect, new Color(0, 0, 0, 185));

            DrawChannelHighlight(MapChannelButton, ChatChannel.Map);
            DrawChannelHighlight(GlobalChannelButton, ChatChannel.Global);
            DrawChannelHighlight(GuildChannelButton, ChatChannel.Guild);
            DrawChannelHighlight(PmChannelButton, ChatChannel.PM);

            var lines = _chatHistory[_activeChatChannel];
            var visible = lines.Skip(Math.Max(0, lines.Count - 7)).ToArray();
            var y = ChatHistoryRect.Y + 5;
            foreach (var line in visible)
            {
                DrawTinyText(line, ChatHistoryRect.X + 6, y, Color.White, 1);
                y += 16;
            }

            var prefix = _activeChatChannel switch
            {
                ChatChannel.Map => "MAP> ",
                ChatChannel.Global => "GLOBAL> ",
                ChatChannel.Guild => "GUILD> ",
                ChatChannel.PM => "PM> ",
                _ => "> "
            };
            DrawTinyText(prefix + _chatInput + "_", ChatInputRect.X + 5, ChatInputRect.Y + 5, Color.White, 1);
        }

        private void DrawChannelHighlight(Rectangle rect, ChatChannel channel)
        {
            if (_spriteBatch is null || _pixel is null || _activeChatChannel != channel) return;
            _spriteBatch.Draw(_pixel, rect, new Color(255, 255, 255, 45));
        }

        private void DrawTinyText(string text, int x, int y, Color color, int scale)
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
                if (cursor > ChatHistoryRect.Right - 8) break;
            }
        }

        private Texture2D? GetMainGameTexture(string assetName) =>
            GetTexture(Path.Combine(AppContext.BaseDirectory, "Assets", "frmMainGame", assetName));

        private Texture2D? GetGaugeTexture(string assetName) =>
            GetTexture(Path.Combine(AppContext.BaseDirectory, "gfx", "Gauges", assetName));

        private Texture2D? GetTexture(string path)
        {
            if (string.IsNullOrWhiteSpace(path) || !File.Exists(path)) return null;
            if (_textures.TryGetValue(path, out var texture)) return texture;

            using var stream = File.OpenRead(path);
            texture = Texture2D.FromStream(GraphicsDevice, stream);
            _textures[path] = texture;
            return texture;
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
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
