Attribute VB_Name = "modDirectX"
Option Explicit

Private Const TILESET_COLUMNS As Long = 12

Public Sub InitDirectX()
    DestroyDirectX
    DX11Initialize frmMainGame.picScreen.hWnd
    InitSurfaces
End Sub

Private Function NewSurface(ByVal Width As Long, ByVal Height As Long) As clsDX11Surface
    Dim Surface As New clsDX11Surface
    Surface.Create Width, Height
    Set NewSurface = Surface
End Function

Private Function LoadSurface(ByVal FileName As String) As clsDX11Surface
    Dim Surface As New clsDX11Surface
    Surface.LoadFromFile FileName
    Surface.ColorKey = 0
    Set LoadSurface = Surface
End Function

Public Sub InitSurfaces()
    Dim Prefix As String
    Dim i As Long
    Prefix = App.Path & GFX_PATH
    Set DD_BackBuffer = NewSurface((MAX_MAPX + 1) * PIC_X, (MAX_MAPY + 1) * PIC_Y)
    Set DD_LowerBuffer = NewSurface(DD_BackBuffer.Width, DD_BackBuffer.Height)
    Set DD_MiddleBuffer = NewSurface(DD_BackBuffer.Width, DD_BackBuffer.Height)
    Set DD_UpperBuffer = NewSurface(DD_BackBuffer.Width, DD_BackBuffer.Height)
    Set DD_SpriteSurf = LoadSurface(Prefix & "sprites" & GFX_EXT)
    For i = 1 To 6
        Set DD_TileSurf(i) = LoadSurface(Prefix & "tiles" & i & GFX_EXT)
    Next
    Set DD_ItemSurf = LoadSurface(Prefix & "items" & GFX_EXT)
    DD_ItemSurf.ColorKey = RGB(255, 255, 255)
    Set DD_SpellSurf = LoadSurface(Prefix & "spells" & GFX_EXT)
    Set DD_ArrowSurf = LoadSurface(Prefix & "arrows" & GFX_EXT)
End Sub

Public Sub DestroyDirectX()
    Dim i As Long
    
    Set DD_SpriteSurf = Nothing
    For i = 1 To 6
        Set DD_TileSurf(i) = Nothing
    Next
    Set DD_ItemSurf = Nothing
    Set DD_SpellSurf = Nothing
    Set DD_ArrowSurf = Nothing
    Set DD_BackBuffer = Nothing
    Set DD_LowerBuffer = Nothing
    Set DD_MiddleBuffer = Nothing
    Set DD_UpperBuffer = Nothing
    DX11Shutdown
End Sub

Public Function NeedToRestoreSurfaces() As Boolean
    NeedToRestoreSurfaces = DX11DeviceLost()
End Function

Public Sub CheckSurfaces()
    If NeedToRestoreSurfaces Then
        InitDirectX
        If Not GettingMap Then BltMap
    End If
End Sub

Public Sub PresentGameFrame()
    On Error GoTo Failed
    DX11Present DD_BackBuffer
    Exit Sub
Failed:
    Dim ErrorNumber As Long, ErrorText As String
    ErrorNumber = Err.Number
    ErrorText = Err.Description
    If DX11DeviceLost Then
        CheckSurfaces
    Else
        Err.Raise ErrorNumber, "Direct3D 11 presentation", ErrorText
    End If
End Sub

Public Sub SetMaskColorFromPixel(ByRef TheSurface As clsDX11Surface, ByVal X As Long, ByVal Y As Long)
    TheSurface.ColorKey = TheSurface.PixelColor(X, Y)
End Sub


