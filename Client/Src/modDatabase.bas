Attribute VB_Name = "modDatabase"
Option Explicit

Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationname As String, ByVal lpKeyname As Any, ByVal lpString As String, ByVal lpFileName As String) As Long
Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationname As String, ByVal lpKeyname As Any, ByVal lpdefault As String, ByVal lpreturnedstring As String, ByVal nsize As Long, ByVal lpFileName As String) As Long

Public Function FileExist(ByVal FileName As String, Optional RAW As Boolean = False) As Boolean
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Optimized function.
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

Public Sub AddLog(ByVal Text As String)
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Added log constants.
' ****************************************************************

    Dim FileName As String
    Dim F As Long

    If Trim$(Command) = "-debug" Then
        If frmDebug.Visible = False Then
            frmDebug.Visible = True
        End If

        FileName = App.Path & LOG_PATH & LOG_DEBUG

        If Not FileExist(LOG_DEBUG, True) Then
            F = FreeFile
            Open FileName For Output As #F
            Close #F
        End If

        F = FreeFile
        Open FileName For Append As #F
        Print #F, Time & ": " & Text
        Close #F
    End If
End Sub

Public Sub SaveLocalMap(ByVal MapNum As Long)
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Added map constants.
' ****************************************************************

    Dim FileName As String
    Dim F As Long

    FileName = App.Path & MAP_PATH & "map" & MapNum & MAP_EXT

    F = FreeFile
    Open FileName For Binary As #F
    Put #F, , SaveMap
    Close #F
End Sub

Public Sub LoadMap(ByVal MapNum As Long)
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Added map constants.
' ****************************************************************

    Dim FileName As String
    Dim F As Long

    FileName = App.Path & MAP_PATH & "map" & MapNum & MAP_EXT

    F = FreeFile
    Open FileName For Binary As #F
    Get #F, , SaveMap
    Close #F
End Sub

Public Function GetMapRevision(ByVal MapNum As Long) As Long
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Added map constants.
' ****************************************************************

    Dim FileName As String
    Dim F As Long
    Dim TmpMap As MapRec

    FileName = App.Path & MAP_PATH & "map" & MapNum & MAP_EXT

    F = FreeFile
    Open FileName For Binary As #F
    Get #F, , TmpMap
    Close #F

    GetMapRevision = TmpMap.Revision
End Function

Public Function GetHDSerial(Optional ByVal DriveLetter As String) As Long
    Dim fso As Object, Drv As Object, DriveSerial As Long

    ' Create a FileSystemObject object
    Set fso = CreateObject("Scripting.FileSystemObject")

    ' Assign the current drive letter if not specified
    If DriveLetter <> vbNullString Then
        Set Drv = fso.GetDrive(DriveLetter)
    Else
        Set Drv = fso.GetDrive(fso.GetDriveName(App.Path))
    End If

    With Drv
        If .IsReady Then
            DriveSerial = Abs(.SerialNumber)
        Else                       ' "Drive Not Ready!"
            DriveSerial = -1
        End If
    End With

    ' Clean up
    Set Drv = Nothing
    Set fso = Nothing

    GetHDSerial = DriveSerial
End Function

Public Function GetMap(ByVal MapNum As Long) As MapRec
    Dim FileName As String
    Dim F As Long

    FileName = App.Path & MAP_PATH & "map" & MapNum & MAP_EXT

    F = FreeFile
    Open FileName For Binary As #F
    Get #F, , GetMap
    Close #F
End Function

Function GetVar(File As String, Header As String, Var As String) As String
    Dim sSpaces As String          ' Max string length
    Dim szReturn As String         ' Return default value if not found

    szReturn = vbNullString

    sSpaces = Space(5000)

    Call GetPrivateProfileString(Header, Var, szReturn, sSpaces, Len(sSpaces), File)

    GetVar = RTrim$(sSpaces)
    GetVar = Left$(GetVar, Len(GetVar) - 1)
End Function

Sub PutVar(File As String, Header As String, Var As String, Value As String)
    Call WritePrivateProfileString(Header, Var, Value, File)
End Sub


Sub ClearTempTile()
    Dim X As Long, Y As Long

    For Y = 0 To MAX_MAPY
        For X = 0 To MAX_MAPX
            TempTile(X, Y).DoorOpen = NO
        Next X
    Next Y
