using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
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

/// <summary>
/// FNA renderer replacing the DirectX/DX11 surface layer.  Eto remains the UI
/// toolkit; the game world is rendered by this FNA game window.
/// </summary>
public sealed class FnaGraphicsService : IDisposable
{
    private readonly ConcurrentQueue<FnaSpriteCommand> _commands = new();
    private Thread? _thread;
    private FnaClientGame? _game;
    private volatile bool _stopRequested;
    public event EventHandler? Closed;
    public event EventHandler<Exception>? Failed;

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
                using var game = new FnaClientGame(_commands, width, height, logic, () => _stopRequested);
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

    public void Stop()
    {
        _stopRequested = true;
        if (_thread is { IsAlive: true } && Thread.CurrentThread != _thread)
            _thread.Join();
        if (_thread is not { IsAlive: true }) _thread = null;
    }

    public void Dispose() => Stop();

    private sealed class FnaClientGame : Game
    {
        private readonly GraphicsDeviceManager _graphics;
        private readonly ConcurrentQueue<FnaSpriteCommand> _incoming;
        private readonly List<FnaSpriteCommand> _frame = new();
        private readonly Dictionary<string, Texture2D> _textures = new(StringComparer.OrdinalIgnoreCase);
        private SpriteBatch? _spriteBatch;
        private volatile bool _exitRequested;
        private readonly ModGameLogic? _logic;
        private readonly Func<bool> _shouldStop;
        private readonly int _width, _height;

        public FnaClientGame(ConcurrentQueue<FnaSpriteCommand> incoming, int width, int height, ModGameLogic? logic, Func<bool> shouldStop)
        {
            _logic = logic;
            _shouldStop = shouldStop;
            _width = width;
            _height = height;
            _incoming = incoming;
            _graphics = new GraphicsDeviceManager(this)
            {
                PreferredBackBufferWidth = width,
                PreferredBackBufferHeight = height,
                SynchronizeWithVerticalRetrace = true
            };
            // Original GameLoop caps frames with Tick + 15; FNA handles pacing.
            IsFixedTimeStep = true;
            TargetElapsedTime = TimeSpan.FromMilliseconds(15);
            Window.Title = "XtremeWorlds";
            IsMouseVisible = true;
        }

        public void RequestExit() => _exitRequested = true;

        protected override void Initialize()
        {
            base.Initialize();
            _logic?.GameInit();
        }

        protected override void LoadContent()
        {
            _spriteBatch = new SpriteBatch(GraphicsDevice);
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

            if (IsActive && Keyboard.GetState().IsKeyDown(Keys.Escape)) Exit();

            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(new Color(8, 12, 18));
            if (_spriteBatch is null)
                return;

            _spriteBatch.Begin(SpriteSortMode.FrontToBack, BlendState.AlphaBlend, SamplerState.PointClamp, null, null);
            var background = GetTexture(Path.Combine(AppContext.BaseDirectory, "Assets", "frmMainGame", "game.jpg"));
            if (background is not null)
                _spriteBatch.Draw(background, new Rectangle(0, 0, _width, _height), null, Color.White, 0f, Vector2.Zero, SpriteEffects.None, 0f);
            foreach (var command in _frame)
            {
                var texture = GetTexture(command.TexturePath);
                if (texture is null) continue;
                _spriteBatch.Draw(texture, command.Destination, command.Source, command.Tint, 0f, Vector2.Zero, SpriteEffects.None, command.LayerDepth);
            }
            _spriteBatch.End();
            _logic?.PresentGameFrame(gameTime.TotalGameTime);
            base.Draw(gameTime);
        }

        private Texture2D? GetTexture(string path)
        {
            if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
                return null;
            if (_textures.TryGetValue(path, out var texture))
                return texture;

            using var stream = File.OpenRead(path);
            texture = Texture2D.FromStream(GraphicsDevice, stream);
            _textures[path] = texture;
            return texture;
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _spriteBatch?.Dispose();
                foreach (var texture in _textures.Values)
                    texture.Dispose();
                _textures.Clear();
            }
            base.Dispose(disposing);
        }
    }
}
