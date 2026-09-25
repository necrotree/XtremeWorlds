Attribute VB_Name = "modClientTCP"
Option Explicit

Sub TcpInit()
    ' ****************************************************************
    ' * WHEN    WHO    WHAT
    ' * ----    ---    ----
    ' * 07/12/2005  Shannara   Replaced hard-coded IP with constant.
    ' ****************************************************************
    Dim IP As String
    Dim Port As String
    Dim FileName As String

    frmMainGame.Socket.Close

    SEP_CHAR = Chr(0)
    END_CHAR = Chr(237)
    PlayerBuffer = vbNullString
    frmMainGame.Socket.RemoteHost = Trim$(GameData.IP)
    frmMainGame.Socket.RemotePort = GameData.Port
End Sub

Sub TcpDestroy()
    frmMainGame.Socket.Close
End Sub

Sub IncomingData(ByVal DataLength As Long)
    Dim Buffer As String
    Dim Packet As String
    Dim top As String * 3
    Dim Start As Integer

    frmMainGame.Socket.GetData Buffer, vbString, DataLength
    ' Call Encryption_XOR_DecryptString(Buffer, ENC_KEY)
    PlayerBuffer = PlayerBuffer & Buffer

    Start = InStr(PlayerBuffer, END_CHAR)
    Do While Start > 0
        Packet = Mid$(PlayerBuffer, 1, Start - 1)
        PlayerBuffer = Mid$(PlayerBuffer, Start + 1, Len(PlayerBuffer))
        Start = InStr(PlayerBuffer, END_CHAR)
        If Len(Packet) > 0 Then
            Call HandleData(Packet)
        End If
    Loop
End Sub

Public Function ConnectToServer() As Boolean
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Optimized function.
' ****************************************************************

    Dim Wait As Long

    ' Check to see if we are already connected, if so just exit
    If IsConnected Then
        ConnectToServer = True
        Exit Function
    End If

    Wait = GetTickCount
    With frmMainGame.Socket
        .Close
        .Connect
    End With

    ' Wait until connected or 4 seconds have passed and report the server being down
    Do While (Not IsConnected) And (GetTickCount <= Wait + 4000)
        DoEvents
    Loop

    If IsConnected Then
        ConnectToServer = True
    Else
        ConnectToServer = False
    End If
End Function

Function IsConnected() As Boolean
    If frmMainGame.Socket.State = sckConnected Then
        IsConnected = True
    Else
        IsConnected = False
    End If
End Function

Function IsPlaying(ByVal index As Long) As Boolean
    If LenB(GetPlayerName(index)) > 0 Then
        IsPlaying = True
    Else
        IsPlaying = False
    End If
End Function

Sub SendData(ByVal Data As String)
    If IsConnected Then
        ' Call Encryption_XOR_EncryptString(data, ENC_KEY)
        frmMainGame.Socket.SendData Data
        DoEvents
    End If
End Sub

Sub SendNewAccount(ByVal name As String, ByVal Password As String, ByVal EncKey As String)
    Dim Packet As String

' Call SendData("HDSerial" & SEP_CHAR & GetHDSerial("C") & END_CHAR)

    Packet = "newaccount" & SEP_CHAR & Trim$(name) & SEP_CHAR & Trim$(Password) & SEP_CHAR & Trim$(EncKey) & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendDelAccount(ByVal name As String, ByVal Password As String, ByVal EncKey As String)
    Dim Packet As String

    Call SendData("HDSerial" & SEP_CHAR & GetHDSerial("C") & END_CHAR)

    Packet = "delaccount" & SEP_CHAR & Trim$(name) & SEP_CHAR & Trim$(Password) & SEP_CHAR & Trim$(EncKey) & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendLogin(ByVal name As String, ByVal Password As String, ByVal EncKey As String)
    Dim Packet As String

    Call SendData("HDSerial" & SEP_CHAR & GetHDSerial("C") & END_CHAR)

    Packet = "login" & SEP_CHAR & Trim$(name) & SEP_CHAR & Trim$(Password) & SEP_CHAR & App.Major & SEP_CHAR & App.Minor & SEP_CHAR & App.Revision & SEP_CHAR & Trim$(EncKey) & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendAddChar(ByVal name As String, ByVal Sex As Long, ByVal ClassNum As Long, ByVal Slot As Long)
    Dim Packet As String

    Packet = "addchar" & SEP_CHAR & Trim$(name) & SEP_CHAR & Sex & SEP_CHAR & ClassNum & SEP_CHAR & Slot & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendDelChar(ByVal Slot As Long)
    Dim Packet As String

    Packet = "delchar" & SEP_CHAR & Slot & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendGetClasses()
    Dim Packet As String

    Packet = "getclasses" & END_CHAR
    Call SendData(Packet)
