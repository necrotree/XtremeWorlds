Attribute VB_Name = "modGameLogic"
Option Explicit

Function GetPlayerDamage(ByVal Index As Long) As Long
    Dim WeaponSlot As Long

    GetPlayerDamage = 0

    ' Check for subscript out of range
    If IsPlaying(Index) = False Or Index <= 0 Or Index > MAX_PLAYERS Then
        Exit Function
    End If

    GetPlayerDamage = Int(GetPlayerSTR(Index) / 2)

    If GetPlayerDamage <= 0 Then
        GetPlayerDamage = 1
    End If

    If GetPlayerWeaponSlot(Index) > 0 Then
        WeaponSlot = GetPlayerWeaponSlot(Index)

        GetPlayerDamage = GetPlayerDamage + Item(GetPlayerInvItemNum(Index, WeaponSlot)).Data2

        Call SetPlayerInvItemDur(Index, WeaponSlot, GetPlayerInvItemDur(Index, WeaponSlot) - 1)

        If GetPlayerInvItemDur(Index, WeaponSlot) <= 0 Then
            Call PlayerMsg(Index, "Your " & Trim$(Item(GetPlayerInvItemNum(Index, WeaponSlot)).Name) & " has broken.", Yellow)
            Call SetPlayerWeaponSlot(Index, 0)
            Call SendWornEquipment(Index)
        Else
            If GetPlayerInvItemDur(Index, WeaponSlot) <= 5 Then
                Call PlayerMsg(Index, "Your " & Trim$(Item(GetPlayerInvItemNum(Index, WeaponSlot)).Name) & " is about to break!", Yellow)
            End If
        End If
    End If
End Function

Function GetPlayerProtection(ByVal Index As Long) As Long
    Dim ArmorSlot As Long, HelmSlot As Long

    GetPlayerProtection = 0

    ' Check for subscript out of range
    If IsPlaying(Index) = False Or Index <= 0 Or Index > MAX_PLAYERS Then
        Exit Function
    End If

    ArmorSlot = GetPlayerArmorSlot(Index)
    HelmSlot = GetPlayerHelmetSlot(Index)
    GetPlayerProtection = Int(GetPlayerDEF(Index) / 5)

    If ArmorSlot > 0 Then
        GetPlayerProtection = GetPlayerProtection + Item(GetPlayerInvItemNum(Index, ArmorSlot)).Data2
        Call SetPlayerInvItemDur(Index, ArmorSlot, GetPlayerInvItemDur(Index, ArmorSlot) - 1)

        If GetPlayerInvItemDur(Index, ArmorSlot) <= 0 Then
            Call PlayerMsg(Index, "Your " & Trim$(Item(GetPlayerInvItemNum(Index, ArmorSlot)).Name) & " has broken.", Yellow)
            Call SetPlayerArmorSlot(Index, 0)
            Call SendWornEquipment(Index)
        Else
            If GetPlayerInvItemDur(Index, ArmorSlot) <= 5 Then
                Call PlayerMsg(Index, "Your " & Trim$(Item(GetPlayerInvItemNum(Index, ArmorSlot)).Name) & " is about to break!", Yellow)
            End If
        End If
    End If

    If HelmSlot > 0 Then
        GetPlayerProtection = GetPlayerProtection + Item(GetPlayerInvItemNum(Index, HelmSlot)).Data2
        Call SetPlayerInvItemDur(Index, HelmSlot, GetPlayerInvItemDur(Index, HelmSlot) - 1)

        If GetPlayerInvItemDur(Index, HelmSlot) <= 0 Then
            Call PlayerMsg(Index, "Your " & Trim$(Item(GetPlayerInvItemNum(Index, HelmSlot)).Name) & " has broken.", Yellow)
            Call SetPlayerHelmetSlot(Index, 0)
            Call SendWornEquipment(Index)
        Else
            If GetPlayerInvItemDur(Index, HelmSlot) <= 5 Then
                Call PlayerMsg(Index, "Your " & Trim$(Item(GetPlayerInvItemNum(Index, HelmSlot)).Name) & " is about to break!", Yellow)
            End If
        End If
    End If
End Function

Function FindOpenPlayerSlot() As Long
    Dim I As Long

    FindOpenPlayerSlot = 0

    For I = 1 To MAX_PLAYERS
        If Not IsConnected(I) Then
            FindOpenPlayerSlot = I
            Exit Function
        End If
    Next I
End Function

Function FindOpenInvSlot(ByVal Index As Long, ByVal ItemNum As Long) As Long
    Dim I As Long

    FindOpenInvSlot = 0

    ' Check for subscript out of range
    If IsPlaying(Index) = False Or ItemNum <= 0 Or ItemNum > MAX_ITEMS Then
        Exit Function
    End If

    If Item(ItemNum).Type = ITEM_TYPE_CURRENCY Then
        ' If currency then check to see if they already have an instance of the item and add it to that
        For I = 1 To MAX_INV
            If GetPlayerInvItemNum(Index, I) = ItemNum Then
                FindOpenInvSlot = I
                Exit Function
            End If
        Next I
    End If

    For I = 1 To MAX_INV
        ' Try to find an open free slot
        If GetPlayerInvItemNum(Index, I) = 0 Then
            FindOpenInvSlot = I
            Exit Function
        End If
    Next I
End Function

Function FindOpenMapItemSlot(ByVal MapNum As Long) As Long
    Dim I As Long

    FindOpenMapItemSlot = 0

    ' Check for subscript out of range
    If MapNum <= 0 Or MapNum > MAX_MAPS_SET Then
        Exit Function
    End If

    For I = 1 To MAX_MAP_ITEMS
        If MapItem(MapNum, I).Num = 0 Then
            FindOpenMapItemSlot = I
            Exit Function
        End If
    Next I
End Function

Function FindOpenSpellSlot(ByVal Index As Long) As Long
    Dim I As Long

    FindOpenSpellSlot = 0

    For I = 1 To MAX_PLAYER_SPELLS
        If GetPlayerSpell(Index, I) = 0 Then
            FindOpenSpellSlot = I
            Exit Function
        End If
    Next I
End Function

Function FindOpenGuildSlot(ByVal Index As Long) As Long
    Dim I As Long

    FindOpenGuildSlot = 0

    For I = 1 To MAX_GUILD_MEMBERS
        If Guild(Index).Member(I) = "" Then
            FindOpenGuildSlot = I
            Exit Function
        End If
    Next I
End Function

Function FindOpenQuestSlot(ByVal Index As Long) As Long
    Dim I As Long

    FindOpenQuestSlot = 0

    For I = 1 To MAX_QUEST_PLAYERS
        If Quest(Index).Player(I) = "" Then
            FindOpenQuestSlot = I
            Exit Function
        End If
    Next I
End Function

Function HasSpell(ByVal Index As Long, ByVal SpellNum As Long) As Boolean
    Dim I As Long

    HasSpell = False

    For I = 1 To MAX_PLAYER_SPELLS
        If GetPlayerSpell(Index, I) = SpellNum Then
            HasSpell = True
            Exit Function
        End If
    Next I
End Function

Function TotalOnlinePlayers() As Long
    Dim I As Long

    frmServer.lstPlayers.Clear
    frmServer.lstAccounts.Clear
    TotalOnlinePlayers = 0

    For I = 1 To HighIndex
        If IsPlaying(I) Then
            TotalOnlinePlayers = TotalOnlinePlayers + 1
            frmServer.lstPlayers.AddItem Trim(Player(I).Char(Player(I).CharNum).Name)
            frmServer.lstAccounts.AddItem Trim(Player(I).Login)
        End If
    Next I
End Function

Function FindPlayer(ByVal Name As String) As Long
    Dim I As Long

    For I = 1 To HighIndex
        If IsPlaying(I) Then
            ' Make sure we dont try to check a name thats to small
            If Len(GetPlayerName(I)) >= Len(Trim$(Name)) Then
                If UCase$(Mid$(GetPlayerName(I), 1, Len(Trim$(Name)))) = UCase$(Trim$(Name)) Then
                    FindPlayer = I
                    Exit Function
                End If
            End If
        End If
    Next I

    FindPlayer = 0
End Function

Function HasItem(ByVal Index As Long, ByVal ItemNum As Long) As Long
    Dim I As Long
    Dim p As Long

    HasItem = 0

    ' Check for subscript out of range
    If IsPlaying(Index) = False Or ItemNum <= 0 Or ItemNum > MAX_ITEMS Then
        Exit Function
    End If

    For I = 1 To MAX_INV
        p = GetPlayerInvItemNum(Index, I)
        ' Check to see if the player has the item
        If p = ItemNum Then
            If Item(ItemNum).Type = ITEM_TYPE_CURRENCY Then
                HasItem = GetPlayerInvItemValue(Index, I)
            Else
                HasItem = 1
            End If
            Exit Function
        End If
    Next I
End Function

Sub TakeItem(ByVal Index As Long, ByVal ItemNum As Long, ByVal ItemVal As Long)
    Dim I As Long, N As Long
    Dim TakeItem As Boolean

    TakeItem = False

    ' Check for subscript out of range
    If IsPlaying(Index) = False Or ItemNum <= 0 Or ItemNum > MAX_ITEMS Then
        Exit Sub
    End If

    For I = 1 To MAX_INV
        ' Check to see if the player has the item
        If GetPlayerInvItemNum(Index, I) = ItemNum Then
            If Item(ItemNum).Type = ITEM_TYPE_CURRENCY Then
                ' Is what we are trying to take away more then what they have?  If so just set it to zero
                If ItemVal >= GetPlayerInvItemValue(Index, I) Then
                    TakeItem = True
                Else
                    Call SetPlayerInvItemValue(Index, I, GetPlayerInvItemValue(Index, I) - ItemVal)
                    Call SendInventoryUpdate(Index, I)
                End If
            Else
                ' Check to see if its any sort of ArmorSlot/WeaponSlot
                Select Case Item(GetPlayerInvItemNum(Index, I)).Type
                    Case ITEM_TYPE_WEAPON
                        If GetPlayerWeaponSlot(Index) > 0 Then
                            If I = GetPlayerWeaponSlot(Index) Then
                                Call SetPlayerWeaponSlot(Index, 0)
                                Call SendWornEquipment(Index)
                                TakeItem = True
                            Else
                                ' Check if the item we are taking isn't already equipped
                                If ItemNum <> GetPlayerInvItemNum(Index, GetPlayerWeaponSlot(Index)) Then
                                    TakeItem = True
                                End If
                            End If
                        Else
                            TakeItem = True
                        End If

                    Case ITEM_TYPE_ARMOR
                        If GetPlayerArmorSlot(Index) > 0 Then
                            If I = GetPlayerArmorSlot(Index) Then
                                Call SetPlayerArmorSlot(Index, 0)
                                Call SendWornEquipment(Index)
                                TakeItem = True
                            Else
                                ' Check if the item we are taking isn't already equipped
                                If ItemNum <> GetPlayerInvItemNum(Index, GetPlayerArmorSlot(Index)) Then
                                    TakeItem = True
                                End If
                            End If
                        Else
                            TakeItem = True
                        End If

                    Case ITEM_TYPE_HELMET
                        If GetPlayerHelmetSlot(Index) > 0 Then
                            If I = GetPlayerHelmetSlot(Index) Then
                                Call SetPlayerHelmetSlot(Index, 0)
                                Call SendWornEquipment(Index)
                                TakeItem = True
                            Else
                                ' Check if the item we are taking isn't already equipped
                                If ItemNum <> GetPlayerInvItemNum(Index, GetPlayerHelmetSlot(Index)) Then
                                    TakeItem = True
                                End If
                            End If
                        Else
                            TakeItem = True
                        End If

                    Case ITEM_TYPE_SHIELD
                        If GetPlayerShieldSlot(Index) > 0 Then
                            If I = GetPlayerShieldSlot(Index) Then
                                Call SetPlayerShieldSlot(Index, 0)
                                Call SendWornEquipment(Index)
                                TakeItem = True
                            Else
                                ' Check if the item we are taking isn't already equipped
                                If ItemNum <> GetPlayerInvItemNum(Index, GetPlayerShieldSlot(Index)) Then
                                    TakeItem = True
                                End If
                            End If
                        Else
                            TakeItem = True
                        End If
                End Select


                N = Item(GetPlayerInvItemNum(Index, I)).Type
                ' Check if its not an equipable weapon, and if it isn't then take it away
                If (N <> ITEM_TYPE_WEAPON) And (N <> ITEM_TYPE_ARMOR) And (N <> ITEM_TYPE_HELMET) And (N <> ITEM_TYPE_SHIELD) Then
                    TakeItem = True
                End If
            End If

            If TakeItem = True Then
                Call SetPlayerInvItemNum(Index, I, 0)
                Call SetPlayerInvItemValue(Index, I, 0)
                Call SetPlayerInvItemDur(Index, I, 0)

                ' Send the inventory update
                Call SendInventoryUpdate(Index, I)
                Exit Sub
            End If
        End If
    Next I
End Sub

Sub GiveItem(ByVal Index As Long, ByVal ItemNum As Long, ByVal ItemVal As Long)
    Dim I As Long

    ' Check for subscript out of range
    If IsPlaying(Index) = False Or ItemNum <= 0 Or ItemNum > MAX_ITEMS Then
        Exit Sub
    End If

    I = FindOpenInvSlot(Index, ItemNum)

    ' Check to see if inventory is full
    If I <> 0 Then
        Call SetPlayerInvItemNum(Index, I, ItemNum)
        Call SetPlayerInvItemValue(Index, I, GetPlayerInvItemValue(Index, I) + ItemVal)

        If (Item(ItemNum).Type = ITEM_TYPE_ARMOR) Or (Item(ItemNum).Type = ITEM_TYPE_WEAPON) Or (Item(ItemNum).Type = ITEM_TYPE_HELMET) Or (Item(ItemNum).Type = ITEM_TYPE_SHIELD) Then
            Call SetPlayerInvItemDur(Index, I, Item(ItemNum).Data1)
        End If

        Call SendInventoryUpdate(Index, I)
    Else
        Call PlayerMsg(Index, "Your inventory is full.", BrightRed)
    End If
End Sub

Sub SpawnItem(ByVal ItemNum As Long, ByVal ItemVal As Long, ByVal MapNum As Long, ByVal X As Long, ByVal y As Long)
    Dim I As Long

    ' Check for subscript out of range
    If ItemNum < 0 Or ItemNum > MAX_ITEMS Or MapNum <= 0 Or MapNum > MAX_MAPS_SET Then
        Exit Sub
    End If

    ' Find open map item slot
    I = FindOpenMapItemSlot(MapNum)

    Call SpawnItemSlot(I, ItemNum, ItemVal, Item(ItemNum).Data1, MapNum, X, y)
End Sub

Sub SpawnItemSlot(ByVal MapItemSlot As Long, ByVal ItemNum As Long, ByVal ItemVal As Long, ByVal ItemDur As Long, ByVal MapNum As Long, ByVal X As Long, ByVal y As Long)
    Dim Packet As String
    Dim I As Long

    ' Check for subscript out of range
    If MapItemSlot <= 0 Or MapItemSlot > MAX_MAP_ITEMS Or ItemNum < 0 Or ItemNum > MAX_ITEMS Or MapNum <= 0 Or MapNum > MAX_MAPS_SET Then
        Exit Sub
    End If

    I = MapItemSlot

    If I <> 0 And ItemNum >= 0 And ItemNum <= MAX_ITEMS Then
        MapItem(MapNum, I).Num = ItemNum
        MapItem(MapNum, I).Value = ItemVal

        If ItemNum <> 0 Then
            If (Item(ItemNum).Type >= ITEM_TYPE_WEAPON) And (Item(ItemNum).Type <= ITEM_TYPE_SHIELD) Then
                MapItem(MapNum, I).Dur = ItemDur
            Else
                MapItem(MapNum, I).Dur = 0
            End If
        Else
            MapItem(MapNum, I).Dur = 0
        End If

        MapItem(MapNum, I).X = X
        MapItem(MapNum, I).y = y

        Packet = "SPAWNITEM" & SEP_CHAR & I & SEP_CHAR & ItemNum & SEP_CHAR & ItemVal & SEP_CHAR & MapItem(MapNum, I).Dur & SEP_CHAR & X & SEP_CHAR & y & END_CHAR
        Call SendDataToMap(MapNum, Packet)
    End If
End Sub

Sub SpawnAllMapsItems()
    Dim I As Long

    For I = 1 To MAX_MAPS_SET
        Call SpawnMapItems(I)
    Next I
End Sub

Sub SpawnMapItems(ByVal MapNum As Long)
    Dim X As Long
    Dim y As Long
    Dim I As Long

    ' Check for subscript out of range
    If MapNum <= 0 Or MapNum > MAX_MAPS_SET Then
        Exit Sub
    End If

    ' Spawn what we have
    For y = 0 To MAX_MAPY
        For X = 0 To MAX_MAPX
            ' Check if the tile type is an item or a saved tile incase someone drops something
            If (Map(MapNum).Tile(X, y).Type = TILE_TYPE_ITEM) Then
                ' Check to see if its a currency and if they set the value to 0 set it to 1 automatically
                If Item(Map(MapNum).Tile(X, y).Data1).Type = ITEM_TYPE_CURRENCY And Map(MapNum).Tile(X, y).Data2 <= 0 Then
                    Call SpawnItem(Map(MapNum).Tile(X, y).Data1, 1, MapNum, X, y)
                Else
                    Call SpawnItem(Map(MapNum).Tile(X, y).Data1, Map(MapNum).Tile(X, y).Data2, MapNum, X, y)
                End If
            End If
        Next X
    Next y
End Sub

