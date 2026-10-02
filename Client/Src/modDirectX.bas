Attribute VB_Name = "modDirectX"
Option Explicit

Private SpriteFrameWidths() As Long
Private SpriteFrameHeights() As Long
Private SpriteFrameTops() As Long
Public SpriteFrameCount As Long

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
    TilesetCount = 0
    Prefix = App.Path & GFX_PATH
    Set DD_BackBuffer = NewSurface((MAX_MAPX + 1) * PIC_X, (MAX_MAPY + 1) * PIC_Y)
    Set DD_LowerBuffer = NewSurface(DD_BackBuffer.Width, DD_BackBuffer.Height)
    Set DD_MiddleBuffer = NewSurface(DD_BackBuffer.Width, DD_BackBuffer.Height)
    Set DD_UpperBuffer = NewSurface(DD_BackBuffer.Width, DD_BackBuffer.Height)
    Set DD_SpriteSurf = LoadSurface(Prefix & "sprites" & GFX_EXT)
    InitSpriteFrames Prefix & "sprites.ini"
    For i = 1 To 255
        If Len(Dir$(Prefix & "tiles" & i & GFX_EXT)) > 0 Then
            Set DD_TileSurf(i) = LoadSurface(Prefix & "tiles" & i & GFX_EXT)
            TilesetCount = i
        End If
    Next
    Set DD_ItemSurf = LoadSurface(Prefix & "items" & GFX_EXT)
    DD_ItemSurf.ColorKey = RGB(255, 255, 255)
    Set DD_SpellSurf = LoadSurface(Prefix & "spells" & GFX_EXT)
    Set DD_ArrowSurf = LoadSurface(Prefix & "arrows" & GFX_EXT)
    InitSpriteOverlays
End Sub

Public Sub DestroyDirectX()
    Dim i As Long
    
    DestroySpriteOverlays
    Set DD_SpriteSurf = Nothing
    SpriteFrameCount = 0
    For i = 1 To 255
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
            GetMapTileRect X, Y, 0, Ground, rec

            DD_LowerBuffer.BltFast _
                X * PIC_X, _
                Y * PIC_Y, _
                MapTileSurface(X, Y, 0), _
                rec, _
                False

            ' Mask / Anim
            If (MapAnim = 0) Or (Anim2 <= 0) Then

                If Anim1 > 0 And TempTile(X, Y).DoorOpen = NO Then
                    GetMapTileRect X, Y, 1, Anim1, rec

                    DD_LowerBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        MapTileSurface(X, Y, 1), _
                        rec, _
                        True
                End If

            Else

                If Anim2 > 0 Then
                    GetMapTileRect X, Y, 2, Anim2, rec

                    DD_LowerBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        MapTileSurface(X, Y, 2), _
                        rec, _
                        True
                End If

            End If

            ' Mask2 / M2Anim
            If (MapAnim = 0) Or (M2Anim <= 0) Then

                If Mask2 > 0 Then
                    GetMapTileRect X, Y, 3, Mask2, rec

                    DD_LowerBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        MapTileSurface(X, Y, 3), _
                        rec, _
                        True
                End If

            Else

                If M2Anim > 0 Then
                    GetMapTileRect X, Y, 4, M2Anim, rec

                    DD_LowerBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        MapTileSurface(X, Y, 4), _
                        rec, _
                        True
                End If

            End If

            ' Fringe / FAnim
            If (MapAnim = 0) Or (FAnim <= 0) Then

                If Fringe > 0 Then
                    GetMapTileRect X, Y, 5, Fringe, rec

                    DD_UpperBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        MapTileSurface(X, Y, 5), _
                        rec, _
                        True
                End If

            Else

                If FAnim > 0 Then
                    GetMapTileRect X, Y, 6, FAnim, rec

                    DD_UpperBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        MapTileSurface(X, Y, 6), _
                        rec, _
                        True
                End If

            End If

            ' Fringe2 / F2Anim
            If (MapAnim = 0) Or (F2Anim <= 0) Then

                If Fringe2 > 0 Then
                    GetMapTileRect X, Y, 7, Fringe2, rec

                    DD_UpperBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        MapTileSurface(X, Y, 7), _
                        rec, _
                        True
                End If

            Else

                If F2Anim > 0 Then
                    GetMapTileRect X, Y, 8, F2Anim, rec

                    DD_UpperBuffer.BltFast _
                        X * PIC_X, _
                        Y * PIC_Y, _
                        MapTileSurface(X, Y, 8), _
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
    Dim X As Long
    Dim Y As Long

    If Player(index).Attacking = 0 Then
        Player(index).Anim = Abs(((Player(index).XOffset + Player(index).YOffset) \ 8) Mod 3)
    Else
        If Player(index).AttackTimer + 500 > GetTickCount Then
            Player(index).Anim = 2
        End If
    End If

    With Player(index)
        If .AttackTimer + 1000 < GetTickCount Then
            .Attacking = 0
            .AttackTimer = 0
        End If
    End With

    If Not GetSpriteFrameRect(GetPlayerSprite(index), GetPlayerDir(index), Player(index).Anim, rec) Then Exit Sub
    GetSpriteDrawPosition GetPlayerSprite(index), GetPlayerPixelX(index), GetPlayerPixelY(index), X, Y
    DD_MiddleBuffer.BltFast X, Y, DD_SpriteSurf, rec, True