End Sub

Sub GetGameName()
    Dim Packet As String

    Packet = "getgamename" & END_CHAR
    Call SendData(Packet)
End Sub

Sub GetGameSite()
    Dim Packet As String

    Packet = "getgamesite" & END_CHAR
    Call SendData(Packet)
End Sub

Sub GetGameMaxes()
    Dim Packet As String

    Packet = "getgamemaxes" & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendUseChar(ByVal CharSlot As Long)
    Dim Packet As String

    Packet = "usechar" & SEP_CHAR & CharSlot & END_CHAR
    Call SendData(Packet)
End Sub

Sub SayMsg(ByVal Text As String)
    Dim Packet As String

    Packet = "saymsg" & SEP_CHAR & Text & END_CHAR
    Call SendData(Packet)
End Sub

Sub GlobalMsg(ByVal Text As String)
    Dim Packet As String

    Packet = "globalmsg" & SEP_CHAR & Text & END_CHAR
    Call SendData(Packet)
End Sub

Sub BroadcastMsg(ByVal Text As String)
    Dim Packet As String

    Packet = "broadcastmsg" & SEP_CHAR & Text & END_CHAR
    Call SendData(Packet)
End Sub

Sub EmoteMsg(ByVal Text As String)
    Dim Packet As String

    Packet = "emotemsg" & SEP_CHAR & Text & END_CHAR
    Call SendData(Packet)
End Sub

Sub MapMsg(ByVal Text As String)
    Dim Packet As String

    Packet = "mapmsg" & SEP_CHAR & Text & END_CHAR
    Call SendData(Packet)
End Sub

Sub PlayerMsg(ByVal Text As String, ByVal MsgTo As String)
    Dim Packet As String

    Packet = "playermsg" & SEP_CHAR & MsgTo & SEP_CHAR & Text & END_CHAR
    Call SendData(Packet)
End Sub

Sub AdminMsg(ByVal Text As String)
    Dim Packet As String

    Packet = "adminmsg" & SEP_CHAR & Text & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendPlayerMove()
    Dim Packet As String

    Packet = "playermove" & SEP_CHAR & GetPlayerDir(MyIndex) & SEP_CHAR & Player(MyIndex).Moving & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendPlayerDir()
    Dim Packet As String

    Packet = "playerdir" & SEP_CHAR & GetPlayerDir(MyIndex) & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendPlayerRequestNewMap()
    Dim Packet As String

    Packet = "requestnewmap" & SEP_CHAR & GetPlayerDir(MyIndex) & END_CHAR
    Call SendData(Packet)
End Sub

Public Sub SendMap()
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Optimized function.
' ****************************************************************

    Dim Packet As String, P1 As String, P2 As String
    Dim X As Long
    Dim Y As Long

    With Map
        Packet = "MAPDATA" & SEP_CHAR & GetPlayerMap(MyIndex) & SEP_CHAR & Trim$(.name) & SEP_CHAR & .Revision & SEP_CHAR & .Moral & SEP_CHAR & .Up & SEP_CHAR & .Down & SEP_CHAR & .Left & SEP_CHAR & .Right & SEP_CHAR & .Music & SEP_CHAR & .BootMap & SEP_CHAR & .BootX & SEP_CHAR & .BootY & SEP_CHAR & .Shop & SEP_CHAR & .Indoors & SEP_CHAR
    End With

    For Y = 0 To MAX_MAPY
        For X = 0 To MAX_MAPX
            With Map.Tile(X, Y)
                Packet = Packet & .Ground & SEP_CHAR & .Mask & SEP_CHAR & .Anim & SEP_CHAR & .Mask2 & SEP_CHAR & .M2Anim & SEP_CHAR & .Fringe & SEP_CHAR & .FAnim & SEP_CHAR & .Fringe2 & SEP_CHAR & .F2Anim & SEP_CHAR & .Type & SEP_CHAR & .Data1 & SEP_CHAR & .Data2 & SEP_CHAR & .Data3 & SEP_CHAR
            End With
        Next X
    Next Y

    With Map
        For X = 1 To MAX_MAP_NPCS
            Packet = Packet & .Npc(X) & SEP_CHAR
        Next X
    End With

    Packet = Packet & END_CHAR

    X = Int(Len(Packet) / 2)
    P1 = Mid$(Packet, 1, X)
    P2 = Mid$(Packet, X + 1, Len(Packet) - X)
    Call SendData(Packet)
