namespace XtremeWorlds.Networking;

/// <summary>Preserves TCP packet order across asynchronous handlers without blocking other connections.</summary>
public sealed class OrderedPacketQueue : IDisposable
{
    private readonly object _gate = new();
    private readonly int _limit;
    private readonly Action<Exception>? _error;
    private Task _tail = Task.CompletedTask;
    private int _pending;
    private bool _disposed;
    public OrderedPacketQueue(int limit = 256, Action<Exception>? error = null) { _limit = Math.Max(1, limit); _error = error; }
    public Task Completion { get { lock (_gate) return _tail; } }
    public bool TryEnqueue(Func<Task> action)
    {
        lock (_gate)
        {
            if (_disposed || _pending >= _limit) return false;
            _pending++;
            _tail = RunAsync(_tail, action);
            return true;
        }
    }
    private async Task RunAsync(Task previous, Func<Task> action)
    {
        try
        {
            await previous.ConfigureAwait(false);
            lock (_gate) if (_disposed) return;
            await action().ConfigureAwait(false);
        }
        catch (Exception ex) { _error?.Invoke(ex); }
        finally { lock (_gate) _pending--; }
    }
    public void Dispose() { lock (_gate) _disposed = true; }
}
