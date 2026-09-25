Attribute VB_Name = "modHandleData"
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Created module.
' ****************************************************************

Option Explicit

Public Sub HandleData(ByVal Data As String)
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Added map constants.
' ****************************************************************

    Dim Parse() As String
    Dim name As String
    Dim Password As String
    Dim EncKey As String
    Dim Sex As Long
    Dim ClassNum As Long
    Dim CharNum As Long
    Dim Msg As String
    Dim IPMask As String
    Dim BanSlot As Long
    Dim MsgTo As Long
    Dim Dir As Long
    Dim InvNum As Long
    Dim Ammount As Long
    Dim Damage As Long
    Dim PointType As Long
    Dim BanPlayer As Long
    Dim Level As Long
    Dim NextLevel As Long
    Dim i As Long, n As Long, X As Long, Y As Long
    Dim ShopNum As Long, GiveItem As Long, GiveValue As Long, GiveItem2 As Long, GiveValue2 As Long, GetItem As Long, GetValue As Long

    ' Handle Data
    Parse = Split(Data, SEP_CHAR)

    ' Add the data to the debug window if we are in debug mode
    If Trim$(Command) = "-debug" Then
        If frmDebug.Visible = False Then frmDebug.Visible = True
        Call TextAdd(frmDebug.txtDebug, "((( Processed Packet " & Parse$(0) & " )))", True)
    End If

    ' Get the packet
    Select Case LCase$(Parse$(0))

        ' ::::::::::::::::::::::::::
        ' :: Alert message packet ::
        ' ::::::::::::::::::::::::::
        Case "alertmsg"
            frmSendGetData.Visible = False
            frmMainMenu.Visible = True

            Msg = Parse(1)
            Call MsgBox(Msg, vbOKOnly, GAME_NAME)
            Exit Sub

        ' ::::::::::::::::::::::::::::
        ' :: Get Online Player List ::
        ' ::::::::::::::::::::::::::::
        Case "onlinelist"
            frmMainGame.lstPlayers.Clear
            Dim Z As Byte
            Dim Online As Byte

            n = 2
            Online = 0
            Z = Val(Parse(1))
            For X = n To (Z + 1)
                frmMainGame.lstPlayers.AddItem Trim$(Parse(n))
                n = n + 2
                Online = Online + 1
            Next X
            Exit Sub

        ' :::::::::::::::::::::::::::
        ' :: All characters packet ::
        ' :::::::::::::::::::::::::::
        Case "allchars"
            n = 1

            frmMainMenu.mnuChars.Visible = True
            frmMainMenu.Visible = True
            frmSendGetData.Visible = False

            frmMainMenu.lstChars.Clear

            For i = 1 To MAX_CHARS
                name = Trim$(Parse(n))
                Msg = Trim$(Parse(n + 1))
                Level = Val(Parse(n + 2))
                TempCharSprite = Val(Parse(n + 3))

                If LenB(Trim$(name)) = 0 Then
                    frmMainMenu.lstChars.AddItem "Free Character Slot"
                Else
                    frmMainMenu.lstChars.AddItem name & " a level " & Level & " " & Msg
                End If

                n = n + 4
            Next i

            frmMainMenu.lstChars.ListIndex = 0
            Exit Sub

        ' :::::::::::::::::::::::::::::::::
        ' :: Login was successful packet ::
        ' :::::::::::::::::::::::::::::::::
        Case "loginok"
            ' Now we can receive game data
            MyIndex = Val(Parse(1))

            frmSendGetData.Visible = True
            frmMainMenu.mnuChars.Visible = False

            Call SetStatus("Receiving game data...")
            Exit Sub

        ' :::::::::::::::::::::::::::::::::::::::
        ' :: New character classes data packet ::
        ' :::::::::::::::::::::::::::::::::::::::
        Case "newcharclasses"
            n = 1

            ' Max classes
            Max_Classes = Val(Parse(n))
            ReDim Class(0 To Max_Classes) As ClassRec

            n = n + 1

            For i = 0 To Max_Classes
                Class(i).name = Parse(n)

                Class(i).HP = Val(Parse(n + 1))
                Class(i).MP = Val(Parse(n + 2))
                Class(i).SP = Val(Parse(n + 3))

                Class(i).STR = Val(Parse(n + 4))
                Class(i).DEF = Val(Parse(n + 5))
                Class(i).speed = Val(Parse(n + 6))
                Class(i).MAGI = Val(Parse(n + 7))

                Class(i).Sprite = Val(Parse(n + 8))
                Class(i).FSprite = Val(Parse(n + 9))

                n = n + 10
            Next i

            ' Used for if the player is creating a new character
            frmMainMenu.mnuNewCharacter.Visible = True
            frmMainMenu.Visible = True
            frmMainMenu.txtNewCharName.SetFocus
            frmSendGetData.Visible = False

            frmMainMenu.cmbClass.Clear

            For i = 0 To Max_Classes
                frmMainMenu.cmbClass.AddItem Trim$(Class(i).name)
            Next i

            With frmMainMenu
                .cmbClass.ListIndex = 0
                .lblHP.Caption = STR(Class(0).HP)
                .lblMP.Caption = STR(Class(0).MP)
                .lblSP.Caption = STR(Class(0).SP)

                .lblSTR.Caption = STR(Class(0).STR)
                .lblDEF.Caption = STR(Class(0).DEF)
                .lblSPEED.Caption = STR(Class(0).speed)
                .lblMAGI.Caption = STR(Class(0).MAGI)

                If Class(.cmbClass.ListIndex).Sprite = Class(.cmbClass.ListIndex).FSprite Then
                    .optMale.Value = True
                    .optMale.Visible = False
                    .optFemale.Value = False
                    .optFemale.Visible = False
                ElseIf Class(.cmbClass.ListIndex).Sprite <> Class(.cmbClass.ListIndex).FSprite Then
                    .optMale.Value = True
                    .optMale.Visible = True
                    .optFemale.Value = False
                    .optFemale.Visible = True
                End If
            End With
            Exit Sub

        ' :::::::::::::::::::::::::
        ' :: Classes data packet ::
        ' :::::::::::::::::::::::::
        Case "classesdata"
            n = 1

            ' Max classes
            Max_Classes = Val(Parse(n))
            ReDim Class(0 To Max_Classes) As ClassRec

            n = n + 1

            For i = 0 To Max_Classes
                Class(i).name = Parse(n)

                Class(i).HP = Val(Parse(n + 1))
                Class(i).MP = Val(Parse(n + 2))
                Class(i).SP = Val(Parse(n + 3))

                Class(i).STR = Val(Parse(n + 4))
                Class(i).DEF = Val(Parse(n + 5))
                Class(i).speed = Val(Parse(n + 6))
                Class(i).MAGI = Val(Parse(n + 7))

                n = n + 8
            Next i
            Exit Sub

        ' ::::::::::::::::::::
        ' :: In game packet ::
        ' ::::::::::::::::::::
        Case "ingame"
            InGame = True
            Call GameInit
            Call GameLoop
            Exit Sub

        ' :::::::::::::::::::::::::::::
        ' :: Player inventory packet ::
        ' :::::::::::::::::::::::::::::
        Case "playerinv"
            n = 1
            For i = 1 To MAX_INV
                Call SetPlayerInvItemNum(MyIndex, i, Val(Parse(n)))
                Call SetPlayerInvItemValue(MyIndex, i, Val(Parse(n + 1)))
                Call SetPlayerInvItemDur(MyIndex, i, Val(Parse(n + 2)))

                n = n + 3
            Next i
            Call UpdateInventory
            Exit Sub

        ' ::::::::::::::::::::::::::::::::::::
        ' :: Player inventory update packet ::
        ' ::::::::::::::::::::::::::::::::::::
        Case "playerinvupdate"
            n = Val(Parse(1))

            Call SetPlayerInvItemNum(MyIndex, n, Val(Parse(2)))
            Call SetPlayerInvItemValue(MyIndex, n, Val(Parse(3)))
            Call SetPlayerInvItemDur(MyIndex, n, Val(Parse(4)))
            Call UpdateInventory
            Exit Sub

        ' ::::::::::::::::::::::::::::::::::
        ' :: Player worn equipment packet ::
        ' ::::::::::::::::::::::::::::::::::
        Case "playerworneq"
            Call SetPlayerArmorSlot(MyIndex, Val(Parse(1)))
            Call SetPlayerWeaponSlot(MyIndex, Val(Parse(2)))
            Call SetPlayerHelmetSlot(MyIndex, Val(Parse(3)))
            Call SetPlayerShieldSlot(MyIndex, Val(Parse(4)))
            Call UpdateInventory
            Exit Sub

        ' ::::::::::::::::::::::
        ' :: Player hp packet ::
        ' ::::::::::::::::::::::
        Case "playerhp"
            Player(MyIndex).MaxHP = Val(Parse(1))
            Call SetPlayerHP(MyIndex, Val(Parse(2)))
            If GetPlayerMaxHP(MyIndex) > 0 Then
                With frmMainGame
                    .lblHP(0).Caption = "HP:   " & GetPlayerHP(MyIndex) & "/" & GetPlayerMaxHP(MyIndex)
                    .lblHP(1).Caption = "HP:   " & GetPlayerHP(MyIndex) & "/" & GetPlayerMaxHP(MyIndex)
                    .shpHP.Width = (((GetPlayerHP(MyIndex) / 100) / (GetPlayerMaxHP(MyIndex) / 100)) * 156)
                End With
            End If
            Exit Sub

        ' ::::::::::::::::::::::
        ' :: Player mp packet ::
        ' ::::::::::::::::::::::
        Case "playermp"
            Player(MyIndex).MaxMP = Val(Parse(1))
            Call SetPlayerMP(MyIndex, Val(Parse(2)))
            If GetPlayerMaxMP(MyIndex) > 0 Then
                frmMainGame.lblMP(0).Caption = "MP:   " & GetPlayerMP(MyIndex) & "/" & GetPlayerMaxMP(MyIndex)
                frmMainGame.lblMP(1).Caption = "MP:   " & GetPlayerMP(MyIndex) & "/" & GetPlayerMaxMP(MyIndex)
                frmMainGame.shpMP.Width = (((GetPlayerMP(MyIndex) / 100) / (GetPlayerMaxMP(MyIndex) / 100)) * 155)
            End If
            Exit Sub

        ' ::::::::::::::::::::::
        ' :: Player sp packet ::
        ' ::::::::::::::::::::::
        Case "playersp"
            Player(MyIndex).MaxSP = Val(Parse(1))
            Call SetPlayerSP(MyIndex, Val(Parse(2)))
            If GetPlayerMaxSP(MyIndex) > 0 Then
                frmMainGame.lblSP(0).Caption = "SP:   " & GetPlayerSP(MyIndex) & "/" & GetPlayerMaxSP(MyIndex)
                frmMainGame.lblSP(1).Caption = "SP:   " & GetPlayerSP(MyIndex) & "/" & GetPlayerMaxSP(MyIndex)
                frmMainGame.shpSP.Width = (((GetPlayerSP(MyIndex) / 100) / (GetPlayerMaxSP(MyIndex) / 100)) * 153)
            End If
            Exit Sub

        ' :::::::::::::::::::::::
        ' :: Player exp packet ::
        ' :::::::::::::::::::::::
        Case "playerexp"
            Player(MyIndex).Exp = Val(Parse(1))
            Call SetPlayerExp(MyIndex, Val(Parse(1)))
            NextLevel = Val(Parse(2))
            ' frmMainGame.shpEXP.Width = (GetPlayerExp(MyIndex) / 100) / (NextLevel / 100) * 172
            If GetPlayerExp(MyIndex) > 0 And NextLevel > 0 Then
                frmMainGame.shpEXP.Width = (((GetPlayerExp(MyIndex) / 100) / (NextLevel / 100)) * 360)
            End If
            If GetPlayerExp(MyIndex) = 0 Then
                frmMainGame.shpEXP.Width = 0
            End If
            Exit Sub

        ' :::::::::::::::::::::::::
        ' :: Player stats packet ::
        ' :::::::::::::::::::::::::
        Case "playerstats"
            Call SetPlayerSTR(MyIndex, Val(Parse(1)))
            Call SetPlayerDEF(MyIndex, Val(Parse(2)))
            Call SetPlayerSPEED(MyIndex, Val(Parse(3)))
            Call SetPlayerMAGI(MyIndex, Val(Parse(4)))
            Exit Sub

        ' :::::::::::::::::::::::::
        ' :: Player guild packet ::
        ' :::::::::::::::::::::::::
        Case "playerguild"
            Call SetPlayerGuild(MyIndex, Val(Parse(1)))
            Exit Sub

        ' ::::::::::::::::::::::::
        ' :: Player data packet ::
        ' ::::::::::::::::::::::::
        Case "playerdata"
            i = Val(Parse(1))

            Call SetPlayerName(i, Parse(2))
            Call SetPlayerSprite(i, Val(Parse(3)))
            Call SetPlayerMap(i, Val(Parse(4)))
            Call SetPlayerX(i, Val(Parse(5)))
            Call SetPlayerY(i, Val(Parse(6)))
            Call SetPlayerDir(i, Val(Parse(7)))
            Call SetPlayerAccess(i, Val(Parse(8)))
            Call SetPlayerPK(i, Val(Parse(9)))
            Call SetPlayerGuild(i, Val(Parse(10)))

            ' Make sure they aren't walking
            Player(i).Moving = 0
            Player(i).XOffset = 0
            Player(i).YOffset = 0

            ' Check if the player is the client player, and if so reset directions
            If i = MyIndex Then
                DirUp = False
                DirDown = False
                DirLeft = False
                DirRight = False
            End If

            Exit Sub

        ' ::::::::::::::::::::::::::::
        ' :: Player movement packet ::
        ' ::::::::::::::::::::::::::::
        Case "playermove"
            i = Val(Parse(1))
            X = Val(Parse(2))
            Y = Val(Parse(3))
            Dir = Val(Parse(4))
            n = Val(Parse(5))

            Call SetPlayerX(i, X)
            Call SetPlayerY(i, Y)
            Call SetPlayerDir(i, Dir)

            Player(i).XOffset = 0
            Player(i).YOffset = 0
            Player(i).Moving = n

            Select Case GetPlayerDir(i)
                Case DIR_UP
                    Player(i).YOffset = PIC_Y
                Case DIR_DOWN
                    Player(i).YOffset = PIC_Y * -1
                Case DIR_LEFT
                    Player(i).XOffset = PIC_X
                Case DIR_RIGHT
                    Player(i).XOffset = PIC_X * -1
            End Select
            Exit Sub

        ' :::::::::::::::::::::::::
        ' :: Npc movement packet ::
        ' :::::::::::::::::::::::::
        Case "npcmove"
            i = Val(Parse(1))
            X = Val(Parse(2))
            Y = Val(Parse(3))
            Dir = Val(Parse(4))
            n = Val(Parse(5))

            MapNpc(i).X = X
            MapNpc(i).Y = Y
            MapNpc(i).Dir = Dir
            MapNpc(i).XOffset = 0
            MapNpc(i).YOffset = 0
            MapNpc(i).Moving = n

            Select Case MapNpc(i).Dir
                Case DIR_UP
                    MapNpc(i).YOffset = PIC_Y
                Case DIR_DOWN
                    MapNpc(i).YOffset = PIC_Y * -1
                Case DIR_LEFT
                    MapNpc(i).XOffset = PIC_X
                Case DIR_RIGHT
                    MapNpc(i).XOffset = PIC_X * -1
            End Select
            Exit Sub

        ' :::::::::::::::::::::::::::::
        ' :: Player direction packet ::
        ' :::::::::::::::::::::::::::::
        Case "playerdir"
            i = Val(Parse(1))
            Dir = Val(Parse(2))
            Call SetPlayerDir(i, Dir)

            Player(i).XOffset = 0
            Player(i).YOffset = 0
            Player(i).Moving = 0
            Exit Sub

        ' ::::::::::::::::::::::::::
        ' :: NPC direction packet ::
        ' ::::::::::::::::::::::::::
        Case "npcdir"
            i = Val(Parse(1))
            Dir = Val(Parse(2))
            MapNpc(i).Dir = Dir

            MapNpc(i).XOffset = 0
            MapNpc(i).YOffset = 0
            MapNpc(i).Moving = 0
            Exit Sub

        ' :::::::::::::::::::::::::::::::
        ' :: Player XY location packet ::
        ' :::::::::::::::::::::::::::::::
        Case "playerxy"
            X = Val(Parse(1))
            Y = Val(Parse(2))

            Call SetPlayerX(MyIndex, X)
            Call SetPlayerY(MyIndex, Y)

            ' Make sure they aren't walking
            Player(MyIndex).Moving = 0
            Player(MyIndex).XOffset = 0
            Player(MyIndex).YOffset = 0

            Exit Sub

        ' ::::::::::::::::::::::::::
        ' :: Player attack packet ::
        ' ::::::::::::::::::::::::::
        Case "attack"
            i = Val(Parse(1))

            ' Set player to attacking
            Player(i).Attacking = 1
            Player(i).AttackTimer = GetTickCount
            Exit Sub

        ' :::::::::::::::::::::::
        ' :: NPC attack packet ::
        ' :::::::::::::::::::::::
        Case "npcattack"
            i = Val(Parse(1))

            ' Set player to attacking
            MapNpc(i).Attacking = 1
            MapNpc(i).AttackTimer = GetTickCount
            Exit Sub

        ' ::::::::::::::::::::::::
        ' :: Map Report packets ::
        ' ::::::::::::::::::::::::
        Case "mapreportclear"
            With frmMapReport.lstMapReport
                .Clear
                .Enabled = False
            End With
            Exit Sub

        Case "mapreportadd"
            For i = 1 To MAX_MAPS
                frmMapReport.lstMapReport.AddItem i & ": " & Parse(i)
            Next i
            Exit Sub

        Case "mapreportend"
            frmMapReport.lstMapReport.Enabled = True

            frmMapReport.Show
            Exit Sub

        ' ::::::::::::::::::::::::::
        ' :: Check for map packet ::
        ' ::::::::::::::::::::::::::
        Case "checkformap"
            ' Erase all players except self
            For i = 1 To HighIndex
                If i <> MyIndex Then
                    Call SetPlayerMap(i, 0)
                End If
            Next i

            ' Erase all temporary tile values
            Call ClearTempTile

            ' Get map num
            X = Val(Parse(1))

            ' Get revision
            Y = Val(Parse(2))

            If FileExist(MAP_PATH & "map" & X & MAP_EXT, True) Then
                ' Check to see if the revisions match
                Dim tempMap As MapRec
                tempMap = GetMap(X)
                If tempMap.Revision = Y Then
                    SaveMap = tempMap

                    Call SendData("needmap" & SEP_CHAR & "no" & END_CHAR)
                    Exit Sub
                End If
            End If

            ' Either the revisions didn't match or we dont have the map, so we need it
            Call SendData("needmap" & SEP_CHAR & "yes" & END_CHAR)
            Exit Sub

        ' :::::::::::::::::::::
        ' :: Map data packet ::
        ' :::::::::::::::::::::
        Case "mapdata"
            n = 1

            SaveMap.name = Parse(n + 1)
            SaveMap.Revision = Val(Parse(n + 2))
            SaveMap.Moral = Val(Parse(n + 3))
            SaveMap.Up = Val(Parse(n + 4))
            SaveMap.Down = Val(Parse(n + 5))
            SaveMap.Left = Val(Parse(n + 6))
            SaveMap.Right = Val(Parse(n + 7))
            SaveMap.Music = Val(Parse(n + 8))
            SaveMap.BootMap = Val(Parse(n + 9))
            SaveMap.BootX = Val(Parse(n + 10))
            SaveMap.BootY = Val(Parse(n + 11))
            SaveMap.Shop = Val(Parse(n + 12))

            n = n + 13

            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    SaveMap.Tile(X, Y).Ground = Val(Parse(n))
                    SaveMap.Tile(X, Y).Mask = Val(Parse(n + 1))
                    SaveMap.Tile(X, Y).Anim = Val(Parse(n + 2))
                    SaveMap.Tile(X, Y).Mask2 = Val(Parse(n + 3))
                    SaveMap.Tile(X, Y).M2Anim = Val(Parse(n + 4))
                    SaveMap.Tile(X, Y).Fringe = Val(Parse(n + 5))
                    SaveMap.Tile(X, Y).FAnim = Val(Parse(n + 6))
                    SaveMap.Tile(X, Y).Fringe2 = Val(Parse(n + 7))
                    SaveMap.Tile(X, Y).F2Anim = Val(Parse(n + 8))
                    SaveMap.Tile(X, Y).Type = Val(Parse(n + 9))
                    SaveMap.Tile(X, Y).Data1 = Val(Parse(n + 10))
                    SaveMap.Tile(X, Y).Data2 = Val(Parse(n + 11))
                    SaveMap.Tile(X, Y).Data3 = Val(Parse(n + 12))

                    n = n + 13
                Next X
            Next Y

            For X = 1 To MAX_MAP_NPCS
                SaveMap.Npc(X) = Val(Parse(n))
                n = n + 1
            Next X

            ' Save the map
            Call SaveLocalMap(Val(Parse(1)))

            ' Check if we get a map from someone else and if we were editing a map cancel it out
            If InEditor Then
                InEditor = False
                frmMainGame.picMapEditor.Visible = False

                If frmMapWarp.Visible Then
                    Unload frmMapWarp
                End If

                If frmMapProperties.Visible Then
                    Unload frmMapProperties
                End If
            End If

            Exit Sub

        ' :::::::::::::::::::::::::::
        ' :: Map items data packet ::
        ' :::::::::::::::::::::::::::
        Case "mapitemdata"
            n = 1

            For i = 1 To MAX_MAP_ITEMS
                SaveMapItem(i).Num = Val(Parse(n))
                SaveMapItem(i).Value = Val(Parse(n + 1))
                SaveMapItem(i).Dur = Val(Parse(n + 2))
                SaveMapItem(i).X = Val(Parse(n + 3))
                SaveMapItem(i).Y = Val(Parse(n + 4))

                n = n + 5
            Next i

            Exit Sub

        ' :::::::::::::::::::::::::
        ' :: Map npc data packet ::
        ' :::::::::::::::::::::::::
        Case "mapnpcdata"
            n = 1

            For i = 1 To MAX_MAP_NPCS
                SaveMapNpc(i).Num = Val(Parse(n))
                SaveMapNpc(i).X = Val(Parse(n + 1))
                SaveMapNpc(i).Y = Val(Parse(n + 2))
                SaveMapNpc(i).Dir = Val(Parse(n + 3))

                n = n + 4
            Next i

            Exit Sub

        ' :::::::::::::::::::::::::::::::
        ' :: Map send completed packet ::
        ' :::::::::::::::::::::::::::::::
        Case "mapdone"
            Map = SaveMap

            For i = 1 To MAX_MAP_ITEMS
                MapItem(i) = SaveMapItem(i)
            Next i

            For i = 1 To MAX_MAP_NPCS
                MapNpc(i) = SaveMapNpc(i)
            Next i

            GettingMap = False
            Call BltMap

            If Map.Moral = MAP_MORAL_NONE Then
                frmMainGame.lblMapInfo.Caption = Trim$(Map.name)
                frmMainGame.lblMapInfo.ForeColor = RGB(231, 0, 0)
            ElseIf Map.Moral = MAP_MORAL_SAFE Then
                frmMainGame.lblMapInfo.Caption = Trim$(Map.name)
                frmMainGame.lblMapInfo.ForeColor = RGB(255, 255, 255)
            ElseIf Map.Moral = MAP_MORAL_INN Then
                frmMainGame.lblMapInfo.Caption = Trim$(Map.name)
                frmMainGame.lblMapInfo.ForeColor = RGB(220, 192, 0)
            ElseIf Map.Moral = MAP_MORAL_ARENA Then
                frmMainGame.lblMapInfo.Caption = Trim$(Map.name)
                frmMainGame.lblMapInfo.ForeColor = RGB(174, 174, 174)
            End If

            BltMap

            ' Play music
            If LenB(MUSIC_EXT) <> 0 Then
                If CurrentSong = Map.Music Then Exit Sub

                Call SwitchSong(Map.Music)
            End If

            Exit Sub

        ' ::::::::::::::::::::
        ' :: Social packets ::
        ' ::::::::::::::::::::
        Case "saymsg", "broadcastmsg", "globalmsg", "playermsg", "mapmsg", "adminmsg"
            Call AddText(Parse(1), Val(Parse(2)))
            Exit Sub

        ' :::::::::::::::::::::::
        ' :: Item spawn packet ::
        ' :::::::::::::::::::::::
        Case "spawnitem"
            n = Val(Parse(1))

            MapItem(n).Num = Val(Parse(2))
            MapItem(n).Value = Val(Parse(3))
            MapItem(n).Dur = Val(Parse(4))
            MapItem(n).X = Val(Parse(5))
            MapItem(n).Y = Val(Parse(6))
            Exit Sub

        ' ::::::::::::::::::::::::
        ' :: Item editor packet ::
        ' ::::::::::::::::::::::::
        Case "itemeditor"
            InItemsEditor = True

            frmIndex.Show
            frmIndex.lstIndex.Clear

            ' Add the names
            For i = 1 To MAX_ITEMS
                frmIndex.lstIndex.AddItem i & ": " & Trim$(Item(i).name)
            Next i

            frmIndex.lstIndex.ListIndex = 0
            Exit Sub

        ' ::::::::::::::::::::::::
        ' :: Update item packet ::
        ' ::::::::::::::::::::::::
        Case "updateitem"
            n = Val(Parse(1))

            ' Update the item
            Item(n).name = Parse(2)
            Item(n).Pic = Val(Parse(3))
            Item(n).Type = Val(Parse(4))
            Item(n).Data1 = Val(Parse(5))
            Item(n).Data2 = Val(Parse(6))
            Item(n).Data3 = Val(Parse(7))
            Exit Sub

        ' :::::::::::::::::::::::::
        ' :: Update Guild Packet ::
        ' :::::::::::::::::::::::::
        Case "updateguild"
            n = Val(Parse(1))

            ' Update the Guild
            Guild(n).name = Trim$(Parse(2))
            Guild(n).Abbreviation = Trim$(Parse(3))
            Guild(n).Founder = Trim$(Parse(4))
            Exit Sub

        ' ::::::::::::::::::::::::::::
        ' :: Update Player in Guild ::
        ' ::::::::::::::::::::::::::::
        Case "playeringuild"
            n = Val(Parse(1))

            ' Update the player in Guild!
            Player(n).Guild = Val(Parse(2))
            Exit Sub

        ' ::::::::::::::::::::::
        ' :: Edit item packet :: <- Used for item editor admins only
        ' ::::::::::::::::::::::
        Case "edititem"
            n = Val(Parse(1))

            ' Update the item
            Item(n).name = Parse(2)
            Item(n).Pic = Val(Parse(3))
            Item(n).Type = Val(Parse(4))
            Item(n).Data1 = Val(Parse(5))
            Item(n).Data2 = Val(Parse(6))
            Item(n).Data3 = Val(Parse(7))

            ' Initialize the item editor
            Call ItemEditorInit

            Exit Sub

        ' ::::::::::::::::::::::::
        ' :: Sign editor packet ::
        ' ::::::::::::::::::::::::
        Case "signeditor"
            InSignEditor = True

            frmIndex.Show
            frmIndex.lstIndex.Clear

            ' Add the names
            For i = 1 To MAX_SIGNS
                frmIndex.lstIndex.AddItem i & ": " & Trim$(Sign(i).name)
            Next i

            frmIndex.lstIndex.ListIndex = 0
            Exit Sub

        ' ::::::::::::::::::::::::
        ' :: Sign names packet  ::
        ' ::::::::::::::::::::::::
        Case "signnames"
            Dim Sn As Long
            For Sn = 1 To MAX_SIGNS
                Sign(Sn).name = Trim$(Parse(Sn))
            Next Sn
            Exit Sub

        ' ::::::::::::::::::::::::
        ' :: Update sign packet ::
        ' ::::::::::::::::::::::::
        Case "updatesign"
            n = Val(Parse(1))

            ' Update the sign name
            Sign(n).name = Trim$(Parse(2))
            Exit Sub

        ' ::::::::::::::::::::::
        ' :: Edit sign packet :: <- Used for sign editor admins only
        ' ::::::::::::::::::::::
        Case "editsign"
            n = Val(Parse(1))

            ' Update the sign
            Sign(n).name = Trim$(Parse(2))
            Sign(n).Background = Trim$(Parse(3))
            Sign(n).Line1 = Trim$(Parse(4))
            Sign(n).Line2 = Trim$(Parse(5))
            Sign(n).Line3 = Trim$(Parse(6))

            ' Initialize the sign editor
            Call SignEditorInit

            Exit Sub

        ' ::::::::::
        ' :: Sign ::
        ' ::::::::::
        Case "sign"
            frmMainGame.picSign.Visible = True
            ' put all the data into the correct area
            frmMainGame.lblNameTop.Caption = Trim$(Parse(2))
            frmMainGame.lblNameBtm.Caption = Trim$(Parse(2))
            frmMainGame.lblLine1Top.Caption = Trim$(Parse(4))
            frmMainGame.lblLine1Btm.Caption = Trim$(Parse(4))
            frmMainGame.lblLine2Top.Caption = Trim$(Parse(5))
            frmMainGame.lblLine2Btm.Caption = Trim$(Parse(5))
            frmMainGame.lblLine3Top.Caption = Trim$(Parse(6))
            frmMainGame.lblLine3Btm.Caption = Trim$(Parse(6))
            Exit Sub

        ' ::::::::::::::::::::::
        ' :: Npc spawn packet ::
        ' ::::::::::::::::::::::
        Case "spawnnpc"
            n = Val(Parse(1))

            MapNpc(n).Num = Val(Parse(2))
            MapNpc(n).X = Val(Parse(3))
            MapNpc(n).Y = Val(Parse(4))
            MapNpc(n).Dir = Val(Parse(5))

            ' Client use only
            MapNpc(n).XOffset = 0
            MapNpc(n).YOffset = 0
            MapNpc(n).Moving = 0
            Exit Sub


        ' :::::::::::::::::::::
        ' :: Npc dead packet ::
        ' :::::::::::::::::::::
        Case "npcdead"
            n = Val(Parse(1))

            MapNpc(n).Num = 0
            MapNpc(n).X = 0
            MapNpc(n).Y = 0
            MapNpc(n).Dir = 0

            ' Client use only
            MapNpc(n).XOffset = 0
            MapNpc(n).YOffset = 0

            MapNpc(n).Moving = 0
            Exit Sub

        ' :::::::::::::::::::::::
        ' :: Npc editor packet ::
        ' :::::::::::::::::::::::
        Case "npceditor"
            InNpcEditor = True

            frmIndex.Show
            frmIndex.lstIndex.Clear

            ' Add the names
            For i = 1 To MAX_NPCS
                frmIndex.lstIndex.AddItem i & ": " & Trim$(Npc(i).name)
            Next i

            frmIndex.lstIndex.ListIndex = 0
            Exit Sub

        ' :::::::::::::::::::::::
        ' :: Update npc packet ::
        ' :::::::::::::::::::::::
        Case "updatenpc"
            n = Val(Parse(1))

            ' Update the item
            Npc(n).name = Parse(2)
            Npc(n).AttackSay = vbNullString
            Npc(n).Sprite = Val(Parse(3))
            Npc(n).SpawnSecs = 0
            Npc(n).Behavior = 0
            Npc(n).Range = 0
            Npc(n).DropChance = 0
            Npc(n).DropItem = 0
            Npc(n).DropItemValue = 0
            Npc(n).STR = 0
            Npc(n).DEF = 0
            Npc(n).speed = 0
            Npc(n).MAGI = 0
            Npc(n).MaxHP = 0
            Npc(n).GiveEXP = 0
            Npc(n).ShopCall = 0
            Exit Sub

        ' :::::::::::::::::::::
        ' :: Edit npc packet :: <- Used for item editor admins only
        ' :::::::::::::::::::::
        Case "editnpc"
            n = Val(Parse(1))

            ' Update the npc
            Npc(n).name = Parse(2)
            Npc(n).AttackSay = Parse(3)
            Npc(n).Sprite = Val(Parse(4))
            Npc(n).SpawnSecs = Val(Parse(5))
            Npc(n).Behavior = Val(Parse(6))
            Npc(n).Range = Val(Parse(7))
            Npc(n).DropChance = Val(Parse(8))
            Npc(n).DropItem = Val(Parse(9))
            Npc(n).DropItemValue = Val(Parse(10))
            Npc(n).STR = Val(Parse(11))
            Npc(n).DEF = Val(Parse(12))
            Npc(n).speed = Val(Parse(13))
            Npc(n).MAGI = Val(Parse(14))
            Npc(n).MaxHP = Val(Parse(15))
            Npc(n).GiveEXP = Val(Parse(16))
            Npc(n).ShopCall = Val(Parse(17))

            ' Initialize the npc editor
            Call NpcEditorInit

            Exit Sub

        ' ::::::::::::::::::::
        ' :: Map key packet ::
        ' ::::::::::::::::::::
        Case "mapkey"
            X = Val(Parse(1))
            Y = Val(Parse(2))
            n = Val(Parse(3))

            TempTile(X, Y).DoorOpen = n
            BltMap
            Exit Sub

        ' :::::::::::::::::::::
        ' :: Edit map packet ::
        ' :::::::::::::::::::::
        Case "editmap"
            Call EditorInit
            Exit Sub

        ' ::::::::::::::::::::::::
        ' :: Shop editor packet ::
        ' ::::::::::::::::::::::::
        Case "shopeditor"
            InShopEditor = True

            frmIndex.Show
            frmIndex.lstIndex.Clear

            ' Add the names
            For i = 1 To MAX_SHOPS
                frmIndex.lstIndex.AddItem i & ": " & Trim$(Shop(i).name)
            Next i

            frmIndex.lstIndex.ListIndex = 0
            Exit Sub

        ' ::::::::::::::::::::::::
        ' :: Update shop packet ::
        ' ::::::::::::::::::::::::
        Case "updateshop"
            n = Val(Parse(1))

            ' Update the shop name
            Shop(n).name = Parse(2)
            Exit Sub

        ' ::::::::::::::::::::::
        ' :: Edit shop packet :: <- Used for shop editor admins only
        ' ::::::::::::::::::::::
        Case "editshop"
            ShopNum = Val(Parse(1))

            ' Update the shop
            Shop(ShopNum).name = Parse(2)
            Shop(ShopNum).JoinSay = Parse(3)
            Shop(ShopNum).LeaveSay = Parse(4)
            Shop(ShopNum).FixesItems = Val(Parse(5))

            n = 6
            For i = 1 To MAX_TRADES

                GiveItem = Val(Parse(n))
                GiveValue = Val(Parse(n + 1))
                GetItem = Val(Parse(n + 2))
                GetValue = Val(Parse(n + 3))
                GiveItem2 = Val(Parse(n + 4))
                GiveValue2 = Val(Parse(n + 5))

                Shop(ShopNum).TradeItem(i).GiveItem = GiveItem
                Shop(ShopNum).TradeItem(i).GiveValue = GiveValue
                Shop(ShopNum).TradeItem(i).GetItem = GetItem
                Shop(ShopNum).TradeItem(i).GetValue = GetValue
                Shop(ShopNum).TradeItem(i).GiveItem2 = GiveItem2
                Shop(ShopNum).TradeItem(i).GiveValue2 = GiveValue2

                n = n + 6
            Next i

            ' Initialize the shop editor
            Call ShopEditorInit

            Exit Sub

        ' :::::::::::::::::::::::::
        ' :: Spell editor packet ::
        ' :::::::::::::::::::::::::
        Case "spelleditor"
            InSpellEditor = True

            frmIndex.Show
            frmIndex.lstIndex.Clear

            ' Add the names
            For i = 1 To MAX_SPELLS
                frmIndex.lstIndex.AddItem i & ": " & Trim$(Spell(i).name)
            Next i

            frmIndex.lstIndex.ListIndex = 0
            Exit Sub

        ' ::::::::::::::::::::::::
        ' :: Update spell packet ::
        ' ::::::::::::::::::::::::
        Case "updatespell"
            n = Val(Parse(1))

            ' Update the spell name
            Spell(n).name = Parse(2)
            Exit Sub

        ' :::::::::::::::::::::::
        ' :: Edit spell packet :: <- Used for spell editor admins only
        ' :::::::::::::::::::::::
        Case "editspell"
            n = Val(Parse(1))

            ' Update the spell
            Spell(n).name = Parse(2)
            Spell(n).ClassReq = Val(Parse(3))
            Spell(n).LevelReq = Val(Parse(4))
            Spell(n).Type = Val(Parse(5))
            Spell(n).Data1 = Val(Parse(6))
            Spell(n).Data2 = Val(Parse(7))
            Spell(n).Data3 = Val(Parse(8))
            Spell(n).Graphic = Val(Parse(9))

            ' Initialize the spell editor
            Call SpellEditorInit

            Exit Sub

        ' :::::::::::::::::::::::::::::::
        ' :: Target XY location packet ::
        ' :::::::::::::::::::::::::::::::
        Case "targetxy"
            VicX = Val(Parse(1))
            VicY = Val(Parse(2))
            SpellAnim = Val(Parse(3))
            SpellVar = 0
            Exit Sub

        ' ::::::::::::::::::
        ' :: Trade packet ::
        ' ::::::::::::::::::
        Case "trade"
            ShopNum = Val(Parse(1))
            If Val(Parse(2)) = 1 Then
                frmTrade.picFixItems.Visible = True
            Else
                frmTrade.picFixItems.Visible = False
            End If

            n = 3
            For i = 1 To MAX_TRADES
                GiveItem = Val(Parse(n))
                GiveValue = Val(Parse(n + 1))
                GetItem = Val(Parse(n + 2))
                GetValue = Val(Parse(n + 3))
                GiveItem2 = Val(Parse(n + 4))
                GiveValue2 = Val(Parse(n + 5))


                If GetItem > 0 Then
                    If GiveItem > 0 And GiveItem2 > 0 Then
                        frmTrade.lstTrade.AddItem "Give " & Trim$(Shop(ShopNum).name) & " " & GiveValue & " " & Trim$(Item(GiveItem).name) & " and " & GiveValue2 & " " & Trim$(Item(GiveItem2).name) & " for " & GetValue & " " & Trim$(Item(GetItem).name)
                    ElseIf GiveItem > 0 And GiveItem2 <= 0 Then
                        frmTrade.lstTrade.AddItem "Give " & Trim$(Shop(ShopNum).name) & " " & GiveValue & " " & Trim$(Item(GiveItem).name) & " for " & GetValue & " " & Trim$(Item(GetItem).name)
                    ElseIf GiveItem <= 0 And GiveItem2 > 0 Then
                        frmTrade.lstTrade.AddItem "Give " & Trim$(Shop(ShopNum).name) & " " & GiveValue2 & " " & Trim$(Item(GiveItem2).name) & " for " & GetValue & " " & Trim$(Item(GetItem).name)
                    End If
                End If
                n = n + 6
            Next i

            If frmTrade.lstTrade.ListCount > 0 Then
                frmTrade.lstTrade.ListIndex = 0
            End If
            frmTrade.Caption = GAME_NAME & " :: Trade"
            frmTrade.Show vbModal
            Exit Sub

        ' :::::::::::::::::::
        ' :: Spells packet ::
        ' :::::::::::::::::::
        Case "spells"

            frmMainGame.picPlayerSpells.Visible = True
            frmMainGame.lstSpells.Clear

            ' Put spells known in player record
            For i = 1 To MAX_PLAYER_SPELLS
                Player(MyIndex).Spell(i) = Val(Parse(i))
                If Player(MyIndex).Spell(i) <> 0 Then
                    frmMainGame.lstSpells.AddItem i & ": " & Trim$(Spell(Player(MyIndex).Spell(i)).name)
                Else
                    frmMainGame.lstSpells.AddItem i & ": Unused Spell Slot"
                End If
            Next i

            frmMainGame.lstSpells.ListIndex = 0

            Exit Sub

        ' :::::::::::::::::::::::
        ' :: Live Stats Packet ::
        ' :::::::::::::::::::::::
        Case "livestats"

            ' GetPlayerHP (MyIndex)
            ' GetPlayerMP (MyIndex)
            ' GetPlayerSP (MyIndex)
            If Trim$(Parse(1)) < 1 Then
                frmMainGame.lblLevel.Caption = "1"
            Else
                frmMainGame.lblLevel.Caption = Trim$(Parse(1))
            End If

