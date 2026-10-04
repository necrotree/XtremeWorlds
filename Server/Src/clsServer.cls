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
Attribute VB_Ext_KEY = "SavedWithClassBuilder6", "Yes"
Attribute VB_Ext_KEY = "Top_Level", "Yes"
Option Explicit
' Winsock SOCKET is UINT_PTR on both 32-bit and 64-bit builds.
Private Declare PtrSafe Function AcceptNativeSocket Lib "ws2_32" Alias "accept" (ByVal listener As LongPtr, ByRef address As WinDevLib.SOCKADDR_IN, ByRef addressLength As Long) As LongPtr
Public Sockets As colSockets
Private mListener As LongPtr
Private mStarted As Boolean
Private mPolling As Boolean
Private mConnections As Collection
Private mPort As Long
Private mHostAddress As String
Private mPublicAddressRequest As Object

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
    TryAutomaticPortForward
    BeginPublicAddressLookup
    Exit Sub
SocketFailed:
    code = WinDevLib.WSAGetLastError()
Failed:
    StopListening
    Err.Raise vbObjectError + 2100, "clsServer.StartListening", "Winsock startup/listen failed: " & CStr(code)
End Sub

Public Sub StopListening()
    Dim connection As clsNativeConnection
    If Not mPublicAddressRequest Is Nothing Then
        On Error Resume Next
        mPublicAddressRequest.Abort
        Set mPublicAddressRequest = Nothing
        On Error GoTo 0
    End If
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
    Dim errorNumber As Long, errorDescription As String
    If mListener = -1 Or mPolling Then Exit Sub
    On Error GoTo PollFailed
    mPolling = True
    
    For index = 1 To 32
        size = LenB(address)
        handle = AcceptNativeSocket(mListener, address, size)
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
PollFailed:
    errorNumber = Err.Number
    errorDescription = Err.Description
    ' A single connection failure must not terminate the timer or leave polling locked.
    On Error Resume Next
    If Not connection Is Nothing Then
        connection.Close
        If connection.UserData > 0 Then modServerTCP.CloseSocket connection.UserData
    End If
    AddLog "Socket poll error " & errorNumber & ": " & errorDescription, "network.log"
    mPolling = False
End Sub

Public Property Get LocalAddress() As String
    If Len(mHostAddress) = 0 Then mHostAddress = "Unavailable"
    LocalAddress = mHostAddress
End Property
Public Property Get LocalPort() As Long
    LocalPort = mPort
End Property

' Resolve once during startup; bounded synchronous COM avoids completion/event-pump stalls.
Private Sub BeginPublicAddressLookup()
    Dim response As String, octets() As String, i As Long
    On Error GoTo LookupFailed
    mHostAddress = "Unavailable"
    Set mPublicAddressRequest = CreateObject("WinHttp.WinHttpRequest.5.1")
    mPublicAddressRequest.SetTimeouts 1500, 1500, 1500, 3000
    mPublicAddressRequest.Open "GET", "https://api.ipify.org", False
    mPublicAddressRequest.Send
    If mPublicAddressRequest.Status <> 200 Then GoTo LookupFailed
    response = Trim$(mPublicAddressRequest.ResponseText)
    octets = Split(response, ".")
    If UBound(octets) <> 3 Then GoTo LookupFailed
    For i = 0 To 3
        If Len(octets(i)) < 1 Or Len(octets(i)) > 3 Then GoTo LookupFailed
        If octets(i) Like "*[!0-9]*" Then GoTo LookupFailed
        If CLng(octets(i)) > 255 Then GoTo LookupFailed
    Next i
    mHostAddress = response
    Set mPublicAddressRequest = Nothing
    Exit Sub
LookupFailed:
    On Error Resume Next
    AddLog "Public IP lookup failed; check internet access. " & Err.Description, "network.log"
    mHostAddress = "Unavailable"
    If Not mPublicAddressRequest Is Nothing Then mPublicAddressRequest.Abort
    Set mPublicAddressRequest = Nothing
End Sub
' UPnP is optional: failure must never prevent the server from listening.
Private Sub TryAutomaticPortForward()
    Dim nat As Object, mappings As Object, mapping As Object
    Dim adapters As Object, adapter As Object, addresses As Variant
    Dim address As Variant, localIP As String
    On Error GoTo ForwardFailed
    Set nat = CreateObject("HNetCfg.NATUPnP")
    Set mappings = nat.StaticPortMappingCollection
    If mappings Is Nothing Then
        AddLog "Automatic TCP port forwarding unavailable: router did not expose UPnP. Forward TCP " & mPort & " manually to this computer.", "network.log"
        Exit Sub
    End If
    Set adapters = GetObject("winmgmts:\\.\root\cimv2").ExecQuery("SELECT IPAddress, DefaultIPGateway FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
    For Each adapter In adapters
        If Not IsNull(adapter.DefaultIPGateway) And Not IsNull(adapter.IPAddress) Then
            addresses = adapter.IPAddress
            For Each address In addresses
                If InStr(CStr(address), ".") > 0 And Left$(CStr(address), 4) <> "169." Then
                    localIP = CStr(address)
                    Exit For
                End If
            Next address
        End If
        If Len(localIP) > 0 Then Exit For
    Next adapter
    If Len(localIP) = 0 Then Err.Raise 5, "Port forwarding", "No LAN IPv4 address with a default gateway."
    On Error Resume Next
    Set mapping = mappings.Item(mPort, "TCP")
    On Error GoTo ForwardFailed
    If Not mapping Is Nothing Then
        If mapping.InternalClient <> localIP Or mapping.InternalPort <> mPort Then
            AddLog "Automatic port forwarding skipped: TCP " & mPort & " already belongs to another destination.", "network.log"
            Exit Sub
        End If
        mapping.Enable True
    Else
        Set mapping = mappings.Add(mPort, "TCP", mPort, localIP, True, "XtremeWorlds")
    End If
    AddLog "Router forwards TCP " & mPort & " to " & localIP & ":" & mPort & ".", "network.log"
    Exit Sub
ForwardFailed:
    Dim message As String
    message = "Automatic port forwarding failed: " & Err.Number & " " & Err.Description
    On Error Resume Next
    AddLog message, "network.log"
End Sub