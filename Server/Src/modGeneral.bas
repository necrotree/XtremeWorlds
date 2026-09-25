Attribute VB_Name = "modGeneral"
Option Explicit

Sub InitServer()
    Dim IPMask As String
    Dim I As Long
    Dim f As Long
    Dim G As Long, Q As Long

    Randomize
    
    vbQuote = ChrW$(34)

    ' Init atmosphere
    GameWeather = WEATHER_NONE
    WeatherSeconds = 0
    GameTime = TIME_DAY
    TimeSeconds = 0

    EnsureDataFolders App.Path

    SEP_CHAR = Chr$(0)
    END_CHAR = Chr$(237)

    ServerLog = True

' Get the listening socket ready to go
' frmServer.Socket(0).RemoteHost = frmServer.Socket(0).LocalIP
' frmServer.Socket(0).LocalPort = GAME_PORT

    Call SetStatus("Loading scripts...")
    Set MyScript = New clsSadScript
    Set clsScriptCommands = New clsCommands
    MyScript.ReadInCode App.Path & "\scripts\Main.as", "\scripts\Main.as", MyScript.SControl
    MyScript.SControl.AddObject "ScriptHardCode", clsScriptCommands, True

    ' Set the Important Data
    MyScript.ExecuteStatement "\scripts\Main.as", "ServerSet"

    Set GameServer = New clsServer

    ' Reset Stuff based On Varriables
    ReDim Map(1 To MAX_MAPS_SET) As MapRec
    ReDim PlayersOnMap(1 To MAX_MAPS_SET) As Long
    ReDim TempTile(1 To MAX_MAPS_SET) As TempTileRec
    ReDim Player(1 To MAX_PLAYERS) As AccountRec
    ReDim MapItem(1 To MAX_MAPS_SET, 1 To MAX_MAP_ITEMS) As MapItemRec
    ReDim MapNpc(1 To MAX_MAPS_SET, 1 To MAX_MAP_NPCS) As MapNpcRec
    ReDim Shop(1 To MAX_SHOPS) As ShopRec
    ReDim Sign(1 To MAX_SIGNS) As SignRec
    ReDim Spell(1 To MAX_SPELLS) As SpellRec
    ReDim Item(1 To MAX_ITEMS) As ItemRec
    ReDim Npc(1 To MAX_NPCS) As NpcRec
    ReDim Guild(1 To MAX_GUILDS) As GuildRec
    For G = 1 To MAX_GUILDS
        ReDim Preserve Guild(G).Member(1 To MAX_GUILD_MEMBERS) As String * NAME_LENGTH
    Next G
    ReDim Quest(1 To MAX_QUESTS) As QuestRec
    For Q = 1 To MAX_QUESTS
        ReDim Preserve Quest(Q).Player(1 To MAX_QUEST_PLAYERS) As String * NAME_LENGTH
    Next Q

    ' Initiate the System Tray
    Call InitTray(GAME_NAME)
    frmLoad.Caption = GAME_NAME & " :: Loading"

    ' Init all the player sockets
    For I = 1 To MAX_PLAYERS
        Call SetStatus("Initializing player array...")
        Call ClearPlayer(I)

        Call GameServer.Sockets.Add(CStr(I))
    Next I

    Call ClearTempTile
    Call ClearMaps
    Call ClearMapItems
    Call ClearMapNpcs
    Call ClearNpcs
    Call ClearItems
    Call ClearShops
    Call ClearSpells
    Call ClearSigns
    Call ClearGuilds
    Call ClearQuests
    Call LoadClasses
    Call LoadMaps
    Call LoadItems
    Call LoadNpcs
    Call LoadShops
    Call LoadSigns
    Call LoadSpells
    Call LoadGuilds
    Call LoadQuests
    Call SpawnAllMapsItems
    Call SpawnAllMapNpcs
    Call LoadBans

    ' Check if the master charlist file exists for checking duplicate names, and if it doesnt make it
    If Not FileExist("\data\accounts\charlist.txt") Then
        f = FreeFile
        Open App.Path & "\data\accounts\charlist.txt" For Output As #f
        Close #f
    End If

    ' Set the MOTD
    MOTD = GetVar(App.Path & "\data\motd.ini", "MOTD", "Msg")

    ' Start listening
    GameServer.StartListening

    Call UpdateCaption

    frmLoad.Visible = False
    frmServer.Show

    SpawnSeconds = 0
    frmServer.tmrGameAI.Enabled = True
