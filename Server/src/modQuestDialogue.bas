Attribute VB_Name = "modQuestDialogue"
Option Explicit

Public Sub SendBookQuestNames(ByVal Index As Long)
    Dim q As Long
    EnsureDefinitions
    For q = 1 To MAX_QUESTS
        SendDataTo Index, "BOOKEDITORQUEST" & SEP_CHAR & q & SEP_CHAR & Definitions(q).Field(1) & END_CHAR
    Next q
End Sub

Public Sub BeginBookQuest(ByVal Index As Long, ByVal q As Long)
    If q < 1 Or q > MAX_QUESTS Then Exit Sub
    EnsureDefinitions
    If Len(Definitions(q).Field(1)) = 0 Then Exit Sub
    If Not Eligible(Index, q) Then Exit Sub
    If Progress(Index, q) <> 0 Then Exit Sub
    SetProgress Index, q, 1
    RefreshDialogueQuestMarkers Index
    PlayerMsg Index, "Quest started: " & Definitions(q).Field(1), White
End Sub

' Dialogue definitions use a sidecar so legacy .qst records remain compatible.
Private Type DialogueQuest
    Field(1 To 19) As String
End Type
Private Definitions() As DialogueQuest
Private LoadedCount As Long

Private Function DefinitionFile() As String
    DefinitionFile = App.Path & "\data\QuestDialogue.ini"
End Function

Private Function HexText(ByVal value As String) As String
    Dim i As Long
    For i = 1 To Len(value)
        HexText = HexText & Right$("0000" & Hex$(AscW(Mid$(value, i, 1)) And &HFFFF&), 4)
    Next i
End Function

Private Function PlainText(ByVal value As String) As String
    Dim i As Long, code As Long
    If Len(value) Mod 4 <> 0 Then Exit Function
    On Error GoTo InvalidText
    For i = 1 To Len(value) Step 4
        code = CLng("&H" & Mid$(value, i, 4))
        If code > 32767 Then code = code - 65536
        PlainText = PlainText & ChrW$(code)
    Next i
    Exit Function
InvalidText:
    PlainText = vbNullString
End Function

Private Sub EnsureDefinitions()
    Dim q As Long, f As Long
    If LoadedCount = MAX_QUESTS Then Exit Sub
    ReDim Definitions(1 To MAX_QUESTS)
    For q = 1 To MAX_QUESTS
        For f = 1 To 19
            Definitions(q).Field(f) = PlainText(GetVar(DefinitionFile, "Quest" & q, "Field" & f))
        Next f
    Next q
    LoadedCount = MAX_QUESTS
End Sub

Private Function Number(ByVal q As Long, ByVal f As Long) As Long
    Number = CLng(Val(Definitions(q).Field(f)))
End Function

Private Function ProgressSection(ByVal Index As Long) As String
    ProgressSection = HexText(LCase$(GetPlayerLogin(Index))) & "_" & HexText(LCase$(GetPlayerName(Index)))
End Function

Private Function Progress(ByVal Index As Long, ByVal q As Long) As Long
    Progress = Val(GetVar(App.Path & "\data\QuestProgress.ini", ProgressSection(Index), "Quest" & q))
End Function

Private Sub SetProgress(ByVal Index As Long, ByVal q As Long, ByVal state As Long)
    PutVar App.Path & "\data\QuestProgress.ini", ProgressSection(Index), "Quest" & q, CStr(state)
End Sub

Private Function Eligible(ByVal Index As Long, ByVal q As Long) As Boolean
    Dim previous As Long, hasPrevious As Boolean, unlocked As Boolean
    If Number(q, 8) > 0 Then
        If GetPlayerClass(Index) <> Number(q, 8) Then Exit Function
    End If
    If GetPlayerLevel(Index) < Number(q, 9) Then Exit Function
    For previous = 1 To MAX_QUESTS
        If Number(previous, 10) = q And Len(Definitions(previous).Field(1)) > 0 Then
            hasPrevious = True
            If Progress(Index, previous) = 2 Then unlocked = True
        End If
    Next previous
    Eligible = Not hasPrevious Or unlocked
End Function

Private Function Nearby(ByVal Index As Long, ByVal slot As Long, ByVal npcNumber As Long) As Boolean
    Dim mapNumber As Long
    If slot < 1 Or slot > MAX_MAP_NPCS Then Exit Function
    mapNumber = GetPlayerMap(Index)
    If mapNumber < 1 Or mapNumber > MAX_MAPS_SET Then Exit Function
    If MapNpc(mapNumber, slot).Num <> npcNumber Or MapNpc(mapNumber, slot).HP <= 0 Then Exit Function
    Nearby = Abs(CLng(MapNpc(mapNumber, slot).X) - GetPlayerX(Index)) <= 1 And Abs(CLng(MapNpc(mapNumber, slot).y) - GetPlayerY(Index)) <= 1
