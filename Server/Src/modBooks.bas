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

Public Function BookHex(ByVal value As String) As String
    Dim i As Long

    For i = 1 To Len(value)
        BookHex = BookHex & Right$("0000" & Hex$(AscW(Mid$(value, i, 1)) And &HFFFF&), 4)
    Next i
End Function

Public Function BookUnhex(ByVal value As String, ByVal maximum As Long) As String
    Dim i As Long
    Dim code As Long

    If Len(value) Mod 4 <> 0 Then Err.Raise 5
    If Len(value) > maximum * 4 Then Err.Raise 5

    For i = 1 To Len(value)
        If InStr(1, "0123456789ABCDEF", Mid$(value, i, 1), vbTextCompare) = 0 Then Err.Raise 5
    Next i

    For i = 1 To Len(value) Step 4
        code = CLng("&H" & Mid$(value, i, 4))
        If code > 32767 Then code = code - 65536
        If code = 0 Then Err.Raise 5
        BookUnhex = BookUnhex & ChrW$(code)
    Next i
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
                    current = Book(current).NextBook
                Next depth
            End If
        End If
    Next slot
End Function

Public Sub SendBookPages(ByVal Index As Long, ByVal id As Long, ByVal page As Long)
    Dim title As String
    Dim rightPage As String

    If Not IsPlaying(Index) Then Exit Sub
    If id < 1 Or id > MAX_BOOKS Then Exit Sub
    If page < 1 Or page > 64 Then Exit Sub
    If Not OwnsBook(Index, id) Then Exit Sub

    If Book(id).PageCount < 1 Then
        PlayerMsg Index, "This book has no text yet.", White
        Exit Sub
    End If

    If page > Book(id).PageCount Then Exit Sub
    page = ((page - 1) \ 2) * 2 + 1
    If page > Book(id).PageCount Then Exit Sub

    If LenB(RTrim$(Book(id).Pages(page))) = 0 Then
        PlayerMsg Index, "This book has no text yet.", White
        Exit Sub
    End If

    title = Trim$(Book(id).Header)
    If LenB(title) = 0 Then title = Trim$(Book(id).Name)
    If LenB(title) = 0 Then title = "Book " & id

    rightPage = vbNullString
    If page < Book(id).PageCount Then rightPage = RTrim$(Book(id).Pages(page + 1))

    SendDataTo Index, "BOOKLINK" & SEP_CHAR & id & SEP_CHAR & Book(id).NextBook & END_CHAR
    SendDataTo Index, "BOOKPAGES" & SEP_CHAR & id & SEP_CHAR & page & SEP_CHAR & Book(id).PageCount & SEP_CHAR & CleanBookPacketText(title) & SEP_CHAR & CleanBookPacketText(RTrim$(Book(id).Pages(page))) & SEP_CHAR & CleanBookPacketText(rightPage) & END_CHAR

    If Book(id).Quest > 0 And Book(id).Quest <= MAX_QUESTS Then BeginBookQuest Index, Book(id).Quest
End Sub

Private Function CleanBookPacketText(ByVal value As String) As String
    value = Replace(value, SEP_CHAR, " ")
    value = Replace(value, END_CHAR, " ")
    CleanBookPacketText = value
End Function

Public Sub HandleBookEditor(ByVal Index As Long, ByRef parts() As String)
    Dim id As Long
    Dim current As Long
    Dim depth As Long
    Dim packet As String

    On Error GoTo Failed

    If Not IsPlaying(Index) Then Exit Sub
    If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then Exit Sub

    Select Case LCase$(parts(0))
        Case "requesteditbook"
            If UBound(parts) <> 0 Then Exit Sub
            If MAX_BOOKS < 1 Then GoTo Failed

            SendDataTo Index, "BOOKEDITORBEGIN" & SEP_CHAR & MAX_BOOKS & END_CHAR

            ' Send the editor list as one packet. Sending hundreds of tiny
            ' socket writes back-to-back can re-enter the IOCP socket layer
            ' and terminate the server without reaching the VB error handler.
            packet = vbNullString

            For id = 1 To MAX_BOOKS
                packet = packet & _
                    "BOOKEDITORNAME" & SEP_CHAR & _
                    id & SEP_CHAR & _
                    CleanBookPacketText(Trim$(Book(id).Name)) & _
                    END_CHAR

                If Len(packet) >= 8192 Then
                    SendDataTo Index, packet
                    packet = vbNullString
                End If
            Next id

            If LenB(packet) <> 0 Then
                SendDataTo Index, packet
            End If

            SendBookQuestNames Index
            SendDataTo Index, "BOOKEDITORREADY" & END_CHAR

        Case "editbook"
            If UBound(parts) <> 1 Then Exit Sub
            If Not BookNumber(parts(1), MAX_BOOKS) Then Exit Sub

            id = CLng(parts(1))
            If id < 1 Or id > MAX_BOOKS Then Exit Sub

            packet = "BOOKEDITORDATA" & SEP_CHAR & id & SEP_CHAR & BookHex(Trim$(Book(id).Name)) & SEP_CHAR & BookHex(Trim$(Book(id).Header)) & SEP_CHAR & BookHex(RTrim$(Book(id).Pages(1))) & SEP_CHAR & BookHex(RTrim$(Book(id).Pages(2))) & SEP_CHAR & Book(id).NextBook & SEP_CHAR & Book(id).Quest
            SendDataTo Index, packet & END_CHAR

        Case "savebook"
            If UBound(parts) <> 7 Then Exit Sub
            If Not BookNumber(parts(1), MAX_BOOKS) Then GoTo Failed
            If Not BookNumber(parts(6), MAX_BOOKS) Then GoTo Failed
            If Not BookNumber(parts(7), MAX_QUESTS) Then GoTo Failed

            id = CLng(parts(1))
            If id < 1 Or id > MAX_BOOKS Then GoTo Failed

            Book(id).Name = BookUnhex(parts(2), 64)
            Book(id).Header = BookUnhex(parts(3), 64)
            Book(id).Pages(1) = BookUnhex(parts(4), 2000)
            Book(id).Pages(2) = BookUnhex(parts(5), 2000)
            Book(id).NextBook = CLng(parts(6))
            Book(id).Quest = CLng(parts(7))
            If Book(id).PageCount < 2 Then Book(id).PageCount = 2

            If Book(id).NextBook = id Then GoTo Failed

            current = Book(id).NextBook
            For depth = 1 To 64
                If current = 0 Then Exit For
                If current < 1 Or current > MAX_BOOKS Then GoTo Failed
                If current = id Then GoTo Failed
                current = Book(current).NextBook
            Next depth
            If current <> 0 Then GoTo Failed

            SaveBook id
            SendDataTo Index, "BOOKEDITORSAVED" & SEP_CHAR & id & END_CHAR
    End Select
    Exit Sub

Failed:
    SendDataTo Index, "BOOKEDITORERROR" & SEP_CHAR & "Unable to load or save. Check field lengths and connecting book loops." & END_CHAR
End Sub
