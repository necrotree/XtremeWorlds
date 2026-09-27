VERSION 5.00
Begin VB.Form frmArrowEditor
   Caption = "Arrow Editor"
   ClientWidth = 5055
   ClientHeight = 4275
   BorderStyle = 4
   ControlBox = 0
   ScaleMode = 3
   MaxButton = 0
   MinButton = 0
   StartUpPosition = 2
   BeginProperty Font
      Name = "Arial"
      Size = 12
   EndProperty
   Begin VB.Label lblName
      Left = 120
      Top = 120
      Width = 735
      Height = 375
      Caption = "Name"
   End
   Begin VB.TextBox txtName
      Left = 960
      Top = 120
      Width = 3975
      Height = 390
      MaxLength = 50
      TabIndex = 0
   End
   Begin VB.PictureBox picIcon
      Left = 4440
      Top = 600
      Width = 480
      Height = 480
      AutoRedraw = -1
      ScaleMode = 3
      BackColor = 0
   End
   Begin VB.Label lblArrow
      Left = 120
      Top = 600
      Width = 735
      Height = 375
      Caption = "Arrow"
   End
   Begin VB.HScrollBar scrlSprite
      Left = 960
      Top = 600
      Width = 2895
      Height = 375
      Min = 0
      Max = 153
      TabIndex = 1
   End
   Begin VB.Label lblSprite
      Left = 3840
      Top = 600
      Width = 495
      Height = 375
      Caption = "1"
      Alignment = 1
   End
   Begin VB.Label lblRangeTitle
      Left = 120
      Top = 1200
      Width = 735
      Height = 375
      Caption = "Range"
   End
   Begin VB.HScrollBar scrlRange
      Left = 960
      Top = 1200
      Width = 2895
      Height = 375
      Min = 1
      Max = 32
      Value = 8
      TabIndex = 2
   End
   Begin VB.Label lblRange
      Left = 3840
      Top = 1200
      Width = 495
      Height = 375
      Caption = "8"
      Alignment = 1
   End
   Begin VB.ComboBox cmbArrow
      Left = 120
      Top = 1620
      Width = 4815
      Height = 390
      Style = 2
      TabIndex = 3
   End
   Begin VB.PictureBox picPreview
      Left = 120
      Top = 2100
      Width = 4815
      Height = 1080
      AutoRedraw = -1
      ScaleMode = 3
      BackColor = 0
   End
   Begin VB.Label lblStatus
      Left = 120
      Top = 3240
      Width = 4815
      Height = 240
   End
   Begin VB.CommandButton cmdOk
      Left = 120
      Top = 3600
      Width = 2295
      Height = 495
      Caption = "OK"
      TabIndex = 4
   End
   Begin VB.CommandButton cmdCancel
      Left = 2640
      Top = 3600
      Width = 2295
      Height = 495
      Caption = "Cancel"
      Cancel = -1
      TabIndex = 5
   End
End
Attribute VB_Name = "frmArrowEditor"
Attribute VB_PredeclaredId = True
Option Explicit
Private mBusy As Boolean
Private mSaving As Boolean

Private Sub Form_Load()
    Dim i As Long
    ArrowEditorActive = True
    mBusy = True
    For i = 1 To MAX_ARROWS
        cmbArrow.AddItem "Arrow " & CStr(i)
    Next
    If Not DD_ArrowSurf Is Nothing Then scrlSprite.Max = DD_ArrowSurf.Height \ PIC_Y - 1
    mBusy = False
    cmbArrow.ListIndex = 0
End Sub

Private Sub cmbArrow_Click()
    Dim number As Long
    If mBusy Or cmbArrow.ListIndex < 0 Then Exit Sub
    number = cmbArrow.ListIndex + 1
    mBusy = True
    txtName.Text = Arrows(number).Name
    If Arrows(number).Sprite >= 0 And Arrows(number).Sprite <= scrlSprite.Max Then
        scrlSprite.Value = Arrows(number).Sprite
    Else
        scrlSprite.Value = 0
    End If
    If Arrows(number).Range >= 1 And Arrows(number).Range <= 32 Then
        scrlRange.Value = Arrows(number).Range
    Else
        scrlRange.Value = 8
    End If
    mBusy = False
    lblStatus.Caption = vbNullString
    DrawPreview
End Sub

Private Sub scrlSprite_Change()
    If Not mBusy Then DrawPreview
End Sub

Private Sub scrlRange_Change()
    lblRange.Caption = CStr(scrlRange.Value)
End Sub

Private Sub DrawPreview()
    Dim source As RECT, destination As RECT
    lblSprite.Caption = CStr(scrlSprite.Value + 1)
    lblRange.Caption = CStr(scrlRange.Value)
    picPreview.Cls
    picIcon.Cls
    If DD_ArrowSurf Is Nothing Then Exit Sub
    source.Left = 0
    source.Top = scrlSprite.Value * PIC_Y
    source.Right = PIC_X * 4
    source.Bottom = source.Top + PIC_Y
    destination.Left = (picPreview.ScaleWidth - PIC_X * 8) \ 2
    destination.Top = (picPreview.ScaleHeight - PIC_Y * 2) \ 2
    destination.Right = destination.Left + PIC_X * 8
    destination.Bottom = destination.Top + PIC_Y * 2
    DD_ArrowSurf.BltToDC picPreview.hDC, source, destination
    source.Right = PIC_X
    destination.Left = (picIcon.ScaleWidth - PIC_X) \ 2
    destination.Top = (picIcon.ScaleHeight - PIC_Y) \ 2
    destination.Right = destination.Left + PIC_X
    destination.Bottom = destination.Top + PIC_Y
    DD_ArrowSurf.BltToDC picIcon.hDC, source, destination
    picIcon.Refresh
    picPreview.Refresh
End Sub

Private Sub cmdOk_Click()
    SaveArrow
End Sub

Private Sub SaveArrow()
    Dim number As Long
    If mSaving Or cmbArrow.ListIndex < 0 Then Exit Sub
    If InStr(txtName.Text, SEP_CHAR) > 0 Or InStr(txtName.Text, END_CHAR) > 0 Then
        MsgBox "The name contains an unsupported character.", vbExclamation
        Exit Sub
    End If
    number = cmbArrow.ListIndex + 1
    mSaving = True
    SetEditingEnabled False
    lblStatus.Caption = "Saving arrow " & number & "..."
    SendData "SAVEARROW" & SEP_CHAR & number & SEP_CHAR & scrlSprite.Value & SEP_CHAR & scrlRange.Value & SEP_CHAR & Trim$(txtName.Text) & END_CHAR
End Sub

Public Sub SaveComplete(ByVal number As Long)
    If Not mSaving Or number <> cmbArrow.ListIndex + 1 Then Exit Sub
    Arrows(number).Name = Trim$(txtName.Text)
    Arrows(number).Sprite = scrlSprite.Value
    Arrows(number).Range = scrlRange.Value
    mSaving = False
    SetEditingEnabled True
    lblStatus.Caption = "Arrow " & number & " saved."
    Unload Me
End Sub

Private Sub SetEditingEnabled(ByVal enabled As Boolean)
    cmbArrow.Enabled = enabled
    txtName.Enabled = enabled
    scrlSprite.Enabled = enabled
    scrlRange.Enabled = enabled
    cmdOk.Enabled = enabled
End Sub

Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ArrowEditorActive = False
End Sub
