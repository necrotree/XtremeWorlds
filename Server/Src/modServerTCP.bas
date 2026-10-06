Attribute VB_Name = "modServerTCP"
Option Explicit
Public GameServer As clsServer

Private Declare Function GetCurrentProcess Lib "kernel32" () As LongPtr
Private Declare Function GetProcessTimes Lib "kernel32" (ByVal hProcess As LongPtr, ByRef CreationTime As Currency, ByRef ExitTime As Currency, ByRef KernelTime As Currency, ByRef UserTime As Currency) As Long
Private CaptionSampleTime As Double
Private CaptionCPUTime As Currency
Private CaptionSampleReady As Boolean
Private ServerLoadPercent As Long

Sub UpdateCaption()
    Dim Address As String
    Dim Online As Long
    Address = "0.0.0.0"
    If Not GameServer Is Nothing Then
        Address = GameServer.LocalAddress
        frmServer.txtPort.Text = CStr(GameServer.LocalPort)
    End If
    Online = TotalOnlinePlayers
    frmServer.Caption = GAME_NAME & " :: Server | IP: " & Address & " | Players: " & CStr(Online)
    frmServer.txtIP.Text = Address
    frmServer.txtOnline.Text = CStr(Online)
End Sub

Public Sub UpdateServerLoad()
    Dim SampleTime As Double
    Dim Elapsed As Double
    Dim CreationTime As Currency, ExitTime As Currency
    Dim KernelTime As Currency, UserTime As Currency
    Dim CPUTime As Currency
    SampleTime = Timer
    Elapsed = SampleTime - CaptionSampleTime
    If Elapsed < 0 Then Elapsed = Elapsed + 86400#
    If CaptionSampleReady And Elapsed < 1# Then Exit Sub
    If GetProcessTimes(GetCurrentProcess(), CreationTime, ExitTime, KernelTime, UserTime) = 0 Then Exit Sub
    ' FILETIME uses 100 ns units; Currency scales these to milliseconds.
    ' 100% means one CPU core is fully occupied by this server process.
    CPUTime = KernelTime + UserTime
    If CaptionSampleReady And Elapsed > 0 Then
        ServerLoadPercent = CLng((CPUTime - CaptionCPUTime) / (Elapsed * 10#))
        If ServerLoadPercent < 0 Then ServerLoadPercent = 0
        If ServerLoadPercent > 100 Then ServerLoadPercent = 100
    End If
    CaptionCPUTime = CPUTime
    CaptionSampleTime = SampleTime
    CaptionSampleReady = True
    Call UpdateCaption
End Sub

Function IsConnected(ByVal Index As Long) As Boolean
' If frmServer.Socket(index).State = sckConnected Then
' IsConnected = True
' Else
' IsConnected = False
' End If

    IsConnected = False
    If Index = 0 Then Exit Function
    If GameServer Is Nothing Then Exit Function
    If Not GameServer.Sockets(Index).Socket Is Nothing Then
        IsConnected = True
    End If

End Function

Function IsPlaying(ByVal Index As Long) As Boolean
    If IsConnected(Index) And Player(Index).InGame = True Then
        IsPlaying = True
    Else
        IsPlaying = False
    End If
End Function

Function IsLoggedIn(ByVal Index As Long) As Boolean
    If IsConnected(Index) And Trim$(Player(Index).Login) <> "" Then
        IsLoggedIn = True
    Else
        IsLoggedIn = False
    End If
End Function

Function IsMultiAccounts(ByVal Login As String) As Boolean
    Dim I As Long

    IsMultiAccounts = False
    For I = 1 To HighIndex
        If IsConnected(I) And LCase$(Trim$(Player(I).Login)) = LCase$(Trim$(Login)) Then
            IsMultiAccounts = True
            Exit Function
        End If
    Next I
End Function

Function IsMultiIPOnline(ByVal IP As String) As Boolean
    Dim I As Long
    Dim N As Long

    N = 0
    IsMultiIPOnline = False
    For I = 1 To HighIndex
' If IsConnected(I) And Trim$(GetPlayerIP(I)) = Trim$(IP) Then
' n = n + 1
'
' If (n > 1) Then
' IsMultiIPOnline = True
' Exit Function
' End If
' End If

        If IsConnected(I) Then
            If Trim$(GetPlayerIP(I)) = Trim$(IP) Then
                N = N + 1

                If (N > 1) Then
                    IsMultiIPOnline = True
                    Exit Function
                End If
            End If
        End If

    Next I
End Function

Function IsBanned(ByVal IP As String) As Boolean

    Dim FileName As String, fIP As String, fName As String
    Dim f As Long
    ' Dim b As Integer
    Dim BIp As String
    Dim I As Integer

    IsBanned = False

    FileName = App.Path & "\banlist.ini"

    For I = 0 To MAX_BANS
        If Len(Ban(I).BannedIP) > 0 Then
            BIp = Ban(I).BannedIP
            If IP = BIp Then
                IsBanned = True
                Exit Function
            Else
                IsBanned = False
            End If
        End If
    Next I

End Function

Function IsBannedHD(ByVal HD As String) As Boolean

    Dim FileName As String
    Dim bHD As String
    Dim I As Integer

    IsBannedHD = False

    FileName = App.Path & "\banlist.ini"

    For I = 0 To MAX_BANS
        If Ban(I).BannedHD <> "" Then
            bHD = Ban(I).BannedHD
            If HD = bHD Then
                IsBannedHD = True
                Exit Function
            Else
                IsBannedHD = False
            End If
        End If
    Next I

End Function

Sub SendDataTo(ByVal Index As Long, ByVal Data As String)
    Dim I As Long, N As Long, startc As Long
    Dim dbytes() As Byte

' If IsConnected(index) Then
' frmServer.Socket(index).SendData Data
' DoEvents
' End If

    ' Call Encryption_XOR_EncryptString(Data, ENC_KEY)
    dbytes = StrConv(Data, vbFromUnicode)
    If IsConnected(Index) Then
        GameServer.Sockets(Index).WriteBytes dbytes
    End If

End Sub

Sub SendDataToAll(ByVal Data As String)
    Dim I As Long

    For I = 1 To HighIndex
        If IsPlaying(I) Then
            Call SendDataTo(I, Data)
        End If
    Next I
End Sub

Sub SendDataToAllBut(ByVal Index As Long, ByVal Data As String)
    Dim I As Long

    For I = 1 To HighIndex
        If IsPlaying(I) And I <> Index Then
            Call SendDataTo(I, Data)
        End If
    Next I
End Sub

Sub SendDataToMap(ByVal MapNum As Long, ByVal Data As String)
    Dim I As Long

    For I = 1 To HighIndex
        If IsPlaying(I) Then
            If GetPlayerMap(I) = MapNum Then
                Call SendDataTo(I, Data)
            End If
        End If
    Next I
End Sub

Sub SendDataToMapBut(ByVal Index As Long, ByVal MapNum As Long, ByVal Data As String)
    Dim I As Long

    For I = 1 To HighIndex
        If IsPlaying(I) Then
            If GetPlayerMap(I) = MapNum And I <> Index Then
                Call SendDataTo(I, Data)
            End If
        End If
    Next I
End Sub

Sub GlobalMsg(ByVal Msg As String, ByVal Color As Byte)
    Dim Packet As String

    Packet = "GLOBALMSG" & SEP_CHAR & Msg & SEP_CHAR & Color & END_CHAR

    Call SendDataToAll(Packet)
End Sub

Sub AdminMsg(ByVal Msg As String, ByVal Color As Byte)
    Dim Packet As String
    Dim I As Long

    Packet = "ADMINMSG" & SEP_CHAR & Msg & SEP_CHAR & Color & END_CHAR
    For I = 1 To HighIndex
        If IsPlaying(I) And GetPlayerAccess(I) > 0 Then
            Call SendDataTo(I, Packet)
        End If
    Next I
End Sub

Sub PlayerMsg(ByVal Index As Long, ByVal Msg As String, ByVal Color As Byte)
    Dim Packet As String

    Packet = "PLAYERMSG" & SEP_CHAR & Msg & SEP_CHAR & Color & END_CHAR

    Call SendDataTo(Index, Packet)
End Sub

Sub MapMsg(ByVal MapNum As Long, ByVal Msg As String, ByVal Color As Byte)
    Dim Packet As String
    Dim Text As String

    Packet = "MAPMSG" & SEP_CHAR & Msg & SEP_CHAR & Color & END_CHAR

    Call SendDataToMap(MapNum, Packet)
End Sub

Sub AlertMsg(ByVal Index As Long, ByVal Msg As String)
    Dim Packet As String

    Packet = "ALERTMSG" & SEP_CHAR & Msg & END_CHAR

    Call SendDataTo(Index, Packet)
    Call CloseSocket(Index)
End Sub

Sub HackingAttempt(ByVal Index As Long, ByVal Reason As String)
    If Index > 0 Then
        If IsPlaying(Index) Then
            Call GlobalMsg(GetPlayerLogin(Index) & "/" & GetPlayerName(Index) & " has been booted for (" & Reason & ")", White)
        End If

        AddLog "Player " & Index & " rejected: " & Reason, "network.log"
        Call AlertMsg(Index, "You have been booted from " & GAME_NAME & ". Reason: " & Reason & ".")
    End If
End Sub

Sub AcceptConnection(ByVal Socket As clsNativeConnection)
    Dim I As Long

    AddLog "AcceptConnection: finding player slot", "network.log"
    I = FindOpenPlayerSlot
    AddLog "AcceptConnection: slot " & I, "network.log"

    If I <> 0 Then
        ' Whoho, we can connect them
        Socket.UserData = I
        Set GameServer.Sockets(CStr(I)).Socket = Socket
        AddLog "AcceptConnection: socket assigned", "network.log"
        Call SocketConnected(I)
        AddLog "AcceptConnection: setup completed", "network.log"
        Socket.RequestRead
    Else
        Socket.Close
    End If
End Sub

Sub SocketConnected(ByVal Index As Long)
    If Index <> 0 Then
        ' Are they trying to connect more then one connection?
        ' If Not IsMultiIPOnline(GetPlayerIP(Index)) Then
        If Not IsBanned(GetPlayerIP(Index)) Then
            Call TextAdd(frmServer.txtText, "Received connection from " & GetPlayerIP(Index) & ".", True)
        Else
            Call AlertMsg(Index, "You have been banned from " & GAME_NAME & ", and can no longer play.")
        End If

        ' Set The High Index
        Call SetHighIndex
        Call SendHighIndex
    ' Else
    ' Tried multiple connections
    ' Call AlertMsg(Index, GAME_NAME & " does not allow multiple IP's anymore.")
    ' End If
    End If
End Sub

Public Sub ReceiveClientBytes(ByVal Socket As clsNativeConnection, ByRef ReceivedBytes() As Byte, Optional ByVal Trace As Boolean = False)
    On Error GoTo PacketFailed

    Dim Buffer As String
    Dim Packet As String
    Dim top As String * 3
    Dim Start As Long
    Dim Index As Long
    Dim DataLength As Long
    Dim errorNumber As Long, errorDescription As String

    Socket.RequestRead
    Buffer = StrConv(ReceivedBytes, vbUnicode)
    DataLength = Len(Buffer)
    Index = CLng(Socket.UserData)
    If Index < 1 Or Index > MAX_PLAYERS Then Exit Sub
    If Buffer = "top" Then
        top = Str(TotalOnlinePlayers)
        Call SendDataTo(Index, top)
        Call CloseSocket(Index)
        Exit Sub
    End If

    Player(Index).Buffer = Player(Index).Buffer & Buffer

    Start = InStr(Player(Index).Buffer, END_CHAR)
    Do While Start > 0
        Packet = Mid(Player(Index).Buffer, 1, Start - 1)
        Player(Index).Buffer = Mid(Player(Index).Buffer, Start + 1, Len(Player(Index).Buffer))
        Player(Index).DataPackets = Player(Index).DataPackets + 1
        Start = InStr(Player(Index).Buffer, END_CHAR)
        If Len(Packet) > 0 Then
            If Trace Then AddLog "Handling command: " & Left$(Packet, InStr(Packet & SEP_CHAR, SEP_CHAR) - 1), "network.log"
            Call modHandleData.HandleData(Index, Packet)
            If Trace Then AddLog "Command completed", "network.log"
        End If
    Loop

    ' Check if elapsed time has passed
    Player(Index).DataBytes = Player(Index).DataBytes + DataLength
    If GetTickCount >= Player(Index).DataTimer + 1000 Then
        Player(Index).DataTimer = GetTickCount
        Player(Index).DataBytes = 0
        Player(Index).DataPackets = 0
        Exit Sub
    End If

    ' Check for data flooding
    If Player(Index).DataBytes > 4096 And GetPlayerAccess(Index) <= 0 Then
        Call HackingAttempt(Index, "Data Flooding")
        Exit Sub
    End If

    ' Allow one-pixel movement at the client movement tick plus normal game packets.
    ' Check for packet flooding
    If Player(Index).DataPackets > 100 And GetPlayerAccess(Index) <= 0 Then
        Call HackingAttempt(Index, "Packet Flooding")
        Exit Sub
    End If
    Exit Sub
PacketFailed:
    errorNumber = Err.Number
    errorDescription = Err.Description
    On Error Resume Next
    AddLog "Packet error for slot " & Index & ": " & errorNumber & " " & errorDescription, "network.log"
    Socket.Close
    If Index > 0 And Index <= MAX_PLAYERS Then CloseSocket Index
End Sub

Sub CloseSocket(ByVal Index As Long)
    ' Make sure player was/is playing the game, and if so, save'm.
    If Index > 0 And IsConnected(Index) Then
        GameServer.Sockets(Index).Socket.BeginDisconnect
        Call LeftGame(Index)

        Call TextAdd(frmServer.txtText, "Connection from " & GetPlayerIP(Index) & " has been terminated.", True)

        Call GameServer.Sockets(Index).Shutdown(SocketShutdownBoth)
        Call GameServer.Sockets(Index).CloseSocket

        Call UpdateCaption
        Call SetHighIndex
        Call SendHighIndex
        Call ClearPlayer(Index)
    End If
End Sub

Sub SendWhosOnline(ByVal Index As Long)
    Dim s As String
    Dim N As Long, I As Long

    s = ""
    N = 0
    For I = 1 To HighIndex
        If IsPlaying(I) And I <> Index Then
            s = s & GetPlayerName(I) & ", "
            N = N + 1
        End If
    Next I

    If N = 0 Then
        s = "There are no other players online."
    Else
        s = Mid$(s, 1, Len(s) - 2)
        s = "There are " & N & " other players online: " & s & "."
    End If

    Dim whoPacket As String
    whoPacket = "WHOLIST"
    For I = 1 To HighIndex
        If IsPlaying(I) And I <> Index Then whoPacket = whoPacket & SEP_CHAR & GetPlayerName(I)
    Next I
    SendDataTo Index, whoPacket & END_CHAR
    Call PlayerMsg(Index, s, WhoColor)
End Sub

Sub SendChars(ByVal Index As Long)
    Dim Packet As String
    Dim I As Long

    Packet = "ALLCHARS" & SEP_CHAR
    For I = 1 To MAX_CHARS
        Packet = Packet & Trim$(Player(Index).Char(I).Name) & SEP_CHAR & Trim$(Class(Player(Index).Char(I).Class).Name) & SEP_CHAR & Player(Index).Char(I).Level & SEP_CHAR & Player(Index).Char(I).Sprite & SEP_CHAR
    Next I
    Packet = Packet & END_CHAR

    Call SendDataTo(Index, Packet)
End Sub

Sub SendJoinMap(ByVal Index As Long)
    Dim Packet As String
    Dim I As Long

    Packet = ""

    ' Send all players on current map to index
    For I = 1 To HighIndex
        If IsPlaying(I) And I <> Index And GetPlayerMap(I) = GetPlayerMap(Index) Then
            Packet = Packet & "PLAYERDATA" & SEP_CHAR & I & SEP_CHAR & GetPlayerName(I) & SEP_CHAR & GetPlayerSprite(I) & SEP_CHAR & GetPlayerMap(I) & SEP_CHAR & GetPlayerX(I) & SEP_CHAR & GetPlayerY(I) & SEP_CHAR & GetPlayerDir(I) & SEP_CHAR & GetPlayerAccess(I) & SEP_CHAR & GetPlayerPK(I) & SEP_CHAR & GetPlayerGuild(I) & SEP_CHAR & Player(I).XOffset & SEP_CHAR & Player(I).YOffset & END_CHAR
            Call SendDataTo(Index, Packet)
            SendSpriteVitals I, Index
        End If
    Next I

    ' Send index's player data to everyone on the map including himself
    Packet = "PLAYERDATA" & SEP_CHAR & Index & SEP_CHAR & GetPlayerName(Index) & SEP_CHAR & GetPlayerSprite(Index) & SEP_CHAR & GetPlayerMap(Index) & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & GetPlayerDir(Index) & SEP_CHAR & GetPlayerAccess(Index) & SEP_CHAR & GetPlayerPK(Index) & SEP_CHAR & GetPlayerGuild(Index) & SEP_CHAR & Player(Index).XOffset & SEP_CHAR & Player(Index).YOffset & END_CHAR
    Call SendDataToMap(GetPlayerMap(Index), Packet)

    SendSpriteVitals Index
End Sub

Sub SendLeaveMap(ByVal Index As Long, ByVal MapNum As Long)
    Dim Packet As String

    Packet = "PLAYERDATA" & SEP_CHAR & Index & SEP_CHAR & GetPlayerName(Index) & SEP_CHAR & GetPlayerSprite(Index) & SEP_CHAR & 0 & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & GetPlayerDir(Index) & SEP_CHAR & GetPlayerAccess(Index) & SEP_CHAR & GetPlayerPK(Index) & END_CHAR
    Call SendDataToMapBut(Index, MapNum, Packet)

End Sub

Sub SendPlayerData(ByVal Index As Long)
    Dim Packet As String

    ' Send index's player data to everyone including himself on the map
    Packet = "PLAYERDATA" & SEP_CHAR & Index & SEP_CHAR & GetPlayerName(Index) & SEP_CHAR & GetPlayerSprite(Index) & SEP_CHAR & GetPlayerMap(Index) & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & GetPlayerDir(Index) & SEP_CHAR & GetPlayerAccess(Index) & SEP_CHAR & GetPlayerPK(Index) & SEP_CHAR & GetPlayerGuild(Index) & SEP_CHAR & Player(Index).XOffset & SEP_CHAR & Player(Index).YOffset & END_CHAR
    Call SendDataToMap(GetPlayerMap(Index), Packet)
    SendSpriteVitals Index
End Sub

Sub SendMap(ByVal Index As Long, ByVal MapNum As Long)
    Dim Packet As String, P1 As String, P2 As String
    Dim X As Long
    Dim y As Long

    Packet = "MAPDATA" & SEP_CHAR & MapNum & SEP_CHAR & Trim$(Map(MapNum).Name) & SEP_CHAR & Map(MapNum).Revision & SEP_CHAR & Map(MapNum).Moral & SEP_CHAR & Map(MapNum).Up & SEP_CHAR & Map(MapNum).Down & SEP_CHAR & Map(MapNum).Left & SEP_CHAR & Map(MapNum).Right & SEP_CHAR & Map(MapNum).Music & SEP_CHAR & Map(MapNum).BootMap & SEP_CHAR & Map(MapNum).BootX & SEP_CHAR & Map(MapNum).BootY & SEP_CHAR & Map(MapNum).Shop & SEP_CHAR & Map(MapNum).Tileset & SEP_CHAR

    For y = 0 To MAX_MAPY
        For X = 0 To MAX_MAPX
            With Map(MapNum).Tile(X, y)
                Packet = Packet & .Ground & SEP_CHAR & .Mask & SEP_CHAR & .Anim & SEP_CHAR & .Mask2 & SEP_CHAR & .M2Anim & SEP_CHAR & .Fringe & SEP_CHAR & .FAnim & SEP_CHAR & .Fringe2 & SEP_CHAR & .F2Anim & SEP_CHAR & .Type & SEP_CHAR & .Data1 & SEP_CHAR & .Data2 & SEP_CHAR & .Data3 & SEP_CHAR
            End With
        Next X
    Next y

    For X = 1 To MAX_MAP_NPCS
        Packet = Packet & Map(MapNum).Npc(X) & SEP_CHAR
    Next X

    Packet = Packet & "MAPEX1" & SEP_CHAR
    For y = 0 To MAX_MAPY
        For X = 0 To MAX_MAPX
            With Map(MapNum).Tile(X, y)
                Packet = Packet & .LayerTileset(0) & SEP_CHAR
                Packet = Packet & .LayerTileset(1) & SEP_CHAR
                Packet = Packet & .LayerTileset(2) & SEP_CHAR
                Packet = Packet & .LayerTileset(3) & SEP_CHAR
                Packet = Packet & .LayerTileset(4) & SEP_CHAR
                Packet = Packet & .LayerTileset(5) & SEP_CHAR
                Packet = Packet & .LayerTileset(6) & SEP_CHAR
                Packet = Packet & .LayerTileset(7) & SEP_CHAR
                Packet = Packet & .LayerTileset(8) & SEP_CHAR
                Packet = Packet & .Type2 & SEP_CHAR & .Data21 & SEP_CHAR & .Data22 & SEP_CHAR & .Data23 & SEP_CHAR
            End With
        Next X
    Next y

    Packet = Packet & END_CHAR

    X = Int(Len(Packet) / 2)
    P1 = Mid$(Packet, 1, X)
    P2 = Mid$(Packet, X + 1, Len(Packet) - X)
    Call SendDataTo(Index, Packet)
End Sub

Sub SendMapItemsTo(ByVal Index As Long, ByVal MapNum As Long)
    Dim Packet As String
    Dim I As Long

    Packet = "MAPITEMDATA" & SEP_CHAR
    For I = 1 To MAX_MAP_ITEMS
        Packet = Packet & MapItem(MapNum, I).Num & SEP_CHAR & MapItem(MapNum, I).Value & SEP_CHAR & MapItem(MapNum, I).Dur & SEP_CHAR & MapItem(MapNum, I).X & SEP_CHAR & MapItem(MapNum, I).y & SEP_CHAR & MapItem(MapNum, I).XOffset & SEP_CHAR & MapItem(MapNum, I).YOffset & SEP_CHAR
    Next I
    Packet = Packet & END_CHAR

    Call SendDataTo(Index, Packet)
End Sub

Sub SendMapItemsToAll(ByVal MapNum As Long)
    Dim Packet As String
    Dim I As Long

    Packet = "MAPITEMDATA" & SEP_CHAR
    For I = 1 To MAX_MAP_ITEMS
        Packet = Packet & MapItem(MapNum, I).Num & SEP_CHAR & MapItem(MapNum, I).Value & SEP_CHAR & MapItem(MapNum, I).Dur & SEP_CHAR & MapItem(MapNum, I).X & SEP_CHAR & MapItem(MapNum, I).y & SEP_CHAR & MapItem(MapNum, I).XOffset & SEP_CHAR & MapItem(MapNum, I).YOffset & SEP_CHAR
    Next I
    Packet = Packet & END_CHAR

    Call SendDataToMap(MapNum, Packet)
End Sub

Sub SendMapNpcsTo(ByVal Index As Long, ByVal MapNum As Long)
    Dim Packet As String
    Dim I As Long

    Packet = "MAPNPCDATA" & SEP_CHAR
    For I = 1 To MAX_MAP_NPCS
        Packet = Packet & MapNpc(MapNum, I).Num & SEP_CHAR & MapNpc(MapNum, I).X & SEP_CHAR & MapNpc(MapNum, I).y & SEP_CHAR & MapNpc(MapNum, I).Dir & SEP_CHAR & MapNpc(MapNum, I).HP & SEP_CHAR & GetNpcMaxHP(MapNpc(MapNum, I).Num) & SEP_CHAR & MapNpc(MapNum, I).MP & SEP_CHAR
    Next I
    Packet = Packet & END_CHAR

    Call SendDataTo(Index, Packet)
End Sub

Sub SendMapNpcsToMap(ByVal MapNum As Long)
    Dim Packet As String
    Dim I As Long

    Packet = "MAPNPCDATA" & SEP_CHAR
    For I = 1 To MAX_MAP_NPCS
        Packet = Packet & MapNpc(MapNum, I).Num & SEP_CHAR & MapNpc(MapNum, I).X & SEP_CHAR & MapNpc(MapNum, I).y & SEP_CHAR & MapNpc(MapNum, I).Dir & SEP_CHAR & MapNpc(MapNum, I).HP & SEP_CHAR & GetNpcMaxHP(MapNpc(MapNum, I).Num) & SEP_CHAR & MapNpc(MapNum, I).MP & SEP_CHAR
    Next I
    Packet = Packet & END_CHAR

    Call SendDataToMap(MapNum, Packet)
End Sub

Sub SendItems(ByVal Index As Long)
    Dim Packet As String
    Dim I As Long

    For I = 1 To MAX_ITEMS
        If Trim$(Item(I).Name) <> "" Then
            Call SendUpdateItemTo(Index, I)
        End If
    Next I
End Sub

Sub SendNpcs(ByVal Index As Long)
    Dim Packet As String
    Dim I As Long

    For I = 1 To MAX_NPCS
        If Trim$(Npc(I).Name) <> "" Then
            Call SendUpdateNpcTo(Index, I)
        End If
    Next I
End Sub

Sub SendInventory(ByVal Index As Long)
    Dim Packet As String
    Dim I As Long

    Packet = "PLAYERINV" & SEP_CHAR
    For I = 1 To MAX_INV
        Packet = Packet & GetPlayerInvItemNum(Index, I) & SEP_CHAR & GetPlayerInvItemValue(Index, I) & SEP_CHAR & GetPlayerInvItemDur(Index, I) & SEP_CHAR
    Next I
    Packet = Packet & END_CHAR

    Call SendDataTo(Index, Packet)
End Sub

Sub SendInventoryUpdate(ByVal Index As Long, ByVal InvSlot As Long)
    Dim Packet As String

    Packet = "PLAYERINVUPDATE" & SEP_CHAR & InvSlot & SEP_CHAR & GetPlayerInvItemNum(Index, InvSlot) & SEP_CHAR & GetPlayerInvItemValue(Index, InvSlot) & SEP_CHAR & GetPlayerInvItemDur(Index, InvSlot) & END_CHAR
    Call SendDataTo(Index, Packet)
    RefreshDialogueQuestMarkers Index
End Sub

Sub SendWornEquipment(ByVal Index As Long)
    Dim Packet As String

    Packet = "PLAYERWORNEQ" & SEP_CHAR & GetPlayerArmorSlot(Index) & SEP_CHAR & GetPlayerWeaponSlot(Index) & SEP_CHAR & GetPlayerHelmetSlot(Index) & SEP_CHAR & GetPlayerShieldSlot(Index) & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendHP(ByVal Index As Long)
    Dim Packet As String

    Packet = "PLAYERHP" & SEP_CHAR & GetPlayerMaxHP(Index) & SEP_CHAR & GetPlayerHP(Index) & END_CHAR
    Call SendDataTo(Index, Packet)
    SendSpriteVitals Index
End Sub

Sub SendMP(ByVal Index As Long)
    Dim Packet As String

    Packet = "PLAYERMP" & SEP_CHAR & GetPlayerMaxMP(Index) & SEP_CHAR & GetPlayerMP(Index) & END_CHAR
    Call SendDataTo(Index, Packet)
    SendSpriteVitals Index
End Sub

Sub SendSP(ByVal Index As Long)
    Dim Packet As String

    Packet = "PLAYERSP" & SEP_CHAR & GetPlayerMaxSP(Index) & SEP_CHAR & GetPlayerSP(Index) & END_CHAR
    Call SendDataTo(Index, Packet)
    SendSpriteVitals Index
End Sub

Sub SendStats(ByVal Index As Long)
    Dim Packet As String

    Packet = "PLAYERSTATS" & SEP_CHAR & GetPlayerSTR(Index) & SEP_CHAR & GetPlayerDEF(Index) & SEP_CHAR & GetPlayerSPEED(Index) & SEP_CHAR & GetPlayerMAGI(Index) & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendWelcome(ByVal Index As Long)
    Dim f As Long

    ' Send them welcome
    Call PlayerMsg(Index, "Type /help for help on commands.  Use arrow keys to move, hold down shift to run, and use ctrl to attack.", Cyan)

    ' Send them MOTD
    If Trim$(MOTD) <> "" Then
        Call PlayerMsg(Index, "MOTD: " & MOTD, BrightCyan)
    End If

    ' Send whos online
    Call SendWhosOnline(Index)
End Sub

Sub SendClasses(ByVal Index As Long)
    Dim Packet As String
    Dim I As Long

    Packet = "CLASSESDATA" & SEP_CHAR & MAX_CLASS & SEP_CHAR
    For I = 1 To MAX_CLASS
        Packet = Packet & GetClassName(I) & SEP_CHAR & GetClassMaxHP(I) & SEP_CHAR & GetClassMaxMP(I) & SEP_CHAR & GetClassMaxSP(I) & SEP_CHAR & Class(I).STR & SEP_CHAR & Class(I).DEF & SEP_CHAR & Class(I).SPEED & SEP_CHAR & Class(I).MAGI & SEP_CHAR
    Next I
    Packet = Packet & END_CHAR

    Call SendDataTo(Index, Packet)
End Sub

Sub SendNewCharClasses(ByVal Index As Long)
    Dim Packet As String
    Dim I As Long

    Packet = "NEWCHARCLASSES" & SEP_CHAR & MAX_CLASS & SEP_CHAR
    For I = 1 To MAX_CLASS
        Packet = Packet & GetClassName(I) & SEP_CHAR & GetClassMaxHP(I) & SEP_CHAR & GetClassMaxMP(I) & SEP_CHAR & GetClassMaxSP(I) & SEP_CHAR & Class(I).STR & SEP_CHAR & Class(I).DEF & SEP_CHAR & Class(I).SPEED & SEP_CHAR & Class(I).MAGI & SEP_CHAR & Class(I).MSprite & SEP_CHAR & Class(I).FSprite & SEP_CHAR
    Next I
    Packet = Packet & END_CHAR

    Call SendDataTo(Index, Packet)
End Sub

Sub SendLeftGame(ByVal Index As Long)
    Dim Packet As String

    Packet = "PLAYERDATA" & SEP_CHAR & Index & SEP_CHAR & "" & SEP_CHAR & 0 & SEP_CHAR & 0 & SEP_CHAR & 0 & SEP_CHAR & 0 & SEP_CHAR & 0 & SEP_CHAR & 0 & SEP_CHAR & 0 & END_CHAR
    Call SendDataToAllBut(Index, Packet)
End Sub

Sub SendPlayerXY(ByVal Index As Long)
    Dim Packet As String

    Packet = "PLAYERXY" & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & Player(Index).XOffset & SEP_CHAR & Player(Index).YOffset & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendUpdateItemToAll(ByVal ItemNum As Long)
    Dim Packet As String

    Packet = "UPDATEITEM" & SEP_CHAR & ItemNum & SEP_CHAR & Trim$(Item(ItemNum).Name) & SEP_CHAR & Item(ItemNum).Pic & SEP_CHAR & Item(ItemNum).Type & SEP_CHAR & Item(ItemNum).Data1 & SEP_CHAR & Item(ItemNum).Data2 & SEP_CHAR & Item(ItemNum).Data3 & END_CHAR
    Call SendDataToAll(Packet)
End Sub

Sub SendUpdateItemTo(ByVal Index As Long, ByVal ItemNum As Long)
    Dim Packet As String

    Packet = "UPDATEITEM" & SEP_CHAR & ItemNum & SEP_CHAR & Trim(Item(ItemNum).Name) & SEP_CHAR & Item(ItemNum).Pic & SEP_CHAR & Item(ItemNum).Type & SEP_CHAR & Item(ItemNum).Data1 & SEP_CHAR & Item(ItemNum).Data2 & SEP_CHAR & Item(ItemNum).Data3 & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendUpdateGuildToAll(ByVal GuildNum As Long)
    Dim Packet As String

    Packet = "UPDATEGUILD" & SEP_CHAR & GuildNum & SEP_CHAR & Trim$(Guild(GuildNum).Name) & SEP_CHAR & Trim$(Guild(GuildNum).Abbreviation) & SEP_CHAR & Trim$(Guild(GuildNum).Founder) & END_CHAR
    Call SendDataToAll(Packet)
End Sub

Sub SendUpdateGuildTo(ByVal Index As Long, ByVal GuildNum As Long)
    Dim Packet As String

    Packet = "UPDATEGUILD" & SEP_CHAR & GuildNum & SEP_CHAR & Trim$(Guild(GuildNum).Name) & SEP_CHAR & Trim$(Guild(GuildNum).Abbreviation) & SEP_CHAR & Trim$(Guild(GuildNum).Founder) & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendEditItemTo(ByVal Index As Long, ByVal ItemNum As Long)
    Dim Packet As String

    Packet = "EDITITEM" & SEP_CHAR & ItemNum & SEP_CHAR & Trim$(Item(ItemNum).Name) & SEP_CHAR & Item(ItemNum).Pic & SEP_CHAR & Item(ItemNum).Type & SEP_CHAR & Item(ItemNum).Data1 & SEP_CHAR & Item(ItemNum).Data2 & SEP_CHAR & Item(ItemNum).Data3 & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendUpdateNpcToAll(ByVal NpcNum As Long)
    Dim Packet As String

    Packet = "UPDATENPC" & SEP_CHAR & NpcNum & SEP_CHAR & Trim$(Npc(NpcNum).Name) & SEP_CHAR & Npc(NpcNum).Sprite & END_CHAR
    Call SendDataToAll(Packet)
End Sub

Sub SendUpdateNpcTo(ByVal Index As Long, ByVal NpcNum As Long)
    Dim Packet As String

    Packet = "UPDATENPC" & SEP_CHAR & NpcNum & SEP_CHAR & Trim$(Npc(NpcNum).Name) & SEP_CHAR & Npc(NpcNum).Sprite & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub ServerReboot()
    frmServer.tmrReboot.Enabled = True
End Sub

Sub SendEditNpcTo(ByVal Index As Long, ByVal NpcNum As Long)
    Dim Packet As String

    SendNpcQuestNames Index
    Packet = "EDITNPC" & SEP_CHAR & NpcNum & SEP_CHAR & Trim$(Npc(NpcNum).Name) & SEP_CHAR & Trim$(Npc(NpcNum).AttackSay) & SEP_CHAR & Npc(NpcNum).Sprite & SEP_CHAR & Npc(NpcNum).SpawnSecs & SEP_CHAR & Npc(NpcNum).Behavior & SEP_CHAR & Npc(NpcNum).Range & SEP_CHAR & Npc(NpcNum).DropChance & SEP_CHAR & Npc(NpcNum).DropItem & SEP_CHAR & Npc(NpcNum).DropItemValue & SEP_CHAR & Npc(NpcNum).STR & SEP_CHAR & Npc(NpcNum).DEF & SEP_CHAR & Npc(NpcNum).SPEED & SEP_CHAR & Npc(NpcNum).MAGI & SEP_CHAR & Npc(NpcNum).MaxHP & SEP_CHAR & Npc(NpcNum).GiveEXP & SEP_CHAR & Npc(NpcNum).ShopCall & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendExp(ByVal Index As Long)
    Dim Packet As String
    Dim N, f As Byte

    Packet = "PLAYEREXP" & SEP_CHAR & GetPlayerExp(Index) & SEP_CHAR & GetPlayerNextLevel(Index) & SEP_CHAR & GetPlayerLevel(Index) & SEP_CHAR & GetPlayerPOINTS(Index) & SEP_CHAR & GetPlayerClass(Index) & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendGuild(ByVal Index As Long)
    Dim Packet As String

    Packet = "PLAYERGUILD" & SEP_CHAR & GetPlayerGuild(Index) & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendShops(ByVal Index As Long)
    Dim I As Long

    For I = 1 To MAX_SHOPS
        If Trim$(Shop(I).Name) <> "" Then
            Call SendUpdateShopTo(Index, I)
        End If
    Next I
End Sub

Sub SendUpdateShopToAll(ByVal ShopNum As Long)
    Dim Packet As String

    Packet = "UPDATESHOP" & SEP_CHAR & ShopNum & SEP_CHAR & Trim$(Shop(ShopNum).Name) & END_CHAR
    Call SendDataToAll(Packet)
End Sub

Sub SendUpdateShopTo(ByVal Index As Long, ByVal ShopNum)
    Dim Packet As String

    Packet = "UPDATESHOP" & SEP_CHAR & ShopNum & SEP_CHAR & Trim$(Shop(ShopNum).Name) & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendEditShopTo(ByVal Index As Long, ByVal ShopNum As Long)
    Dim Packet As String
    Dim I As Long

    Packet = "EDITSHOP" & SEP_CHAR & ShopNum & SEP_CHAR & Trim$(Shop(ShopNum).Name) & SEP_CHAR & Trim$(Shop(ShopNum).JoinSay) & SEP_CHAR & Trim$(Shop(ShopNum).LeaveSay) & SEP_CHAR & Shop(ShopNum).FixesItems & SEP_CHAR
    For I = 1 To MAX_TRADES
        Packet = Packet & Shop(ShopNum).TradeItem(I).GiveItem & SEP_CHAR & Shop(ShopNum).TradeItem(I).GiveValue & SEP_CHAR & Shop(ShopNum).TradeItem(I).GetItem & SEP_CHAR & Shop(ShopNum).TradeItem(I).GetValue & SEP_CHAR & Shop(ShopNum).TradeItem(I).GiveItem2 & SEP_CHAR & Shop(ShopNum).TradeItem(I).GiveValue2 & SEP_CHAR
    Next I
    Packet = Packet & END_CHAR

    Call SendDataTo(Index, Packet)
End Sub

Sub SendSpells(ByVal Index As Long)
    Dim I As Long

    For I = 1 To MAX_SPELLS
        If Trim$(Spell(I).Name) <> "" Then
            Call SendUpdateSpellTo(Index, I)
        End If
    Next I
End Sub

Sub SendGuilds(ByVal Index As Long)
    Dim I As Long

    For I = 1 To MAX_GUILDS
        If Trim$(Guild(I).Name) <> vbNullString Then
            Call SendUpdateGuildTo(Index, I)
        End If
    Next I
End Sub

Sub SendUpdateSpellToAll(ByVal SpellNum As Long)
    Dim Packet As String

    Packet = "UPDATESPELL" & SEP_CHAR & SpellNum & SEP_CHAR & Trim$(Spell(SpellNum).Name) & SEP_CHAR & Spell(SpellNum).Graphic & SEP_CHAR & Spell(SpellNum).LevelReq & SEP_CHAR & Spell(SpellNum).MPReq & END_CHAR
    Call SendDataToAll(Packet)
End Sub

Sub SendUpdateSpellTo(ByVal Index As Long, ByVal SpellNum As Long)
    Dim Packet As String

    Packet = "UPDATESPELL" & SEP_CHAR & SpellNum & SEP_CHAR & Trim$(Spell(SpellNum).Name) & SEP_CHAR & Spell(SpellNum).Graphic & SEP_CHAR & Spell(SpellNum).LevelReq & SEP_CHAR & Spell(SpellNum).MPReq & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendEditSpellTo(ByVal Index As Long, ByVal SpellNum As Long)
    Call SendSpellDelivery(Index, SpellNum)
    Dim Packet As String

    Packet = "EDITSPELL" & SEP_CHAR & SpellNum & SEP_CHAR & Trim$(Spell(SpellNum).Name) & SEP_CHAR & Spell(SpellNum).ClassReq & SEP_CHAR & Spell(SpellNum).LevelReq & SEP_CHAR & Spell(SpellNum).Type & SEP_CHAR & Spell(SpellNum).Data1 & SEP_CHAR & Spell(SpellNum).Data2 & SEP_CHAR & Spell(SpellNum).Data3 & SEP_CHAR & Spell(SpellNum).Graphic & SEP_CHAR & Spell(SpellNum).MPReq & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendTrade(ByVal Index As Long, ByVal ShopNum As Long)
    Dim Packet As String
    Dim I As Byte, X As Long, y As Long

    CurrentShop = ShopNum

    Packet = "TRADE" & SEP_CHAR & Trim$(ShopNum) & SEP_CHAR & Shop(ShopNum).FixesItems & SEP_CHAR
    For I = 1 To MAX_TRADES Step 1
        Packet = Packet & Trim$(Shop(ShopNum).TradeItem(I).GiveItem) & SEP_CHAR & Trim$(Shop(ShopNum).TradeItem(I).GiveValue) & SEP_CHAR & Trim$(Shop(ShopNum).TradeItem(I).GetItem) & SEP_CHAR & Trim$(Shop(ShopNum).TradeItem(I).GetValue) & SEP_CHAR & Trim$(Shop(ShopNum).TradeItem(I).GiveItem2) & SEP_CHAR & Trim$(Shop(ShopNum).TradeItem(I).GiveValue2) & SEP_CHAR

        ' Item #
        X = Trim$(Shop(ShopNum).TradeItem(I).GetItem)
        If X > 0 Then
            If Item(X).Type = ITEM_TYPE_SPELL Then
                ' Spell class requirement
                y = Spell(Item(X).Data1).ClassReq

                If y = 0 Then
                    Call PlayerMsg(Index, Trim$(Item(X).Name) & " can be used by all classes.", Yellow)
                Else
                    Call PlayerMsg(Index, Trim$(Item(X).Name) & " can only be used by a " & GetClassName(y - 1) & ".", Yellow)
                End If
            End If
        End If
    Next
    Packet = Packet & END_CHAR

    Call SendDataTo(Index, Packet)
End Sub

Sub SendPlayerSpells(ByVal Index As Long)
    Dim Packet As String
    Dim I As Long

    Packet = "SPELLS" & SEP_CHAR
    For I = 1 To MAX_PLAYER_SPELLS
        Packet = Packet & GetPlayerSpell(Index, I) & SEP_CHAR
    Next I
    Packet = Packet & END_CHAR

    Call SendDataTo(Index, Packet)
End Sub

Sub SendWeatherTo(ByVal Index As Long)
    Dim Packet As String

    Packet = "WEATHER" & SEP_CHAR & GameWeather & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendWeatherToAll()
    Dim I As Long

    For I = 1 To MAX_PLAYERS
        If IsPlaying(I) Then
            Call SendWeatherTo(I)
        End If
    Next I
End Sub

Sub SendName(ByVal Index As Long)
    Dim Packet As String

    Packet = "SENDNAME" & SEP_CHAR & GAME_NAME & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendSite(ByVal Index As Long)
    Dim Packet As String

    Packet = "SENDSITE" & SEP_CHAR & GAME_WEBSITE & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendMaxes(ByVal Index As Long)
    Dim Packet As String

    Packet = "SENDMAXES" & SEP_CHAR & MAX_NPCS & SEP_CHAR & MAX_ITEMS & SEP_CHAR & MAX_PLAYERS & SEP_CHAR & MAX_SHOPS & SEP_CHAR & MAX_SPELLS & SEP_CHAR & MAX_SIGNS & SEP_CHAR & MAX_MAPS_SET & SEP_CHAR & MAX_GUILDS & SEP_CHAR & MAX_GUILD_MEMBERS & SEP_CHAR & MAX_ARROWS & SEP_CHAR & MAX_BOOKS & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendTimeTo(ByVal Index As Long)
    Dim Packet As String

    Packet = "TIME" & SEP_CHAR & GameTime & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendTimeToAll()
    Dim I As Long

    For I = 1 To MAX_PLAYERS
        If IsPlaying(I) Then
            Call SendTimeTo(I)
        End If
    Next I
End Sub

Sub SendOnlineList(ByVal Index As Long)
    Dim Packet As String
    Dim I As Long
    Dim N As Long
    Dim Color As Byte

    Packet = ""
    N = 0
    For I = 1 To MAX_PLAYERS
        If IsPlaying(I) Then
            Packet = Packet & SEP_CHAR & GetPlayerName(I) & SEP_CHAR
            N = N + 1
        End If
    Next I
    
    Packet = "ONLINELIST" & SEP_CHAR & N & Packet & Color & END_CHAR
    Call SendDataToAll(Packet)
End Sub

Sub SendSign(ByVal Index As Long)
    Dim I As Long

    For I = 1 To MAX_SIGNS
        If Trim(Sign(I).Name) <> "" Then
            Call SendUpdateSignTo(Index, I)
        End If
    Next I
End Sub

Sub SendUpdateSignToAll(ByVal SignNum As Long)
    Dim Packet As String

    Packet = "UPDATESIGN" & SEP_CHAR & SignNum & SEP_CHAR & Trim$(Sign(SignNum).Name) & END_CHAR
    Call SendDataToAll(Packet)
End Sub

Sub SendUpdateSignTo(ByVal Index As Long, ByVal SignNum As Long)
    Dim Packet As String

    Packet = "UPDATESIGN" & SEP_CHAR & SignNum & SEP_CHAR & Trim$(Sign(SignNum).Name) & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendEditSignTo(ByVal Index As Long, ByVal SignNum As Long)
    Dim Packet As String

    Packet = "EDITSIGN" & SEP_CHAR & SignNum & SEP_CHAR & Trim$(Sign(SignNum).Name) & SEP_CHAR & Trim$(Sign(SignNum).Background) & SEP_CHAR & Trim$(Sign(SignNum).Line1) & SEP_CHAR & Trim$(Sign(SignNum).Line2) & SEP_CHAR & Trim$(Sign(SignNum).Line3) & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendSignTo(ByVal Index As Long, ByVal SignNum As Long)
    Dim Packet As String

    Packet = "SIGN" & SEP_CHAR & SignNum & SEP_CHAR & Trim$(Sign(SignNum).Name) & SEP_CHAR & Trim$(Sign(SignNum).Background) & SEP_CHAR & Trim$(Sign(SignNum).Line1) & SEP_CHAR & Trim$(Sign(SignNum).Line2) & SEP_CHAR & Trim$(Sign(SignNum).Line3) & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendHighIndex()
    Dim I As Long
    For I = 1 To HighIndex
        Call SendDataTo(I, "HighIndex" & SEP_CHAR & HighIndex & END_CHAR)
    Next I
End Sub

Sub GlobalMessage(ByVal Msg As String, ByVal Color As Byte)
    Call GlobalMsg(Msg, Color)
End Sub

Sub AdminMessage(ByVal Msg As String, ByVal Color As Byte)
    Call AdminMsg(Msg, Color)
End Sub

Sub PlayerMessage(ByVal Index As Long, ByVal Msg As String, ByVal Color As Byte)
    Call PlayerMsg(Index, Msg, Color)
End Sub

Sub MapMessage(ByVal MapNum As Long, ByVal Msg As String, ByVal Color As Byte)
    Call MapMsg(MapNum, Msg, Color)
End Sub

Sub AlertMessage(ByVal Index As Long, ByVal Msg As String)
    Call AlertMsg(Index, Msg)
End Sub

Sub SendSpellAnim(ByVal Index As Long, ByVal Anim As Integer, ByVal X As Byte, ByVal y As Byte)
    Dim Packet As String

    Packet = "SPLANIM" & SEP_CHAR & Anim & SEP_CHAR & X & SEP_CHAR & y & END_CHAR
    Call SendDataToMap(GetPlayerMap(Index), Packet)
End Sub

Sub SendTargetXY(ByVal Index As Long, ByVal VicX As Long, ByVal VicY As Long, ByVal MapNum As Long, ByVal Anim As Long)
    Dim Packet As String

    Packet = "TARGETXY" & SEP_CHAR & VicX & SEP_CHAR & VicY & SEP_CHAR & Anim & END_CHAR
    Call SendDataToMap(MapNum, Packet)
End Sub

Sub SendPlayerStats(ByVal Index As Long)

    Call SendHP(Index)
    Call SendMP(Index)
    Call SendSP(Index)
    Call SendExp(Index)
    Call SendStats(Index)
    Call SendInventory(Index)
    Call SendWornEquipment(Index)
    Call SendPlayerData(Index)

End Sub

Sub SendEditArrowTo(ByVal Index As Long, ByVal arrowNum As Long)
    Dim Packet As String

    Packet = "EDITARROW" & SEP_CHAR & arrowNum & SEP_CHAR & Trim$(Arrow(arrowNum).Name) & SEP_CHAR & Trim$(Arrow(arrowNum).Range) & SEP_CHAR & Arrow(arrowNum).Sprite & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Sub SendEditClassTo(ByVal Index As Long, ByVal classNum As Long)
    Dim Packet As String
    
    Packet = "EDITCLASS" & SEP_CHAR & classNum & SEP_CHAR & Trim$(Class(classNum).Name) & SEP_CHAR & Class(classNum).MSprite & SEP_CHAR & Class(classNum).FSprite & SEP_CHAR & Class(classNum).STR & SEP_CHAR & Class(classNum).DEF & SEP_CHAR & Class(classNum).MAGI & SEP_CHAR & Class(classNum).SPEED & SEP_CHAR & Class(classNum).Map & SEP_CHAR & Class(classNum).X & SEP_CHAR & Class(classNum).Y & END_CHAR
    Call SendDataTo(Index, Packet)
End Sub

Public Sub SendSpriteVitals(ByVal Index As Long, Optional ByVal Recipient As Long = 0)
    Dim Packet As String
    If Not IsPlaying(Index) Then Exit Sub
    If GetPlayerMap(Index) <= 0 Then Exit Sub
    Packet = "SPRITEVITALS" & SEP_CHAR & Index & SEP_CHAR & GetPlayerMap(Index) & SEP_CHAR & GetPlayerHP(Index) & SEP_CHAR & GetPlayerMaxHP(Index) & SEP_CHAR & GetPlayerMP(Index) & SEP_CHAR & GetPlayerMaxMP(Index) & SEP_CHAR & GetPlayerSP(Index) & SEP_CHAR & GetPlayerMaxSP(Index) & END_CHAR
    If Recipient > 0 Then
        SendDataTo Recipient, Packet
    Else
        SendDataToMap GetPlayerMap(Index), Packet
    End If
End Sub

Public Sub SendSpriteBubble(ByVal Index As Long, ByVal Message As String)
    Dim Packet As String
    If Not IsPlaying(Index) Then Exit Sub
    If GetPlayerMap(Index) <= 0 Then Exit Sub
    Message = Left(Trim(Message), 240)
    If Len(Message) = 0 Then Exit Sub
    Packet = "SPRITEBUBBLE" & SEP_CHAR & Index & SEP_CHAR & GetPlayerMap(Index) & SEP_CHAR & Message & END_CHAR
    SendDataToMap GetPlayerMap(Index), Packet
End Sub
Public Sub HandleReadBook(ByVal Index As Long, ByRef Parts() As String)
    Dim bookId As Long, page As Long
    If UBound(Parts) <> 2 Then Exit Sub
    If Not IsNumeric(Parts(1)) Or Not IsNumeric(Parts(2)) Then Exit Sub
    If Val(Parts(1)) < 1 Or Val(Parts(1)) > 32767 Then Exit Sub
    If Val(Parts(2)) < 1 Or Val(Parts(2)) > 64 Then Exit Sub
    bookId = CLng(Val(Parts(1)))
    page = CLng(Val(Parts(2)))
    SendBookPages Index, bookId, page
End Sub

Public Sub SwapInventorySlots(ByVal Index As Long, ByRef Parts() As String)
    Dim source As Long, destination As Long, character As Long, temporary As PlayerInvRec
    If Index < 1 Or Index > MAX_PLAYERS Then Exit Sub
    If Not IsPlaying(Index) Then Exit Sub
    If UBound(Parts) <> 2 Then Exit Sub
    If Not IsNumeric(Parts(1)) Or Not IsNumeric(Parts(2)) Then Exit Sub
    If Val(Parts(1)) < 1 Or Val(Parts(1)) > MAX_INV Then Exit Sub
    If Val(Parts(2)) < 1 Or Val(Parts(2)) > MAX_INV Then Exit Sub
    If Val(Parts(1)) <> Fix(Val(Parts(1))) Or Val(Parts(2)) <> Fix(Val(Parts(2))) Then Exit Sub
    source = CLng(Val(Parts(1)))
    destination = CLng(Val(Parts(2)))
    If source = destination Then Exit Sub
    If GetPlayerInvItemNum(Index, source) <= 0 Then Exit Sub
    character = Player(Index).CharNum
    With Player(Index).Char(character)
        temporary = .Inv(source)
        .Inv(source) = .Inv(destination)
        .Inv(destination) = temporary
        .WeaponSlot = InventorySlotAfterSwap(.WeaponSlot, source, destination)
        .ArmorSlot = InventorySlotAfterSwap(.ArmorSlot, source, destination)
        .HelmetSlot = InventorySlotAfterSwap(.HelmetSlot, source, destination)
        .ShieldSlot = InventorySlotAfterSwap(.ShieldSlot, source, destination)
    End With
    SendInventoryUpdate Index, source
    SendInventoryUpdate Index, destination
    SendWornEquipment Index
End Sub

Private Function InventorySlotAfterSwap(ByVal slot As Long, ByVal source As Long, ByVal destination As Long) As Long
    InventorySlotAfterSwap = slot
    If slot = source Then InventorySlotAfterSwap = destination
    If slot = destination Then InventorySlotAfterSwap = source
End Function
Public Sub SendGuildDetails(ByVal Index As Long)
    Dim guildId As Long, member As Long, previous As Long, name As String, duplicate As Boolean
    If Not IsPlaying(Index) Then Exit Sub
    guildId = GetPlayerGuild(Index)
    If guildId < 1 Or guildId > MAX_GUILDS Then
        SendDataTo Index, "GUILDDETAILSBEGIN" & SEP_CHAR & "No guild" & SEP_CHAR & "" & END_CHAR
        Exit Sub
    End If
    SendDataTo Index, "GUILDDETAILSBEGIN" & SEP_CHAR & Trim$(Guild(guildId).Name) & SEP_CHAR & Trim$(Guild(guildId).Founder) & END_CHAR
    name = Trim$(Guild(guildId).Founder)
    If Len(name) > 0 Then SendGuildMemberDetails Index, name, "Founder"
    For member = 1 To MAX_GUILD_MEMBERS
        name = Trim$(Guild(guildId).Member(member))
        duplicate = (LCase$(name) = LCase$(Trim$(Guild(guildId).Founder)))
        For previous = 1 To member - 1
            If LCase$(name) = LCase$(Trim$(Guild(guildId).Member(previous))) Then duplicate = True
        Next previous
        If Len(name) > 0 And Not duplicate Then SendGuildMemberDetails Index, name, "Member"
    Next member
End Sub

Private Sub SendGuildMemberDetails(ByVal Index As Long, ByVal name As String, ByVal role As String)
    Dim playerIndex As Long, status As String
    status = "Offline"
    playerIndex = FindPlayer(name)
    If playerIndex > 0 And playerIndex <= MAX_PLAYERS Then
        If IsPlaying(playerIndex) Then status = "Online"
    End If
    SendDataTo Index, "GUILDMEMBERDETAILS" & SEP_CHAR & name & SEP_CHAR & role & SEP_CHAR & status & END_CHAR
End Sub

Public Sub SendNpcVitals(ByVal MapNum As Long, ByVal Slot As Long)
    Dim NpcNum As Long
    NpcNum = MapNpc(MapNum, Slot).Num
    If NpcNum <= 0 Then Exit Sub
    SendDataToMap MapNum, "NPCVITALS" & SEP_CHAR & MapNum & SEP_CHAR & Slot & SEP_CHAR & NpcNum & SEP_CHAR & MapNpc(MapNum, Slot).HP & SEP_CHAR & GetNpcMaxHP(NpcNum) & SEP_CHAR & MapNpc(MapNum, Slot).MP & END_CHAR
End Sub
