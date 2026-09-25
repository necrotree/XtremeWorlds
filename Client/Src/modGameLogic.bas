Attribute VB_Name = "modGameLogic"
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Added correct procedures from modTypes.bas.
' ****************************************************************
Option Explicit


Public Sub Main()
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Added map constants, removed map dir check.
' ****************************************************************

    Dim i As Long
    Dim FileName As String

    Call SetStatus("Loading...")
    frmSendGetData.Visible = True

    FileName = App.Path & DATA_PATH & "Data.dat"

    ' Make sure we set that we aren't in the game
    InGame = False
    GettingMap = True
    InEditor = False
    InItemsEditor = False
    InNpcEditor = False
    InShopEditor = False

    ' Init text vars
    vbQuote = ChrW$(34)

    ' Grab hd serial and model numbers for submition
    Call GrabHD

    ' Clear out players
    For i = 1 To HighIndex
        Call ClearPlayer(i)
    Next i
    Call ClearTempTile

    ' Initiate DirectX and Surfaces
    Call SetStatus("Initializing Direct3D 11")
    Call InitDirectX
    ' InitDirectX creates all surfaces.

    Call SetStatus("Loading Game Data")
    FileName = App.Path & DATA_PATH & "Data.dat"

    Call SetStatus("Registering Plugins")
    LoadDllList

    If Not FileExist("data\Data.dat") Then
        GameData.IP = "127.0.0.1"
        GameData.Port = 7234
        Dim F  As Long
        F = FreeFile
        Open FileName For Binary As #F
        Put #F, , GameData
        Close #F
    Else
        F = FreeFile
        Open FileName For Binary As #F
        Get #F, , GameData
        Close #F
    End If

    GameData.PlayerX = 32
    GameData.PlayerY = 32

    Call SetStatus("Initializing TCP settings")
    Call TcpInit

' Call SetStatus("Initializing FMod")
' If FileExist("data\Data.dat") Then
' MUSIC_EXT = Trim$(GetVar(FileName, "MUSICINFO", "MUSICEXT"))
' Else
' MUSIC_EXT = ".mid"
' Call PutVar(FileName, "MUSICINFO", "MUSICEXT", ".mid")
' End If
' FModInit = True
' If LenB(MUSIC_EXT) <> 0 Then
' FModInit = True
' If FSOUND_Init(44100, 32, 0) = 0 Then
' FModInit = False
' 'Error
' MsgBox "An error occured initializing fmod!  Sound will not play!" & vbCrLf & _
' FSOUND_GetErrorString(FSOUND_GetError), vbOKOnly
' End If
' FSOUND_SetVolume FSOUND_ALL, 0
' End If

    frmSendGetData.Visible = False

    If GameData.Autoupdater = 1 Then
        frmAutoPatcher.Show
    Else
        frmMainMenu.Show
    End If

End Sub

Sub GameInit()
    Unload frmMainMenu

    frmMainGame.Visible = True
    frmMainGame.lblGameName = Trim$(GAME_NAME)
    frmSendGetData.Visible = False

End Sub

