using System.Collections.Concurrent;
using XtremeWorlds.Client.Engine.Graphics;

namespace Client.Blazor.Services;

// SDL owns process-wide input/event state. Only one circuit may run its Game loop
// in this host; additional concurrent players require separate renderer workers.
public sealed class BrowserFnaRenderer : IDisposable
{
    private static readonly SemaphoreSlim lease = new(1, 1);
    private readonly FnaGraphicsService graphics = new();
    private readonly ConcurrentQueue<(string Action, object[] Args)> actions = new();
    private byte[]? frame;
    private string? failure;
    private bool ownsLease;
    private (string Name, int Level)? character;
    private readonly ConcurrentQueue<(string Channel, string Text)> chat = new();
    public byte[]? Frame => Volatile.Read(ref frame);
    public string? Failure => Volatile.Read(ref failure);

    public BrowserFnaRenderer()
    {
        graphics.Failed += (_, error) => Volatile.Write(ref failure, error.Message);
        graphics.Closed += (_, _) => actions.Enqueue(("Logout", []));
        graphics.MainGameActionRequested += (action, args) => actions.Enqueue((action, args));
    }

    public bool Start()
    {
        if (ownsLease) return true;
        if (!lease.Wait(0))
        {
            failure = "The renderer is in use. Please try again when the current game ends.";
            return false;
        }
        ownsLease = true;
        failure = null;
        graphics.Start(frameReady: bytes => Volatile.Write(ref frame, bytes));
        return true;
    }

    public bool TryAction(out (string Action, object[] Args) action) => actions.TryDequeue(out action);
    public void Click(int x, int y) { if (ownsLease && x is >= 0 and < 950 && y is >= 0 and < 700) graphics.BrowserClick(x, y); }
    public void Key(string key) { if (ownsLease && key.Length <= 16) graphics.BrowserKey(key); }
    public void Chat(string channel, string text) => chat.Enqueue((channel, text));
    public void Character(string name, int level) => character = (name, level);
    public void Update()
    {
        if (Frame is null) return;
        if (character is { } info)
        {
            // playerdata supplies a name and level, but no class or vitals.
            graphics.SetCharacterState("Unknown", info.Level, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            character = null;
        }
        while (chat.TryDequeue(out var line)) graphics.AddChatMessage(line.Channel, line.Text);
    }
    public void Stop()
    {
        graphics.Stop();
        frame = null;
        character = null;
        while (chat.TryDequeue(out _)) { }
        while (actions.TryDequeue(out _)) { }
        if (ownsLease) { ownsLease = false; lease.Release(); }
    }
    public void Dispose() { Stop(); graphics.Dispose(); }
}
