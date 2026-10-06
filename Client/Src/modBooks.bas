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
