Attribute VB_Name = "modGeneral"
Option Explicit

Public SOffsetX As Integer
Public SOffsetY As Integer

Public Sub UnloadAllForms()
    Dim frm As Form

    For Each frm In VB.Forms
        Unload frm
    Next
End Sub

Sub GameDestroy()
    If LenB(MUSIC_EXT) <> 0 Then FSOUND_Close

    InGame = False
    Call DestroyDirectX
    Call TcpDestroy
    Call UnloadAllForms

    End
End Sub

Public Sub SetFocusOnGame()
On Error Resume Next
    frmMainGame.picScreen.SetFocus
End Sub

Sub MovePicture(PB As PictureBox, Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Button = 1 Then
        PB.Left = PB.Left + X - SOffsetX
        PB.top = PB.top + Y - SOffsetY
    End If
End Sub

' This sub writes text to the chatbox
Public Sub AddText(ByVal Msg As String, ByVal Color As Integer)
    Dim S As String

    S = vbNewLine & Msg
    frmMainGame.txtChat.SelStart = Len(frmMainGame.txtChat.Text)
    frmMainGame.txtChat.SelColor = QBColor(Color)
    frmMainGame.txtChat.SelText = S
    frmMainGame.txtChat.SelStart = Len(frmMainGame.txtChat.Text) - 1

    ' Prevent players from name spoofing
    frmMainGame.txtChat.SelHangingIndent = 15

End Sub

' Used for debugger
Public Sub TextAdd(ByVal Txt As TextBox, Msg As String, NewLine As Boolean)
    If NewLine Then
        Txt.Text = Txt.Text + Msg + vbCrLf
    Else
        Txt.Text = Txt.Text + Msg
    End If

    Txt.SelStart = Len(Txt.Text) - 1
End Sub

Sub SetStatus(ByVal Caption As String)
    frmSendGetData.lblStatus.Caption = Caption
    DoEvents
End Sub


