VERSION 5.00
Begin VB.Form frmHotkeys
   Caption = "Keyboard Shortcuts"
   ClientWidth = 6600
   ClientHeight = 6000
   BorderStyle = 3
   MaxButton = 0
   MinButton = 0
   StartUpPosition = 1
   Begin VB.ListBox lstActions
      Left = 180
      Top = 180
      Width = 6240
      Height = 3375
      TabIndex = 0
   End
   Begin VB.Label lblKey
      Caption = "Key for selected action:"
      Left = 180
      Top = 3720
      Width = 2700
      Height = 255
   End
   Begin VB.ComboBox cboKey
      Style = 2
      Left = 3000
      Top = 3660
      Width = 3420
      Height = 315
      TabIndex = 1
   End
   Begin VB.Label lblHelp
      Caption = "Select an action and choose a key. Enter always opens/sends chat. Unassign a duplicate key before using it for another action."
      Left = 180
      Top = 4200
      Width = 6240
      Height = 555
   End
   Begin VB.CommandButton cmdArrows
      Caption = "Arrow defaults"
      Left = 180
      Top = 4980
      Width = 1860
      Height = 375
      TabIndex = 2
   End
   Begin VB.CommandButton cmdWASD
      Caption = "WASD defaults"
      Left = 2160
      Top = 4980
      Width = 1860
      Height = 375
      TabIndex = 3
   End
   Begin VB.CommandButton cmdSave
      Caption = "Save"
      Left = 4200
      Top = 5520
      Width = 1020
      Height = 375
      TabIndex = 4
   End
   Begin VB.CommandButton cmdCancel
      Caption = "Cancel"
      Left = 5400
      Top = 5520
      Width = 1020
      Height = 375
      Cancel = -1
      TabIndex = 5
   End
End
Attribute VB_Name = "frmHotkeys"
Attribute VB_PredeclaredId = True
Option Explicit
Private mKeys(1 To HK_COUNT) As Integer
Private mBusy As Boolean

Private Sub Form_Load()
    Dim i As Long
    EditingHotkeys = True
    ReleaseGameKeys
    LoadHotkeys
    For i = 1 To HK_COUNT
        mKeys(i) = Hotkeys(i)
    Next
    If Not CustomHotkeys Then DefaultHotkeys mKeys, GameData.WASD <> 0
    For i = 0 To 255
        If Len(HotkeyName(CInt(i))) > 0 Then
            cboKey.AddItem HotkeyName(CInt(i))
            cboKey.ItemData(cboKey.NewIndex) = i
        End If
    Next
    RefreshActions 0
End Sub

Private Sub RefreshActions(ByVal selected As Long)
    Dim i As Long
    mBusy = True
    lstActions.Clear
    For i = 1 To HK_COUNT
        lstActions.AddItem HotkeyActionName(i) & "  -  " & HotkeyName(mKeys(i))
    Next
    lstActions.ListIndex = selected
    mBusy = False
    lstActions_Click
End Sub

Private Sub lstActions_Click()
    Dim i As Long
    If mBusy Or lstActions.ListIndex < 0 Then Exit Sub
    mBusy = True
    For i = 0 To cboKey.ListCount - 1
        If cboKey.ItemData(i) = mKeys(lstActions.ListIndex + 1) Then cboKey.ListIndex = i
    Next
    mBusy = False
End Sub

Private Sub cboKey_Click()
    Dim action As Long, previous As Integer, problem As String
    If mBusy Or lstActions.ListIndex < 0 Or cboKey.ListIndex < 0 Then Exit Sub
    action = lstActions.ListIndex + 1
    previous = mKeys(action)
    mKeys(action) = CInt(cboKey.ItemData(cboKey.ListIndex))
    problem = ValidateHotkeys(mKeys)
    If Len(problem) > 0 Then
        mKeys(action) = previous
        MsgBox problem, vbExclamation, "Keyboard Shortcuts"
    End If
    RefreshActions action - 1
End Sub

Private Sub cmdArrows_Click()
    DefaultHotkeys mKeys, False
    RefreshActions lstActions.ListIndex
End Sub
Private Sub cmdWASD_Click()
    DefaultHotkeys mKeys, True
    RefreshActions lstActions.ListIndex
End Sub
Private Sub cmdSave_Click()
    If SaveHotkeys(mKeys) Then
        frmMainGame.ApplyMovementControls
        Unload Me
    End If
End Sub
Private Sub cmdCancel_Click()
    Unload Me
End Sub
Private Sub Form_Unload(Cancel As Integer)
    EditingHotkeys = False
    ReleaseGameKeys
End Sub