End Function

Private Function ItemCount(ByVal Index As Long, ByVal itemNumber As Long) As Long
    Dim slot As Long
    If itemNumber = 0 Then Exit Function
    For slot = 1 To MAX_INV
        If GetPlayerInvItemNum(Index, slot) = itemNumber Then
            If Item(itemNumber).Type = ITEM_TYPE_CURRENCY Then
                ItemCount = ItemCount + GetPlayerInvItemValue(Index, slot)
            Else
                ItemCount = ItemCount + 1
            End If
        End If
    Next slot
End Function

Private Function HasRequiredItem(ByVal Index As Long, ByVal q As Long) As Boolean
    HasRequiredItem = Number(q, 15) = 0
    If Not HasRequiredItem Then HasRequiredItem = ItemCount(Index, Number(q, 15)) >= Number(q, 16)
End Function

Private Sub ShowDialogue(ByVal Index As Long, ByVal q As Long, ByVal slot As Long, ByVal field As Long, ByVal action As Long, Optional ByVal message As String = "")
    If Len(message) = 0 Then message = Definitions(q).Field(field)
    If Len(message) = 0 Then message = "There is nothing more to say right now."
    SendDataTo Index, "QUESTDIALOGUE" & SEP_CHAR & q & SEP_CHAR & slot & SEP_CHAR & Definitions(q).Field(1) & SEP_CHAR & Trim$(Npc(Number(q, 2)).Name) & SEP_CHAR & message & SEP_CHAR & action & END_CHAR
End Sub

Public Sub RefreshDialogueQuestMarkers(ByVal Index As Long)
    Dim slot As Long, q As Long, status As Long, npcNumber As Long, state As Long
    If Not IsPlaying(Index) Then Exit Sub
    If GetPlayerMap(Index) < 1 Or GetPlayerMap(Index) > MAX_MAPS_SET Then Exit Sub
    EnsureDefinitions
    For slot = 1 To MAX_MAP_NPCS
        npcNumber = MapNpc(GetPlayerMap(Index), slot).Num
        status = 0
        For q = 1 To MAX_QUESTS
            If Len(Definitions(q).Field(1)) > 0 And Number(q, 2) = npcNumber And npcNumber > 0 Then
                state = Progress(Index, q)
                If Eligible(Index, q) Then
                    If state = 1 Then
                        status = 2
                        If HasRequiredItem(Index, q) Then status = 3
                        Exit For
                    ElseIf state <> 2 Or Number(q, 14) = 0 Then
                        status = 1
                    End If
                End If
            End If
        Next q
        If npcNumber > 0 Then
            ' Leave script-owned markers alone when no dialogue quest uses this NPC.
            For q = 1 To MAX_QUESTS
                If Number(q, 2) = npcNumber And Len(Definitions(q).Field(1)) > 0 Then
                    SetQuestNpcMarker Index, slot, status
                    Exit For
                End If
            Next q
        End If
    Next slot
End Sub

Public Sub HandleQuestTalk(ByVal Index As Long, ByRef parts() As String)
    Dim slot As Long, q As Long, selected As Long, npcNumber As Long, state As Long
    If Not IsPlaying(Index) Or UBound(parts) <> 1 Then Exit Sub
    If GetPlayerMap(Index) < 1 Or GetPlayerMap(Index) > MAX_MAPS_SET Then Exit Sub
    If Not ValidInteger(parts(1), 1, MAX_MAP_NPCS) Then Exit Sub
    slot = CLng(parts(1))
    npcNumber = MapNpc(GetPlayerMap(Index), slot).Num
    If npcNumber < 1 Then Exit Sub
    If Not Nearby(Index, slot, npcNumber) Then Exit Sub
    EnsureDefinitions
    For q = 1 To MAX_QUESTS
        If Number(q, 2) = npcNumber And Len(Definitions(q).Field(1)) > 0 Then
            If selected = 0 Then selected = q
            If Eligible(Index, q) Then
                state = Progress(Index, q)
                If state = 1 Then
                    selected = q
                    Exit For
                End If
                If state <> 2 Or Number(q, 14) = 0 Then selected = q: Exit For
            End If
        End If
    Next q
    If selected = 0 Then Exit Sub
    q = selected
    If Not Eligible(Index, q) Then
        ShowDialogue Index, q, slot, 6, 0
    ElseIf Progress(Index, q) = 2 And Number(q, 14) = 1 Then
        ShowDialogue Index, q, slot, 7, 0
    ElseIf Progress(Index, q) = 1 Then
        If HasRequiredItem(Index, q) Then
            ShowDialogue Index, q, slot, 3, 2
        Else
            ShowDialogue Index, q, slot, 5, 0
        End If
    Else
        ShowDialogue Index, q, slot, 3, 1
    End If
