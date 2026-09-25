Attribute VB_Name = "modHandleData"
Option Explicit

Sub HandleData(ByVal Index As Long, ByVal Data As String)
    Dim Parse() As String
    Dim name As String
    Dim EncKey As String
    Dim Password As String
    Dim Sex As Long
    Dim Class As Long
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
    Dim Movement As Long
    Dim I As Long, N As Long, X As Long, y As Long, f As Long
    Dim MapNum As Long
    Dim s As String
    Dim tMapStart As Long, tMapEnd As Long
    Dim ShopNum As Long, ItemNum As Long
    Dim DurNeeded As Long, GoldNeeded As Long
    Dim BIp As Integer
    Dim Packet As String
    
    On Error GoTo ErrorHandle

    ' Handle Data
    Parse = Split(Data, SEP_CHAR)

    ' :::::::::::::::::::::::::::::::::::::::::::::::
    ' :: Requesting classes for making a character ::
    ' :::::::::::::::::::::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "getclasses" Then
        If Not IsPlaying(Index) Then
            Call SendNewCharClasses(Index)
        End If
        Exit Sub
    End If

    ' ::::::::::::::::::::::::
    ' :: New account packet ::
    ' ::::::::::::::::::::::::
    If LCase$(Parse(0)) = "newaccount" Then
        If Not IsPlaying(Index) And Not IsLoggedIn(Index) Then
            ' Get the data
            name = Parse(1)
            Password = Parse(2)
            ' Sex = Parse(3)

            If IsBannedHD(Player(Index).HDSerial) Then
                Call AlertMsg(Index, "You have been banned from " & GAME_NAME & ", you can no longer play!")
                Exit Sub
            End If

            ' Prevent hacking
            If Len(Trim$(name)) < 3 Or Len(Trim$(Password)) < 3 Then
                Call AlertMsg(Index, "Your name and password must be at least three characters in length")
                Exit Sub
            End If

            ' Prevent hacking
            For I = 1 To Len(name)
                N = Asc(Mid$(name, I, 1))

                If (N >= 65 And N <= 90) Or (N >= 97 And N <= 122) Or (N = 95) Or (N = 32) Or (N >= 48 And N <= 57) Then
                Else
                    Call AlertMsg(Index, "Invalid name, only letters, numbers, spaces, and _ allowed in names.")
                    Exit Sub
                End If
            Next I

            ' Check to see if account already exists
            If Not AccountExist(name) Then
                Call AddAccount(Index, name, Password)
                Call TextAdd(frmServer.txtText, "Account " & name & " has been created.", True)
                Call AddLog("Account " & name & " has been created.", PLAYER_LOG)
                Call AlertMsg(Index, "Your account has been created!")
            Else
                Call AlertMsg(Index, "Sorry, that account name is already taken!")
            End If
        End If
        Exit Sub
    End If

    ' :::::::::::::::::::::::::::
    ' :: Delete account packet ::
    ' :::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "delaccount" Then
        If Not IsPlaying(Index) And Not IsLoggedIn(Index) Then
            ' Get the data
            name = Parse(1)
            Password = Parse(2)

            If IsBannedHD(Player(Index).HDSerial) Then
                Call AlertMsg(Index, "You have been banned from " & GAME_NAME & ", you can no longer play!")
                Exit Sub
            End If

            ' Prevent hacking
            If Len(Trim$(name)) < 3 Or Len(Trim$(Password)) < 3 Then
                Call AlertMsg(Index, "The name and password must be at least three characters in length")
                Exit Sub
            End If

            If Not AccountExist(name) Then
                Call AlertMsg(Index, "That account name does not exist.")
                Exit Sub
            End If

            If Not PasswordOK(name, Password) Then
                Call AlertMsg(Index, "Incorrect password.")
                Exit Sub
            End If

            If Not EncKeyOK(name, EncKey) Then
                Call AlertMsg(Index, "Incorrect Encryption Key.")
                Exit Sub
            End If

            ' Delete names from master name file
            Call LoadPlayer(Index, name)
            For I = 1 To MAX_CHARS
                If Trim$(Player(Index).Char(I).name) <> "" Then
                    Call DeleteName(Player(Index).Char(I).name)
                End If
            Next I
            Call ClearPlayer(Index)

            ' Everything went ok
            Call Kill(App.Path & "\data\accounts\" & Trim$(name) & ".act")
            Call AddLog("Account " & Trim$(name) & " has been deleted.", PLAYER_LOG)
            Call AlertMsg(Index, "Your account has been deleted.")
        End If
        Exit Sub
    End If

    ' ::::::::::::::::::
    ' :: Login packet ::
    ' ::::::::::::::::::
    If LCase$(Parse(0)) = "login" Then
        If Not IsPlaying(Index) And Not IsLoggedIn(Index) Then
            ' Get the data
            name = Parse(1)
            Password = Parse(2)
            EncKey = Parse(6)

            ' Are they banned?
            If IsBannedHD(Player(Index).HDSerial) Then
                Call AlertMsg(Index, "You have been banned from " & GAME_NAME & ", you can no longer play!")
                Exit Sub
            End If

            ' Prevent Dupeing
            For I = 1 To Len(name)
                N = Asc(Mid(name, I, 1))

                If (N >= 65 And N <= 90) Or (N >= 97 And N <= 122) Or (N = 95) Or (N = 32) Or (N >= 48 And N <= 57) Then
                Else
                    Call AlertMsg(Index, "Account Duplication Not Allowed!")
                    Exit Sub
                End If
            Next I

            ' Check versions
            If Val(Parse(3)) < CLIENT_MAJOR Or Val(Parse(4)) < CLIENT_MINOR Or Val(Parse(5)) < CLIENT_REVISION Then
                Call AlertMsg(Index, "Version outdated, please visit " & GAME_WEBSITE)
                Exit Sub
            End If

            If Len(Trim$(name)) < 3 Or Len(Trim$(Password)) < 3 Then
                Call AlertMsg(Index, "Your name and password must be at least three characters in length")
                Exit Sub
            End If

            If Not AccountExist(name) Then
                Call AlertMsg(Index, "That account name does not exist.")
                Exit Sub
            End If

            If Not PasswordOK(name, Password) Then
                Call AlertMsg(Index, "Incorrect password.")
                Exit Sub
            End If

            If IsMultiAccounts(name) Then
                Call AlertMsg(Index, "Multiple account logins is not authorized.")
                Exit Sub
            End If

            ' Everything went ok

            ' Load the player
            Call LoadPlayer(Index, name)
            Call SendChars(Index)

            ' Show the player up on the socket status
            Call AddLog(GetPlayerLogin(Index) & " has logged in from " & GetPlayerIP(Index) & ".", PLAYER_LOG)
            Call TextAdd(frmServer.txtText, GetPlayerLogin(Index) & " has logged in from " & GetPlayerIP(Index) & ".", True)
        End If
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::
    ' :: Add character packet ::
    ' ::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "addchar" Then
        If Not IsPlaying(Index) Then
            name = Parse(1)
            Sex = Val(Parse(2))
            Class = Val(Parse(3))
            CharNum = Val(Parse(4))

            ' Prevent hacking
            If Len(Trim$(name)) < 3 Then
                Call AlertMsg(Index, "Character name must be at least three characters in length.")
                Exit Sub
            End If

            ' Prevent being me
            If LCase$(Trim$(name)) = "magnus" Then
                Call AlertMsg(Index, "Lets get one thing straight, you are not me, ok? :)")
                Exit Sub
            End If

            ' Prevent hacking
            For I = 1 To Len(name)
                N = Asc(Mid$(name, I, 1))

                If (N >= 65 And N <= 90) Or (N >= 97 And N <= 122) Or (N = 95) Or (N = 32) Or (N >= 48 And N <= 57) Then
                Else
                    Call AlertMsg(Index, "Invalid name, only letters, numbers, spaces, and _ allowed in names.")
                    Exit Sub
                End If
            Next I

            ' Prevent hacking
            If CharNum < 1 Or CharNum > MAX_CHARS Then
                Call HackingAttempt(Index, "Invalid CharNum")
                Exit Sub
            End If

            ' Prevent hacking
            If (Sex < SEX_MALE) Or (Sex > SEX_FEMALE) Then
                Call HackingAttempt(Index, "Invalid Sex (dont laugh)")
                Exit Sub
            End If

            ' Prevent hacking
            If Class < 0 Or Class > Max_Classes Then
                Call HackingAttempt(Index, "Invalid Class")
                Exit Sub
            End If

            ' Check if char already exists in slot
            If CharExist(Index, CharNum) Then
                Call AlertMsg(Index, "Character already exists!")
                Exit Sub
            End If

            ' Check if name is already in use
            If FindChar(name) Then
                Call AlertMsg(Index, "Sorry, but that name is in use!")
                Exit Sub
            End If

            ' Everything went ok, add the character
            Call AddChar(Index, name, Sex, Class, CharNum)
            Call SavePlayer(Index)
            Call AddLog("Character " & name & " added to " & GetPlayerLogin(Index) & "'s account.", PLAYER_LOG)
            Call AlertMsg(Index, "Character has been created!")
        End If
        Exit Sub
    End If

    ' :::::::::::::::::::::::::::::::
    ' :: Deleting character packet ::
    ' :::::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "delchar" Then
        If Not IsPlaying(Index) Then
            CharNum = Val(Parse(1))

            ' Prevent hacking
            If CharNum < 1 Or CharNum > MAX_CHARS Then
                Call HackingAttempt(Index, "Invalid CharNum")
                Exit Sub
            End If

            Call DelChar(Index, CharNum)
            Call AddLog("Character deleted on " & GetPlayerLogin(Index) & "'s account.", PLAYER_LOG)
            Call AlertMsg(Index, "Character has been deleted!")
        End If
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::::
    ' :: Using character packet ::
    ' ::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "usechar" Then
        If Not IsPlaying(Index) Then
            CharNum = Val(Parse(1))

            ' Prevent hacking
            If CharNum < 1 Or CharNum > MAX_CHARS Then
                Call HackingAttempt(Index, "Invalid CharNum")
                Exit Sub
            End If

            ' Check to make sure the character exists and if so, set it as its current char
            If CharExist(Index, CharNum) Then
                Player(Index).CharNum = CharNum
                Call JoinGame(Index)

                CharNum = Player(Index).CharNum
                Call AddLog(GetPlayerLogin(Index) & "/" & GetPlayerName(Index) & " has began playing " & GAME_NAME & ".", PLAYER_LOG)
                Call TextAdd(frmServer.txtText, GetPlayerLogin(Index) & "/" & GetPlayerName(Index) & " has began playing " & GAME_NAME & ".", True)
                Call UpdateCaption

                ' Now we want to check if they are already on the master list (this makes it add the user if they already haven't been added to the master list for older accounts)
                If Not FindChar(GetPlayerName(Index)) Then
                    f = FreeFile
                    Open App.Path & "\data\accounts\charlist.txt" For Append As #f
                    Print #f, GetPlayerName(Index)
                    Close #f
                End If
            Else
                Call AlertMsg(Index, "Character does not exist!")
            End If
        End If
        Exit Sub
    End If

    ' ::::::::::::::::::::
    ' :: Social packets ::
    ' ::::::::::::::::::::
    If LCase$(Parse(0)) = "saymsg" Then
        Msg = Parse(1)

        ' Prevent hacking
        For I = 1 To Len(Msg)
            If Asc(Mid$(Msg, I, 1)) < 32 Or Asc(Mid$(Msg, I, 1)) > 126 Then
                Call HackingAttempt(Index, "Say Text Modification")
                Exit Sub
            End If
        Next I

        Call AddLog("Map #" & GetPlayerMap(Index) & ": " & GetPlayerName(Index) & " says, '" & Msg & "'", PLAYER_LOG)
        Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " says, '" & Msg & "'", SayColor)
        Exit Sub
    End If

    If LCase$(Parse(0)) = "emotemsg" Then
        Msg = Parse(1)

        ' Prevent hacking
        For I = 1 To Len(Msg)
            If Asc(Mid$(Msg, I, 1)) < 32 Or Asc(Mid$(Msg, I, 1)) > 126 Then
                Call HackingAttempt(Index, "Emote Text Modification")
                Exit Sub
            End If
        Next I

        Call AddLog("Map #" & GetPlayerMap(Index) & ": " & GetPlayerName(Index) & " " & Msg, PLAYER_LOG)
        Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " " & Msg, EmoteColor)
        Exit Sub
    End If

    If LCase$(Parse(0)) = "broadcastmsg" Then
        Msg = Parse(1)

        ' Prevent hacking
        For I = 1 To Len(Msg)
            If Asc(Mid$(Msg, I, 1)) < 32 Or Asc(Mid$(Msg, I, 1)) > 126 Then
                Call HackingAttempt(Index, "Broadcast Text Modification")
                Exit Sub
            End If
        Next I

        s = GetPlayerName(Index) & ": " & Msg
        Call AddLog(s, PLAYER_LOG)
        Call GlobalMsg(s, BroadcastColor)
        Call TextAdd(frmServer.txtText, s, True)
        Exit Sub
    End If

    If LCase$(Parse(0)) = "globalmsg" Then
        Msg = Parse(1)

        ' Prevent hacking
        For I = 1 To Len(Msg)
            If Asc(Mid$(Msg, I, 1)) < 32 Or Asc(Mid$(Msg, I, 1)) > 126 Then
                Call HackingAttempt(Index, "Global Text Modification")
                Exit Sub
            End If
        Next I

        If GetPlayerAccess(Index) > 0 Then
            s = "(global) " & GetPlayerName(Index) & ": " & Msg
            Call AddLog(s, ADMIN_LOG)
            Call GlobalMsg(s, GlobalColor)
            Call TextAdd(frmServer.txtText, s, True)
        End If
        Exit Sub
    End If

    If LCase$(Parse(0)) = "adminmsg" Then
        Msg = Parse(1)

        ' Prevent hacking
        For I = 1 To Len(Msg)
            If Asc(Mid$(Msg, I, 1)) < 32 Or Asc(Mid$(Msg, I, 1)) > 126 Then
                Call HackingAttempt(Index, "Admin Text Modification")
                Exit Sub
            End If
        Next I

        If GetPlayerAccess(Index) > 0 Then
            Call AddLog("(admin " & GetPlayerName(Index) & ") " & Msg, ADMIN_LOG)
            Call AdminMsg("(admin " & GetPlayerName(Index) & ") " & Msg, AdminColor)
        End If
        Exit Sub
    End If

    If LCase$(Parse(0)) = "playermsg" Then
        MsgTo = FindPlayer(Parse(1))
        Msg = Parse(2)

        ' Prevent hacking
        For I = 1 To Len(Msg)
            If Asc(Mid$(Msg, I, 1)) < 32 Or Asc(Mid$(Msg, I, 1)) > 126 Then
                Call HackingAttempt(Index, "Player Msg Text Modification")
                Exit Sub
            End If
        Next I

        ' Check if they are trying to talk to themselves
        If MsgTo <> Index Then
            If MsgTo > 0 Then
                Call AddLog(GetPlayerName(Index) & " tells " & GetPlayerName(MsgTo) & ", " & Msg & "'", PLAYER_LOG)
                Call PlayerMsg(MsgTo, GetPlayerName(Index) & " tells you, '" & Msg & "'", TellColor)
                Call PlayerMsg(Index, "You tell " & GetPlayerName(MsgTo) & ", '" & Msg & "'", TellColor)
            Else
                Call PlayerMsg(Index, "Player is not online.", White)
            End If
        Else
            Call AddLog("Map #" & GetPlayerMap(Index) & ": " & GetPlayerName(Index) & " begins to mumble to himself, what a wierdo...", PLAYER_LOG)
            Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " begins to mumble to himself, what a wierdo...", Green)
        End If

        Exit Sub
    End If

    ' :::::::::::::::::::::::::::::
    ' :: Moving character packet ::
    ' :::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "playermove" And Player(Index).GettingMap = NO Then
        Dir = Val(Parse(1))
        Movement = Val(Parse(2))

        ' Prevent hacking
        If Dir < DIR_UP Or Dir > DIR_RIGHT Then
            Call HackingAttempt(Index, "Invalid Direction")
            Exit Sub
        End If

        ' Prevent hacking
        If Movement < 1 Or Movement > 2 Then
            Call HackingAttempt(Index, "Invalid Movement")
            Exit Sub
        End If

        ' Prevent player from moving if they have casted a spell
        If Player(Index).CastedSpell = YES Then
            ' Check if they have already casted a spell, and if so we can't let them move
            If GetTickCount > Player(Index).AttackTimer + 1000 Then
                Player(Index).CastedSpell = NO
            Else
                Call SendPlayerXY(Index)
                Exit Sub
            End If
        End If

        Call PlayerMove(Index, Dir, Movement)
        Exit Sub
    End If

    ' :::::::::::::::::::::::::::::
    ' :: Moving character packet ::
    ' :::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "playerdir" And Player(Index).GettingMap = NO Then
        Dir = Val(Parse(1))

        ' Prevent hacking
        If Dir < DIR_UP Or Dir > DIR_RIGHT Then
            Call HackingAttempt(Index, "Invalid Direction")
            Exit Sub
        End If

        Call SetPlayerDir(Index, Dir)
        Call SendDataToMapBut(Index, GetPlayerMap(Index), "PLAYERDIR" & SEP_CHAR & Index & SEP_CHAR & GetPlayerDir(Index) & END_CHAR)
        Exit Sub
    End If

    ' :::::::::::::::::::::
    ' :: Use item packet ::
    ' :::::::::::::::::::::
    If LCase$(Parse(0)) = "useitem" Then
        InvNum = Val(Parse(1))
        CharNum = Player(Index).CharNum

        ' Prevent hacking
        If InvNum < 1 Or InvNum > MAX_ITEMS Then
            Call HackingAttempt(Index, "Invalid InvNum")
            Exit Sub
        End If

        ' Prevent hacking
        If CharNum < 1 Or CharNum > MAX_CHARS Then
            Call HackingAttempt(Index, "Invalid CharNum")
            Exit Sub
        End If

        If (GetPlayerInvItemNum(Index, InvNum) > 0) And (GetPlayerInvItemNum(Index, InvNum) <= MAX_ITEMS) Then
            ItemNum = GetPlayerInvItemNum(Index, InvNum)
            N = Item(ItemNum).Data2

            ' Find out what kind of item it is
            Select Case Item(ItemNum).Type
                Case ITEM_TYPE_ARMOR
                    If InvNum <> GetPlayerArmorSlot(Index) Then
                        If Int(GetPlayerDEF(Index)) < N Then
                            Call PlayerMsg(Index, "Your defense is to low to wear this armor!  Required DEF (" & N * 2 & ")", BrightRed)
                            Exit Sub
                        End If
                        If Int(GetPlayerInvItemDur(Index, InvNum)) <= 0 Then
                            Call PlayerMsg(Index, "This item is broken! Please get it fixed first!", BrightRed)
                            Exit Sub
                        End If
                        Call SetPlayerArmorSlot(Index, InvNum)
                        MyScript.ExecuteStatement "\scripts\Main.as", "OnEquipItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_ARMOR & ", " & ItemNum
                        
                    Else
                        Call SetPlayerArmorSlot(Index, 0)
                        MyScript.ExecuteStatement "\scripts\Main.as", "OnUnEquipItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_ARMOR & ", " & ItemNum
                    End If
                    Call SendWornEquipment(Index)

                Case ITEM_TYPE_WEAPON
                    If InvNum <> GetPlayerWeaponSlot(Index) Then
                        If Int(GetPlayerSTR(Index)) < N Then
                            Call PlayerMsg(Index, "Your strength is to low to hold this weapon!  Required STR (" & N * 2 & ")", BrightRed)
                            Exit Sub
                        End If
                        If Int(GetPlayerInvItemDur(Index, InvNum)) <= 0 Then
                            Call PlayerMsg(Index, "This item is broken! Please get it fixed first!", BrightRed)
                            Exit Sub
                        End If
                        
                        MyScript.ExecuteStatement "\scripts\Main.as", "OnEquipItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_WEAPON & ", " & ItemNum
                        Call SetPlayerWeaponSlot(Index, InvNum)
 
                        
                    Else
                        Call SetPlayerWeaponSlot(Index, 0)
                        MyScript.ExecuteStatement "\scripts\Main.as", "OnUnEquipItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_WEAPON & ", " & ItemNum
                    End If
                    Call SendWornEquipment(Index)

                Case ITEM_TYPE_HELMET
                    If InvNum <> GetPlayerHelmetSlot(Index) Then
                        If Int(GetPlayerSPEED(Index)) < N Then
                            Call PlayerMsg(Index, "Your speed coordination is to low to wear this helmet!  Required SPEED (" & N * 2 & ")", BrightRed)
                            Exit Sub
                        End If
                        If Int(GetPlayerInvItemDur(Index, InvNum)) <= 0 Then
                            Call PlayerMsg(Index, "This item is broken! Please get it fixed first!", BrightRed)
                            Exit Sub
                        End If
                        
                        MyScript.ExecuteStatement "\scripts\Main.as", "OnEquipItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_HELMET & ", " & ItemNum
                        Call SetPlayerHelmetSlot(Index, InvNum)

                    Else
                        Call SetPlayerHelmetSlot(Index, 0)
                        MyScript.ExecuteStatement "\scripts\Main.as", "OnUnEquipItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_HELMET & ", " & ItemNum
                    End If
                    Call SendWornEquipment(Index)

                Case ITEM_TYPE_SHIELD
                    If InvNum <> GetPlayerShieldSlot(Index) Then
                        MyScript.ExecuteStatement "\scripts\Main.as", "OnEquipItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_SHIELD & ", " & ItemNum
                        Call SetPlayerShieldSlot(Index, InvNum)

                    Else
                        Call SetPlayerShieldSlot(Index, 0)
                        MyScript.ExecuteStatement "\scripts\Main.as", "OnUnEquipItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_SHIELD & ", " & ItemNum

                    End If
                    Call SendWornEquipment(Index)

                Case ITEM_TYPE_POTIONADDHP
                    Call SetPlayerHP(Index, GetPlayerHP(Index) + Item(Player(Index).Char(CharNum).Inv(InvNum).Num).Data1)
                    Call TakeItem(Index, Player(Index).Char(CharNum).Inv(InvNum).Num, 0)
                    MyScript.ExecuteStatement "\scripts\Main.as", "OnUseItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_POTIONADDHP & ", " & ItemNum
                    Call SendHP(Index)

                Case ITEM_TYPE_POTIONADDMP
                    Call SetPlayerMP(Index, GetPlayerMP(Index) + Item(Player(Index).Char(CharNum).Inv(InvNum).Num).Data1)
                    Call TakeItem(Index, Player(Index).Char(CharNum).Inv(InvNum).Num, 0)
                    MyScript.ExecuteStatement "\scripts\Main.as", "OnUseItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_POTIONADDMP & ", " & ItemNum
                    Call SendMP(Index)

                Case ITEM_TYPE_POTIONADDSP
                    Call SetPlayerSP(Index, GetPlayerSP(Index) + Item(Player(Index).Char(CharNum).Inv(InvNum).Num).Data1)
                    Call TakeItem(Index, Player(Index).Char(CharNum).Inv(InvNum).Num, 0)
                    MyScript.ExecuteStatement "\scripts\Main.as", "OnUseItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_POTIONADDSP & ", " & ItemNum
                    Call SendSP(Index)

                Case ITEM_TYPE_POTIONSUBHP
                    Call SetPlayerHP(Index, GetPlayerHP(Index) - Item(Player(Index).Char(CharNum).Inv(InvNum).Num).Data1)
                    Call TakeItem(Index, Player(Index).Char(CharNum).Inv(InvNum).Num, 0)
                    MyScript.ExecuteStatement "\scripts\Main.as", "OnUseItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_POTIONSUBHP & ", " & ItemNum
                    Call SendHP(Index)

                Case ITEM_TYPE_POTIONSUBMP
                    Call SetPlayerMP(Index, GetPlayerMP(Index) - Item(Player(Index).Char(CharNum).Inv(InvNum).Num).Data1)
                    Call TakeItem(Index, Player(Index).Char(CharNum).Inv(InvNum).Num, 0)
                    MyScript.ExecuteStatement "\scripts\Main.as", "OnUseItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_POTIONSUBMP & ", " & ItemNum
                    Call SendMP(Index)

                Case ITEM_TYPE_POTIONSUBSP
                    Call SetPlayerSP(Index, GetPlayerSP(Index) - Item(Player(Index).Char(CharNum).Inv(InvNum).Num).Data1)
                    Call TakeItem(Index, Player(Index).Char(CharNum).Inv(InvNum).Num, 0)
                    MyScript.ExecuteStatement "\scripts\Main.as", "OnUseItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_POTIONSUBSP & ", " & ItemNum
                    Call SendSP(Index)

                Case ITEM_TYPE_WARP
                    Call PlayerWarp(Index, Item(Player(Index).Char(CharNum).Inv(InvNum).Num).Data1, Item(Player(Index).Char(CharNum).Inv(InvNum).Num).Data2, Item(Player(Index).Char(CharNum).Inv(InvNum).Num).Data3)
                    Call TakeItem(Index, Player(Index).Char(CharNum).Inv(InvNum).Num, 0)
                    MyScript.ExecuteStatement "\scripts\Main.as", "OnUseItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_WARP & ", " & ItemNum

                Case ITEM_TYPE_KEY
                    Select Case GetPlayerDir(Index)
                        Case DIR_UP
                            If GetPlayerY(Index) > 0 Then
                                X = GetPlayerX(Index)
                                y = GetPlayerY(Index) - 1
                            Else
                                Exit Sub
                            End If

                        Case DIR_DOWN
                            If GetPlayerY(Index) < MAX_MAPY Then
                                X = GetPlayerX(Index)
                                y = GetPlayerY(Index) + 1
                            Else
                                Exit Sub
                            End If

                        Case DIR_LEFT
                            If GetPlayerX(Index) > 0 Then
                                X = GetPlayerX(Index) - 1
                                y = GetPlayerY(Index)
                            Else
                                Exit Sub
                            End If

                        Case DIR_RIGHT
                            If GetPlayerX(Index) < MAX_MAPX Then
                                X = GetPlayerX(Index) + 1
                                y = GetPlayerY(Index)
                            Else
                                Exit Sub
                            End If
                    End Select

                    ' Check if a key exists
                    If Map(GetPlayerMap(Index)).Tile(X, y).Type = TILE_TYPE_KEY Then
                        ' Check if the key they are using matches the map key
                        If GetPlayerInvItemNum(Index, InvNum) = Map(GetPlayerMap(Index)).Tile(X, y).Data1 Then
                            TempTile(GetPlayerMap(Index)).DoorOpen(X, y) = YES
                            TempTile(GetPlayerMap(Index)).DoorTimer = GetTickCount

                            Call SendDataToMap(GetPlayerMap(Index), "MAPKEY" & SEP_CHAR & X & SEP_CHAR & y & SEP_CHAR & 1 & END_CHAR)
                            Call MapMsg(GetPlayerMap(Index), "A door has been unlocked.", White)
                            MyScript.ExecuteStatement "\scripts\Main.as", "OnUseItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_KEY & ", " & ItemNum

                            ' Check if we are supposed to take away the item
                            If Map(GetPlayerMap(Index)).Tile(X, y).Data2 = 1 Then
                                Call TakeItem(Index, GetPlayerInvItemNum(Index, InvNum), 0)
                                Call PlayerMsg(Index, "The key disolves.", Yellow)
                            End If
                        End If
                    End If

                Case ITEM_TYPE_SPELL
                    ' Get the spell num
                    N = Item(GetPlayerInvItemNum(Index, InvNum)).Data1

                    If N > 0 Then
                        ' Make sure they are the right class
                        If Spell(N).ClassReq - 1 = GetPlayerClass(Index) Or Spell(N).ClassReq = 0 Then
                            ' Make sure they are the right level
                            I = GetSpellReqLevel(Index, N)
                            If I <= GetPlayerLevel(Index) Then
                                I = FindOpenSpellSlot(Index)

                                ' Make sure they have an open spell slot
                                If I > 0 Then
                                    ' Make sure they dont already have the spell
                                    If Not HasSpell(Index, N) Then
                                        Call SetPlayerSpell(Index, I, N)
                                        Call TakeItem(Index, GetPlayerInvItemNum(Index, InvNum), 0)
                                        Call PlayerMsg(Index, "You study the spell carefully...", Yellow)
                                        Call PlayerMsg(Index, "You have learned a new spell!", White)
                                    Else
                                        Call TakeItem(Index, GetPlayerInvItemNum(Index, InvNum), 0)
                                        Call PlayerMsg(Index, "You have already learned this spell!  The spells crumbles into dust.", BrightRed)
                                    End If
                                    MyScript.ExecuteStatement "\scripts\Main.as", "OnUseItem " & Index & ", " & InvNum & ", " & ITEM_TYPE_SPELL & ", " & ItemNum
                                Else
                                    Call PlayerMsg(Index, "You have learned all that you can learn!", BrightRed)
                                End If
                            Else
                                Call PlayerMsg(Index, "You must be level " & I & " to learn this spell.", White)
                            End If
                        Else
                            Call PlayerMsg(Index, "This spell can only be learned by a " & GetClassName(Spell(N).ClassReq - 1) & ".", White)
                        End If
                    Else
                        Call PlayerMsg(Index, "This scroll is not connected to a spell, please inform an administrator!", White)
                    End If

            End Select
        End If
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::
    ' :: Player attack packet ::
    ' ::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "attack" Then
        ' Try to attack a player
        For I = 1 To HighIndex
            ' Make sure we dont try to attack ourselves
            If I <> Index Then
                ' Can we attack the player?
                If CanAttackPlayer(Index, I) Then
                    If Not CanPlayerBlockHit(I) Then
                        ' Get the damage we can do
                        If Not CanPlayerCriticalHit(Index) Then
                            Damage = GetPlayerDamage(Index) - GetPlayerProtection(I)
                        Else
                            N = GetPlayerDamage(Index)
                            Damage = N + Int(Rnd * Int(N / 2)) + 1 - GetPlayerProtection(I)
                            Call PlayerMsg(Index, "You feel a surge of energy upon swinging!", BrightCyan)
                            Call PlayerMsg(I, GetPlayerName(Index) & " swings with enormous might!", BrightCyan)
                        End If

                        If Damage > 0 Then
                            Call AttackPlayer(Index, I, Damage)
                        Else
                            Call PlayerMsg(Index, "Your attack does nothing.", BrightRed)
                        End If
                    Else
                        Call PlayerMsg(Index, GetPlayerName(I) & "'s " & Trim$(Item(GetPlayerInvItemNum(I, GetPlayerShieldSlot(I))).name) & " has blocked your hit!", BrightCyan)
                        Call PlayerMsg(I, "Your " & Trim$(Item(GetPlayerInvItemNum(I, GetPlayerShieldSlot(I))).name) & " has blocked " & GetPlayerName(Index) & "'s hit!", BrightCyan)
                    End If

                    Exit Sub
                End If
            End If
        Next I

        ' Try to attack a npc
        For I = 1 To MAX_MAP_NPCS
            ' Can we attack the npc?
            If CanAttackNpc(Index, I) Then
                ' Get the damage we can do
                If Not CanPlayerCriticalHit(Index) Then
                    Damage = GetPlayerDamage(Index) - Int(Npc(MapNpc(GetPlayerMap(Index), I).Num).DEF / 2)
                Else
                    N = GetPlayerDamage(Index)
                    Damage = N + Int(Rnd * Int(N / 2)) + 1 - Int(Npc(MapNpc(GetPlayerMap(Index), I).Num).DEF / 2)
                    Call PlayerMsg(Index, "You feel a surge of energy upon swinging!", BrightCyan)
                End If

                If Damage > 0 Then
                    Call AttackNpc(Index, I, Damage)
                    Call SendDataTo(Index, "BLITPLAYERDMG" & SEP_CHAR & Damage & SEP_CHAR & I & END_CHAR)
                Else
                    Call PlayerMsg(Index, "Your attack does nothing.", BrightRed)
                    Call SendDataTo(Index, "BLITPLAYERDMG" & SEP_CHAR & Damage & SEP_CHAR & I & END_CHAR)
                End If
                Exit Sub
            End If
        Next I

        Exit Sub
    End If

    ' ::::::::::::::::::::::
    ' :: Use stats packet ::
    ' ::::::::::::::::::::::
    If LCase$(Parse(0)) = "usestatpoint" Then
        PointType = Val(Parse(1))

        ' Prevent hacking
        If (PointType < 0) Or (PointType > 3) Then
            Call HackingAttempt(Index, "Invalid Point Type")
            Exit Sub
        End If

        ' Make sure they have points
        If GetPlayerPOINTS(Index) > 0 Then
            ' Take away a stat point
            Call SetPlayerPOINTS(Index, GetPlayerPOINTS(Index) - 1)

            ' Everything is ok
            Select Case PointType
                Case 0
                    Call SetPlayerSTR(Index, GetPlayerSTR(Index) + 1)
                    Call PlayerMsg(Index, "You have gained more strength!", White)
                Case 1
                    Call SetPlayerDEF(Index, GetPlayerDEF(Index) + 1)
                    Call PlayerMsg(Index, "You have gained more defense!", White)
                Case 2
                    Call SetPlayerMAGI(Index, GetPlayerMAGI(Index) + 1)
                    Call PlayerMsg(Index, "You have gained more magic abilities!", White)
                Case 3
                    Call SetPlayerSPEED(Index, GetPlayerSPEED(Index) + 1)
                    Call PlayerMsg(Index, "You have gained more speed!", White)
            End Select
        Else
            Call PlayerMsg(Index, "You have no skill points to train with!", BrightRed)
        End If

        ' Send the update
        Call SendStats(Index)
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::::::::
    ' :: Player info request packet ::
    ' ::::::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "playerinforequest" Then
        name = Parse(1)

        I = FindPlayer(name)
        If I > 0 Then
            Call PlayerMsg(Index, "Account: " & Trim$(Player(I).Login) & ", Name: " & GetPlayerName(I), BrightGreen)
            If GetPlayerAccess(Index) > ADMIN_MONITER Then
                Call PlayerMsg(Index, "-=- Stats for " & GetPlayerName(I) & " -=-", BrightGreen)
                Call PlayerMsg(Index, "Level: " & GetPlayerLevel(I) & "  Exp: " & GetPlayerExp(I) & "/" & GetPlayerNextLevel(I), BrightGreen)
                Call PlayerMsg(Index, "HP: " & GetPlayerHP(I) & "/" & GetPlayerMaxHP(I) & "  MP: " & GetPlayerMP(I) & "/" & GetPlayerMaxMP(I) & "  SP: " & GetPlayerSP(I) & "/" & GetPlayerMaxSP(I), BrightGreen)
                Call PlayerMsg(Index, "STR: " & GetPlayerSTR(I) & "  DEF: " & GetPlayerDEF(I) & "  MAGI: " & GetPlayerMAGI(I) & "  SPEED: " & GetPlayerSPEED(I), BrightGreen)
                N = Int(GetPlayerSTR(I) / 2) + Int(GetPlayerLevel(I) / 2)
                I = Int(GetPlayerDEF(I) / 2) + Int(GetPlayerLevel(I) / 2)
                If N > 100 Then N = 100
                If I > 100 Then I = 100
                Call PlayerMsg(Index, "Critical Hit Chance: " & N & "%, Block Chance: " & I & "%", BrightGreen)
            End If
        Else
            Call PlayerMsg(Index, "Player is not online.", White)
        End If
        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Warp me to packet ::
    ' :::::::::::::::::::::::
    If LCase$(Parse(0)) = "warpmeto" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The player
        N = FindPlayer(Parse(1))

        If N <> Index Then
            If N > 0 Then
                Call PlayerWarp(Index, GetPlayerMap(N), GetPlayerX(N), GetPlayerY(N))
                Call PlayerMsg(N, GetPlayerName(Index) & " has warped to you.", BrightBlue)
                Call PlayerMsg(Index, "You have been warped to " & GetPlayerName(N) & ".", BrightBlue)
                Call AddLog(GetPlayerName(Index) & " has warped to " & GetPlayerName(N) & ", map #" & GetPlayerMap(N) & ".", ADMIN_LOG)
            Else
                Call PlayerMsg(Index, "Player is not online.", White)
            End If
        Else
            Call PlayerMsg(Index, "You cannot warp to yourself!", White)
        End If

        Exit Sub
    End If

    ' ::::::::::::::::::::::::::::::
    ' :: Request edit sign packet ::
    ' ::::::::::::::::::::::::::::::
    Dim Sn As Long
    Dim SnPacket As String
    If LCase(Parse(0)) = "requesteditsign" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        SnPacket = "signnames"
        For Sn = 1 To MAX_SIGNS
            SnPacket = SnPacket & SEP_CHAR & Trim(Sign(Sn).name)
        Next Sn
        SnPacket = SnPacket & END_CHAR
        Call SendDataTo(Index, SnPacket)

        Call SendDataTo(Index, "SIGNEDITOR" & END_CHAR)


        Exit Sub
    End If

    ' ::::::::::::::::::::::
    ' :: Edit sign packet ::
    ' ::::::::::::::::::::::
    If LCase(Parse(0)) = "editsign" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The sign #
        N = Val(Parse(1))

        ' Prevent hacking
        If N < 0 Or N > MAX_SIGNS Then
            Call HackingAttempt(Index, "Invalid Sign Index")
            Exit Sub
        End If

        Call AddLog(GetPlayerName(Index) & " editing sign #" & N & ".", ADMIN_LOG)
        Call SendEditSignTo(Index, N)
    End If

    ' ::::::::::::::::::::::
    ' :: Save sign packet ::
    ' ::::::::::::::::::::::
    If (LCase(Parse(0)) = "savesign") Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' Sign #
        N = Val(Parse(1))

        ' Prevent hacking
        If N < 0 Or N > MAX_SIGNS Then
            Call HackingAttempt(Index, "Invalid Sign Index")
            Exit Sub
        End If

        ' Update the sign
        Sign(N).name = Trim$(Parse(2))
        Sign(N).Background = Trim$(Parse(3))
        Sign(N).Line1 = Trim$(Parse(4))
        Sign(N).Line2 = Trim$(Parse(5))
        Sign(N).Line3 = Trim$(Parse(6))

        ' Save it
        Call SendUpdateSignToAll(N)
        Call SaveSign(N)
        Call AddLog(GetPlayerName(Index) & " saving sign #" & N & ".", ADMIN_LOG)
        Exit Sub
    End If

    ' ::::::::::::::::::
    ' :: Request Sign ::
    ' ::::::::::::::::::
    If (LCase(Parse(0)) = "requestsign") Then

        ' Sign #
        N = Val(Parse(1))

        ' Prevent hacking
        If N < 0 Or N > MAX_SIGNS Then
            Call HackingAttempt(Index, "Invalid Sign Index")
            Exit Sub
        End If

        ' Send sign info
        Call SendSignTo(Index, N)
    End If

    ' :::::::::::::::::::::::
    ' :: Warp to me packet ::
    ' :::::::::::::::::::::::
    If LCase$(Parse(0)) = "warptome" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The player
        N = FindPlayer(Parse(1))

        If N <> Index Then
            If N > 0 Then
                Call PlayerWarp(N, GetPlayerMap(Index), GetPlayerX(Index), GetPlayerY(Index))
                Call PlayerMsg(N, "You have been summoned by " & GetPlayerName(Index) & ".", BrightBlue)
                Call PlayerMsg(Index, GetPlayerName(N) & " has been summoned.", BrightBlue)
                Call AddLog(GetPlayerName(Index) & " has warped " & GetPlayerName(N) & " to self, map #" & GetPlayerMap(Index) & ".", ADMIN_LOG)
            Else
                Call PlayerMsg(Index, "Player is not online.", White)
            End If
        Else
            Call PlayerMsg(Index, "You cannot warp yourself to yourself!", White)
        End If

        Exit Sub
    End If


    ' ::::::::::::::::::::::::
    ' :: Warp to map packet ::
    ' ::::::::::::::::::::::::
    If LCase$(Parse(0)) = "warpto" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The map
        N = Val(Parse(1))

        ' Prevent hacking
        If N < 0 Or N > MAX_MAPS_SET Then
            Call HackingAttempt(Index, "Invalid map")
            Exit Sub
        End If

        Call PlayerWarp(Index, N, GetPlayerX(Index), GetPlayerY(Index))
        Call PlayerMsg(Index, "You have been warped to map #" & N, BrightBlue)
        Call AddLog(GetPlayerName(Index) & " warped to map #" & N & ".", ADMIN_LOG)
        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Set sprite packet ::
    ' :::::::::::::::::::::::
    If LCase$(Parse(0)) = "setsprite" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The sprite
        N = Val(Parse(1))

        Call SetPlayerSprite(Index, N)
        Call SendPlayerData(Index)
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::::::
    ' :: Set Player Sprite Packet ::
    ' ::::::::::::::::::::::::::::::
    If LCase(Parse(0)) = "playersprite" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The player
        N = FindPlayer(Parse(2))
        ' The Sprite
        I = Val(Parse(1))
        If Not Trim$(GetPlayerName(N)) = "Magnus" Then
            If N > 0 Then
                Call PlayerMsg(N, "Your Sprite has been changed to " & I & " by " & GetPlayerName(Index) & ".", BrightGreen)
                Call PlayerMsg(Index, "You changed " & GetPlayerName(N) & "'s sprite to " & I & ".", BrightGreen)
                Call AddLog(GetPlayerName(Index) & " has changed " & GetPlayerName(N) & "'s Sprite to " & I & ".", ADMIN_LOG)
                Call SetPlayerSprite(N, I)
                Call SendPlayerData(N)
            Else
                Call PlayerMsg(Index, "Player is not online.", BrightRed)
            End If
        Else
            Call PlayerMsg(Index, "You cannot change Magnus' sprite!", BrightRed)
        End If
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::
    ' :: Stats request packet ::
    ' ::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "getstats" Then
        Call PlayerMsg(Index, "-=- Stats for " & GetPlayerName(Index) & " -=-", White)
        Call PlayerMsg(Index, "Level: " & GetPlayerLevel(Index) & "  Exp: " & GetPlayerExp(Index) & "/" & GetPlayerNextLevel(Index), White)
        Call PlayerMsg(Index, "HP: " & GetPlayerHP(Index) & "/" & GetPlayerMaxHP(Index) & "  MP: " & GetPlayerMP(Index) & "/" & GetPlayerMaxMP(Index) & "  SP: " & GetPlayerSP(Index) & "/" & GetPlayerMaxSP(Index), White)
        Call PlayerMsg(Index, "STR: " & GetPlayerSTR(Index) & "  DEF: " & GetPlayerDEF(Index) & "  MAGI: " & GetPlayerMAGI(Index) & "  SPEED: " & GetPlayerSPEED(Index), White)
        N = Int(GetPlayerSTR(Index) / 2) + Int(GetPlayerLevel(Index) / 2)
        I = Int(GetPlayerDEF(Index) / 2) + Int(GetPlayerLevel(Index) / 2)
        If N > 100 Then N = 100
        If I > 100 Then I = 100
        Call PlayerMsg(Index, "Critical Hit Chance: " & N & "%, Block Chance: " & I & "%", White)
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::
    ' ::  Live Stats  packet  ::
    ' ::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "getlivestats" Then