Public Sub BltMap()
    Dim Ground As Long
    Dim Anim1 As Long
    Dim Anim2 As Long
    Dim Mask2 As Long
    Dim M2Anim As Long
    Dim Fringe As Long
    Dim FAnim As Long
    Dim Fringe2 As Long
    Dim F2Anim As Long
    Dim X As Long, Y As Long

    If Map.Tileset = 0 Then Exit Sub

    rec.Top = 0
    rec.Bottom = (MAX_MAPY + 1) * 32
    rec.Left = 0
    rec.Right = (MAX_MAPX + 1) * 32

    DD_LowerBuffer.BltColorFill rec, RGB(0, 0, 0)
    DD_UpperBuffer.BltColorFill rec, RGB(0, 0, 0)

    For X = 0 To MAX_MAPX
        For Y = 0 To MAX_MAPY

            With Map.Tile(X, Y)
                Ground = .Ground
                Anim1 = .Mask
                Anim2 = .Anim
                Mask2 = .Mask2
                M2Anim = .M2Anim
                Fringe = .Fringe
                FAnim = .FAnim
                Fringe2 = .Fringe2
                F2Anim = .F2Anim
            End With

            ' Ground
            rec.Left = (Ground Mod TILESET_COLUMNS) * PIC_X
            rec.Top = (Ground \ TILESET_COLUMNS) * PIC_Y
            rec.Right = rec.Left + PIC_X
            rec.Bottom = rec.Top + PIC_Y

            DD_LowerBuffer.BltFast _
                X * PIC_X, _
                Y * PIC_Y, _
                DD_TileSurf(Map.Tileset), _
                rec, _
                False

            ' Mask / Anim
            If (MapAnim = 0) Or (Anim2 <= 0) Then

                If Anim1 > 0 And TempTile(X, Y).DoorOpen = NO Then
                    rec.Left = (Anim1 Mod TILESET_COLUMNS) * PIC_X
                    rec.Top = (Anim1 \ TILESET_COLUMNS) * PIC_Y
                    rec.Right = rec.Left + PIC_X
                    rec.Bottom = rec.Top + PIC_Y

                    DD_LowerBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        DD_TileSurf(Map.Tileset), _
                        rec, _
                        True
                End If

            Else

                If Anim2 > 0 Then
                    rec.Left = (Anim2 Mod TILESET_COLUMNS) * PIC_X
                    rec.Top = (Anim2 \ TILESET_COLUMNS) * PIC_Y
                    rec.Right = rec.Left + PIC_X
                    rec.Bottom = rec.Top + PIC_Y

                    DD_LowerBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        DD_TileSurf(Map.Tileset), _
                        rec, _
                        True
                End If

            End If

            ' Mask2 / M2Anim
            If (MapAnim = 0) Or (M2Anim <= 0) Then

                If Mask2 > 0 Then
                    rec.Left = (Mask2 Mod TILESET_COLUMNS) * PIC_X
                    rec.Top = (Mask2 \ TILESET_COLUMNS) * PIC_Y
                    rec.Right = rec.Left + PIC_X
                    rec.Bottom = rec.Top + PIC_Y

                    DD_LowerBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        DD_TileSurf(Map.Tileset), _
                        rec, _
                        True
                End If

            Else

                If M2Anim > 0 Then
                    rec.Left = (M2Anim Mod TILESET_COLUMNS) * PIC_X
                    rec.Top = (M2Anim \ TILESET_COLUMNS) * PIC_Y
                    rec.Right = rec.Left + PIC_X
                    rec.Bottom = rec.Top + PIC_Y

                    DD_LowerBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        DD_TileSurf(Map.Tileset), _
                        rec, _
                        True
                End If

            End If

            ' Fringe / FAnim
            If (MapAnim = 0) Or (FAnim <= 0) Then

                If Fringe > 0 Then
                    rec.Left = (Fringe Mod TILESET_COLUMNS) * PIC_X
                    rec.Top = (Fringe \ TILESET_COLUMNS) * PIC_Y
                    rec.Right = rec.Left + PIC_X
                    rec.Bottom = rec.Top + PIC_Y

                    DD_UpperBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        DD_TileSurf(Map.Tileset), _
                        rec, _
                        True
                End If

            Else

                If FAnim > 0 Then
                    rec.Left = (FAnim Mod TILESET_COLUMNS) * PIC_X
                    rec.Top = (FAnim \ TILESET_COLUMNS) * PIC_Y
                    rec.Right = rec.Left + PIC_X
                    rec.Bottom = rec.Top + PIC_Y

                    DD_UpperBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        DD_TileSurf(Map.Tileset), _
                        rec, _
                        True
                End If

            End If

            ' Fringe2 / F2Anim
            If (MapAnim = 0) Or (F2Anim <= 0) Then

                If Fringe2 > 0 Then
                    rec.Left = (Fringe2 Mod TILESET_COLUMNS) * PIC_X
                    rec.Top = (Fringe2 \ TILESET_COLUMNS) * PIC_Y
                    rec.Right = rec.Left + PIC_X
                    rec.Bottom = rec.Top + PIC_Y

                    DD_UpperBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        DD_TileSurf(Map.Tileset), _
                        rec, _
                        True
                End If

            Else

                If F2Anim > 0 Then
                    rec.Left = (F2Anim Mod TILESET_COLUMNS) * PIC_X
                    rec.Top = (F2Anim \ TILESET_COLUMNS) * PIC_Y
                    rec.Right = rec.Left + PIC_X
                    rec.Bottom = rec.Top + PIC_Y

                    DD_UpperBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        DD_TileSurf(Map.Tileset), _
                        rec, _
                        True
                End If

            End If

        Next Y
    Next X
