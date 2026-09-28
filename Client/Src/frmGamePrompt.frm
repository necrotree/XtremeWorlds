VERSION 5.00
Begin VB.Form frmGamePrompt
   BorderStyle = 0
   ClientWidth = 5040
   ClientHeight = 2250
   ScaleMode = 3
   ScaleWidth = 336
   ScaleHeight = 150
   AutoRedraw = -1
   KeyPreview = -1
   ShowInTaskbar = 0
   StartUpPosition = 2
   Picture = "frmGamePrompt.frx":0
   Begin VB.Label lblTitle
      Left = 240
      Top = 180
      Width = 4560
      Height = 270
      ForeColor = 14809087
      BackStyle = 0
      Caption = ""
   End
   Begin VB.TextBox txtMessage
      Left = 240
      Top = 540
      Width = 4560
      Height = 900
      ForeColor = 14809087
      MultiLine = -1
      Locked = -1
      ScrollBars = 2
      BorderStyle = 0
      BackColor = 2894936
   End
   Begin VB.Label lblChoice
      Left = 375
      Top = 1620
      Width = 1290
      Height = 360
      ForeColor = 14809087
      BackStyle = 1
      Caption = ""
      Index = 0
      BorderStyle = 1
      Alignment = 2
      BackColor = 2894936
   End
   Begin VB.Label lblChoice
      Left = 1785
      Top = 1620
      Width = 1290
      Height = 360
      ForeColor = 14809087
      BackStyle = 1
      Caption = ""
      Index = 1
      BorderStyle = 1
      Alignment = 2
      BackColor = 2894936
   End
   Begin VB.Label lblChoice
      Left = 3195
      Top = 1620
      Width = 1290
      Height = 360
      ForeColor = 14809087
      BackStyle = 1
      Caption = ""
      Index = 2
      BorderStyle = 1
      Alignment = 2
      BackColor = 2894936
   End
End
Attribute VB_Name = "frmGamePrompt"
Attribute VB_PredeclaredId = True
    Option Explicit
    Public Result As VbMsgBoxResult
    Private Choices(2) As VbMsgBoxResult
    Private ChoiceCount As Long
    Private FocusChoice As Long
    Private EscapeResult As VbMsgBoxResult

    Public Sub Configure(ByVal Message As String, ByVal Buttons As VbMsgBoxStyle, ByVal Title As String)
        Dim i As Long, Lines As Long, Part As Variant
        lblTitle.Caption = Title
        txtMessage.Text = Message
        Lines = 0
        For Each Part In Split(Replace(Message, vbCr, vbNullString), vbLf)
            Lines = Lines + 1 + Len(CStr(Part)) \ 42
        Next Part
        If Lines < 2 Then Lines = 2
        If Lines > 22 Then Lines = 22
        txtMessage.Height = Lines * 17
        Me.Height = (txtMessage.Top + txtMessage.Height + 52) * Screen.TwipsPerPixelY
        Select Case (CLng(Buttons) And 15)
            Case vbOKCancel
                SetChoice 0, "OK", vbOK
                SetChoice 1, "Cancel", vbCancel
                EscapeResult = vbCancel
            Case vbYesNo, vbYesNoCancel
                SetChoice 0, "Yes", vbYes
                SetChoice 1, "No", vbNo
                If (CLng(Buttons) And 15) = vbYesNoCancel Then
                    SetChoice 2, "Cancel", vbCancel
                    EscapeResult = vbCancel
                End If
            Case vbRetryCancel
                SetChoice 0, "Retry", vbRetry
                SetChoice 1, "Cancel", vbCancel
                EscapeResult = vbCancel
            Case vbAbortRetryIgnore
                SetChoice 0, "Abort", vbAbort
                SetChoice 1, "Retry", vbRetry
                SetChoice 2, "Ignore", vbIgnore
            Case Else
                SetChoice 0, "OK", vbOK
                EscapeResult = vbOK
        End Select
        For i = 0 To 2
            lblChoice(i).Visible = (i < ChoiceCount)
            lblChoice(i).Top = txtMessage.Top + txtMessage.Height + 12
            lblChoice(i).Left = (ScaleWidth - ChoiceCount * 94 + 8) / 2 + i * 94
        Next i
        FocusChoice = (CLng(Buttons) And &H300) \ &H100
        If FocusChoice >= ChoiceCount Then FocusChoice = 0
        HighlightChoice
        PaintSkin
    End Sub

    Private Sub SetChoice(ByVal Index As Long, ByVal Caption As String, ByVal Value As VbMsgBoxResult)
        Choices(Index) = Value
        lblChoice(Index).Caption = Caption
        ChoiceCount = Index + 1
    End Sub

    Private Sub HighlightChoice()
        Dim i As Long
        For i = 0 To 2
            lblChoice(i).FontBold = (i = FocusChoice)
            If i = FocusChoice Then
                lblChoice(i).BackColor = RGB(110, 68, 53)
            Else
                lblChoice(i).BackColor = RGB(88, 44, 44)
            End If
        Next i
    End Sub

    Private Sub lblChoice_Click(Index As Integer)
        Result = Choices(Index)
        Me.Hide
    End Sub

    Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
        Select Case KeyCode
            Case vbKeyReturn
                lblChoice_Click CInt(FocusChoice)
                KeyCode = 0
            Case vbKeyEscape
                If EscapeResult <> 0 Then
                    Result = EscapeResult
                    Me.Hide
                End If
                KeyCode = 0
            Case vbKeyTab, vbKeyLeft, vbKeyRight
                If KeyCode = vbKeyLeft Or (KeyCode = vbKeyTab And (Shift And vbShiftMask) <> 0) Then
                    FocusChoice = (FocusChoice + ChoiceCount - 1) Mod ChoiceCount
                Else
                    FocusChoice = (FocusChoice + 1) Mod ChoiceCount
                End If
                HighlightChoice
                KeyCode = 0
        End Select
    End Sub

    Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
        If UnloadMode = vbFormControlMenu Then
            Cancel = True
            If EscapeResult <> 0 Then
                Result = EscapeResult
                Me.Hide
            End If
        End If
    End Sub

    Private Sub PaintSkin()
        Dim h As Single
        h = ScaleHeight
        Me.PaintPicture Me.Picture, 0, 0, 336, 7, 0, 0, 336, 7
        Me.PaintPicture Me.Picture, 0, 7, 7, h - 14, 0, 7, 7, 50
        Me.PaintPicture Me.Picture, 7, 7, 322, h - 14, 7, 7, 322, 50
        Me.PaintPicture Me.Picture, 329, 7, 7, h - 14, 329, 7, 7, 50
        Me.PaintPicture Me.Picture, 0, h - 7, 336, 7, 0, 57, 336, 7
    End Sub