Public Sub GameLoop()
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Optimized function, added font constants.
' ****************************************************************

    Dim Tick As Long
    Dim TickFPS As Long
    Dim FPS As Long
    Dim X As Long
    Dim Y As Long
    Dim i As Long
    Dim rec_back As RECT
    Dim WalkTimer As Long

    WalkTimer = GetTickCount

    ' Set the focus
    Call SetFocusOnGame

    ' Set font
    Call SetFont(FONT_NAME, FONT_SIZE)

    ' Used for calculating fps
    TickFPS = GetTickCount
    FPS = 0

    Do While InGame
        Tick = GetTickCount

        ' Check to make sure they aren't trying to auto do anything
        If GetAsyncKeyState(VK_UP) >= 0 And DirUp = True Then DirUp = False
        If GetAsyncKeyState(VK_DOWN) >= 0 And DirDown = True Then DirDown = False
        If GetAsyncKeyState(VK_LEFT) >= 0 And DirLeft = True Then DirLeft = False
        If GetAsyncKeyState(VK_RIGHT) >= 0 And DirRight = True Then DirRight = False
        If GetAsyncKeyState(VK_CONTROL) >= 0 And ControlDown = True Then ControlDown = False
        If GetAsyncKeyState(VK_SHIFT) >= 0 And ShiftDown = True Then ShiftDown = False

        ' Check to make sure we are still connected
        If Not IsConnected Then InGame = False

        If frmMainGame.WindowState <> vbMinimized Then

            Call CheckSurfaces

            If Not GettingMap Then
            

                rec.top = 0
                rec.Bottom = (MAX_MAPY + 1) * 32
                rec.Left = 0
                rec.Right = (MAX_MAPX + 1) * 32

                DD_BackBuffer.BltColorFill rec, RGB(0, 0, 0)
                DD_MiddleBuffer.BltColorFill rec, RGB(0, 0, 0)

                ' BltMap

                ' Blit out the items
                For i = 1 To MAX_MAP_ITEMS
                    If MapItem(i).Num > 0 Then
                        Call BltItem(i)
                    End If
                Next i

                ' Blit out the npcs
                For i = 1 To MAX_MAP_NPCS
                    Call BltNpc(i)
                Next i

                ' Blit out players
                For i = 1 To HighIndex
                    If IsPlaying(i) And GetPlayerMap(i) = GetPlayerMap(MyIndex) Then
                        Call BltPlayer(i)
                    End If
                Next i

                For i = 1 To HighIndex
                    If IsPlaying(i) And GetPlayerMap(i) = GetPlayerMap(MyIndex) Then
                        Call BltPlayerTop(i)
                    End If
                Next i

                ' Blit Spell
                ' If GetVar(App.Path & DATA_PATH & "Data.dat", "OPTIONS", "SPELLGFX") = 1 Then
                If GameData.SpellGFX = 1 Then
                    Call BltSpell(VicX, VicY, SpellAnim)
                End If

                rec.top = 0
                rec.Bottom = (MAX_MAPY + 1) * 32
                rec.Left = 0
                rec.Right = (MAX_MAPX + 1) * 32

                Call DD_BackBuffer.BltFast(0, 0, DD_LowerBuffer, rec, True)
                Call DD_BackBuffer.BltFast(0, 0, DD_MiddleBuffer, rec, True)
                Call DD_BackBuffer.BltFast(0, 0, DD_UpperBuffer, rec, True)

                ' Lock the backbuffer so we can draw text and names
                TexthDC = DD_BackBuffer.GetDC

                For i = 1 To HighIndex
                    If IsPlaying(i) And GetPlayerMap(i) = GetPlayerMap(MyIndex) Then
                        ' If GetVar(App.Path & DATA_PATH & "Data.dat", "OPTIONS", "PLAYERNAMES") = "1" Then
                        If GameData.PlayerNames = 1 Then
                            Call DrawPlayerName(i)
                            Call DrawPlayerGuildName(i)
                        ' ElseIf GetVar(App.Path & DATA_PATH & "Data.dat", "OPTIONS", "PLAYERNAMES") = "2" Then
                        ElseIf GameData.PlayerNames = 2 Then
                            If Player(i).X = CurX And Player(i).Y = CurY Then
                                Call DrawPlayerName(i)
                                Call DrawPlayerGuildName(i)
                            End If
                        End If
                    End If
                Next i

                ' Draw NPC Names
                For i = 1 To MAX_MAP_NPCS
                    If MapNpc(i).Num > 0 Then
                        ' If GetVar(App.Path & DATA_PATH & "Data.dat", "OPTIONS", "NPCNAMES") = "1" Then
                        If GameData.NpcNames = 1 Then
                            Call DrawMapNPCName(i)
                        ' ElseIf GetVar(App.Path & DATA_PATH & "Data.dat", "OPTIONS", "NPCNAMES") = "2" Then
                        ElseIf GameData.NpcNames = 2 Then
                            If MapNpc(i).X = CurX And MapNpc(i).Y = CurY Then
                                Call DrawMapNPCName(i)
                            End If
                        End If
                    End If
                Next i

                ' draw damage above player's head
                If NPCWho > 0 Then
                    If MapNpc(NPCWho).Num > 0 Then
                        If GetTickCount < NPCDmgTime + 2000 Then
                            Call DrawText(TexthDC, (Player(MyIndex).X) * PIC_X + (Int(Len(NPCDmgDamage)) / 2) * 3 + Player(MyIndex).XOffset, (Player(MyIndex).Y) * PIC_Y - 30 + Player(MyIndex).YOffset - II, NPCDmgDamage, QBColor(BrightRed))
                        End If
                        II = II + 1
                    End If
                End If

                ' draw damage above NPC's head
                If NPCWho > 0 Then
                    If MapNpc(NPCWho).Num > 0 Then
                        If GetTickCount < DmgTime + 2000 Then
                            Call DrawText(TexthDC, (MapNpc(NPCWho).X) * PIC_X + (Int(Len(DmgDamage)) / 2) * 3 + MapNpc(NPCWho).XOffset, (MapNpc(NPCWho).Y) * PIC_Y - 57 + MapNpc(NPCWho).YOffset - iii, DmgDamage, QBColor(White))
                        End If
                        iii = iii + 1
                    End If
                End If

                ' Blit out attribs if in editor
                If InEditor Then
                    For Y = 0 To MAX_MAPY
                        For X = 0 To MAX_MAPX
                            With Map.Tile(X, Y)
                                If .Type = TILE_TYPE_BLOCKED Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "B", QBColor(BrightRed))
                                If .Type = TILE_TYPE_HEAL Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "H", QBColor(BrightGreen))
                                If .Type = TILE_TYPE_KILL Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "D", QBColor(BrightRed))
                                If .Type = TILE_TYPE_WARP Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "W", QBColor(BrightBlue))
                                If .Type = TILE_TYPE_ITEM Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "I", QBColor(White))
                                If .Type = TILE_TYPE_NPCAVOID Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "N", QBColor(White))
                                If .Type = TILE_TYPE_KEY Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "K", QBColor(White))
                                If .Type = TILE_TYPE_KEYOPEN Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "O", QBColor(White))
                                If .Type = TILE_TYPE_DOOR Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "Door", QBColor(Pink))
                                If .Type = TILE_TYPE_SIGN Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "S", QBColor(Yellow))
                                If .Type = TILE_TYPE_MSG Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "Msg", QBColor(White))
                                If .Type = TILE_TYPE_SPRITE Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "Sprt", QBColor(BrightBlue))
                                If .Type = TILE_TYPE_NPCSPAWN Then Call DrawText(TexthDC, X * PIC_X + 8, Y * PIC_Y + 8, "Npc", QBColor(Yellow))
                            End With
                        Next X
                    Next Y
                End If

                ' Blit the text they are putting in
                frmMainGame.txtMyTextBox.Text = MyText
                If Len(MyText) > 4 Then
                    frmMainGame.txtMyTextBox.SelStart = Len(MyText) + 1
                End If
                
                ' draw FPS
                If BFPS Then
                    Call DrawText(TexthDC, (MAX_MAPX - 1) * PIC_X, 1, Trim$("FPS: " & GameFPS), QBColor(Yellow))
                End If

                ' draw cursor and player X and Y locations
                If BLoc Then
                    Call DrawText(TexthDC, 0, 1, Trim$("cur x: " & CurX & " y: " & CurY), QBColor(Yellow))
                    Call DrawText(TexthDC, 0, 17, Trim$("loc x: " & GetPlayerX(MyIndex) & " y: " & GetPlayerY(MyIndex)), QBColor(Yellow))
                    Call DrawText(TexthDC, 0, 33, Trim$(" (map #" & GetPlayerMap(MyIndex) & ")"), QBColor(Yellow))
                End If

                ' Draw map name
                ' If Map.Moral = MAP_MORAL_NONE Then
                ' Call DrawText(TexthDC, Int((MAX_MAPX + 1) * PIC_X / 2) - (Int(Len(Trim$(Map.Name)) / 2) * 8), 1, Trim$(Map.Name), QBColor(BrightRed))
                ' Else
                ' Call DrawText(TexthDC, Int((MAX_MAPX + 1) * PIC_X / 2) - (Int(Len(Trim$(Map.Name)) / 2) * 8), 1, Trim$(Map.Name), QBColor(White))
                ' End If

                ' Release DC
                Call DD_BackBuffer.ReleaseDC(TexthDC)

            Else
                ' Lock the backbuffer so we can draw text and names
                TexthDC = DD_BackBuffer.GetDC

                ' Check if we are getting a map, and if we are tell them so
                Call DrawText(TexthDC, 50, 50, "Receiving Map...", QBColor(BrightCyan))

                ' Release DC
                Call DD_BackBuffer.ReleaseDC(TexthDC)
            End If

            ' Get the rect for the back buffer to blit from
            With rec
                .top = 0
                .Bottom = (MAX_MAPY + 1) * PIC_Y
                .Left = 0
                .Right = (MAX_MAPX + 1) * PIC_X
            End With

            ' Present to the game picture box through the DXGI swap chain.
            Call PresentGameFrame

        End If

        If GetTickCount > WalkTimer + 30 Then
            ' Check if player is trying to move
            Call CheckMovement

            ' Check to see if player is trying to attack
            Call CheckAttack

            ' Process player movements (actually move them)
            For i = 1 To HighIndex
                If IsPlaying(i) Then
                    If Player(i).Moving > 0 Then
                        Call ProcessMovement(i)
                    End If
                End If
            Next i

            ' Process npc movements (actually move them)
            For i = 1 To MAX_MAP_NPCS
                If Map.Npc(i) > 0 Then
                    Call ProcessNpcMovement(i)
                End If
            Next i

            ' Handle the volume of the music
            Call HandleVolume

            WalkTimer = GetTickCount
        End If

        ' Change map animation every 250 milliseconds
        If GetTickCount > MapAnimTimer + 250 Then
            If MapAnim = 0 Then
                MapAnim = 1
                BltMap
            Else
                MapAnim = 0
                BltMap
            End If
            MapAnimTimer = GetTickCount
        End If

        ' Lock fps
        Do While GetTickCount < Tick + 15
            DoEvents
            Sleep 1
        Loop

        ' Calculate fps
        If GetTickCount > TickFPS + 1000 Then
            GameFPS = FPS
            TickFPS = GetTickCount
            FPS = 0
        Else
            FPS = FPS + 1
        End If

        DoEvents

    Loop

    frmMainGame.Visible = False
    frmSendGetData.Visible = True
    Call SetStatus("Destroying game data...")

    ' Report disconnection if server disconnects
    If IsConnected = False Then
        Call MsgBox("Thank you for playing " & GAME_NAME & "!", vbOKOnly, GAME_NAME)
        frmMainMenu.Visible = True
    End If

    ' Shutdown the game
    Call GameDestroy

End Sub

