using System;
using System.Collections.Concurrent;
using System.Linq;
using System.Text;
using Telepathy;

namespace XtremeWorlds.Client.Engine.Networking;

/// <summary>
/// Mirror's TCP transport layer for the converted client.  Mirror itself is
/// Unity-specific, while Telepathy is Mirror's standalone, raw C# TCP transport.
/// </summary>
public sealed class MirrorTcpClient : IDisposable
{
    private readonly Telepathy.Client _client;
    private readonly ConcurrentQueue<byte[]> _received = new();
    private bool _connected;

    public MirrorTcpClient(int maxMessageSize = 1024 * 1024)
    {
        _client = new Telepathy.Client(maxMessageSize)
        {
            NoDelay = true
        };
        _client.OnConnected = () =>
        {
            _connected = true;
            Connected?.Invoke(this, EventArgs.Empty);
        };
        _client.OnData = segment =>
        {
            var copy = segment.ToArray();
            _received.Enqueue(copy);
            DataReceived?.Invoke(this, new NetworkDataEventArgs(copy));
        };
        _client.OnDisconnected = () =>
        {
            _connected = false;
            Disconnected?.Invoke(this, EventArgs.Empty);
        };
    }

    public event EventHandler? Connected;
    public event EventHandler? Disconnected;
    public event EventHandler<NetworkDataEventArgs>? DataReceived;

    public bool IsConnected => _connected;

    public void Connect(string host, int port)
    {
        if (_connected)
            return;
        _client.Connect(host, port);
    }

    public bool ConnectAndWait(string host, int port, TimeSpan timeout)
    {
        Connect(host, port);
        var end = DateTime.UtcNow + timeout;
        while (!_connected && DateTime.UtcNow < end)
        {
            Tick();
            System.Threading.Thread.Sleep(5);
        }
        return _connected;
    }

    public void Send(ReadOnlySpan<byte> data)
    {
        if (!_connected || data.Length == 0)
            return;
        _client.Send(new ArraySegment<byte>(data.ToArray()));
    }

    public void SendText(string text)
    {
        Send(Encoding.UTF8.GetBytes(text ?? string.Empty));
    }

    public void Tick(int processLimit = 1000)
    {
        _client.Tick(processLimit);
    }

    public bool TryDequeue(out byte[] packet) => _received.TryDequeue(out packet!);

    public void Disconnect()
    {
        _client.Disconnect();
        _connected = false;
    }

    public void Dispose()
    {
        Disconnect();
    }
}

public sealed class NetworkDataEventArgs : EventArgs
{
    public NetworkDataEventArgs(byte[] data) => Data = data;
    public byte[] Data { get; }
}
