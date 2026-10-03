using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using Telepathy;

if (args.Length > 0 && args[0] == "--probe")
{
    var probe = new Client(1024 * 1024);
    bool connected = false;
    probe.OnConnected = () => { connected = true; Console.WriteLine("CONNECTED"); };
    probe.OnDisconnected = () => Console.WriteLine("DISCONNECTED");
    probe.OnData = data => Console.WriteLine("DATA bytes=" + data.Count);
    probe.Connect("127.0.0.1", 7234);
    var end = DateTime.UtcNow.AddSeconds(5);
    while (DateTime.UtcNow < end) { probe.Tick(100); Thread.Sleep(10); }
    Console.WriteLine("Live socket connected=" + probe.Connected);
    probe.Disconnect();
    if (!connected) throw new Exception("Local server connection failed.");
    return;
}

Log.Info = _ => { };
Log.Warning = _ => { };
Log.Error = _ => { };
// Deterministically reproduce a disconnect before either worker gets its stream.
for (int i = 0; i < 100; i++)
{
    using var client = new TcpClient();
    using var pending = new ManualResetEvent(true);
    ThreadFunctions.SendLoop(0, client, new MagnificentSendPipe(1024), pending);
    ThreadFunctions.ReceiveLoop(0, client, 1024, new MagnificentReceivePipe(1024), 100);
}
// Exercise real connection setup followed by an immediate peer disconnect.
var listener = new TcpListener(IPAddress.Loopback, 0);
listener.Start();
int port = ((IPEndPoint)listener.LocalEndpoint).Port;
for (int i = 0; i < 100; i++)
{
    var client = new Client(1024);
    int disconnected = 0;
    client.OnDisconnected = () => disconnected++;
    client.Connect("127.0.0.1", port);
    using var peer = listener.AcceptTcpClient();
    peer.Close();
    var deadline = DateTime.UtcNow.AddSeconds(2);
    while (disconnected == 0 && DateTime.UtcNow < deadline)
    {
        client.Tick(100);
        Thread.Sleep(1);
    }
    client.Disconnect();
    if (disconnected == 0) throw new Exception("Expected a disconnect event.");
}
listener.Stop();
Console.WriteLine("PASS: closed-socket worker startup and 100 immediate peer disconnects.");