End Sub

' Full frames are drawn once in Y order; there is no separate top pass.
Public Sub BltPlayerTop(ByVal index As Long)
End Sub

' Sprite rows contain twelve frames (four directions, three animation frames).
' Width defaults to 48, height to 64 (the bundled sheet has right padding).
' Optional sprites.ini
' overrides [Sprites] Width/Height and [Sprite0], [Sprite1], ... Width/Height.

Private Sub InitSpriteFrames(ByVal FileName As String)
    Dim DefaultWidth As Long, DefaultHeight As Long, Width As Long, Height As Long
    Dim Top As Long, Section As String
    DefaultWidth = 48
    DefaultHeight = 64
    Width = Val(GetVar(FileName, "Sprites", "Width"))
    Height = Val(GetVar(FileName, "Sprites", "Height"))
    If Width > 0 Then DefaultWidth = Width
    If Height > 0 Then DefaultHeight = Height
    If DefaultWidth < 1 Or DefaultWidth * 12 > DD_SpriteSurf.Width Or DefaultHeight < 1 Then Err.Raise 5, "Sprites", "Invalid default sprite dimensions."
    ReDim SpriteFrameWidths(0 To DD_SpriteSurf.Height - 1)
    ReDim SpriteFrameHeights(0 To DD_SpriteSurf.Height - 1)
    ReDim SpriteFrameTops(0 To DD_SpriteSurf.Height - 1)
    SpriteFrameCount = 0
    Do While Top < DD_SpriteSurf.Height
        Section = "Sprite" & CStr(SpriteFrameCount)
        Width = Val(GetVar(FileName, Section, "Width"))
        Height = Val(GetVar(FileName, Section, "Height"))
        If Width = 0 Then Width = DefaultWidth
        If Height = 0 Then Height = DefaultHeight
        If Width < 1 Or Width * 12 > DD_SpriteSurf.Width Or Height < 1 Or Top + Height > DD_SpriteSurf.Height Then Err.Raise 5, "Sprites", "Invalid frame dimensions for " & Section
        SpriteFrameWidths(SpriteFrameCount) = Width
        SpriteFrameHeights(SpriteFrameCount) = Height
        SpriteFrameTops(SpriteFrameCount) = Top
        Top = Top + Height
        SpriteFrameCount = SpriteFrameCount + 1
    Loop
End Sub