Sub PlayerMapGetItem(ByVal Index As Long)
    Dim I As Long
    Dim N As Long
    Dim MapNum As Long
    Dim Msg As String

    If IsPlaying(Index) = False Then
        Exit Sub
    End If

    MapNum = GetPlayerMap(Index)

    For I = 1 To MAX_MAP_ITEMS
        ' See if theres even an item here
        If (MapItem(MapNum, I).Num > 0) And (MapItem(MapNum, I).Num <= MAX_ITEMS) Then
            ' Check if item is at the same location as the player
            If (MapItem(MapNum, I).X = GetPlayerX(Index)) And (MapItem(MapNum, I).y = GetPlayerY(Index)) Then
                ' Find open slot
                N = FindOpenInvSlot(Index, MapItem(MapNum, I).Num)

                ' Open slot available?
                If N <> 0 Then
                    ' Set item in players inventor
                    Call SetPlayerInvItemNum(Index, N, MapItem(MapNum, I).Num)
                    If Item(GetPlayerInvItemNum(Index, N)).Type = ITEM_TYPE_CURRENCY Then
                        Call SetPlayerInvItemValue(Index, N, GetPlayerInvItemValue(Index, N) + MapItem(MapNum, I).Value)
                        Msg = "You picked up " & MapItem(MapNum, I).Value & " " & Trim$(Item(GetPlayerInvItemNum(Index, N)).Name) & "."
                    Else
                        Call SetPlayerInvItemValue(Index, N, 0)
                        If IsVowel(Item(GetPlayerInvItemNum(Index, N)).Name) = True Then
                            Msg = "You picked up an " & Trim$(Item(GetPlayerInvItemNum(Index, N)).Name) & "."
                        Else
                            Msg = "You picked up a " & Trim$(Item(GetPlayerInvItemNum(Index, N)).Name) & "."
                        End If
                    End If
                    Call SetPlayerInvItemDur(Index, N, MapItem(MapNum, I).Dur)

                    ' Erase item from the map
                    MapItem(MapNum, I).Num = 0
                    MapItem(MapNum, I).Value = 0
                    MapItem(MapNum, I).Dur = 0
                    MapItem(MapNum, I).X = 0
                    MapItem(MapNum, I).y = 0

                    Call SendInventoryUpdate(Index, N)
                    Call SpawnItemSlot(I, 0, 0, 0, GetPlayerMap(Index), GetPlayerX(Index), GetPlayerY(Index))
                    Call PlayerMsg(Index, Msg, Yellow)
                    Exit Sub
                Else
                    Call PlayerMsg(Index, "Your inventory is full.", BrightRed)
                    Exit Sub
                End If
            End If
        End If
    Next I
End Sub

Sub PlayerMapDropItem(ByVal Index As Long, ByVal InvNum As Long, ByVal Ammount As Long)
    Dim I As Long

    ' Check for subscript out of range
    If IsPlaying(Index) = False Or InvNum <= 0 Or InvNum > MAX_INV Then
        Exit Sub
    End If

    If (GetPlayerInvItemNum(Index, InvNum) > 0) And (GetPlayerInvItemNum(Index, InvNum) <= MAX_ITEMS) Then
        I = FindOpenMapItemSlot(GetPlayerMap(Index))

        If I <> 0 Then
            MapItem(GetPlayerMap(Index), I).Dur = 0

            ' Check to see if its any sort of ArmorSlot/WeaponSlot
            Select Case Item(GetPlayerInvItemNum(Index, InvNum)).Type
                Case ITEM_TYPE_ARMOR
                    If InvNum = GetPlayerArmorSlot(Index) Then
                        Call SetPlayerArmorSlot(Index, 0)
                        Call SendWornEquipment(Index)
                    End If
                    MapItem(GetPlayerMap(Index), I).Dur = GetPlayerInvItemDur(Index, InvNum)

                Case ITEM_TYPE_WEAPON
                    If InvNum = GetPlayerWeaponSlot(Index) Then
                        Call SetPlayerWeaponSlot(Index, 0)
                        Call SendWornEquipment(Index)
                    End If
                    MapItem(GetPlayerMap(Index), I).Dur = GetPlayerInvItemDur(Index, InvNum)

                Case ITEM_TYPE_HELMET
                    If InvNum = GetPlayerHelmetSlot(Index) Then
                        Call SetPlayerHelmetSlot(Index, 0)
                        Call SendWornEquipment(Index)
                    End If
                    MapItem(GetPlayerMap(Index), I).Dur = GetPlayerInvItemDur(Index, InvNum)

                Case ITEM_TYPE_SHIELD
                    If InvNum = GetPlayerShieldSlot(Index) Then
                        Call SetPlayerShieldSlot(Index, 0)
                        Call SendWornEquipment(Index)
                    End If
                    MapItem(GetPlayerMap(Index), I).Dur = GetPlayerInvItemDur(Index, InvNum)
            End Select

            MapItem(GetPlayerMap(Index), I).Num = GetPlayerInvItemNum(Index, InvNum)
            MapItem(GetPlayerMap(Index), I).X = GetPlayerX(Index)
            MapItem(GetPlayerMap(Index), I).y = GetPlayerY(Index)

            If Item(GetPlayerInvItemNum(Index, InvNum)).Type = ITEM_TYPE_CURRENCY Then
                ' Check if its more then they have and if so drop it all
                If Ammount >= GetPlayerInvItemValue(Index, InvNum) Then
                    MapItem(GetPlayerMap(Index), I).Value = GetPlayerInvItemValue(Index, InvNum)
                    Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " drops " & GetPlayerInvItemValue(Index, InvNum) & " " & Trim$(Item(GetPlayerInvItemNum(Index, InvNum)).Name) & ".", Yellow)
                    Call SetPlayerInvItemNum(Index, InvNum, 0)
                    Call SetPlayerInvItemValue(Index, InvNum, 0)
                    Call SetPlayerInvItemDur(Index, InvNum, 0)
                Else
                    MapItem(GetPlayerMap(Index), I).Value = Ammount
                    Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " drops " & Ammount & " " & Trim$(Item(GetPlayerInvItemNum(Index, InvNum)).Name) & ".", Yellow)
                    Call SetPlayerInvItemValue(Index, InvNum, GetPlayerInvItemValue(Index, InvNum) - Ammount)
                End If
            Else
                ' Its not a currency object so this is easy
                MapItem(GetPlayerMap(Index), I).Value = 0
                If Item(GetPlayerInvItemNum(Index, InvNum)).Type >= ITEM_TYPE_WEAPON And Item(GetPlayerInvItemNum(Index, InvNum)).Type <= ITEM_TYPE_SHIELD Then
                    If IsVowel(Item(GetPlayerInvItemNum(Index, InvNum)).Name) = True Then
                        Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " drops an " & Trim$(Item(GetPlayerInvItemNum(Index, InvNum)).Name) & " " & GetPlayerInvItemDur(Index, InvNum) & "/" & Item(GetPlayerInvItemNum(Index, InvNum)).Data1 & ".", Yellow)
                    Else
                        Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " drops a " & Trim$(Item(GetPlayerInvItemNum(Index, InvNum)).Name) & " " & GetPlayerInvItemDur(Index, InvNum) & "/" & Item(GetPlayerInvItemNum(Index, InvNum)).Data1 & ".", Yellow)
                    End If
                Else
                    If IsVowel(Item(GetPlayerInvItemNum(Index, InvNum)).Name) = True Then
                        Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " drops an " & Trim$(Item(GetPlayerInvItemNum(Index, InvNum)).Name) & ".", Yellow)
                    Else
                        Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " drops a " & Trim$(Item(GetPlayerInvItemNum(Index, InvNum)).Name) & ".", Yellow)
                    End If
                End If

                Call SetPlayerInvItemNum(Index, InvNum, 0)
                Call SetPlayerInvItemValue(Index, InvNum, 0)
                Call SetPlayerInvItemDur(Index, InvNum, 0)
            End If

            ' Send inventory update
            Call SendInventoryUpdate(Index, InvNum)
            ' Spawn the item before we set the num or we'll get a different free map item slot
            Call SpawnItemSlot(I, MapItem(GetPlayerMap(Index), I).Num, Ammount, MapItem(GetPlayerMap(Index), I).Dur, GetPlayerMap(Index), GetPlayerX(Index), GetPlayerY(Index))
        
            MyScript.ExecuteStatement "\scripts\Main.as", "OnItemDrop " & Index & "," & MapItem(GetPlayerMap(Index), I).Num & "," & MapItem(GetPlayerMap(Index), I).Value & "," & MapItem(GetPlayerMap(Index), I).Dur & "," & InvNum
        
        Else
            Call PlayerMsg(Index, "To many items already on the ground.", BrightRed)
        End If
    End If
End Sub

Sub SpawnNpc(ByVal MapNpcNum As Long, ByVal MapNum As Long)
    Dim Packet As String
    Dim NpcNum As Long
    Dim I As Long, X As Long, y As Long
    Dim Spawned As Boolean

    ' Check for subscript out of range
    If MapNpcNum <= 0 Or MapNpcNum > MAX_MAP_NPCS Or MapNum <= 0 Or MapNum > MAX_MAPS_SET Then
        Exit Sub
    End If

    Spawned = False

    NpcNum = Map(MapNum).Npc(MapNpcNum)
    If NpcNum > 0 Then
        MapNpc(MapNum, MapNpcNum).Num = NpcNum
        MapNpc(MapNum, MapNpcNum).Target = 0

        MapNpc(MapNum, MapNpcNum).HP = GetNpcMaxHP(NpcNum)
        MapNpc(MapNum, MapNpcNum).MP = GetNpcMaxMP(NpcNum)
        MapNpc(MapNum, MapNpcNum).SP = GetNpcMaxSP(NpcNum)

        MapNpc(MapNum, MapNpcNum).Dir = Int(Rnd * 4)

        ' Check if theres a spawn tile for the specific npc
        For X = 0 To MAX_MAPX
            For y = 0 To MAX_MAPY
                If Map(MapNum).Tile(X, y).Type = TILE_TYPE_NPCSPAWN Then
                    If Map(MapNum).Tile(X, y).Data1 = MapNpcNum Then
                        MapNpc(MapNum, MapNpcNum).X = X
                        MapNpc(MapNum, MapNpcNum).y = y
                        MapNpc(MapNum, MapNpcNum).Dir = Map(MapNum).Tile(X, y).Data2
                        MapNpc(MapNum, MapNpcNum).Moveable = Map(MapNum).Tile(X, y).Data3
                        Spawned = True
                        Exit For
                    End If
                End If
            Next y
        Next X

' If Map(MapNum).Tile(x, y).Type <> TILE_TYPE_NPCSPAWN Then
' MapNpc(MapNum, MapNpcNum).Moveable = 0
' End If

        ' Well try 100 times to randomly place the sprite
        If Not Spawned Then
            ' Well try 100 times to randomly place the sprite
            For I = 1 To 100
                X = Int(Rnd * MAX_MAPX)
                y = Int(Rnd * MAX_MAPY)

                ' Check if the tile is walkable
                If Map(MapNum).Tile(X, y).Type = TILE_TYPE_WALKABLE Then
                    MapNpc(MapNum, MapNpcNum).X = X
                    MapNpc(MapNum, MapNpcNum).y = y
                    Spawned = True
                    Exit For
                End If
            Next I
        End If

        ' Didn't spawn, so now we'll just try to find a free tile
        If Not Spawned Then
            For y = 0 To MAX_MAPY
                For X = 0 To MAX_MAPX
                    If Map(MapNum).Tile(X, y).Type = TILE_TYPE_WALKABLE Then
                        MapNpc(MapNum, MapNpcNum).X = X
                        MapNpc(MapNum, MapNpcNum).y = y
                        Spawned = True
                    End If
                Next X
            Next y
        End If

        ' If we suceeded in spawning then send it to everyone
        If Spawned Then
            Packet = "SPAWNNPC" & SEP_CHAR & MapNpcNum & SEP_CHAR & MapNpc(MapNum, MapNpcNum).Num & SEP_CHAR & MapNpc(MapNum, MapNpcNum).X & SEP_CHAR & MapNpc(MapNum, MapNpcNum).y & SEP_CHAR & MapNpc(MapNum, MapNpcNum).Dir & END_CHAR
            Call SendDataToMap(MapNum, Packet)
        End If
    End If
End Sub

Sub SpawnMapNpcs(ByVal MapNum As Long)
    Dim I As Long

    For I = 1 To MAX_MAP_NPCS
        Call SpawnNpc(I, MapNum)
    Next I
End Sub

Sub SpawnAllMapNpcs()
    Dim I As Long

    For I = 1 To MAX_MAPS_SET
        Call SpawnMapNpcs(I)
    Next I
End Sub

Function CanAttackPlayer(ByVal Attacker As Long, ByVal Victim As Long) As Boolean
    CanAttackPlayer = False

    ' Check for subscript out of range
    If IsPlaying(Attacker) = False Or IsPlaying(Victim) = False Then
        Exit Function
    End If

    ' Make sure they have more then 0 hp
    If GetPlayerHP(Victim) <= 0 Then
        Exit Function
    End If

    ' Make sure we dont attack the player if they are switching maps
    If Player(Victim).GettingMap = YES Then
        Exit Function
    End If

    ' Make sure they are on the same map
    If (GetPlayerMap(Attacker) = GetPlayerMap(Victim)) And (GetTickCount > Player(Attacker).AttackTimer + 950) Then

        ' Check if at same coordinates
        Select Case GetPlayerDir(Attacker)
            Case DIR_UP
                If (GetPlayerY(Victim) + 1 = GetPlayerY(Attacker)) And (GetPlayerX(Victim) = GetPlayerX(Attacker)) Then
                    ' Check to make sure that they dont have access
                    If GetPlayerAccess(Attacker) > ADMIN_MONITER Then
                        Call PlayerMsg(Attacker, "You cannot attack any player for thou art an admin!", BrightBlue)
                    Else
                        ' Check to make sure the victim isn't an admin
                        If GetPlayerAccess(Victim) > ADMIN_MONITER Then
                            Call PlayerMsg(Attacker, "You cannot attack " & GetPlayerName(Victim) & "!", BrightRed)
                        Else
                            ' Check if map is attackable
                            If Map(GetPlayerMap(Attacker)).Moral = MAP_MORAL_NONE Or Map(GetPlayerMap(Attacker)).Moral = MAP_MORAL_ARENA Or GetPlayerPK(Victim) = YES Then
                                ' Make sure they are high enough level
                                If GetPlayerLevel(Attacker) < 10 Then
                                    Call PlayerMsg(Attacker, "You are below level 10, you cannot attack another player yet!", BrightRed)
                                Else
                                    If GetPlayerLevel(Victim) < 10 Then
                                        Call PlayerMsg(Attacker, GetPlayerName(Victim) & " is below level 10, you cannot attack this player yet!", BrightRed)
                                    Else
                                        CanAttackPlayer = True
                                    End If
                                End If
                            Else
                                Call PlayerMsg(Attacker, "This is a safe zone!", BrightRed)
                            End If
                        End If
                    End If
                End If

            Case DIR_DOWN
                If (GetPlayerY(Victim) - 1 = GetPlayerY(Attacker)) And (GetPlayerX(Victim) = GetPlayerX(Attacker)) Then
                    ' Check to make sure that they dont have access
                    If GetPlayerAccess(Attacker) > ADMIN_MONITER Then
                        Call PlayerMsg(Attacker, "You cannot attack any player for thou art an admin!", BrightBlue)
                    Else
                        ' Check to make sure the victim isn't an admin
                        If GetPlayerAccess(Victim) > ADMIN_MONITER Then
                            Call PlayerMsg(Attacker, "You cannot attack " & GetPlayerName(Victim) & "!", BrightRed)
                        Else
                            ' Check if map is attackable
                            If Map(GetPlayerMap(Attacker)).Moral = MAP_MORAL_NONE Or Map(GetPlayerMap(Attacker)).Moral = MAP_MORAL_ARENA Or GetPlayerPK(Victim) = YES Then
                                ' Make sure they are high enough level
                                If GetPlayerLevel(Attacker) < 10 Then
                                    Call PlayerMsg(Attacker, "You are below level 10, you cannot attack another player yet!", BrightRed)
                                Else
                                    If GetPlayerLevel(Victim) < 10 Then
                                        Call PlayerMsg(Attacker, GetPlayerName(Victim) & " is below level 10, you cannot attack this player yet!", BrightRed)
                                    Else
                                        CanAttackPlayer = True
                                    End If
                                End If
                            Else
                                Call PlayerMsg(Attacker, "This is a safe zone!", BrightRed)
                            End If
                        End If
                    End If
                End If

            Case DIR_LEFT
                If (GetPlayerY(Victim) = GetPlayerY(Attacker)) And (GetPlayerX(Victim) + 1 = GetPlayerX(Attacker)) Then
                    ' Check to make sure that they dont have access
                    If GetPlayerAccess(Attacker) > ADMIN_MONITER Then
                        Call PlayerMsg(Attacker, "You cannot attack any player for thou art an admin!", BrightBlue)
                    Else
                        ' Check to make sure the victim isn't an admin
                        If GetPlayerAccess(Victim) > ADMIN_MONITER Then
                            Call PlayerMsg(Attacker, "You cannot attack " & GetPlayerName(Victim) & "!", BrightRed)
                        Else
                            ' Check if map is attackable
                            If Map(GetPlayerMap(Attacker)).Moral = MAP_MORAL_NONE Or Map(GetPlayerMap(Attacker)).Moral = MAP_MORAL_ARENA Or GetPlayerPK(Victim) = YES Then
                                ' Make sure they are high enough level
                                If GetPlayerLevel(Attacker) < 10 Then
                                    Call PlayerMsg(Attacker, "You are below level 10, you cannot attack another player yet!", BrightRed)
                                Else
                                    If GetPlayerLevel(Victim) < 10 Then
                                        Call PlayerMsg(Attacker, GetPlayerName(Victim) & " is below level 10, you cannot attack this player yet!", BrightRed)
                                    Else
                                        CanAttackPlayer = True
                                    End If
                                End If
                            Else
                                Call PlayerMsg(Attacker, "This is a safe zone!", BrightRed)
                            End If
                        End If
                    End If
                End If

            Case DIR_RIGHT
                If (GetPlayerY(Victim) = GetPlayerY(Attacker)) And (GetPlayerX(Victim) - 1 = GetPlayerX(Attacker)) Then
                    ' Check to make sure that they dont have access
                    If GetPlayerAccess(Attacker) > ADMIN_MONITER Then
                        Call PlayerMsg(Attacker, "You cannot attack any player for thou art an admin!", BrightBlue)
                    Else
                        ' Check to make sure the victim isn't an admin
                        If GetPlayerAccess(Victim) > ADMIN_MONITER Then
                            Call PlayerMsg(Attacker, "You cannot attack " & GetPlayerName(Victim) & "!", BrightRed)
                        Else
                            ' Check if map is attackable
                            If Map(GetPlayerMap(Attacker)).Moral = MAP_MORAL_NONE Or Map(GetPlayerMap(Attacker)).Moral = MAP_MORAL_ARENA Or GetPlayerPK(Victim) = YES Then
                                ' Make sure they are high enough level
                                If GetPlayerLevel(Attacker) < 10 Then
                                    Call PlayerMsg(Attacker, "You are below level 10, you cannot attack another player yet!", BrightRed)
                                Else
                                    If GetPlayerLevel(Victim) < 10 Then
                                        Call PlayerMsg(Attacker, GetPlayerName(Victim) & " is below level 10, you cannot attack this player yet!", BrightRed)
                                    Else
                                        CanAttackPlayer = True
                                    End If
                                End If
                            Else
                                Call PlayerMsg(Attacker, "This is a safe zone!", BrightRed)
                            End If
                        End If
                    End If
                End If
        End Select
    End If
