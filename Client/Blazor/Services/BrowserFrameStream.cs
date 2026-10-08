using System.Threading.Channels;
using System.Collections.Concurrent;
using System.Net.WebSockets;

namespace Client.Blazor.Services;

/// <summary>Streams the latest FNA frame independently of the interactive Blazor circuit.</summary>
public static class BrowserFrameStream
{
    private sealed record Source(Func<byte[]?> Frame, Action<Action<byte[]>> Subscribe, Action<Action<byte[]>> Unsubscribe, Action Keyframe, CancellationToken Stopped);
    private static readonly ConcurrentDictionary<string, Source> Sources = new();
    public static string Register(Func<byte[]?> frame, Action<Action<byte[]>> subscribe, Action<Action<byte[]>> unsubscribe, Action keyframe, CancellationToken stopped)
    {
        string id = Guid.NewGuid().ToString("N");
        Sources[id] = new(frame, subscribe, unsubscribe, keyframe, stopped);
        return id;
    }
    public static void Remove(string? id) { if (id != null) Sources.TryRemove(id, out _); }
    public static async Task ServeAsync(HttpContext context, string id)
    {
        if (!Sources.TryGetValue(id, out var source)) { context.Response.StatusCode = 404; return; }
        if (!context.WebSockets.IsWebSocketRequest) { context.Response.StatusCode = 400; return; }
        using var socket = await context.WebSockets.AcceptWebSocketAsync();
        using var cancellation = CancellationTokenSource.CreateLinkedTokenSource(context.RequestAborted, source.Stopped);
        var frames = Channel.CreateBounded<byte[]>(new BoundedChannelOptions(1) {
            FullMode = BoundedChannelFullMode.Wait, SingleReader = false, SingleWriter = false,
            AllowSynchronousContinuations = false
        });
        bool needsKeyframe = true;
        void OnFrame(byte[] frame)
        {
            bool full = frame[0] == 137;
            if (needsKeyframe && !full) return;
            // Never drop a patch: the next full frame must repair any skipped changes.
            if (!full && !frames.Writer.TryWrite(frame)) { needsKeyframe = true; source.Keyframe(); return; }
            if (full) { while (frames.Reader.TryRead(out _)) { } frames.Writer.TryWrite(frame); needsKeyframe = false; }
        }
        source.Subscribe(OnFrame);
        source.Keyframe();
        byte[]? previous = null;
        // Observe browser closure even when the renderer has not produced another frame.
        var receive = ReceiveUntilClosedAsync(socket, cancellation, source.Keyframe);
        try
        {
            await foreach (var frame in frames.Reader.ReadAllAsync(cancellation.Token))
            {
                if (ReferenceEquals(frame, previous)) continue;
                await socket.SendAsync(frame, WebSocketMessageType.Binary, true, cancellation.Token);
                previous = frame;
            }
        }
        catch (OperationCanceledException) { }
        catch (WebSocketException) { }
        finally { source.Unsubscribe(OnFrame); frames.Writer.TryComplete(); cancellation.Cancel(); socket.Abort(); await receive; }
    }
    private static async Task ReceiveUntilClosedAsync(WebSocket socket, CancellationTokenSource cancellation, Action keyframe)
    {
        try
        {
            var buffer = new byte[64];
            while (!cancellation.IsCancellationRequested)
            {
                var message = await socket.ReceiveAsync(buffer, cancellation.Token);
                if (message.MessageType == WebSocketMessageType.Close) break;
                if (message.MessageType == WebSocketMessageType.Text) keyframe();
            }
        }
        catch (WebSocketException) { }
        catch (OperationCanceledException) { }
        finally { cancellation.Cancel(); }
    }
}