End Sub

Sub DestroyServer()
    Dim I As Long

    nid.cbSize = Len(nid)
    nid.hWnd = frmServer.hWnd
    nid.uId = vbNull
    nid.uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
    nid.uCallBackMessage = WM_MOUSEMOVE
    nid.hIcon = frmServer.Icon
    nid.szTip = "Crystalion Server" & vbNullChar
    ' Add to the sys tray
    Call Shell_NotifyIcon(NIM_DELETE, nid)

    frmLoad.Visible = True
    frmServer.Visible = False

    Call SetStatus("Saving players online...")
    Call SaveAllPlayersOnline
    Call SetStatus("Clearing maps...")
    Call ClearMaps
    Call SetStatus("Clearing map items...")
    Call ClearMapItems
    Call SetStatus("Clearing map npcs...")
    Call ClearMapNpcs
    Call SetStatus("Clearing npcs...")
    Call ClearNpcs
    Call SetStatus("Clearing items...")
    Call ClearItems
    Call SetStatus("Clearing shops...")
    Call ClearShops
    Call SetStatus("Unloading sockets and timers...")
    For I = 1 To MAX_PLAYERS
        Call GameServer.Sockets.Remove(CStr(I))
    Next I
    Set GameServer = Nothing

    End
End Sub

Sub SetStatus(ByVal Status As String)
    frmLoad.lblStatus.Caption = Status
End Sub

Sub ServerLogic()
    Dim I As Long

    ' Check for disconnections
    ' For I = 1 To MAX_PLAYERS
    ' If frmServer.Socket(I).State > 7 Then
    ' Call CloseSocket(I)
    ' End If
    ' Next I
    '
    Call CheckGiveHP
    Call GameAI
End Sub

Sub CheckSpawnMapItems()
    Dim X As Long, y As Long

    ' Used for map item respawning
    SpawnSeconds = SpawnSeconds + 1

    ' ///////////////////////////////////////////
    ' // This is used for respawning map items //
    ' ///////////////////////////////////////////
    If SpawnSeconds >= 120 Then
        ' 2 minutes have passed
        For y = 1 To MAX_MAPS_SET
            ' Make sure no one is on the map when it respawns
            If PlayersOnMap(y) = False Then
                ' Clear out unnecessary junk
                For X = 1 To MAX_MAP_ITEMS
                    Call ClearMapItem(X, y)
                Next X

                ' Spawn the items
                Call SpawnMapItems(y)
                Call SendMapItemsToAll(y)
            End If
            DoEvents
        Next y


        SpawnSeconds = 0
    End If
End Sub

Sub GameAI()
    Dim I As Long, X As Long, y As Long, N As Long, x1 As Long, y1 As Long, TickCount As Long
    Dim Damage As Long, DistanceX As Long, DistanceY As Long, NpcNum As Long, Target As Long
    Dim DidWalk As Boolean