End Function

Function CanAttackNpc(ByVal Attacker As Long, ByVal MapNpcNum As Long) As Boolean
    Dim MapNum As Long, NpcNum As Long

    CanAttackNpc = False

    ' Check for subscript out of range
    If IsPlaying(Attacker) = False Or MapNpcNum <= 0 Or MapNpcNum > MAX_MAP_NPCS Then
        Exit Function
    End If

    ' Check for subscript out of range
    If MapNpc(GetPlayerMap(Attacker), MapNpcNum).Num <= 0 Then
        Exit Function
    End If

    MapNum = GetPlayerMap(Attacker)
    NpcNum = MapNpc(MapNum, MapNpcNum).Num

    ' Make sure the npc isn't already dead
    If MapNpc(MapNum, MapNpcNum).HP <= 0 Then
        Exit Function
    End If

    ' Make sure they are on the same map
    If IsPlaying(Attacker) Then
        If NpcNum > 0 And GetTickCount > Player(Attacker).AttackTimer + 950 Then
            ' Check if at same coordinates
            Select Case GetPlayerDir(Attacker)
                Case DIR_UP
                    If (MapNpc(MapNum, MapNpcNum).y + 1 = GetPlayerY(Attacker)) And (MapNpc(MapNum, MapNpcNum).X = GetPlayerX(Attacker)) Then
                        If Npc(NpcNum).Behavior <> NPC_BEHAVIOR_FRIENDLY And Npc(NpcNum).Behavior <> NPC_BEHAVIOR_SHOPKEEPER Then
                            CanAttackNpc = True
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If
                        ElseIf Npc(NpcNum).Behavior = NPC_BEHAVIOR_SHOPKEEPER Then
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call SendTrade(Attacker, Npc(NpcNum).ShopCall)
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call SendTrade(Attacker, Npc(NpcNum).ShopCall)
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If

                        ElseIf Npc(NpcNum).Behavior = NPC_BEHAVIOR_FRIENDLY Then
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If
                        End If
                    End If

                Case DIR_DOWN
                    If (MapNpc(MapNum, MapNpcNum).y - 1 = GetPlayerY(Attacker)) And (MapNpc(MapNum, MapNpcNum).X = GetPlayerX(Attacker)) Then
                        If Npc(NpcNum).Behavior <> NPC_BEHAVIOR_FRIENDLY And Npc(NpcNum).Behavior <> NPC_BEHAVIOR_SHOPKEEPER Then
                            CanAttackNpc = True
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If
                        ElseIf Npc(NpcNum).Behavior = NPC_BEHAVIOR_SHOPKEEPER Then
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call SendTrade(Attacker, Npc(NpcNum).ShopCall)
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call SendTrade(Attacker, Npc(NpcNum).ShopCall)
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If
                        ElseIf Npc(NpcNum).Behavior = NPC_BEHAVIOR_FRIENDLY Then
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If
                        End If
                    End If

                Case DIR_LEFT
                    If (MapNpc(MapNum, MapNpcNum).y = GetPlayerY(Attacker)) And (MapNpc(MapNum, MapNpcNum).X + 1 = GetPlayerX(Attacker)) Then
                        If Npc(NpcNum).Behavior <> NPC_BEHAVIOR_FRIENDLY And Npc(NpcNum).Behavior <> NPC_BEHAVIOR_SHOPKEEPER Then
                            CanAttackNpc = True
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If
                        ElseIf Npc(NpcNum).Behavior = NPC_BEHAVIOR_SHOPKEEPER Then
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call SendTrade(Attacker, Npc(NpcNum).ShopCall)
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call SendTrade(Attacker, Npc(NpcNum).ShopCall)
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If
                        ElseIf Npc(NpcNum).Behavior = NPC_BEHAVIOR_FRIENDLY Then
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If
                        End If
                    End If

                Case DIR_RIGHT
                    If (MapNpc(MapNum, MapNpcNum).y = GetPlayerY(Attacker)) And (MapNpc(MapNum, MapNpcNum).X - 1 = GetPlayerX(Attacker)) Then
                        If Npc(NpcNum).Behavior <> NPC_BEHAVIOR_FRIENDLY And Npc(NpcNum).Behavior <> NPC_BEHAVIOR_SHOPKEEPER Then
                            CanAttackNpc = True
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If
                        ElseIf Npc(NpcNum).Behavior = NPC_BEHAVIOR_SHOPKEEPER Then
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call SendTrade(Attacker, Npc(NpcNum).ShopCall)
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call SendTrade(Attacker, Npc(NpcNum).ShopCall)
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If
                        ElseIf Npc(NpcNum).Behavior = NPC_BEHAVIOR_FRIENDLY Then
                            If IsVowel(Npc(NpcNum).Name) = True Then
                                Call PlayerMsg(Attacker, "An " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            Else
                                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says to you, '" & Trim$(Npc(NpcNum).AttackSay) & ".'", Grey)
                            End If
                        End If
                    End If
            End Select
        End If
    End If
End Function

Function CanNpcAttackPlayer(ByVal MapNpcNum As Long, ByVal Index As Long) As Boolean
    Dim MapNum As Long, NpcNum As Long

    CanNpcAttackPlayer = False

    ' Check for subscript out of range
    If MapNpcNum <= 0 Or MapNpcNum > MAX_MAP_NPCS Or IsPlaying(Index) = False Then
        Exit Function
    End If

    ' Check for subscript out of range
    If MapNpc(GetPlayerMap(Index), MapNpcNum).Num <= 0 Then
        Exit Function
    End If

    MapNum = GetPlayerMap(Index)
    NpcNum = MapNpc(MapNum, MapNpcNum).Num

    ' Make sure the npc isn't already dead
    If MapNpc(MapNum, MapNpcNum).HP <= 0 Then
        Exit Function
    End If

    ' Make sure npcs dont attack more then once a second
    If GetTickCount < MapNpc(MapNum, MapNpcNum).AttackTimer + 1000 Then
        Exit Function
    End If

    ' Make sure we dont attack the player if they are switching maps
    If Player(Index).GettingMap = YES Then
        Exit Function
    End If

    MapNpc(MapNum, MapNpcNum).AttackTimer = GetTickCount

    ' Make sure they are on the same map
    If IsPlaying(Index) Then
        If NpcNum > 0 Then
            ' Check if at same coordinates
            If (GetPlayerY(Index) + 1 = MapNpc(MapNum, MapNpcNum).y) And (GetPlayerX(Index) = MapNpc(MapNum, MapNpcNum).X) Then
                CanNpcAttackPlayer = True
            Else
                If (GetPlayerY(Index) - 1 = MapNpc(MapNum, MapNpcNum).y) And (GetPlayerX(Index) = MapNpc(MapNum, MapNpcNum).X) Then
                    CanNpcAttackPlayer = True
                Else
                    If (GetPlayerY(Index) = MapNpc(MapNum, MapNpcNum).y) And (GetPlayerX(Index) + 1 = MapNpc(MapNum, MapNpcNum).X) Then
                        CanNpcAttackPlayer = True
                    Else
                        If (GetPlayerY(Index) = MapNpc(MapNum, MapNpcNum).y) And (GetPlayerX(Index) - 1 = MapNpc(MapNum, MapNpcNum).X) Then
                            CanNpcAttackPlayer = True
                        End If
                    End If
                End If
            End If

        ' Select Case MapNpc(MapNum, MapNpcNum).Dir
        ' Case DIR_UP
        ' If (GetPlayerY(Index) + 1 = MapNpc(MapNum, MapNpcNum).y) And (GetPlayerX(Index) = MapNpc(MapNum, MapNpcNum).x) Then
        ' CanNpcAttackPlayer = True
        ' End If
        '
        ' Case DIR_DOWN
        ' If (GetPlayerY(Index) - 1 = MapNpc(MapNum, MapNpcNum).y) And (GetPlayerX(Index) = MapNpc(MapNum, MapNpcNum).x) Then
        ' CanNpcAttackPlayer = True
        ' End If
        '
        ' Case DIR_LEFT
        ' If (GetPlayerY(Index) = MapNpc(MapNum, MapNpcNum).y) And (GetPlayerX(Index) + 1 = MapNpc(MapNum, MapNpcNum).x) Then
        ' CanNpcAttackPlayer = True
        ' End If
        '
        ' Case DIR_RIGHT
        ' If (GetPlayerY(Index) = MapNpc(MapNum, MapNpcNum).y) And (GetPlayerX(Index) - 1 = MapNpc(MapNum, MapNpcNum).x) Then
        ' CanNpcAttackPlayer = True
        ' End If
        ' End Select
        End If
    End If
End Function

Sub AttackPlayer(ByVal Attacker As Long, ByVal Victim As Long, ByVal Damage As Long)
    Dim Exp As Long
    Dim N As Long
    Dim I As Long

    ' Check for subscript out of range
    If IsPlaying(Attacker) = False Or IsPlaying(Victim) = False Or Damage < 0 Then
        Exit Sub
    End If

    ' Check for weapon
    If GetPlayerWeaponSlot(Attacker) > 0 Then
        N = GetPlayerInvItemNum(Attacker, GetPlayerWeaponSlot(Attacker))
    Else
        N = 0
    End If

    ' Send this packet so they can see the person attacking
    Call SendDataToMapBut(Attacker, GetPlayerMap(Attacker), "ATTACK" & SEP_CHAR & Attacker & END_CHAR)

    If Damage >= GetPlayerHP(Victim) Then
    
        ' Set HP to nothing
        Call SetPlayerHP(Victim, 0)

        ' Check for a weapon and say damage
        If N = 0 Then
            Call PlayerMsg(Attacker, "You hit " & GetPlayerName(Victim) & " for " & Damage & " hit points.", White)
            Call PlayerMsg(Victim, GetPlayerName(Attacker) & " hit you for " & Damage & " hit points.", BrightRed)
        Else
            If IsVowel(Trim$(Item(N).Name)) Then
                Call PlayerMsg(Attacker, "You hit " & GetPlayerName(Victim) & " with an " & Trim$(Item(N).Name) & " for " & Damage & " hit points.", White)
                Call PlayerMsg(Victim, GetPlayerName(Attacker) & " hit you with an " & Trim$(Item(N).Name) & " for " & Damage & " hit points.", BrightRed)
            Else
                Call PlayerMsg(Attacker, "You hit " & GetPlayerName(Victim) & " with a " & Trim$(Item(N).Name) & " for " & Damage & " hit points.", White)
                Call PlayerMsg(Victim, GetPlayerName(Attacker) & " hit you with a " & Trim$(Item(N).Name) & " for " & Damage & " hit points.", BrightRed)
            End If
        End If

        ' Player is dead
        MyScript.ExecuteStatement "\scripts\Main.as", "OnDeathByPlayer " & Victim & ", " & Attacker & ", " & GetPlayerMap(Attacker) & ", " & Map(GetPlayerMap(Attacker)).Moral
        

        ' Warp player away
        With Map(GetPlayerMap(Victim))
            If .BootMap > 0 And .BootX > 0 And .BootY > 0 Then
                Call PlayerWarp(Victim, .BootMap, .BootX, .BootY)
            Else
                Call PlayerWarp(Victim, START_MAP, START_X, START_Y)
            End If
        End With

        ' Restore vitals
        Call SetPlayerHP(Victim, GetPlayerMaxHP(Victim))
        Call SetPlayerMP(Victim, GetPlayerMaxMP(Victim))
        Call SetPlayerSP(Victim, GetPlayerMaxSP(Victim))
        Call SendHP(Victim)
        Call SendMP(Victim)
        Call SendSP(Victim)
        Call SendExp(Victim)

        ' Check for a level up
        Call CheckPlayerLevelUp(Attacker)

        ' Check if target is player who died and if so set target to 0
        If Player(Attacker).TargetType = TARGET_TYPE_PLAYER And Player(Attacker).Target = Victim Then
            Player(Attacker).Target = 0
            Player(Attacker).TargetType = 0
        End If

        ' Don't deam a PKer if it's an arena
        If Map(GetPlayerMap(Attacker)).Moral <> MAP_MORAL_ARENA Then
            If GetPlayerPK(Victim) = NO Then
                If GetPlayerPK(Attacker) = NO Then
                    Call SetPlayerPK(Attacker, YES)
                    Call SendPlayerData(Attacker)
                    Call GlobalMsg(GetPlayerName(Attacker) & " has been deemed a Player Killer!!!", BrightRed)
                End If
            Else
                Call SetPlayerPK(Victim, NO)
                Call SendPlayerData(Victim)
                Call GlobalMsg(GetPlayerName(Victim) & " has paid the price for being a Player Killer!!!", BrightRed)
            End If
        End If
    Else
        ' Player not dead, just do the damage
        Call SetPlayerHP(Victim, GetPlayerHP(Victim) - Damage)
        Call SendHP(Victim)

        ' Check for a weapon and say damage
        If N = 0 Then
            Call PlayerMsg(Attacker, "You hit " & GetPlayerName(Victim) & " for " & Damage & " hit points.", White)
            Call PlayerMsg(Victim, GetPlayerName(Attacker) & " hit you for " & Damage & " hit points.", BrightRed)
        Else
            Call PlayerMsg(Attacker, "You hit " & GetPlayerName(Victim) & " with a " & Trim$(Item(N).Name) & " for " & Damage & " hit points.", White)
            Call PlayerMsg(Victim, GetPlayerName(Attacker) & " hit you with a " & Trim$(Item(N).Name) & " for " & Damage & " hit points.", BrightRed)
        End If
    End If

    ' Reset timer for attacking
    Player(Attacker).AttackTimer = GetTickCount
End Sub

Sub NpcAttackPlayer(ByVal MapNpcNum As Long, ByVal Victim As Long, ByVal Damage As Long)
    Dim Name As String
    Dim MapNum As Long

    ' Check for subscript out of range
    If MapNpcNum <= 0 Or MapNpcNum > MAX_MAP_NPCS Or IsPlaying(Victim) = False Or Damage < 0 Then
        Exit Sub
    End If

    ' Check for subscript out of range
    If MapNpc(GetPlayerMap(Victim), MapNpcNum).Num <= 0 Then
        Exit Sub
    End If

    ' Send this packet so they can see the person attacking
    Call SendDataToMap(GetPlayerMap(Victim), "NPCATTACK" & SEP_CHAR & MapNpcNum & END_CHAR)

    MapNum = GetPlayerMap(Victim)
    Name = Trim$(Npc(MapNpc(MapNum, MapNpcNum).Num).Name)

    If Damage >= GetPlayerHP(Victim) Then
    
        'Call the DeathByNpc Sub
        MyScript.ExecuteStatement "\scripts\Main.as", "OnDeathByNpc " & Victim & ", " & MapNpc(MapNum, MapNpcNum).Num & ", " & MapNum & ", " & MapNpcNum

        ' Drop all worn items by victim
        If GetPlayerWeaponSlot(Victim) > 0 Then
            Call PlayerMapDropItem(Victim, GetPlayerWeaponSlot(Victim), 0)
        End If
        If GetPlayerArmorSlot(Victim) > 0 Then
            Call PlayerMapDropItem(Victim, GetPlayerArmorSlot(Victim), 0)
        End If
        If GetPlayerHelmetSlot(Victim) > 0 Then
            Call PlayerMapDropItem(Victim, GetPlayerHelmetSlot(Victim), 0)
        End If
        If GetPlayerShieldSlot(Victim) > 0 Then
            Call PlayerMapDropItem(Victim, GetPlayerShieldSlot(Victim), 0)
        End If

        ' Warp player away
        With Map(MapNum)
            If .BootMap > 0 And .BootX > 0 And .BootY > 0 Then
                Call PlayerWarp(Victim, .BootMap, .BootX, .BootY)
            Else
                Call PlayerWarp(Victim, START_MAP, START_X, START_Y)
            End If
        End With
            

        ' Restore vitals
        Call SetPlayerHP(Victim, GetPlayerMaxHP(Victim))
        Call SetPlayerMP(Victim, GetPlayerMaxMP(Victim))
        Call SetPlayerSP(Victim, GetPlayerMaxSP(Victim))
        Call SendHP(Victim)
        Call SendMP(Victim)
        Call SendSP(Victim)
        Call SendExp(Victim)

        ' Set NPC target to 0
        MapNpc(MapNum, MapNpcNum).Target = 0

        ' If the player the attacker killed was a pk then take it away
        If GetPlayerPK(Victim) = YES Then
            Call SetPlayerPK(Victim, NO)
            Call SendPlayerData(Victim)
        End If
    Else
        ' Player not dead, just do the damage
        Call SetPlayerHP(Victim, GetPlayerHP(Victim) - Damage)
        Call SendHP(Victim)

        ' Say damage
        Call PlayerMsg(Victim, "A " & Name & " hit you for " & Damage & " hit points.", BrightRed)
    End If
    Call SendDataTo(Victim, "BLITNPCDMG" & SEP_CHAR & Damage & END_CHAR)
End Sub

Sub AttackNpc(ByVal Attacker As Long, ByVal MapNpcNum As Long, ByVal Damage As Long)
    Dim Name As String
    Dim Exp As Long
    Dim N As Long, I As Long
    Dim STR As Long, DEF As Long, MapNum As Long, NpcNum As Long

    ' Check for subscript out of range
    If IsPlaying(Attacker) = False Or MapNpcNum <= 0 Or MapNpcNum > MAX_MAP_NPCS Or Damage < 0 Then
        Exit Sub
    End If

    ' Check for weapon
    If GetPlayerWeaponSlot(Attacker) > 0 Then
        N = GetPlayerInvItemNum(Attacker, GetPlayerWeaponSlot(Attacker))
    Else
        N = 0
    End If

    ' Send this packet so they can see the person attacking
    Call SendDataToMapBut(Attacker, GetPlayerMap(Attacker), "ATTACK" & SEP_CHAR & Attacker & END_CHAR)

    MapNum = GetPlayerMap(Attacker)
    NpcNum = MapNpc(MapNum, MapNpcNum).Num
    Name = Trim$(Npc(NpcNum).Name)

    If Damage >= MapNpc(MapNum, MapNpcNum).HP Then
        ' Check for a weapon and say damage
        If N = 0 Then
            If IsVowel(Npc(NpcNum).Name) = True Then
                Call PlayerMsg(Attacker, "You hit an " & Name & " for " & Damage & " hit points, killing it.", BrightRed)
            Else
                Call PlayerMsg(Attacker, "You hit a " & Name & " for " & Damage & " hit points, killing it.", BrightRed)
            End If
        Else
            If IsVowel(Npc(NpcNum).Name) = True Then
                Call PlayerMsg(Attacker, "You hit an " & Name & " with a " & Trim$(Item(N).Name) & " for " & Damage & " hit points, killing it.", BrightRed)
            Else
                Call PlayerMsg(Attacker, "You hit a " & Name & " with a " & Trim$(Item(N).Name) & " for " & Damage & " hit points, killing it.", BrightRed)
            End If
        End If
        
        MyScript.ExecuteStatement "\scripts\Main.as", "OnNpcDeath " & Attacker & ", " & NpcNum & ", " & MapNum & ", " & MapNpcNum

        ' Calculate exp to give attacker
        Exp = Npc(NpcNum).GiveEXP

        ' Make sure we dont get less then 0
        If Exp < 0 Then
            Exp = 1
        End If

        ' Check if in party, if so divide the exp up by 2
        If Player(Attacker).InParty = NO Then
            Call SetPlayerExp(Attacker, GetPlayerExp(Attacker) + Exp)
            Call PlayerMsg(Attacker, "You have gained " & Exp & " experience points.", BrightBlue)
            Call SendExp(Attacker)
        Else
            Exp = Exp / 2

            If Exp < 0 Then
                Exp = 1
            End If

            Call SetPlayerExp(Attacker, GetPlayerExp(Attacker) + Exp)
            Call PlayerMsg(Attacker, "You have gained " & Exp & " party experience points.", BrightBlue)
            Call SendExp(Attacker)

            N = Player(Attacker).PartyPlayer
            If N > 0 Then
                Call SetPlayerExp(N, GetPlayerExp(N) + Exp)
                Call PlayerMsg(N, "You have gained " & Exp & " party experience points.", BrightBlue)
                Call SendExp(N)
            End If
        End If

        ' Drop the goods if they get it
        If Npc(NpcNum).DropItem > 0 And Npc(NpcNum).DropChance > 0 Then
            N = Int(Rnd * Npc(NpcNum).DropChance) + 1
            If N = 1 Then
                Call SpawnItem(Npc(NpcNum).DropItem, Npc(NpcNum).DropItemValue, MapNum, MapNpc(MapNum, MapNpcNum).X, MapNpc(MapNum, MapNpcNum).y)
            End If
        End If

        ' Now set HP to 0 so we know to actually kill them in the server loop (this prevents subscript out of range)
        MapNpc(MapNum, MapNpcNum).Num = 0
        MapNpc(MapNum, MapNpcNum).SpawnWait = GetTickCount
        MapNpc(MapNum, MapNpcNum).HP = 0
        Call SendDataToMap(MapNum, "NPCDEAD" & SEP_CHAR & MapNpcNum & END_CHAR)

        ' Check for level up
        Call CheckPlayerLevelUp(Attacker)

        ' Check for level up party member
        If Player(Attacker).InParty = YES Then
            Call CheckPlayerLevelUp(Player(Attacker).PartyPlayer)
        End If

        ' Check if target is npc that died and if so set target to 0
        If Player(Attacker).TargetType = TARGET_TYPE_NPC And Player(Attacker).Target = MapNpcNum Then
            Player(Attacker).Target = 0
            Player(Attacker).TargetType = 0
        End If
    Else
        ' NPC not dead, just do the damage
        MapNpc(MapNum, MapNpcNum).HP = MapNpc(MapNum, MapNpcNum).HP - Damage

        ' Check for a weapon and say damage
        If N = 0 Then
            If IsVowel(Npc(NpcNum).Name) = True Then
                Call PlayerMsg(Attacker, "You hit an " & Name & " for " & Damage & " hit points.", White)
            Else
                Call PlayerMsg(Attacker, "You hit a " & Name & " for " & Damage & " hit points.", White)
            End If
        Else
            If IsVowel(Npc(NpcNum).Name) = True Then
                If IsVowel(Item(N).Name) = True Then
                    Call PlayerMsg(Attacker, "You hit an " & Name & " with an " & Trim$(Item(N).Name) & " for " & Damage & " hit points.", White)
                Else
                    Call PlayerMsg(Attacker, "You hit an " & Name & " with a " & Trim$(Item(N).Name) & " for " & Damage & " hit points.", White)
                End If
            Else
                If IsVowel(Item(N).Name) = True Then
                    Call PlayerMsg(Attacker, "You hit a " & Name & " with an " & Trim$(Item(N).Name) & " for " & Damage & " hit points.", White)
                Else
                    Call PlayerMsg(Attacker, "You hit a " & Name & " with a " & Trim$(Item(N).Name) & " for " & Damage & " hit points.", White)
                End If
            End If
        End If

        ' Check if we should send a message
        If MapNpc(MapNum, MapNpcNum).Target = 0 And MapNpc(MapNum, MapNpcNum).Target <> Attacker Then
            If Trim$(Npc(NpcNum).AttackSay) <> vbNullString Then
                Call PlayerMsg(Attacker, "A " & Trim$(Npc(NpcNum).Name) & " says, '" & Trim$(Npc(NpcNum).AttackSay) & "' to you.", SayColor)
            End If
        End If

        ' Set the NPC target to the player
        MapNpc(MapNum, MapNpcNum).Target = Attacker

        ' Now check for guard ai and if so have all onmap guards come after'm
        If Npc(MapNpc(MapNum, MapNpcNum).Num).Behavior = NPC_BEHAVIOR_GUARD Then
            For I = 1 To MAX_MAP_NPCS
                If MapNpc(MapNum, I).Num = MapNpc(MapNum, MapNpcNum).Num Then
                    MapNpc(MapNum, I).Target = Attacker
                End If
            Next I
        End If
    End If

    ' Reset attack timer
    Player(Attacker).AttackTimer = GetTickCount
End Sub

Sub PlayerWarp(ByVal Index As Long, ByVal MapNum As Long, ByVal X As Long, ByVal y As Long)
    Dim Packet As String
    Dim ShopNum As Long, OldMap As Long

    ' Check for subscript out of range
    If IsPlaying(Index) = False Or MapNum <= 0 Or MapNum > MAX_MAPS_SET Then
        Exit Sub
    End If

    ' Check if there was an npc on the map the player is leaving, and if so say goodbye
    ShopNum = Map(GetPlayerMap(Index)).Shop
    If ShopNum > 0 Then
        If Trim$(Shop(ShopNum).LeaveSay) <> vbNullString Then
            Call PlayerMsg(Index, Trim$(Shop(ShopNum).Name) & " says, '" & Trim$(Shop(ShopNum).LeaveSay) & "'", SayColor)
        End If
    End If
    
    ' Call the Leave Map sub.
    MyScript.ExecuteStatement "\scripts\Main.as", "LeaveMap " & Index
    
    ' Save old map to send erase player data to
    OldMap = GetPlayerMap(Index)
    Call SendLeaveMap(Index, OldMap)
    Call SetPlayerMap(Index, MapNum)
    Call SetPlayerX(Index, X)
    Call SetPlayerY(Index, y)
    ' MyScript.ExecuteStatement "\scripts\Main.as", "OnScriptedTile " & Index

    ' Check if there is an shop on the map and say hello if so
    ShopNum = Map(GetPlayerMap(Index)).Shop
    If ShopNum > 0 Then
        If Trim$(Shop(ShopNum).JoinSay) <> vbNullString Then
            Call PlayerMsg(Index, Trim$(Shop(ShopNum).Name) & " says, '" & Trim$(Shop(ShopNum).JoinSay) & "'", SayColor)
        End If
    End If
    
    ' Call the Join Map Sub
    MyScript.ExecuteStatement "\scripts\Main.as", "JoinMap " & Index


    ' Now we check if there were any players left on the map the player just left, and if not stop processing npcs
    If GetTotalMapPlayers(OldMap) = 0 Then
        PlayersOnMap(OldMap) = NO
    End If

    ' Sets it so we know to process npcs on the map
    PlayersOnMap(MapNum) = YES

    Player(Index).GettingMap = YES
    Call SendDataTo(Index, "CHECKFORMAP" & SEP_CHAR & MapNum & SEP_CHAR & Map(MapNum).Revision & END_CHAR)
End Sub

Sub PlayerMove(ByVal Index As Long, ByVal Dir As Long, ByVal Movement As Long)
    Dim Packet As String
    Dim MapNum As Long
    Dim NewMap As Long
    Dim X As Long
    Dim y As Long
    Dim I As Long
    Dim Moved As Byte
    Dim MapMsg1 As String
    Dim MsgType As Byte
    Dim SpriteNum As Long

    ' Check for subscript out of range
    If IsPlaying(Index) = False Or Dir < DIR_UP Or Dir > DIR_RIGHT Or Movement < 1 Or Movement > 2 Then
        Exit Sub
    End If

    Call SetPlayerDir(Index, Dir)

    Moved = NO

    Select Case Dir
        Case DIR_UP
            ' Check to make sure not outside of boundries
            If GetPlayerY(Index) > 0 Then
                ' Check to make sure that the tile is walkable
                If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) - 1).Type <> TILE_TYPE_BLOCKED Then
                    ' Check to see if the tile is a key and if it is check if its opened
                    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) - 1).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) - 1).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index), GetPlayerY(Index) - 1) = YES) Then
                        ' Check to see if the tile is a door and if it is check if its opened
                        If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) - 1).Type <> TILE_TYPE_DOOR Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) - 1).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index), GetPlayerY(Index) - 1) = YES) Then
                            Call SetPlayerY(Index, GetPlayerY(Index) - 1)

                            Packet = "PLAYERMOVE" & SEP_CHAR & Index & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & GetPlayerDir(Index) & SEP_CHAR & Movement & END_CHAR
                            Call SendDataToMapBut(Index, GetPlayerMap(Index), Packet)
                            Moved = YES
                        End If
                    End If
                ' Check to make sure that the tile is walkable
                ElseIf Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) - 1).Type = TILE_TYPE_BLOCKED Then
                    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) - 1).Data1 = 0 Then
                        ' Check to see if the tile is a key and if it is check if its opened
                        If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) - 1).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) - 1).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index), GetPlayerY(Index) - 1) = YES) Then
                            ' Check to see if the tile is a door and if it is check if its opened
                            If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) - 1).Type <> TILE_TYPE_DOOR Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) - 1).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index), GetPlayerY(Index) - 1) = YES) Then
                                Call SetPlayerY(Index, GetPlayerY(Index) - 1)

                                Packet = "PLAYERMOVE" & SEP_CHAR & Index & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & GetPlayerDir(Index) & SEP_CHAR & Movement & END_CHAR
                                Call SendDataToMapBut(Index, GetPlayerMap(Index), Packet)
                                Moved = YES
                            End If
                        End If
                    End If
                End If
            Else
                ' Check to see if we can move them to the another map
                If Map(GetPlayerMap(Index)).Up > 0 Then
                    NewMap = Map(GetPlayerMap(Index)).Up
                    If Not Map(NewMap).Tile(GetPlayerX(Index), MAX_MAPY).Type = TILE_TYPE_BLOCKED And Not Map(NewMap).Tile(GetPlayerX(Index), MAX_MAPY).Data1 = 1 Then
                        Call PlayerWarp(Index, Map(GetPlayerMap(Index)).Up, GetPlayerX(Index), MAX_MAPY)
                        Moved = YES
                    End If
                End If
            End If

        Case DIR_DOWN
            ' Check to make sure not outside of boundries
            If GetPlayerY(Index) < MAX_MAPY Then
                ' Check to make sure that the tile is walkable
                If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) + 1).Type <> TILE_TYPE_BLOCKED Then
                    ' Check to see if the tile is a key and if it is check if its opened
                    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) + 1).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) + 1).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index), GetPlayerY(Index) + 1) = YES) Then
                        ' Check to see if the tile is a door and if it is check if its opened
                        If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) + 1).Type <> TILE_TYPE_DOOR Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) + 1).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index), GetPlayerY(Index) + 1) = YES) Then
                            Call SetPlayerY(Index, GetPlayerY(Index) + 1)

                            Packet = "PLAYERMOVE" & SEP_CHAR & Index & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & GetPlayerDir(Index) & SEP_CHAR & Movement & END_CHAR
                            Call SendDataToMapBut(Index, GetPlayerMap(Index), Packet)
                            Moved = YES
                        End If
                    End If
                ElseIf Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) + 1).Type = TILE_TYPE_BLOCKED Then
                    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) + 1).Data1 = 0 Then
                        ' Check to see if the tile is a key and if it is check if its opened
                        If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) + 1).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) + 1).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index), GetPlayerY(Index) + 1) = YES) Then
                            ' Check to see if the tile is a door and if it is check if its opened
                            If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) + 1).Type <> TILE_TYPE_DOOR Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index) + 1).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index), GetPlayerY(Index) + 1) = YES) Then
                                Call SetPlayerY(Index, GetPlayerY(Index) + 1)

                                Packet = "PLAYERMOVE" & SEP_CHAR & Index & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & GetPlayerDir(Index) & SEP_CHAR & Movement & END_CHAR
                                Call SendDataToMapBut(Index, GetPlayerMap(Index), Packet)
                                Moved = YES
                            End If
                        End If
                    End If
                End If
            Else
                ' Check to see if we can move them to the another map
                If Map(GetPlayerMap(Index)).Down > 0 Then
                    NewMap = Map(GetPlayerMap(Index)).Down
                    If Not Map(NewMap).Tile(GetPlayerX(Index), 0).Type = TILE_TYPE_BLOCKED And Not Map(NewMap).Tile(GetPlayerX(Index), 0).Data1 = 1 Then
                        Call PlayerWarp(Index, Map(GetPlayerMap(Index)).Down, GetPlayerX(Index), 0)
                        Moved = YES
                    End If
                End If
            End If

        Case DIR_LEFT
            ' Check to make sure not outside of boundries
            If GetPlayerX(Index) > 0 Then
                ' Check to make sure that the tile is walkable
                If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) - 1, GetPlayerY(Index)).Type <> TILE_TYPE_BLOCKED Then
                    ' Check to see if the tile is a key and if it is check if its opened
                    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) - 1, GetPlayerY(Index)).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) - 1, GetPlayerY(Index)).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index) - 1, GetPlayerY(Index)) = YES) Then
                        ' Check to see if the tile is a door and if it is check if its opened
                        If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) - 1, GetPlayerY(Index)).Type <> TILE_TYPE_DOOR Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) - 1, GetPlayerY(Index)).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index) - 1, GetPlayerY(Index)) = YES) Then
                            Call SetPlayerX(Index, GetPlayerX(Index) - 1)

                            Packet = "PLAYERMOVE" & SEP_CHAR & Index & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & GetPlayerDir(Index) & SEP_CHAR & Movement & END_CHAR
                            Call SendDataToMapBut(Index, GetPlayerMap(Index), Packet)
                            Moved = YES
                        End If
                    End If
                ElseIf Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) - 1, GetPlayerY(Index)).Type = TILE_TYPE_BLOCKED Then
                    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) - 1, GetPlayerY(Index)).Data1 = 0 Then
                        ' Check to see if the tile is a key and if it is check if its opened
                        If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) - 1, GetPlayerY(Index)).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) - 1, GetPlayerY(Index)).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index) - 1, GetPlayerY(Index)) = YES) Then
                            ' Check to see if the tile is a door and if it is check if its opened
                            If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) - 1, GetPlayerY(Index)).Type <> TILE_TYPE_DOOR Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) - 1, GetPlayerY(Index)).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index) - 1, GetPlayerY(Index)) = YES) Then
                                Call SetPlayerX(Index, GetPlayerX(Index) - 1)

                                Packet = "PLAYERMOVE" & SEP_CHAR & Index & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & GetPlayerDir(Index) & SEP_CHAR & Movement & END_CHAR
                                Call SendDataToMapBut(Index, GetPlayerMap(Index), Packet)
                                Moved = YES
                            End If
                        End If
                    End If
                End If             ' For Blocks
            Else
                ' Check to see if we can move them to the another map
                If Map(GetPlayerMap(Index)).Left > 0 Then
                    NewMap = Map(GetPlayerMap(Index)).Left
                    If Not Map(NewMap).Tile(MAX_MAPX, GetPlayerY(Index)).Type = TILE_TYPE_BLOCKED And Not Map(NewMap).Tile(MAX_MAPX, GetPlayerY(Index)).Data1 = 1 Then
                        Call PlayerWarp(Index, Map(GetPlayerMap(Index)).Left, MAX_MAPX, GetPlayerY(Index))
                        Moved = YES
                    End If
                End If
            End If

        Case DIR_RIGHT
            ' Check to make sure not outside of boundries
            If GetPlayerX(Index) < MAX_MAPX Then
                ' Check to make sure that the tile is walkable
                If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) + 1, GetPlayerY(Index)).Type <> TILE_TYPE_BLOCKED Then
                    ' Check to see if the tile is a key and if it is check if its opened
                    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) + 1, GetPlayerY(Index)).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) + 1, GetPlayerY(Index)).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index) + 1, GetPlayerY(Index)) = YES) Then
                        ' Check to see if the tile is a door and if it is check if its opened
                        If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) + 1, GetPlayerY(Index)).Type <> TILE_TYPE_DOOR Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) + 1, GetPlayerY(Index)).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index) + 1, GetPlayerY(Index)) = YES) Then
                            Call SetPlayerX(Index, GetPlayerX(Index) + 1)

                            Packet = "PLAYERMOVE" & SEP_CHAR & Index & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & GetPlayerDir(Index) & SEP_CHAR & Movement & END_CHAR
                            Call SendDataToMapBut(Index, GetPlayerMap(Index), Packet)
                            Moved = YES
                        End If
                    End If
                ElseIf Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) + 1, GetPlayerY(Index)).Type = TILE_TYPE_BLOCKED Then
                    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) + 1, GetPlayerY(Index)).Data1 = 0 Then
                        ' Check to see if the tile is a key and if it is check if its opened
                        If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) + 1, GetPlayerY(Index)).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) + 1, GetPlayerY(Index)).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index) + 1, GetPlayerY(Index)) = YES) Then
                            ' Check to see if the tile is a door and if it is check if its opened
                            If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) + 1, GetPlayerY(Index)).Type <> TILE_TYPE_DOOR Or (Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index) + 1, GetPlayerY(Index)).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(GetPlayerX(Index) + 1, GetPlayerY(Index)) = YES) Then
                                Call SetPlayerX(Index, GetPlayerX(Index) + 1)

                                Packet = "PLAYERMOVE" & SEP_CHAR & Index & SEP_CHAR & GetPlayerX(Index) & SEP_CHAR & GetPlayerY(Index) & SEP_CHAR & GetPlayerDir(Index) & SEP_CHAR & Movement & END_CHAR
                                Call SendDataToMapBut(Index, GetPlayerMap(Index), Packet)
                                Moved = YES
                            End If
                        End If
                    End If
                End If             ' For Blocks
            Else
                ' Check to see if we can move them to the another map
                If Map(GetPlayerMap(Index)).Right > 0 Then
                    NewMap = Map(GetPlayerMap(Index)).Right
                    If Not Map(NewMap).Tile(0, GetPlayerY(Index)).Type = TILE_TYPE_BLOCKED And Not Map(NewMap).Tile(0, GetPlayerY(Index)).Data1 = 1 Then
                        Call PlayerWarp(Index, Map(GetPlayerMap(Index)).Right, 0, GetPlayerY(Index))
                        Moved = YES
                    End If
                End If
            End If
    End Select


    ' Check to see if the tile is a warp tile, and if so warp them
    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Type = TILE_TYPE_WARP Then
        Player(Index).WarpTick = GetTickCount + 200
        Moved = YES
    End If

    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Type = TILE_TYPE_NUDGE Then
        Moved = YES
        Call PlayerMove(Index, Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data1, 0)
        Exit Sub
    End If

    ' Check to see if there is a message tile
    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Type = TILE_TYPE_MSG Then
        MapMsg1 = Trim$(Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data1)
        MsgType = Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data2

        If MsgType = 0 Then
            Call PlayerMsg(Index, Trim$(MapMsg1), White)
        ElseIf MsgType = 1 Then
            Call GlobalMsg(Trim$(MapMsg1), Yellow)
        End If
    End If

    ' Check for key trigger open
    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Type = TILE_TYPE_KEYOPEN Then
        X = Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data1
        y = Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data2

        If Map(GetPlayerMap(Index)).Tile(X, y).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(Index)).DoorOpen(X, y) = NO Then
            TempTile(GetPlayerMap(Index)).DoorOpen(X, y) = YES
            TempTile(GetPlayerMap(Index)).DoorTimer = GetTickCount

            Call SendDataToMap(GetPlayerMap(Index), "MAPKEY" & SEP_CHAR & X & SEP_CHAR & y & SEP_CHAR & 1 & END_CHAR)
            Call MapMsg(GetPlayerMap(Index), "A door has been unlocked.", White)
        End If
    End If

    ' ///////////////////////
    ' //check for door tile//
    ' ///////////////////////
    X = GetPlayerX(Index)
    y = GetPlayerY(Index)

    ' check if doors on players left
    If X > 0 Then
        If Map(GetPlayerMap(Index)).Tile(X - 1, y).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(X - 1, y) = NO Then
            TempTile(GetPlayerMap(Index)).DoorOpen(X - 1, y) = YES
            TempTile(GetPlayerMap(Index)).DoorTimer = GetTickCount

            Call SendDataToMap(GetPlayerMap(Index), "MAPKEY" & SEP_CHAR & X - 1 & SEP_CHAR & y & SEP_CHAR & 1 & END_CHAR)
            Call MapMsg(GetPlayerMap(Index), "A door has been unlocked.", White)
        End If
    End If

    ' check if doors on players right
    If X < 15 Then
        If Map(GetPlayerMap(Index)).Tile(X + 1, y).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(X + 1, y) = NO Then
            TempTile(GetPlayerMap(Index)).DoorOpen(X + 1, y) = YES
            TempTile(GetPlayerMap(Index)).DoorTimer = GetTickCount

            Call SendDataToMap(GetPlayerMap(Index), "MAPKEY" & SEP_CHAR & X + 1 & SEP_CHAR & y & SEP_CHAR & 1 & END_CHAR)
            Call MapMsg(GetPlayerMap(Index), "A door has been unlocked.", White)
        End If
    End If

    ' check if doors above player
    If y > 0 Then
        If Map(GetPlayerMap(Index)).Tile(X, y - 1).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(X, y - 1) = NO Then
            TempTile(GetPlayerMap(Index)).DoorOpen(X, y - 1) = YES
            TempTile(GetPlayerMap(Index)).DoorTimer = GetTickCount

            Call SendDataToMap(GetPlayerMap(Index), "MAPKEY" & SEP_CHAR & X & SEP_CHAR & y - 1 & SEP_CHAR & 1 & END_CHAR)
            Call MapMsg(GetPlayerMap(Index), "A door has been unlocked.", White)
        End If
    End If

    ' check of doors below player
    If y < 11 Then
        If Map(GetPlayerMap(Index)).Tile(X, y + 1).Type = TILE_TYPE_DOOR And TempTile(GetPlayerMap(Index)).DoorOpen(X, y + 1) = NO Then
            TempTile(GetPlayerMap(Index)).DoorOpen(X, y + 1) = YES
            TempTile(GetPlayerMap(Index)).DoorTimer = GetTickCount

            Call SendDataToMap(GetPlayerMap(Index), "MAPKEY" & SEP_CHAR & X & SEP_CHAR & y + 1 & SEP_CHAR & 1 & END_CHAR)
            Call MapMsg(GetPlayerMap(Index), "A door has been unlocked.", White)
        End If
    End If

    ' Check to see if they should be healed!
    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Type = TILE_TYPE_HEAL Then
        Call SetPlayerHP(Index, GetPlayerMaxHP(Index))
        Call SendHP(Index)
        Call PlayerMsg(Index, "You feel odd as a strange glow eminated from you and your a lifted into the air. Bright orbs of light travel around you. You are miraculously healed!", BrightGreen)
    End If

    ' Check for kill tile, and if so kill them
    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Type = TILE_TYPE_KILL Then
        If GetPlayerArmorSlot(Index) = Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data2 Or GetPlayerWeaponSlot(Index) = Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data2 Or GetPlayerHelmetSlot(Index) = Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data2 Or GetPlayerShieldSlot(Index) = Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data2 Then
        ' Do Nothing
        Else
            ' Check to see if the sucker is going to die!
            If GetPlayerHP(Index) > Trim$(Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data1) Then
                Call SetPlayerHP(Index, GetPlayerHP(Index) - Trim$(Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data1))
                Call SendHP(Index)
                Call PlayerMsg(Index, "You've taken " & Trim$(Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data1) & " damage!", BrightRed)
            ElseIf GetPlayerHP(Index) <= Trim$(Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data1) Then
                Call PlayerMsg(Index, "You've taken " & Trim$(Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data1) & " damage, which has killed you!", BrightRed)
                Call GlobalMsg("The player " & GetPlayerName(Index) & " has died!", BrightRed)

                ' Warp player away
                If Map(GetPlayerMap(Index)).BootMap > 0 And Map(GetPlayerMap(Index)).BootX > 0 And Map(GetPlayerMap(Index)).BootY > 0 Then
                    Call PlayerWarp(Index, Map(GetPlayerMap(Index)).BootMap, Map(GetPlayerMap(Index)).BootX, Map(GetPlayerMap(Index)).BootY)
                    Moved = YES
                Else
                    Call PlayerWarp(Index, START_MAP, START_X, START_Y)
                    Moved = YES
                End If

                ' Restore vitals
                Call SetPlayerHP(Index, GetPlayerMaxHP(Index))
                Call SetPlayerMP(Index, GetPlayerMaxMP(Index))
                Call SetPlayerSP(Index, GetPlayerMaxSP(Index))
                Call SendHP(Index)
                Call SendMP(Index)
                Call SendSP(Index)
            End If
        End If
    End If

    ' ///////////////////////
    ' //check 4 sprite tile//
    ' ///////////////////////
    ' Check for sprite tile and then change the sprite
    If Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Type = TILE_TYPE_SPRITE Then
        SpriteNum = Map(GetPlayerMap(Index)).Tile(GetPlayerX(Index), GetPlayerY(Index)).Data1
        Call SetPlayerSprite(Index, SpriteNum)
        Call SendPlayerData(Index)
    End If

    ' Scripted Tile Sub
    MyScript.ExecuteStatement "\scripts\Main.as", "OnScriptedTile " & Index

    ' They tried to hack
    If Moved = NO Then
        Call HackingAttempt(Index, "Position Modification")
    End If
