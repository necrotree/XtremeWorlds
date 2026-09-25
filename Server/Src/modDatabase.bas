Attribute VB_Name = "modDatabase"
Option Explicit

Public Function GetVar(File As String, Header As String, Var As String) As String
    Dim sSpaces As String          ' Max string length
    Dim szReturn As String         ' Return default value if not found

    szReturn = vbNullString

    sSpaces = Space$(5000)

    Call GetPrivateProfileString(Header, Var, szReturn, sSpaces, Len(sSpaces), File)

    GetVar = RTrim$(sSpaces)
    GetVar = Left$(GetVar, Len(GetVar) - 1)
End Function

Public Sub PutVar(File As String, Header As String, Var As String, Value As String)
    Call WritePrivateProfileString(Header, Var, Value, File)
End Sub

Public Function FileExist(ByVal FileName As String, Optional RAW As Boolean = False) As Boolean
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/16/2005  Shannara   Optimized function.
' ****************************************************************

    If RAW = False Then
        If Dir(App.Path & "\" & FileName) = vbNullString Then
            FileExist = False
            Exit Function
        Else
            FileExist = True
            Exit Function
        End If
    Else
        If Dir(FileName) = vbNullString Then
            FileExist = False
            Exit Function
        Else
            FileExist = True
        End If
    End If
End Function

Sub SavePlayer(ByVal Index As Long)
    Dim FileName As String
    Dim f As Long
    Dim I As Long
    Dim StartByte As Long

    FileName = App.Path & "\data\accounts\" & Trim$(Player(Index).Login) & ".act"

    Dim dataFile1 As clsDataFile
    Set dataFile1 = New clsDataFile
    dataFile1.WriteText Player(Index).Login, NAME_LENGTH
    dataFile1.WriteText Player(Index).Password, NAME_LENGTH
    WritePlayerRec dataFile1, Player(Index).Char(1)
    WritePlayerRec dataFile1, Player(Index).Char(2)
    WritePlayerRec dataFile1, Player(Index).Char(3)
    dataFile1.Save FileName
End Sub

Sub LoadPlayer(ByVal Index As Long, ByVal Name As String)
    Dim FileName As String
    Dim f As Long
    Dim StartByte As Long

    Call ClearPlayer(Index)

    FileName = App.Path & "\data\accounts\" & Trim$(Name) & ".act"

    Dim dataFile2 As clsDataFile
    Set dataFile2 = New clsDataFile
    dataFile2.Load FileName
    Player(Index).Login = dataFile2.ReadText(NAME_LENGTH)
    Player(Index).Password = dataFile2.ReadText(NAME_LENGTH)
    ReadPlayerRec dataFile2, Player(Index).Char(1)
    ReadPlayerRec dataFile2, Player(Index).Char(2)
    ReadPlayerRec dataFile2, Player(Index).Char(3)
    dataFile2.RequireEnd
End Sub

Function AccountExist(ByVal Name As String) As Boolean
    Dim FileName As String

    FileName = "\data\accounts\" & Trim$(Name) & ".act"

    If FileExist(FileName) Then
        AccountExist = True
    Else
        AccountExist = False
    End If
End Function

Function CharExist(ByVal Index As Long, ByVal CharNum As Long) As Boolean
    If Trim$(Player(Index).Char(CharNum).Name) <> vbNullString Then
        CharExist = True
    Else
        CharExist = False
    End If
End Function

Function PasswordOK(ByVal Name As String, ByVal Password As String) As Boolean
    Dim FileName As String
    Dim RightPassword As String * NAME_LENGTH
    Dim nFileNum As Integer


    PasswordOK = False

    If AccountExist(Name) Then
        FileName = App.Path & "\data\accounts\" & Trim$(Name) & ".act"

    Dim dataFile3 As clsDataFile
    Set dataFile3 = New clsDataFile
    dataFile3.Load FileName
    dataFile3.Position = NAME_LENGTH
    RightPassword = dataFile3.ReadText(NAME_LENGTH)

        If Trim$(Password) = Trim$(RightPassword) Then
            PasswordOK = True
        End If
    End If


End Function

Function EncKeyOK(ByVal Name As String, ByVal EncKey As String) As Boolean
    Dim FileName As String
    Dim RightPassword As String
    Dim RightEncKey As String

    EncKeyOK = False

    If AccountExist(Name) Then
        FileName = App.Path & "\data\accounts\" & Trim$(Name) & ".act"
        RightEncKey = ENC_KEY

        If UCase$(Trim$(EncKey)) = UCase$(Trim$(ENC_KEY)) Then
            EncKeyOK = True
        End If
    End If
End Function

Sub AddAccount(ByVal Index As Long, ByVal Name As String, ByVal Password As String)
    Dim I As Long

    Player(Index).Login = Name
    Player(Index).Password = Password
    Player(Index).EncKey = ENC_KEY

    For I = 1 To MAX_CHARS
        Call ClearChar(Index, I)
    Next I

    Call SavePlayer(Index)
End Sub

Sub AddChar(ByVal Index As Long, ByVal Name As String, ByVal Sex As Byte, ByVal ClassNum As Byte, ByVal CharNum As Long)
    Dim f As Long

    If Trim$(Player(Index).Char(CharNum).Name) = vbNullString Then
        Player(Index).CharNum = CharNum

        Player(Index).Char(CharNum).Name = Name
        Player(Index).Char(CharNum).Sex = Sex
        Player(Index).Char(CharNum).Class = ClassNum

        If Player(Index).Char(CharNum).Sex = SEX_MALE Then
            Player(Index).Char(CharNum).Sprite = Class(ClassNum).Sprite
        Else
            Player(Index).Char(CharNum).Sprite = Class(ClassNum).FSprite
        End If

        Player(Index).Char(CharNum).Level = 1

        Player(Index).Char(CharNum).STR = Class(ClassNum).STR
        Player(Index).Char(CharNum).DEF = Class(ClassNum).DEF
        Player(Index).Char(CharNum).SPEED = Class(ClassNum).SPEED
        Player(Index).Char(CharNum).MAGI = Class(ClassNum).MAGI

        Player(Index).Char(CharNum).Map = START_MAP
        Player(Index).Char(CharNum).X = START_X
        Player(Index).Char(CharNum).y = START_Y

        Player(Index).Char(CharNum).HP = GetPlayerMaxHP(Index)
        Player(Index).Char(CharNum).MP = GetPlayerMaxMP(Index)
        Player(Index).Char(CharNum).SP = GetPlayerMaxSP(Index)

        ' Append name to file
        f = FreeFile
        Open App.Path & "\data\accounts\charlist.txt" For Append As #f
        Print #f, Name
        Close #f

' Call SavePlayer(Index)

        Exit Sub
    End If
End Sub

Sub DelChar(ByVal Index As Long, ByVal CharNum As Long)
    Dim f1 As Long, f2 As Long
    Dim s As String

    Call DeleteName(Player(Index).Char(CharNum).Name)
    Call ClearChar(Index, CharNum)
    Call SavePlayer(Index)
End Sub

Function FindChar(ByVal Name As String) As Boolean
    Dim f As Long
    Dim s As String

    FindChar = False

    f = FreeFile
    Open App.Path & "\data\accounts\charlist.txt" For Input As #f
    Do While Not EOF(f)
        Input #f, s

        If Trim$(LCase$(s)) = Trim$(LCase$(Name)) Then
            FindChar = True
            Close #f
            Exit Function
        End If
    Loop
    Close #f
End Function

Sub SaveAllPlayersOnline()
    Dim I As Long

    For I = 1 To HighIndex
        If IsPlaying(I) Then
            Call SavePlayer(I)
        End If
    Next I
End Sub

Sub LoadClasses()
    Dim FileName As String
    Dim I As Long

    Call CheckClasses

    FileName = App.Path & "\data\classes.ini"

    Max_Classes = Val(GetVar(FileName, "INIT", "MaxClasses"))

    ReDim Class(0 To Max_Classes) As ClassRec

    Call ClearClasses

    For I = 0 To Max_Classes
        Class(I).Name = GetVar(FileName, "CLASS" & I, "Name")
        Class(I).Sprite = GetVar(FileName, "CLASS" & I, "Sprite")
        Class(I).FSprite = GetVar(FileName, "CLASS" & I, "FSprite")
        Class(I).STR = Val(GetVar(FileName, "CLASS" & I, "STR"))
        Class(I).DEF = Val(GetVar(FileName, "CLASS" & I, "DEF"))
        Class(I).SPEED = Val(GetVar(FileName, "CLASS" & I, "SPEED"))
        Class(I).MAGI = Val(GetVar(FileName, "CLASS" & I, "MAGI"))

        DoEvents
    Next I
End Sub

Sub SaveClasses()
    Dim FileName As String
    Dim I As Long

    FileName = App.Path & "\data\classes.ini"

    Call PutVar(FileName, "INIT", "MaxClasses", CStr(Max_Classes))

    For I = 0 To Max_Classes
        Call PutVar(FileName, "CLASS" & I, "Name", Trim$(Class(I).Name))
        Call PutVar(FileName, "CLASS" & I, "Sprite", Str$(Class(I).Sprite))
        Call PutVar(FileName, "CLASS" & I, "FSprite", Str$(Class(I).FSprite))
        Call PutVar(FileName, "CLASS" & I, "STR", Str$(Class(I).STR))
        Call PutVar(FileName, "CLASS" & I, "DEF", Str$(Class(I).DEF))
        Call PutVar(FileName, "CLASS" & I, "SPEED", Str$(Class(I).SPEED))
        Call PutVar(FileName, "CLASS" & I, "MAGI", Str$(Class(I).MAGI))
    Next I
End Sub

Sub CheckClasses()
    If Not FileExist("data\classes.ini") Then
        ' First startup reaches here before LoadClasses allocates the array.
        ReDim Class(0 To Max_Classes) As ClassRec
        Call ClearClasses
        Call SaveClasses
    End If
End Sub

Sub SaveItems()
    Dim I As Long

    Call SetStatus("Saving items... ")

    For I = 1 To MAX_ITEMS

        If Not FileExist("data\items\item" & I & ".itm") Then
            Call SetStatus("Saving items... ")

            DoEvents
            Call SaveItem(I)
        End If

    Next

End Sub

Sub SaveItem(ByVal ItemNum As Long)
    Dim FileName As String
    Dim f  As Long

    FileName = App.Path & "\data\items\item" & ItemNum & ".itm"

    Dim dataFile4 As clsDataFile
    Set dataFile4 = New clsDataFile
    WriteItemRec dataFile4, Item(ItemNum)
    dataFile4.Save FileName
End Sub

Sub LoadItems()
    Dim FileName As String
    Dim I As Long
    Dim f As Long

    Call CheckItems

    For I = 1 To MAX_ITEMS
        Call SetStatus("Loading items... ")
        FileName = App.Path & "\data\items\item" & I & ".itm"

    Dim dataFile5 As clsDataFile
    Set dataFile5 = New clsDataFile
    dataFile5.Load FileName
    ReadItemRec dataFile5, Item(I)
    dataFile5.RequireEnd

        DoEvents
    Next

End Sub

Sub CheckItems()
    Call SaveItems
End Sub

' Begin Guilds

Sub SaveGuilds()
    Dim I As Long

    Call SetStatus("Saving Guilds... ")

    For I = 1 To MAX_GUILDS

        If Not FileExist("data\guilds\guild" & I & ".gld") Then
            Call SetStatus("Saving Guilds... ")

            DoEvents
            Call SaveGuild(I)
        End If

    Next

End Sub

Sub SaveGuild(ByVal GuildNum As Long)
    Dim FileName As String
    Dim f  As Long

    FileName = App.Path & "\data\guilds\guild" & GuildNum & ".gld"

    Dim dataFile6 As clsDataFile
    Set dataFile6 = New clsDataFile
    WriteGuildRec dataFile6, Guild(GuildNum)
    dataFile6.Save FileName
End Sub

Sub LoadGuilds()
    Dim FileName As String
    Dim I As Long
    Dim f As Long

    Call CheckGuilds

    For I = 1 To MAX_GUILDS
        Call SetStatus("Loading Guilds... ")
        FileName = App.Path & "\data\guilds\guild" & I & ".gld"

    Dim dataFile7 As clsDataFile
    Set dataFile7 = New clsDataFile
    dataFile7.Load FileName
    ReadGuildRec dataFile7, Guild(I)
    dataFile7.RequireEnd

        DoEvents
    Next

End Sub

Sub CheckGuilds()
    Call SaveGuilds
End Sub

' End Guilds

'Begin Quests

Sub SaveQuests()
    Dim I As Long

    Call SetStatus("Saving Quests... ")

    For I = 1 To MAX_QUESTS

        If Not FileExist("data\quests\quest" & I & ".qst") Then
            Call SetStatus("Saving Quests... ")

            DoEvents
            Call SaveQuest(I)
        End If

    Next

End Sub

Sub SaveQuest(ByVal QuestNum As Long)
    Dim FileName As String
    Dim f  As Long

    FileName = App.Path & "\data\quests\quest" & QuestNum & ".qst"

    Dim dataFile8 As clsDataFile
    Set dataFile8 = New clsDataFile
    WriteQuestRec dataFile8, Quest(QuestNum)
    dataFile8.Save FileName
End Sub

Sub LoadQuests()
    Dim FileName As String
    Dim I As Long
    Dim f As Long

    Call CheckQuests

    For I = 1 To MAX_QUESTS
        Call SetStatus("Loading Quests... ")
        FileName = App.Path & "\data\quests\quest" & I & ".qst"

    Dim dataFile9 As clsDataFile
    Set dataFile9 = New clsDataFile
    dataFile9.Load FileName
    ReadQuestRec dataFile9, Quest(I)
    dataFile9.RequireEnd

        DoEvents
    Next

End Sub

Sub CheckQuests()
    Call SaveQuests
End Sub

'End Quests

Sub SaveShops()
    Dim I As Long

    Call SetStatus("Saving Shops... ")

    For I = 1 To MAX_SHOPS

        If Not FileExist("data\Shops\Shop" & I & ".shp") Then
            Call SetStatus("Saving Shops... ")

            DoEvents
            Call SaveShop(I)
        End If

    Next

End Sub

Sub SaveShop(ByVal ShopNum As Long)
    Dim FileName As String
    Dim f  As Long

    FileName = App.Path & "\data\Shops\Shop" & ShopNum & ".shp"

    Dim dataFile10 As clsDataFile
    Set dataFile10 = New clsDataFile
    WriteShopRec dataFile10, Shop(ShopNum)
    dataFile10.Save FileName
End Sub

Sub LoadShops()
    Dim FileName As String
    Dim I As Long
    Dim f As Long

    Call CheckShops

    For I = 1 To MAX_SHOPS
        Call SetStatus("Loading Shops... ")
        FileName = App.Path & "\data\Shops\Shop" & I & ".shp"

    Dim dataFile11 As clsDataFile
    Set dataFile11 = New clsDataFile
    dataFile11.Load FileName
    ReadShopRec dataFile11, Shop(I)
    dataFile11.RequireEnd

        DoEvents
    Next

End Sub

Sub CheckShops()
    Call SaveShops
End Sub

Sub SaveSign(ByVal SignNum As Long)
    Dim FileName As String
    Dim f  As Long

    FileName = App.Path & "\data\Signs\Sign" & SignNum & ".sign"

    Dim dataFile12 As clsDataFile
    Set dataFile12 = New clsDataFile
    WriteSignRec dataFile12, Sign(SignNum)
    dataFile12.Save FileName
End Sub

Sub SaveSigns()
    Dim I As Long

    Call SetStatus("Saving Signs... ")

    For I = 1 To MAX_SIGNS

        If Not FileExist("data\Signs\Sign" & I & ".sign") Then
            Call SetStatus("Saving Signs... ")

            DoEvents
            Call SaveSign(I)
        End If

    Next

End Sub

Sub LoadSigns()
    Dim FileName As String
    Dim I As Long
    Dim f As Long

    Call CheckSigns

    For I = 1 To MAX_SIGNS
        Call SetStatus("Loading signs... ")
        FileName = App.Path & "\data\Signs\Sign" & I & ".sign"

    Dim dataFile13 As clsDataFile
    Set dataFile13 = New clsDataFile
    dataFile13.Load FileName
    ReadSignRec dataFile13, Sign(I)
    dataFile13.RequireEnd
        If I Mod 20 Then DoEvents
    Next
End Sub

Sub CheckSigns()
    Call SaveSigns
End Sub

Sub SaveSpell(ByVal SpellNum As Long)
    Dim FileName As String
    Dim f  As Long

    FileName = App.Path & "\data\Spells\Spell" & SpellNum & ".spl"

    Dim dataFile14 As clsDataFile
    Set dataFile14 = New clsDataFile
    WriteSpellRec dataFile14, Spell(SpellNum)
    dataFile14.Save FileName
End Sub

Sub SaveSpells()
    Dim I As Long

    Call SetStatus("Saving Spells... ")

    For I = 1 To MAX_SPELLS

        If Not FileExist("data\Spells\Spell" & I & ".spl") Then
            Call SetStatus("Saving Spells... ")

            DoEvents
            Call SaveSpell(I)
        End If

    Next

End Sub

Sub LoadSpells()
    Dim FileName As String
    Dim I As Long
    Dim f As Long

    Call CheckSpells

    For I = 1 To MAX_SPELLS
        Call SetStatus("Loading Spells... ")
        FileName = App.Path & "\data\Spells\Spell" & I & ".spl"

    Dim dataFile15 As clsDataFile
    Set dataFile15 = New clsDataFile
    dataFile15.Load FileName
    ReadSpellRec dataFile15, Spell(I)
    dataFile15.RequireEnd

        DoEvents
    Next

End Sub

Sub CheckSpells()
    Call SaveSpells
End Sub

Sub SaveNpc(ByVal NpcNum As Long)
    Dim FileName As String
    Dim f  As Long

    FileName = App.Path & "\data\Npcs\Npc" & NpcNum & ".npc"

    Dim dataFile16 As clsDataFile
    Set dataFile16 = New clsDataFile
    WriteNpcRec dataFile16, Npc(NpcNum)
    dataFile16.Save FileName
End Sub

Sub SaveNpcs()
    Dim I As Long

    Call SetStatus("Saving Npcs... ")

    For I = 1 To MAX_NPCS

        If Not FileExist("data\Npcs\Npc" & I & ".npc") Then
            Call SetStatus("Saving Npcs... ")

            DoEvents
            Call SaveNpc(I)
        End If

    Next

End Sub

Sub LoadNpcs()
    Dim FileName As String
    Dim I As Long
    Dim f As Long

    Call CheckNpcs

    For I = 1 To MAX_NPCS
        Call SetStatus("Loading Npcs... ")
        FileName = App.Path & "\data\Npcs\Npc" & I & ".npc"

    Dim dataFile17 As clsDataFile
    Set dataFile17 = New clsDataFile
    dataFile17.Load FileName
    ReadNpcRec dataFile17, Npc(I)
    dataFile17.RequireEnd

        DoEvents
    Next

End Sub

Sub CheckNpcs()
    Call SaveNpcs
End Sub

Sub SaveMap(ByVal MapNum As Long)
    Dim FileName As String
    Dim f As Long

    FileName = App.Path & "\maps\map" & MapNum & ".dat"

    Dim dataFile18 As clsDataFile
    Set dataFile18 = New clsDataFile
    WriteMapRec dataFile18, Map(MapNum)
    dataFile18.Save FileName
End Sub

Sub SaveMaps()
    Dim FileName As String
    Dim I As Long
    Dim f As Long

    For I = 1 To MAX_MAPS_SET
        Call SaveMap(I)
    Next I
End Sub

Sub LoadMaps()
    Dim FileName As String
    Dim I As Long
    Dim f As Long

    Call CheckMaps

    For I = 1 To MAX_MAPS_SET
        FileName = App.Path & "\maps\map" & I & ".dat"

    Dim dataFile19 As clsDataFile
    Set dataFile19 = New clsDataFile
    dataFile19.Load FileName
    ReadMapRec dataFile19, Map(I)
    dataFile19.RequireEnd

        DoEvents
    Next I
End Sub

Sub ConvertOldMapsToNew()
    Dim FileName As String
    Dim I As Long
    Dim f As Long
    Dim X As Long, y As Long
    Dim OldMap As OldMapRec
    Dim NewMap As MapRec

    For I = 1 To MAX_MAPS_SET
        FileName = App.Path & "\maps\map" & I & ".dat"

        ' Get the old file

    Dim dataFile20 As clsDataFile
    Set dataFile20 = New clsDataFile
    dataFile20.Load FileName
    ReadOldMapRec dataFile20, OldMap
    dataFile20.RequireEnd

        ' Keep the old file until the native writer replaces it successfully.
        ResetMapRec NewMap

        ' Convert
        NewMap.Name = OldMap.Name
        NewMap.Revision = OldMap.Revision + 1
        NewMap.Moral = OldMap.Moral
        NewMap.Up = OldMap.Up
        NewMap.Down = OldMap.Down
        NewMap.Left = OldMap.Left
        NewMap.Right = OldMap.Right
        NewMap.Music = OldMap.Music
        NewMap.BootMap = OldMap.BootMap
        NewMap.BootX = OldMap.BootX
        NewMap.BootY = OldMap.BootY
        NewMap.Shop = OldMap.Shop
        For y = 0 To MAX_MAPY
            For X = 0 To MAX_MAPX
                NewMap.Tile(X, y).Ground = OldMap.Tile(X, y).Ground
                NewMap.Tile(X, y).Mask = OldMap.Tile(X, y).Mask
                NewMap.Tile(X, y).Anim = OldMap.Tile(X, y).Anim
                NewMap.Tile(X, y).Fringe = OldMap.Tile(X, y).Fringe
                NewMap.Tile(X, y).Type = OldMap.Tile(X, y).Type
                NewMap.Tile(X, y).Data1 = OldMap.Tile(X, y).Data1
                NewMap.Tile(X, y).Data2 = OldMap.Tile(X, y).Data2
                NewMap.Tile(X, y).Data3 = OldMap.Tile(X, y).Data3
            Next X
        Next y

        For X = 1 To MAX_MAP_NPCS
            NewMap.Npc(X) = OldMap.Npc(X)
        Next X

        ' Set new values to 0 or null
        NewMap.Indoors = NO

        ' Save the new map

    Dim dataFile21 As clsDataFile
    Set dataFile21 = New clsDataFile
    WriteMapRec dataFile21, NewMap
    dataFile21.Save FileName
    Next I
End Sub

Sub CheckMaps()
    Dim FileName As String
    Dim X As Long
    Dim y As Long
    Dim I As Long
    Dim N As Long

    Call ClearMaps

    For I = 1 To MAX_MAPS_SET
        FileName = "maps\map" & I & ".dat"

        ' Check to see if map exists, if it doesn't, create it.
        If Not FileExist(FileName) Then
            Call SaveMap(I)
        End If
    Next I
End Sub

Sub AddLog(ByVal Text As String, ByVal FN As String)
    Dim FileName As String
    Dim f As Long

    If ServerLog = True Then
        FileName = App.Path & "\logs\" & FN

        If Not FileExist("logs\" & FN) Then
            f = FreeFile
            Open FileName For Output As #f
            Close #f
        End If

        f = FreeFile
        Open FileName For Append As #f
        Print #f, Time & ": " & Text
        Close #f
    End If
End Sub

Sub BanIndex(ByVal BanPlayerIndex As Long, Optional BannedByIndex As String)
    Dim I As Long, BNum As Long
    BNum = -1
    For I = 0 To MAX_BANS
        If Len(Ban(I).BannedIP) = 0 And Len(Ban(I).BannedHD) = 0 Then
            BNum = I
            Exit For
        End If
    Next I
    If BNum < 0 Then
        If MAX_BANS = 32767 Then Err.Raise 6, "BanIndex", "The ban list is full."
        MAX_BANS = MAX_BANS + 1
        ReDim Preserve Ban(0 To MAX_BANS) As BanRec
        BNum = MAX_BANS
    End If
    Ban(BNum).BannedIP = GetPlayerIP(BanPlayerIndex)
    Ban(BNum).BannedChar = GetPlayerName(BanPlayerIndex)
    Ban(BNum).BannedBy = Trim$(BannedByIndex)
    Ban(BNum).BannedHD = GetPlayerHD(BanPlayerIndex)
    SaveBan BNum
End Sub

Sub UnBanIndex(ByVal BannedPlayerName As String, ByVal DeBannedByIndex As Long)
    Dim I As Long
    For I = 0 To MAX_BANS
        If Len(Ban(I).BannedChar) > 0 And LCase$(Ban(I).BannedChar) = LCase$(BannedPlayerName) Then
            Ban(I).BannedIP = vbNullString
            Ban(I).BannedChar = vbNullString
            Ban(I).BannedBy = vbNullString
            Ban(I).BannedHD = vbNullString
            SaveBan I
            Call GlobalMsg(BannedPlayerName & " has been unbanned from " & GAME_NAME & " by " & GetPlayerName(DeBannedByIndex) & "!", White)
            Call AddLog(GetPlayerName(DeBannedByIndex) & " has unbanned " & BannedPlayerName & ".", ADMIN_LOG)
            Exit Sub
        End If
    Next I
    Call PlayerMsg(DeBannedByIndex, "Player is not banned!", White)
End Sub

Sub DeleteName(ByVal Name As String)
    Dim f1 As Long, f2 As Long
    Dim s As String

    Call FileCopy(App.Path & "\data\accounts\charlist.txt", App.Path & "\data\accounts\chartemp.txt")

    ' Destroy name from charlist
    f1 = FreeFile
    Open App.Path & "\data\accounts\chartemp.txt" For Input As #f1
    f2 = FreeFile
    Open App.Path & "\data\accounts\charlist.txt" For Output As #f2

    Do While Not EOF(f1)
        Input #f1, s
        If Trim$(LCase$(s)) <> Trim$(LCase$(Name)) Then
            Print #f2, s
        End If
    Loop

    Close #f1
    Close #f2

    Call Kill(App.Path & "\data\accounts\chartemp.txt")
End Sub

Private Function BanListFile() As String
    ' Keep legacy root-level lists usable; all operations resolve the same file.
    BanListFile = App.Path & "\data\banlist.ini"
    If Not FileExist(BanListFile, True) Then
        If FileExist(App.Path & "\banlist.ini", True) Then BanListFile = App.Path & "\banlist.ini"
    End If
End Function

Sub LoadBans()
    Dim FileName As String, total As String
    Dim I As Long, lastSlot As Double
    EnsureDataFolders App.Path
    FileName = BanListFile()
    total = Trim$(GetVar(FileName, "Total", "Total"))
    If Len(total) = 0 Then
        lastSlot = 0
    Else
        If Not IsNumeric(total) Then Err.Raise 13, "LoadBans", "Invalid ban list total: " & FileName
        lastSlot = CDbl(total)
        If lastSlot < 0 Or lastSlot > 32767 Or lastSlot <> Fix(lastSlot) Then Err.Raise 13, "LoadBans", "Invalid ban list total: " & FileName
    End If
    ' Total is the highest allocated slot, not the number of active bans.
    MAX_BANS = CLng(lastSlot)
    ReDim Ban(0 To MAX_BANS) As BanRec
    For I = 0 To MAX_BANS
        Ban(I).BannedIP = GetVar(FileName, "Ban" & I, "BannedIP")
        Ban(I).BannedChar = GetVar(FileName, "Ban" & I, "BannedChar")
        Ban(I).BannedBy = GetVar(FileName, "Ban" & I, "BannedBy")
        Ban(I).BannedHD = GetVar(FileName, "Ban" & I, "BannedHD")
    Next I
    If Len(total) = 0 Then PutVar FileName, "Total", "Total", CStr(MAX_BANS)
End Sub

Sub SaveBan(ByVal BanNum As Long)
    Dim FileName As String
    FileName = BanListFile()
    Call PutVar(FileName, "Ban" & BanNum, "BannedIP", Ban(BanNum).BannedIP)
    Call PutVar(FileName, "Ban" & BanNum, "BannedChar", Ban(BanNum).BannedChar)
    Call PutVar(FileName, "Ban" & BanNum, "BannedBy", Ban(BanNum).BannedBy)
    Call PutVar(FileName, "Ban" & BanNum, "BannedHD", Ban(BanNum).BannedHD)
    Call PutVar(FileName, "Total", "Total", CStr(MAX_BANS))
End Sub
