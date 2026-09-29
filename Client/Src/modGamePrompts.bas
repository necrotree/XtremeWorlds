Attribute VB_Name = "modGamePrompts"
Option Explicit

Private Sub RestoreLoginButtons()
    Dim openForm As Form
    For Each openForm In VB.Forms
        If StrComp(openForm.Name, "frmMainMenu", vbTextCompare) = 0 Then
            frmMainMenu.ShowMenuHome
            Exit Sub
        End If
    Next
End Sub

Public Function GameMsgBox(ByVal Prompt As String, Optional ByVal Buttons As VbMsgBoxStyle = vbOKOnly, Optional ByVal Title As String = "") As VbMsgBoxResult
    Dim Dialog As New frmGamePrompt
    If Len(Title) = 0 Then Title = GAME_NAME
    If (CLng(Buttons) And 15) <> vbOKOnly And (CLng(Buttons) And 15) <> vbYesNo Then
        GameMsgBox = MsgBox(Prompt, Buttons, Title)
        RestoreLoginButtons
        Exit Function
    End If
    Load Dialog
    Dialog.Configure Prompt, Buttons, Title
    Dialog.Show vbModal
    GameMsgBox = Dialog.Result
    RestoreLoginButtons
    Unload Dialog
    Set Dialog = Nothing
End Function