End Sub

Public Sub HandleQuestAction(ByVal Index As Long, ByRef parts() As String)
    Dim q As Long, slot As Long, action As Long, i As Long, available As Long, needed As Long
    Dim required As Long, reward As Long, amount As Long, remaining As Long, takeAmount As Long
    If Not IsPlaying(Index) Or UBound(parts) <> 3 Then Exit Sub
    If Not ValidInteger(parts(1), 1, MAX_QUESTS) Or Not ValidInteger(parts(2), 1, MAX_MAP_NPCS) Or Not ValidInteger(parts(3), 1, 2) Then Exit Sub
    q = CLng(parts(1)): slot = CLng(parts(2)): action = CLng(parts(3))
    EnsureDefinitions
    If Len(Definitions(q).Field(1)) = 0 Then Exit Sub
    If Not Nearby(Index, slot, Number(q, 2)) Then Exit Sub
    If Not Eligible(Index, q) Then ShowDialogue Index, q, slot, 6, 0: Exit Sub
    If Progress(Index, q) = 2 And Number(q, 14) = 1 Then ShowDialogue Index, q, slot, 7, 0: Exit Sub
    If action = 1 Then
        If Progress(Index, q) = 1 Then Exit Sub
        SetProgress Index, q, 1
        ShowDialogue Index, q, slot, 3, 0, "Quest accepted. " & Definitions(q).Field(3)
    Else
        If Progress(Index, q) <> 1 Then Exit Sub
        If Not HasRequiredItem(Index, q) Then ShowDialogue Index, q, slot, 5, 0: Exit Sub
        required = Number(q, 15): reward = Number(q, 17): amount = Number(q, 18)
        If reward > 0 Then
            If Item(reward).Type = ITEM_TYPE_CURRENCY Then
                If CDbl(ItemCount(Index, reward)) + amount > 2147483647# Then Exit Sub
            End If
            For i = 1 To MAX_INV
                If GetPlayerInvItemNum(Index, i) = 0 Then available = available + 1
            Next i
            needed = amount
            If Item(reward).Type = ITEM_TYPE_CURRENCY Then
                needed = 1
                If FindOpenInvSlot(Index, reward) > 0 Then needed = 0
            End If
            If required > 0 Then
                If Item(required).Type <> ITEM_TYPE_CURRENCY Then available = available + Number(q, 16)
            End If
            If available < needed Then ShowDialogue Index, q, slot, 6, 0, "Make room in your inventory for the quest reward.": Exit Sub
        End If
        If CDbl(GetPlayerExp(Index)) + Number(q, 19) > 2147483647# Then Exit Sub
        ' Mark completion before sending inventory updates, which may dispatch UI events.
        SetProgress Index, q, 2
        If required > 0 Then
            If Item(required).Type = ITEM_TYPE_CURRENCY Then
                remaining = Number(q, 16)
                Do While remaining > 0
                    takeAmount = HasItem(Index, required)
                    If takeAmount > remaining Then takeAmount = remaining
                    If takeAmount <= 0 Then Exit Do
                    TakeItem Index, required, takeAmount
                    remaining = remaining - takeAmount
                Loop
            Else
                For i = 1 To Number(q, 16)
                    TakeItem Index, required, 0
                Next i
            End If
        End If
        If reward > 0 Then
            If Item(reward).Type = ITEM_TYPE_CURRENCY Then
                GiveItem Index, reward, amount
            Else
                For i = 1 To amount
                    GiveItem Index, reward, 1
                Next i
            End If
        End If
        SetPlayerExp Index, GetPlayerExp(Index) + Number(q, 19)
        CheckPlayerLevelUp Index
        If Number(q, 11) = 1 Then SetPlayerHP Index, GetPlayerMaxHP(Index)
        If Number(q, 12) = 1 Then SetPlayerMP Index, GetPlayerMaxMP(Index)
        If Number(q, 13) = 1 Then SetPlayerSP Index, GetPlayerMaxSP(Index)
        SendHP Index: SendMP Index: SendSP Index: SendExp Index
        SavePlayer Index
        ShowDialogue Index, q, slot, 4, 0
    End If
    RefreshDialogueQuestMarkers Index
End Sub

Private Function ValidInteger(ByVal value As String, ByVal minimum As Long, ByVal maximum As Long) As Boolean
    Dim number As Double, i As Long, code As Long
    If Len(value) = 0 Or Len(value) > 10 Then Exit Function
    For i = 1 To Len(value)
        code = Asc(Mid$(value, i, 1))
        If code < 48 Or code > 57 Then Exit Function
    Next i
    number = Val(value)
    ValidInteger = number = Fix(number) And number >= minimum And number <= maximum