End Sub

Function CanNpcMove(ByVal MapNum As Long, ByVal MapNpcNum As Long, ByVal Dir) As Boolean
    Dim I As Long, N As Long
    Dim X As Long, y As Long

    CanNpcMove = False

    If MapNpc(MapNum, MapNpcNum).Moveable = 1 Then
        CanNpcMove = False
        Exit Function
    End If

    ' Check for subscript out of range
    If MapNum <= 0 Or MapNum > MAX_MAPS_SET Or MapNpcNum <= 0 Or MapNpcNum > MAX_MAP_NPCS Or Dir < DIR_UP Or Dir > DIR_RIGHT Then
        Exit Function
    End If

    X = MapNpc(MapNum, MapNpcNum).X
    y = MapNpc(MapNum, MapNpcNum).y

    CanNpcMove = True

    Select Case Dir
        Case DIR_UP
            ' Check to make sure not outside of boundries
            If y > 0 Then
                N = Map(MapNum).Tile(X, y - 1).Type

                ' Check to make sure that the tile is walkable
                If N <> TILE_TYPE_WALKABLE And N <> TILE_TYPE_ITEM And N <> TILE_TYPE_BLOCKED And N <> TILE_TYPE_NPCSPAWN Then
                    CanNpcMove = False
                    Exit Function
                ElseIf N = TILE_TYPE_BLOCKED Then
                    If Map(MapNum).Tile(X, y - 1).Data2 = 1 Then
                        CanNpcMove = False
                        Exit Function
                    End If
                End If

                ' Check to make sure that there is not a player in the way
                For I = 1 To HighIndex
                    If IsPlaying(I) Then
                        If (GetPlayerMap(I) = MapNum) And (GetPlayerX(I) = MapNpc(MapNum, MapNpcNum).X) And (GetPlayerY(I) = MapNpc(MapNum, MapNpcNum).y - 1) Then
                            CanNpcMove = False
                            Exit Function
                        End If
                    End If
                Next I

                ' Check to make sure that there is not another npc in the way
                For I = 1 To MAX_MAP_NPCS
                    If (I <> MapNpcNum) And (MapNpc(MapNum, I).Num > 0) And (MapNpc(MapNum, I).X = MapNpc(MapNum, MapNpcNum).X) And (MapNpc(MapNum, I).y = MapNpc(MapNum, MapNpcNum).y - 1) Then
                        CanNpcMove = False
                        Exit Function
                    End If
                Next I
            Else
                CanNpcMove = False
            End If

        Case DIR_DOWN
            ' Check to make sure not outside of boundries
            If y < MAX_MAPY Then
                N = Map(MapNum).Tile(X, y + 1).Type

                ' Check to make sure that the tile is walkable
                If N <> TILE_TYPE_WALKABLE And N <> TILE_TYPE_ITEM And N <> TILE_TYPE_BLOCKED And N <> TILE_TYPE_NPCSPAWN Then
                    CanNpcMove = False
                    Exit Function
                ElseIf N = TILE_TYPE_BLOCKED Then
                    If Map(MapNum).Tile(X, y + 1).Data2 = 1 Then
                        CanNpcMove = False
                        Exit Function
                    End If
                End If

                ' Check to make sure that there is not a player in the way
                For I = 1 To HighIndex
                    If IsPlaying(I) Then
                        If (GetPlayerMap(I) = MapNum) And (GetPlayerX(I) = MapNpc(MapNum, MapNpcNum).X) And (GetPlayerY(I) = MapNpc(MapNum, MapNpcNum).y + 1) Then
                            CanNpcMove = False
                            Exit Function
                        End If
                    End If
                Next I

                ' Check to make sure that there is not another npc in the way
                For I = 1 To MAX_MAP_NPCS
                    If (I <> MapNpcNum) And (MapNpc(MapNum, I).Num > 0) And (MapNpc(MapNum, I).X = MapNpc(MapNum, MapNpcNum).X) And (MapNpc(MapNum, I).y = MapNpc(MapNum, MapNpcNum).y + 1) Then
                        CanNpcMove = False
                        Exit Function
                    End If
                Next I
            Else
                CanNpcMove = False
            End If

        Case DIR_LEFT
            ' Check to make sure not outside of boundries
            If X > 0 Then
                N = Map(MapNum).Tile(X - 1, y).Type

                ' Check to make sure that the tile is walkable
                If N <> TILE_TYPE_WALKABLE And N <> TILE_TYPE_ITEM And N <> TILE_TYPE_BLOCKED And N <> TILE_TYPE_NPCSPAWN Then
                    CanNpcMove = False
                    Exit Function
                ElseIf N = TILE_TYPE_BLOCKED Then
                    If Map(MapNum).Tile(X - 1, y).Data2 = 1 Then
                        CanNpcMove = False
                        Exit Function
                    End If
                End If

                ' Check to make sure that there is not a player in the way
                For I = 1 To HighIndex
                    If IsPlaying(I) Then
                        If (GetPlayerMap(I) = MapNum) And (GetPlayerX(I) = MapNpc(MapNum, MapNpcNum).X - 1) And (GetPlayerY(I) = MapNpc(MapNum, MapNpcNum).y) Then
                            CanNpcMove = False
                            Exit Function
                        End If
                    End If
                Next I

                ' Check to make sure that there is not another npc in the way
                For I = 1 To MAX_MAP_NPCS
                    If (I <> MapNpcNum) And (MapNpc(MapNum, I).Num > 0) And (MapNpc(MapNum, I).X = MapNpc(MapNum, MapNpcNum).X - 1) And (MapNpc(MapNum, I).y = MapNpc(MapNum, MapNpcNum).y) Then
                        CanNpcMove = False
                        Exit Function
                    End If
                Next I
            Else
                CanNpcMove = False
            End If

        Case DIR_RIGHT
            ' Check to make sure not outside of boundries
            If X < MAX_MAPX Then
                N = Map(MapNum).Tile(X + 1, y).Type

                ' Check to make sure that the tile is walkable
                If N <> TILE_TYPE_WALKABLE And N <> TILE_TYPE_ITEM And N <> TILE_TYPE_BLOCKED And N <> TILE_TYPE_NPCSPAWN Then
                    CanNpcMove = False
                    Exit Function
                ElseIf N = TILE_TYPE_BLOCKED Then
                    If Map(MapNum).Tile(X + 1, y).Data2 = 1 Then
                        CanNpcMove = False
                        Exit Function
                    End If
                End If

                ' Check to make sure that there is not a player in the way
                For I = 1 To HighIndex
                    If IsPlaying(I) Then
                        If (GetPlayerMap(I) = MapNum) And (GetPlayerX(I) = MapNpc(MapNum, MapNpcNum).X + 1) And (GetPlayerY(I) = MapNpc(MapNum, MapNpcNum).y) Then
                            CanNpcMove = False
                            Exit Function
                        End If
                    End If
                Next I

                ' Check to make sure that there is not another npc in the way
                For I = 1 To MAX_MAP_NPCS
                    If (I <> MapNpcNum) And (MapNpc(MapNum, I).Num > 0) And (MapNpc(MapNum, I).X = MapNpc(MapNum, MapNpcNum).X + 1) And (MapNpc(MapNum, I).y = MapNpc(MapNum, MapNpcNum).y) Then
                        CanNpcMove = False
                        Exit Function
                    End If
                Next I
            Else
                CanNpcMove = False
            End If
    End Select
