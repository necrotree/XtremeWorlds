using System.Collections.Concurrent;
using System.Threading;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace Eto.FNA;

/// <summary>A device-independent UI draw operation, using pixel coordinates.</summary>
public readonly record struct FnaUiQuad(Rectangle Bounds, Color Color);

/// <summary>An immutable frame passed from the Eto owner to the FNA owner.</summary>
public sealed class FnaUiFrame
{
    public static FnaUiFrame Empty { get; } = new(Array.Empty<FnaUiQuad>());
    public IReadOnlyList<FnaUiQuad> Quads { get; }

    public FnaUiFrame(IEnumerable<FnaUiQuad> quads)
    {
        Quads = Array.AsReadOnly(quads.ToArray());
    }
}

public enum FnaUiPointerKind { Move, Down, Up, Wheel }
public readonly record struct FnaUiPointerEvent(FnaUiPointerKind Kind, int X, int Y, int Button, int WheelDelta = 0);
public readonly record struct FnaUiKeyEvent(int KeyCode, bool Pressed, bool Repeat = false);

/// <summary>
/// A cross-thread mailbox between an Eto owner and an FNA game thread.
/// Eto controls and graphics objects are never shared between the threads.
/// </summary>
public sealed class FnaUiBridge
{
    private FnaUiFrame _current = FnaUiFrame.Empty;
    private readonly ConcurrentQueue<FnaUiPointerEvent> _pointer = new();
    private readonly ConcurrentQueue<FnaUiKeyEvent> _keys = new();
    private readonly ConcurrentQueue<string> _text = new();

    /// <summary>Publish from the Eto event thread after layout or control changes.</summary>
    public void Publish(FnaUiFrame frame) =>
        Interlocked.Exchange(ref _current, frame ?? throw new ArgumentNullException(nameof(frame)));

    /// <summary>Consume from the FNA render thread.</summary>
    public FnaUiFrame Snapshot() => Volatile.Read(ref _current);

    /// <summary>Post from the FNA Update loop.</summary>
    public void PostPointer(FnaUiPointerEvent value) => _pointer.Enqueue(value);
    public void PostKey(FnaUiKeyEvent value) => _keys.Enqueue(value);
    public void PostText(string value)
    {
        if (!string.IsNullOrEmpty(value)) _text.Enqueue(value);
    }

    /// <summary>Consume from Eto's UI event thread, never from FNA Draw.</summary>
    public bool TryReadPointer(out FnaUiPointerEvent value) => _pointer.TryDequeue(out value);
    public bool TryReadKey(out FnaUiKeyEvent value) => _keys.TryDequeue(out value);
    public bool TryReadText(out string value) => _text.TryDequeue(out value!);
}

/// <summary>
/// FNA-owned GPU resources. Construct, Draw and Dispose on the FNA thread.
/// Caller is responsible for SpriteBatch.Begin/End.
/// </summary>
public sealed class FnaUiRenderer : IDisposable
{
    private readonly Texture2D _whitePixel;
    private bool _disposed;

    public FnaUiRenderer(GraphicsDevice device)
    {
        ArgumentNullException.ThrowIfNull(device);
        _whitePixel = new Texture2D(device, 1, 1);
        _whitePixel.SetData(new[] { Color.White });
    }

    public void Draw(SpriteBatch batch, FnaUiFrame frame)
    {
        ObjectDisposedException.ThrowIf(_disposed, this);
        ArgumentNullException.ThrowIfNull(batch);
        ArgumentNullException.ThrowIfNull(frame);
        foreach (var quad in frame.Quads)
            if (quad.Bounds.Width > 0 && quad.Bounds.Height > 0)
                batch.Draw(_whitePixel, quad.Bounds, quad.Color);
    }

    public void Dispose()
    {
        if (_disposed) return;
        _disposed = true;
        _whitePixel.Dispose();
    }
}
