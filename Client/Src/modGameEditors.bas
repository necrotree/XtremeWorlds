Attribute VB_Name = "modGameEditors"
Option Explicit

Public EditorTileset As Long
Public EditorAttributeLayer As Long

Private Const EDITOR_TILE_COLUMNS As Long = 12
Private EditorSelectionWidth As Long
Private EditorSelectionHeight As Long
Private EditorAnchorX As Long
Private EditorAnchorY As Long
Private EditorSelecting As Boolean

Public Sub EditorInit()
    Dim lastScrollRow As Long
    If Not InEditor Or EditorTileset < 1 Then EditorTileset = Map.Tileset
    If EditorTileset = 0 Then
        EditorTileset = 1
    End If
    
    If DD_TileSurf(EditorTileset) Is Nothing Then Exit Sub
    If DD_TileSurf(EditorTileset).Height < PIC_Y Then Exit Sub
    If Not InEditor Then
        SaveMap = Map
        Call EditorPreserveTilesets
    End If
    InEditor = True
    EditorSelecting = False
    EditorSelectionWidth = 1
    EditorSelectionHeight = 1
    frmMainGame.picMapEditor.Visible = True
    frmMainGame.LayoutGamePanels
    frmMainGame.scrlTileset.Value = EditorTileset
    frmMainGame.picBack.SetFocus
    frmMainGame.picBack.ToolTipText = "Hold the left mouse button and drag to select a block of tiles."

    lastScrollRow = DD_TileSurf(EditorTileset).Height \ PIC_Y - frmMainGame.picBack.ScaleHeight \ PIC_Y
    If lastScrollRow < 0 Then lastScrollRow = 0
    If frmMainGame.scrlPicture.Value > lastScrollRow Then frmMainGame.scrlPicture.Value = lastScrollRow
    frmMainGame.scrlPicture.Max = lastScrollRow
    EditorTileX = 0
    EditorTileY = frmMainGame.scrlPicture.Value
    Call EditorTileScroll
    Call EditorSelectionPreview
End Sub

' Older maps use zero to inherit the map tileset. Capture the source before
' editing so changing the palette or map default cannot retarget existing tiles.
Public Sub EditorPreserveTilesets()
    Dim X As Long, Y As Long, Layer As Long
    For Y = 0 To MAX_MAPY
        For X = 0 To MAX_MAPX
            For Layer = 0 To 8
                Map.Tile(X, Y).LayerTileset(Layer) = TileLayerTileset(Map.Tile(X, Y), Layer)
            Next Layer
        Next X
    Next Y
End Sub

' Selecting a tileset affects only the brush used for subsequent painting.
Public Sub EditorChangeTileset(ByVal Tileset As Long)
    If Tileset < 1 Or Tileset > 6 Then Exit Sub
    If EditorTileset = Tileset Then Exit Sub
    If InEditor Then Call EditorPreserveTilesets
    EditorTileset = Tileset
    If InEditor Then Call EditorInit
End Sub