End Function

Sub NpcMove(ByVal MapNum As Long, ByVal MapNpcNum As Long, ByVal Dir As Long, ByVal Movement As Long)
    Dim Packet As String
    Dim X As Long
    Dim y As Long
    Dim I As Long

    ' Check for subscript out of range
    If MapNum <= 0 Or MapNum > MAX_MAPS_SET Or MapNpcNum <= 0 Or MapNpcNum > MAX_MAP_NPCS Or Dir < DIR_UP Or Dir > DIR_RIGHT Or Movement < 1 Or Movement > 2 Then
        Exit Sub
    End If

    MapNpc(MapNum, MapNpcNum).Dir = Dir

    Select Case Dir
        Case DIR_UP
            MapNpc(MapNum, MapNpcNum).y = MapNpc(MapNum, MapNpcNum).y - 1
            Packet = "NPCMOVE" & SEP_CHAR & MapNpcNum & SEP_CHAR & MapNpc(MapNum, MapNpcNum).X & SEP_CHAR & MapNpc(MapNum, MapNpcNum).y & SEP_CHAR & MapNpc(MapNum, MapNpcNum).Dir & SEP_CHAR & Movement & END_CHAR
            Call SendDataToMap(MapNum, Packet)

        Case DIR_DOWN
            MapNpc(MapNum, MapNpcNum).y = MapNpc(MapNum, MapNpcNum).y + 1
            Packet = "NPCMOVE" & SEP_CHAR & MapNpcNum & SEP_CHAR & MapNpc(MapNum, MapNpcNum).X & SEP_CHAR & MapNpc(MapNum, MapNpcNum).y & SEP_CHAR & MapNpc(MapNum, MapNpcNum).Dir & SEP_CHAR & Movement & END_CHAR
            Call SendDataToMap(MapNum, Packet)

        Case DIR_LEFT
            MapNpc(MapNum, MapNpcNum).X = MapNpc(MapNum, MapNpcNum).X - 1
            Packet = "NPCMOVE" & SEP_CHAR & MapNpcNum & SEP_CHAR & MapNpc(MapNum, MapNpcNum).X & SEP_CHAR & MapNpc(MapNum, MapNpcNum).y & SEP_CHAR & MapNpc(MapNum, MapNpcNum).Dir & SEP_CHAR & Movement & END_CHAR
            Call SendDataToMap(MapNum, Packet)

        Case DIR_RIGHT
            MapNpc(MapNum, MapNpcNum).X = MapNpc(MapNum, MapNpcNum).X + 1
            Packet = "NPCMOVE" & SEP_CHAR & MapNpcNum & SEP_CHAR & MapNpc(MapNum, MapNpcNum).X & SEP_CHAR & MapNpc(MapNum, MapNpcNum).y & SEP_CHAR & MapNpc(MapNum, MapNpcNum).Dir & SEP_CHAR & Movement & END_CHAR
            Call SendDataToMap(MapNum, Packet)
    End Select