Public Function GetSpriteFrameRect(ByVal Sprite As Long, ByVal Direction As Long, ByVal Frame As Long, ByRef Source As RECT) As Boolean
    If DD_SpriteSurf Is Nothing Then Exit Function
    If Sprite < 0 Or Sprite >= SpriteFrameCount Then Exit Function
    If Direction < 0 Or Direction > 3 Or Frame < 0 Or Frame > 2 Then Exit Function
    Source.Left = (Direction * 3 + Frame) * SpriteFrameWidths(Sprite)
    Source.Top = SpriteFrameTops(Sprite)
    Source.Right = Source.Left + SpriteFrameWidths(Sprite)
    Source.Bottom = Source.Top + SpriteFrameHeights(Sprite)
    GetSpriteFrameRect = True
End Function

Public Sub GetSpriteDimensions(ByVal Sprite As Long, ByRef Width As Long, ByRef Height As Long)
    Width = PIC_X: Height = PIC_Y
    If Sprite < 0 Or Sprite >= SpriteFrameCount Then Exit Sub
    Width = SpriteFrameWidths(Sprite)
    Height = SpriteFrameHeights(Sprite)
End Sub

Public Sub GetSpriteDrawPosition(ByVal Sprite As Long, ByVal PixelX As Long, ByVal PixelY As Long, ByRef X As Long, ByRef Y As Long)
    Dim Width As Long, Height As Long
    GetSpriteDimensions Sprite, Width, Height
    X = PixelX - (Width - PIC_X) \ 2
    ' A 64-pixel frame starts at PixelY + 48 after the additional 32-pixel shift.
    ' All frame heights share the same feet anchor.
    Y = GetSpriteFeetY(PixelY) - Height
    ' Clip at the buffer edges instead of moving the sprite away from its tile.
End Sub

Public Function GetSpriteFeetY(ByVal PixelY As Long) As Long
    GetSpriteFeetY = PixelY + PIC_Y * 2 + PIC_Y \ 2 + 32
End Function

Public Sub BltYSortedSprites()
    Dim Indices() As Long, Depths() As Long, IsNpc() As Boolean
    Dim Count As Long, I As Long, J As Long, Index As Long, Depth As Long, NpcEntry As Boolean
    ReDim Indices(1 To MAX_MAP_NPCS + HighIndex)
    ReDim Depths(1 To MAX_MAP_NPCS + HighIndex)
    ReDim IsNpc(1 To MAX_MAP_NPCS + HighIndex)
    For I = 1 To MAX_MAP_NPCS
        If MapNpc(I).Num > 0 Then
            Count = Count + 1
            Indices(Count) = I
            Depths(Count) = GetSpriteFeetY(CLng(MapNpc(I).Y) * PIC_Y + MapNpc(I).YOffset)
            IsNpc(Count) = True
        End If
    Next I
    For I = 1 To HighIndex
        If IsPlaying(I) And GetPlayerMap(I) = GetPlayerMap(MyIndex) Then
            Count = Count + 1
            Indices(Count) = I
            Depths(Count) = GetSpriteFeetY(GetPlayerPixelY(I))
        End If
    Next I
    ' Stable insertion sort keeps equal-depth sprites from flickering.
    For I = 2 To Count
        Index = Indices(I): Depth = Depths(I): NpcEntry = IsNpc(I)
        J = I - 1
        Do While J >= 1
            If Depths(J) <= Depth Then Exit Do
            Indices(J + 1) = Indices(J): Depths(J + 1) = Depths(J): IsNpc(J + 1) = IsNpc(J)
            J = J - 1
        Loop
        Indices(J + 1) = Index: Depths(J + 1) = Depth: IsNpc(J + 1) = NpcEntry
    Next I
    For I = 1 To Count
        If IsNpc(I) Then
            BltNPC Indices(I)
        Else
            BltPlayer Indices(I)
        End If
    Next I
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

