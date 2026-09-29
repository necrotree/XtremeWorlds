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
    Begin VB.Image imgOk
        Left = 0
        Top = 0
        Width = 1530
        Height = 360
        Stretch = -1
        Visible = 0
    End
    Begin VB.Image imgYes
        Left = 0
        Top = 0
        Width = 1530
        Height = 360
        Stretch = -1
        Visible = 0
    End
    Begin VB.Image imgNo
        Left = 0
        Top = 0
        Width = 1530
        Height = 360
        Stretch = -1
        Visible = 0
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
        ChoiceCount = 0
        EscapeResult = 0
        Result = 0
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
            Case vbYesNo
                SetChoice 0, vbYes
                SetChoice 1, vbNo
                EscapeResult = vbNo
            Case Else
                SetChoice 0, vbOK
                EscapeResult = vbOK
        End Select
        imgOk.Visible = False
        imgYes.Visible = False
        imgNo.Visible = False
        PositionChoices
        FocusChoice = (CLng(Buttons) And &H300) \ &H100
        If FocusChoice >= ChoiceCount Then FocusChoice = 0
        PaintSkin
    End Sub

    Private Sub SetChoice(ByVal Index As Long, ByVal Value As VbMsgBoxResult)
        Choices(Index) = Value
        ChoiceCount = Index + 1
    End Sub

    Private Sub PositionChoices()
        Dim i As Long, x As Long, y As Long
        y = txtMessage.Top + txtMessage.Height + 12
        x = (ScaleWidth - ChoiceCount * 110 + 8) / 2
        For i = 0 To ChoiceCount - 1
            Select Case Choices(i)
                Case vbOK
                    imgOk.Move x, y, 102, 24
                    imgOk.Visible = True
                Case vbYes
                    imgYes.Move x, y, 102, 24
                    imgYes.Visible = True
                Case vbNo
                    imgNo.Move x, y, 102, 24
                    imgNo.Visible = True
            End Select
            x = x + 110
        Next i
    End Sub

    Private Sub SelectChoice(ByVal Value As VbMsgBoxResult)
        Dim i As Long
        For i = 0 To ChoiceCount - 1
            If Choices(i) = Value Then
                Result = Value
                Me.Hide
                Exit Sub
            End If
        Next i
    End Sub

    Private Sub imgOk_Click()
        SelectChoice vbOK
    End Sub

    Private Sub imgYes_Click()
        SelectChoice vbYes
    End Sub

    Private Sub imgNo_Click()
        SelectChoice vbNo
    End Sub

    Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
        Select Case KeyCode
            Case vbKeyReturn
                If FocusChoice >= 0 And FocusChoice < ChoiceCount Then SelectChoice Choices(FocusChoice)
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