' Dim Packet As String
' N = Critical Hit, I = Block

        N = Int(GetPlayerSTR(Index) / 2) + Int(GetPlayerLevel(Index) / 2)
        I = Int(GetPlayerDEF(Index) / 2) + Int(GetPlayerLevel(Index) / 2)
        If N > 100 Then N = 100
        If I > 100 Then I = 100

        Packet = "LIVESTATS" & SEP_CHAR & GetPlayerLevel(Index) & SEP_CHAR & GetPlayerExp(Index) & SEP_CHAR & GetPlayerNextLevel(Index) & SEP_CHAR & N & SEP_CHAR & I & SEP_CHAR & GetPlayerPOINTS(Index) & END_CHAR

        Call SendDataTo(Index, Packet)
        Exit Sub
    End If


    ' ::::::::::::::::::::::::::::::::::
    ' :: Player request for a new map ::
    ' ::::::::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "requestnewmap" Then
        Dir = Val(Parse(1))

        ' Prevent hacking
        If Dir < DIR_UP Or Dir > DIR_RIGHT Then
            Call HackingAttempt(Index, "Invalid Direction")
            Exit Sub
        End If

        Call PlayerMove(Index, Dir, 1)
        Exit Sub
    End If

    ' :::::::::::::::::::::
    ' :: Map data packet ::
    ' :::::::::::::::::::::
    If LCase$(Parse(0)) = "mapdata" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        N = 1

        MapNum = GetPlayerMap(Index)
        Map(MapNum).name = Parse(N + 1)
        Map(MapNum).Revision = Map(MapNum).Revision + 1
        Map(MapNum).Moral = Val(Parse(N + 3))
        Map(MapNum).Up = Val(Parse(N + 4))
        Map(MapNum).Down = Val(Parse(N + 5))
        Map(MapNum).Left = Val(Parse(N + 6))
        Map(MapNum).Right = Val(Parse(N + 7))
        Map(MapNum).Music = Val(Parse(N + 8))
        Map(MapNum).BootMap = Val(Parse(N + 9))
        Map(MapNum).BootX = Val(Parse(N + 10))
        Map(MapNum).BootY = Val(Parse(N + 11))
        Map(MapNum).Shop = Val(Parse(N + 12))
        Map(MapNum).Indoors = Val(Parse(N + 13))

        N = N + 14

        For y = 0 To MAX_MAPY
            For X = 0 To MAX_MAPX
                Map(MapNum).Tile(X, y).Ground = Val(Parse(N))
                Map(MapNum).Tile(X, y).Mask = Val(Parse(N + 1))
                Map(MapNum).Tile(X, y).Anim = Val(Parse(N + 2))
                Map(MapNum).Tile(X, y).Mask2 = Val(Parse(N + 3))
                Map(MapNum).Tile(X, y).M2Anim = Val(Parse(N + 4))
                Map(MapNum).Tile(X, y).Fringe = Val(Parse(N + 5))
                Map(MapNum).Tile(X, y).FAnim = Val(Parse(N + 6))
                Map(MapNum).Tile(X, y).Fringe2 = Val(Parse(N + 7))
                Map(MapNum).Tile(X, y).F2Anim = Val(Parse(N + 8))
                Map(MapNum).Tile(X, y).Type = Val(Parse(N + 9))
                Map(MapNum).Tile(X, y).Data1 = Val(Parse(N + 10))
                Map(MapNum).Tile(X, y).Data2 = Val(Parse(N + 11))
                Map(MapNum).Tile(X, y).Data3 = Val(Parse(N + 12))

                N = N + 13
            Next X
        Next y

        For X = 1 To MAX_MAP_NPCS
            Map(MapNum).Npc(X) = Val(Parse(N))
            N = N + 1
            Call ClearMapNpc(X, MapNum)
        Next X
        Call SendMapNpcsToMap(MapNum)
        Call SpawnMapNpcs(MapNum)

        ' Save the map
        Call SaveMap(MapNum)

        ' Refresh map for everyone online
        For I = 1 To HighIndex
            If IsPlaying(I) And GetPlayerMap(I) = MapNum Then
                Call PlayerWarp(I, MapNum, GetPlayerX(I), GetPlayerY(I))
            End If
        Next I

        Exit Sub
    End If

    ' ::::::::::::::::::::::::::::
    ' :: Need map yes/no packet ::
    ' ::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "needmap" Then
        ' Get yes/no value
        s = LCase$(Parse(1))

        If s = "yes" Then
            Call SendMap(Index, GetPlayerMap(Index))
            Call SendMapItemsTo(Index, GetPlayerMap(Index))
            Call SendMapNpcsTo(Index, GetPlayerMap(Index))
            Call SendJoinMap(Index)
            Player(Index).GettingMap = NO
            Call SendDataTo(Index, "MAPDONE" & END_CHAR)
        Else
            Call SendMapItemsTo(Index, GetPlayerMap(Index))
            Call SendMapNpcsTo(Index, GetPlayerMap(Index))
            Call SendJoinMap(Index)
            Player(Index).GettingMap = NO
            Call SendDataTo(Index, "MAPDONE" & END_CHAR)
        End If

        Exit Sub
    End If

    ' :::::::::::::::::::::::::::::::::::::::::::::::
    ' :: Player trying to pick up something packet ::
    ' :::::::::::::::::::::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "mapgetitem" Then
        Call PlayerMapGetItem(Index)
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::::::::::::::::::::
    ' :: Player trying to drop something packet ::
    ' ::::::::::::::::::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "mapdropitem" Then
        InvNum = Val(Parse(1))
        Ammount = Val(Parse(2))

        ' Prevent hacking
        If InvNum < 1 Or InvNum > MAX_INV Then
            Call HackingAttempt(Index, "Invalid InvNum")
            Exit Sub
        End If

        ' Prevent hacking
        If Ammount > GetPlayerInvItemValue(Index, InvNum) Then
            Call HackingAttempt(Index, "Item ammount modification")
            Exit Sub
        End If

        ' Prevent hacking
        If Item(GetPlayerInvItemNum(Index, InvNum)).Type = ITEM_TYPE_CURRENCY Then
            ' Check if money and if it is we want to make sure that they aren't trying to drop 0 value
            If Ammount <= 0 Then
                Call HackingAttempt(Index, "Trying to drop 0 ammount of currency")
                Exit Sub
            End If
        End If

        Call PlayerMapDropItem(Index, InvNum, Ammount)
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::::
    ' :: Server Shutdown Packet ::
    ' ::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "shutdown" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_CREATOR Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If
        ShutOn = True
        frmServer.tmrShutdown.Enabled = True
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::
    ' :: Reboot Server Packet ::
    ' ::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "rebootserver" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_CREATOR Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If
        Call ServerReboot
        Exit Sub
    End If




    ' ::::::::::::::::::::::::::
    ' :: Sleep Request packet ::
    ' ::::::::::::::::::::::::::
    Dim GoldItem As Long
    If LCase$(Parse(0)) = "innsleep" Then

        For I = 1 To MAX_INV
            Select Case Trim$(GetPlayerInvItemName(Index, I))
                Case "Gold"
                    If Map(GetPlayerMap(Index)).Moral = MAP_MORAL_INN Then
                        If GetPlayerInvItemValue(Index, I) >= Val(GetPlayerLevel(Index) * 10) Then
                            Call TakeItem(Index, I, Val(GetPlayerLevel(Index) * 10))
                            Call SetPlayerHP(Index, GetPlayerMaxHP(Index))
                            Call SetPlayerMP(Index, GetPlayerMaxMP(Index))
                            Call SetPlayerSP(Index, GetPlayerMaxSP(Index))
                            Call SendHP(Index)
                            Call SendMP(Index)
                            Call SendSP(Index)
                            Call PlayerMsg(Index, "You sleep and wake up feeling refreshed!", BrightGreen)
                            Exit Sub
                        ElseIf GetPlayerInvItemValue(Index, I) < Val(GetPlayerLevel(Index) * 10) Then
                            Call PlayerMsg(Index, "You do not have enough money to sleep here!", BrightRed)
                            Exit Sub
                        End If
                    Else
                        Call PlayerMsg(Index, "There is no Inn here. You cannot sleep!", BrightRed)
                        Exit Sub
                    End If
                Case Else
                    Call PlayerMsg(Index, "You do not have any gold with which to pay!", BrightRed)
                    Exit Sub
            End Select
        Next I

        Exit Sub
    End If

    ' ::::::::::::::::::::::::
    ' :: Respawn map packet ::
    ' ::::::::::::::::::::::::
    If LCase$(Parse(0)) = "maprespawn" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' Clear out it all
        For I = 1 To MAX_MAP_ITEMS
            Call SpawnItemSlot(I, 0, 0, 0, GetPlayerMap(Index), MapItem(GetPlayerMap(Index), I).X, MapItem(GetPlayerMap(Index), I).y)
            Call ClearMapItem(I, GetPlayerMap(Index))
        Next I

        ' Respawn
        Call SpawnMapItems(GetPlayerMap(Index))

        ' Respawn NPCS
        For I = 1 To MAX_MAP_NPCS
            Call SpawnNpc(I, GetPlayerMap(Index))
        Next I

        Call PlayerMsg(Index, "Map respawned.", Blue)
        Call AddLog(GetPlayerName(Index) & " has respawned map #" & GetPlayerMap(Index), ADMIN_LOG)
        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Map Report Packet ::
    ' :::::::::::::::::::::::
    If LCase(Parse(0)) = "mapreport" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' Clear the current list.
        Call SendDataTo(Index, "MAPREPORTCLEAR" & END_CHAR)

        ' Add all the maps to the list.
        Packet = "MAPREPORTADD" & SEP_CHAR
        For N = 1 To MAX_MAPS_SET
            Packet = Packet & Trim$(Map(N).name) & SEP_CHAR
        Next N
        Call SendDataTo(Index, Packet & END_CHAR)

        ' Enable the list.
        Call SendDataTo(Index, "MAPREPORTEND" & END_CHAR)

        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Sign Names Packet ::
    ' :::::::::::::::::::::::
    If LCase(Parse(0)) = "signnames" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        Packet = "SIGNNAMES" & SEP_CHAR
        For N = 1 To MAX_SIGNS
            Packet = Packet & Trim$(Sign(N).name) & SEP_CHAR
        Next N
        Call SendDataTo(Index, Packet & END_CHAR)
    End If

    ' ::::::::::::::::::::::::
    ' :: Kick player packet ::
    ' ::::::::::::::::::::::::
    If LCase$(Parse(0)) = "kickplayer" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) <= 0 Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The player index
        N = FindPlayer(Parse(1))

        If N <> Index Then
            If N > 0 Then
                If GetPlayerAccess(N) <= GetPlayerAccess(Index) Then
                    Call GlobalMsg(GetPlayerName(N) & " has been kicked from " & GAME_NAME & " by " & GetPlayerName(Index) & "!", White)
                    Call AddLog(GetPlayerName(Index) & " has kicked " & GetPlayerName(N) & ".", ADMIN_LOG)
                    Call AlertMsg(N, "You have been kicked by " & GetPlayerName(Index) & "!")
                Else
                    Call PlayerMsg(Index, "That is a higher access admin then you!", White)
                End If
            Else
                Call PlayerMsg(Index, "Player is not online.", White)
            End If
        Else
            Call PlayerMsg(Index, "You cannot kick yourself!", White)
        End If

        Exit Sub
    End If

    ' :::::::::::::::::::::
    ' :: Ban list packet ::
    ' :::::::::::::::::::::
    If LCase$(Parse(0)) = "banlist" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        N = 1