Sub ProcessMovement(ByVal index As Long)
    ' Check to see if player is out of SP if so then make them walk
    If Player(MyIndex).Moving = MOVING_RUNNING Then

        If GetPlayerSP(MyIndex) <= 0 Then
            Call SetPlayerSP(MyIndex, 0)
            Player(MyIndex).Moving = MOVING_WALKING
        Else
            If GetTickCount - SPDrain >= SPTick Then
                Call SetPlayerSP(MyIndex, GetPlayerSP(MyIndex) - 1)
                SPDrain = GetTickCount
            End If
        End If
    End If

    ' Check if player is walking, and if so process moving them over
    If Player(index).Moving = MOVING_WALKING Then
        Select Case GetPlayerDir(index)
            Case DIR_UP
                Player(index).YOffset = Player(index).YOffset - WALK_SPEED
            Case DIR_DOWN
                Player(index).YOffset = Player(index).YOffset + WALK_SPEED
            Case DIR_LEFT
                Player(index).XOffset = Player(index).XOffset - WALK_SPEED
            Case DIR_RIGHT
                Player(index).XOffset = Player(index).XOffset + WALK_SPEED
        End Select

    ' Check if player is running, and if so process moving them over
    ElseIf Player(index).Moving = MOVING_RUNNING Then
        Select Case GetPlayerDir(index)
            Case DIR_UP
                Player(index).YOffset = Player(index).YOffset - RUN_SPEED
            Case DIR_DOWN
                Player(index).YOffset = Player(index).YOffset + RUN_SPEED
            Case DIR_LEFT
                Player(index).XOffset = Player(index).XOffset - RUN_SPEED
            Case DIR_RIGHT
                Player(index).XOffset = Player(index).XOffset + RUN_SPEED
        End Select

        ' Update SP
        frmMainGame.lblSP(0) = "SP: " & Val(GetPlayerSP(MyIndex)) & "/" & Val(GetPlayerMaxSP(MyIndex))
        frmMainGame.lblSP(1) = "SP: " & Val(GetPlayerSP(MyIndex)) & "/" & Val(GetPlayerMaxSP(MyIndex))
        frmMainGame.shpSP.Width = (((GetPlayerSP(MyIndex) / 100) / (GetPlayerMaxSP(MyIndex) / 100)) * 153)

    End If

    ' Check if completed walking over to the next tile
    If (Player(index).XOffset = 0) And (Player(index).YOffset = 0) Then
        Player(index).Moving = 0
    End If

End Sub

Sub ProcessNpcMovement(ByVal MapNpcNum As Long)
    ' Check if player is walking, and if so process moving them over
    If MapNpc(MapNpcNum).Moving = MOVING_WALKING Then
        Select Case MapNpc(MapNpcNum).Dir
            Case DIR_UP
                MapNpc(MapNpcNum).YOffset = MapNpc(MapNpcNum).YOffset - WALK_SPEED
            Case DIR_DOWN
                MapNpc(MapNpcNum).YOffset = MapNpc(MapNpcNum).YOffset + WALK_SPEED
            Case DIR_LEFT
                MapNpc(MapNpcNum).XOffset = MapNpc(MapNpcNum).XOffset - WALK_SPEED
            Case DIR_RIGHT
                MapNpc(MapNpcNum).XOffset = MapNpc(MapNpcNum).XOffset + WALK_SPEED
        End Select

        ' Check if completed walking over to the next tile
        If (MapNpc(MapNpcNum).XOffset = 0) And (MapNpc(MapNpcNum).YOffset = 0) Then
            MapNpc(MapNpcNum).Moving = 0
        End If
    End If
End Sub

