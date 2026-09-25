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
    Private mReadEnabled As Boolean
    Private mOutput() As Byte
    Private mLength As Long
    Private mOffset As Long
    Private mShutdownAfterSend As Boolean

    Public Sub Attach(ByVal handle As LongPtr, ByRef address As WinDevLib.SOCKADDR_IN)
        Dim bytes(0 To 3) As Byte
        Dim nonblocking As Long = 1
        mSocket = handle
        Set RemoteAddress = New clsNativeAddress
        WinDevLib.CopyMemory bytes(0), address.sin_addr, 4
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
        ' Let the game save the player before releasing its connection wrapper.
        If UserData > 0 Then modServerTCP.CloseSocket UserData
        Me.Close
    End Sub
    Public Sub Write(ByRef bytes() As Byte, Optional ByVal thenShutdown As Boolean)
        Dim count As Long
        If mSocket = -1 Then Exit Sub
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
        FlushOutput
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
        Dim packet As clsNativePacket
        FlushOutput
        ' Bound work per tick so one busy client cannot monopolize the UI/game loop.
        For batch = 1 To 8
            If mSocket = -1 Or Not mReadEnabled Then Exit Sub
            count = WinDevLib.ws_recv(mSocket, buffer(0), 8192, 0)
            If count = 0 Then
                PeerDisconnected
                Exit Sub
            ElseIf count < 0 Then
                If WinDevLib.WSAGetLastError() <> WinDevLib.WSAEWOULDBLOCK Then PeerDisconnected
                Exit Sub
            End If
            Set packet = New clsNativePacket
            packet.Assign buffer, count
            modServerTCP.IncomingData Me, packet
        Next
    End Sub
    Private Sub Class_Terminate()
        Me.Close
    End Sub