End Sub

Sub WarpMeTo(ByVal name As String)
    Dim Packet As String

    Packet = "WARPMETO" & SEP_CHAR & name & END_CHAR
    Call SendData(Packet)
End Sub

Sub WarpToMe(ByVal name As String)
    Dim Packet As String

    Packet = "WARPTOME" & SEP_CHAR & name & END_CHAR
    Call SendData(Packet)
End Sub

Sub WarpTo(ByVal MapNum As Long)
    Dim Packet As String

    Packet = "WARPTO" & SEP_CHAR & MapNum & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendSetAccess(ByVal name As String, ByVal Access As Byte)
    Dim Packet As String

    Packet = "SETACCESS" & SEP_CHAR & name & SEP_CHAR & Access & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendSetSprite(ByVal SpriteNum As Long)
    Dim Packet As String

    Packet = "SETSPRITE" & SEP_CHAR & SpriteNum & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendPlayerSprite(ByVal SpriteNum As Integer, ByVal name As String)
    Dim Packet As String

    Packet = "PLAYERSPRITE" & SEP_CHAR & SpriteNum & SEP_CHAR & name & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendRequestEditSign()
    Dim Packet As String

    Packet = "REQUESTEDITSIGN" & END_CHAR
    Call SendData(Packet)
End Sub

Public Sub SendSaveSign(ByVal SignNum As Long)
    Dim Packet As String

    With Sign(SignNum)
        Packet = "SAVESIGN" & SEP_CHAR & SignNum & SEP_CHAR & Trim$(.name) & SEP_CHAR & Trim$(.Background) & SEP_CHAR & Trim$(.Line1) & SEP_CHAR & Trim$(.Line2) & SEP_CHAR & Trim$(.Line3) & END_CHAR
    End With

    Call SendData(Packet)
End Sub

Sub SendKick(ByVal name As String)
    Dim Packet As String

    Packet = "KICKPLAYER" & SEP_CHAR & name & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendBan(ByVal name As String)
    Dim Packet As String

    Packet = "BANPLAYER" & SEP_CHAR & name & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendUnBan(ByVal name As String)
    Dim Packet As String

    Packet = "UNBANPLAYER" & SEP_CHAR & name & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendBanList()
    Dim Packet As String

    Packet = "BANLIST" & END_CHAR
    Call SendData(Packet)
End Sub
Sub SendRequestEditItem()
    Dim Packet As String

    Packet = "REQUESTEDITITEM" & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendRequestEditGuild()
    Dim Packet As String

    Packet = "REQUESTEDITGUILD" & END_CHAR
    Call SendData(Packet)
End Sub

Public Sub SendSaveItem(ByVal ItemNum As Long)
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Optimized function.
' ****************************************************************

    Dim Packet As String

    With Item(ItemNum)
        Packet = "SAVEITEM" & SEP_CHAR & ItemNum & SEP_CHAR & Trim$(.name) & SEP_CHAR & .Pic & SEP_CHAR & .Type & SEP_CHAR & .Data1 & SEP_CHAR & .Data2 & SEP_CHAR & .Data3 & END_CHAR
    End With

    Call SendData(Packet)
End Sub

Public Sub SendSaveGuild(ByVal Guild As Long, ByVal name As String, ByVal Abr As String, ByVal Founder As String)
    ' ****************************************************************
    ' * WHEN    WHO    WHAT
    ' * ----    ---    ----
    ' * 08/22/2007  Magnus   Added Function.
    ' ****************************************************************
    Dim Packet As String

    Packet = "SAVEGUILD" & SEP_CHAR & Guild & SEP_CHAR & name & SEP_CHAR & Abr & SEP_CHAR & Founder & END_CHAR

    Call SendData(Packet)

End Sub

Sub SendRequestEditNpc()
    Dim Packet As String

    Packet = "REQUESTEDITNPC" & END_CHAR
    Call SendData(Packet)
End Sub

