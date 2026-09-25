Attribute VB_Name = "modGameEditors"
Option Explicit

Public Sub EditorInit()
' ****************************************************************
' * WHEN        WHO        WHAT
' * ----        ---        ----
' * 06/01/2006  BigRed     Changed BitBlt to DX7
' * 07/12/2005  Shannara   Added gfx constants.
' ****************************************************************

    SaveMap = Map
    InEditor = True
    frmMainGame.picMapEditor.Visible = True

    frmMainGame.scrlPicture.max = Int(DD_TileSurf.Height / PIC_Y) - 7

    With rec
        .top = 0
        .Bottom = frmMainGame.picBack.Height
        .Left = 0
        .Right = frmMainGame.picBack.Width
    End With

    If DD_TileSurf Is Nothing Then
    Else
        With rec_pos
            If frmMainGame.scrlPicture.Value = 0 Then
                .top = 0
            Else
                .top = (frmMainGame.scrlPicture.Value * PIC_Y) * 1
            End If
            .Left = 0
            .Bottom = .top + (frmMainGame.picBack.Height)
            .Right = frmMainGame.picBack.Width
        End With

        DD_TileSurf.BltToDC frmMainGame.picBack.hDC, rec_pos, rec
        frmMainGame.picBack.Refresh
    End If
End Sub

Public Sub EditorMouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim X1, Y1 As Long

    If InEditor Then
        X1 = Int(X / PIC_X)
        Y1 = Int(Y / PIC_Y)
        If (Button = 1) And (X1 >= 0) And (X1 <= MAX_MAPX) And (Y1 >= 0) And (Y1 <= MAX_MAPY) Then
            If frmMainGame.optLayers.Value = True Then
                With Map.Tile(X1, Y1)
                    If frmMainGame.optGround.Value = True Then .Ground = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optMask.Value = True Then .Mask = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optAnim.Value = True Then .Anim = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optMask2.Value = True Then .Mask2 = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optM2Anim.Value = True Then .M2Anim = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optFringe.Value = True Then .Fringe = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optFAnim.Value = True Then .FAnim = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optFringe2.Value = True Then .Fringe2 = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optF2Anim.Value = True Then .F2Anim = EditorTileY * 7 + EditorTileX
                End With
            Else
                With Map.Tile(X1, Y1)
                    If frmMainGame.optBlocked.Value = True Then
                        .Type = TILE_TYPE_BLOCKED
                        .Data1 = EditorBlockPlayer
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
            End If
        End If

        If (Button = 2) And (X1 >= 0) And (X1 <= MAX_MAPX) And (Y1 >= 0) And (Y1 <= MAX_MAPY) Then
            If frmMainGame.optLayers.Value = True Then
                With Map.Tile(X1, Y1)
                    If frmMainGame.optGround.Value = True Then .Ground = 0
                    If frmMainGame.optMask.Value = True Then .Mask = 0
                    If frmMainGame.optAnim.Value = True Then .Anim = 0
                    If frmMainGame.optMask2.Value = True Then .Mask2 = 0
                    If frmMainGame.optM2Anim.Value = True Then .M2Anim = 0
                    If frmMainGame.optFringe.Value = True Then .Fringe = 0
                    If frmMainGame.optFAnim.Value = True Then .FAnim = 0
                    If frmMainGame.optFringe2.Value = True Then .Fringe2 = 0
                    If frmMainGame.optF2Anim.Value = True Then .F2Anim = 0
                End With
            Else
                With Map.Tile(X1, Y1)
                    .Type = 0
                    .Data1 = 0
                    .Data2 = 0
                    .Data3 = 0
                End With
            End If
        End If
        Call BltMap
    End If
End Sub

