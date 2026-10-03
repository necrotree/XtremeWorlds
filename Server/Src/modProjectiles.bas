Attribute VB_Name = "modProjectiles"
Option Explicit

Public Type ArrowRec
    Name As String
    Sprite As Long
    Range As Long
End Type
Public Type SpellDeliveryRec
    Mode As Long ' 0 = selected target within range, 1 = directional projectile
    Arrow As Long
    Range As Long
End Type
Private Type ProjectileRec
    Active As Boolean
    Owner As Long
    Map As Long
    Spell As Long
    Sprite As Long
    Direction As Long
    X As Long
    Y As Long
    Remaining As Long
    LastStep As Long
End Type
Public SpellDelivery() As SpellDeliveryRec
Private Shots(1 To MAX_PROJECTILES) As ProjectileRec
Private DeliveryReady As Boolean
Private UpdatingShots As Boolean

Public Function DeliveryFile() As String
    DeliveryFile = App.Path & "\data\Projectiles.ini"
End Function

Public Function DeliveryInteger(ByVal text As String, ByVal minimum As Long, ByVal maximum As Long, ByRef result As Long) As Boolean
    Dim value As Double
    If Len(text) = 0 Or Len(text) > 10 Then Exit Function
    If Not IsNumeric(text) Then Exit Function
    value = Val(text)
    If value <> Fix(value) Or value < minimum Or value > maximum Then Exit Function
    result = CLng(value)
    DeliveryInteger = True
End Function

Sub SaveArrows()
    Dim I As Long

    Call SetStatus("Saving arrows... ")

    For I = 1 To MAX_ARROWS

        If Not FileExist("data\arrows\arrow" & I & ".arw") Then
            Call SetStatus("Saving arrow... ")

            DoEvents
            Call SaveArrow(I)
        End If

    Next

End Sub

Sub SaveArrow(ByVal arrowNum As Long)
    Dim FileName As String
    Dim f  As Long

    FileName = App.Path & "\data\arrows\arrow" & arrowNum & ".arw"

    Dim dataFile4 As clsDataFile
    Set dataFile4 = New clsDataFile
    WriteArrowRec dataFile4, Arrow(arrowNum)
    dataFile4.Save FileName
End Sub

Sub CheckArrows()
    Call SaveArrows
End Sub

Sub LoadArrows()
    Dim FileName As String
    Dim I As Long
    Dim f As Long

    Call CheckArrows

    For I = 1 To MAX_ARROWS
        Call SetStatus("Loading arrows... ")
        FileName = App.Path & "\data\arrows\arrow" & I & ".arw"

        Dim dataFile5 As clsDataFile
        Set dataFile5 = New clsDataFile
        dataFile5.Load FileName
        ReadArrowRec dataFile5, Arrow(I)
        dataFile5.RequireEnd

        DoEvents
    Next

End Sub

Public Sub SendSpellDelivery(ByVal Index As Long, ByVal number As Long)
    If Not DeliveryReady Then Exit Sub
    With SpellDelivery(number)
        SendDataTo Index, "SPELLDELIVERY" & SEP_CHAR & number & SEP_CHAR & .Mode & SEP_CHAR & .Arrow & SEP_CHAR & .Range & END_CHAR
    End With
End Sub

' Validate the entire extension before the ordinary spell record is modified.
Public Function ReadSpellDelivery(ByRef packet() As String, ByRef mode As Long, ByRef arrow As Long, ByRef distance As Long) As Boolean
    mode = 0: arrow = 1: distance = 32
    If UBound(packet) = 10 Then
        ReadSpellDelivery = True ' Compatibility with the original spell editor.
        Exit Function
    End If
    If UBound(packet) <> 13 Then Exit Function
    If Not DeliveryInteger(packet(11), 0, 1, mode) Then Exit Function
    If Not DeliveryInteger(packet(12), 1, MAX_ARROWS, arrow) Then Exit Function
    If Not DeliveryInteger(packet(13), 1, 32, distance) Then Exit Function
    ReadSpellDelivery = True
End Function

