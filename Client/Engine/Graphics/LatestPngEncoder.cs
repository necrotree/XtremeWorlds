using System.Buffers;
using System.Buffers.Binary;
using System.Diagnostics;
using System.IO.Compression;

namespace XtremeWorlds.Client.Engine.Graphics;

/// <summary>Compresses captured RGBA pixels off the game thread, retaining at most one pending capture.</summary>
public sealed class LatestPngEncoder : IDisposable
{
    private readonly object _gate = new();
    private readonly int _width, _height;
    private readonly Action<byte[]> _ready;
    private readonly CancellationTokenSource _stop = new();
    private readonly SemaphoreSlim _signal = new(0, 1);
    private readonly Task _worker;
    private byte[]? _pending;
    private bool _disposed;
    private byte[]? _previous;
    private int _forceKeyframe = 1;
    public void RequestKeyframe() => Interlocked.Exchange(ref _forceKeyframe, 1);
    private double _lastEncodeMilliseconds;
    public double LastEncodeMilliseconds => Volatile.Read(ref _lastEncodeMilliseconds);
    public LatestPngEncoder(int width, int height, Action<byte[]> ready)
    {
        if (width <= 0 || height <= 0) throw new ArgumentOutOfRangeException(nameof(width));
        _width = width; _height = height; _ready = ready;
        _worker = Task.Run(RunAsync);
    }
    // Takes ownership of a buffer rented from ArrayPool<byte>.Shared.
    public void Submit(byte[] pixels)
    {
        lock (_gate)
        {
            if (_disposed) { ArrayPool<byte>.Shared.Return(pixels); return; }
            if (_pending != null) ArrayPool<byte>.Shared.Return(_pending);
            _pending = pixels;
            if (_signal.CurrentCount == 0) _signal.Release();
        }
    }
    private async Task RunAsync()
    {
        try
        {
            while (true)
            {
                await _signal.WaitAsync(_stop.Token);
                byte[]? pixels;
                lock (_gate) { pixels = _pending; _pending = null; }
                if (pixels == null) continue;
                try
                {
                    long started = Stopwatch.GetTimestamp();
                    byte[]? png = EncodeChanged(pixels);
                    Volatile.Write(ref _lastEncodeMilliseconds, Stopwatch.GetElapsedTime(started).TotalMilliseconds);
                    if (png != null && !_stop.IsCancellationRequested) _ready(png);
                }
                finally { ArrayPool<byte>.Shared.Return(pixels); }
            }
        }
        catch (OperationCanceledException) when (_stop.IsCancellationRequested) { }
    }
    private byte[]? EncodeChanged(byte[] pixels)
    {
        int count = checked(_width * _height * 4);
        bool full = Interlocked.Exchange(ref _forceKeyframe, 0) != 0 || _previous == null;
        int minX = _width, minY = _height, maxX = -1, maxY = -1;
        if (!full)
        {
            var current = System.Runtime.InteropServices.MemoryMarshal.Cast<byte, uint>(pixels.AsSpan(0, count));
            var previous = System.Runtime.InteropServices.MemoryMarshal.Cast<byte, uint>(_previous!.AsSpan(0, count));
            for (int y = 0; y < _height; y++)
                for (int x = 0; x < _width; x++)
                    if (current[y * _width + x] != previous[y * _width + x])
                    {
                        minX = Math.Min(minX, x); maxX = Math.Max(maxX, x);
                        minY = Math.Min(minY, y); maxY = Math.Max(maxY, y);
                    }
            if (maxX < 0) return null;
        }
        _previous ??= new byte[count];
        pixels.AsSpan(0, count).CopyTo(_previous);
        if (full || (maxX - minX + 1) * (maxY - minY + 1) > _width * _height / 2)
            return Encode(pixels.AsSpan(0, count), _width, _height);
        int width = maxX - minX + 1, height = maxY - minY + 1;
        byte[] rectangle = ArrayPool<byte>.Shared.Rent(width * height * 4);
        try
        {
            for (int y = 0; y < height; y++)
                pixels.AsSpan(((minY + y) * _width + minX) * 4, width * 4).CopyTo(rectangle.AsSpan(y * width * 4));
            byte[] png = Encode(rectangle.AsSpan(0, width * height * 4), width, height);
            byte[] patch = new byte[png.Length + 12];
            "XWP1"u8.CopyTo(patch);
            BinaryPrimitives.WriteInt32BigEndian(patch.AsSpan(4), minX);
            BinaryPrimitives.WriteInt32BigEndian(patch.AsSpan(8), minY);
            png.CopyTo(patch, 12);
            return patch;
        }
        finally { ArrayPool<byte>.Shared.Return(rectangle); }
    }
    public static byte[] Encode(ReadOnlySpan<byte> pixels, int width, int height)
    {
        int stride = checked(width * 4);
        if (width <= 0 || height <= 0 || pixels.Length != checked(stride * height)) throw new ArgumentException("Invalid RGBA capture.");
        using var output = new MemoryStream();
        output.Write(new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 });
        Span<byte> header = stackalloc byte[13];
        BinaryPrimitives.WriteInt32BigEndian(header, width); BinaryPrimitives.WriteInt32BigEndian(header[4..], height);
        header[8] = 8; header[9] = 6; header[10] = header[11] = header[12] = 0;
        Chunk(output, "IHDR"u8, header);
        using var compressed = new MemoryStream();
        byte[] row = ArrayPool<byte>.Shared.Rent(stride + 1);
        try
        {
            using (var zlib = new ZLibStream(compressed, CompressionLevel.Fastest, true))
                for (int y = 0; y < height; y++)
                {
                    row[0] = 1; // PNG Sub filter improves texture compression without an expensive filter search.
                    var source = pixels.Slice(y * stride, stride);
                    for (int x = 0; x < stride; x++)
                        row[x + 1] = unchecked((byte)(source[x] - (x >= 4 ? source[x - 4] : 0)));
                    zlib.Write(row, 0, stride + 1);
                }
        }
        finally { ArrayPool<byte>.Shared.Return(row); }
        Chunk(output, "IDAT"u8, compressed.GetBuffer().AsSpan(0, (int)compressed.Length));
        Chunk(output, "IEND"u8, ReadOnlySpan<byte>.Empty);
        return output.ToArray();
    }
    private static void Chunk(Stream output, ReadOnlySpan<byte> type, ReadOnlySpan<byte> data)
    {
        Span<byte> number = stackalloc byte[4];
        BinaryPrimitives.WriteInt32BigEndian(number, data.Length);
        output.Write(number); output.Write(type); output.Write(data);
        uint crc = uint.MaxValue;
        foreach (byte value in type) crc = CrcTable[(crc ^ value) & 255] ^ (crc >> 8);
        foreach (byte value in data) crc = CrcTable[(crc ^ value) & 255] ^ (crc >> 8);
        BinaryPrimitives.WriteUInt32BigEndian(number, ~crc); output.Write(number);
    }
    private static readonly uint[] CrcTable = BuildCrcTable();
    private static uint[] BuildCrcTable()
    {
        var table = new uint[256];
        for (uint i = 0; i < 256; i++)
        {
            uint value = i;
            for (int bit = 0; bit < 8; bit++) value = (value & 1) != 0 ? 0xedb88320U ^ (value >> 1) : value >> 1;
            table[i] = value;
        }
        return table;
    }
    public void Dispose()
    {
        lock (_gate)
        {
            if (_disposed) return;
            _disposed = true; _stop.Cancel();
            if (_pending != null) { ArrayPool<byte>.Shared.Return(_pending); _pending = null; }
        }
        _worker.GetAwaiter().GetResult();
        _signal.Dispose(); _stop.Dispose();
    }
}