End Sub

Sub NpcDir(ByVal MapNum As Long, ByVal MapNpcNum As Long, ByVal Dir As Long)
    Dim Packet As String

    ' Check for subscript out of range
    If MapNum <= 0 Or MapNum > MAX_MAPS_SET Or MapNpcNum <= 0 Or MapNpcNum > MAX_MAP_NPCS Or Dir < DIR_UP Or Dir > DIR_RIGHT Then
        Exit Sub
    End If

    MapNpc(MapNum, MapNpcNum).Dir = Dir
    Packet = "NPCDIR" & SEP_CHAR & MapNpcNum & SEP_CHAR & Dir & END_CHAR
    Call SendDataToMap(MapNum, Packet)
End Sub

Sub JoinGame(ByVal Index As Long)
    ' Set the flag so we know the person is in the game
    Player(Index).InGame = True

    ' Send an ok to client to start receiving in game data
    Call SendDataTo(Index, "LOGINOK" & SEP_CHAR & Index & END_CHAR)

    ' Send some more little goodies, no need to explain these
    Call CheckEquippedItems(Index)
    Call SendClasses(Index)
    Call SendItems(Index)
    Call SendNpcs(Index)
    Call SendShops(Index)
    Call SendSpells(Index)
    Call SendGuilds(Index)
    Call SendInventory(Index)
    Call SendWornEquipment(Index)
    Call SendHP(Index)
    Call SendMP(Index)
    Call SendSP(Index)
    Call SendStats(Index)
    Call SendWeatherTo(Index)
    Call SendTimeTo(Index)
    Call SendOnlineList(Index)
    Call SendExp(Index)
    Call SendGuild(Index)


    ' Warp the player to his saved location
    Call PlayerWarp(Index, GetPlayerMap(Index), GetPlayerX(Index), GetPlayerY(Index))

    ' Send welcome messages
    Call SendWelcome(Index)

    ' Send the flag so they know they can start doing stuff
    Call SendDataTo(Index, "INGAME" & END_CHAR)

    MyScript.ExecuteStatement "\scripts\Main.as", "JoinGame " & Index
End Sub

Sub LeftGame(ByVal Index As Long)
    Dim N As Long

    If Player(Index).InGame = True Then
        Player(Index).InGame = False

        ' Check if player was the only player on the map and stop npc processing if so
        If GetTotalMapPlayers(GetPlayerMap(Index)) = 0 Then
            PlayersOnMap(GetPlayerMap(Index)) = NO
        End If


        ' Check if the player was in a party, and if so cancel it out so the other player doesn't continue to get half exp
        If Player(Index).InParty = YES Then
            N = Player(Index).PartyPlayer

            Call PlayerMsg(N, GetPlayerName(Index) & " has left " & GAME_NAME & ", disbanning party.", Pink)
            Player(N).InParty = NO
            Player(N).PartyPlayer = 0
        End If

        Call SavePlayer(Index)

        ' Send a global message that he/she left
        MyScript.ExecuteStatement "\scripts\Main.as", "LeftGame " & Index
        Call TextAdd(frmServer.txtText, GetPlayerName(Index) & " has disconnected from " & GAME_NAME & ".", True)
        Call SendLeftGame(Index)
    End If

    Call ClearPlayer(Index)
    Call SendOnlineList(Index)
End Sub

Function GetTotalMapPlayers(ByVal MapNum As Long) As Long
    Dim I As Long, N As Long

    N = 0

    For I = 1 To HighIndex
        If IsPlaying(I) And GetPlayerMap(I) = MapNum Then
            N = N + 1
        End If
    Next I

    GetTotalMapPlayers = N
End Function

Function GetNpcMaxHP(ByVal NpcNum As Long)
    Dim X As Long, y As Long

    ' Prevent subscript out of range
    If NpcNum <= 0 Or NpcNum > MAX_NPCS Then
        GetNpcMaxHP = 0
        Exit Function
    End If

    GetNpcMaxHP = Npc(NpcNum).MaxHP
End Function

Function GetNpcMaxMP(ByVal NpcNum As Long)
    ' Prevent subscript out of range
    If NpcNum <= 0 Or NpcNum > MAX_NPCS Then
        GetNpcMaxMP = 0
        Exit Function
    End If

    GetNpcMaxMP = Npc(NpcNum).MAGI * 2
End Function

Function GetNpcMaxSP(ByVal NpcNum As Long)
    ' Prevent subscript out of range
    If NpcNum <= 0 Or NpcNum > MAX_NPCS Then
        GetNpcMaxSP = 0
        Exit Function
    End If

    GetNpcMaxSP = Npc(NpcNum).SPEED * 2
End Function

Function GetPlayerHPRegen(ByVal Index As Long)
    Dim I As Long

    ' Prevent subscript out of range
    If IsPlaying(Index) = False Or Index <= 0 Or Index > MAX_PLAYERS Then
        GetPlayerHPRegen = 0
        Exit Function
    End If

    I = Int(GetPlayerDEF(Index) / 2)
    If I < 2 Then I = 2

    GetPlayerHPRegen = I
End Function

Function GetPlayerMPRegen(ByVal Index As Long)
    Dim I As Long

    ' Prevent subscript out of range
    If IsPlaying(Index) = False Or Index <= 0 Or Index > MAX_PLAYERS Then
        GetPlayerMPRegen = 0
        Exit Function
    End If

    I = Int(GetPlayerMAGI(Index) / 2)
    If I < 2 Then I = 2

    GetPlayerMPRegen = I
End Function

Function GetPlayerSPRegen(ByVal Index As Long)
    Dim I As Long

    ' Prevent subscript out of range
    If IsPlaying(Index) = False Or Index <= 0 Or Index > MAX_PLAYERS Then
        GetPlayerSPRegen = 0
        Exit Function
    End If

    I = Int(GetPlayerSPEED(Index) / 2)
    If I < 2 Then I = 2

    GetPlayerSPRegen = I
End Function

Function GetNpcHPRegen(ByVal NpcNum As Long)
    Dim I As Long

    ' Prevent subscript out of range
    If NpcNum <= 0 Or NpcNum > MAX_NPCS Then
        GetNpcHPRegen = 0
        Exit Function
    End If

    I = Int(Npc(NpcNum).DEF / 3)
    If I < 1 Then I = 1

    GetNpcHPRegen = I
End Function

Sub CheckPlayerLevelUp(ByVal Index As Long)
    Dim I As Long
    Dim N, f As Byte
    Dim ExtraEXP As Long



    ' Check if attacker got a level up
    If GetPlayerExp(Index) >= GetPlayerNextLevel(Index) Then
        MyScript.ExecuteStatement "\scripts\Main.as", "OnLevelUp " & Index
' Call SetPlayerLevel(Index, GetPlayerLevel(Index) + 1)

' If GetPlayerExp(Player) > GetPlayerNextLevel(Player) Then
' ExtraEXP = (GetPlayerExp(Player) - GetPlayerNextLevel(Player))
' Else
' ExtraEXP = 0
' End If

' Get the ammount of skill points to add
' I = Int(GetPlayerSPEED(Index) / 10)
' If I < 1 Then I = 1
' If I > 3 Then I = 3
' If I > 5 Then I = 4
' If I > 9 Then I = 5

        ' Call SetPlayerPOINTS(Index, GetPlayerPOINTS(Index) + I)
        ' Call SetPlayerExp(Index, ExtraEXP)
        Call SendExp(Index)

    ' Call GlobalMsg(GetPlayerName(Index) & " has gained a level!", Brown)
    ' Call PlayerMsg(Index, "You have gained a level!  You now have " & GetPlayerPOINTS(Index) & " stat points to distribute.", BrightBlue)
    End If

    Call CheckPlayerLevelUp(Index)

End Sub

Sub CastSpell(ByVal Index As Long, ByVal SpellSlot As Long)
    Dim SpellNum As Long, MPReq As Long, I As Long, N As Long, Damage As Long
    Dim NpcNum As Long, Name As String, MapNpcNum As Long
    Dim Casted As Boolean, Exp As Long

    Casted = False

    ' Prevent subscript out of range
    If SpellSlot <= 0 Or SpellSlot > MAX_PLAYER_SPELLS Then
        Exit Sub
    End If

    SpellNum = GetPlayerSpell(Index, SpellSlot)

    ' Make sure player has the spell
    If Not HasSpell(Index, SpellNum) Then
        Call PlayerMsg(Index, "You do not have this spell!", BrightRed)
        Exit Sub
    End If

    I = GetSpellReqLevel(Index, SpellNum)
    ' MPReq = (I + Spell(SpellNum).Data1 + Spell(SpellNum).Data2 + Spell(SpellNum).Data3)
    MPReq = GetSpellReqMP(Index, SpellNum)

    ' Check if they have enough MP
    If GetPlayerMP(Index) < MPReq Then
        Call PlayerMsg(Index, "Not enough mana points!", BrightRed)
        Exit Sub
    End If

    ' Make sure they are the right level
    If I > GetPlayerLevel(Index) Then
        Call PlayerMsg(Index, "You must be level " & I & " to cast this spell.", BrightRed)
        Exit Sub
    End If

    ' Check if timer is ok
    If GetTickCount < Player(Index).AttackTimer + 1000 Then
        Exit Sub
    End If

    ' Check if the spell is a give item and do that instead of a stat modification
    If Spell(SpellNum).Type = SPELL_TYPE_GIVEITEM Then
        N = FindOpenInvSlot(Index, Spell(SpellNum).Data1)

        If N > 0 Then
            Call GiveItem(Index, Spell(SpellNum).Data1, Spell(SpellNum).Data2)
            Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " casts " & Trim$(Spell(SpellNum).Name) & ".", BrightBlue)

            ' Take away the mana points
            Call SetPlayerMP(Index, GetPlayerMP(Index) - MPReq)
            Call SendMP(Index)
            Casted = True
            Call SendSpellAnim(Index, Spell(SpellNum).Graphic, GetPlayerX(Index), GetPlayerY(Index))

        Else
            Call PlayerMsg(Index, "Your inventory is full!", BrightRed)
        End If

        Exit Sub
    End If

    N = Player(Index).Target

    If Player(Index).TargetType = TARGET_TYPE_PLAYER Then
        If IsPlaying(N) Then
            If GetPlayerHP(N) > 0 And GetPlayerMap(Index) = GetPlayerMap(N) And GetPlayerLevel(Index) >= 10 And GetPlayerLevel(N) >= 10 And Map(GetPlayerMap(Index)).Moral = MAP_MORAL_NONE Or Map(GetPlayerMap(Index)).Moral = MAP_MORAL_ARENA And GetPlayerAccess(Index) <= 1 And GetPlayerAccess(N) <= 1 Then
                ' If GetPlayerLevel(n) + 5 >= GetPlayerLevel(Index) Then
                ' If GetPlayerLevel(n) - 5 <= GetPlayerLevel(Index) Then
                Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " casts " & Trim$(Spell(SpellNum).Name) & " on " & GetPlayerName(N) & ".", BrightBlue)
                Call SendTargetXY(Index, GetPlayerX(N), GetPlayerY(N), GetPlayerMap(Index), Spell(SpellNum).Graphic)

                Select Case Spell(SpellNum).Type
                    Case SPELL_TYPE_SUBHP

                        Damage = (Int(GetPlayerMAGI(Index) / 4) + Spell(SpellNum).Data1) - GetPlayerProtection(N)
                        If Damage > 0 And Damage < GetPlayerHP(N) Then
                            Call SetPlayerHP(N, GetPlayerHP(N) - Damage)
                            Call SendHP(N)
                            Call PlayerMsg(Index, Trim$(Spell(SpellNum).Name) & " dealt " & STR$(Damage) & " damage to " & Trim$(GetPlayerName(N)), Yellow)
                            Call PlayerMsg(N, Trim$(GetPlayerName(Index)) & "'s spell dealt " & STR$(Damage) & " damage to you!", BrightRed)
                        ElseIf Damage >= GetPlayerHP(N) Then   ' KillPlayerSpell
                            ' Set HP to nothing
                            Call SetPlayerHP(N, 0)

                            ' Check for a weapon and say damage
                            Call PlayerMsg(Index, Trim$(Spell(SpellNum).Name) & " dealt " & STR$(Damage) & " damage to " & Trim$(GetPlayerName(N)), Yellow)
                            Call PlayerMsg(N, Trim$(GetPlayerName(Index)) & "'s spell dealt " & STR$(Damage) & " damage to you!", BrightRed)

                            ' Player is dead
                            If Map(GetPlayerMap(Index)).Moral = MAP_MORAL_ARENA Then
                                Call GlobalMsg(GetPlayerName(N) & " was defeated in an arena by " & GetPlayerName(Index) & "." & GetPlayerName(N) & " lost no EXP.", Yellow)
                            Else
                                Call GlobalMsg(GetPlayerName(N) & " has been killed by " & GetPlayerName(Index), BrightRed)
                            End If

                            ' If map is an arena then don't drop items or lose exp
                            If Map(GetPlayerMap(Index)).Moral <> MAP_MORAL_ARENA Then

                                ' Drop all worn items by victim
                                If GetPlayerWeaponSlot(N) > 0 Then
                                    Call PlayerMapDropItem(N, GetPlayerWeaponSlot(N), 0)
                                End If

                                If GetPlayerArmorSlot(N) > 0 Then
                                    Call PlayerMapDropItem(N, GetPlayerArmorSlot(N), 0)
                                End If

                                If GetPlayerHelmetSlot(N) > 0 Then
                                    Call PlayerMapDropItem(N, GetPlayerHelmetSlot(N), 0)
                                End If

                                If GetPlayerShieldSlot(N) > 0 Then
                                    Call PlayerMapDropItem(N, GetPlayerShieldSlot(N), 0)
                                End If

                                ' Calculate exp to give attacker
                                Exp = Int(GetPlayerExp(N) / 10)

                                ' Make sure we dont get less then 0
                                If Exp < 0 Then
                                    Exp = 0
                                End If

                                If Exp = 0 Then
                                    Call PlayerMsg(N, "You lost no experience points.", BrightRed)
                                    Call PlayerMsg(Index, "You received no experience points from that weak insignificant player.", BrightBlue)
                                Else
                                    Call SetPlayerExp(N, GetPlayerExp(N) - Exp)
                                    Call PlayerMsg(N, "You lost " & Exp & " experience points.", BrightRed)
                                    Call SetPlayerExp(Index, GetPlayerExp(Index) + Exp)
                                    Call PlayerMsg(Index, "You got " & Exp & " experience points for killing " & GetPlayerName(N) & ".", BrightBlue)
                                End If
                            End If

                            ' Warp player away
                            If Map(GetPlayerMap(N)).BootMap > 0 And Map(GetPlayerMap(N)).BootX > 0 And Map(GetPlayerMap(N)).BootY > 0 Then
                                Call PlayerWarp(N, Map(GetPlayerMap(N)).BootMap, Map(GetPlayerMap(N)).BootX, Map(GetPlayerMap(N)).BootY)
                            Else
                                Call PlayerWarp(N, START_MAP, START_X, START_Y)
                            End If

                            ' Restore vitals
                            Call SetPlayerHP(N, GetPlayerMaxHP(N))
                            Call SetPlayerMP(N, GetPlayerMaxMP(N))
                            Call SetPlayerSP(N, GetPlayerMaxSP(N))
                            Call SendHP(N)
                            Call SendMP(N)
                            Call SendSP(N)
                            Call SendExp(N)

                            ' Check for a level up
                            Call CheckPlayerLevelUp(Index)

                            ' Check if target is player who died and if so set target to 0
                            If Player(Index).TargetType = TARGET_TYPE_PLAYER And Player(Index).Target = N Then
                                Player(Index).Target = 0
                                Player(Index).TargetType = 0
                            End If

                            ' Don't deam a PKer if it's an arena
                            If Map(GetPlayerMap(Index)).Moral <> MAP_MORAL_ARENA Then
                                If GetPlayerPK(N) = NO Then
                                    If GetPlayerPK(Index) = NO Then
                                        Call SetPlayerPK(Index, YES)
                                        Call SendPlayerData(Index)
                                        Call GlobalMsg(GetPlayerName(Index) & " has been deemed a Player Killer!!!", BrightRed)
                                    End If
                                Else
                                    Call SetPlayerPK(N, NO)
                                    Call SendPlayerData(N)
                                    Call GlobalMsg(GetPlayerName(N) & " has paid the price for being a Player Killer!!!", BrightRed)
                                End If
                            End If
                        Else
                            Call PlayerMsg(Index, "The spell was to weak to hurt " & GetPlayerName(N) & "!", BrightRed)
                        End If

                    Case SPELL_TYPE_SUBMP
                        Call SetPlayerMP(N, GetPlayerMP(N) - Spell(SpellNum).Data1)
                        Call SendMP(N)
                        Call PlayerMsg(Index, Trim$(Spell(SpellNum).Name) & " dispersed " & STR$(Spell(SpellNum).Data1) & " MP from " & Trim$(GetPlayerName(N)), Yellow)
                        Call PlayerMsg(N, Trim$(GetPlayerName(Index)) & "'s spell dispersed " & STR$(Spell(SpellNum).Data1) & " of your MP!", BrightRed)

                    Case SPELL_TYPE_SUBSP
                        Call SetPlayerSP(N, GetPlayerSP(N) - Spell(SpellNum).Data1)
                        Call SendSP(N)
                        Call PlayerMsg(Index, Trim$(Spell(SpellNum).Name) & " dispersed " & STR$(Spell(SpellNum).Data1) & " SP from " & Trim$(GetPlayerName(N)), Yellow)
                        Call PlayerMsg(N, Trim$(GetPlayerName(Index)) & "'s spell dispersed " & STR$(Spell(SpellNum).Data1) & " of your SP!", BrightRed)
                End Select
