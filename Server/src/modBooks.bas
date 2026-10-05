Attribute VB_Name = "modBooks"
Option Explicit

Private Type BinaryBook
    Signature As Long
    Version As Long
    PageCount As Long
    NextBook As Long
    Quest As Long
    Name As String * 64
    Header As String * 64
    Pages(1 To 64) As String * 2000
End Type

Private Function BookPath(ByVal id As Long) As String
    BookPath = App.Path & "\books\" & id & ".bin"
End Function

Public Sub InitializeBooks()
    Dim ids(1 To 32767) As Long, count As Long, fileName As String, id As Long, i As Long, book As BinaryBook
    fileName = Dir$(App.Path & "\books\*.txt")
    Do While Len(fileName) > 0
        id = Val(fileName)
        If id >= 1 And id <= 32767 And fileName = CStr(id) & ".txt" Then
            count = count + 1
            ids(count) = id
        End If
        fileName = Dir$()
    Loop
    For i = 1 To count
        ReadDefinition ids(i), book
    Next i
End Sub

Private Function ReadDefinition(ByVal id As Long, ByRef book As BinaryBook) As Boolean
    Dim f As Long, line As String, p As Long, opened As Boolean, emptyBook As BinaryBook
    On Error GoTo Failed
    If id < 1 Or id > 32767 Then Exit Function
    book = emptyBook
    book.Signature = &H58424B31
    book.Version = 1
    book.PageCount = 2
    If Len(Dir$(BookPath(id))) > 0 Then
        f = FreeFile
        Open BookPath(id) For Binary Access Read As #f
        opened = True
        If LOF(f) <> Len(book) Then Err.Raise 5
        Get #f, , book
        Close #f
        opened = False
        If book.Signature <> &H58424B31 Or book.Version <> 1 Then Err.Raise 5
        If book.PageCount < 1 Or book.PageCount > 64 Then Err.Raise 5
        If book.NextBook < 0 Or book.NextBook > 32767 Or book.Quest < 0 Or book.Quest > MAX_QUESTS Then Err.Raise 5
    ElseIf Len(Dir$(App.Path & "\books\" & id & ".txt")) > 0 Then
        f = FreeFile
        Open App.Path & "\books\" & id & ".txt" For Input As #f
        opened = True
        p = 1
        Do While Not EOF(f)
            Line Input #f, line
            If line = "[PAGE]" Then
                p = p + 1
                If p > 64 Then Err.Raise 5
            Else
                If Len(RTrim$(book.Pages(p))) + Len(line) + 2 > 2000 Then Err.Raise 5
                book.Pages(p) = RTrim$(book.Pages(p)) & line & vbCrLf
            End If
        Loop
        Close #f
        opened = False
        book.PageCount = p
        If Not WriteDefinition(id, book) Then Err.Raise 5
    End If
    ReadDefinition = True
    Exit Function
Failed:
    On Error Resume Next
    If opened Then Close #f
    AddLog "Cannot read binary book " & id, "errors.log"
End Function

Private Function WriteDefinition(ByVal id As Long, ByRef book As BinaryBook) As Boolean
    Dim f As Long, temporary As String, opened As Boolean
    On Error GoTo Failed
    If Len(Dir$(App.Path & "\books", vbDirectory)) = 0 Then MkDir App.Path & "\books"
    temporary = BookPath(id) & ".tmp"
    If Len(Dir$(temporary)) > 0 Then Kill temporary
    f = FreeFile
    Open temporary For Binary As #f
    opened = True
    Put #f, , book
    Close #f
    opened = False
    ' Keep the previous complete definition until the replacement is ready.
    If Len(Dir$(BookPath(id) & ".bak")) > 0 Then Kill BookPath(id) & ".bak"
    If Len(Dir$(BookPath(id))) > 0 Then Name BookPath(id) As BookPath(id) & ".bak"
    Name temporary As BookPath(id)
    WriteDefinition = True
    Exit Function
Failed:
    On Error Resume Next
    If opened Then Close #f
    If Len(Dir$(BookPath(id))) = 0 And Len(Dir$(BookPath(id) & ".bak")) > 0 Then Name BookPath(id) & ".bak" As BookPath(id)
    AddLog "Cannot save binary book " & id, "errors.log"
End Function

Private Function BookNumber(ByVal value As String, ByVal maximum As Long) As Boolean
    Dim i As Long, code As Long
    If Len(value) = 0 Or Len(value) > 5 Then Exit Function
    For i = 1 To Len(value)
        code = Asc(Mid$(value, i, 1))
        If code < 48 Or code > 57 Then Exit Function
    Next i
    BookNumber = Val(value) <= maximum
End Function

Public Function BookHex(ByVal value As String) As String
    Dim i As Long
    For i = 1 To Len(value)
        BookHex = BookHex & Right$("0000" & Hex$(AscW(Mid$(value, i, 1)) And &HFFFF&), 4)
    Next i
End Function

Public Function BookUnhex(ByVal value As String, ByVal maximum As Long) As String
    Dim i As Long, code As Long
    If Len(value) Mod 4 <> 0 Or Len(value) > maximum * 4 Then Err.Raise 5
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
    Dim slot As Long, itemNum As Long, current As Long, depth As Long, book As BinaryBook
    For slot = 1 To MAX_INV
        itemNum = GetPlayerInvItemNum(Index, slot)
        If itemNum >= 1 And itemNum <= MAX_ITEMS Then
            If Item(itemNum).Type = ITEM_TYPE_BOOK Then
                current = Item(itemNum).Data1
                For depth = 1 To 64
                    If current < 1 Then Exit For
                    If current = id Then OwnsBook = True: Exit Function
                    If Not ReadDefinition(current, book) Then Exit For
                    current = book.NextBook
                Next depth
            End If
        End If
    Next slot
End Function

Public Sub SendBinaryBookPages(ByVal Index As Long, ByVal id As Long, ByVal page As Long)
    Dim book As BinaryBook, title As String, rightPage As String
    If Not IsPlaying(Index) Then Exit Sub
    If id < 1 Or id > 32767 Or page < 1 Or page > 64 Then Exit Sub
    If Not OwnsBook(Index, id) Then Exit Sub
    If Len(Dir$(BookPath(id))) = 0 And Len(Dir$(App.Path & "\books\" & id & ".txt")) = 0 Then PlayerMsg Index, "This book has no text yet.", White: Exit Sub
    If Not ReadDefinition(id, book) Then PlayerMsg Index, "This book could not be opened.", White: Exit Sub
    If page > book.PageCount Then Exit Sub
    page = ((page - 1) \ 2) * 2 + 1
    title = Trim$(book.Header)
    If Len(title) = 0 Then title = Trim$(book.Name)
    If Len(title) = 0 Then title = "Book " & id
    If page < book.PageCount Then rightPage = RTrim$(book.Pages(page + 1))
    SendDataTo Index, "BOOKLINK" & SEP_CHAR & id & SEP_CHAR & book.NextBook & END_CHAR
    SendDataTo Index, "BOOKPAGES" & SEP_CHAR & id & SEP_CHAR & page & SEP_CHAR & book.PageCount & SEP_CHAR & Replace(Replace(title, SEP_CHAR, " "), END_CHAR, " ") & SEP_CHAR & Replace(Replace(RTrim$(book.Pages(page)), SEP_CHAR, " "), END_CHAR, " ") & SEP_CHAR & Replace(Replace(rightPage, SEP_CHAR, " "), END_CHAR, " ") & END_CHAR
    If book.Quest > 0 Then BeginBookQuest Index, book.Quest
End Sub

Public Sub HandleBookEditor(ByVal Index As Long, ByRef parts() As String)
    Dim id As Long, q As Long, book As BinaryBook, linked As BinaryBook, current As Long, depth As Long
    Dim fileName As String, packet As String, ids(1 To 32767) As Long, count As Long
    On Error GoTo Failed
    If Not IsPlaying(Index) Then Exit Sub
    If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then Exit Sub
    Select Case LCase$(parts(0))
        Case "bookeditor"
            If UBound(parts) <> 0 Then Exit Sub
            SendDataTo Index, "BOOKEDITORBEGIN" & END_CHAR
            fileName = Dir$(App.Path & "\books\*.bin")
            Do While Len(fileName) > 0
                id = Val(fileName)
                If id >= 1 And id <= 32767 And fileName = CStr(id) & ".bin" Then
                    count = count + 1
                    ids(count) = id
                End If
                fileName = Dir$()
            Loop
            For q = 1 To count
                If ReadDefinition(ids(q), book) Then SendDataTo Index, "BOOKEDITORNAME" & SEP_CHAR & ids(q) & SEP_CHAR & Replace(Replace(Trim$(book.Name), SEP_CHAR, " "), END_CHAR, " ") & END_CHAR
            Next q
            SendBookQuestNames Index
            SendDataTo Index, "BOOKEDITORREADY" & END_CHAR
        Case "editbook"
            If UBound(parts) <> 1 Then Exit Sub
            If Not BookNumber(parts(1), 32767) Then Exit Sub
            id = CLng(parts(1))
            If id < 1 Then Exit Sub
            If Not ReadDefinition(id, book) Then GoTo Failed
            packet = "BOOKEDITORDATA" & SEP_CHAR & id & SEP_CHAR & BookHex(Trim$(book.Name)) & SEP_CHAR & BookHex(Trim$(book.Header)) & SEP_CHAR & BookHex(RTrim$(book.Pages(1))) & SEP_CHAR & BookHex(RTrim$(book.Pages(2))) & SEP_CHAR & book.NextBook & SEP_CHAR & book.Quest
            SendDataTo Index, packet & END_CHAR
        Case "savebook"
            If UBound(parts) <> 7 Then Exit Sub
            If Not BookNumber(parts(1), 32767) Or Not BookNumber(parts(6), 32767) Or Not BookNumber(parts(7), MAX_QUESTS) Then GoTo Failed
            id = CLng(parts(1))
            If id < 1 Then GoTo Failed
            If Not ReadDefinition(id, book) Then GoTo Failed
            book.Name = BookUnhex(parts(2), 64)
            book.Header = BookUnhex(parts(3), 64)
            book.Pages(1) = BookUnhex(parts(4), 2000)
            book.Pages(2) = BookUnhex(parts(5), 2000)
            book.NextBook = CLng(parts(6))
            book.Quest = CLng(parts(7))
            If book.PageCount < 2 Then book.PageCount = 2
            current = book.NextBook
            For depth = 1 To 64
                If current = 0 Then Exit For
                If current = id Then GoTo Failed
                If Not ReadDefinition(current, linked) Then GoTo Failed
                current = linked.NextBook
            Next depth
            If current <> 0 Then GoTo Failed
            If Not WriteDefinition(id, book) Then GoTo Failed
            SendDataTo Index, "BOOKEDITORSAVED" & SEP_CHAR & id & END_CHAR
    End Select
    Exit Sub
Failed:
    SendDataTo Index, "BOOKEDITORERROR" & SEP_CHAR & "Unable to load or save. Check field lengths and connecting book loops." & END_CHAR
End Sub