End Sub

Public Sub BltItem(ByVal ItemNum As Long)
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Optimized function.
' ****************************************************************

    ' Only used if ever want to switch to blt rather then bltfast
    With rec_pos
        .Top = MapItem(ItemNum).Y * PIC_Y
        .Bottom = .Top + PIC_Y
        .Left = MapItem(ItemNum).X * PIC_X
        .Right = .Left + PIC_X
    End With

    Call GetItemPictureRect(Item(MapItem(ItemNum).Num).Pic, rec)

    Call DD_MiddleBuffer.BltFast(MapItem(ItemNum).X * PIC_X, MapItem(ItemNum).Y * PIC_Y, DD_ItemSurf, rec, True)
End Sub

Public Sub BltPlayer(ByVal index As Long)
    ' ****************************************************************
    ' * WHEN    WHO    WHAT
    ' * ----    ---    ----
    ' * 07/12/2005  Shannara   Optimized function.
    ' ****************************************************************
    Dim X As Long, Y As Long

    ' Check for player(index).animation
    If Player(index).Attacking = 0 Then
        ' Use positive pixel remainders for walking frames in every direction.
        Player(index).Anim = ((Player(index).XOffset + Player(index).YOffset) \ 8) Mod 3
    Else
        If Player(index).AttackTimer + 500 > GetTickCount Then
            Player(index).Anim = 2
        End If
    End If

    ' Check to see if we want to stop making him attack
    With Player(index)
        If .AttackTimer + 1000 < GetTickCount Then
            .Attacking = 0
            .AttackTimer = 0
        End If
    End With

    With rec
        .Top = (GetPlayerSprite(index) * GameData.PlayerY)
        .Bottom = .Top + PIC_Y * 2
        .Left = (GetPlayerDir(index) * 3 + Player(index).Anim) * (GameData.PlayerX + 16)
        .Right = .Left + (GameData.PlayerX + 16)
    End With

    If GameData.PlayerX > 48 Then
        X = (GetPlayerX(index) * PIC_X) + (Player(index).XOffset) - (GameData.PlayerX / 4)
    Else
        X = (GetPlayerX(index) * PIC_X) + (Player(index).XOffset)
    End If
    Y = (GetPlayerY(index) * PIC_Y) + (Player(index).YOffset)

    ' Check if its out of bounds because of the offset
    If Y < 0 Then
        Y = 0
        With rec
            .Top = .Top + (Y * -1)
        End With
    End If

    Call DD_MiddleBuffer.BltFast(X, Y, DD_SpriteSurf, rec, True)
End Sub

Public Sub BltPlayerTop(ByVal index As Long)
    Dim X As Long, Y As Long

    With rec
        .Top = (GetPlayerSprite(index) * GameData.PlayerY) - GameData.PlayerY
        .Bottom = .Top + (GameData.PlayerY - 32)
        .Left = (GetPlayerDir(index) * 3 + Player(index).Anim) * GameData.PlayerX
        .Right = .Left + GameData.PlayerX
    End With

    If GameData.PlayerX > 32 Then
        X = (GetPlayerX(index) * PIC_X) + (Player(index).XOffset) - (GameData.PlayerX / 4)
    Else
        X = (GetPlayerX(index) * PIC_X) + (Player(index).XOffset)
    End If
    Y = (GetPlayerY(index) * PIC_Y) + (Player(index).YOffset)

    Y = Y - (GameData.PlayerY - 32)

    ' Check if its out of bounds because of the offset
    If Y < 0 Then
        Y = 0
        With rec
            .Top = .Top + (Y * -1)
        End With
    End If

    Call DD_MiddleBuffer.BltFast(X, Y, DD_SpriteSurf, rec, True)