' Else
' Call PlayerMsg(Index, GetPlayerName(n) & " is far to powerful to even consider attacking.", BrightBlue)
' End If
' Else
' Call PlayerMsg(Index, GetPlayerName(n) & " is to weak to even bother with.", BrightBlue)
' End If

                ' Take away the mana points
                Call SetPlayerMP(Index, GetPlayerMP(Index) - MPReq)
                Call SendMP(Index)
                Casted = True
                Call SendTargetXY(Index, GetPlayerX(N), GetPlayerY(N), GetPlayerMap(Index), Spell(SpellNum).Graphic)

            Else
                If GetPlayerMap(Index) = GetPlayerMap(N) And Spell(SpellNum).Type >= SPELL_TYPE_ADDHP And Spell(SpellNum).Type <= SPELL_TYPE_ADDSP Then
                    Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " casts " & Trim$(Spell(SpellNum).Name) & " on " & GetPlayerName(N) & ".", BrightBlue)
                    Select Case Spell(SpellNum).Type

                        Case SPELL_TYPE_ADDHP
                            Call SetPlayerHP(N, GetPlayerHP(N) + Spell(SpellNum).Data1)
                            Call SendHP(N)
                            Call PlayerMsg(Index, Trim$(Spell(SpellNum).Name) & " healed " & Trim$(GetPlayerName(N)) & " for " & STR$(Spell(SpellNum).Data1) & " HP!", BrightGreen)
                            Call PlayerMsg(N, Trim$(GetPlayerName(Index)) & "'s spell healed you for " & STR$(Spell(SpellNum).Data1) & " HP!", BrightGreen)

                        Case SPELL_TYPE_ADDMP
                            Call SetPlayerMP(N, GetPlayerMP(N) + Spell(SpellNum).Data1)
                            Call SendMP(N)
                            Call PlayerMsg(Index, Trim$(Spell(SpellNum).Name) & " healed " & Trim$(GetPlayerName(N)) & " for " & STR$(Spell(SpellNum).Data1) & " MP!", BrightGreen)
                            Call PlayerMsg(N, Trim$(GetPlayerName(Index)) & "'s spell healed you for " & STR$(Spell(SpellNum).Data1) & " HP!", BrightGreen)

                        Case SPELL_TYPE_ADDSP
                            Call SetPlayerSP(N, GetPlayerSP(N) + Spell(SpellNum).Data1)
                            Call SendSP(N)
                            Call PlayerMsg(Index, Trim$(Spell(SpellNum).Name) & " healed " & Trim$(GetPlayerName(N)) & " for " & STR$(Spell(SpellNum).Data1) & " SP!", BrightGreen)
                            Call PlayerMsg(N, Trim$(GetPlayerName(Index)) & "'s spell healed you for " & STR$(Spell(SpellNum).Data1) & " HP!", BrightGreen)
                    End Select

                    ' Take away the mana points
                    Call SetPlayerMP(Index, GetPlayerMP(Index) - MPReq)
                    Call SendMP(Index)
                    Casted = True

                ElseIf GetPlayerMap(Index) = GetPlayerMap(N) And Spell(SpellNum).Type = SPELL_TYPE_WARP Then
                    Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " warps " & GetPlayerName(N) & " by casting " & Trim$(Spell(SpellNum).Name) & "!", BrightBlue)
                    Call PlayerWarp(N, Spell(SpellNum).Data1, Spell(SpellNum).Data2, Spell(SpellNum).Data3)

                    ' Take away the mana points
                    Call SetPlayerMP(Index, GetPlayerMP(Index) - MPReq)
                    Call SendMP(Index)
                    Casted = True
                Else
                    Call PlayerMsg(Index, "Could not cast spell!", BrightRed)
                End If
            End If
        Else
            Call PlayerMsg(Index, "Could not cast spell!", BrightRed)
        End If
    Else
        NpcNum = MapNpc(GetPlayerMap(Index), N).Num
        Name = Trim$(Npc(NpcNum).Name)
        If Npc(NpcNum).Behavior <> NPC_BEHAVIOR_FRIENDLY And Npc(NpcNum).Behavior <> NPC_BEHAVIOR_SHOPKEEPER Then
            If IsVowel(Name) = True Then
                Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " casts " & Trim$(Spell(SpellNum).Name) & " on an " & Trim$(Npc(NpcNum).Name) & ".", BrightBlue)
            Else
                Call MapMsg(GetPlayerMap(Index), GetPlayerName(Index) & " casts " & Trim$(Spell(SpellNum).Name) & " on a " & Trim$(Npc(NpcNum).Name) & ".", BrightBlue)
            End If
            Call SendTargetXY(Index, MapNpc(GetPlayerMap(Index), N).X, MapNpc(GetPlayerMap(Index), N).y, GetPlayerMap(Index), Spell(SpellNum).Graphic)
            Casted = True

            Select Case Spell(SpellNum).Type
                Case SPELL_TYPE_ADDHP
                    MapNpc(GetPlayerMap(Index), N).HP = MapNpc(GetPlayerMap(Index), N).HP + Spell(SpellNum).Data1
                Case SPELL_TYPE_SUBHP   ' I am here

                    Damage = (Int(GetPlayerMAGI(Index) / 4) + Spell(SpellNum).Data1) - Int(Npc(NpcNum).DEF / 2)
                    If Damage > 0 And Damage < MapNpc(GetPlayerMap(Index), N).HP Then
                        MapNpc(GetPlayerMap(Index), N).HP = MapNpc(GetPlayerMap(Index), N).HP - Damage
                        Call PlayerMsg(Index, "Your spell dealt " & STR$(Damage) & " damage!", Yellow)
                    ElseIf Damage >= MapNpc(GetPlayerMap(Index), N).HP Then
                        Call PlayerMsg(Index, "Your spell dealt " & Damage & " damage, killing it.", BrightRed)

                        ' Calculate exp to give attacker
                        Exp = Npc(NpcNum).GiveEXP

                        ' Make sure we dont get less then 0
                        If Exp < 0 Then
                            Exp = 1
                        End If

                        ' Check if in party, if so divide the exp up by 2
                        If Player(Index).InParty = NO Then
                            Call SetPlayerExp(Index, GetPlayerExp(Index) + Exp)
                            Call PlayerMsg(Index, "You have gained " & Exp & " experience points.", BrightBlue)
                            Call SendExp(Index)
                        Else
                            Exp = Exp / 2

                            If Exp < 0 Then
                                Exp = 1
                            End If

                            Call SetPlayerExp(Index, GetPlayerExp(Index) + Exp)
                            Call PlayerMsg(Index, "You have gained " & Exp & " party experience points.", BrightBlue)
                            Call SendExp(Index)

                            I = Player(Index).PartyPlayer
                            If I > 0 Then
                                Call SetPlayerExp(N, GetPlayerExp(I) + Exp)
                                Call PlayerMsg(I, "You have gained " & Exp & " party experience points.", BrightBlue)
                                Call SendExp(I)
                            End If
                        End If

                        ' Drop the goods if they get it
                        If Npc(NpcNum).DropItem > 0 And Npc(NpcNum).DropChance > 0 Then
                            I = Int(Rnd * Npc(NpcNum).DropChance) + 1
                            If I = 1 Then
                                Call SpawnItem(Npc(NpcNum).DropItem, Npc(NpcNum).DropItemValue, GetPlayerMap(Index), MapNpc(GetPlayerMap(Index), N).X, MapNpc(GetPlayerMap(Index), N).y)
                            End If
                        End If

                        ' Now set HP to 0 so we know to actually kill them in the server loop (this prevents subscript out of range)
                        MapNpc(GetPlayerMap(Index), N).Num = 0
                        MapNpc(GetPlayerMap(Index), N).SpawnWait = GetTickCount
                        MapNpc(GetPlayerMap(Index), N).HP = 0
                        Call SendDataToMap(GetPlayerMap(Index), "NPCDEAD" & SEP_CHAR & NpcNum & END_CHAR)

                        ' Check for level up
                        Call CheckPlayerLevelUp(Index)

                        ' Check for level up party member
                        If Player(Index).InParty = YES Then
                            Call CheckPlayerLevelUp(Player(Index).PartyPlayer)
                        End If

                        ' Check if target is npc that died and if so set target to 0
                        If Player(Index).TargetType = TARGET_TYPE_NPC And Player(Index).Target = N Then
                            Player(Index).Target = 0
                            Player(Index).TargetType = 0
                        End If
                    Else
                        Call PlayerMsg(Index, "The spell was to weak to hurt " & Trim$(Npc(MapNpc(GetPlayerMap(Index), N).Num).Name) & "!", BrightRed)
                    End If

                Case SPELL_TYPE_ADDMP
                    MapNpc(GetPlayerMap(Index), N).MP = MapNpc(GetPlayerMap(Index), N).MP + Spell(SpellNum).Data1

                Case SPELL_TYPE_SUBMP
                    MapNpc(GetPlayerMap(Index), N).MP = MapNpc(GetPlayerMap(Index), N).MP - Spell(SpellNum).Data1

                Case SPELL_TYPE_ADDSP
                    MapNpc(GetPlayerMap(Index), N).SP = MapNpc(GetPlayerMap(Index), N).SP + Spell(SpellNum).Data1

                Case SPELL_TYPE_SUBSP
                    MapNpc(GetPlayerMap(Index), N).SP = MapNpc(GetPlayerMap(Index), N).SP - Spell(SpellNum).Data1

            End Select

            ' Take away the mana points
            Call SetPlayerMP(Index, GetPlayerMP(Index) - MPReq)
            Call SendMP(Index)

        Else
            Call PlayerMsg(Index, "Unable cast spell!", BrightRed)
        End If
    End If

' If Casted = True Then
' Player(Index).AttackTimer = GetTickCount
' Player(Index).CastedSpell = YES
' End If
End Sub

Function GetSpellReqLevel(ByVal Index As Long, ByVal SpellNum As Long)
    GetSpellReqLevel = Spell(SpellNum).LevelReq
End Function

Function GetSpellReqMP(ByVal Index As Long, ByVal SpellNum As Long)
    GetSpellReqMP = Spell(SpellNum).MPReq
End Function

Function CanPlayerCriticalHit(ByVal Index As Long) As Boolean
    Dim I As Long, N As Long

    CanPlayerCriticalHit = False

    If GetPlayerWeaponSlot(Index) > 0 Then
        N = Int(Rnd * 2)
        If N = 1 Then
            I = Int(GetPlayerSTR(Index) / 2) + Int(GetPlayerLevel(Index) / 2)

            N = Int(Rnd * 100) + 1
            If N <= I Then
                CanPlayerCriticalHit = True
            End If
        End If
    End If
End Function

Function CanPlayerBlockHit(ByVal Index As Long) As Boolean
    Dim I As Long, N As Long, ShieldSlot As Long

    CanPlayerBlockHit = False

    ShieldSlot = GetPlayerShieldSlot(Index)

    If ShieldSlot > 0 Then
        N = Int(Rnd * 2)
        If N = 1 Then
            I = Int(GetPlayerDEF(Index) / 2) + Int(GetPlayerLevel(Index) / 2)

            N = Int(Rnd * 100) + 1
            If N <= I Then
                CanPlayerBlockHit = True
            End If
        End If
    End If
End Function

Sub CheckEquippedItems(ByVal Index As Long)
    Dim Slot As Long, ItemNum As Long

    ' We want to check incase an admin takes away an object but they had it equipped
    Slot = GetPlayerWeaponSlot(Index)
    If Slot > 0 Then
        ItemNum = GetPlayerInvItemNum(Index, Slot)

        If ItemNum > 0 Then
            If Item(ItemNum).Type <> ITEM_TYPE_WEAPON Then
                Call SetPlayerWeaponSlot(Index, 0)
            End If
        Else
            Call SetPlayerWeaponSlot(Index, 0)
        End If
    End If

    Slot = GetPlayerArmorSlot(Index)
    If Slot > 0 Then
        ItemNum = GetPlayerInvItemNum(Index, Slot)

        If ItemNum > 0 Then
            If Item(ItemNum).Type <> ITEM_TYPE_ARMOR Then
                Call SetPlayerArmorSlot(Index, 0)
            End If
        Else
            Call SetPlayerArmorSlot(Index, 0)
        End If
    End If

    Slot = GetPlayerHelmetSlot(Index)
    If Slot > 0 Then
        ItemNum = GetPlayerInvItemNum(Index, Slot)

        If ItemNum > 0 Then
            If Item(ItemNum).Type <> ITEM_TYPE_HELMET Then
                Call SetPlayerHelmetSlot(Index, 0)
            End If
        Else
            Call SetPlayerHelmetSlot(Index, 0)
        End If
    End If

    Slot = GetPlayerShieldSlot(Index)
    If Slot > 0 Then
        ItemNum = GetPlayerInvItemNum(Index, Slot)

        If ItemNum > 0 Then
            If Item(ItemNum).Type <> ITEM_TYPE_SHIELD Then
                Call SetPlayerShieldSlot(Index, 0)
            End If
        Else
            Call SetPlayerShieldSlot(Index, 0)
        End If
    End If
End Sub


Sub ClearTempTile()
    Dim I As Long, y As Long, X As Long

    For I = 1 To MAX_MAPS_SET
        TempTile(I).DoorTimer = 0

        For y = 0 To MAX_MAPY
            For X = 0 To MAX_MAPX
                TempTile(I).DoorOpen(X, y) = NO
            Next X
        Next y
    Next I
End Sub

Sub ClearClasses()
    Dim I As Long
    ReDim Class(0 To Max_Classes) As ClassRec
    For I = 0 To Max_Classes
        ResetClassRec Class(I)
    Next I
End Sub

Sub ClearPlayer(ByVal Index As Long)
    Dim I As Long
    Player(Index).Login = vbNullString
    Player(Index).Password = vbNullString
    Player(Index).EncKey = vbNullString
    For I = 0 To MAX_CHARS
        ResetPlayerRec Player(Index).Char(I)
    Next I
    Player(Index).Buffer = vbNullString
    Player(Index).IncBuffer = vbNullString
    Player(Index).CharNum = 0
    Player(Index).InGame = False
    Player(Index).AttackTimer = 0
    Player(Index).DataTimer = 0
    Player(Index).DataBytes = 0
    Player(Index).DataPackets = 0
    Player(Index).PartyPlayer = 0
    Player(Index).InParty = 0
    Player(Index).TargetType = 0
    Player(Index).Target = 0
    Player(Index).CastedSpell = 0
    Player(Index).PartyStarter = 0
    Player(Index).GettingMap = 0
    Player(Index).HDSerial = vbNullString
    Player(Index).WarpTick = 0
End Sub

Sub ClearChar(ByVal Index As Long, ByVal CharNum As Long)
    ResetPlayerRec Player(Index).Char(CharNum)
End Sub

Sub ClearItem(ByVal Index As Long)
    ResetItemRec Item(Index)
End Sub

Sub ClearItems()
    Dim I As Long

    For I = 1 To MAX_ITEMS
        Call ClearItem(I)
    Next I
End Sub

Sub ClearNpc(ByVal Index As Long)
    ResetNpcRec Npc(Index)
End Sub

Sub ClearNpcs()
    Dim I As Long

    For I = 1 To MAX_NPCS
        Call ClearNpc(I)
    Next I
End Sub

Sub ClearSign(ByVal Index As Long)
    ResetSignRec Sign(Index)
End Sub

Sub ClearSigns()
    Dim I As Long

    For I = 1 To MAX_SIGNS
        Call ClearSign(I)
    Next I
End Sub

Sub ClearGuild(ByVal Index As Long)
    ResetGuildRec Guild(Index)
End Sub

Sub ClearGuilds()
    Dim I As Long

    For I = 1 To MAX_GUILDS
        Call ClearGuild(I)
    Next I
End Sub

Sub ClearQuest(ByVal Index As Long)
    ResetQuestRec Quest(Index)
End Sub

Sub ClearQuests()
    Dim I As Long

    For I = 1 To MAX_QUESTS
        Call ClearQuest(I)
    Next I
End Sub

Sub ClearMapItem(ByVal Index As Long, ByVal MapNum As Long)
    MapItem(MapNum, Index).Num = 0
    MapItem(MapNum, Index).Value = 0
    MapItem(MapNum, Index).Dur = 0
    MapItem(MapNum, Index).X = 0
    MapItem(MapNum, Index).y = 0
End Sub