End Function

Public Sub HandleQuestEditor(ByVal Index As Long, ByRef parts() As String)
    Dim q As Long, f As Long, command As String, candidate As DialogueQuest, packet As String
    If Not IsPlaying(Index) Then Exit Sub
    If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then Exit Sub
    EnsureDefinitions
    command = LCase$(parts(0))
    If command = "questeditor" Then
        If UBound(parts) <> 0 Then Exit Sub
        SendDataTo Index, "QUESTEDITORBEGIN" & SEP_CHAR & MAX_QUESTS & END_CHAR
        For q = 1 To MAX_QUESTS
            SendDataTo Index, "QUESTEDITORNAME" & SEP_CHAR & q & SEP_CHAR & Definitions(q).Field(1) & END_CHAR
        Next q
        packet = "QUESTEDITORCLASSES" & SEP_CHAR & MAX_CLASS
        For f = 1 To MAX_CLASS
            packet = packet & SEP_CHAR & Trim$(Class(f).Name)
        Next f
        SendDataTo Index, packet & END_CHAR
        SendDataTo Index, "QUESTEDITORREADY" & END_CHAR
        Exit Sub
    End If
    If UBound(parts) < 1 Then Exit Sub
    If Not ValidInteger(parts(1), 1, MAX_QUESTS) Then Exit Sub
    q = CLng(parts(1))
    If command = "savequestdialogue" Then
        If UBound(parts) <> 20 Then Exit Sub
        For f = 1 To 19
            candidate.Field(f) = Trim$(parts(f + 1))
            If Len(candidate.Field(f)) > 240 Then Exit Sub
            If InStr(candidate.Field(f), vbCr) > 0 Or InStr(candidate.Field(f), vbLf) > 0 Then Exit Sub
        Next f
        If Not ValidInteger(candidate.Field(2), 1, MAX_NPCS) Then GoTo InvalidDefinition
        If Not ValidInteger(candidate.Field(8), 0, MAX_CLASS) Then GoTo InvalidDefinition
        If Not ValidInteger(candidate.Field(9), 0, 32767) Then GoTo InvalidDefinition
        If Not ValidInteger(candidate.Field(10), 0, MAX_QUESTS) Then GoTo InvalidDefinition
        If CLng(candidate.Field(10)) = q Then GoTo InvalidDefinition
        For f = 11 To 14
            If Not ValidInteger(candidate.Field(f), 0, 1) Then GoTo InvalidDefinition
        Next f
        If Not ValidInteger(candidate.Field(15), 0, MAX_ITEMS) Or Not ValidInteger(candidate.Field(17), 0, MAX_ITEMS) Then GoTo InvalidDefinition
        If Not ValidInteger(candidate.Field(16), 1, MAX_INV) Or Not ValidInteger(candidate.Field(18), 1, MAX_INV) Then GoTo InvalidDefinition
        If Not ValidInteger(candidate.Field(19), 0, 1000000000) Then GoTo InvalidDefinition
        ' Reject chains that loop back to this quest.
        Dim nextQuest As Long, steps As Long
        nextQuest = CLng(candidate.Field(10))
        Do While nextQuest > 0
            If nextQuest = q Or steps >= MAX_QUESTS Then GoTo InvalidDefinition
            nextQuest = Number(nextQuest, 10)
            steps = steps + 1
        Loop
        For f = 1 To 19
            PutVar DefinitionFile, "Quest" & q, "Field" & f, HexText(candidate.Field(f))
            Definitions(q).Field(f) = candidate.Field(f)
        Next f
        SendDataTo Index, "QUESTEDITORSAVED" & SEP_CHAR & q & END_CHAR
        AddLog GetPlayerName(Index) & " saved dialogue quest #" & q & ".", ADMIN_LOG
        Dim playerIndex As Long
        For playerIndex = 1 To HighIndex
            If IsPlaying(playerIndex) Then RefreshDialogueQuestMarkers playerIndex
        Next playerIndex
        Exit Sub
    End If
    If command <> "editquestdialogue" Or UBound(parts) <> 1 Then Exit Sub
    packet = "QUESTEDITORDATA" & SEP_CHAR & q
    For f = 1 To 19
        packet = packet & SEP_CHAR & Definitions(q).Field(f)
    Next f
    SendDataTo Index, packet & END_CHAR
    Exit Sub
InvalidDefinition:
    SendDataTo Index, "QUESTEDITORERROR" & SEP_CHAR & "Check NPC, requirements, quantities, and quest chaining. Quantities must be 1-" & MAX_INV & "." & END_CHAR
End Sub