' WeatherSeconds = WeatherSeconds + 1
' TimeSeconds = TimeSeconds + 1

    ' Lets change the weather if its time to
    If WeatherSeconds >= 60 Then
        I = Int(Rnd * 3)
        If I <> GameWeather Then
            GameWeather = I
            Call SendWeatherToAll
        End If
        WeatherSeconds = 0
    End If

    ' Check if we need to switch from day to night or night to day
    If TimeSeconds >= 60 Then
        If GameTime = TIME_DAY Then
            GameTime = TIME_NIGHT
        Else
            GameTime = TIME_DAY
        End If

        Call SendTimeToAll
        TimeSeconds = 0
    End If

    For y = 1 To MAX_MAPS_SET
        If PlayersOnMap(y) = YES Then
            TickCount = GetTickCount

            ' ////////////////////////////////////
            ' // This is used for closing doors //
            ' ////////////////////////////////////
            If TickCount > TempTile(y).DoorTimer + 5000 Then
                For y1 = 0 To MAX_MAPY
                    For x1 = 0 To MAX_MAPX
                        If Map(y).Tile(x1, y1).Type = TILE_TYPE_KEY Or TILE_TYPE_DOOR And TempTile(y).DoorOpen(x1, y1) = YES Then
                            TempTile(y).DoorOpen(x1, y1) = NO
                            Call SendDataToMap(y, "MAPKEY" & SEP_CHAR & x1 & SEP_CHAR & y1 & SEP_CHAR & 0 & END_CHAR)
                        End If
                    Next x1
                Next y1
            End If

            For X = 1 To MAX_MAP_NPCS
                NpcNum = MapNpc(y, X).Num

                ' /////////////////////////////////////////
                ' // This is used for ATTACKING ON SIGHT //
                ' /////////////////////////////////////////
                ' Make sure theres a npc with the map
                If Map(y).Npc(X) > 0 And MapNpc(y, X).Num > 0 Then
                    ' If the npc is a attack on sight, search for a player on the map
                    If Npc(NpcNum).Behavior = NPC_BEHAVIOR_ATTACKONSIGHT Or Npc(NpcNum).Behavior = NPC_BEHAVIOR_GUARD Then
                        For I = 1 To HighIndex
                            If IsPlaying(I) Then
                                If GetPlayerMap(I) = y And MapNpc(y, X).Target = 0 And GetPlayerAccess(I) <= ADMIN_MONITER Then
                                    N = Npc(NpcNum).Range

                                    DistanceX = MapNpc(y, X).X - GetPlayerX(I)
                                    DistanceY = MapNpc(y, X).y - GetPlayerY(I)

                                    ' Make sure we get a positive value
                                    If DistanceX < 0 Then DistanceX = DistanceX * -1
                                    If DistanceY < 0 Then DistanceY = DistanceY * -1

                                    ' Are they in range?  if so GET'M!
                                    If DistanceX <= N And DistanceY <= N Then
                                        If Npc(NpcNum).Behavior = NPC_BEHAVIOR_ATTACKONSIGHT Or GetPlayerPK(I) = YES Then
                                            If Trim$(Npc(NpcNum).AttackSay) <> "" Then
                                                Call PlayerMsg(I, "A " & Trim$(Npc(NpcNum).Name) & " says, '" & Trim$(Npc(NpcNum).AttackSay) & "' to you.", SayColor)
                                            End If

                                            MapNpc(y, X).Target = I
                                        End If
                                    End If
                                End If
                            End If
                        Next I
                    End If
                End If

                ' /////////////////////////////////////////////
                ' // This is used for NPC walking/targetting //
                ' /////////////////////////////////////////////
                ' Make sure theres a npc with the map
                If Map(y).Npc(X) > 0 And MapNpc(y, X).Num > 0 Then
                    Target = MapNpc(y, X).Target

                    ' Check to see if its time for the npc to walk
                    If Npc(NpcNum).Behavior >= 0 Then
                        ' Check to see if we are following a player or not
                        If Target > 0 Then
                            ' Check if the player is even playing, if so follow'm
                            If IsPlaying(Target) And GetPlayerMap(Target) = y Then
                                DidWalk = False

                                I = Int(Rnd * 5)

                                ' Lets move the npc
                                Select Case I
                                    Case 0
                                        ' Up
                                        If MapNpc(y, X).y > GetPlayerY(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_UP) Then
                                                Call NpcMove(y, X, DIR_UP, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Down
                                        If MapNpc(y, X).y < GetPlayerY(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_DOWN) Then
                                                Call NpcMove(y, X, DIR_DOWN, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Left
                                        If MapNpc(y, X).X > GetPlayerX(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_LEFT) Then
                                                Call NpcMove(y, X, DIR_LEFT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Right
                                        If MapNpc(y, X).X < GetPlayerX(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_RIGHT) Then
                                                Call NpcMove(y, X, DIR_RIGHT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If

                                    Case 1
                                        ' Right
                                        If MapNpc(y, X).X < GetPlayerX(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_RIGHT) Then
                                                Call NpcMove(y, X, DIR_RIGHT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Left
                                        If MapNpc(y, X).X > GetPlayerX(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_LEFT) Then
                                                Call NpcMove(y, X, DIR_LEFT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Down
                                        If MapNpc(y, X).y < GetPlayerY(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_DOWN) Then
                                                Call NpcMove(y, X, DIR_DOWN, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Up
                                        If MapNpc(y, X).y > GetPlayerY(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_UP) Then
                                                Call NpcMove(y, X, DIR_UP, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If

                                    Case 2
                                        ' Down
                                        If MapNpc(y, X).y < GetPlayerY(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_DOWN) Then
                                                Call NpcMove(y, X, DIR_DOWN, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Up
                                        If MapNpc(y, X).y > GetPlayerY(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_UP) Then
                                                Call NpcMove(y, X, DIR_UP, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Right
                                        If MapNpc(y, X).X < GetPlayerX(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_RIGHT) Then
                                                Call NpcMove(y, X, DIR_RIGHT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Left
                                        If MapNpc(y, X).X > GetPlayerX(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_LEFT) Then
                                                Call NpcMove(y, X, DIR_LEFT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If

                                    Case 3
                                        ' Left
                                        If MapNpc(y, X).X > GetPlayerX(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_LEFT) Then
                                                Call NpcMove(y, X, DIR_LEFT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Right
                                        If MapNpc(y, X).X < GetPlayerX(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_RIGHT) Then
                                                Call NpcMove(y, X, DIR_RIGHT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Up
                                        If MapNpc(y, X).y > GetPlayerY(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_UP) Then
                                                Call NpcMove(y, X, DIR_UP, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                        ' Down
                                        If MapNpc(y, X).y < GetPlayerY(Target) And DidWalk = False Then
                                            If CanNpcMove(y, X, DIR_DOWN) Then
                                                Call NpcMove(y, X, DIR_DOWN, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
                                End Select



                                ' Check if we can't move and if player is behind something and if we can just switch dirs
                                If Not DidWalk Then
                                    If MapNpc(y, X).X - 1 = GetPlayerX(Target) And MapNpc(y, X).y = GetPlayerY(Target) Then
                                        If MapNpc(y, X).Dir <> DIR_LEFT Then
                                            Call NpcDir(y, X, DIR_LEFT)
                                        End If
                                        DidWalk = True
                                    End If
                                    If MapNpc(y, X).X + 1 = GetPlayerX(Target) And MapNpc(y, X).y = GetPlayerY(Target) Then
                                        If MapNpc(y, X).Dir <> DIR_RIGHT Then
                                            Call NpcDir(y, X, DIR_RIGHT)
                                        End If
                                        DidWalk = True
                                    End If
                                    If MapNpc(y, X).X = GetPlayerX(Target) And MapNpc(y, X).y - 1 = GetPlayerY(Target) Then
                                        If MapNpc(y, X).Dir <> DIR_UP Then
                                            Call NpcDir(y, X, DIR_UP)
                                        End If
                                        DidWalk = True
                                    End If
                                    If MapNpc(y, X).X = GetPlayerX(Target) And MapNpc(y, X).y + 1 = GetPlayerY(Target) Then
                                        If MapNpc(y, X).Dir <> DIR_DOWN Then
                                            Call NpcDir(y, X, DIR_DOWN)
                                        End If
                                        DidWalk = True
                                    End If

                                    ' We could not move so player must be behind something, walk randomly.
                                    If Not DidWalk Then
                                        I = Int(Rnd * 2)
                                        If I = 1 Then
                                            I = Int(Rnd * 4)
                                            If CanNpcMove(y, X, I) Then
                                                Call NpcMove(y, X, I, MOVING_WALKING)
                                            End If
                                        End If
                                    End If
                                End If
                            Else
                                MapNpc(y, X).Target = 0
                            End If
                        Else
                            I = Int(Rnd * 4)
                            If I = 1 Then
                                I = Int(Rnd * 4)
                                If CanNpcMove(y, X, I) Then
                                    Call NpcMove(y, X, I, MOVING_WALKING)
                                End If
                            End If
                        End If
                    End If
                End If

                ' /////////////////////////////////////////////
                ' // This is used for npcs to attack players //
                ' /////////////////////////////////////////////
                ' Make sure theres a npc with the map
                If Map(y).Npc(X) > 0 And MapNpc(y, X).Num > 0 Then
                    Target = MapNpc(y, X).Target

                    ' Check if the npc can attack the targeted player player
                    If Target > 0 Then
                        ' Is the target playing and on the same map?
                        If IsPlaying(Target) And GetPlayerMap(Target) = y Then
                            ' Can the npc attack the player?
                            If CanNpcAttackPlayer(X, Target) Then
                                If Not CanPlayerBlockHit(Target) Then
                                    Damage = Npc(NpcNum).STR - GetPlayerProtection(Target)
                                    If Damage > 0 Then
                                        Call NpcAttackPlayer(X, Target, Damage)
                                    Else
                                        Call PlayerMsg(Target, "The " & Trim$(Npc(NpcNum).Name) & "'s hit didn't even phase you!", BrightBlue)
                                    End If
                                Else
                                    Call PlayerMsg(Target, "Your " & Trim$(Item(GetPlayerInvItemNum(Target, GetPlayerShieldSlot(Target))).Name) & " blocks the " & Trim$(Npc(NpcNum).Name) & "'s hit!", BrightCyan)
                                End If
                            End If
                        Else
                            ' Player left map or game, set target to 0
                            MapNpc(y, X).Target = 0
                        End If
                    End If
                End If

                ' ////////////////////////////////////////////
                ' // This is used for regenerating NPC's HP //
                ' ////////////////////////////////////////////
                ' Check to see if we want to regen some of the npc's hp
                If MapNpc(y, X).Num > 0 And TickCount > GiveNPCHPTimer + 10000 Then
                    If MapNpc(y, X).HP > 0 Then
                        MapNpc(y, X).HP = MapNpc(y, X).HP + GetNpcHPRegen(NpcNum)

                        ' Check if they have more then they should and if so just set it to max
                        If MapNpc(y, X).HP > GetNpcMaxHP(NpcNum) Then
                            MapNpc(y, X).HP = GetNpcMaxHP(NpcNum)
                        End If
                    End If
                End If

                ' ////////////////////////////////////////////////////////
                ' // This is used for checking if an NPC is dead or not //
                ' ////////////////////////////////////////////////////////
                ' Check if the npc is dead or not
                ' If MapNpc(y, x).Num > 0 Then
                ' If MapNpc(y, x).HP <= 0 And Npc(MapNpc(y, x).Num).STR > 0 And Npc(MapNpc(y, x).Num).DEF > 0 Then
                ' MapNpc(y, x).Num = 0
                ' MapNpc(y, x).SpawnWait = TickCount
                ' End If
                ' End If

                ' //////////////////////////////////////
                ' // This is used for spawning an NPC //
                ' //////////////////////////////////////
                ' Check if we are supposed to spawn an npc or not
                If MapNpc(y, X).Num = 0 And Map(y).Npc(X) > 0 Then
                    If TickCount > MapNpc(y, X).SpawnWait + (Npc(Map(y).Npc(X)).SpawnSecs * 1000) Then
                        Call SpawnNpc(X, y)
                    End If
                End If
            Next X
        End If
        DoEvents
    Next y

    ' Make sure we reset the timer for npc hp regeneration
    If GetTickCount > GiveNPCHPTimer + 10000 Then
        GiveNPCHPTimer = GetTickCount
    End If

    ' Make sure we reset the timer for door closing
    If GetTickCount > KeyTimer + 15000 Then
        KeyTimer = GetTickCount
    End If
End Sub

Sub CheckGiveHP()
    Dim I As Long, N As Long

    If GetTickCount > GiveHPTimer + 10000 Then
        For I = 1 To HighIndex
            If IsPlaying(I) Then
                Call SetPlayerHP(I, GetPlayerHP(I) + GetPlayerHPRegen(I))
                Call SendHP(I)
                Call SetPlayerMP(I, GetPlayerMP(I) + GetPlayerMPRegen(I))
                Call SendMP(I)
                Call SetPlayerSP(I, GetPlayerSP(I) + GetPlayerSPRegen(I))
                Call SendSP(I)
            End If
            DoEvents
        Next I

        GiveHPTimer = GetTickCount
    End If
End Sub

Sub PlayerSaveTimer()
    Static MinPassed As Long
    Dim I As Long

    MinPassed = MinPassed + 1
    If MinPassed >= 120 Then
        If TotalOnlinePlayers > 0 Then
            PlayerI = 1
            frmServer.PlayerTimer.Enabled = True
            frmServer.tmrPlayerSave.Enabled = False
        End If

        MinPassed = 0
    End If
End Sub

' Optimized by DFA
Public Function IsVowel(ByVal Word As String) As Boolean
    IsVowel = False
    
    ' Make sure it isn't a 0-length string
    If LenB(Word) = 0 Then
        Exit Function
    End If
    
    Word = AscB(UCase$(Word))
    
    Select Case Word
    
        Case vbKeyA
            IsVowel = True
        
        Case vbKeyE
            IsVowel = True
        
        Case vbKeyI
            IsVowel = True
        
        Case vbKeyO
            IsVowel = True
        
        Case vbKeyU
            IsVowel = True
            
    End Select
    
    ' Old Method
    'If UCase$(Mid$(Trim$(Word), 1, 1)) = "A" Or UCase$(Mid$(Trim$(Word), 1, 1)) = "E" Or UCase$(Mid$(Trim$(Word), 1, 1)) = "I" Or UCase$(Mid$(Trim$(Word), 1, 1)) = "O" Or UCase$(Mid$(Trim$(Word), 1, 1)) = "U" Then
    '    IsVowel = True
    '    Exit Function
    'End If

End Function

Public Function MapShopFixesItems(ByVal Index As Long) As Boolean
    Dim I As Long

    MapShopFixesItems = False

    ' Check the map shop
    If Map(GetPlayerMap(Index)).Shop > 0 Then
        If CurrentShop = Map(GetPlayerMap(Index)).Shop Then
            If Shop(Map(GetPlayerMap(Index)).Shop).FixesItems = 1 Then
                MapShopFixesItems = True
                Exit Function
            End If
        End If
    End If

    ' Check the NPC shops
    For I = 1 To MAX_MAP_NPCS
        If Npc(Map(GetPlayerMap(Index)).Npc(I)).ShopCall > 0 Then
            If CurrentShop = Npc(Map(GetPlayerMap(Index)).Npc(I)).ShopCall Then
                If Shop(Npc(Map(GetPlayerMap(Index)).Npc(I)).ShopCall).FixesItems = 1 Then
                    MapShopFixesItems = True
                    Exit Function
                End If
            End If
        End If
    Next I

End Function

Public Sub ReloadScripts()
    Set MyScript = Nothing
    Set clsScriptCommands = Nothing
    
    Set MyScript = New clsSadScript
    Set clsScriptCommands = New clsCommands
    MyScript.ReadInCode App.Path & "\Scripts\Main.as", "\Scripts\Main.as", MyScript.SControl
    MyScript.SControl.AddObject "ScriptHardCode", clsScriptCommands, True
    Call TextAdd(frmServer.txtText, "Scripts reloaded.", True)
    Call AdminMsg("Scripts reloaded by server.", 15)
        
End Sub

Sub SetQuestComplete(ByVal Index As Long, QuestNum As Long)
    Dim pSlot As Long

    pSlot = FindOpenQuestSlot(QuestNum)

    Quest(QuestNum).Player(pSlot) = Trim$(GetPlayerName(Index))

End Sub

Function IsQuestComplete(ByVal Index As Long, QuestNum As Long) As Boolean
    Dim Q As Long
    
    IsQuestComplete = False

    For Q = 1 To MAX_QUEST_PLAYERS
        If Trim$(Quest(QuestNum).Player(Q)) = Trim$(GetPlayerName(Index)) Then
            IsQuestComplete = True
            Exit Function
        End If
    Next Q

End Function
