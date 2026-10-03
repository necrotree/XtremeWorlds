using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

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

    public bool IsRunning => _thread is { IsAlive: true };

    public void Start(int width = 1024, int height = 768)
    {
        if (IsRunning) return;
        _thread = new Thread(() =>
        {
            using var game = new FnaClientGame(_commands, width, height);
            _game = game;
            game.Run();
            _game = null;
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
        _game?.RequestExit();
        if (_thread is { IsAlive: true })
            _thread.Join(TimeSpan.FromSeconds(2));
        _thread = null;
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

        public FnaClientGame(ConcurrentQueue<FnaSpriteCommand> incoming, int width, int height)
        {
            _incoming = incoming;
            _graphics = new GraphicsDeviceManager(this)
            {
                PreferredBackBufferWidth = width,
                PreferredBackBufferHeight = height,
                SynchronizeWithVerticalRetrace = true
            };
            IsFixedTimeStep = false;
            Window.Title = "XtremeWorlds - FNA";
            IsMouseVisible = true;
        }

        public void RequestExit() => _exitRequested = true;

        protected override void LoadContent()
        {
            _spriteBatch = new SpriteBatch(GraphicsDevice);
            base.LoadContent();
        }

        protected override void Update(GameTime gameTime)
        {
            if (_exitRequested)
            {
                Exit();
                return;
            }

            _frame.Clear();
            while (_incoming.TryDequeue(out var command))
                _frame.Add(command);

            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(new Color(8, 12, 18));
            if (_spriteBatch is null)
                return;

            _spriteBatch.Begin(SpriteSortMode.FrontToBack, BlendState.AlphaBlend, SamplerState.PointClamp, null, null);
            foreach (var command in _frame)
            {
                var texture = GetTexture(command.TexturePath);
                if (texture is null) continue;
                _spriteBatch.Draw(texture, command.Destination, command.Source, command.Tint, 0f, Vector2.Zero, SpriteEffects.None, command.LayerDepth);
            }
            _spriteBatch.End();
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
