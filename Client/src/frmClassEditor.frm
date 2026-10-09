VERSION 5.00
Begin VB.Form frmClassEditor
   Caption = "Class Editor"
   ClientWidth = 7200
   ClientHeight = 7200
   BorderStyle = 4
   MaxButton = 0
   MinButton = 0
   ScaleMode = 3
   StartUpPosition = 2
   BeginProperty Font
      Name = "Arial"
      Size = 10
   EndProperty
   Begin VB.Label lblName
      Left = 180
      Top = 180
      Width = 1125
      Height = 360
      Caption = "Name"
   End
   Begin VB.TextBox txtName
      Left = 1620
      Top = 180
      Width = 5250
      Height = 390
      MaxLength = 50
   End
   Begin VB.Label lblField
      Index = 0
      Left = 180
      Top = 780
      Width = 1410
      Height = 360
      Caption = "Male sprite"
   End
   Begin VB.HScrollBar scrlValue
      Index = 0
      Left = 1620
      Top = 780
      Width = 4320
      Height = 360
      Min = 0
      Max = 32767
   End
   Begin VB.Label lblValue
      Index = 0
      Left = 6075
      Top = 780
      Width = 795
      Height = 360
      Caption = "0"
   End
   Begin VB.Label lblField
      Index = 1
      Left = 180
      Top = 1320
      Width = 1410
      Height = 360
      Caption = "Female sprite"
   End
   Begin VB.HScrollBar scrlValue
      Index = 1
      Left = 1620
      Top = 1320
      Width = 4320
      Height = 360
      Min = 0
      Max = 32767
   End
   Begin VB.Label lblValue
      Index = 1
      Left = 6075
      Top = 1320
      Width = 795
      Height = 360
      Caption = "0"
   End
   Begin VB.Label lblField
      Index = 2
      Left = 180
      Top = 1860
      Width = 1410
      Height = 360
      Caption = "Strength"
   End
   Begin VB.HScrollBar scrlValue
      Index = 2
      Left = 1620
      Top = 1860
      Width = 4320
      Height = 360
      Min = 0
      Max = 255
   End
   Begin VB.Label lblValue
      Index = 2
      Left = 6075
      Top = 1860
      Width = 795
      Height = 360
      Caption = "0"
   End
   Begin VB.Label lblField
      Index = 3
      Left = 180
      Top = 2400
      Width = 1410
      Height = 360
      Caption = "Defense"
   End
   Begin VB.HScrollBar scrlValue
      Index = 3
      Left = 1620
      Top = 2400
      Width = 4320
      Height = 360
      Min = 0
      Max = 255
   End
   Begin VB.Label lblValue
      Index = 3
      Left = 6075
      Top = 2400
      Width = 795
      Height = 360
      Caption = "0"
   End
   Begin VB.Label lblField
      Index = 4
      Left = 180
      Top = 2940
      Width = 1410
      Height = 360
      Caption = "Speed"
   End
   Begin VB.HScrollBar scrlValue
      Index = 4
      Left = 1620
      Top = 2940
      Width = 4320
      Height = 360
      Min = 0
      Max = 255
   End
   Begin VB.Label lblValue
      Index = 4
      Left = 6075
      Top = 2940
      Width = 795
      Height = 360
      Caption = "0"
   End
   Begin VB.Label lblField
      Index = 5
      Left = 180
      Top = 3480
      Width = 1410
      Height = 360
      Caption = "Magic"
   End
   Begin VB.HScrollBar scrlValue
      Index = 5
      Left = 1620
      Top = 3480
      Width = 4320
      Height = 360
      Min = 0
      Max = 255
   End
   Begin VB.Label lblValue
      Index = 5
      Left = 6075
      Top = 3480
      Width = 795
      Height = 360
      Caption = "0"
   End
   Begin VB.PictureBox picPreview
      Index = 0
      Left = 1620
      Top = 4110
      Width = 1200
      Height = 1200
      AutoRedraw = -1
      ScaleMode = 3
      BackColor = 0
   End
   Begin VB.Label lblPreview
      Index = 0
      Left = 1620
      Top = 5340
      Width = 1200
      Height = 270
      Caption = "Male"
   End
   Begin VB.PictureBox picPreview
      Index = 1
      Left = 4020
      Top = 4110
      Width = 1200
      Height = 1200
      AutoRedraw = -1
      ScaleMode = 3
      BackColor = 0
   End
   Begin VB.Label lblPreview
      Index = 1
      Left = 4020
      Top = 5340
      Width = 1200
      Height = 270
      Caption = "Female"
   End
   Begin VB.Label lblVitals
      Left = 180
      Top = 5730
      Width = 6750
      Height = 330
      Caption = ""
   End
   Begin VB.CommandButton cmdOk
      Left = 180
      Top = 6240
      Width = 3150
      Height = 450
      Caption = "Save"
   End
   Begin VB.CommandButton cmdCancel
      Left = 3720
      Top = 6240
      Width = 3150
      Height = 450
      Caption = "Cancel"
   End
   Begin VB.Label lblStatus
      Left = 180
      Top = 6750
      Width = 6750
      Height = 390
      Caption = ""
   End
   Begin VB.Timer tmrSave
      Left = 0
      Top = 0
      Width = 405
      Height = 405
      Enabled = 0
      Interval = 1000
   End
