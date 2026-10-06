Attribute VB_Name = "modBookEditor"
Option Explicit
Public BookEditorOpen As Boolean
Public BookPreviewOpen As Boolean
Public LinkedBookId As Long

Public Sub HandleBookEditorPacket(ByRef parts() As String)
    Dim maximum As Long
    Select Case LCase$(parts(0))
        Case "bookeditorbegin"
            If UBound(parts) <> 1 Then Exit Sub
            If Not OverlayInteger(parts(1), 32767, maximum) Then Exit Sub
            If maximum < 1 Then Exit Sub
            Load frmBookEditor
            frmBookEditor.BeginList maximum
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