End Sub

Sub ClearPlayer(ByVal index As Long)
    Dim i As Long
    Dim n As Long

    Player(index).name = vbNullString
    Player(index).Class = 0
    Player(index).Level = 0
    Player(index).Sprite = 0
    Player(index).Exp = 0
    Player(index).Access = 0
    Player(index).PK = NO

    Player(index).HP = 0
    Player(index).MP = 0
    Player(index).SP = 0

    Player(index).STR = 0
    Player(index).DEF = 0
    Player(index).speed = 0
    Player(index).MAGI = 0

    For n = 1 To MAX_INV
        Player(index).Inv(n).Num = 0
        Player(index).Inv(n).Value = 0
        Player(index).Inv(n).Dur = 0
    Next n

    Player(index).ArmorSlot = 0
    Player(index).WeaponSlot = 0
    Player(index).HelmetSlot = 0
    Player(index).ShieldSlot = 0

    Player(index).Map = 0
    Player(index).X = 0
    Player(index).Y = 0
    Player(index).Dir = 0

    ' Client use only
    Player(index).MaxHP = 0
    Player(index).MaxMP = 0
    Player(index).MaxSP = 0
    Player(index).XOffset = 0
    Player(index).YOffset = 0
    Player(index).Moving = 0
    Player(index).Attacking = 0
    Player(index).AttackTimer = 0
    Player(index).MapGetTimer = 0
    Player(index).CastedSpell = NO
End Sub

Sub ClearItem(ByVal index As Long)
    Item(index).name = vbNullString

    Item(index).Type = 0
    Item(index).Data1 = 0
    Item(index).Data2 = 0
    Item(index).Data3 = 0
End Sub

Sub ClearItems()
    Dim i As Long

    For i = 1 To MAX_ITEMS
        Call ClearItem(i)
    Next i
End Sub

Sub ClearMapItem(ByVal index As Long)
    MapItem(index).Num = 0
    MapItem(index).Value = 0
    MapItem(index).Dur = 0
    MapItem(index).X = 0
    MapItem(index).Y = 0
End Sub

Sub ClearMap()
    Dim i As Long
    Dim X As Long
    Dim Y As Long

    Map.name = vbNullString
    Map.Revision = 0
    Map.Moral = 0
    Map.Up = 0
    Map.Down = 0
    Map.Left = 0
    Map.Right = 0

    For Y = 0 To MAX_MAPY
        For X = 0 To MAX_MAPX
            Map.Tile(X, Y).Ground = 0
            Map.Tile(X, Y).Mask = 0
            Map.Tile(X, Y).Anim = 0
            Map.Tile(X, Y).Mask2 = 0
            Map.Tile(X, Y).M2Anim = 0
            Map.Tile(X, Y).Fringe = 0
            Map.Tile(X, Y).FAnim = 0
            Map.Tile(X, Y).Fringe2 = 0
            Map.Tile(X, Y).F2Anim = 0
            Map.Tile(X, Y).Type = 0
            Map.Tile(X, Y).Data1 = 0
            Map.Tile(X, Y).Data2 = 0
            Map.Tile(X, Y).Data3 = 0
        Next X
    Next Y
End Sub

Sub ClearMapItems()
    Dim X As Long

    For X = 1 To MAX_MAP_ITEMS
        Call ClearMapItem(X)
    Next X
End Sub

Sub ClearMapNpc(ByVal index As Long)
    MapNpc(index).Num = 0
    MapNpc(index).Target = 0
    MapNpc(index).HP = 0
    MapNpc(index).MP = 0
    MapNpc(index).SP = 0
    MapNpc(index).Map = 0
    MapNpc(index).X = 0
    MapNpc(index).Y = 0
    MapNpc(index).Dir = 0

    ' Client use only
    MapNpc(index).XOffset = 0
    MapNpc(index).YOffset = 0
    MapNpc(index).Moving = 0
    MapNpc(index).Attacking = 0
    MapNpc(index).AttackTimer = 0
End Sub

Sub ClearMapNpcs()
    Dim i As Long

    For i = 1 To MAX_MAP_NPCS
        Call ClearMapNpc(i)
    Next i
End Sub






' //////////////////////
' // Player functions //
' //////////////////////