Public Sub BltNPC(ByVal index As Long)
    Dim X As Long
    Dim Y As Long
    Dim AnimFrame As Long
    Dim Direction As Long
    Dim SpriteNum As Long

    If MapNpc(index).Num <= 0 Then Exit Sub

    ' Walking animation
    AnimFrame = _
        ((CLng(MapNpc(index).XOffset) + CLng(MapNpc(index).YOffset)) \ 8) Mod 3

    If AnimFrame < 0 Then
        AnimFrame = -AnimFrame
    End If

    MapNpc(index).Anim = AnimFrame

    SpriteNum = CLng(Npc(MapNpc(index).Num).Sprite)
    Direction = CLng(MapNpc(index).Dir)
    If Not GetSpriteFrameRect(SpriteNum, Direction, AnimFrame, rec) Then Exit Sub
    GetSpriteDrawPosition SpriteNum, CLng(MapNpc(index).X) * PIC_X + MapNpc(index).XOffset, CLng(MapNpc(index).Y) * PIC_Y + MapNpc(index).YOffset, X, Y
    DD_MiddleBuffer.BltFast X, Y, DD_SpriteSurf, rec, True
End Sub
' Item pictures are zero-based, ordered left to right across six columns.
Public Sub GetItemPictureRect(ByVal Picture As Long, ByRef Source As RECT)
    Source.Left = (Picture Mod 6) * PIC_X
    Source.Top = (Picture \ 6) * PIC_Y
    Source.Right = Source.Left + PIC_X
    Source.Bottom = Source.Top + PIC_Y
End Sub
Private Function MapTileSurface(ByVal X As Long, ByVal Y As Long, ByVal Layer As Long) As clsDX11Surface
    Dim tileset As Long
    tileset = Map.LayerTileset(X, Y, Layer)
    If tileset = 0 Then tileset = Map.Tileset
    If tileset < 1 Or tileset > 255 Then tileset = 1
    If DD_TileSurf(tileset) Is Nothing Then tileset = 1
    Set MapTileSurface = DD_TileSurf(tileset)
End Function

Public Function TilesetColumns(ByVal Tileset As Long) As Long
    ' Tile IDs use the source sheet's row width, even when the picker only
    ' displays part of a wide sheet.
    TilesetColumns = 1
    If Tileset < 1 Or Tileset > UBound(DD_TileSurf) Then Exit Function
    If DD_TileSurf(Tileset) Is Nothing Then Exit Function
    TilesetColumns = DD_TileSurf(Tileset).Width \ PIC_X
    If TilesetColumns < 1 Then TilesetColumns = 1
End Function

Private Sub GetMapTileRect(ByVal X As Long, ByVal Y As Long, ByVal Layer As Long, ByVal TileNumber As Long, ByRef Source As RECT)
    Dim Surface As clsDX11Surface, Columns As Long
    Set Surface = MapTileSurface(X, Y, Layer)
    Columns = Surface.Width \ PIC_X
    If Columns < 1 Then Columns = 1
    Source.Left = (TileNumber Mod Columns) * PIC_X
    Source.Top = (TileNumber \ Columns) * PIC_Y
    Source.Right = Source.Left + PIC_X
    Source.Bottom = Source.Top + PIC_Y
End Sub

' Warp attributes occupy one map cell, independent of sprite dimensions.
Public Sub BltEditorWarpTiles()
    Dim X As Long, Y As Long, bounds As RECT, color As Long
    color = RGB(64, 128, 255)
    For Y = 0 To MAX_MAPY
        For X = 0 To MAX_MAPX
            If Map.Tile(X, Y).Type = TILE_TYPE_WARP Then
                bounds.Left = X * PIC_X
                bounds.Top = Y * PIC_Y
                bounds.Right = bounds.Left + PIC_X
                bounds.Bottom = bounds.Top + 1
                DD_BackBuffer.BltColorFill bounds, color
                bounds.Top = (Y + 1) * PIC_Y - 1
                bounds.Bottom = bounds.Top + 1
                DD_BackBuffer.BltColorFill bounds, color
                bounds.Top = Y * PIC_Y
                bounds.Bottom = bounds.Top + PIC_Y
                bounds.Right = bounds.Left + 1
                DD_BackBuffer.BltColorFill bounds, color
                bounds.Left = (X + 1) * PIC_X - 1
                bounds.Right = bounds.Left + 1
                DD_BackBuffer.BltColorFill bounds, color
            End If
        Next X
    Next Y
End Sub
