Imports System
Imports System.Text
Imports Telepathy

' Mirror's high-level networking API is Unity-specific. This host uses MirrorNetworking's
' standalone Telepathy TCP transport, the TCP transport Mirror builds on.
Public NotInheritable Class MirrorTcpHost
    Implements IDisposable

    Private ReadOnly _port As Integer
    Private ReadOnly _server As Telepathy.Server

    Public Event Connected(connectionId As Integer, address As String)
    Public Event DataReceived(connectionId As Integer, payload As ReadOnlyMemory(Of Byte))
    Public Event Disconnected(connectionId As Integer)

    Public Sub New(port As Integer, maxMessageSize As Integer, tcpNoDelay As Boolean)
        _port = port
        _server = New Telepathy.Server(maxMessageSize) With {
            .NoDelay = tcpNoDelay,
            .SendQueueLimit = 10000,
            .ReceiveQueueLimit = 10000
        }
        _server.OnConnected =
            Sub(id As Integer, address As String)
                RaiseEvent Connected(id, address)
            End Sub
        _server.OnData =
            Sub(id As Integer, data As ArraySegment(Of Byte))
                Dim copy(data.Count - 1) As Byte
                Buffer.BlockCopy(data.Array!, data.Offset, copy, 0, data.Count)
                RaiseEvent DataReceived(id, copy)
            End Sub
        _server.OnDisconnected =
            Sub(id As Integer)
                RaiseEvent Disconnected(id)
            End Sub
    End Sub

    Public Sub Start()
        If Not _server.Start(_port) Then Throw New InvalidOperationException("TCP host is already running.")
    End Sub

    Public Sub Tick(Optional processLimit As Integer = 1000)
        _server.Tick(processLimit)
    End Sub

    Public Function Send(connectionId As Integer, bytes As Byte()) As Boolean
        Return _server.Send(connectionId, New ArraySegment(Of Byte)(bytes))
    End Function

    Public Function SendText(connectionId As Integer, text As String) As Boolean
        Return Send(connectionId, Encoding.UTF8.GetBytes(text))
    End Function

    Public Sub Disconnect(connectionId As Integer)
        _server.Disconnect(connectionId)
    End Sub

    Public Sub Stop()
        _server.Stop()
    End Sub

    Public Sub Dispose() Implements IDisposable.Dispose
        Stop()
    End Sub
End Class
