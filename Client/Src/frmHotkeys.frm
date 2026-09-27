VERSION 5.00
Begin VB.Form frmHotkeys
   Caption = "Keyboard Shortcuts"
   ClientWidth = 15120
   ClientHeight = 8100
   BorderStyle = 3
   MaxButton = 0
   MinButton = 0
   StartUpPosition = 1
   Begin VB.ListBox lstActions
      Left = 180
      Top = 4560
      Width = 8250
      Height = 2700
      TabIndex = 0
   End
   Begin VB.Label lblKey
      Caption = "Key for selected action:"
      Left = 8700
      Top = 4560
      Width = 5850
      Height = 300
   End
   Begin VB.ComboBox cboKey
      Left = 8700
      Top = 4920
      Width = 6150
      Height = 360
      Style = 2
      TabIndex = 1
   End
   Begin VB.Label lblHelp
      Caption = "Select an action or slot, then click a key above. Green: selected binding. Blue: assigned. Gray: system keys. Enter is reserved for chat/pickup. Choose Unassigned to clear a binding."
      Left = 8700
      Top = 5400
      Width = 6150
      Height = 1020
   End
   Begin VB.CommandButton cmdArrows
      Caption = "Arrow defaults"
      Left = 8700
      Top = 6660
      Width = 2940
      Height = 420
      TabIndex = 2
   End
   Begin VB.CommandButton cmdWASD
      Caption = "WASD defaults"
      Left = 11790
      Top = 6660
      Width = 3060
      Height = 420
      TabIndex = 3
   End
   Begin VB.CommandButton cmdSave
      Caption = "Save"
      Left = 11790
      Top = 7440
      Width = 1440
      Height = 420
      TabIndex = 4
   End
   Begin VB.CommandButton cmdCancel
      Caption = "Cancel"
      Left = 13410
      Top = 7440
      Width = 1440
      Height = 420
      TabIndex = 5
      Cancel = -1
   End
   Begin VB.PictureBox picKeyboard
      Left = 90
      Top = 120
      Width = 14940
      Height = 4200
      ScaleMode = 3
      AutoRedraw = -1
      BackColor = 2105376
      ForeColor = 0
      TabStop = 0
   End
End
Attribute VB_Name = "frmHotkeys"
Attribute VB_PredeclaredId = True
Option Explicit
Private mKeys(1 To HK_COUNT) As Integer
Private mBusy As Boolean
Private mKeyCode(0 To 110) As Integer
Private mKeyX(0 To 110) As Long
Private mKeyY(0 To 110) As Long
Private mKeyW(0 To 110) As Long
Private mKeyH(0 To 110) As Long
Private mKeyCaption(0 To 110) As String
Private mKeyCount As Long



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
    BuildKeyboard
    RefreshActions 0
End Sub

Private Sub RefreshActions(ByVal selected As Long)
    Dim i As Long
    mBusy = True
    lstActions.Clear
    For i = 1 To HK_COUNT
        lstActions.AddItem ActionCaption(i) & "  -  " & HotkeyName(mKeys(i))
    Next
    lstActions.ListIndex = selected
    mBusy = False
    lstActions_Click
End Sub

Private Function ActionCaption(ByVal action As Long) As String
    Dim number As Long
    ActionCaption = HotkeyActionName(action)
    If Not InGame Or MyIndex < 1 Or MyIndex > MAX_PLAYERS Then Exit Function
    If action >= HK_SPELL Then
        number = Player(MyIndex).Spell(action - HK_SPELL + 1)
        If number > 0 And number <= MAX_SPELLS Then ActionCaption = ActionCaption & ": " & Trim$(Spell(number).name)
    ElseIf action >= HK_INVENTORY Then
        number = GetPlayerInvItemNum(MyIndex, action - HK_INVENTORY + 1)
        If number > 0 And number <= MAX_ITEMS Then ActionCaption = ActionCaption & ": " & Trim$(Item(number).name)
    End If
End Function

Private Sub lstActions_Click()
    Dim i As Long
    If mBusy Or lstActions.ListIndex < 0 Then Exit Sub
    mBusy = True
    For i = 0 To cboKey.ListCount - 1
        If cboKey.ItemData(i) = mKeys(lstActions.ListIndex + 1) Then cboKey.ListIndex = i
    Next
    mBusy = False
    DrawKeyboard
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

Private Sub AddKeyboardKey(ByVal key As Integer, ByVal title As String, ByVal X As Long, ByVal Y As Long, Optional ByVal W As Long = 42, Optional ByVal H As Long = 38)
    mKeyCode(mKeyCount) = key
    mKeyCaption(mKeyCount) = title
    mKeyX(mKeyCount) = X
    mKeyY(mKeyCount) = Y
    mKeyW(mKeyCount) = W
    mKeyH(mKeyCount) = H
    mKeyCount = mKeyCount + 1
End Sub