' Var Password = HD

        For I = 0 To MAX_BANS
            BIp = Ban(I).BannedIP
            If BIp = vbNullString Then
                Call PlayerMsg(Index, "There are currently no banned users!", White)
            Else
                name = Ban(I).BannedBy
                s = Ban(I).BannedChar
                Password = Ban(I).BannedHD
                Call PlayerMsg(Index, N & ": " & s & " ( Banned IP " & BIp & "[" & Password & "] by " & name & " )", White)
                N = N + 1
            End If
        Next I

        Exit Sub
    End If

    ' ::::::::::::::::::::::::
    ' :: Ban destroy packet ::
    ' ::::::::::::::::::::::::
    If LCase$(Parse(0)) = "bandestroy" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_CREATOR Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        For N = 0 To MAX_BANS
            Ban(N).BannedIP = vbNullString
            Ban(N).BannedChar = vbNullString
            Ban(N).BannedBy = vbNullString
            Ban(N).BannedHD = vbNullString
            Call SaveBan(N)
        Next N

        Call PlayerMsg(Index, "Ban list destroyed.", White)
        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Ban player packet ::
    ' :::::::::::::::::::::::
    If LCase$(Parse(0)) = "banplayer" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The player index
        N = FindPlayer(Parse(1))

        If N <> Index Then
            If N > 0 Then
                If GetPlayerAccess(N) <= GetPlayerAccess(Index) Then
                    Call BanIndex(N, Trim$(GetPlayerName(Index)))
                    Call GlobalMsg(GetPlayerName(N) & " has been banned from " & GAME_NAME & " by " & GetPlayerName(Index) & "!", White)
                    Call AddLog(GetPlayerName(N) & " has banned " & GetPlayerName(Index) & ".", ADMIN_LOG)
                    Call AlertMsg(N, "You have been banned by " & GetPlayerName(Index) & "!")
                Else
                    Call PlayerMsg(Index, "That is a higher access admin then you!", White)
                End If
            Else
                Call PlayerMsg(Index, "Player is not online.", White)
            End If
        Else
            Call PlayerMsg(Index, "You cannot ban yourself!", White)
        End If

        Exit Sub
    End If

    ' :::::::::::::::::::::::::
    ' :: UnBan player packet ::
    ' :::::::::::::::::::::::::
    If LCase$(Parse(0)) = "unbanplayer" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The player index
        name = Trim$(Parse(1))

        Call UnBanIndex(name, Index)

        Exit Sub
    End If

    ' ::::::::::::::::::::::
    ' :: HD Serial packet ::
    ' ::::::::::::::::::::::
    If LCase$(Parse(0)) = "hdserial" Then
        Player(Index).HDSerial = Parse(1)
        Exit Sub
    End If

    ' ::::::::::::::::::::::
    ' :: Game Name packet ::
    ' ::::::::::::::::::::::
    If LCase$(Parse(0)) = "getgamename" Then
        Call SendName(Index)
        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Game Maxes packet ::
    ' :::::::::::::::::::::::
    If LCase$(Parse(0)) = "getgamemaxes" Then
        Call SendMaxes(Index)
        Exit Sub
    End If

    ' ::::::::::::::::::::::
    ' :: Game Site packet ::
    ' ::::::::::::::::::::::
    If LCase$(Parse(0)) = "getgamesite" Then
        Call SendSite(Index)
        Exit Sub
    End If

    ' :::::::::::::::::::::::::::::
    ' :: Request edit map packet ::
    ' :::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "requesteditmap" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        Call SendDataTo(Index, "EDITMAP" & END_CHAR)
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::::::
    ' :: Request edit item packet ::
    ' ::::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "requestedititem" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        Call SendDataTo(Index, "ITEMEDITOR" & END_CHAR)
        Exit Sub
    End If

    ' ::::::::::::::::::::::
    ' :: Edit item packet ::
    ' ::::::::::::::::::::::
    If LCase$(Parse(0)) = "edititem" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The item #
        N = Val(Parse(1))

        ' Prevent hacking
        If N < 0 Or N > MAX_ITEMS Then
            Call HackingAttempt(Index, "Invalid Item Index")
            Exit Sub
        End If

        Call AddLog(GetPlayerName(Index) & " editing item #" & N & ".", ADMIN_LOG)
        Call SendEditItemTo(Index, N)
    End If

    ' ::::::::::::::::::::::
    ' :: Save item packet ::
    ' ::::::::::::::::::::::
    If LCase$(Parse(0)) = "saveitem" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        N = Val(Parse(1))
        If N < 0 Or N > MAX_ITEMS Then
            Call HackingAttempt(Index, "Invalid Item Index")
            Exit Sub
        End If

        ' Update the item
        Item(N).name = Parse(2)
        Item(N).Pic = Val(Parse(3))
        Item(N).Type = Val(Parse(4))
        Item(N).Data1 = Val(Parse(5))
        Item(N).Data2 = Val(Parse(6))
        Item(N).Data3 = Val(Parse(7))

        ' Save it
        Call SendUpdateItemToAll(N)
        Call SaveItem(N)
        Call AddLog(GetPlayerName(Index) & " saved item #" & N & ".", ADMIN_LOG)
        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Save Guild packet ::
    ' :::::::::::::::::::::::
    If LCase$(Parse(0)) = "saveguild" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        N = Val(Parse(1))
        If N < 0 Or N > MAX_GUILDS Then
            Call HackingAttempt(Index, "Invalid Guild Index")
            Exit Sub
        End If

        ' Make sure the founder is online!
        If FindPlayer(Parse(4)) = 0 Then
            Call PlayerMsg(Index, "Founder must be online!", BrightRed)
            Exit Sub
        End If

        ' Update the Guild
        Guild(N).name = Trim$(Parse(2))
        Guild(N).Abbreviation = Trim$(Parse(3))
        Guild(N).Founder = Trim$(Parse(4))

        ' Save it
        Call SetPlayerGuild(FindPlayer(Parse(4)), N)
        Call SavePlayer(FindPlayer(Parse(4)))
        Call SendDataToAll("playeringuild" & SEP_CHAR & FindPlayer(Parse(4)) & SEP_CHAR & N & END_CHAR)
        Call SendUpdateGuildToAll(N)
        Call SaveGuild(N)

