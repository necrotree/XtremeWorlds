Attribute VB_Name = "modBookEditor"
Option Explicit
Public Type BookRec
    Signature As Long
    Version As Long
    PageCount As Long
    NextBook As Long
    Quest As Long
    Name As String * 64
    Header As String * 64
    Pages(1 To 64) As String * 2000
End Type

Public BookEditorOpen As Boolean
Public BookPreviewOpen As Boolean
Public LinkedBookId As Long

Public Sub HandleBookEditorPacket(ByRef parts() As String)
    Dim id As Long

    Select Case LCase$(parts(0))
        Case "bookeditorbegin"
            If UBound(parts) <> 1 Then Exit Sub

            MAX_BOOKS = CLng(Val(parts(1)))
            If MAX_BOOKS < 1 Then Exit Sub

            ReDim Book(1 To MAX_BOOKS) As BookRec

            Load frmBookEditor
            frmBookEditor.BeginList

        Case "bookeditorname"
            If UBound(parts) <> 2 Then Exit Sub

            id = CLng(Val(parts(1)))
            If id < 1 Or id > MAX_BOOKS Then Exit Sub

            Book(id).Name = parts(2)
            frmBookEditor.AddBook id, Trim$(Book(id).Name)

        Case "bookeditorquest"
            If UBound(parts) = 2 Then
                frmBookEditor.AddQuest CLng(Val(parts(1))), parts(2)
            End If

        Case "bookeditorready"
            frmBookEditor.OpenEditor

        Case "bookeditordata"
            If UBound(parts) <> 7 Then Exit Sub

            id = CLng(Val(parts(1)))
            If id < 1 Or id > MAX_BOOKS Then Exit Sub

            Book(id).Name = parts(2)
            Book(id).Header = parts(3)
            Book(id).Pages(1) = parts(4)
            Book(id).Pages(2) = parts(5)
            Book(id).NextBook = CLng(Val(parts(6)))
            Book(id).Quest = CLng(Val(parts(7)))

            If Book(id).PageCount < 2 Then Book(id).PageCount = 2

            frmBookEditor.LoadBook id

        Case "bookeditorsaved"
            If UBound(parts) = 1 Then
                frmBookEditor.Saved CLng(Val(parts(1)))
            End If

        Case "bookeditorerror"
            If UBound(parts) = 1 Then
                frmBookEditor.SaveFailed parts(1)
            End If
    End Select
End Sub