Public Sub EditorMouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim X1 As Long, Y1 As Long
    Dim attributeTile As TileRec

    If InEditor Then
        X1 = Int(X / PIC_X)
        Y1 = Int(Y / PIC_Y)
        If (Button = 1) And (X1 >= 0) And (X1 <= MAX_MAPX) And (Y1 >= 0) And (Y1 <= MAX_MAPY) Then
            If frmMainGame.optLayers.Value = True Then
                Call EditorPaintSelection(X1, Y1)
            Else
                Call ReadEditorAttribute(Map.Tile(X1, Y1), attributeTile)
                With attributeTile
                    If frmMainGame.optBlocked.Value = True Then
                        .Type = TILE_TYPE_BLOCKED
                        .Data1 = EditorBlockPlayer
                        If EditorBlockPlayer = 0 And EditorBlockNPC = 0 And EditorBlockFlight = 0 Then .Data1 = 1
                        .Data2 = EditorBlockNPC
                        .Data3 = EditorBlockFlight
                    End If
                    If frmMainGame.optWarp.Value = True Then
                        .Type = TILE_TYPE_WARP
                        .Data1 = EditorWarpMap
                        .Data2 = EditorWarpX
                        .Data3 = EditorWarpY
                    End If
                    If frmMainGame.optHeal.Value = True Then
                        .Type = TILE_TYPE_HEAL
                        .Data1 = 0
                        .Data2 = 0
                        .Data3 = 0
                    End If
                    If frmMainGame.optKill.Value = True Then
                        .Type = TILE_TYPE_KILL
                        .Data1 = KillValue
                        .Data2 = KillVoidItem
                        .Data3 = 0
                    End If
                    If frmMainGame.optItem.Value = True Then
                        .Type = TILE_TYPE_ITEM
                        .Data1 = ItemEditorNum
                        .Data2 = ItemEditorValue
                        .Data3 = 0
                    End If
                    If frmMainGame.optNpcAvoid.Value = True Then
                        .Type = TILE_TYPE_NPCAVOID
                        .Data1 = 0
                        .Data2 = 0
                        .Data3 = 0
                    End If
                    If frmMainGame.optKey.Value = True Then
                        .Type = TILE_TYPE_KEY
                        .Data1 = KeyEditorNum
                        .Data2 = KeyEditorTake
                        .Data3 = 0
                    End If
                    If frmMainGame.optKeyOpen.Value = True Then
                        .Type = TILE_TYPE_KEYOPEN
                        .Data1 = KeyOpenEditorX
                        .Data2 = KeyOpenEditorY
                        .Data3 = 0
                    End If
                    If frmMainGame.optDoor.Value = True Then
                        .Type = TILE_TYPE_DOOR
                        .Data1 = 0
                        .Data2 = 0
                        .Data3 = 0
                    End If
                    If frmMainGame.optSign.Value = True Then
                        .Type = TILE_TYPE_SIGN
                        .Data1 = SignNum
                        .Data2 = 0
                        .Data3 = 0
                    End If
                    If frmMainGame.optMsg.Value = True Then
                        .Type = TILE_TYPE_MSG
                        .Data1 = MsgEditorText
                        .Data2 = MsgEditorType
                        .Data3 = 0
                    End If
                    If frmMainGame.optSprite.Value = True Then
                        .Type = TILE_TYPE_SPRITE
                        .Data1 = SpriteNum
                        .Data2 = 0
                        .Data3 = 0
                    End If
                    If frmMainGame.optNpcSpawn.Value = True Then
                        .Type = TILE_TYPE_NPCSPAWN
                        .Data1 = SpawnNpcNum
                        .Data2 = SpawnNpcDir
                        .Data3 = SpawnNpcStill
                    End If
                    If frmMainGame.optNudge.Value = True Then
                        .Type = TILE_TYPE_NUDGE
                        .Data1 = EditorNudge
                        .Data2 = 0
                        .Data3 = 0
                    End If
                End With
                Call WriteEditorAttribute(Map.Tile(X1, Y1), attributeTile)
            End If
        End If

        If (Button = 2) And (X1 >= 0) And (X1 <= MAX_MAPX) And (Y1 >= 0) And (Y1 <= MAX_MAPY) Then
            If frmMainGame.optLayers.Value = True Then
                With Map.Tile(X1, Y1)
                    If frmMainGame.optGround.Value = True Then
                        .Ground = 0
                        .LayerTileset(0) = 0
                    End If
                    If frmMainGame.optMask.Value = True Then
                        .Mask = 0
                        .LayerTileset(1) = 0
                    End If
                    If frmMainGame.optAnim.Value = True Then
                        .Anim = 0
                        .LayerTileset(2) = 0
                    End If
                    If frmMainGame.optMask2.Value = True Then
                        .Mask2 = 0
                        .LayerTileset(3) = 0
                    End If
                    If frmMainGame.optM2Anim.Value = True Then
                        .M2Anim = 0
                        .LayerTileset(4) = 0
                    End If
                    If frmMainGame.optFringe.Value = True Then
                        .Fringe = 0
                        .LayerTileset(5) = 0
                    End If
                    If frmMainGame.optFAnim.Value = True Then
                        .FAnim = 0
                        .LayerTileset(6) = 0
                    End If
                    If frmMainGame.optFringe2.Value = True Then
                        .Fringe2 = 0
                        .LayerTileset(7) = 0
                    End If
                    If frmMainGame.optF2Anim.Value = True Then
                        .F2Anim = 0
                        .LayerTileset(8) = 0
                    End If
                End With
            Else
                Call ReadEditorAttribute(Map.Tile(X1, Y1), attributeTile)
                With attributeTile
                    .Type = 0
                    .Data1 = 0
                    .Data2 = 0
                    .Data3 = 0
                End With
                Call WriteEditorAttribute(Map.Tile(X1, Y1), attributeTile)
            End If
        End If
        Call BltMap
    End If
End Sub

Private Sub EditorPaintSelection(ByVal MapX As Long, ByVal MapY As Long)
    Dim X As Long, Y As Long, tileNumber As Long
    If EditorSelectionWidth < 1 Then EditorSelectionWidth = 1
    If EditorSelectionHeight < 1 Then EditorSelectionHeight = 1
    For Y = 0 To EditorSelectionHeight - 1
        For X = 0 To EditorSelectionWidth - 1
            If MapX + X <= MAX_MAPX And MapY + Y <= MAX_MAPY Then
                tileNumber = (EditorTileY + Y) * EDITOR_TILE_COLUMNS + EditorTileX + X
                With Map.Tile(MapX + X, MapY + Y)
                    If frmMainGame.optGround.Value Then
                        .Ground = tileNumber
                        .LayerTileset(0) = EditorTileset
                    End If
                    If frmMainGame.optMask.Value Then
                        .Mask = tileNumber
                        .LayerTileset(1) = EditorTileset
                    End If
                    If frmMainGame.optAnim.Value Then
                        .Anim = tileNumber
                        .LayerTileset(2) = EditorTileset
                    End If
                    If frmMainGame.optMask2.Value Then
                        .Mask2 = tileNumber
                        .LayerTileset(3) = EditorTileset
                    End If
                    If frmMainGame.optM2Anim.Value Then
                        .M2Anim = tileNumber
                        .LayerTileset(4) = EditorTileset
                    End If
                    If frmMainGame.optFringe.Value Then
                        .Fringe = tileNumber
                        .LayerTileset(5) = EditorTileset
                    End If
                    If frmMainGame.optFAnim.Value Then
                        .FAnim = tileNumber
                        .LayerTileset(6) = EditorTileset
                    End If
                    If frmMainGame.optFringe2.Value Then
                        .Fringe2 = tileNumber
                        .LayerTileset(7) = EditorTileset
                    End If
                    If frmMainGame.optF2Anim.Value Then
                        .F2Anim = tileNumber
                        .LayerTileset(8) = EditorTileset
                    End If
                End With
            End If
        Next X
    Next Y
End Sub

