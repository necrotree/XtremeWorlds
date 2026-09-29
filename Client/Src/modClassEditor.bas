Attribute VB_Name = "modClassEditor"
Option Explicit
Public ClassEditorOpen As Boolean
Private ClassEditorRequested As Boolean

Public Sub RequestClassEditor()
    If Not InGame Then Exit Sub
    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then Exit Sub
    If ClassEditorOpen Then
        frmClassEditor.Show
        Exit Sub
    End If
    ClassEditorRequested = True
    SendData "REQUESTEDITCLASS" & END_CHAR
End Sub

Public Function HandleClassEditorPacket(ByRef parts() As String) As Boolean
    Select Case LCase$(parts(0))
        Case "class_edit_data"
            HandleClassEditorPacket = True
            If Not ClassEditorRequested And Not ClassEditorOpen Then Exit Function
            ClassEditorRequested = False
            Load frmClassEditor
            frmClassEditor.LoadClasses parts
            frmClassEditor.Show
        Case "class_edit_saved"
            HandleClassEditorPacket = True
            If ClassEditorOpen Then frmClassEditor.SaveComplete
        Case "class_edit_error"
            HandleClassEditorPacket = True
            ClassEditorRequested = False
            If UBound(parts) < 1 Then Exit Function
            If ClassEditorOpen Then
                frmClassEditor.SaveFailed parts(1)
            Else
                GameMsgBox parts(1), vbExclamation, "Class Editor"
            End If
    End Select
End Function