Sub HandleKeypresses(ByVal KeyAscii As Integer)
    Dim ChatText As String
    Dim name As String
    Dim i As Long
    Dim n As Long

    ' Handle when the player presses the return key
    If (KeyAscii = vbKeyReturn) Then
        ' If frmMainGame.Width = 13275 Then
        ' Exit Sub
        ' Else
        ' Broadcast message
        If Mid$(MyText, 1, 1) = "'" Then
            ChatText = Mid$(MyText, 2, Len(MyText) - 1)
            If Len(Trim$(ChatText)) > 0 Then
                Call BroadcastMsg(ChatText)
            End If
            MyText = vbNullString
            Exit Sub
        End If

        ' Emote message
        If Mid$(MyText, 1, 1) = "-" Then
            ChatText = Mid$(MyText, 2, Len(MyText) - 1)
            If Len(Trim$(ChatText)) > 0 Then
                Call EmoteMsg(ChatText)
            End If
            MyText = vbNullString
            Exit Sub
        End If

        ' Player message
        If Mid$(MyText, 1, 1) = "!" Then
            ChatText = Mid$(MyText, 2, Len(MyText) - 1)
            name = vbNullString

            ' Get the desired player from the user text
            For i = 1 To Len(ChatText)
                If Mid$(ChatText, i, 1) <> " " Then
                    name = name & Mid$(ChatText, i, 1)
                Else
                    Exit For
                End If
            Next i

            ' Make sure they are actually sending something
            If Len(ChatText) - i > 0 Then
                ChatText = Mid$(ChatText, i + 1, Len(ChatText) - i)

                ' Send the message to the player
                Call PlayerMsg(ChatText, name)
            Else
                Call AddText("Usage: !playername msghere", AlertColor)
            End If
            MyText = vbNullString
            Exit Sub
        End If

        ' // Commands //
        ' Help
        If LCase$(Mid$(MyText, 1, 5)) = "/help" Then
            Call AddText("Social Commands:", HelpColor)
            Call AddText("'msghere = Broadcast Message", HelpColor)
            Call AddText("-msghere = Emote Message", HelpColor)
            Call AddText("!namehere msghere = Private Message", HelpColor)
            Call AddText("Available Commands: /help, /info, /who, /fps, /inv, /stats, /train, /trade, /party, /join, /leave, /options, /sync, /resync)", HelpColor)
            MyText = vbNullString
            Exit Sub
        End If

        ' Verification User
        If LCase$(Mid$(MyText, 1, 5)) = "/info" Then
            ChatText = Mid$(MyText, 6, Len(MyText) - 5)
            Call SendData("playerinforequest" & SEP_CHAR & ChatText & END_CHAR)
            MyText = vbNullString
            Exit Sub
        End If

        ' Whos Online
        If LCase$(Mid$(MyText, 1, 4)) = "/who" Then
            Call SendWhosOnline
            MyText = vbNullString
            Exit Sub
        End If

        ' Checking fps
        If LCase$(Mid$(MyText, 1, 4)) = "/fps" Then

            If Not BFPS Then
                BFPS = True
            Else
                BFPS = False
            End If

            MyText = vbNullString
            Exit Sub
        End If

        ' Show inventory
        If LCase$(Mid$(MyText, 1, 4)) = "/inv" Then
            Call UpdateInventory
            frmMainGame.picInv.Visible = True
            MyText = vbNullString
            Exit Sub
        End If

        ' Request stats
        If LCase$(Mid$(MyText, 1, 6)) = "/stats" Then
            Call SendData("getstats" & END_CHAR)
            MyText = vbNullString
            Exit Sub
        End If

        ' Show training
        If LCase$(Mid$(MyText, 1, 6)) = "/train" Then
            Call CloseSideMenu
            frmMainGame.picMnuTrain.Visible = True
            frmMainGame.cmbStat.ListIndex = 0
            MyText = vbNullString
            Exit Sub
        End If

        ' Request Trade
        If LCase$(Mid$(MyText, 1, 6)) = "/trade" Then
            Call SendData("trade" & END_CHAR)
            MyText = vbNullString
            Exit Sub
        End If

        ' Sign
        Dim SignPacket As String
        If Map.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex)).Type = TILE_TYPE_SIGN Then
            SignNum = Map.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex)).Data1
            SignPacket = "requestsign" & SEP_CHAR & SignNum & END_CHAR
            Call SendData(SignPacket)
        End If

        ' Party request
        If LCase$(Mid$(MyText, 1, 6)) = "/party" Then
            ' Make sure they are actually sending something
            If Len(MyText) > 7 Then
                ChatText = Mid$(MyText, 8, Len(MyText) - 7)
                Call SendPartyRequest(ChatText)
            Else
                Call AddText("Usage: /party playernamehere", AlertColor)
            End If
            MyText = vbNullString
            Exit Sub
        End If

        ' Map inn
        'If LCase$(Mid$(MyText, 1, 6)) = "/sleep" Then
        '    Call SendInnSleep
        '    MyText = vbNullString
        '    Exit Sub
        'End If

        ' Options
        If LCase$(Mid$(MyText, 1, 8)) = "/options" Then
            MyText = vbNullString
            frmOptions.Show vbModal
            Exit Sub
        End If

        ' Sync
        If LCase$(Mid$(MyText, 1, 5)) = "/sync" Or LCase$(Mid$(MyText, 1, 7)) = "/resync" Then
            Call ReSync
            MyText = vbNullString
            Exit Sub
        End If

        ' Join party
        If LCase$(Mid$(MyText, 1, 5)) = "/join" Then
            Call SendJoinParty
            MyText = vbNullString
            Exit Sub
        End If

        ' Leave party
        If LCase$(Mid$(MyText, 1, 6)) = "/leave" Then
            Call SendLeaveParty
            MyText = vbNullString
            Exit Sub
        End If

        ' // Moniter Admin Commands //
        If GetPlayerAccess(MyIndex) > 0 Then
            ' Admin Help
            If LCase$(Mid$(MyText, 1, 6)) = "/admin" Then
                Call AddText("Social Commands:", HelpColor)
                Call AddText("""msghere = Global Admin Message", HelpColor)
                Call AddText("=msghere = Private Admin Message", HelpColor)
                Call AddText("Available Commands: /admin, /loc, /mapeditor, /warpmeto, /warptome, /warpto, /setsprite, /playersprite, /signedit, /mapreport, /kick, /ban, /unban, /itemedit, /respawn, /npcedit, /motd, /shopedit, /spelledit, /guild", HelpColor)
                MyText = vbNullString
                Exit Sub
            End If

            If LCase$(Mid$(MyText, 1, 6)) = "/guild" Then
                Call AddText("Your guild is " & GetPlayerGuild(MyIndex) & ".", HelpColor)
                ' Call AddText("Guild name: " & Trim$(Guild(GetPlayerGuild(MyIndex)).name), HelpColor)
                MyText = vbNullString
                Exit Sub
            End If

            ' Kicking a player
            If LCase$(Mid$(MyText, 1, 5)) = "/kick" Then
                If Len(MyText) > 6 Then
                    MyText = Mid$(MyText, 7, Len(MyText) - 6)
                    Call SendKick(MyText)
                End If
                MyText = vbNullString
                Exit Sub
            End If

            ' Global Message
            If Mid$(MyText, 1, 1) = vbQuote Then
                ChatText = Mid$(MyText, 2, Len(MyText) - 1)
                If Len(Trim$(ChatText)) > 0 Then
                    Call GlobalMsg(ChatText)
                End If
                MyText = vbNullString
                Exit Sub
            End If

            ' Admin Message
            If Mid$(MyText, 1, 1) = "=" Then
                ChatText = Mid$(MyText, 2, Len(MyText) - 1)
                If Len(Trim$(ChatText)) > 0 Then
                    Call AdminMsg(ChatText)
                End If
                MyText = vbNullString
                Exit Sub
            End If
        End If

        ' // Mapper Admin Commands //
        If GetPlayerAccess(MyIndex) >= ADMIN_MAPPER Then
            ' Location
            If LCase$(Mid$(MyText, 1, 4)) = "/loc" Then

                If Not BLoc Then
                    BLoc = True
                Else
                    BLoc = False
                End If

                ' Call SendRequestLocation
                MyText = vbNullString
                Exit Sub
            End If

            ' Map Editor
            If LCase$(Mid$(MyText, 1, 10)) = "/mapeditor" Then
                frmMainGame.lblMapNumber.Caption = GetPlayerMap(MyIndex)
                frmMainGame.lblMapName.Caption = Trim$(Map.name)
                Call SendRequestEditMap
                MyText = vbNullString
                Exit Sub
            End If

            ' Warping to a player
            If LCase$(Mid$(MyText, 1, 9)) = "/warpmeto" Then
                If Len(MyText) > 10 Then
                    MyText = Mid$(MyText, 10, Len(MyText) - 9)
                    Call WarpMeTo(MyText)
                End If
                MyText = vbNullString
                Exit Sub
            End If

            ' Warping a player to you
            If LCase$(Mid$(MyText, 1, 9)) = "/warptome" Then
                If Len(MyText) > 10 Then
                    MyText = Mid$(MyText, 10, Len(MyText) - 9)
                    Call WarpToMe(MyText)
                End If
                MyText = vbNullString
                Exit Sub
            End If

            ' Warping to a map
            If LCase$(Mid$(MyText, 1, 7)) = "/warpto" Then
                If Len(MyText) > 8 Then
                    MyText = Mid$(MyText, 8, Len(MyText) - 7)
                    n = Val(MyText)

                    ' Check to make sure its a valid map #
                    If n > 0 And n <= MAX_MAPS Then
                        Call WarpTo(n)
                    Else
                        Call AddText("Invalid map number.", Red)
                    End If
                End If
                MyText = vbNullString
                Exit Sub
            End If

            ' Setting sprite
            If LCase$(Mid$(MyText, 1, 10)) = "/setsprite" Then
                If Len(MyText) > 11 Then
                    ' Get sprite #
                    MyText = Mid$(MyText, 12, Len(MyText) - 11)

                    Call SendSetSprite(Val(MyText))
                End If
                MyText = vbNullString
                Exit Sub
            End If

            ' Settings Player Sprite
            Dim sArray() As String
            If LCase$(Left$(MyText, 13)) = "/playersprite" Then
                sArray = Split(MyText, " ")
                Call SendPlayerSprite(sArray(1), sArray(2))
                MyText = vbNullString
            End If

            ' Map report
            If LCase$(Mid$(MyText, 1, 10)) = "/mapreport" Then
                Call SendData("mapreport" & END_CHAR)
                MyText = vbNullString
                Exit Sub
            End If

            ' Respawn request
            If Mid$(MyText, 1, 8) = "/respawn" Then
                Call SendMapRespawn
                MyText = vbNullString
                Exit Sub
            End If

            ' Editing sign request
            If Mid$(MyText, 1, 10) = "/signedit" Then
                Call SendRequestEditSign
                MyText = vbNullString
                Exit Sub
            End If

            ' MOTD change
            If Mid$(MyText, 1, 5) = "/motd" Then
                If Len(MyText) > 6 Then
                    MyText = Mid$(MyText, 7, Len(MyText) - 6)
                    If LenB(Trim$(MyText)) > 0 Then
                        Call SendMOTDChange(MyText)
                    End If
                End If
                MyText = vbNullString
                Exit Sub
            End If

            ' Check the ban list
            If LCase$(Mid$(MyText, 1, 8)) = "/banlist" Then
                Call SendBanList
                MyText = vbNullString
                Exit Sub
            End If


            ' // Developer Admin Commands //
            If GetPlayerAccess(MyIndex) >= ADMIN_DEVELOPER Then

                ' Banning a player
                If LCase$(Mid$(MyText, 1, 4)) = "/ban" Then
                    If Len(MyText) > 5 Then
                        MyText = Mid$(MyText, 6, Len(MyText) - 5)
                        Call SendBan(MyText)
                        MyText = vbNullString
                    End If
                    Exit Sub
                End If

                ' unBanning a player
                If LCase$(Mid$(MyText, 1, 6)) = "/unban" Then
                    If Len(MyText) > 7 Then
                        MyText = Mid$(MyText, 8, Len(MyText) - 7)
                        Call SendUnBan(MyText)
                        MyText = vbNullString
                    End If
                    Exit Sub
                End If

                ' Creating a Guild
                If LCase$(Mid$(MyText, 1, 12)) = "/createguild" Then
                    MyText = vbNullString
                    frmGuildCreate.Show vbModal
                End If

                ' Editing item request
                If Mid$(MyText, 1, 9) = "/itemedit" Then
                    Call SendRequestEditItem
                    MyText = vbNullString
                    Exit Sub
                End If


                ' Editing guild request
                If Mid$(MyText, 1, 10) = "/guildedit" Then
                    Call SendRequestEditGuild
                    MyText = vbNullString
                    Exit Sub
                End If

                ' Editing npc request
                If Mid$(MyText, 1, 8) = "/npcedit" Then
                    Call SendRequestEditNpc
                    MyText = vbNullString
                    Exit Sub
                End If

                ' Editing shop request
                If Mid$(MyText, 1, 9) = "/shopedit" Then
                    Call SendRequestEditShop
                    MyText = vbNullString
                    Exit Sub
                End If

                ' Editing spell request
                If Mid$(MyText, 1, 10) = "/spelledit" Then
                    Call SendRequestEditSpell
                    MyText = vbNullString
                    Exit Sub
                End If
            End If
        End If

        ' // Creator Admin Commands //
        If GetPlayerAccess(MyIndex) >= ADMIN_CREATOR Then
            ' Giving another player access
            If LCase$(Mid$(MyText, 1, 10)) = "/setaccess" Then
                ' Get access #
                i = Val(Mid$(MyText, 12, 1))

                MyText = Mid$(MyText, 14, Len(MyText) - 13)

                Call SendSetAccess(MyText, i)
                MyText = vbNullString
                Exit Sub
            End If

            ' Server Reboot
            If LCase$(Mid$(MyText, 1, 7)) = "/reboot" Then
                Call SendData("rebootserver" & END_CHAR)
                MyText = vbNullString
                Exit Sub
            End If

            ' Server Shutdown
            If LCase$(Mid$(MyText, 1, 9)) = "/shutdown" Then
                Call SendData("shutdown" & END_CHAR)
                MyText = vbNullString
                Exit Sub
            End If

            ' Ban destroy
            If LCase$(Mid$(MyText, 1, 15)) = "/destroybanlist" Then
                Call SendBanDestroy
                MyText = vbNullString
                Exit Sub
            End If
        End If

        ' Say message
        If Len(Trim$(MyText)) > 0 Then
            Call SayMsg(MyText)
        End If
        MyText = vbNullString
        Exit Sub
    End If

    ' Handle when the user presses the backspace key
    If (KeyAscii = vbKeyBack) Then
        If Len(MyText) > 0 Then
            MyText = Mid$(MyText, 1, Len(MyText) - 1)
        End If
    End If

    ' And if neither, then add the character to the user's text buffer
    ' If frmMainGame.Width = 13275 Then
    ' Else
    If (KeyAscii <> vbKeyReturn) And (KeyAscii <> vbKeyBack) Then
        ' Make sure they just use standard keys, no gay shitty macro keys
        If KeyAscii >= 32 And KeyAscii <= 126 Then
            If TxtHasFocus = True Then
                MyText = MyText & Chr(KeyAscii)
            End If
        End If
    End If
' End If
' End If
End Sub

Sub CheckMapGetItem()
    If GetTickCount > Player(MyIndex).MapGetTimer + 250 And LenB(Trim$(MyText)) = 0 Then
        Player(MyIndex).MapGetTimer = GetTickCount
        Call SendData("mapgetitem" & END_CHAR)
    End If
End Sub

Public Sub CheckAttack()
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Optimized function.
' ****************************************************************

    If ControlDown = True And Player(MyIndex).AttackTimer + 1000 < GetTickCount And Player(MyIndex).Attacking = 0 Then
        With Player(MyIndex)
            .Attacking = 1
            .AttackTimer = GetTickCount
        End With
        Call SendData("attack" & END_CHAR)
    End If
End Sub

Sub CheckInput2()
    If GettingMap = False Then
        If GetKeyState(VK_RETURN) < 0 Then
            Call CheckMapGetItem
        End If
        If GetKeyState(VK_CONTROL) < 0 Then
            ControlDown = True
        Else
            ControlDown = False
        End If
        If GetKeyState(VK_UP) < 0 Then
            DirUp = True
            DirDown = False
            DirLeft = False
            DirRight = False
        Else
            DirUp = False
        End If
        If GetKeyState(VK_DOWN) < 0 Then
            DirUp = False
            DirDown = True
            DirLeft = False
            DirRight = False
        Else
            DirDown = False
        End If
        If GetKeyState(VK_LEFT) < 0 Then
            DirUp = False
            DirDown = False
            DirLeft = True
            DirRight = False
        Else
            DirLeft = False
        End If
        If GetKeyState(VK_RIGHT) < 0 Then
            DirUp = False
            DirDown = False
            DirLeft = False
            DirRight = True
        Else
            DirRight = False
        End If
        If GetKeyState(VK_SHIFT) < 0 Then
            ShiftDown = True
        Else
            ShiftDown = False
        End If
    End If
End Sub

Sub CheckInput(ByVal KeyState As Byte, ByVal KeyCode As Integer, ByVal Shift As Integer)
    If GettingMap = False Then
        If KeyState = 1 Then
            If KeyCode = vbKeyReturn Then
                Call CheckMapGetItem
            End If
            If KeyCode = vbKeyControl Then
                ControlDown = True
            End If
            If KeyCode = vbKeyUp Then
                DirUp = True
                DirDown = False
                DirLeft = False
                DirRight = False
            End If
            If KeyCode = vbKeyDown Then
                DirUp = False
                DirDown = True
                DirLeft = False
                DirRight = False
            End If
            If KeyCode = vbKeyLeft Then
                DirUp = False
                DirDown = False
                DirLeft = True
                DirRight = False
            End If
            If KeyCode = vbKeyRight Then
                DirUp = False
                DirDown = False
                DirLeft = False
                DirRight = True
            End If
            If KeyCode = vbKeyShift Then
                ShiftDown = True
            End If
            If KeyCode = vbKeyEscape Then
                Call GameDestroy
            End If
        Else
            If KeyCode = vbKeyUp Then DirUp = False
            If KeyCode = vbKeyDown Then DirDown = False
            If KeyCode = vbKeyLeft Then DirLeft = False
            If KeyCode = vbKeyRight Then DirRight = False
            If KeyCode = vbKeyShift Then ShiftDown = False
            If KeyCode = vbKeyControl Then ControlDown = False
        End If
    End If
End Sub

Function IsTryingToMove() As Boolean
    If (DirUp = True) Or (DirDown = True) Or (DirLeft = True) Or (DirRight = True) Then
        IsTryingToMove = True
    Else
        IsTryingToMove = False
    End If
End Function

Function CanMove() As Boolean
    Dim i As Long, D As Long

    CanMove = True

    ' Make sure they aren't trying to move when they are already moving
    If Player(MyIndex).Moving <> 0 Then
        CanMove = False
        Exit Function
    End If

    ' Make sure they haven't just casted a spell
    If Player(MyIndex).CastedSpell = YES Then
        If GetTickCount > Player(MyIndex).AttackTimer + 1000 Then
            Player(MyIndex).CastedSpell = NO
        Else
            CanMove = False
            Exit Function
        End If
    End If

    D = GetPlayerDir(MyIndex)
    If DirUp Then
        Call SetPlayerDir(MyIndex, DIR_UP)

        ' Check to see if they are trying to go out of bounds
        If GetPlayerY(MyIndex) > 0 Then
            ' Check to see if the map tile is blocked or not
            If Map.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex) - 1).Type = TILE_TYPE_BLOCKED Then
                If Map.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex) - 1).Data1 = 1 Then
                    CanMove = False
                Else
                    CanMove = True
                End If

                ' Set the new direction if they weren't facing that direction
                If D <> DIR_UP Then
                    Call SendPlayerDir
                End If
                Exit Function
            End If

            ' Check to see if the key door is open or not
            If Map.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex) - 1).Type = TILE_TYPE_KEY Or Map.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex) - 1).Type = TILE_TYPE_DOOR Then
                ' This actually checks if its open or not
                If TempTile(GetPlayerX(MyIndex), GetPlayerY(MyIndex) - 1).DoorOpen = NO Then
                    CanMove = False

                    ' Set the new direction if they weren't facing that direction
                    If D <> DIR_UP Then
                        Call SendPlayerDir
                    End If
                    Exit Function
                End If
            End If

            ' Check to see if a player is already on that tile
            For i = 1 To HighIndex
                If IsPlaying(i) Then
                    If GetPlayerMap(i) = GetPlayerMap(MyIndex) Then
                        If (GetPlayerX(i) = GetPlayerX(MyIndex)) And (GetPlayerY(i) = GetPlayerY(MyIndex) - 1) Then
                            CanMove = False

                            ' Set the new direction if they weren't facing that direction
                            If D <> DIR_UP Then
                                Call SendPlayerDir
                            End If
                            Exit Function
                        End If
                    End If
                End If
            Next i

            ' Check to see if a npc is already on that tile
            For i = 1 To MAX_MAP_NPCS
                If MapNpc(i).Num > 0 Then
                    If (MapNpc(i).X = GetPlayerX(MyIndex)) And (MapNpc(i).Y = GetPlayerY(MyIndex) - 1) Then
                        CanMove = False

                        ' Set the new direction if they weren't facing that direction
                        If D <> DIR_UP Then
                            Call SendPlayerDir
                        End If
                        Exit Function
                    End If
                End If
            Next i
        Else
            ' Check if they can warp to a new map
            If Map.Up > 0 Then
                Call SendPlayerRequestNewMap
                GettingMap = True
            End If
            CanMove = False
            Exit Function
        End If
    End If

    If DirDown Then
        Call SetPlayerDir(MyIndex, DIR_DOWN)

        ' Check to see if they are trying to go out of bounds
        If GetPlayerY(MyIndex) < MAX_MAPY Then
            ' Check to see if the map tile is blocked or not
            If Map.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex) + 1).Type = TILE_TYPE_BLOCKED Then
                If Map.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex) + 1).Data1 = 1 Then
                    CanMove = False
                Else
                    CanMove = True
                End If

                ' Set the new direction if they weren't facing that direction
                If D <> DIR_DOWN Then
                    Call SendPlayerDir
                End If
                Exit Function
            End If

            ' Check to see if the key door is open or not
            If Map.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex) + 1).Type = TILE_TYPE_KEY Or Map.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex) + 1).Type = TILE_TYPE_DOOR Then
                ' This actually checks if its open or not
                If TempTile(GetPlayerX(MyIndex), GetPlayerY(MyIndex) + 1).DoorOpen = NO Then
                    CanMove = False

                    ' Set the new direction if they weren't facing that direction
                    If D <> DIR_DOWN Then
                        Call SendPlayerDir
                    End If
                    Exit Function
                End If
            End If

            ' Check to see if a player is already on that tile
            For i = 1 To HighIndex
                If IsPlaying(i) And GetPlayerMap(i) = GetPlayerMap(MyIndex) Then
                    If (GetPlayerX(i) = GetPlayerX(MyIndex)) And (GetPlayerY(i) = GetPlayerY(MyIndex) + 1) Then
                        CanMove = False

                        ' Set the new direction if they weren't facing that direction
                        If D <> DIR_DOWN Then
                            Call SendPlayerDir
                        End If
                        Exit Function
                    End If
                End If
            Next i

            ' Check to see if a npc is already on that tile
            For i = 1 To MAX_MAP_NPCS
                If MapNpc(i).Num > 0 Then
                    If (MapNpc(i).X = GetPlayerX(MyIndex)) And (MapNpc(i).Y = GetPlayerY(MyIndex) + 1) Then
                        CanMove = False

                        ' Set the new direction if they weren't facing that direction
                        If D <> DIR_DOWN Then
                            Call SendPlayerDir
                        End If
                        Exit Function
                    End If
                End If
            Next i
        Else
            ' Check if they can warp to a new map
            If Map.Down > 0 Then
                Call SendPlayerRequestNewMap
                GettingMap = True
            End If
            CanMove = False
            Exit Function
        End If
    End If

    If DirLeft Then
        Call SetPlayerDir(MyIndex, DIR_LEFT)

        ' Check to see if they are trying to go out of bounds
        If GetPlayerX(MyIndex) > 0 Then
            ' Check to see if the map tile is blocked or not
            If Map.Tile(GetPlayerX(MyIndex) - 1, GetPlayerY(MyIndex)).Type = TILE_TYPE_BLOCKED Then
                If Map.Tile(GetPlayerX(MyIndex) - 1, GetPlayerY(MyIndex)).Data1 = 1 Then
                    CanMove = False
                Else
                    CanMove = True
                End If

                ' Set the new direction if they weren't facing that direction
                If D <> DIR_LEFT Then
                    Call SendPlayerDir
                End If
                Exit Function
            End If

            ' Check to see if the key door is open or not
            If Map.Tile(GetPlayerX(MyIndex) - 1, GetPlayerY(MyIndex)).Type = TILE_TYPE_KEY Or Map.Tile(GetPlayerX(MyIndex) - 1, GetPlayerY(MyIndex)).Type = TILE_TYPE_DOOR Then
                ' This actually checks if its open or not
                If TempTile(GetPlayerX(MyIndex) - 1, GetPlayerY(MyIndex)).DoorOpen = NO Then
                    CanMove = False

                    ' Set the new direction if they weren't facing that direction
                    If D <> DIR_LEFT Then
                        Call SendPlayerDir
                    End If
                    Exit Function
                End If
            End If

            ' Check to see if a player is already on that tile
            For i = 1 To HighIndex
                If IsPlaying(i) And GetPlayerMap(i) = GetPlayerMap(MyIndex) Then
                    If (GetPlayerX(i) = GetPlayerX(MyIndex) - 1) And (GetPlayerY(i) = GetPlayerY(MyIndex)) Then
                        CanMove = False

                        ' Set the new direction if they weren't facing that direction
                        If D <> DIR_LEFT Then
                            Call SendPlayerDir
                        End If
                        Exit Function
                    End If
                End If
            Next i

            ' Check to see if a npc is already on that tile
            For i = 1 To MAX_MAP_NPCS
                If MapNpc(i).Num > 0 Then
                    If (MapNpc(i).X = GetPlayerX(MyIndex) - 1) And (MapNpc(i).Y = GetPlayerY(MyIndex)) Then
                        CanMove = False

                        ' Set the new direction if they weren't facing that direction
                        If D <> DIR_LEFT Then
                            Call SendPlayerDir
                        End If
                        Exit Function
                    End If
                End If
            Next i
        Else
            ' Check if they can warp to a new map
            If Map.Left > 0 Then
                Call SendPlayerRequestNewMap
                GettingMap = True
            End If
            CanMove = False
            Exit Function
        End If
    End If

    If DirRight Then
        Call SetPlayerDir(MyIndex, DIR_RIGHT)

        ' Check to see if they are trying to go out of bounds
        If GetPlayerX(MyIndex) < MAX_MAPX Then
            ' Check to see if the map tile is blocked or not
            If Map.Tile(GetPlayerX(MyIndex) + 1, GetPlayerY(MyIndex)).Type = TILE_TYPE_BLOCKED Then
                If Map.Tile(GetPlayerX(MyIndex) + 1, GetPlayerY(MyIndex)).Data1 = 1 Then
                    CanMove = False
                Else
                    CanMove = True
                End If

                ' Set the new direction if they weren't facing that direction
                If D <> DIR_RIGHT Then
                    Call SendPlayerDir
                End If
                Exit Function
            End If

            ' Check to see if the key door is open or not
            If Map.Tile(GetPlayerX(MyIndex) + 1, GetPlayerY(MyIndex)).Type = TILE_TYPE_KEY Or Map.Tile(GetPlayerX(MyIndex) + 1, GetPlayerY(MyIndex)).Type = TILE_TYPE_DOOR Then
                ' This actually checks if its open or not
                If TempTile(GetPlayerX(MyIndex) + 1, GetPlayerY(MyIndex)).DoorOpen = NO Then
                    CanMove = False

                    ' Set the new direction if they weren't facing that direction
                    If D <> DIR_RIGHT Then
                        Call SendPlayerDir
                    End If
                    Exit Function
                End If
            End If

            ' Check to see if a player is already on that tile
            For i = 1 To HighIndex
                If IsPlaying(i) And GetPlayerMap(i) = GetPlayerMap(MyIndex) Then
                    If (GetPlayerX(i) = GetPlayerX(MyIndex) + 1) And (GetPlayerY(i) = GetPlayerY(MyIndex)) Then
                        CanMove = False

                        ' Set the new direction if they weren't facing that direction
                        If D <> DIR_RIGHT Then
                            Call SendPlayerDir
                        End If
                        Exit Function
                    End If
                End If
            Next i

            ' Check to see if a npc is already on that tile
            For i = 1 To MAX_MAP_NPCS
                If MapNpc(i).Num > 0 Then
                    If (MapNpc(i).X = GetPlayerX(MyIndex) + 1) And (MapNpc(i).Y = GetPlayerY(MyIndex)) Then
                        CanMove = False

                        ' Set the new direction if they weren't facing that direction
                        If D <> DIR_RIGHT Then
                            Call SendPlayerDir
                        End If
                        Exit Function
                    End If
                End If
            Next i
        Else
            ' Check if they can warp to a new map
            If Map.Right > 0 Then
                Call SendPlayerRequestNewMap
                GettingMap = True
            End If
            CanMove = False
            Exit Function
        End If
    End If
End Function

Sub CheckMovement()
    If GettingMap = False Then
        If IsTryingToMove Then
            If CanMove Then
                ' Check if player has the shift key down for running
                If ShiftDown Then
                    Player(MyIndex).Moving = MOVING_RUNNING
                Else
                    Player(MyIndex).Moving = MOVING_WALKING
                End If

                Select Case GetPlayerDir(MyIndex)
                    Case DIR_UP
                        Call SendPlayerMove
                        Player(MyIndex).YOffset = PIC_Y
                        Call SetPlayerY(MyIndex, GetPlayerY(MyIndex) - 1)

                    Case DIR_DOWN
                        Call SendPlayerMove
                        Player(MyIndex).YOffset = PIC_Y * -1
                        Call SetPlayerY(MyIndex, GetPlayerY(MyIndex) + 1)

                    Case DIR_LEFT
                        Call SendPlayerMove
                        Player(MyIndex).XOffset = PIC_X
                        Call SetPlayerX(MyIndex, GetPlayerX(MyIndex) - 1)

                    Case DIR_RIGHT
                        Call SendPlayerMove
                        Player(MyIndex).XOffset = PIC_X * -1
                        Call SetPlayerX(MyIndex, GetPlayerX(MyIndex) + 1)
                End Select

                ' Gotta check :)
                If Map.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex)).Type = TILE_TYPE_WARP Then
                    GettingMap = True
                End If
            End If
        End If
    End If
End Sub

Function FindPlayer(ByVal name As String) As Long
    Dim i As Long

    For i = 1 To HighIndex
        If IsPlaying(i) Then
            ' Make sure we dont try to check a name thats to small
            If Len(GetPlayerName(i)) >= Len(Trim$(name)) Then
                If UCase$(Mid$(GetPlayerName(i), 1, Len(Trim$(name)))) = UCase$(Trim$(name)) Then
                    FindPlayer = i
                    Exit Function
                End If
            End If
        End If
    Next i

    FindPlayer = 0
End Function

Public Function FindXY(X As Single, Y As Single)
    Dim X2, Y2 As Long
    Dim xyvalue As String
    If InEditor Then
        X2 = Int(X / PIC_X)
        Y2 = Int(Y / PIC_Y)
        frmMainGame.lblMapX.Caption = X2
        frmMainGame.lblMapY.Caption = Y2
    End If
End Function

Public Sub NewCharBltSprite(ByVal ListIndexSprite As Integer)
    With rec
        If frmMainMenu.optMale.Value = True Then
            .top = Int(Class(ListIndexSprite).Sprite) * PIC_Y
        Else
            .top = Int(Class(ListIndexSprite).FSprite) * PIC_Y
        End If
        .Bottom = .top + PIC_Y
        .Left = 3 * PIC_X
        .Right = .Left + PIC_X
    End With

    With rec_pos
        .top = 0
        .Bottom = PIC_Y
        .Left = 0
        .Right = PIC_X
    End With

    If DD_SpriteSurf Is Nothing Then
    Else
        DD_SpriteSurf.BltToDC frmMainMenu.picPic.hDC, rec, rec_pos
    End If
    frmMainMenu.picPic.Refresh
End Sub

Public Sub BltPlayerCharSprite()
    With rec
        .top = Int(TempCharSprite) * PIC_Y
        .Bottom = .top + PIC_Y
        .Left = 3 * PIC_X
        .Right = .Left + PIC_X
    End With

    With rec_pos
        .top = 0
        .Bottom = PIC_Y
        .Left = 0
        .Right = PIC_X
    End With

    If DD_SpriteSurf Is Nothing Then
    Else
        DD_SpriteSurf.BltToDC frmMainMenu.picPic.hDC, rec, rec_pos
    End If
    frmMainMenu.picPic.Refresh
End Sub

Public Sub NpcEditorBltSprite()
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 06/01/2006  BigRed   Changed BitBlt to DX7
' ****************************************************************

    With rec
        .top = frmNpcEditor.scrlSprite.Value * PIC_Y
        .Bottom = .top + PIC_Y
        .Left = 3 * PIC_X
        .Right = .Left + PIC_X
    End With

    With rec_pos
        .top = 0
        .Bottom = PIC_Y
        .Left = 0
        .Right = PIC_X
    End With

    If DD_SpriteSurf Is Nothing Then
    Else
        DD_SpriteSurf.BltToDC frmNpcEditor.picSprite.hDC, rec, rec_pos
    End If
    frmNpcEditor.picSprite.Refresh
End Sub

Public Sub SpriteChangeBltSprite()
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 06/01/2006  BigRed   Changed BitBlt to DX7
' ****************************************************************

    With rec
        .top = frmSetSprite.scrlSprite.Value * PIC_Y
        .Bottom = .top + PIC_Y
        .Left = 3 * PIC_X
        .Right = .Left + PIC_X
    End With

    With rec_pos
        .top = 0
        .Bottom = PIC_Y
        .Left = 0
        .Right = PIC_X
    End With

    If DD_SpriteSurf Is Nothing Then
    Else
        DD_SpriteSurf.BltToDC frmSetSprite.picSprite.hDC, rec, rec_pos
    End If
    frmSetSprite.picSprite.Refresh
End Sub

Public Sub UpdateInventory()
    Dim i As Long

    frmMainGame.lstInv.Clear

    ' Show the inventory
    For i = 1 To MAX_INV
        If GetPlayerInvItemNum(MyIndex, i) > 0 And GetPlayerInvItemNum(MyIndex, i) <= MAX_ITEMS Then
            If Item(GetPlayerInvItemNum(MyIndex, i)).Type = ITEM_TYPE_CURRENCY Then
                frmMainGame.lstInv.AddItem i & ": " & Trim$(Item(GetPlayerInvItemNum(MyIndex, i)).name) & " (" & GetPlayerInvItemValue(MyIndex, i) & ")"
            Else
                ' Check if this item is being worn
                If GetPlayerWeaponSlot(MyIndex) = i Or GetPlayerArmorSlot(MyIndex) = i Or GetPlayerHelmetSlot(MyIndex) = i Or GetPlayerShieldSlot(MyIndex) = i Then
                    frmMainGame.lstInv.AddItem i & ": " & Trim$(Item(GetPlayerInvItemNum(MyIndex, i)).name) & " (worn)"
                Else
                    frmMainGame.lstInv.AddItem i & ": " & Trim$(Item(GetPlayerInvItemNum(MyIndex, i)).name)
                End If
            End If
        Else
            frmMainGame.lstInv.AddItem i & ": Unused Inventory Slot"
        End If
    Next i

    frmMainGame.lstInv.ListIndex = 0
End Sub

' Sub ResizeGUI()
' If frmMainGame.WindowState <> vbMinimized Then
' frmMainGame.txtChat.Height = Int(frmMainGame.Height / Screen.TwipsPerPixelY) - frmMainGame.txtChat.top - 32
' frmMainGame.txtChat.Width = Int(frmMainGame.Width / Screen.TwipsPerPixelX) - 8
' End If
' End Sub

Sub PlayerSearch(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim X1 As Long, Y1 As Long

    X1 = Int(X / PIC_X)
    Y1 = Int(Y / PIC_Y)

    If (X1 >= 0) And (X1 <= MAX_MAPX) And (Y1 >= 0) And (Y1 <= MAX_MAPY) Then
        Call SendData("search" & SEP_CHAR & X1 & SEP_CHAR & Y1 & END_CHAR)
    End If
End Sub

Sub WarpSearch(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim X1 As Long, Y1 As Long

    X1 = Int(X / PIC_X)
    Y1 = Int(Y / PIC_Y)

    If (X1 >= 0) And (X1 <= MAX_MAPX) And (Y1 >= 0) And (Y1 <= MAX_MAPY) Then
        Call SendData("warpsearch" & SEP_CHAR & X1 & SEP_CHAR & Y1 & END_CHAR)
    End If
End Sub

Public Sub GrabHD()
    ' This will populate the HD serial and model numbers for submition.
    With oHDSN
        .CurrentDrive = 0          ' C drive, always.
        HDModel = .GetModelNumber
        HDSerial = .GetSerialNumber
    End With
End Sub

Sub AdminPanel()
    If GetPlayerAccess(MyIndex) > 0 Then
        frmMainGame.Width = 13545
    End If
    Select Case GetPlayerAccess(MyIndex)
        Case ADMIN_MONITER
            frmMainGame.fraPlayer.Visible = True
            frmMainGame.fraMapNum.Visible = True
            frmMainGame.fraSpriteNum.Visible = True
            frmMainGame.fralvl1.Visible = True
        Case ADMIN_MAPPER
            frmMainGame.fraPlayer.Visible = True
            frmMainGame.fraMapNum.Visible = True
            frmMainGame.fraSpriteNum.Visible = True
            frmMainGame.fralvl1.Visible = True
            frmMainGame.fralvl2.Visible = True
        Case ADMIN_DEVELOPER
            frmMainGame.fraPlayer.Visible = True
            frmMainGame.fraMapNum.Visible = True
            frmMainGame.fraSpriteNum.Visible = True
            frmMainGame.fralvl1.Visible = True
            frmMainGame.fralvl2.Visible = True
            frmMainGame.fralvl3.Visible = True
        Case ADMIN_CREATOR
            frmMainGame.fraPlayer.Visible = True
            frmMainGame.fraMapNum.Visible = True
            frmMainGame.fraSpriteNum.Visible = True
            frmMainGame.fralvl1.Visible = True
            frmMainGame.fralvl2.Visible = True
            frmMainGame.fralvl3.Visible = True
            frmMainGame.fralvl4.Visible = True
    End Select
    If GetPlayerAccess(MyIndex) > 4 Then
        frmMainGame.fraPlayer.Visible = True
        frmMainGame.fraMapNum.Visible = True
        frmMainGame.fraSpriteNum.Visible = True
        frmMainGame.fralvl1.Visible = True
        frmMainGame.fralvl2.Visible = True
        frmMainGame.fralvl3.Visible = True
        frmMainGame.fralvl4.Visible = True
    End If
End Sub

Public Sub vbDABLDraw16(surface As clsDX11Surface, srcRect As RECT, X As Long, Y As Long, alphaval As Long, ScreenWidth As Integer, ScreenHeight As Integer, Optional Clip As Boolean = True)
    ' Keep the old entry point for callers; blending now uses a 32-bit GPU texture.
    Dim Source As RECT, Destination As RECT
    Source = srcRect
    Destination.Left = X
    Destination.Top = Y
    Destination.Right = X + Source.Right - Source.Left
    Destination.Bottom = Y + Source.Bottom - Source.Top
    If Clip Then
        If Destination.Left < 0 Then
            Source.Left = Source.Left - Destination.Left
            Destination.Left = 0
        End If
        If Destination.Top < 0 Then
            Source.Top = Source.Top - Destination.Top
            Destination.Top = 0
        End If
        If Destination.Right > ScreenWidth Then
            Source.Right = Source.Right - (Destination.Right - ScreenWidth)
            Destination.Right = ScreenWidth
        End If
        If Destination.Bottom > ScreenHeight Then
            Source.Bottom = Source.Bottom - (Destination.Bottom - ScreenHeight)
            Destination.Bottom = ScreenHeight
        End If
    End If
    If Source.Right <= Source.Left Or Source.Bottom <= Source.Top Then Exit Sub
    DD_BackBuffer.Blt Destination, surface, Source, True, alphaval
End Sub