Private Sub BuildKeyboard()
    Dim i As Long, codes As Variant, titles As Variant
    mKeyCount = 0
    AddKeyboardKey 27, "Esc", 8, 8
    For i = 1 To 12
        AddKeyboardKey 111 + i, "F" & CStr(i), 60 + (i - 1) * 46 + ((i - 1) \ 4) * 12, 8
    Next
    AddKeyboardKey 44, "Print", 652, 8
    AddKeyboardKey 145, "Scroll", 698, 8
    AddKeyboardKey 19, "Pause", 744, 8
    codes = Array(192, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 189, 187)
    titles = Array("`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=")
    For i = 0 To 12
        AddKeyboardKey CInt(codes(i)), CStr(titles(i)), 8 + i * 46, 60
    Next
    AddKeyboardKey 8, "Back", 606, 60, 42
    AddKeyboardKey 9, "Tab", 8, 102, 60
    codes = Array(81, 87, 69, 82, 84, 89, 85, 73, 79, 80, 219, 221)
    titles = Array("Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]")
    For i = 0 To 11
        AddKeyboardKey CInt(codes(i)), CStr(titles(i)), 72 + i * 46, 102
    Next
    AddKeyboardKey 220, "\", 624, 102, 24
    AddKeyboardKey 20, "Caps Lock", 8, 144, 78
    codes = Array(65, 83, 68, 70, 71, 72, 74, 75, 76, 186, 222)
    titles = Array("A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'")
    For i = 0 To 10
        AddKeyboardKey CInt(codes(i)), CStr(titles(i)), 90 + i * 46, 144
    Next
    AddKeyboardKey 13, "Enter", 596, 144, 52
    AddKeyboardKey 16, "Shift", 8, 186, 96
    codes = Array(90, 88, 67, 86, 66, 78, 77, 188, 190, 191)
    titles = Array("Z", "X", "C", "V", "B", "N", "M", ",", ".", "/")
    For i = 0 To 9
        AddKeyboardKey CInt(codes(i)), CStr(titles(i)), 108 + i * 46, 186
    Next
    AddKeyboardKey 16, "Shift", 568, 186, 80
    AddKeyboardKey 17, "Ctrl", 8, 228, 70
    AddKeyboardKey 0, "Win", 82, 228, 46
    AddKeyboardKey 0, "Alt", 132, 228, 56
    AddKeyboardKey 32, "Space", 192, 228, 254
    AddKeyboardKey 0, "Alt", 450, 228, 56
    AddKeyboardKey 0, "Menu", 510, 228, 56
    AddKeyboardKey 17, "Ctrl", 570, 228, 78
    AddKeyboardKey 45, "Insert", 660, 60
    AddKeyboardKey 36, "Home", 706, 60
    AddKeyboardKey 33, "PgUp", 752, 60
    AddKeyboardKey 46, "Del", 660, 102
    AddKeyboardKey 35, "End", 706, 102
    AddKeyboardKey 34, "PgDn", 752, 102
    AddKeyboardKey 38, "Up", 706, 186
    AddKeyboardKey 37, "Left", 660, 228
    AddKeyboardKey 40, "Down", 706, 228
    AddKeyboardKey 39, "Right", 752, 228
    AddKeyboardKey 144, "Num", 808, 60
    AddKeyboardKey 111, "/", 854, 60
    AddKeyboardKey 106, "*", 900, 60
    AddKeyboardKey 109, "-", 946, 60
    For i = 0 To 8
        AddKeyboardKey 103 - (i \ 3) * 3 + (i Mod 3), CStr(7 - (i \ 3) * 3 + (i Mod 3)), 808 + (i Mod 3) * 46, 102 + (i \ 3) * 42
    Next
    AddKeyboardKey 107, "+", 946, 102, 42, 80
    AddKeyboardKey 13, "Enter", 946, 186, 42, 80
    AddKeyboardKey 96, "0", 808, 228, 88
    AddKeyboardKey 110, ".", 900, 228
End Sub

Private Sub DrawKeyboard()
    Dim i As Long, j As Long, fill As Long, bound As Boolean, selected As Integer
    picKeyboard.Cls
    If lstActions.ListIndex >= 0 Then selected = mKeys(lstActions.ListIndex + 1)
    For i = 0 To mKeyCount - 1
        fill = RGB(238, 238, 238)
        bound = False
        For j = 1 To HK_COUNT
            If mKeyCode(i) <> 0 And mKeys(j) = mKeyCode(i) Then bound = True
        Next
        If bound Then fill = RGB(181, 213, 230)
        If mKeyCode(i) = selected And selected <> 0 Then fill = RGB(105, 193, 160)
        If mKeyCode(i) = 0 Then fill = RGB(140, 140, 140)
        picKeyboard.Line (mKeyX(i), mKeyY(i))-(mKeyX(i) + mKeyW(i), mKeyY(i) + mKeyH(i)), fill, BF
        picKeyboard.Line (mKeyX(i), mKeyY(i))-(mKeyX(i) + mKeyW(i), mKeyY(i) + mKeyH(i)), RGB(100, 100, 100), B
        picKeyboard.CurrentX = mKeyX(i) + (mKeyW(i) - picKeyboard.TextWidth(mKeyCaption(i))) / 2
        picKeyboard.CurrentY = mKeyY(i) + (mKeyH(i) - picKeyboard.TextHeight("A")) / 2
        picKeyboard.Print mKeyCaption(i)
    Next
End Sub

Private Sub picKeyboard_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim i As Long, j As Long
    If Button <> 1 Then Exit Sub
    For i = 0 To mKeyCount - 1
        If X >= mKeyX(i) And X <= mKeyX(i) + mKeyW(i) And Y >= mKeyY(i) And Y <= mKeyY(i) + mKeyH(i) Then
            If mKeyCode(i) = 0 Then Exit Sub
            For j = 0 To cboKey.ListCount - 1
                If cboKey.ItemData(j) = mKeyCode(i) Then
                    cboKey.ListIndex = j
                    Exit Sub
                End If
            Next
        End If
    Next
End Sub
