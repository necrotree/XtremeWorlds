Attribute VB_Name = "modBookEditor"
Option Explicit
Public BookEditorOpen As Boolean
Public BookPreviewOpen As Boolean
Public LinkedBookId As Long

Public Function EncodeBookText(ByVal value As String) As String
    Dim i As Long
    For i = 1 To Len(value)
        EncodeBookText = EncodeBookText & Right$("0000" & Hex$(AscW(Mid$(value, i, 1)) And &HFFFF&), 4)
    Next i
End Function

Public Function DecodeBookText(ByVal value As String) As String
    Dim i As Long, code As Long
    If Len(value) Mod 4 <> 0 Then Exit Function
    For i = 1 To Len(value) Step 4
        code = CLng("&H" & Mid$(value, i, 4))
        If code > 32767 Then code = code - 65536
        DecodeBookText = DecodeBookText & ChrW$(code)
    Next i
End Function

Public Sub HandleBookEditorPacket(ByRef parts() As String)
    Select Case LCase$(parts(0))
        Case "bookeditorbegin"
            Load frmBookEditor
            frmBookEditor.BeginList
        Case "bookeditorname"
            If UBound(parts) = 2 Then frmBookEditor.AddBook CLng(Val(parts(1))), parts(2)
        Case "bookeditorquest"
            If UBound(parts) = 2 Then frmBookEditor.AddQuest CLng(Val(parts(1))), parts(2)
        Case "bookeditorready"
            frmBookEditor.OpenEditor
        Case "bookeditordata"
            If UBound(parts) = 7 Then frmBookEditor.LoadDefinition parts
        Case "bookeditorsaved"
            If UBound(parts) = 1 Then frmBookEditor.Saved CLng(Val(parts(1)))
        Case "bookeditorerror"
            If UBound(parts) = 1 Then frmBookEditor.SaveFailed parts(1)
    End Select
End Sub