Public Sub SaveSpellDelivery(ByVal number As Long, ByVal mode As Long, ByVal arrow As Long, ByVal distance As Long)
    Dim section As String, i As Long
    section = "Spell" & CStr(number)
    SpellDelivery(number).Mode = mode
    SpellDelivery(number).Arrow = arrow
    SpellDelivery(number).Range = distance
    PutVar DeliveryFile, section, "Mode", CStr(mode)
    PutVar DeliveryFile, section, "Arrow", CStr(arrow)
    PutVar DeliveryFile, section, "Range", CStr(distance)
    ' An edited spell must not change the effect of an already flying shot.
    For i = 1 To MAX_PROJECTILES
        If Shots(i).Active And Shots(i).Spell = number Then RemoveProjectile i
    Next
End Sub

Public Function CanSpellAffect(ByVal caster As Long, ByVal spellNumber As Long, ByVal targetType As Long, ByVal target As Long) As Boolean
    Dim mapNumber As Long, harmful As Boolean, npcNumber As Long
    mapNumber = GetPlayerMap(caster)
    harmful = Spell(spellNumber).Type >= SPELL_TYPE_SUBHP And Spell(spellNumber).Type <= SPELL_TYPE_SUBSP
    If targetType = TARGET_TYPE_PLAYER Then
        If target < 1 Or target > MAX_PLAYERS Then Exit Function
        If Not IsPlaying(target) Then Exit Function
        If GetPlayerMap(target) <> mapNumber Or GetPlayerHP(target) <= 0 Then Exit Function
        If harmful Then
            If caster = target Then Exit Function
            If GetPlayerAccess(caster) > 1 Or GetPlayerAccess(target) > 1 Then Exit Function
            If Map(mapNumber).Moral <> MAP_MORAL_ARENA Then
                If Map(mapNumber).Moral <> MAP_MORAL_NONE Then Exit Function
                If GetPlayerLevel(caster) < 10 Or GetPlayerLevel(target) < 10 Then Exit Function
            End If
        ElseIf Spell(spellNumber).Type = SPELL_TYPE_GIVEITEM Then
            If Spell(spellNumber).Data1 < 1 Or Spell(spellNumber).Data1 > MAX_ITEMS Then Exit Function
            If Spell(spellNumber).Data2 < 1 Then Exit Function
            If FindOpenInvSlot(target, Spell(spellNumber).Data1) = 0 Then Exit Function
        ElseIf Spell(spellNumber).Type = SPELL_TYPE_WARP Then
            If Spell(spellNumber).Data1 < 1 Or Spell(spellNumber).Data1 > MAX_MAPS_SET Then Exit Function
            If Spell(spellNumber).Data2 < 0 Or Spell(spellNumber).Data2 > MAX_MAPX Then Exit Function
            If Spell(spellNumber).Data3 < 0 Or Spell(spellNumber).Data3 > MAX_MAPY Then Exit Function
        End If
    ElseIf targetType = TARGET_TYPE_NPC Then
        If target < 1 Or target > MAX_MAP_NPCS Then Exit Function
        npcNumber = MapNpc(mapNumber, target).Num
        If npcNumber < 1 Or npcNumber > MAX_NPCS Then Exit Function
        If MapNpc(mapNumber, target).HP <= 0 Then Exit Function
        ' Inventory and player warp effects require a player recipient.
        If Spell(spellNumber).Type = SPELL_TYPE_GIVEITEM Or Spell(spellNumber).Type = SPELL_TYPE_WARP Then Exit Function
        If harmful Then
            If Npc(npcNumber).Behavior = NPC_BEHAVIOR_FRIENDLY Or Npc(npcNumber).Behavior = NPC_BEHAVIOR_SHOPKEEPER Then Exit Function
        End If
    Else
        Exit Function
    End If
    CanSpellAffect = True
End Function

