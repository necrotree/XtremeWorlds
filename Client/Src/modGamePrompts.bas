Attribute VB_Name = "modGamePrompts"
Option Explicit

Public Function GameMsgBox(ByVal Prompt As String, Optional ByVal Buttons As VbMsgBoxStyle = vbOKOnly, Optional ByVal Title As String = "") As VbMsgBoxResult
    Dim Dialog As New frmGamePrompt
    If Len(Title) = 0 Then Title = GAME_NAME
    Load Dialog
    Dialog.Configure Prompt, Buttons, Title
    Dialog.Show vbModal
    GameMsgBox = Dialog.Result
    Unload Dialog
    Set Dialog = Nothing
End Function