' lblHP.Caption = GetPlayerHP(MyIndex) & "/" & GetPlayerMaxHP(MyIndex)
' lblMP.Caption = GetPlayerMP(MyIndex) & "/" & GetPlayerMaxMP(MyIndex)
' lblSP.Caption = GetPlayerSP(MyIndex) & "/" & GetPlayerMaxSP(MyIndex)


            frmMainGame.lblSTR.Caption = GetPlayerSTR(MyIndex)
            frmMainGame.lblDEF.Caption = GetPlayerDEF(MyIndex)
            frmMainGame.lblMAGI.Caption = GetPlayerMAGI(MyIndex)
            frmMainGame.lblSPEED.Caption = GetPlayerSPEED(MyIndex)

            Call SetPlayerPOINTS(MyIndex, Trim$(Parse(6)))
            frmMainGame.lblPoints.Caption = GetPlayerPOINTS(MyIndex)
            frmMainGame.lblPlayerPoints.Caption = GetPlayerPOINTS(MyIndex)

            frmMainGame.lblEXP.Caption = Trim$(Parse(2))
            frmMainGame.lblTNL.Caption = Int(Trim$(Parse(3)) - Trim$(Parse(2)))

            frmMainGame.lblCHit.Caption = Trim$(Parse(4)) & "%"
            frmMainGame.lblBlock.Caption = Trim$(Parse(5)) & "%"


            Exit Sub


        ' :::::::::::::::::::::::
        ' :: High Index Packet ::
        ' :::::::::::::::::::::::
        Case "highindex"
            HighIndex = Val(Parse(1))
            Exit Sub

        ' ::::::::::::::::::::
        ' :: Weather packet ::
        ' ::::::::::::::::::::
        Case "weather"
            GameWeather = Val(Parse(1))
            Exit Sub

        ' :::::::::::::::::
        ' :: Time packet ::
        ' :::::::::::::::::
        Case "time"
            GameTime = Val(Parse(1))
            Exit Sub

        ' :::::::::::::::::
        ' :: Site packet ::
        ' :::::::::::::::::
        Case "sendsite"
            WEBSITE = Trim$(Parse(1))
            Exit Sub

        ' :::::::::::::::::
        ' :: Name packet ::
        ' :::::::::::::::::
        Case "sendname"
            GAME_NAME = Trim$(Parse(1))
            Exit Sub

        ' ::::::::::::::::::
        ' :: Maxes packet ::
        ' ::::::::::::::::::
        Case "sendmaxes"
            MAX_NPCS = Val(Parse(1))
            MAX_ITEMS = Val(Parse(2))
            MAX_PLAYERS = Val(Parse(3))
            MAX_SHOPS = Val(Parse(4))
            MAX_SPELLS = Val(Parse(5))
            MAX_SIGNS = Val(Parse(6))
            MAX_MAPS = Val(Parse(7))
            MAX_GUILDS = Val(Parse(8))
            MAX_GUILD_MEMBERS = Val(Parse(9))

            ReDim Shop(1 To MAX_SHOPS) As ShopRec
            ReDim Sign(1 To MAX_SIGNS) As SignRec
            ReDim Spell(1 To MAX_SPELLS) As SpellRec
            ReDim Item(1 To MAX_ITEMS) As ItemRec
            ReDim Player(1 To MAX_PLAYERS) As PlayerRec
            ReDim Npc(1 To MAX_NPCS) As NpcRec
            ReDim Guild(1 To MAX_GUILDS) As GuildRec

            For i = 1 To MAX_GUILDS
                ReDim Preserve Guild(i).Member(1 To MAX_GUILD_MEMBERS) As String * NAME_LENGTH
            Next i

            frmNpcEditor.scrlNum.max = MAX_ITEMS
            frmMapDmg.scrlItem.max = MAX_ITEMS
            frmMapKey.scrlItem.max = MAX_ITEMS
            frmMapItem.scrlItem.max = MAX_ITEMS
            frmItemEditor.scrlSpell.max = MAX_SPELLS
            frmSignChoose.scrlSignNum.max = MAX_SIGNS
            frmGuildCreate.scrlGuild.max = MAX_GUILDS
            Exit Sub

        ' ::::::::::::::::::::::::
        ' :: Blit Player Damage ::
        ' ::::::::::::::::::::::::
        Case "blitplayerdmg"
            DmgDamage = Val(Parse(1))
            NPCWho = Val(Parse(2))
            DmgTime = GetTickCount
            iii = 0
            Exit Sub

        ' :::::::::::::::::::::
        ' :: Blit NPC Damage ::
        ' :::::::::::::::::::::
        Case "blitnpcdmg"
            NPCDmgDamage = Val(Parse(1))
            NPCDmgTime = GetTickCount
            II = 0
            Exit Sub

    End Select
End Sub