End Sub

Public Sub SpellEditorBltAnim(ByVal Frame As Byte)
    Call BitBlt(frmSpellEditor.picAnim.hDC, 0, 0, PIC_X, PIC_Y, frmSpellEditor.picSpells.hDC, Frame * PIC_X, frmSpellEditor.scrlAnim.Value * PIC_Y, SRCCOPY)
End Sub

Sub BltSpell(ByVal VicX As Long, ByVal VicY As Long, ByVal SpellAnim As Byte)
    If SpellVar > 13 Then
        Exit Sub
    End If
    ' Change Spell Animation Every 250 miliseconds
    If GetTickCount > SpellAnimTimer + 75 Then
        If SpellVar > 13 Then
            SpellVar = 0
            Exit Sub
        Else
            SpellVar = SpellVar + 1
        End If
        SpellAnimTimer = GetTickCount
    End If

    ' 32x32 Spells
    rec.Top = SpellAnim * PIC_Y
    rec.Bottom = rec.Top + PIC_Y
    rec.Left = SpellVar * PIC_X
    rec.Right = rec.Left + PIC_X

    ' 32x32 spells
    Call DD_MiddleBuffer.BltFast(VicX * PIC_X, VicY * PIC_Y, DD_SpellSurf, rec, True)
End Sub

Public Sub BltNpc(ByVal MapNpcNum As Long)
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Optimized function.
' ****************************************************************

    Dim Anim As Byte
    Dim X As Long, Y As Long

    ' Make sure that theres an npc there, and if not exit the sub
    If MapNpc(MapNpcNum).Num <= 0 Then
        Exit Sub
    End If

    ' Only used if ever want to switch to blt rather then bltfast
    With rec_pos
        .Top = MapNpc(MapNpcNum).Y * PIC_Y + MapNpc(MapNpcNum).YOffset
        .Bottom = .Top + PIC_Y
        .Left = MapNpc(MapNpcNum).X * PIC_X + MapNpc(MapNpcNum).XOffset
        .Right = .Left + PIC_X
    End With

    ' Check for animation
    Anim = 0
    If MapNpc(MapNpcNum).Attacking = 0 Then
        Select Case MapNpc(MapNpcNum).Dir
            Case DIR_UP
                If (MapNpc(MapNpcNum).YOffset < PIC_Y / 2) Then Anim = 1
            Case DIR_DOWN
                If (MapNpc(MapNpcNum).YOffset < PIC_Y / 2 * -1) Then Anim = 1
            Case DIR_LEFT
                If (MapNpc(MapNpcNum).XOffset < PIC_Y / 2) Then Anim = 1
            Case DIR_RIGHT
                If (MapNpc(MapNpcNum).XOffset < PIC_Y / 2 * -1) Then Anim = 1
        End Select
    Else
        If MapNpc(MapNpcNum).AttackTimer + 500 > GetTickCount Then
            Anim = 2
        End If
    End If

    ' Check to see if we want to stop making him attack
    With MapNpc(MapNpcNum)
        If .AttackTimer + 1000 < GetTickCount Then
            .Attacking = 0
            .AttackTimer = 0
        End If
    End With

    With rec
        .Top = Npc(MapNpc(MapNpcNum).Num).Sprite * PIC_Y
        .Bottom = .Top + PIC_Y
        .Left = (MapNpc(MapNpcNum).Dir * 3 + Anim) * PIC_X
        .Right = .Left + PIC_X
    End With

    With MapNpc(MapNpcNum)
        X = .X * PIC_X + .XOffset
        Y = .Y * PIC_Y + .YOffset - 4
    End With

    ' Check if its out of bounds because of the offset
    If Y < 0 Then
        Y = 0
        With rec
            .Top = .Top + (Y * -1)
        End With
    End If

    Call DD_MiddleBuffer.BltFast(X, Y, DD_SpriteSurf, rec, True)
End Sub




' Item pictures are zero-based, ordered left to right across six columns.
Public Sub GetItemPictureRect(ByVal Picture As Long, ByRef Source As RECT)
    Source.Left = (Picture Mod 6) * PIC_X
    Source.Top = (Picture \ 6) * PIC_Y
    Source.Right = Source.Left + PIC_X
    Source.Bottom = Source.Top + PIC_Y
End Sub