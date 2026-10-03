Imports System
Imports System.Collections.Concurrent
Imports System.Diagnostics
Imports System.Threading
Imports System.Threading.Tasks

Public NotInheritable Class ServerHost
    Implements IDisposable

    Private ReadOnly _settings As ServerSettings
    Private ReadOnly _network As MirrorTcpHost
    Private ReadOnly _database As SpacetimeRepository
    Private ReadOnly _sessions As New ConcurrentDictionary(Of Integer, PlayerSession)()
    Private ReadOnly _router As PacketRouter
    Private ReadOnly _stop As New CancellationTokenSource()

    Public Sub New(settings As ServerSettings)
        _settings = settings
        _database = New SpacetimeRepository(settings)
        _network = New MirrorTcpHost(settings.Port, settings.MaxMessageSize, settings.TcpNoDelay)
        _router = New PacketRouter(settings, _network, _database, _sessions)

        AddHandler _network.Connected, AddressOf OnConnected
        AddHandler _network.DataReceived, AddressOf OnData
        AddHandler _network.Disconnected, AddressOf OnDisconnected
    End Sub

    Public Async Function RunAsync(externalToken As CancellationToken) As Task
        Console.WriteLine($"{_settings.GameName} starting on TCP {_settings.Port}...")
        Console.WriteLine($"SpacetimeDB: {_settings.SpacetimeUri} / {_settings.SpacetimeDatabase}")
        Await _database.PingAsync(externalToken)
        _network.Start()
        Console.WriteLine($"Mirror Telepathy TCP host active. TCPNoDelay={_settings.TcpNoDelay}")

        Dim tickLength = TimeSpan.FromSeconds(1.0 / Math.Max(1, _settings.TickRate))
        Dim sw As New Stopwatch()
        While Not _stop.IsCancellationRequested AndAlso Not externalToken.IsCancellationRequested
            sw.Restart()
            _network.Tick(1000)
            _router.Tick()
            Dim delay = tickLength - sw.Elapsed
            If delay > TimeSpan.Zero Then
                Await Task.Delay(delay, _stop.Token).ConfigureAwait(False)
            End If
        End While

        _network.Stop()
        Console.WriteLine("Server stopped.")
    End Function

    Public Sub RequestStop()
        If Not _stop.IsCancellationRequested Then _stop.Cancel()
    End Sub

    Private Sub OnConnected(connectionId As Integer, address As String)
        If _sessions.Count >= _settings.MaxPlayers Then
            _network.SendText(connectionId, PacketCodec.Compose("alertmsg", "Server is full."))
            _network.Disconnect(connectionId)
            Return
        End If
        _sessions(connectionId) = New PlayerSession With {.ConnectionId = connectionId, .IpAddress = address}
        Console.WriteLine($"[{connectionId}] connected from {address}")
    End Sub

    Private Sub OnData(connectionId As Integer, payload As ReadOnlyMemory(Of Byte))
        Dim text = PacketCodec.Decode(payload.Span)
        _ = _router.HandleAsync(connectionId, text)
    End Sub

    Private Sub OnDisconnected(connectionId As Integer)
        Dim session As PlayerSession = Nothing
        _sessions.TryRemove(connectionId, session)
        Console.WriteLine($"[{connectionId}] disconnected")
    End Sub

    Public Sub Dispose() Implements IDisposable.Dispose
        _network.Dispose()
        _database.Dispose()
        _stop.Dispose()
    End Sub
End Class