End
Attribute VB_Name = "frmClassEditor"
Attribute VB_PredeclaredId = True
Option Explicit
Private mLoading As Boolean
Private mSaving As Boolean
Private mNumber As Long
Private mWait As Long

Private Sub Form_Load()
    ClassEditorOpen = True
    mNumber = -1
    txtName.MaxLength = NAME_LENGTH
End Sub

Public Sub LoadClass(ByVal number As Long)
    Dim I As Long, lastSprite As Long
    mLoading = True
    mNumber = number
    Caption = "Class Editor - " & number
    lastSprite = 32767
    If Not DD_SpriteSurf Is Nothing Then lastSprite = DD_SpriteSurf.Height \ PIC_Y - 1
    If lastSprite > 32767 Then lastSprite = 32767
    If lastSprite < 0 Then lastSprite = 0
    For I = 0 To 1
        scrlValue(I).Max = lastSprite
    Next I
    With Class(number)
        txtName.Text = Trim$(.Name)
        ' Keep older saved sprite IDs editable if the local sheet is smaller.
        If .Sprite > scrlValue(0).Max Then scrlValue(0).Max = .Sprite
        If .FSprite > scrlValue(1).Max Then scrlValue(1).Max = .FSprite
        scrlValue(0).Value = .Sprite
        scrlValue(1).Value = .FSprite
        scrlValue(2).Value = .STR
        scrlValue(3).Value = .DEF
        scrlValue(4).Value = .speed
        scrlValue(5).Value = .MAGI
    End With
    mLoading = False
    DrawPreview
    lblStatus.Caption = "Changes apply to newly created characters."
End Sub

Private Sub scrlValue_Change(Index As Integer)
    If Not mLoading Then DrawPreview
End Sub

Private Sub scrlValue_Scroll(Index As Integer)
    scrlValue_Change Index
End Sub

Private Sub DrawPreview()
    Dim I As Long, source As RECT, destination As RECT
    For I = 0 To 5
        lblValue(I).Caption = CStr(scrlValue(I).Value)
    Next I
    lblVitals.Caption = "Starting HP: " & (1 + scrlValue(2).Value \ 2 + scrlValue(2).Value) * 2 & "   MP: " & (1 + scrlValue(5).Value \ 2 + scrlValue(5).Value) * 2 & "   SP: " & (1 + scrlValue(4).Value \ 2 + scrlValue(4).Value) * 2
    For I = 0 To 1
        picPreview(I).Cls
        If Not DD_SpriteSurf Is Nothing Then
            source.Left = 3 * PIC_X
            source.Top = CLng(scrlValue(I).Value) * PIC_Y
            source.Right = source.Left + PIC_X
            source.Bottom = source.Top + PIC_Y
            If source.Right <= DD_SpriteSurf.Width And source.Bottom <= DD_SpriteSurf.Height Then
                destination.Left = 8: destination.Top = 8
                destination.Right = 72: destination.Bottom = 72
                DD_SpriteSurf.BltToDC picPreview(I).hDC, source, destination
            End If
        End If
        picPreview(I).Refresh
    Next I
End Sub

Private Sub cmdOk_Click()
    Dim packet As String, I As Long, character As Long, className As String
    If mSaving Or mNumber < 0 Then Exit Sub
    className = Trim$(txtName.Text)
    If Len(className) = 0 Then
        GameMsgBox "Enter a class name.", vbExclamation, "Class Editor"
        Exit Sub
    End If
    For I = 1 To Len(className)
        character = AscW(Mid$(className, I, 1))
        If character < 32 Or character > 126 Then
            GameMsgBox "Use printable English characters in the class name.", vbExclamation, "Class Editor"
            Exit Sub
        End If
    Next I
    If Not IsConnected Then
        SaveFailed "Not connected to the server."
        Exit Sub
    End If
    packet = "SAVECLASS" & SEP_CHAR & mNumber & SEP_CHAR & className
    For I = 0 To 5
        packet = packet & SEP_CHAR & scrlValue(I).Value
    Next I
    mSaving = True
    mWait = 0
    SetEditingEnabled False
    tmrSave.Enabled = True
    lblStatus.Caption = "Saving class " & mNumber & "..."
    SendData packet & END_CHAR
End Sub

Private Sub SetEditingEnabled(ByVal enabled As Boolean)
    Dim I As Long
    txtName.Enabled = enabled
    cmdOk.Enabled = enabled
    cmdCancel.Enabled = enabled
    For I = 0 To 5
        scrlValue(I).Enabled = enabled
    Next I
End Sub

Public Sub SaveComplete(ByVal number As Long)
    If Not mSaving Or number <> mNumber Then Exit Sub
    mSaving = False
    tmrSave.Enabled = False
    Unload Me
End Sub

Public Sub SaveFailed(ByVal message As String)
    mSaving = False
    tmrSave.Enabled = False
    SetEditingEnabled True
    lblStatus.Caption = message
End Sub

Private Sub tmrSave_Timer()
    mWait = mWait + 1
    If Not IsConnected Or mWait >= 30 Then SaveFailed "Save not confirmed. Reopen the editor to verify before retrying."
End Sub

Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    If mSaving Then Cancel = True
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ClassEditorOpen = False
End Sub
