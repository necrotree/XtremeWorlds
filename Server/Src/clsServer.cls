VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsServer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit
Public Sockets As colSockets
Private mListener As LongPtr
Private mStarted As Boolean
Private mPolling As Boolean
Private mConnections As Collection
Private mPort As Long

Private Sub Class_Initialize()
    mListener = -1
    Set Sockets = New colSockets
    Set mConnections = New Collection
End Sub
Private Sub Class_Terminate()
    StopListening
    Set Sockets = Nothing
End Sub
Public Sub StartListening()
    Dim startup As WinDevLib.WSADATA
    Dim address As WinDevLib.SOCKADDR_IN
    Dim nonblocking As Long
    Dim code As Long
    StopListening
    If GAME_PORT < 1 Or GAME_PORT > 65535 Then Err.Raise 5, "clsServer", "Invalid server TCP port."
    code = WinDevLib.WSAStartup(&H202, startup)
    If code <> 0 Then GoTo Failed
    mStarted = True
    mListener = WinDevLib.ws_socket(WinDevLib.AF_INET, WinDevLib.SOCK_STREAM, WinDevLib.IPPROTO_TCP)
    If mListener = -1 Then GoTo SocketFailed
    nonblocking = 1
    If WinDevLib.ws_ioctlsocket(mListener, WinDevLib.FIONBIO, nonblocking) <> 0 Then GoTo SocketFailed
    address.sin_family = WinDevLib.AF_INET
    address.sin_port = WinDevLib.ws_htons(GAME_PORT)
    ' Zero-initialized sin_addr binds all local IPv4 interfaces.
    If WinDevLib.ws_bind(mListener, address, LenB(address)) <> 0 Then GoTo SocketFailed
    If WinDevLib.ws_listen(mListener, WinDevLib.SOMAXCONN) <> 0 Then GoTo SocketFailed
    mPort = GAME_PORT
    Exit Sub
SocketFailed:
    code = WinDevLib.WSAGetLastError()
Failed:
    StopListening
    Err.Raise vbObjectError + 2100, "clsServer.StartListening", "Winsock startup/listen failed: " & CStr(code)
End Sub
Public Sub StopListening()
    Dim connection As clsNativeConnection
    If mListener <> -1 Then
        WinDevLib.ws_closesocket mListener
        mListener = -1
    End If
    If Not mConnections Is Nothing Then
        For Each connection In mConnections
            connection.Close
        Next
    End If
    Set mConnections = New Collection
    If mStarted Then
        WinDevLib.WSACleanup
        mStarted = False
    End If
End Sub
Public Sub Poll()
    Dim address As WinDevLib.SOCKADDR_IN
    Dim size As Long
    Dim handle As LongPtr
    Dim connection As clsNativeConnection
    Dim index As Long
    Dim code As Long
    If mListener = -1 Or mPolling Then Exit Sub
    mPolling = True
    On Error GoTo Failed
    For index = 1 To 32
        size = LenB(address)
        handle = WinDevLib.ws_accept(mListener, address, size)
        If handle = -1 Then
            code = WinDevLib.WSAGetLastError()
            If code <> WinDevLib.WSAEWOULDBLOCK Then Err.Raise vbObjectError + 2101, "clsServer.Poll", "Winsock accept failed: " & CStr(code)
            Exit For
        End If
        Set connection = New clsNativeConnection
        connection.Attach handle, address
        If connection.IsOpen Then
            mConnections.Add connection
            AcceptConnection connection
        End If
    Next
    For index = mConnections.Count To 1 Step -1
        Set connection = mConnections(index)
        connection.Poll
        If Not connection.IsOpen Then mConnections.Remove index
    Next
    mPolling = False
    Exit Sub
Failed:
    mPolling = False
    Err.Raise Err.Number, Err.Source, Err.Description
End Sub
Public Property Get LocalAddress() As String
    LocalAddress = "0.0.0.0"
End Property
Public Property Get LocalPort() As Long
    LocalPort = mPort
End Property