Public Sub EditorChooseTile(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' ****************************************************************
    ' * WHEN        WHO        WHAT
    ' * ----        ---        ----
    ' * 06/01/2006  BigRed     Changed BitBlt to DX7
    ' ****************************************************************
    If Button = 1 Then
        EditorTileX = Int(X / PIC_X)
        EditorTileY = Int(Y / PIC_Y) + frmMainGame.scrlPicture.Value
    End If

    With rec_pos
        .top = EditorTileY * PIC_Y
        .Bottom = .top + PIC_Y
        .Left = EditorTileX * PIC_X
        .Right = .Left + PIC_X
    End With

    With rec
        .top = 0
        .Bottom = PIC_Y
        .Left = 0
        .Right = PIC_X
    End With

    If DD_TileSurf Is Nothing Then
    Else
        DD_TileSurf.BltToDC frmMainGame.picSelect.hDC, rec_pos, rec
    End If
    frmMainGame.picSelect.Refresh
End Sub

Public Sub EditorTileScroll()
    ' ****************************************************************
    ' * WHEN        WHO        WHAT
    ' * ----        ---        ----
    ' * 06/01/2006  BigRed     Changed BitBlt to DX7
    ' ****************************************************************
    With rec
        .top = 0
        .Bottom = frmMainGame.picBack.Height
        .Left = 0
        .Right = frmMainGame.picBack.Width
    End With

    If DD_TileSurf Is Nothing Then
    Else
        With rec_pos
            If frmMainGame.scrlPicture.Value = 0 Then
                .top = 0
            Else
                .top = (frmMainGame.scrlPicture.Value * PIC_Y) * 1
            End If
            .Left = 0
            .Bottom = .top + (frmMainGame.picBack.Height)
            .Right = frmMainGame.picBack.Width
        End With

        DD_TileSurf.BltToDC frmMainGame.picBack.hDC, rec_pos, rec
        frmMainGame.picBack.Refresh
    End If
End Sub

Public Sub EditorSend()
    Call SendMap
    Call EditorCancel
End Sub

Public Sub EditorCancel()
    Map = SaveMap
    InEditor = False
    frmMainGame.picMapEditor.Visible = False
    BltMap
End Sub

Public Sub EditorClearLayer()
    Dim YesNo As Long, X As Long, Y As Long

    ' Ground layer
    If frmMainGame.optGround.Value = True Then
        YesNo = MsgBox("Are you sure you wish to clear the ground layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Ground = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Mask layer
    If frmMainGame.optMask.Value = True Then
        YesNo = MsgBox("Are you sure you wish to clear the mask layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Mask = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Mask Animation layer
    If frmMainGame.optAnim.Value = True Then
        YesNo = MsgBox("Are you sure you wish to clear the animation layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Anim = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Mask 2 layer
    If frmMainGame.optMask2.Value = True Then
        YesNo = MsgBox("Are you sure you wish to clear the mask 2 layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Mask2 = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Mask 2 Animation layer
    If frmMainGame.optM2Anim.Value = True Then
        YesNo = MsgBox("Are you sure you wish to clear the mask 2 animation layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).M2Anim = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Fringe layer
    If frmMainGame.optFringe.Value = True Then
        YesNo = MsgBox("Are you sure you wish to clear the fringe layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Fringe = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Fringe Animation layer
    If frmMainGame.optFAnim.Value = True Then
        YesNo = MsgBox("Are you sure you wish to clear the fringe animation layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).FAnim = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Fringe 2 layer
    If frmMainGame.optFringe2.Value = True Then
        YesNo = MsgBox("Are you sure you wish to clear the fringe 2 layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).Fringe2 = 0
                Next X
            Next Y
            BltMap
        End If
    End If

    ' Fringe 2 Animation layer
    If frmMainGame.optF2Anim.Value = True Then
        YesNo = MsgBox("Are you sure you wish to clear the fringe 2 animation layer?", vbYesNo, GAME_NAME)

        If YesNo = vbYes Then
            For Y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    Map.Tile(X, Y).F2Anim = 0
                Next X
            Next Y
            BltMap
        End If
    End If
End Sub

Public Sub EditorClearAttribs()
    Dim YesNo As Long, X As Long, Y As Long

    YesNo = MsgBox("Are you sure you wish to clear the attributes on this map?", vbYesNo, GAME_NAME)

    If YesNo = vbYes Then
        For Y = 0 To MAX_MAPY
            For X = 0 To MAX_MAPX
                Map.Tile(X, Y).Type = 0
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

    With rec
        .top = frmItemEditor.scrlPic.Value * PIC_Y
        .Bottom = .top + PIC_Y
        .Left = 0
        .Right = PIC_X
    End With

    With rec_pos
        .top = 0
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
    With rec
        .top = Item(GetPlayerInvItemNum(MyIndex, frmMainGame.lstInv.ListIndex + 1)).Pic * PIC_Y
        .Bottom = .top + PIC_Y
        .Left = 0
        .Right = PIC_X
    End With

    With rec_pos
        .top = 0
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
    Dim Equip(4) As Integer
    Dim i As Byte

    If GetPlayerShieldSlot(MyIndex) > 0 Then Equip(0) = GetPlayerShieldSlot(MyIndex)
    If GetPlayerArmorSlot(MyIndex) > 0 Then Equip(1) = GetPlayerArmorSlot(MyIndex)
    If GetPlayerWeaponSlot(MyIndex) > 0 Then Equip(2) = GetPlayerWeaponSlot(MyIndex)
    If GetPlayerHelmetSlot(MyIndex) > 0 Then Equip(3) = GetPlayerHelmetSlot(MyIndex)

    For i = 0 To 3
        If Equip(i) <> 0 Then
            With rec
                .top = Item(GetPlayerInvItemNum(MyIndex, Equip(i))).Pic * PIC_Y
                .Bottom = .top + PIC_Y
                .Left = 0
                .Right = PIC_X
            End With

            With rec_pos
                .top = 0
                .Bottom = PIC_Y
                .Left = 0
                .Right = PIC_X
            End With

            If DD_ItemSurf Is Nothing Then
            Else
                DD_ItemSurf.BltToDC frmMainGame.Equip(i).hDC, rec, rec_pos
            End If
        Else
            frmMainGame.Equip(i).Picture = LoadPicture(vbNullString)

        End If
        frmMainGame.Equip(i).Refresh
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
    frmNpcEditor.txtSpawnSecs.Text = STR(Npc(EditorIndex).SpawnSecs)
    frmNpcEditor.cmbBehavior.ListIndex = Npc(EditorIndex).Behavior
    frmNpcEditor.scrlRange.Value = Npc(EditorIndex).Range
    frmNpcEditor.txtChance.Text = STR(Npc(EditorIndex).DropChance)
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
    For i = 0 To Max_Classes
        frmSpellEditor.cmbClassReq.AddItem Trim$(Class(i).name)
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

    frmSpellEditor.Show vbModal
End Sub

Public Sub SpellEditorOk()
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