Public Sub CastSpell(ByVal Index As Long, ByVal slot As Long)
    Dim number As Long, mana As Long, target As Long, targetType As Long
    Dim tx As Long, ty As Long, dx As Long, dy As Long, distance As Long
    If Not DeliveryReady Or Not IsPlaying(Index) Then Exit Sub
    If slot < 1 Or slot > MAX_PLAYER_SPELLS Then Exit Sub
    number = GetPlayerSpell(Index, slot)
    If number < 1 Or number > MAX_SPELLS Then Exit Sub
    If Spell(number).Type > SPELL_TYPE_WARP Then Exit Sub
    If GetPlayerHP(Index) <= 0 Then Exit Sub
    If GetTickCount < Player(Index).AttackTimer + 1000 Then Exit Sub
    If Spell(number).ClassReq <> 0 Then
        If Spell(number).ClassReq - 1 <> GetPlayerClass(Index) Then Exit Sub
    End If
    If GetPlayerLevel(Index) < Spell(number).LevelReq Then
        PlayerMsg Index, "Your level is too low to cast this spell.", BrightRed
        Exit Sub
    End If
    mana = Spell(number).MPReq
    If mana < 0 Then Exit Sub
    If GetPlayerMP(Index) < mana Then
        PlayerMsg Index, "Not enough mana points!", BrightRed
        Exit Sub
    End If
    If SpellDelivery(number).Mode = 1 Then
        If Not LaunchProjectile(Index, number) Then Exit Sub
    Else
        target = Player(Index).Target
        targetType = Player(Index).TargetType
        If target = 0 And (Spell(number).Type <= SPELL_TYPE_ADDSP Or Spell(number).Type >= SPELL_TYPE_GIVEITEM) Then
            target = Index
            targetType = TARGET_TYPE_PLAYER
        End If
        If Not CanSpellAffect(Index, number, targetType, target) Then
            PlayerMsg Index, "Select a valid target for this spell.", BrightRed
            Exit Sub
        End If
        If targetType = TARGET_TYPE_PLAYER Then
            tx = GetPlayerPixelX(target): ty = GetPlayerPixelY(target)
        Else
            tx = MapNpc(GetPlayerMap(Index), target).X * PIC_X
            ty = MapNpc(GetPlayerMap(Index), target).y * PIC_Y
        End If
        dx = tx - GetPlayerPixelX(Index): dy = ty - GetPlayerPixelY(Index)
        distance = SpellDelivery(number).Range * PIC_X
        If CDbl(dx) * dx + CDbl(dy) * dy > CDbl(distance) * distance Then
            PlayerMsg Index, "Target is outside spell range.", BrightRed
            Exit Sub
        End If
    End If
    ' Pay once, on casting. A missed projectile still consumes mana/cooldown.
    SetPlayerMP Index, GetPlayerMP(Index) - mana
    SendMP Index
    Player(Index).AttackTimer = GetTickCount
    Player(Index).CastedSpell = YES
    If SpellDelivery(number).Mode = 0 Then ApplySpellEffect Index, number, targetType, target
End Sub

Private Function LaunchProjectile(ByVal owner As Long, ByVal number As Long) As Boolean
    Dim i As Long, num As Long
    num = SpellDelivery(number).Arrow
    If num < 1 Or num > MAX_ARROWS Then Exit Function
    For i = 1 To MAX_PROJECTILES
        If Not Shots(i).Active Then
            With Shots(i)
                .Active = True
                .Owner = owner
                .Map = GetPlayerMap(owner)
                .Spell = number
                .Sprite = Arrow(num).Sprite
                .Direction = GetPlayerDir(owner)
                .X = GetPlayerPixelX(owner) + PIC_X \ 2
                .Y = GetPlayerPixelY(owner) + PIC_Y \ 2
                .Remaining = Arrow(num).Range * PIC_X
                .LastStep = GetTickCount
            End With
            SendProjectile i
            LaunchProjectile = True
            Exit Function
        End If
    Next
    PlayerMsg owner, "Too many projectiles are active. Try again shortly.", BrightRed
End Function

Private Sub SendProjectile(ByVal number As Long)
    With Shots(number)
        SendDataToMap .Map, "PROJECTILE" & SEP_CHAR & number & SEP_CHAR & .Map & SEP_CHAR & .Sprite & SEP_CHAR & .Direction & SEP_CHAR & .X & SEP_CHAR & .Y & END_CHAR
    End With
End Sub

Private Sub RemoveProjectile(ByVal number As Long)
    If Not Shots(number).Active Then Exit Sub
    Shots(number).Active = False
    SendDataToMap Shots(number).Map, "PROJECTILEEND" & SEP_CHAR & number & END_CHAR
End Sub

