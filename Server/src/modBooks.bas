Attribute VB_Name = "modBooks"
Option Explicit

Private Function BookNumber(ByVal value As String, ByVal maximum As Long) As Boolean
    Dim i As Long
    Dim code As Long

    If Len(value) = 0 Or Len(value) > 5 Then Exit Function

    For i = 1 To Len(value)
        code = Asc(Mid$(value, i, 1))
        If code < 48 Or code > 57 Then Exit Function
    Next i

    BookNumber = (Val(value) <= maximum)
End Function

Private Function OwnsBook(ByVal Index As Long, ByVal id As Long) As Boolean
    Dim slot As Long
    Dim itemNum As Long
    Dim current As Long
    Dim depth As Long

    If id < 1 Or id > MAX_BOOKS Then Exit Function

    For slot = 1 To MAX_INV
        itemNum = GetPlayerInvItemNum(Index, slot)

        If itemNum >= 1 And itemNum <= MAX_ITEMS Then
            If Item(itemNum).Type = ITEM_TYPE_BOOK Then
                current = Item(itemNum).Data1

                For depth = 1 To 64
                    If current < 1 Or current > MAX_BOOKS Then Exit For

                    If current = id Then
                        OwnsBook = True
                        Exit Function
                    End If

                    current = NextBookId(Book(current))
                Next depth
            End If
        End If
    Next slot
End Function

Private Function NextBookId(ByRef value As BookRec) As Long
    NextBookId = value.NextBook
End Function

Public Sub SendBookPages(ByVal Index As Long, ByVal id As Long, ByVal page As Long)
    If Not IsPlaying(Index) Then Exit Sub
    If id < 1 Or id > MAX_BOOKS Then Exit Sub
    If page < 1 Or page > 64 Then Exit Sub
    If Not OwnsBook(Index, id) Then Exit Sub
    SendBookRecordPages Index, id, page, Book(id)
End Sub

Private Sub SendBookRecordPages(ByVal Index As Long, ByVal id As Long, ByVal page As Long, ByRef value As BookRec)
    Dim title As String
    Dim rightPage As String

    If Not IsPlaying(Index) Then Exit Sub

    If id < 1 Or id > MAX_BOOKS Then Exit Sub
    If page < 1 Or page > 64 Then Exit Sub

    If Not OwnsBook(Index, id) Then Exit Sub

    If value.PageCount < 1 Then
        PlayerMsg Index, "This book has no text yet.", White
        Exit Sub
    End If

    If page > value.PageCount Then Exit Sub

    ' Always start on the left page of a two-page spread.
    page = ((page - 1) \ 2) * 2 + 1

    If page > value.PageCount Then Exit Sub

    If LenB(RTrim$(value.Pages(page))) = 0 Then
        PlayerMsg Index, "This book has no text yet.", White
        Exit Sub
    End If

    title = Trim$(value.Header)

    If LenB(title) = 0 Then
        title = Trim$(value.Name)
    End If

    If LenB(title) = 0 Then
        title = "Book " & id
    End If

    rightPage = vbNullString

    If page < value.PageCount Then
        rightPage = RTrim$(value.Pages(page + 1))
    End If

    SendDataTo Index, _
        "BOOKLINK" & SEP_CHAR & _
        id & SEP_CHAR & _
        value.NextBook & _
        END_CHAR

    SendDataTo Index, _
        "BOOKPAGES" & SEP_CHAR & _
        id & SEP_CHAR & _
        page & SEP_CHAR & _
        value.PageCount & SEP_CHAR & _
        CleanBookPacketText(title) & SEP_CHAR & _
        CleanBookPacketText(RTrim$(value.Pages(page))) & SEP_CHAR & _
        CleanBookPacketText(rightPage) & _
        END_CHAR

    If value.Quest > 0 And value.Quest <= MAX_QUESTS Then
        BeginBookQuest Index, value.Quest
    End If
End Sub

Private Function CleanBookPacketText(ByVal value As String) As String
    value = Replace(value, SEP_CHAR, " ")
    value = Replace(value, END_CHAR, " ")

    CleanBookPacketText = value