Function GetPlayerName(ByVal index As Long) As String
    GetPlayerName = Trim$(Player(index).name)
End Function

Sub SetPlayerName(ByVal index As Long, ByVal name As String)
    Player(index).name = name
End Sub

Function GetPlayerClass(ByVal index As Long) As Long
    GetPlayerClass = Player(index).Class
End Function

Sub SetPlayerClass(ByVal index As Long, ByVal ClassNum As Long)
    Player(index).Class = ClassNum
End Sub

Function GetPlayerSprite(ByVal index As Long) As Long
    GetPlayerSprite = Player(index).Sprite
End Function

Sub SetPlayerSprite(ByVal index As Long, ByVal Sprite As Long)
    Player(index).Sprite = Sprite
End Sub

Function GetPlayerLevel(ByVal index As Long) As Long
    GetPlayerLevel = Player(index).Level
End Function

Sub SetPlayerLevel(ByVal index As Long, ByVal Level As Long)
    Player(index).Level = Level
End Sub

Function GetPlayerExp(ByVal index As Long) As Long
    GetPlayerExp = Player(index).Exp
End Function

Sub SetPlayerExp(ByVal index As Long, ByVal Exp As Long)
    Player(index).Exp = Exp
End Sub

Function GetPlayerNextLevel(ByVal index As Long) As Long
    GetPlayerNextLevel = (GetPlayerLevel(index) + 1) * (GetPlayerSTR(index) + GetPlayerDEF(index) + GetPlayerMAGI(index) + GetPlayerSPEED(index) + GetPlayerPOINTS(index)) * 25
End Function

Function GetPlayerAccess(ByVal index As Long) As Long
    GetPlayerAccess = Player(index).Access
End Function

Sub SetPlayerAccess(ByVal index As Long, ByVal Access As Long)
    Player(index).Access = Access
End Sub

Function GetPlayerPK(ByVal index As Long) As Long
    GetPlayerPK = Player(index).PK
End Function

Sub SetPlayerPK(ByVal index As Long, ByVal PK As Long)
    Player(index).PK = PK
End Sub

Function GetPlayerGuild(ByVal index As Long) As Long
    GetPlayerGuild = Player(index).Guild
End Function

Function SetPlayerGuild(ByVal index As Long, ByVal Guild As Long)
    Player(index).Guild = Guild
End Function

Function GetPlayerHP(ByVal index As Long) As Long
    GetPlayerHP = Player(index).HP
End Function

Sub SetPlayerHP(ByVal index As Long, ByVal HP As Long)
    Player(index).HP = HP

    If GetPlayerHP(index) > GetPlayerMaxHP(index) Then
        Player(index).HP = GetPlayerMaxHP(index)
    End If
End Sub

Function GetPlayerMP(ByVal index As Long) As Long
    GetPlayerMP = Player(index).MP
End Function

Sub SetPlayerMP(ByVal index As Long, ByVal MP As Long)
    Player(index).MP = MP

    If GetPlayerMP(index) > GetPlayerMaxMP(index) Then
        Player(index).MP = GetPlayerMaxMP(index)
    End If
End Sub

Function GetPlayerSP(ByVal index As Long) As Long
    GetPlayerSP = Player(index).SP
End Function

Sub SetPlayerSP(ByVal index As Long, ByVal SP As Long)
    Player(index).SP = SP

    If GetPlayerSP(index) > GetPlayerMaxSP(index) Then
        Player(index).SP = GetPlayerMaxSP(index)
    End If
End Sub

Function GetPlayerMaxHP(ByVal index As Long) As Long
    GetPlayerMaxHP = Player(index).MaxHP
End Function

Function GetPlayerMaxMP(ByVal index As Long) As Long
    GetPlayerMaxMP = Player(index).MaxMP
End Function

Function GetPlayerMaxSP(ByVal index As Long) As Long
    GetPlayerMaxSP = Player(index).MaxSP
End Function

Function GetPlayerSTR(ByVal index As Long) As Long
    GetPlayerSTR = Player(index).STR
End Function

Sub SetPlayerSTR(ByVal index As Long, ByVal STR As Long)
    Player(index).STR = STR
End Sub

Function GetPlayerDEF(ByVal index As Long) As Long
    GetPlayerDEF = Player(index).DEF
End Function