' Call SendPlayerData(FindPlayer(Parse(4)))

        Call AddLog(GetPlayerName(Index) & " saved guild #" & N & ".", ADMIN_LOG)
    End If

    ' :::::::::::::::::::::::::::::
    ' :: Request edit npc packet ::
    ' :::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "requesteditnpc" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        Call SendDataTo(Index, "NPCEDITOR" & END_CHAR)
        Exit Sub
    End If

    ' :::::::::::::::::::::
    ' :: Edit npc packet ::
    ' :::::::::::::::::::::
    If LCase$(Parse(0)) = "editnpc" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The npc #
        N = Val(Parse(1))

        ' Prevent hacking
        If N < 0 Or N > MAX_NPCS Then
            Call HackingAttempt(Index, "Invalid NPC Index")
            Exit Sub
        End If

        Call AddLog(GetPlayerName(Index) & " editing npc #" & N & ".", ADMIN_LOG)
        Call SendEditNpcTo(Index, N)
    End If

    ' :::::::::::::::::::::
    ' :: Save npc packet ::
    ' :::::::::::::::::::::
    If LCase$(Parse(0)) = "savenpc" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        N = Val(Parse(1))

        ' Prevent hacking
        If N < 0 Or N > MAX_NPCS Then
            Call HackingAttempt(Index, "Invalid NPC Index")
            Exit Sub
        End If

        ' Update the npc
        Npc(N).name = Parse(2)
        Npc(N).AttackSay = Parse(3)
        Npc(N).Sprite = Val(Parse(4))
        Npc(N).SpawnSecs = Val(Parse(5))
        Npc(N).Behavior = Val(Parse(6))
        Npc(N).Range = Val(Parse(7))
        Npc(N).DropChance = Val(Parse(8))
        Npc(N).DropItem = Val(Parse(9))
        Npc(N).DropItemValue = Val(Parse(10))
        Npc(N).STR = Val(Parse(11))
        Npc(N).DEF = Val(Parse(12))
        Npc(N).SPEED = Val(Parse(13))
        Npc(N).MAGI = Val(Parse(14))
        Npc(N).MaxHP = Val(Parse(15))
        Npc(N).GiveEXP = Val(Parse(16))
        Npc(N).ShopCall = Val(Parse(17))
        ' Save it
        Call SendUpdateNpcToAll(N)
        Call SaveNpc(N)
        Call AddLog(GetPlayerName(Index) & " saved npc #" & N & ".", ADMIN_LOG)
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::::::
    ' :: Request edit shop packet ::
    ' ::::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "requesteditshop" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        Call SendDataTo(Index, "SHOPEDITOR" & END_CHAR)
        Exit Sub
    End If

    ' ::::::::::::::::::::::
    ' :: Edit shop packet ::
    ' ::::::::::::::::::::::
    If LCase$(Parse(0)) = "editshop" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The shop #
        N = Val(Parse(1))

        ' Prevent hacking
        If N < 0 Or N > MAX_SHOPS Then
            Call HackingAttempt(Index, "Invalid Shop Index")
            Exit Sub
        End If

        Call AddLog(GetPlayerName(Index) & " editing shop #" & N & ".", ADMIN_LOG)
        Call SendEditShopTo(Index, N)
    End If

    ' ::::::::::::::::::::::
    ' :: Save shop packet ::
    ' ::::::::::::::::::::::
    If (LCase$(Parse(0)) = "saveshop") Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ShopNum = Val(Parse(1))

        ' Prevent hacking
        If ShopNum < 0 Or ShopNum > MAX_SHOPS Then
            Call HackingAttempt(Index, "Invalid Shop Index")
            Exit Sub
        End If

        ' Update the shop
        Shop(ShopNum).name = Parse(2)
        Shop(ShopNum).JoinSay = Parse(3)
        Shop(ShopNum).LeaveSay = Parse(4)
        Shop(ShopNum).FixesItems = Val(Parse(5))

        N = 6
        For I = 1 To MAX_TRADES
            Shop(ShopNum).TradeItem(I).GiveItem = Val(Parse(N))
            Shop(ShopNum).TradeItem(I).GiveValue = Val(Parse(N + 1))
            Shop(ShopNum).TradeItem(I).GetItem = Val(Parse(N + 2))
            Shop(ShopNum).TradeItem(I).GetValue = Val(Parse(N + 3))
            Shop(ShopNum).TradeItem(I).GiveItem2 = Val(Parse(N + 4))
            Shop(ShopNum).TradeItem(I).GiveValue2 = Val(Parse(N + 5))
            N = N + 6
        Next I

        ' Save it
        Call SendUpdateShopToAll(ShopNum)
        Call SaveShop(ShopNum)
        Call AddLog(GetPlayerName(Index) & " saving shop #" & ShopNum & ".", ADMIN_LOG)
        Exit Sub
    End If

    ' :::::::::::::::::::::::::::::::
    ' :: Request edit spell packet ::
    ' :::::::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "requesteditspell" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        Call SendDataTo(Index, "SPELLEDITOR" & END_CHAR)
        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Edit spell packet ::
    ' :::::::::::::::::::::::
    If LCase$(Parse(0)) = "editspell" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' The spell #
        N = Val(Parse(1))

        ' Prevent hacking
        If N < 0 Or N > MAX_SPELLS Then
            Call HackingAttempt(Index, "Invalid Spell Index")
            Exit Sub
        End If

        Call AddLog(GetPlayerName(Index) & " editing spell #" & N & ".", ADMIN_LOG)
        Call SendEditSpellTo(Index, N)
    End If

    ' :::::::::::::::::::::::
    ' :: Save spell packet ::
    ' :::::::::::::::::::::::
    If (LCase$(Parse(0)) = "savespell") Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        ' Spell #
        N = Val(Parse(1))

        ' Prevent hacking
        If N < 0 Or N > MAX_SPELLS Then
            Call HackingAttempt(Index, "Invalid Spell Index")
            Exit Sub
        End If

        ' Update the spell
        Spell(N).name = Parse(2)
        Spell(N).ClassReq = Val(Parse(3))
        Spell(N).LevelReq = Val(Parse(4))
        Spell(N).Type = Val(Parse(5))
        Spell(N).Data1 = Val(Parse(6))
        Spell(N).Data2 = Val(Parse(7))
        Spell(N).Data3 = Val(Parse(8))
        Spell(N).MPReq = Val(Parse(9))
        Spell(N).Graphic = Val(Parse(10))

        ' Save it
        Call SendUpdateSpellToAll(N)
        Call SaveSpell(N)
        Call AddLog(GetPlayerName(Index) & " saving spell #" & N & ".", ADMIN_LOG)
        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Set access packet ::
    ' :::::::::::::::::::::::
    If LCase$(Parse(0)) = "setaccess" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_CREATOR Then
            Call HackingAttempt(Index, "Trying to use powers not available")
            Exit Sub
        End If

        ' The index
        N = FindPlayer(Parse(1))
        ' The access
        I = Val(Parse(2))


        ' Check for invalid access level
        If I >= 0 Or I <= 3 Then
            ' Check if player is on
            If N > 0 Then
                If GetPlayerAccess(N) <= 0 Then
                    Call GlobalMsg(GetPlayerName(N) & " has been blessed with administrative access.", BrightBlue)
                End If

                Call SetPlayerAccess(N, I)
                Call SendPlayerData(N)
                Call AddLog(GetPlayerName(Index) & " has modified " & GetPlayerName(N) & "'s access.", ADMIN_LOG)
            Else
                Call PlayerMsg(Index, "Player is not online.", White)
            End If
        Else
            Call PlayerMsg(Index, "Invalid access level.", Red)
        End If

        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Who online packet ::
    ' :::::::::::::::::::::::
    If LCase$(Parse(0)) = "whosonline" Then
        Call SendWhosOnline(Index)
        Exit Sub
    End If

    ' ::::::::::::::::::::::::
    ' :: Online list packet ::
    ' ::::::::::::::::::::::::
    If LCase$(Parse(0)) = "onlinelist" Then
        Call SendOnlineList(Index)
        Exit Sub
    End If

    ' :::::::::::::::::::::
    ' :: Set MOTD packet ::
    ' :::::::::::::::::::::
    If LCase$(Parse(0)) = "setmotd" Then
        ' Prevent hacking
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        Call PutVar(App.Path & "\data\motd.ini", "MOTD", "Msg", Parse(1))
        MOTD = Parse(1)
        Call GlobalMsg("MOTD changed to: " & Parse(1), BrightCyan)
        Call AddLog(GetPlayerName(Index) & " changed MOTD to: " & Parse(1), ADMIN_LOG)
        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Bug Report packet ::
    ' :::::::::::::::::::::::
    If LCase$(Parse(0)) = "bugreport" Then
        Dim BugReport As String
        Dim Message As String
        Dim BugType, BugOccur, BugRepeat As Byte
        Dim BType, BOccur, BRepeat As String
        Message = Trim$(Parse(1))
        BugType = Parse(2)
        BugOccur = Parse(3)
        BugRepeat = Parse(4)

        If BugType = 1 Then
            BType = "Mapping"
        ElseIf BugType = 2 Then
            BType = "Programming"
        ElseIf BugType = 3 Then
            BType = "Other"
        End If

        If BugOccur = 1 Then
            BOccur = "Often"
        ElseIf BugOccur = 2 Then
            BOccur = "Sometimes"
        ElseIf BugOccur = 3 Then
            BOccur = "Once"
        End If

        If BugRepeat = 1 Then
            BRepeat = "Yes"
        ElseIf BugRepeat = 2 Then
            BRepeat = "No"
        End If
        ' 11.11PM Magnus: Type[Mapping] - Occurs[Often] - Repeat?[Yes]: Message
        BugReport = Time & " " & GetPlayerName(Index) & ": Type[" & BType & "] - Occurs[" & BOccur & "] - Repeat?[" & BRepeat & "]: " & Message
        frmServer.lstBugReport.AddItem BugReport
        Call AddLog(BugReport, BUG_LOG)
        Call PlayerMsg(Index, "Thank you for reporting this bug, " & GetPlayerName(Index), White)
        Exit Sub
    End If

    ' ::::::::::::::::::
    ' :: Trade packet ::
    ' ::::::::::::::::::
    If LCase$(Parse(0)) = "trade" Then
        If Map(GetPlayerMap(Index)).Shop > 0 Then
            Call SendTrade(Index, Map(GetPlayerMap(Index)).Shop)
        Else
            Call PlayerMsg(Index, "There is no shop here.", BrightRed)
        End If
        Exit Sub
    End If

    ' ::::::::::::::::::::::::::
    ' :: Trade request packet ::
    ' ::::::::::::::::::::::::::
    If LCase$(Parse(0)) = "traderequest" Then
        ' Trade num
        N = Val(Parse(1))

        ' Prevent hacking
        If (N <= 0) Or (N > MAX_TRADES) Then
            Call HackingAttempt(Index, "Trade Request Modification")
            Exit Sub
        End If

        ' Index for shop
        I = CurrentShop            ' Map(GetPlayerMap(Index)).Shop

        ' Check if inv full
        X = FindOpenInvSlot(Index, Shop(I).TradeItem(N).GetItem)
        If X = 0 Then
            Call PlayerMsg(Index, "Trade unsuccessful, inventory full.", BrightRed)
            Exit Sub
        End If

        ' Check if there are 2 Item to trade
        If Shop(I).TradeItem(N).GiveItem >= 1 And Shop(I).TradeItem(N).GiveItem2 >= 1 Then
            If HasItem(Index, Shop(I).TradeItem(N).GiveItem) >= Shop(I).TradeItem(N).GiveValue And HasItem(Index, Shop(I).TradeItem(N).GiveItem2) >= Shop(I).TradeItem(N).GiveValue2 Then
                Call TakeItem(Index, Shop(I).TradeItem(N).GiveItem, Shop(I).TradeItem(N).GiveValue)
                Call TakeItem(Index, Shop(I).TradeItem(N).GiveItem2, Shop(I).TradeItem(N).GiveValue2)
                Call GiveItem(Index, Shop(I).TradeItem(N).GetItem, Shop(I).TradeItem(N).GetValue)
                Call PlayerMsg(Index, "The trade was successful!", Yellow)
            Else
                Call PlayerMsg(Index, "Trade unsuccessful.", BrightRed)
            End If
            Exit Sub
        ElseIf Shop(I).TradeItem(N).GiveItem >= 1 And Shop(I).TradeItem(N).GiveItem2 <= 0 Then
            If HasItem(Index, Shop(I).TradeItem(N).GiveItem) >= Shop(I).TradeItem(N).GiveValue Then
                Call TakeItem(Index, Shop(I).TradeItem(N).GiveItem, Shop(I).TradeItem(N).GiveValue)
                Call GiveItem(Index, Shop(I).TradeItem(N).GetItem, Shop(I).TradeItem(N).GetValue)
                Call PlayerMsg(Index, "The trade was successful!", Yellow)
            Else
                Call PlayerMsg(Index, "Trade unsuccessful.", BrightRed)
            End If
            Exit Sub
        ElseIf Shop(I).TradeItem(N).GiveItem <= 0 And Shop(I).TradeItem(N).GiveItem2 >= 1 Then
            If HasItem(Index, Shop(I).TradeItem(N).GiveItem2) >= Shop(I).TradeItem(N).GiveValue2 Then
                Call TakeItem(Index, Shop(I).TradeItem(N).GiveItem2, Shop(I).TradeItem(N).GiveValue2)
                Call GiveItem(Index, Shop(I).TradeItem(N).GetItem, Shop(I).TradeItem(N).GetValue)
                Call PlayerMsg(Index, "The trade was successful!", Yellow)
            Else
                Call PlayerMsg(Index, "Trade unsuccessful.", BrightRed)
            End If
            Exit Sub
        ElseIf Shop(I).TradeItem(N).GiveItem <= 0 And Shop(I).TradeItem(N).GiveItem <= 0 Then
            Call PlayerMsg(Index, "There is nothing to trade!", BrightRed)
            Exit Sub
        Else
            Call PlayerMsg(Index, "Trade Error!", BrightRed)
            Exit Sub
        End If

    End If

    ' :::::::::::::::::::::
    ' :: Fix item packet ::
    ' :::::::::::::::::::::
    If LCase$(Parse(0)) = "fixitem" Then
        ' Inv num
        N = Val(Parse(1))

        ' Check to make sure there is a fix item shop on the map.
        If Not MapShopFixesItems(Index) Then
            Call PlayerMsg(Index, "Using a packet editor is strickly prohibited. Your account and IP has been logged and will be reported!", BrightRed)
            Call AddLog(GetPlayerName(Index) & " has been caught using a packet editor from this IP: " & GetPlayerIP(Index), PLAYER_LOG)
            Exit Sub

        Else

            ' Make sure its a equipable item
            If Item(GetPlayerInvItemNum(Index, N)).Type < ITEM_TYPE_WEAPON Or Item(GetPlayerInvItemNum(Index, N)).Type > ITEM_TYPE_SHIELD Then
                Call PlayerMsg(Index, "You can only fix weapons, armors, helmets, and shields.", BrightRed)
                Exit Sub
            End If

            ' Check if they have a full inventory
            If FindOpenInvSlot(Index, GetPlayerInvItemNum(Index, N)) <= 0 Then
                Call PlayerMsg(Index, "You have no inventory space left!", BrightRed)
                Exit Sub
            End If

            ' Now check the rate of pay
            ItemNum = GetPlayerInvItemNum(Index, N)
            I = Int(Item(GetPlayerInvItemNum(Index, N)).Data2 / 5)
            If I <= 0 Then I = 1

            DurNeeded = Item(ItemNum).Data1 - GetPlayerInvItemDur(Index, N)
            GoldNeeded = Int(DurNeeded * I / 2)
            If GoldNeeded <= 0 Then GoldNeeded = 1

            ' Check if they even need it repaired
            If DurNeeded <= 0 Then
                Call PlayerMsg(Index, "This item is in perfect condition!", White)
                Exit Sub
            End If

            ' Check if they have enough for at least one point
            If HasItem(Index, 1) >= I Then
                ' Check if they have enough for a total restoration
                If HasItem(Index, 1) >= GoldNeeded Then
                    Call TakeItem(Index, 1, GoldNeeded)
                    Call SetPlayerInvItemDur(Index, N, Item(ItemNum).Data1)
                    Call PlayerMsg(Index, "Item has been totally restored for " & GoldNeeded & " gold!", BrightBlue)
                Else
                    ' They dont so restore as much as we can
                    DurNeeded = (HasItem(Index, 1) / I)
                    GoldNeeded = Int(DurNeeded * I / 2)
                    If GoldNeeded <= 0 Then GoldNeeded = 1

                    Call TakeItem(Index, 1, GoldNeeded)
                    Call SetPlayerInvItemDur(Index, N, GetPlayerInvItemDur(Index, N) + DurNeeded)
                    Call PlayerMsg(Index, "Item has been partially fixed for " & GoldNeeded & " gold!", BrightBlue)
                End If
            Else
                Call PlayerMsg(Index, "Insufficient gold to fix this item!", BrightRed)
            End If
            Exit Sub
        End If
    End If

    ' :::::::::::::::::::
    ' :: Search packet ::
    ' :::::::::::::::::::
    If LCase$(Parse(0)) = "search" Then
        X = Val(Parse(1))
        y = Val(Parse(2))

        ' Prevent subscript out of range
        If X < 0 Or X > MAX_MAPX Or y < 0 Or y > MAX_MAPY Then
            Exit Sub
        End If

        ' Check for a player
        For I = 1 To HighIndex
            If IsPlaying(I) And GetPlayerMap(Index) = GetPlayerMap(I) And GetPlayerX(I) = X And GetPlayerY(I) = y Then

                ' Consider the player
                If GetPlayerLevel(I) >= GetPlayerLevel(Index) + 5 Then
                    Call PlayerMsg(Index, "You wouldn't stand a chance.", BrightRed)
                Else
                    If GetPlayerLevel(I) > GetPlayerLevel(Index) Then
                        Call PlayerMsg(Index, "This one seems to have an advantage over you.", Yellow)
                    Else
                        If GetPlayerLevel(I) = GetPlayerLevel(Index) Then
                            Call PlayerMsg(Index, "This would be an even fight.", White)
                        Else
                            If GetPlayerLevel(Index) >= GetPlayerLevel(I) + 5 Then
                                Call PlayerMsg(Index, "You could slaughter that player.", BrightBlue)
                            Else
                                If GetPlayerLevel(Index) > GetPlayerLevel(I) Then
                                    Call PlayerMsg(Index, "You would have an advantage over that player.", Yellow)
                                End If
                            End If
                        End If
                    End If
                End If

                ' Change target
                Player(Index).Target = I
                Player(Index).TargetType = TARGET_TYPE_PLAYER
                Call PlayerMsg(Index, "Your target is now " & GetPlayerName(I) & ".", Yellow)
                Exit Sub
            End If
        Next I

        ' Check for an item
        For I = 1 To MAX_MAP_ITEMS
            If MapItem(GetPlayerMap(Index), I).Num > 0 Then
                If MapItem(GetPlayerMap(Index), I).X = X And MapItem(GetPlayerMap(Index), I).y = y Then
                    If IsVowel(Item(MapItem(GetPlayerMap(Index), I).Num).name) = True Then
                        Call PlayerMsg(Index, "You see an " & Trim$(Item(MapItem(GetPlayerMap(Index), I).Num).name) & ".", Yellow)
                    Else
                        Call PlayerMsg(Index, "You see a " & Trim$(Item(MapItem(GetPlayerMap(Index), I).Num).name) & ".", Yellow)
                    End If
                    Exit Sub
                End If
            End If
        Next I

        ' Check for an npc
        For I = 1 To MAX_MAP_NPCS
            If MapNpc(GetPlayerMap(Index), I).Num > 0 Then
                If MapNpc(GetPlayerMap(Index), I).X = X And MapNpc(GetPlayerMap(Index), I).y = y Then
                    ' Change target
                    Player(Index).Target = I
                    Player(Index).TargetType = TARGET_TYPE_NPC
                    If IsVowel(Npc(MapNpc(GetPlayerMap(Index), I).Num).name) = True Then
                        Call PlayerMsg(Index, "Your target is now an " & Trim$(Npc(MapNpc(GetPlayerMap(Index), I).Num).name) & ".", Yellow)
                    Else
                        Call PlayerMsg(Index, "Your target is now a " & Trim$(Npc(MapNpc(GetPlayerMap(Index), I).Num).name) & ".", Yellow)
                    End If
                    Exit Sub
                End If
            End If
        Next I

        Exit Sub
    End If

    ' ::::::::::::::::::::::::
    ' :: Warp Search packet ::
    ' ::::::::::::::::::::::::
    If LCase$(Parse(0)) = "warpsearch" Then
        X = Val(Parse(1))
        y = Val(Parse(2))

        ' Prevent subscript out of range
        If X < 0 Or X > MAX_MAPX Or y < 0 Or y > MAX_MAPY Then
            Exit Sub
        End If

        Call PlayerWarp(Index, GetPlayerMap(Index), X, y)
    End If

    ' ::::::::::::::::::
    ' :: Party packet ::
    ' ::::::::::::::::::
    If LCase$(Parse(0)) = "party" Then
        N = FindPlayer(Parse(1))

        ' Prevent partying with self
        If N = Index Then
            Exit Sub
        End If

        ' Check for a previous party and if so drop it
        If Player(Index).InParty = YES Then
            Call PlayerMsg(Index, "You are already in a party!", Pink)
            Exit Sub
        End If

        If N > 0 Then
            ' Check if its an admin
            If GetPlayerAccess(Index) > ADMIN_MONITER Then
                Call PlayerMsg(Index, "You can't join a party, you are an admin!", BrightBlue)
                Exit Sub
            End If

            If GetPlayerAccess(N) > ADMIN_MONITER Then
                Call PlayerMsg(Index, "Admins cannot join parties!", BrightBlue)
                Exit Sub
            End If

            ' Make sure they are in right level range
            If GetPlayerLevel(Index) + 5 < GetPlayerLevel(N) Or GetPlayerLevel(Index) - 5 > GetPlayerLevel(N) Then
                Call PlayerMsg(Index, "There is more then a 5 level gap between you two, party failed.", Pink)
                Exit Sub
            End If

            ' Check to see if player is already in a party
            If Player(N).InParty = NO Then
                Call PlayerMsg(Index, "Party request has been sent to " & GetPlayerName(N) & ".", Pink)
                Call PlayerMsg(N, GetPlayerName(Index) & " wants you to join their party.  Type /join to join, or /leave to decline.", Pink)

                Player(Index).PartyStarter = YES
                Player(Index).PartyPlayer = N
                Player(N).PartyPlayer = Index
            Else
                Call PlayerMsg(Index, "Player is already in a party!", Pink)
            End If
        Else
            Call PlayerMsg(Index, "Player is not online.", White)
        End If
        Exit Sub
    End If

    ' :::::::::::::::::::::::
    ' :: Join party packet ::
    ' :::::::::::::::::::::::
    If LCase$(Parse(0)) = "joinparty" Then
        N = Player(Index).PartyPlayer

        If N > 0 Then
            ' Check to make sure they aren't the starter
            If Player(Index).PartyStarter = NO Then
                ' Check to make sure that each of there party players match
                If Player(N).PartyPlayer = Index Then
                    Call PlayerMsg(Index, "You have joined " & GetPlayerName(N) & "'s party!", Pink)
                    Call PlayerMsg(N, GetPlayerName(Index) & " has joined your party!", Pink)

                    Player(Index).InParty = YES
                    Player(N).InParty = YES
                Else
                    Call PlayerMsg(Index, "Party failed.", Pink)
                End If
            Else
                Call PlayerMsg(Index, "You have not been invited to join a party!", Pink)
            End If
        Else
            Call PlayerMsg(Index, "You have not been invited into a party!", Pink)
        End If
        Exit Sub
    End If

    ' ::::::::::::::::::::::::
    ' :: Leave party packet ::
    ' ::::::::::::::::::::::::
    If LCase$(Parse(0)) = "leaveparty" Then
        N = Player(Index).PartyPlayer

        If N > 0 Then
            If Player(Index).InParty = YES Then
                Call PlayerMsg(Index, "You have left the party.", Pink)
                Call PlayerMsg(N, GetPlayerName(Index) & " has left the party.", Pink)

                Player(Index).PartyPlayer = 0
                Player(Index).PartyStarter = NO
                Player(Index).InParty = NO
                Player(N).PartyPlayer = 0
                Player(N).PartyStarter = NO
                Player(N).InParty = NO
            Else
                Call PlayerMsg(Index, "Declined party request.", Pink)
                Call PlayerMsg(N, GetPlayerName(Index) & " declined your request.", Pink)

                Player(Index).PartyPlayer = 0
                Player(Index).PartyStarter = NO
                Player(Index).InParty = NO
                Player(N).PartyPlayer = 0
                Player(N).PartyStarter = NO
                Player(N).InParty = NO
            End If
        Else
            Call PlayerMsg(Index, "You are not in a party!", Pink)
        End If
        Exit Sub
    End If

    ' :::::::::::::::::::
    ' :: Spells packet ::
    ' :::::::::::::::::::
    If LCase$(Parse(0)) = "spells" Then
        Call SendPlayerSpells(Index)
        Exit Sub
    End If

    ' :::::::::::::::::
    ' :: Cast packet ::
    ' :::::::::::::::::
    If LCase$(Parse(0)) = "cast" Then
        ' Spell slot
        N = Val(Parse(1))

        Call CastSpell(Index, N)

        Exit Sub
    End If

    ' :::::::::::::::::::::::::
    ' :: Forget spell packet ::
    ' :::::::::::::::::::::::::
    If LCase(Parse(0)) = "forgetspell" Then
        ' Spell slot
        N = CLng(Parse(1))

        ' Prevent subscript out of range
        If N <= 0 Or N > MAX_PLAYER_SPELLS Then
            HackingAttempt Index, "Invalid Spell Slot"
            Exit Sub
        End If

        With Player(Index).Char(Player(Index).CharNum)
            If .Spell(N) = 0 Then
                PlayerMsg Index, "No spell here.", Red

            Else
                PlayerMsg Index, "You have forgotten the spell" & vbQuote & Trim$(Spell(.Spell(N)).name) & vbQuote, Green
                .Spell(N) = 0
                Call SendSpells(Index)
            End If
        End With

        Exit Sub
    End If

    ' :::::::::::::::::::::
    ' :: Resync packet  ::
    ' :::::::::::::::::::::
    If LCase$(Parse(0)) = "resync" Then
        Call PlayerWarp(Index, GetPlayerMap(Index), GetPlayerX(Index), GetPlayerY(Index))
        Call PlayerMsg(Index, "Resynced!", White)
        Exit Sub
    End If

    ' :::::::::::::::::::::
    ' :: Location packet ::
    ' :::::::::::::::::::::
    If LCase$(Parse(0)) = "requestlocation" Then
        If GetPlayerAccess(Index) < ADMIN_MAPPER Then
            Call HackingAttempt(Index, "Admin Cloning")
            Exit Sub
        End If

        Call PlayerMsg(Index, "Map: " & GetPlayerMap(Index) & ", X: " & GetPlayerX(Index) & ", Y: " & GetPlayerY(Index), Pink)
        Exit Sub
    End If

    Exit Sub

ErrorHandle:



End Sub









    ' Sub NpcTrade(ByVal Index As Long)
    ' If Npc(MapNpc(GetPlayerMap(Index), I).Num).ShopCall > 0 Then
    ' Call SendTrade(Index, Npc(MapNpc(GetPlayerMap(Index), I).Num).ShopCall)
    ' Else
    ' Call PlayerMsg(Index, "A " & Trim$(Npc(MapNpc(GetPlayerMap(Index), I).Num).Name) & " says to you,'" & Trim$(Npc(MapNpc(GetPlayerMap(Index), I).Num).AttackSay) & "'", Grey)
    ' End If
    ' Exit Sub
    ' End Sub
