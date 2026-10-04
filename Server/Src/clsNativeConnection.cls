VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsNativeConnection"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
     Option Explicit
    Public UserData As Long
    Public RemoteAddress As clsNativeAddress
    Private mSocket As LongPtr
    Private Sub Class_Initialize()
        mSocket = -1
    End Sub
    Private mDisconnecting As Boolean
    Private mTracingFirstSend As Boolean
    Private mTracedFirstSend As Boolean
    Private mTracedFirstReceive As Boolean
    Private mReadEnabled As Boolean
    Private mOutput() As Byte
    Private mLength As Long
    Private mOffset As Long
    Private mShutdownAfterSend As Boolean

    Public Sub Attach(ByVal handle As LongPtr, ByRef address As WinDevLib.SOCKADDR_IN)
        Dim bytes(0 To 3) As Byte
        Dim nonblocking As Long = 1
        mDisconnecting = False
        mSocket = handle
        Set RemoteAddress = New clsNativeAddress
        ' Read the IPv4 bytes without passing a UDT to an untyped memory-copy API.
        Dim ipv4 As Long
        ipv4 = address.sin_addr.s_addr
        bytes(0) = ipv4 And &HFF&
        bytes(1) = (ipv4 And &HFF00&) \ &H100&
        bytes(2) = (ipv4 And &HFF0000) \ &H10000
        bytes(3) = ((ipv4 And &H7F000000) \ &H1000000)
        If ipv4 < 0 Then bytes(3) = bytes(3) Or &H80
        RemoteAddress.Address = CStr(bytes(0)) & "." & CStr(bytes(1)) & "." & CStr(bytes(2)) & "." & CStr(bytes(3))
        RemoteAddress.Port = WinDevLib.ws_ntohs(CLng(address.sin_port) And &HFFFF&) And &HFFFF&
        If WinDevLib.ws_ioctlsocket(mSocket, WinDevLib.FIONBIO, nonblocking) <> 0 Then
            Me.Close
        End If
    End Sub
    Public Property Get IsOpen() As Boolean
        IsOpen = (mSocket <> -1)
    End Property
    Public Sub RequestRead()
        mReadEnabled = True
    End Sub
    Public Sub BeginDisconnect()
        mDisconnecting = True
        mReadEnabled = False
    End Sub
    Public Sub Close()
        If mSocket <> -1 Then
            WinDevLib.ws_closesocket mSocket
            mSocket = -1
        End If
        mReadEnabled = False
        mLength = 0
        mOffset = 0
        Erase mOutput
    End Sub
    Public Sub Shutdown(ByVal how As Long)
        If mSocket <> -1 Then WinDevLib.ws_shutdown mSocket, how
    End Sub
    Private Sub PeerDisconnected()
        If mDisconnecting Then Exit Sub
        mDisconnecting = True
        ' Keep the slot attached for saving, but never send through the failed connection.
        On Error GoTo CleanupFailed
        If UserData > 0 Then modServerTCP.CloseSocket UserData
        Me.Close
        Exit Sub
CleanupFailed:
        Dim errorNumber As Long, errorDescription As String
        errorNumber = Err.Number
        errorDescription = Err.Description
        Me.Close
        On Error Resume Next
        AddLog "Disconnect cleanup for slot " & UserData & ": " & errorNumber & " " & errorDescription, "network.log"
    End Sub
    Public Sub Write(ByRef bytes() As Byte, Optional ByVal thenShutdown As Boolean)
        Dim count As Long
        If mSocket = -1 Or mDisconnecting Then Exit Sub
        If mTracingFirstSend Then Err.Raise 5, "Socket send", "Recursive first send for slot " & UserData
        count = UBound(bytes) - LBound(bytes) + 1
        If count = 0 Then Exit Sub
        ' Compact unsent bytes so repeated partial writes do not grow the queue forever.
        If mOffset > 0 Then
            WinDevLib.CopyMemory mOutput(0), mOutput(mOffset), mLength - mOffset
            mLength = mLength - mOffset
            mOffset = 0
        End If
        ReDim Preserve mOutput(0 To mLength + count - 1)
        WinDevLib.CopyMemory mOutput(mLength), bytes(LBound(bytes)), count
        mLength = mLength + count
        mShutdownAfterSend = mShutdownAfterSend Or thenShutdown
        If Not mTracedFirstSend Then
            mTracingFirstSend = True
            AddLog "First send begins, slot " & UserData & ", bytes " & mLength, "network.log"
        End If
        FlushOutput
        If mTracingFirstSend Then
            AddLog "First send completed, slot " & UserData, "network.log"
            mTracingFirstSend = False
            mTracedFirstSend = True
        End If
    End Sub
    Public Sub WriteString(ByVal data As String, Optional ByVal sendAsUNICODE As Boolean, Optional ByVal thenShutdown As Boolean)
        Dim bytes() As Byte
        If Len(data) = 0 Then Exit Sub
        If sendAsUNICODE Then
            bytes = data
        Else
            bytes = StrConv(data, vbFromUnicode)
        End If
        Write bytes, thenShutdown
    End Sub
    Private Sub FlushOutput()
        Dim count As Long
        If mDisconnecting Then Exit Sub
        Do While mSocket <> -1 And mOffset < mLength
            count = WinDevLib.ws_send(mSocket, mOutput(mOffset), mLength - mOffset, 0)
            If count < 0 Then
                If WinDevLib.WSAGetLastError() <> WinDevLib.WSAEWOULDBLOCK Then PeerDisconnected
                Exit Sub
            End If
            If count = 0 Then Exit Sub
            mOffset = mOffset + count
        Loop
        If mOffset = mLength Then
            mOffset = 0
            mLength = 0
            Erase mOutput
            If mShutdownAfterSend Then
                mShutdownAfterSend = False
                Shutdown WinDevLib.SD_SEND
            End If
        End If
    End Sub
    Public Sub Poll()
        Dim buffer(0 To 8191) As Byte
        Dim count As Long
        Dim batch As Long
        Dim received() As Byte, byteIndex As Long
        FlushOutput
        ' Bound work per tick so one busy client cannot monopolize the UI/game loop.
        For batch = 1 To 8
            If mSocket = -1 Or mDisconnecting Or Not mReadEnabled Then Exit Sub
            count = WinDevLib.ws_recv(mSocket, buffer(0), 8192, 0)
            If count = 0 Then
                PeerDisconnected
                Exit Sub
            ElseIf count < 0 Then
                If WinDevLib.WSAGetLastError() <> WinDevLib.WSAEWOULDBLOCK Then PeerDisconnected
                Exit Sub
            End If
            If Not mTracedFirstReceive Then AddLog "First receive, slot " & UserData & ", bytes " & count, "network.log"
            ReDim received(0 To count - 1)
            For byteIndex = 0 To count - 1
                received(byteIndex) = buffer(byteIndex)
            Next byteIndex
            modServerTCP.ReceiveClientBytes Me, received, Not mTracedFirstReceive
            If Not mTracedFirstReceive Then
                AddLog "First packet handled, slot " & UserData, "network.log"
                mTracedFirstReceive = True
            End If
        Next
    End Sub
    Private Sub Class_Terminate()
        Me.Close
    End Sub
