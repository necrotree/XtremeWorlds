using System;
using System.Diagnostics;
using System.Text;

namespace Server
{

    // Mirror's high-level networking API is Unity-specific. This host uses MirrorNetworking's
    // standalone Telepathy TCP transport, the TCP transport Mirror builds on.
    public sealed class MirrorTcpHost : IDisposable
    {

        private readonly int _port;
        private readonly Telepathy.Server _server;

        public event ConnectedEventHandler Connected;

        public delegate void ConnectedEventHandler(int connectionId, string address);
        public event DataReceivedEventHandler DataReceived;

        public delegate void DataReceivedEventHandler(int connectionId, ReadOnlyMemory<byte> payload);
        public event DisconnectedEventHandler Disconnected;

        public delegate void DisconnectedEventHandler(int connectionId);

        public MirrorTcpHost(int port, int maxMessageSize, bool tcpNoDelay)
        {
            _port = port;
            _server = new Telepathy.Server(maxMessageSize)
            {
                NoDelay = tcpNoDelay,
                SendQueueLimit = 10000,
                ReceiveQueueLimit = 10000
            };
            _server.OnConnected = new Action<int, string>((id, address) => Connected?.Invoke(id, address));
            _server.OnData = new Action<int, ArraySegment<byte>>((id, data) =>
    {
        var copy = new byte[data.Count];
        Buffer.BlockCopy(data.Array, data.Offset, copy, 0, data.Count);
        DataReceived?.Invoke(id, copy);
    });
            _server.OnDisconnected = new Action<int>((id) => Disconnected?.Invoke(id));
        }

        public void Start()
        {
            if (!_server.Start(_port))
                throw new InvalidOperationException("TCP host is already running.");
        }

        public void Tick(int processLimit = 1000)
        {
            _server.Tick(processLimit);
        }

        public bool Send(int connectionId, byte[] bytes)
        {
            return _server.Send(connectionId, new ArraySegment<byte>(bytes));
        }

        public bool SendText(int connectionId, string text)
        {
            return Send(connectionId, Encoding.UTF8.GetBytes(text));
        }

        public void Disconnect(int connectionId)
        {
            _server.Disconnect(connectionId);
        }

        public void Stop()
        {
            _server.Stop();
        }

        public void Dispose()
        {
            Debugger.Break();/* TODO ERROR: Skipped SkippedTokensTrivia
(*//* TODO ERROR: Skipped SkippedTokensTrivia
)*/
        }
    }
}