Private Function ProjectileBlocked(ByVal mapNumber As Long, ByVal X As Long, ByVal Y As Long) As Boolean
    Dim tx As Long, ty As Long
    ProjectileBlocked = True
    If X < 0 Or Y < 0 Or X >= (MAX_MAPX + 1) * PIC_X Or Y >= (MAX_MAPY + 1) * PIC_Y Then Exit Function
    tx = X \ PIC_X: ty = Y \ PIC_Y
    With Map(mapNumber).Tile(tx, ty)
        If HasTileType(Map(mapNumber).Tile(tx, ty), TILE_TYPE_BLOCKED) Then Exit Function
        If HasTileType(Map(mapNumber).Tile(tx, ty), TILE_TYPE_KEY) Or HasTileType(Map(mapNumber).Tile(tx, ty), TILE_TYPE_DOOR) Then
            If TempTile(mapNumber).DoorOpen(tx, ty) = NO Then Exit Function
        End If
    End With
    ProjectileBlocked = False
End Function

Private Function ProjectileTarget(ByVal number As Long) As Boolean
    Dim i As Long, tx As Long, ty As Long, owner As Long, spellNumber As Long, mapNumber As Long
    owner = Shots(number).Owner: spellNumber = Shots(number).Spell: mapNumber = Shots(number).Map
    For i = 1 To MAX_PLAYERS
        If i <> owner Then
            If IsPlaying(i) Then
                If GetPlayerMap(i) = mapNumber And GetPlayerHP(i) > 0 Then
                    tx = GetPlayerPixelX(i): ty = GetPlayerPixelY(i)
                    If Shots(number).X >= tx And Shots(number).X < tx + PIC_X And Shots(number).Y >= ty And Shots(number).Y < ty + PIC_Y Then
                        RemoveProjectile number
                        If CanSpellAffect(owner, spellNumber, TARGET_TYPE_PLAYER, i) Then ApplySpellEffect owner, spellNumber, TARGET_TYPE_PLAYER, i
                        ProjectileTarget = True
                        Exit Function
                    End If
                End If
            End If
        End If
    Next
    For i = 1 To MAX_MAP_NPCS
        If MapNpc(mapNumber, i).Num > 0 And MapNpc(mapNumber, i).HP > 0 Then
            tx = MapNpc(mapNumber, i).X * PIC_X: ty = MapNpc(mapNumber, i).y * PIC_Y
            If Shots(number).X >= tx And Shots(number).X < tx + PIC_X And Shots(number).Y >= ty And Shots(number).Y < ty + PIC_Y Then
                RemoveProjectile number
                If CanSpellAffect(owner, spellNumber, TARGET_TYPE_NPC, i) Then ApplySpellEffect owner, spellNumber, TARGET_TYPE_NPC, i
                ProjectileTarget = True
                Exit Function
            End If
        End If
    Next
End Function

Public Sub UpdateProjectiles()
    Dim i As Long, stepNumber As Long, count As Long, tick As Long
    If Not DeliveryReady Or UpdatingShots Then Exit Sub
    UpdatingShots = True
    On Error GoTo Finished
    tick = GetTickCount
    For i = 1 To MAX_PROJECTILES
        If Shots(i).Active Then
            If Not IsPlaying(Shots(i).Owner) Then
                RemoveProjectile i
            ElseIf GetPlayerMap(Shots(i).Owner) <> Shots(i).Map Or GetPlayerHP(Shots(i).Owner) <= 0 Then
                RemoveProjectile i
            Else
                ' Sweep every four pixels; never jump over a tile or target.
                count = (CDbl(tick) - Shots(i).LastStep) \ 20
                If count < 0 Then
                    Shots(i).LastStep = tick
                    count = 0
                End If
                If count > 8 Then count = 8
                For stepNumber = 1 To count
                    With Shots(i)
                        Select Case .Direction
                            Case DIR_UP: .Y = .Y - 4
                            Case DIR_DOWN: .Y = .Y + 4
                            Case DIR_LEFT: .X = .X - 4
                            Case DIR_RIGHT: .X = .X + 4
                        End Select
                        .Remaining = .Remaining - 4
                        .LastStep = .LastStep + 20
                        If ProjectileBlocked(.Map, .X, .Y) Then
                            RemoveProjectile i
                        ElseIf ProjectileTarget(i) Then
                            Exit For
                        ElseIf .Remaining <= 0 Then
                            RemoveProjectile i
                        End If
                    End With
                    If Not Shots(i).Active Then Exit For
                Next
                If Shots(i).Active And count > 0 Then SendProjectile i
            End If
        End If
    Next
Finished:
    UpdatingShots = False
End Sub