Sub SetPlayerDEF(ByVal index As Long, ByVal DEF As Long)
    Player(index).DEF = DEF
End Sub

Function GetPlayerSPEED(ByVal index As Long) As Long
    GetPlayerSPEED = Player(index).speed
End Function

Sub SetPlayerSPEED(ByVal index As Long, ByVal speed As Long)
    Player(index).speed = speed
End Sub

Function GetPlayerMAGI(ByVal index As Long) As Long
    GetPlayerMAGI = Player(index).MAGI
End Function

Sub SetPlayerMAGI(ByVal index As Long, ByVal MAGI As Long)
    Player(index).MAGI = MAGI
End Sub

Function GetPlayerPOINTS(ByVal index As Long) As Long
    GetPlayerPOINTS = Player(index).POINTS
End Function

Sub SetPlayerPOINTS(ByVal index As Long, ByVal POINTS As Long)
    Player(index).POINTS = POINTS
End Sub

Function GetPlayerMap(ByVal index As Long) As Long
    GetPlayerMap = Player(index).Map
End Function

Sub SetPlayerMap(ByVal index As Long, ByVal MapNum As Long)
    Player(index).Map = MapNum
End Sub

Function GetPlayerX(ByVal index As Long) As Long
    GetPlayerX = Player(index).X
End Function

Sub SetPlayerX(ByVal index As Long, ByVal X As Long)
    Player(index).X = X
End Sub

Function GetPlayerY(ByVal index As Long) As Long
    GetPlayerY = Player(index).Y
End Function

Sub SetPlayerY(ByVal index As Long, ByVal Y As Long)
    Player(index).Y = Y
End Sub

Function GetPlayerDir(ByVal index As Long) As Long
    GetPlayerDir = Player(index).Dir
End Function

Sub SetPlayerDir(ByVal index As Long, ByVal Dir As Long)
    Player(index).Dir = Dir
End Sub

Function GetPlayerInvItemNum(ByVal index As Long, ByVal InvSlot As Long) As Long
    GetPlayerInvItemNum = Player(index).Inv(InvSlot).Num
End Function

Sub SetPlayerInvItemNum(ByVal index As Long, ByVal InvSlot As Long, ByVal ItemNum As Long)
    Player(index).Inv(InvSlot).Num = ItemNum
End Sub

Function GetPlayerInvItemValue(ByVal index As Long, ByVal InvSlot As Long) As Long
    GetPlayerInvItemValue = Player(index).Inv(InvSlot).Value
End Function

Sub SetPlayerInvItemValue(ByVal index As Long, ByVal InvSlot As Long, ByVal ItemValue As Long)
    Player(index).Inv(InvSlot).Value = ItemValue
End Sub

Function GetPlayerInvItemDur(ByVal index As Long, ByVal InvSlot As Long) As Long
    GetPlayerInvItemDur = Player(index).Inv(InvSlot).Dur
End Function

Sub SetPlayerInvItemDur(ByVal index As Long, ByVal InvSlot As Long, ByVal ItemDur As Long)
    Player(index).Inv(InvSlot).Dur = ItemDur
End Sub

Function GetPlayerArmorSlot(ByVal index As Long) As Long
    GetPlayerArmorSlot = Player(index).ArmorSlot
End Function

Sub SetPlayerArmorSlot(ByVal index As Long, InvNum As Long)
    Player(index).ArmorSlot = InvNum
End Sub

Function GetPlayerWeaponSlot(ByVal index As Long) As Long
    GetPlayerWeaponSlot = Player(index).WeaponSlot
End Function

Sub SetPlayerWeaponSlot(ByVal index As Long, InvNum As Long)
    Player(index).WeaponSlot = InvNum
End Sub

Function GetPlayerHelmetSlot(ByVal index As Long) As Long
    GetPlayerHelmetSlot = Player(index).HelmetSlot
End Function

Sub SetPlayerHelmetSlot(ByVal index As Long, InvNum As Long)
    Player(index).HelmetSlot = InvNum
End Sub

Function GetPlayerShieldSlot(ByVal index As Long) As Long
    GetPlayerShieldSlot = Player(index).ShieldSlot
End Function

Sub SetPlayerShieldSlot(ByVal index As Long, InvNum As Long)
    Player(index).ShieldSlot = InvNum
End Sub