Sub ClearMapItems()
    Dim X As Long
    Dim y As Long

    For y = 1 To MAX_MAPS_SET
        For X = 1 To MAX_MAP_ITEMS
            Call ClearMapItem(X, y)
        Next X
    Next y
End Sub

Sub ClearMapNpc(ByVal Index As Long, ByVal MapNum As Long)
    MapNpc(MapNum, Index).Num = 0
    MapNpc(MapNum, Index).Target = 0
    MapNpc(MapNum, Index).HP = 0
    MapNpc(MapNum, Index).MP = 0
    MapNpc(MapNum, Index).SP = 0
    MapNpc(MapNum, Index).X = 0
    MapNpc(MapNum, Index).y = 0
    MapNpc(MapNum, Index).Dir = 0

    ' Server use only
    MapNpc(MapNum, Index).SpawnWait = 0
    MapNpc(MapNum, Index).AttackTimer = 0
End Sub

Sub ClearMapNpcs()
    Dim X As Long
    Dim y As Long

    For y = 1 To MAX_MAPS_SET
        For X = 1 To MAX_MAP_NPCS
            Call ClearMapNpc(X, y)
        Next X
    Next y
End Sub

Sub ClearMap(ByVal MapNum As Long)
    ResetMapRec Map(MapNum)
    PlayersOnMap(MapNum) = NO
End Sub

Sub ClearMaps()
    Dim I As Long

    For I = 1 To MAX_MAPS_SET
        Call ClearMap(I)
    Next I
End Sub

Sub ClearShop(ByVal Index As Long)
    ResetShopRec Shop(Index)
End Sub

Sub ClearShops()
    Dim I As Long

    For I = 1 To MAX_SHOPS
        Call ClearShop(I)
    Next I
End Sub

Sub ClearSpell(ByVal Index As Long)
    ResetSpellRec Spell(Index)
End Sub

Sub ClearSpells()
    Dim I As Long

    For I = 1 To MAX_SPELLS
        Call ClearSpell(I)
    Next I
End Sub




' //////////////////////
' // PLAYER FUNCTIONS //
' //////////////////////

Function GetPlayerLogin(ByVal Index As Long) As String
    GetPlayerLogin = Trim$(Player(Index).Login)
End Function

Sub SetPlayerLogin(ByVal Index As Long, ByVal Login As String)
    Player(Index).Login = Login
End Sub

Function GetPlayerPassword(ByVal Index As Long) As String
    GetPlayerPassword = Trim$(Player(Index).Password)
End Function

Sub SetPlayerPassword(ByVal Index As Long, ByVal Password As String)
    Player(Index).Password = Password
End Sub

Function GetPlayerName(ByVal Index As Long) As String
    GetPlayerName = Trim$(Player(Index).Char(Player(Index).CharNum).Name)
End Function

Sub SetPlayerName(ByVal Index As Long, ByVal Name As String)
    Player(Index).Char(Player(Index).CharNum).Name = Name
End Sub

Sub SetPlayerClass(ByVal Index As Long, ByVal ClassNum As Long)
    Player(Index).Char(Player(Index).CharNum).Class = ClassNum
End Sub

Function GetPlayerClassName(ByVal Index As Long) As String
    GetPlayerClassName = Trim$(Class(Player(Index).Char(Player(Index).CharNum).Class).Name)
End Function

Function GetPlayerClass(ByVal Index As Long) As Long
    GetPlayerClass = Player(Index).Char(Player(Index).CharNum).Class
End Function

Function GetPlayerSprite(ByVal Index As Long) As Long
    GetPlayerSprite = Player(Index).Char(Player(Index).CharNum).Sprite
End Function

Sub SetPlayerSprite(ByVal Index As Long, ByVal Sprite As Long)
    Player(Index).Char(Player(Index).CharNum).Sprite = Sprite
End Sub

Function GetPlayerLevel(ByVal Index As Long) As Long
    GetPlayerLevel = Player(Index).Char(Player(Index).CharNum).Level
End Function

Sub SetPlayerLevel(ByVal Index As Long, ByVal Level As Long)
    Player(Index).Char(Player(Index).CharNum).Level = Level
End Sub

Function GetPlayerNextLevel(ByVal Index As Long) As Long
    GetPlayerNextLevel = (GetPlayerLevel(Index) + 1) * (GetPlayerSTR(Index) + GetPlayerDEF(Index) + GetPlayerMAGI(Index) + GetPlayerSPEED(Index) + GetPlayerPOINTS(Index)) * 25
End Function

Function GetPlayerExp(ByVal Index As Long) As Long
    GetPlayerExp = Player(Index).Char(Player(Index).CharNum).Exp
End Function

Sub SetPlayerExp(ByVal Index As Long, ByVal Exp As Long)
    Player(Index).Char(Player(Index).CharNum).Exp = Exp
End Sub

Function GetPlayerAccess(ByVal Index As Long) As Long
    GetPlayerAccess = Player(Index).Char(Player(Index).CharNum).Access
End Function

Sub SetPlayerAccess(ByVal Index As Long, ByVal Access As Long)
    Player(Index).Char(Player(Index).CharNum).Access = Access
End Sub

Function GetPlayerPK(ByVal Index As Long) As Long
    GetPlayerPK = Player(Index).Char(Player(Index).CharNum).PK
End Function

Sub SetPlayerPK(ByVal Index As Long, ByVal PK As Long)
    Player(Index).Char(Player(Index).CharNum).PK = PK
End Sub

Function GetPlayerHP(ByVal Index As Long) As Long
    GetPlayerHP = Player(Index).Char(Player(Index).CharNum).HP
End Function

Sub SetPlayerHP(ByVal Index As Long, ByVal HP As Long)
    Player(Index).Char(Player(Index).CharNum).HP = HP

    If GetPlayerHP(Index) > GetPlayerMaxHP(Index) Then
        Player(Index).Char(Player(Index).CharNum).HP = GetPlayerMaxHP(Index)
    End If
    If GetPlayerHP(Index) < 0 Then
        Player(Index).Char(Player(Index).CharNum).HP = 0
    End If
End Sub

Function GetPlayerMP(ByVal Index As Long) As Long
    GetPlayerMP = Player(Index).Char(Player(Index).CharNum).MP
End Function

Sub SetPlayerMP(ByVal Index As Long, ByVal MP As Long)
    Player(Index).Char(Player(Index).CharNum).MP = MP

    If GetPlayerMP(Index) > GetPlayerMaxMP(Index) Then
        Player(Index).Char(Player(Index).CharNum).MP = GetPlayerMaxMP(Index)
    End If
    If GetPlayerMP(Index) < 0 Then
        Player(Index).Char(Player(Index).CharNum).MP = 0
    End If
End Sub

Function GetPlayerSP(ByVal Index As Long) As Long
    GetPlayerSP = Player(Index).Char(Player(Index).CharNum).SP
End Function

Sub SetPlayerSP(ByVal Index As Long, ByVal SP As Long)
    Player(Index).Char(Player(Index).CharNum).SP = SP

    If GetPlayerSP(Index) > GetPlayerMaxSP(Index) Then
        Player(Index).Char(Player(Index).CharNum).SP = GetPlayerMaxSP(Index)
    End If
    If GetPlayerSP(Index) < 0 Then
        Player(Index).Char(Player(Index).CharNum).SP = 0
    End If
End Sub

Function GetPlayerMaxHP(ByVal Index As Long) As Long
    Dim CharNum As Long
    Dim I As Long

    CharNum = Player(Index).CharNum
    GetPlayerMaxHP = (Player(Index).Char(CharNum).Level + Int(GetPlayerSTR(Index) / 2) + Class(Player(Index).Char(CharNum).Class).STR) * 2
End Function

Function GetPlayerMaxMP(ByVal Index As Long) As Long
    Dim CharNum As Long

    CharNum = Player(Index).CharNum
    GetPlayerMaxMP = (Player(Index).Char(CharNum).Level + Int(GetPlayerMAGI(Index) / 2) + Class(Player(Index).Char(CharNum).Class).MAGI) * 2
End Function

Function GetPlayerMaxSP(ByVal Index As Long) As Long
    Dim CharNum As Long

    CharNum = Player(Index).CharNum
    GetPlayerMaxSP = (Player(Index).Char(CharNum).Level + Int(GetPlayerSPEED(Index) / 2) + Class(Player(Index).Char(CharNum).Class).SPEED) * 2
End Function

Function GetClassName(ByVal ClassNum As Long) As String
    GetClassName = Trim$(Class(ClassNum).Name)
End Function

Function GetClassMaxHP(ByVal ClassNum As Long) As Long
    GetClassMaxHP = (1 + Int(Class(ClassNum).STR / 2) + Class(ClassNum).STR) * 2
End Function

Function GetClassMaxMP(ByVal ClassNum As Long) As Long
    GetClassMaxMP = (1 + Int(Class(ClassNum).MAGI / 2) + Class(ClassNum).MAGI) * 2
End Function

Function GetClassMaxSP(ByVal ClassNum As Long) As Long
    GetClassMaxSP = (1 + Int(Class(ClassNum).SPEED / 2) + Class(ClassNum).SPEED) * 2
End Function

Function GetClassSTR(ByVal ClassNum As Long) As Long
    GetClassSTR = Class(ClassNum).STR
End Function

Function GetClassDEF(ByVal ClassNum As Long) As Long
    GetClassDEF = Class(ClassNum).DEF
End Function

Function GetClassSPEED(ByVal ClassNum As Long) As Long
    GetClassSPEED = Class(ClassNum).SPEED
End Function

Function GetClassMAGI(ByVal ClassNum As Long) As Long
    GetClassMAGI = Class(ClassNum).MAGI
End Function

Function GetPlayerSTR(ByVal Index As Long) As Long
    GetPlayerSTR = Player(Index).Char(Player(Index).CharNum).STR
End Function

Sub SetPlayerSTR(ByVal Index As Long, ByVal STR As Long)
    Player(Index).Char(Player(Index).CharNum).STR = STR
End Sub

Function GetPlayerDEF(ByVal Index As Long) As Long
    GetPlayerDEF = Player(Index).Char(Player(Index).CharNum).DEF
End Function

Sub SetPlayerDEF(ByVal Index As Long, ByVal DEF As Long)
    Player(Index).Char(Player(Index).CharNum).DEF = DEF
End Sub

Function GetPlayerSPEED(ByVal Index As Long) As Long
    GetPlayerSPEED = Player(Index).Char(Player(Index).CharNum).SPEED
End Function

Sub SetPlayerSPEED(ByVal Index As Long, ByVal SPEED As Long)
    Player(Index).Char(Player(Index).CharNum).SPEED = SPEED
End Sub

Function GetPlayerMAGI(ByVal Index As Long) As Long
    GetPlayerMAGI = Player(Index).Char(Player(Index).CharNum).MAGI
End Function

Sub SetPlayerMAGI(ByVal Index As Long, ByVal MAGI As Long)
    Player(Index).Char(Player(Index).CharNum).MAGI = MAGI
End Sub

Function GetPlayerPOINTS(ByVal Index As Long) As Long
    GetPlayerPOINTS = Player(Index).Char(Player(Index).CharNum).POINTS
End Function

Sub SetPlayerPOINTS(ByVal Index As Long, ByVal POINTS As Long)
    Player(Index).Char(Player(Index).CharNum).POINTS = POINTS
End Sub

Function GetPlayerGuild(ByVal Index As Long) As Long
    GetPlayerGuild = Player(Index).Char(Player(Index).CharNum).Guild
End Function

Function SetPlayerGuild(ByVal Index As Long, ByVal Guild As Long)
    Player(Index).Char(Player(Index).CharNum).Guild = Guild
End Function

Function GetPlayerMap(ByVal Index As Long) As Long
    GetPlayerMap = Player(Index).Char(Player(Index).CharNum).Map
End Function

Sub SetPlayerMap(ByVal Index As Long, ByVal MapNum As Long)
    If MapNum > 0 And MapNum <= MAX_MAPS_SET Then
        Player(Index).Char(Player(Index).CharNum).Map = MapNum
    End If
End Sub

Function GetPlayerX(ByVal Index As Long) As Long
    GetPlayerX = Player(Index).Char(Player(Index).CharNum).X
End Function

Sub SetPlayerX(ByVal Index As Long, ByVal X As Long)
    Player(Index).Char(Player(Index).CharNum).X = X
End Sub

Function GetPlayerY(ByVal Index As Long) As Long
    GetPlayerY = Player(Index).Char(Player(Index).CharNum).y
End Function

Sub SetPlayerY(ByVal Index As Long, ByVal y As Long)
    Player(Index).Char(Player(Index).CharNum).y = y
End Sub

Function GetPlayerDir(ByVal Index As Long) As Long
    GetPlayerDir = Player(Index).Char(Player(Index).CharNum).Dir
End Function

Sub SetPlayerDir(ByVal Index As Long, ByVal Dir As Long)
    Player(Index).Char(Player(Index).CharNum).Dir = Dir
End Sub

Function GetPlayerIP(ByVal Index As Long) As String
    ' GetPlayerIP = frmServer.Socket(index).RemoteHostIP
    GetPlayerIP = GameServer.Sockets(Index).RemoteAddress
End Function

Function GetPlayerInvItemNum(ByVal Index As Long, ByVal InvSlot As Long) As Long
    GetPlayerInvItemNum = Player(Index).Char(Player(Index).CharNum).Inv(InvSlot).Num
End Function

Function GetPlayerInvItemName(ByVal Index As Long, ByVal InvSlot As Long) As String
    GetPlayerInvItemName = Item(Player(Index).Char(Player(Index).CharNum).Inv(InvSlot).Num).Name
End Function

Sub SetPlayerInvItemNum(ByVal Index As Long, ByVal InvSlot As Long, ByVal ItemNum As Long)
    Player(Index).Char(Player(Index).CharNum).Inv(InvSlot).Num = ItemNum
End Sub

Function GetPlayerInvItemValue(ByVal Index As Long, ByVal InvSlot As Long) As Long
    GetPlayerInvItemValue = Player(Index).Char(Player(Index).CharNum).Inv(InvSlot).Value
End Function

Sub SetPlayerInvItemValue(ByVal Index As Long, ByVal InvSlot As Long, ByVal ItemValue As Long)
    Player(Index).Char(Player(Index).CharNum).Inv(InvSlot).Value = ItemValue
End Sub

Function GetPlayerInvItemDur(ByVal Index As Long, ByVal InvSlot As Long) As Long
    GetPlayerInvItemDur = Player(Index).Char(Player(Index).CharNum).Inv(InvSlot).Dur
End Function

Sub SetPlayerInvItemDur(ByVal Index As Long, ByVal InvSlot As Long, ByVal ItemDur As Long)
    Player(Index).Char(Player(Index).CharNum).Inv(InvSlot).Dur = ItemDur
End Sub

Function GetPlayerSpell(ByVal Index As Long, ByVal SpellSlot As Long) As Long
    GetPlayerSpell = Player(Index).Char(Player(Index).CharNum).Spell(SpellSlot)
End Function

Sub SetPlayerSpell(ByVal Index As Long, ByVal SpellSlot As Long, ByVal SpellNum As Long)
    Player(Index).Char(Player(Index).CharNum).Spell(SpellSlot) = SpellNum
End Sub

Function GetPlayerArmorSlot(ByVal Index As Long) As Long
    GetPlayerArmorSlot = Player(Index).Char(Player(Index).CharNum).ArmorSlot
End Function

Sub SetPlayerArmorSlot(ByVal Index As Long, InvNum As Long)
    Player(Index).Char(Player(Index).CharNum).ArmorSlot = InvNum
End Sub

Function GetPlayerWeaponSlot(ByVal Index As Long) As Long
    GetPlayerWeaponSlot = Player(Index).Char(Player(Index).CharNum).WeaponSlot
End Function

Sub SetPlayerWeaponSlot(ByVal Index As Long, InvNum As Long)
    Player(Index).Char(Player(Index).CharNum).WeaponSlot = InvNum
End Sub

Function GetPlayerHelmetSlot(ByVal Index As Long) As Long
    GetPlayerHelmetSlot = Player(Index).Char(Player(Index).CharNum).HelmetSlot
End Function

Sub SetPlayerHelmetSlot(ByVal Index As Long, InvNum As Long)
    Player(Index).Char(Player(Index).CharNum).HelmetSlot = InvNum
End Sub

Function GetPlayerShieldSlot(ByVal Index As Long) As Long
    GetPlayerShieldSlot = Player(Index).Char(Player(Index).CharNum).ShieldSlot
End Function

Sub SetPlayerShieldSlot(ByVal Index As Long, InvNum As Long)
    Player(Index).Char(Player(Index).CharNum).ShieldSlot = InvNum
End Sub

Function GetItemName(ByVal ItemNum As Long) As String
    GetItemName = Trim$(Item(ItemNum).Name)
End Function

Function GetNpcName(ByVal NpcNum As Long) As String
    GetNpcName = Trim$(Npc(NpcNum).Name)
End Function

Function GetPlayerHD(ByVal Index As Long) As String
    GetPlayerHD = Player(Index).HDSerial
End Function

Sub SetHighIndex()
    Dim I As Integer
    Dim X As Integer

    For I = 0 To MAX_PLAYERS
        X = MAX_PLAYERS - I

        If IsConnected(X) = True Then
            HighIndex = X
            Exit Sub
        End If

    Next I

    HighIndex = 0

End Sub

Function GetServerName()
    GetServerName = Trim$(GAME_NAME)
End Function

Public Sub CheckWarp()
    Dim I As Integer

    For I = 0 To HighIndex
        If IsConnected(I) Then
            If Player(I).WarpTick < GetTickCount And Player(I).WarpTick > 0 Then
                Call PlayerWarp(I, Map(GetPlayerMap(I)).Tile(GetPlayerX(I), _
                        GetPlayerY(I)).Data1, Map(GetPlayerMap(I)).Tile(GetPlayerX(I), GetPlayerY(I)).Data2, _
                        Map(GetPlayerMap(I)).Tile(GetPlayerX(I), GetPlayerY(I)).Data3)

                ' Reset WarpTick so it doesnt constantly warp them
                Player(I).WarpTick = 0
            End If
        End If
    Next I
End Sub