End Function

Public Sub HandleBookEditor(ByVal Index As Long, ByRef parts() As String)
    Dim id As Long

    On Error GoTo Failed

    If Not IsPlaying(Index) Then Exit Sub
    If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then Exit Sub

    Select Case LCase$(parts(0))

        Case "bookeditor"

            If UBound(parts) <> 0 Then Exit Sub

            SendDataTo Index, "BOOKEDITORBEGIN" & SEP_CHAR & MAX_BOOKS & END_CHAR

            ' Books work like the other editors:
            ' every slot from 1 to MAX_BOOKS is always available.
            For id = 1 To MAX_BOOKS
                SendBookEditorName Index, id, Book(id)
            Next id

            SendBookQuestNames Index

            SendDataTo Index, "BOOKEDITORREADY" & END_CHAR

        Case "editbook"

            If UBound(parts) <> 1 Then Exit Sub

            If Not BookNumber(parts(1), MAX_BOOKS) Then Exit Sub

            id = CLng(parts(1))

            If id < 1 Or id > MAX_BOOKS Then Exit Sub

            SendBookEditorRecord Index, id, Book(id)

        Case "savebook"

            If UBound(parts) <> 7 Then Exit Sub

            If Not BookNumber(parts(1), MAX_BOOKS) Then GoTo Failed
            If Not BookNumber(parts(6), MAX_BOOKS) Then GoTo Failed
            If Not BookNumber(parts(7), MAX_QUESTS) Then GoTo Failed

            id = CLng(parts(1))

            If id < 1 Or id > MAX_BOOKS Then GoTo Failed

            If Not ApplyBookEditorRecord(Book(id), id, parts) Then GoTo Failed

            SaveBook id

            SendDataTo Index, _
                "BOOKEDITORSAVED" & SEP_CHAR & id & END_CHAR

    End Select

    Exit Sub

Failed:
    SendDataTo Index, _
        "BOOKEDITORERROR" & SEP_CHAR & _
        "Unable to load or save. Check field lengths and connecting book loops." & _
        END_CHAR
End Sub
' BookRec contains 64 fixed-width pages. Keep it ByRef throughout the editor
' so packet construction does not create full-record stack temporaries.
Private Sub SendBookEditorName(ByVal Index As Long, ByVal id As Long, ByRef value As BookRec)
    SendDataTo Index, "BOOKEDITORNAME" & SEP_CHAR & id & SEP_CHAR & CleanBookPacketText(Trim$(value.Name)) & END_CHAR
End Sub

Private Sub SendBookEditorRecord(ByVal Index As Long, ByVal id As Long, ByRef value As BookRec)
    Dim packet As String
    packet = "BOOKEDITORDATA" & SEP_CHAR & id & SEP_CHAR & _
        CleanBookPacketText(Trim$(value.Name)) & SEP_CHAR & _
        CleanBookPacketText(Trim$(value.Header)) & SEP_CHAR & _
        CleanBookPacketText(RTrim$(value.Pages(1))) & SEP_CHAR & _
        CleanBookPacketText(RTrim$(value.Pages(2))) & SEP_CHAR & _
        value.NextBook & SEP_CHAR & value.Quest
    SendDataTo Index, packet & END_CHAR
End Sub

Private Function ApplyBookEditorRecord(ByRef value As BookRec, ByVal id As Long, ByRef parts() As String) As Boolean
    Dim current As Long, depth As Long
    current = CLng(parts(6))
    For depth = 1 To 64
        If current = 0 Then Exit For
        If current < 1 Or current > MAX_BOOKS Then Exit Function
        If current = id Then Exit Function
        current = NextBookId(Book(current))
    Next depth
    If current <> 0 Then Exit Function
    value.Name = parts(2)
    value.Header = parts(3)
    value.Pages(1) = parts(4)
    value.Pages(2) = parts(5)
    value.NextBook = CLng(parts(6))
    value.Quest = CLng(parts(7))
    If value.PageCount < 2 Then value.PageCount = 2
    ApplyBookEditorRecord = True
End Function