Public Sub SendSaveNpc(ByVal NpcNum As Long)
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Optimized function.
' ****************************************************************

    Dim Packet As String

    With Npc(NpcNum)
        Packet = "SAVENPC" & SEP_CHAR & NpcNum & SEP_CHAR & Trim$(.name) & SEP_CHAR & Trim$(.AttackSay) & SEP_CHAR & .Sprite & SEP_CHAR & .SpawnSecs & SEP_CHAR & .Behavior & SEP_CHAR & .Range & SEP_CHAR & .DropChance & SEP_CHAR & .DropItem & SEP_CHAR & .DropItemValue & SEP_CHAR & .STR & SEP_CHAR & .DEF & SEP_CHAR & .speed & SEP_CHAR & .MAGI & SEP_CHAR & .MaxHP & SEP_CHAR & .GiveEXP & SEP_CHAR & .ShopCall & END_CHAR
    End With

    Call SendData(Packet)
End Sub

Sub SendMapRespawn()
    Dim Packet As String

    Packet = "MAPRESPAWN" & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendUseItem(ByVal InvNum As Long)
    Dim Packet As String

    Packet = "USEITEM" & SEP_CHAR & InvNum & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendDropItem(ByVal InvNum, ByVal Ammount As Long)
    Dim Packet As String

    Packet = "MAPDROPITEM" & SEP_CHAR & InvNum & SEP_CHAR & Ammount & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendWhosOnline()
    Dim Packet As String

    Packet = "WHOSONLINE" & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendMOTDChange(ByVal MOTD As String)
    Dim Packet As String

    Packet = "SETMOTD" & SEP_CHAR & MOTD & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendRequestEditShop()
    Dim Packet As String

    Packet = "REQUESTEDITSHOP" & END_CHAR
    Call SendData(Packet)
End Sub

Public Sub SendSaveShop(ByVal ShopNum As Long)
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Optimized function.
' ****************************************************************

    Dim Packet As String
    Dim i As Long

    With Shop(ShopNum)
        Packet = "SAVESHOP" & SEP_CHAR & ShopNum & SEP_CHAR & Trim$(.name) & SEP_CHAR & Trim$(.JoinSay) & SEP_CHAR & Trim$(.LeaveSay) & SEP_CHAR & .FixesItems & SEP_CHAR
    End With

    For i = 1 To MAX_TRADES
        With Shop(ShopNum).TradeItem(i)
            Packet = Packet & .GiveItem & SEP_CHAR & .GiveValue & SEP_CHAR & .GetItem & SEP_CHAR & .GetValue & SEP_CHAR & .GiveItem2 & SEP_CHAR & .GiveValue2 & SEP_CHAR
        End With
    Next i

    Packet = Packet & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendRequestEditSpell()
    Dim Packet As String

    Packet = "REQUESTEDITSPELL" & END_CHAR
    Call SendData(Packet)
End Sub

Public Sub SendSaveSpell(ByVal SpellNum As Long)
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Optimized function.
' ****************************************************************

    Dim Packet As String

    With Spell(SpellNum)
        Packet = "SAVESPELL" & SEP_CHAR & SpellNum & SEP_CHAR & Trim$(.name) & SEP_CHAR & .ClassReq & SEP_CHAR & .LevelReq & SEP_CHAR & .Type & SEP_CHAR & .Data1 & SEP_CHAR & .Data2 & SEP_CHAR & .Data3 & SEP_CHAR & .MPReq & SEP_CHAR & .Graphic & END_CHAR
    End With

    Call SendData(Packet)
End Sub

Sub SendRequestEditMap()
    Dim Packet As String

    Packet = "REQUESTEDITMAP" & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendPartyRequest(ByVal name As String)
    Dim Packet As String

    Packet = "PARTY" & SEP_CHAR & name & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendJoinParty()
    Dim Packet As String

    Packet = "JOINPARTY" & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendLeaveParty()
    Dim Packet As String

    Packet = "LEAVEPARTY" & END_CHAR
    Call SendData(Packet)
End Sub

Sub ReSync()
    Dim Packet As String

    Packet = "RESYNC" & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendInnSleep()
    Dim Packet As String
    Packet = "INNSLEEP" & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendBanDestroy()
    Dim Packet As String

    Packet = "BANDESTROY" & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendRequestLocation()
    Dim Packet As String

    Packet = "REQUESTLOCATION" & END_CHAR
    Call SendData(Packet)
End Sub

Sub SendBugReport(ByVal Message As String, BugType As Byte, BugOccur As Byte, BugRepeat As Byte)
    Dim Packet As String

    Packet = "BUGREPORT" & SEP_CHAR & Message & SEP_CHAR & BugType & SEP_CHAR & BugOccur & SEP_CHAR & BugRepeat & END_CHAR
    Call SendData(Packet)
End Sub