Public Sub EditorChooseTile(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Not InEditor Or Button <> 1 Then Exit Sub

    EditorSelecting = False

    If DD_TileSurf(EditorTileset) Is Nothing Then Exit Sub

    If X < 0 Or X >= frmMainGame.picBack.ScaleWidth Then Exit Sub
    If Y < 0 Or Y >= frmMainGame.picBack.ScaleHeight Then Exit Sub

    If Int(X / PIC_X) >= EDITOR_TILE_COLUMNS Then Exit Sub

    If Int(Y / PIC_Y) + frmMainGame.scrlPicture.Value >= _
       DD_TileSurf(EditorTileset).Height \ PIC_Y Then Exit Sub

    EditorAnchorX = Int(X / PIC_X)
    EditorAnchorY = Int(Y / PIC_Y) + frmMainGame.scrlPicture.Value

    EditorTileX = EditorAnchorX
    EditorTileY = EditorAnchorY

    EditorSelectionWidth = 1
    EditorSelectionHeight = 1

    EditorSelecting = True

    Call EditorTileScroll
    Call EditorSelectionPreview
End Sub

Public Sub EditorUpdateSelection(Button As Integer, X As Single, Y As Single)
    Dim tileX As Long
    Dim tileY As Long
    Dim lastX As Long
    Dim lastY As Long
    Dim leftTile As Long
    Dim topTile As Long
    Dim width As Long
    Dim height As Long

    If Not InEditor Or Not EditorSelecting Then Exit Sub

    If (Button And 1) = 0 Then
        EditorSelecting = False
        Exit Sub
    End If

    If DD_TileSurf(EditorTileset) Is Nothing Then Exit Sub

    '
    ' 384 / 32 = 12 columns
    ' Last valid index = 11
    '
    lastX = frmMainGame.picBack.ScaleWidth \ PIC_X - 1

    If lastX >= EDITOR_TILE_COLUMNS Then
        lastX = EDITOR_TILE_COLUMNS - 1
    End If

    If lastX >= DD_TileSurf(EditorTileset).Width \ PIC_X Then
        lastX = DD_TileSurf(EditorTileset).Width \ PIC_X - 1
    End If

    lastY = frmMainGame.picBack.ScaleHeight \ PIC_Y - 1

    tileX = Int(X / PIC_X)
    tileY = Int(Y / PIC_Y)

    If tileX < 0 Then tileX = 0
    If tileX > lastX Then tileX = lastX

    If tileY < 0 Then tileY = 0
    If tileY > lastY Then tileY = lastY

    tileY = tileY + frmMainGame.scrlPicture.Value

    If tileY >= DD_TileSurf(EditorTileset).Height \ PIC_Y Then
        tileY = DD_TileSurf(EditorTileset).Height \ PIC_Y - 1
    End If

    leftTile = EditorAnchorX
    topTile = EditorAnchorY

    If tileX < leftTile Then leftTile = tileX
    If tileY < topTile Then topTile = tileY

    width = Abs(tileX - EditorAnchorX) + 1
    height = Abs(tileY - EditorAnchorY) + 1

    If leftTile = EditorTileX And _
       topTile = EditorTileY And _
       width = EditorSelectionWidth And _
       height = EditorSelectionHeight Then Exit Sub

    EditorTileX = leftTile
    EditorTileY = topTile

    EditorSelectionWidth = width
    EditorSelectionHeight = height

    Call EditorTileScroll
    Call EditorSelectionPreview
End Sub

Public Sub EditorEndSelection(Button As Integer, X As Single, Y As Single)
    If Button <> 1 Then Exit Sub
    Call EditorUpdateSelection(Button, X, Y)
    EditorSelecting = False
End Sub

Private Sub EditorSelectionPreview()
    Dim source As RECT, destination As RECT, previewScale As Single
    If DD_TileSurf(EditorTileset) Is Nothing Then Exit Sub
    If EditorSelectionWidth < 1 Or EditorSelectionHeight < 1 Then Exit Sub
    source.Left = EditorTileX * PIC_X
    source.Top = EditorTileY * PIC_Y
    source.Right = source.Left + EditorSelectionWidth * PIC_X
    source.Bottom = source.Top + EditorSelectionHeight * PIC_Y
End Sub

Public Sub EditorTileScroll()
    Dim source As RECT
    Dim destination As RECT

    If DD_TileSurf(EditorTileset) Is Nothing Then Exit Sub

    With frmMainGame.picBack
        .Cls

        source.Left = 0
        source.Top = frmMainGame.scrlPicture.Value * PIC_Y

        source.Right = .ScaleWidth
        source.Bottom = source.Top + .ScaleHeight

        If source.Right > DD_TileSurf(EditorTileset).Width Then
            source.Right = DD_TileSurf(EditorTileset).Width
        End If

        If source.Bottom > DD_TileSurf(EditorTileset).Height Then
            source.Bottom = DD_TileSurf(EditorTileset).Height
        End If

        destination.Left = 0
        destination.Top = 0
        destination.Right = source.Right - source.Left
        destination.Bottom = source.Bottom - source.Top

        DD_TileSurf(EditorTileset).BltToDC .hDC, source, destination

        Call EditorDrawSelection

        .Refresh
    End With
End Sub

Private Sub EditorDrawSelection()
    Dim left As Long
    Dim top As Long
    Dim right As Long
    Dim bottom As Long

    If Not InEditor Then Exit Sub
    If EditorSelectionWidth < 1 Or EditorSelectionHeight < 1 Then Exit Sub

    left = EditorTileX * PIC_X
    top = (EditorTileY - frmMainGame.scrlPicture.Value) * PIC_Y

    right = left + EditorSelectionWidth * PIC_X - 1
    bottom = top + EditorSelectionHeight * PIC_Y - 1

    frmMainGame.picBack.Line _
        (left, top)-(right, bottom), vbWhite, B

    frmMainGame.picBack.Line _
        (left + 1, top + 1)-(right - 1, bottom - 1), vbBlack, B
End Sub

Public Sub EditorSend()
    Call SendMap
    Call EditorCancel
End Sub

Public Sub EditorCancel()
    Map = SaveMap
    InEditor = False
    EditorSelecting = False
    frmMainGame.picMapEditor.Visible = False
    frmMainGame.LayoutGamePanels
    frmMainGame.scrlTileset.Value = EditorTileset
    BltMap
End Sub

Public Sub EditorClearLayer()
    Dim YesNo As Long, X As Long, Y As Long

    ' Ground layer
    If frmMainGame.optGround.Value = True Then
        YesNo = GameMsgBox("Are you sure you wish to clear the ground layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Ground = 0
                    Map.Tile(X, Y).LayerTileset(0) = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Mask layer
    If frmMainGame.optMask.Value = True Then
        YesNo = GameMsgBox("Are you sure you wish to clear the mask layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Mask = 0
                    Map.Tile(X, Y).LayerTileset(1) = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Mask Animation layer
    If frmMainGame.optAnim.Value = True Then
        YesNo = GameMsgBox("Are you sure you wish to clear the animation layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Anim = 0
                    Map.Tile(X, Y).LayerTileset(2) = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Mask 2 layer
    If frmMainGame.optMask2.Value = True Then
        YesNo = GameMsgBox("Are you sure you wish to clear the mask 2 layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Mask2 = 0
                    Map.Tile(X, Y).LayerTileset(3) = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Mask 2 Animation layer
    If frmMainGame.optM2Anim.Value = True Then
        YesNo = GameMsgBox("Are you sure you wish to clear the mask 2 animation layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).M2Anim = 0
                    Map.Tile(X, Y).LayerTileset(4) = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Fringe layer
    If frmMainGame.optFringe.Value = True Then
        YesNo = GameMsgBox("Are you sure you wish to clear the fringe layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Fringe = 0
                    Map.Tile(X, Y).LayerTileset(5) = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Fringe Animation layer
    If frmMainGame.optFAnim.Value = True Then
        YesNo = GameMsgBox("Are you sure you wish to clear the fringe animation layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).FAnim = 0
                    Map.Tile(X, Y).LayerTileset(6) = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Fringe 2 layer
    If frmMainGame.optFringe2.Value = True Then
        YesNo = GameMsgBox("Are you sure you wish to clear the fringe 2 layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Fringe2 = 0
                    Map.Tile(X, Y).LayerTileset(7) = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Fringe 2 Animation layer
    If frmMainGame.optF2Anim.Value = True Then
        YesNo = GameMsgBox("Are you sure you wish to clear the fringe 2 animation layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).F2Anim = 0
                    Map.Tile(X, Y).LayerTileset(8) = 0
                Next X
            Next Y
            BltMap
        End If
    End If
End Sub

Public Sub EditorClearAttribs()
    Dim YesNo As Long, X As Long, Y As Long

    YesNo = GameMsgBox("Are you sure you wish to clear the attributes on this map?", vbYesNo, GAME_NAME)

    If YesNo = vbYes Then
        For Y = 0 To MAX_MAPY
            For X = 0 To MAX_MAPX
                If EditorAttributeLayer = 2 Then
                    Map.Tile(X, Y).Type2 = 0
                    Map.Tile(X, Y).Data21 = 0
                    Map.Tile(X, Y).Data22 = 0
                    Map.Tile(X, Y).Data23 = 0
                Else
                    Map.Tile(X, Y).Type = 0
                    Map.Tile(X, Y).Data1 = 0
                    Map.Tile(X, Y).Data2 = 0
                    Map.Tile(X, Y).Data3 = 0
                End If
            Next X
        Next Y
    End If
End Sub

Public Sub ItemEditorInit()
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 06/01/2006  BigRed   Removed LoadPicture
' * 07/12/2005  Shannara   Added gfx constant.
' ****************************************************************

    frmItemEditor.txtName.Text = Trim$(Item(EditorIndex).name)
    If Not DD_ItemSurf Is Nothing Then frmItemEditor.scrlPic.Max = 6 * (DD_ItemSurf.Height \ PIC_Y) - 1
    frmItemEditor.scrlPic.Value = Item(EditorIndex).Pic
    frmItemEditor.cmbType.ListIndex = Item(EditorIndex).Type

    If (frmItemEditor.cmbType.ListIndex >= ITEM_TYPE_WEAPON) And (frmItemEditor.cmbType.ListIndex <= ITEM_TYPE_SHIELD) Then
        frmItemEditor.fraEquipment.Visible = True
        frmItemEditor.scrlDurability.Value = Item(EditorIndex).Data1
        frmItemEditor.scrlStrength.Value = Item(EditorIndex).Data2
    Else
        frmItemEditor.fraEquipment.Visible = False
    End If

    If (frmItemEditor.cmbType.ListIndex >= ITEM_TYPE_POTIONADDHP) And (frmItemEditor.cmbType.ListIndex <= ITEM_TYPE_POTIONSUBSP) Then
        frmItemEditor.fraVitals.Visible = True
        frmItemEditor.scrlVitalMod.Value = Item(EditorIndex).Data1
    Else
        frmItemEditor.fraVitals.Visible = False
    End If

    If (frmItemEditor.cmbType.ListIndex = ITEM_TYPE_SPELL) Then
        frmItemEditor.fraSpell.Visible = True
        frmItemEditor.scrlSpell.Value = Item(EditorIndex).Data1
    Else
        frmItemEditor.fraSpell.Visible = False
    End If

    frmItemEditor.Show vbModal
End Sub

Public Sub ItemEditorOk()
    Item(EditorIndex).name = frmItemEditor.txtName.Text
    Item(EditorIndex).Pic = frmItemEditor.scrlPic.Value
    Item(EditorIndex).Type = frmItemEditor.cmbType.ListIndex

    If (frmItemEditor.cmbType.ListIndex >= ITEM_TYPE_WEAPON) And (frmItemEditor.cmbType.ListIndex <= ITEM_TYPE_SHIELD) Then
        Item(EditorIndex).Data1 = frmItemEditor.scrlDurability.Value
        Item(EditorIndex).Data2 = frmItemEditor.scrlStrength.Value
        Item(EditorIndex).Data3 = 0
    End If

    If (frmItemEditor.cmbType.ListIndex >= ITEM_TYPE_POTIONADDHP) And (frmItemEditor.cmbType.ListIndex <= ITEM_TYPE_POTIONSUBSP) Then
        Item(EditorIndex).Data1 = frmItemEditor.scrlVitalMod.Value
        Item(EditorIndex).Data2 = 0
        Item(EditorIndex).Data3 = 0
    End If

    If (frmItemEditor.cmbType.ListIndex = ITEM_TYPE_SPELL) Then
        Item(EditorIndex).Data1 = frmItemEditor.scrlSpell.Value
        Item(EditorIndex).Data2 = 0
        Item(EditorIndex).Data3 = 0
    End If

    If (frmItemEditor.cmbType.ListIndex = ITEM_TYPE_WARP) Then
        Item(EditorIndex).Data1 = Val(frmItemEditor.txtMap.Text)
        Item(EditorIndex).Data2 = frmItemEditor.scrlMapX.Value
        Item(EditorIndex).Data3 = frmItemEditor.scrlMapY.Value
    End If

    Call SendSaveItem(EditorIndex)
    InItemsEditor = False
    Unload frmItemEditor
End Sub

Public Sub ItemEditorCancel()
    InItemsEditor = False
    Unload frmItemEditor
End Sub

Public Sub ItemEditorBltItem()
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 06/01/2006  BigRed   Changed BitBlt to DX7
' ****************************************************************

    Call GetItemPictureRect(frmItemEditor.scrlPic.Value, rec)

    With rec_pos
        .Top = 0
        .Bottom = PIC_Y
        .Left = 0
        .Right = PIC_X
    End With

    If DD_ItemSurf Is Nothing Then
    Else
        DD_ItemSurf.BltToDC frmItemEditor.picPic.hDC, rec, rec_pos
    End If
    frmItemEditor.picPic.Refresh
End Sub

Public Sub BltPlayerInvItem()
    Call GetItemPictureRect(Item(GetPlayerInvItemNum(MyIndex, frmMainGame.lstInv.ListIndex + 1)).Pic, rec)

    With rec_pos
        .Top = 0
        .Bottom = PIC_Y
        .Left = 0
        .Right = PIC_X
    End With

    If Not DD_ItemSurf Is Nothing Then
        DD_ItemSurf.BltToDC frmMainGame.picItem.hDC, rec, rec_pos
    End If
    frmMainGame.picItem.Refresh
End Sub

Public Sub BltPlayerGear()
    Dim Slots(3) As Long, i As Long, Num As Long
    Dim Background As New clsDX11Surface, Canvas As New clsDX11Surface
    Dim Source As RECT, Bounds As RECT
    If DD_ItemSurf Is Nothing Then Exit Sub
    Slots(0) = GetPlayerShieldSlot(MyIndex)
    Slots(1) = GetPlayerArmorSlot(MyIndex)
    Slots(2) = GetPlayerWeaponSlot(MyIndex)
    Slots(3) = GetPlayerHelmetSlot(MyIndex)
    Background.LoadFromFile App.Path & "\Gfx\Gui\Character.jpg"
    Canvas.Create 32, 32
    Bounds.Right = 32
    Bounds.Bottom = 32
    For i = 0 To 3
        Source.Left = 45 + i * 45
        Source.Top = 298
        Source.Right = Source.Left + 32
        Source.Bottom = Source.Top + 32
        Canvas.Blt Bounds, Background, Source
        frmMainGame.imgEquipment(i).ToolTipText = "Empty"
        If Slots(i) > 0 And Slots(i) <= MAX_INV Then
            Num = GetPlayerInvItemNum(MyIndex, Slots(i))
            If Num > 0 And Num <= MAX_ITEMS Then
                GetItemPictureRect Item(Num).Pic, Source
                Canvas.BltFast 0, 0, DD_ItemSurf, Source, True
                frmMainGame.imgEquipment(i).ToolTipText = Trim$(Item(Num).name) & " (Durability: " & GetPlayerInvItemDur(MyIndex, Slots(i)) & ")"
            End If
        End If
        Set frmMainGame.imgEquipment(i).Picture = MenuSurfacePicture(Canvas)
    Next i
End Sub

Public Sub SignEditorInit()
    frmSignEditor.txtSignName.Text = Trim$(Sign(EditorIndex).name)
    frmSignEditor.txtSignLine1.Text = Trim$(Sign(EditorIndex).Line1)
    frmSignEditor.txtSignLine2.Text = Trim$(Sign(EditorIndex).Line2)
    frmSignEditor.txtSignLine3.Text = Trim$(Sign(EditorIndex).Line3)
    frmSignEditor.Show vbModal
End Sub

Public Sub SignEditorOk()
    Sign(EditorIndex).name = frmSignEditor.txtSignName.Text
    Sign(EditorIndex).Line1 = frmSignEditor.txtSignLine1.Text
    Sign(EditorIndex).Line2 = frmSignEditor.txtSignLine2.Text
    Sign(EditorIndex).Line3 = frmSignEditor.txtSignLine3.Text

    If frmSignEditor.optWooden.Value = True Then
        Sign(EditorIndex).Background = 0
    ElseIf frmSignEditor.optScroll.Value = True Then
        Sign(EditorIndex).Background = 1
    End If

    Call SendSaveSign(EditorIndex)
    InSignEditor = False
    Unload frmSignEditor
End Sub

Public Sub SignEditorCancel()
    InSignEditor = False
    Unload frmSignEditor
End Sub

Public Sub NpcEditorInit()
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 06/01/2006  BigRed   Removed LoadPicture
' * 07/12/2005  Shannara   Added gfx constant.
' ****************************************************************

    frmNpcEditor.txtName.Text = Trim$(Npc(EditorIndex).name)
    frmNpcEditor.txtAttackSay.Text = Trim$(Npc(EditorIndex).AttackSay)
    frmNpcEditor.scrlSprite.Value = Npc(EditorIndex).Sprite
    frmNpcEditor.txtSpawnSecs.Text = Str(Npc(EditorIndex).SpawnSecs)
    frmNpcEditor.cmbBehavior.ListIndex = Npc(EditorIndex).Behavior
    frmNpcEditor.scrlRange.Value = Npc(EditorIndex).Range
    frmNpcEditor.txtChance.Text = Str(Npc(EditorIndex).DropChance)
    frmNpcEditor.scrlNum.Value = Npc(EditorIndex).DropItem
    frmNpcEditor.scrlValue.Value = Npc(EditorIndex).DropItemValue
    frmNpcEditor.scrlSTR.Value = Npc(EditorIndex).STR
    frmNpcEditor.scrlDEF.Value = Npc(EditorIndex).DEF
    frmNpcEditor.scrlSPEED.Value = Npc(EditorIndex).speed
    frmNpcEditor.scrlMAGI.Value = Npc(EditorIndex).MAGI
    frmNpcEditor.cmbShop.ListIndex = Npc(EditorIndex).ShopCall
    frmNpcEditor.txtMaxHP.Text = Trim$(Npc(EditorIndex).MaxHP)
    frmNpcEditor.txtGiveEXP.Text = Trim$(Npc(EditorIndex).GiveEXP)

    frmNpcEditor.Show vbModal
End Sub

Public Sub NpcEditorOk()
    Npc(EditorIndex).name = frmNpcEditor.txtName.Text
    Npc(EditorIndex).AttackSay = frmNpcEditor.txtAttackSay.Text
    Npc(EditorIndex).Sprite = frmNpcEditor.scrlSprite.Value
    Npc(EditorIndex).SpawnSecs = Val(frmNpcEditor.txtSpawnSecs.Text)
    Npc(EditorIndex).Behavior = frmNpcEditor.cmbBehavior.ListIndex
    Npc(EditorIndex).Range = frmNpcEditor.scrlRange.Value
    Npc(EditorIndex).DropChance = Val(frmNpcEditor.txtChance.Text)
    Npc(EditorIndex).DropItem = frmNpcEditor.scrlNum.Value
    Npc(EditorIndex).DropItemValue = frmNpcEditor.scrlValue.Value
    Npc(EditorIndex).STR = frmNpcEditor.scrlSTR.Value
    Npc(EditorIndex).DEF = frmNpcEditor.scrlDEF.Value
    Npc(EditorIndex).speed = frmNpcEditor.scrlSPEED.Value
    Npc(EditorIndex).MAGI = frmNpcEditor.scrlMAGI.Value
    Npc(EditorIndex).MaxHP = frmNpcEditor.txtMaxHP.Text
    Npc(EditorIndex).GiveEXP = frmNpcEditor.txtGiveEXP.Text
    Npc(EditorIndex).ShopCall = frmNpcEditor.cmbShop.ListIndex

    Call SendSaveNpc(EditorIndex)
    InNpcEditor = False
    Unload frmNpcEditor
End Sub

' Public Sub SignEditorOk()
' Sign(EditorIndex).Name = frmSignEditor.txtName.Text
' Sign(EditorIndex).Line1 =
' Npc(EditorIndex).Sprite = frmNpcEditor.scrlSprite.Value
' Npc(EditorIndex).SpawnSecs = Val(frmNpcEditor.txtSpawnSecs.Text)
' Npc(EditorIndex).Behavior = frmNpcEditor.cmbBehavior.ListIndex
'
' Call SendSaveSign(EditorIndex)
' InSignEditor = False
' Unload frmSignEditor
' End Sub

Public Sub NpcEditorCancel()
    InNpcEditor = False
    Unload frmNpcEditor
End Sub

Public Sub ShopEditorInit()
    On Error Resume Next

    Dim i As Long

    frmShopEditor.txtName.Text = Trim$(Shop(EditorIndex).name)
    frmShopEditor.txtJoinSay.Text = Trim$(Shop(EditorIndex).JoinSay)
    frmShopEditor.txtLeaveSay.Text = Trim$(Shop(EditorIndex).LeaveSay)
    frmShopEditor.chkFixesItems.Value = Shop(EditorIndex).FixesItems

    frmShopEditor.cmbItemGive.Clear
    frmShopEditor.cmbItemGive.AddItem "None"
    frmShopEditor.cmbItemGet.Clear
    frmShopEditor.cmbItemGet.AddItem "None"
    frmShopEditor.cmbitem2Give.Clear
    frmShopEditor.cmbitem2Give.AddItem "None"
    For i = 1 To MAX_ITEMS
        frmShopEditor.cmbItemGive.AddItem i & ": " & Trim$(Item(i).name)
        frmShopEditor.cmbitem2Give.AddItem i & ": " & Trim$(Item(i).name)
        frmShopEditor.cmbItemGet.AddItem i & ": " & Trim$(Item(i).name)
    Next i
    frmShopEditor.cmbItemGive.ListIndex = 0
    frmShopEditor.cmbitem2Give.ListIndex = 0
    frmShopEditor.cmbItemGet.ListIndex = 0

    Call UpdateShopTrade

    frmShopEditor.Show vbModal
End Sub

Public Sub UpdateShopTrade()
    Dim i As Long, GetItem As Long, GetValue As Long, GiveItem As Long, GiveValue As Long, GiveItem2 As Long, GiveValue2 As Long

    frmShopEditor.lstTradeItem.Clear
    For i = 1 To MAX_TRADES
        GetItem = Shop(EditorIndex).TradeItem(i).GetItem
        GetValue = Shop(EditorIndex).TradeItem(i).GetValue
        GiveItem = Shop(EditorIndex).TradeItem(i).GiveItem
        GiveValue = Shop(EditorIndex).TradeItem(i).GiveValue
        GiveItem2 = Shop(EditorIndex).TradeItem(i).GiveItem2
        GiveValue2 = Shop(EditorIndex).TradeItem(i).GiveValue2

        If GetItem > 0 And GiveItem > 0 And GiveItem2 > 0 Then
            frmShopEditor.lstTradeItem.AddItem i & ": " & GiveValue & " " & Trim$(Item(GiveItem).name) & " and " & GiveValue2 & " " & Trim$(Item(GiveItem2).name) & " for " & GetValue & " " & Trim$(Item(GetItem).name)
        ElseIf GetItem > 0 And GiveItem > 0 And GiveItem2 <= 0 Then
            frmShopEditor.lstTradeItem.AddItem i & ": " & GiveValue & " " & Trim$(Item(GiveItem).name) & " for " & GetValue & " " & Trim$(Item(GetItem).name)
        ElseIf GetItem > 0 And GiveItem <= 0 And GiveItem2 > 0 Then
            frmShopEditor.lstTradeItem.AddItem i & ": " & GiveValue2 & " " & Trim$(Item(GiveItem2).name) & " for " & GetValue & " " & Trim$(Item(GetItem).name)
        Else
            frmShopEditor.lstTradeItem.AddItem "Empty Trade Slot"
        End If
    Next i
    frmShopEditor.lstTradeItem.ListIndex = 0
End Sub

Public Sub ShopEditorOk()
    Shop(EditorIndex).name = frmShopEditor.txtName.Text
    Shop(EditorIndex).JoinSay = frmShopEditor.txtJoinSay.Text
    Shop(EditorIndex).LeaveSay = frmShopEditor.txtLeaveSay.Text
    Shop(EditorIndex).FixesItems = frmShopEditor.chkFixesItems.Value

    Call SendSaveShop(EditorIndex)
    InShopEditor = False
    Unload frmShopEditor
End Sub

Public Sub ShopEditorCancel()
    InShopEditor = False
    Unload frmShopEditor
End Sub

Public Sub SpellEditorInit()
    On Error Resume Next

    Dim i As Long
    frmSpellEditor.picSpells.Picture = LoadPicture(App.Path & "\gfx\spells.bmp")

    frmSpellEditor.cmbClassReq.AddItem "All Classes"
    For i = 0 To MAX_CLASS
        frmSpellEditor.cmbClassReq.AddItem Trim$(Class(i).Name)
    Next i

    frmSpellEditor.txtName.Text = Trim$(Spell(EditorIndex).name)
    frmSpellEditor.cmbClassReq.ListIndex = Spell(EditorIndex).ClassReq
    frmSpellEditor.scrlLevelReq.Value = Spell(EditorIndex).LevelReq
    frmSpellEditor.scrlMP.Value = Spell(EditorIndex).MPReq
    frmSpellEditor.scrlAnim.Value = Spell(EditorIndex).Graphic

    frmSpellEditor.cmbType.ListIndex = Spell(EditorIndex).Type
    If Spell(EditorIndex).Type <> SPELL_TYPE_GIVEITEM And Spell(EditorIndex).Type <> SPELL_TYPE_WARP Then
        frmSpellEditor.fraVitals.Visible = True
        frmSpellEditor.fraGiveItem.Visible = False
        frmSpellEditor.fraWarp.Visible = False
        frmSpellEditor.scrlVitalMod.Value = Spell(EditorIndex).Data1
    ElseIf Spell(EditorIndex).Type = SPELL_TYPE_GIVEITEM Then
        frmSpellEditor.fraVitals.Visible = False
        frmSpellEditor.fraGiveItem.Visible = True
        frmSpellEditor.fraWarp.Visible = False
        frmSpellEditor.scrlItemNum.Value = Spell(EditorIndex).Data1
        frmSpellEditor.scrlItemValue.Value = Spell(EditorIndex).Data2
    ElseIf Spell(EditorIndex).Type = SPELL_TYPE_WARP Then
        frmSpellEditor.fraVitals.Visible = False
        frmSpellEditor.fraGiveItem.Visible = False
        frmSpellEditor.fraWarp.Visible = True
        frmSpellEditor.txtMap.Text = Spell(EditorIndex).Data1
        frmSpellEditor.scrlMapX = Spell(EditorIndex).Data2
        frmSpellEditor.scrlMapY = Spell(EditorIndex).Data3
    End If

    Call InitSpellDeliveryEditor
    frmSpellEditor.Show vbModal
End Sub

Public Sub SpellEditorOk()
    If Not SaveSpellDeliveryEditor Then Exit Sub
    Spell(EditorIndex).name = frmSpellEditor.txtName.Text
    Spell(EditorIndex).ClassReq = frmSpellEditor.cmbClassReq.ListIndex
    Spell(EditorIndex).LevelReq = frmSpellEditor.scrlLevelReq.Value
    Spell(EditorIndex).MPReq = frmSpellEditor.scrlMP.Value
    Spell(EditorIndex).Type = frmSpellEditor.cmbType.ListIndex
    Spell(EditorIndex).Graphic = frmSpellEditor.scrlAnim.Value
    If Spell(EditorIndex).Type <> SPELL_TYPE_GIVEITEM And Spell(EditorIndex).Type <> SPELL_TYPE_WARP Then
        Spell(EditorIndex).Data1 = frmSpellEditor.scrlVitalMod.Value
        Spell(EditorIndex).Data2 = 0
        Spell(EditorIndex).Data3 = 0
    ElseIf Spell(EditorIndex).Type = SPELL_TYPE_GIVEITEM Then
        Spell(EditorIndex).Data1 = frmSpellEditor.scrlItemNum.Value
        Spell(EditorIndex).Data2 = frmSpellEditor.scrlItemValue.Value
        Spell(EditorIndex).Data3 = 0
    ElseIf Spell(EditorIndex).Type = SPELL_TYPE_WARP Then
        Spell(EditorIndex).Data1 = Val(frmSpellEditor.txtMap.Text)
        Spell(EditorIndex).Data2 = frmSpellEditor.scrlMapX.Value
        Spell(EditorIndex).Data3 = frmSpellEditor.scrlMapY.Value
    End If

    Call SendSaveSpell(EditorIndex)
    InSpellEditor = False
    Unload frmSpellEditor
End Sub

Public Sub SpellEditorCancel()
    InSpellEditor = False
    Unload frmSpellEditor
End Sub

Public Sub ArrowEditorInit()
    frmArrowEditor.txtName.Text = Trim$(Arrow(EditorIndex).Name)
    frmArrowEditor.scrlRange.Value = Arrow(EditorIndex).Range
    frmArrowEditor.scrlSprite = Arrow(EditorIndex).Sprite

    frmArrowEditor.Show vbModal
End Sub

Public Sub ClassEditorInit()
    frmClassEditor.txtName.Text = Trim$(Class(EditorIndex).Name)
    frmClassEditor.scrlMSprite.Value = Class(EditorIndex).MSprite
    frmClassEditor.scrlFSprite.Value = Class(EditorIndex).FSprite
    frmClassEditor.scrlSTR.Value = Class(EditorIndex).STR
    frmClassEditor.scrlDEF.Value = Class(EditorIndex).DEF
    frmClassEditor.scrlMAGI.Value = Class(EditorIndex).MAGI
    frmClassEditor.scrlSPD.Value = Class(EditorIndex).Speed
    frmClassEditor.scrlMap.Value = Class(EditorIndex).Map
    frmClassEditor.scrlX.Value = Class(EditorIndex).X
    frmClassEditor.scrlY.Value = Class(EditorIndex).Y

    frmClassEditor.Show vbModal
End Sub






Private Sub ReadEditorAttribute(ByRef tile As TileRec, ByRef selected As TileRec)
    selected = tile
    If EditorAttributeLayer = 2 Then
        selected.Type = tile.Type2
        selected.Data1 = tile.Data21
        selected.Data2 = tile.Data22
        selected.Data3 = tile.Data23
    End If
End Sub

Private Sub WriteEditorAttribute(ByRef tile As TileRec, ByRef selected As TileRec)
    If EditorAttributeLayer = 2 Then
        tile.Type2 = selected.Type
        tile.Data21 = selected.Data1
        tile.Data22 = selected.Data2
        tile.Data23 = selected.Data3
    Else
        tile.Type = selected.Type
        tile.Data1 = selected.Data1
        tile.Data2 = selected.Data2
        tile.Data3 = selected.Data3
    End If
End Sub

Public Sub EditorFillSelection()
    Dim X As Long, Y As Long, savedWidth As Long, savedHeight As Long
    savedWidth = EditorSelectionWidth
    savedHeight = EditorSelectionHeight
    EditorSelectionWidth = 1
    EditorSelectionHeight = 1
    For Y = 0 To MAX_MAPY
        For X = 0 To MAX_MAPX
            Call EditorMouseDown(1, 0, X * PIC_X, Y * PIC_Y)
        Next X
    Next Y
    EditorSelectionWidth = savedWidth
    EditorSelectionHeight = savedHeight
End Sub
