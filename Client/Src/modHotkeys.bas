Attribute VB_Name = "modHotkeys"
Option Explicit

Public Const HK_UP As Long = 1
Public Const HK_DOWN As Long = 2
Public Const HK_LEFT As Long = 3
Public Const HK_RIGHT As Long = 4
Public Const HK_ATTACK As Long = 5
Public Const HK_RUN As Long = 6
Public Const HK_PICKUP As Long = 7
Public Const HK_CAST As Long = 8
Public Const HK_ADMIN As Long = 9
Public Const HK_QUIT As Long = 10
Public Const HK_COUNT As Long = 10
Public Hotkeys(1 To HK_COUNT) As Integer
Public CustomHotkeys As Boolean
Public EditingHotkeys As Boolean
Private mLoaded As Boolean
Private Declare Function ReadKeySetting Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal section As String, ByVal key As String, ByVal default As String, ByVal buffer As String, ByVal size As Long, ByVal path As String) As Long
Private Declare Function WriteKeySetting Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal section As String, ByVal key As String, ByVal value As String, ByVal path As String) As Long

Public Function HotkeyActionName(ByVal action As Long) As String
    HotkeyActionName = Choose(action, "Move up", "Move down", "Move left", "Move right", "Attack", "Run", "Pick up item", "Cast memorized spell", "Toggle admin panel", "Quit game")
End Function

Public Sub DefaultHotkeys(ByRef keys() As Integer, ByVal wasd As Boolean)
    keys(HK_UP) = vbKeyUp
    keys(HK_DOWN) = vbKeyDown
    keys(HK_LEFT) = vbKeyLeft
    keys(HK_RIGHT) = vbKeyRight
    keys(HK_ATTACK) = vbKeyControl
    keys(HK_RUN) = vbKeyShift
    keys(HK_PICKUP) = vbKeyReturn
    keys(HK_CAST) = vbKeyInsert
    keys(HK_ADMIN) = vbKeyF1
    keys(HK_QUIT) = vbKeyEscape
    If wasd Then
        keys(HK_UP) = vbKeyW
        keys(HK_DOWN) = vbKeyS
        keys(HK_LEFT) = vbKeyA
        keys(HK_RIGHT) = vbKeyD
        keys(HK_PICKUP) = vbKeyE
    End If
End Sub

Public Function HotkeyName(ByVal key As Integer) As String
    Select Case key
        Case 0: HotkeyName = "Unassigned"
        Case 48 To 57, 65 To 90: HotkeyName = Chr$(key)
        Case 112 To 123: HotkeyName = "F" & CStr(key - 111)
        Case vbKeyUp: HotkeyName = "Up arrow"
        Case vbKeyDown: HotkeyName = "Down arrow"
        Case vbKeyLeft: HotkeyName = "Left arrow"
        Case vbKeyRight: HotkeyName = "Right arrow"
        Case vbKeyControl: HotkeyName = "Ctrl"
        Case vbKeyShift: HotkeyName = "Shift"
        Case vbKeySpace: HotkeyName = "Space"
        Case vbKeyReturn: HotkeyName = "Enter (pickup only)"
        Case vbKeyEscape: HotkeyName = "Escape"
        Case vbKeyInsert: HotkeyName = "Insert"
        Case vbKeyDelete: HotkeyName = "Delete"
        Case vbKeyHome: HotkeyName = "Home"
        Case vbKeyEnd: HotkeyName = "End"
        Case vbKeyPageUp: HotkeyName = "Page Up"
        Case vbKeyPageDown: HotkeyName = "Page Down"
    End Select
End Function

Public Function ValidateHotkeys(ByRef keys() As Integer) As String
    Dim i As Long, j As Long
    For i = 1 To HK_COUNT
        If Len(HotkeyName(keys(i))) = 0 Then
            ValidateHotkeys = "Unsupported key for " & HotkeyActionName(i) & "."
            Exit Function
        End If
        If keys(i) = vbKeyReturn And i <> HK_PICKUP Then
            ValidateHotkeys = "Enter is reserved for chat and picking up items."
            Exit Function
        End If
        For j = 1 To i - 1
            If keys(i) <> 0 And keys(i) = keys(j) Then
                ValidateHotkeys = HotkeyActionName(i) & " and " & HotkeyActionName(j) & " both use " & HotkeyName(keys(i)) & "."
                Exit Function
            End If
        Next
    Next
End Function

Public Sub LoadHotkeys()
    Dim i As Long, count As Long, buffer As String, value As String, path As String
    DefaultHotkeys Hotkeys, False
    CustomHotkeys = False
    path = App.Path & DATA_PATH & "Hotkeys.ini"
    buffer = Space$(16)
    count = ReadKeySetting("Keyboard", "Enabled", "0", buffer, Len(buffer), path)
    If Left$(buffer, count) = "1" Then
        For i = 1 To HK_COUNT
            buffer = Space$(16)
            count = ReadKeySetting("Keyboard", CStr(i), CStr(Hotkeys(i)), buffer, Len(buffer), path)
            value = Left$(buffer, count)
            If Not IsNumeric(value) Then GoTo InvalidProfile
            If Val(value) < 0 Or Val(value) > 255 Or Val(value) <> Fix(Val(value)) Then GoTo InvalidProfile
            Hotkeys(i) = CInt(value)
        Next
        If Len(ValidateHotkeys(Hotkeys)) > 0 Then GoTo InvalidProfile
        CustomHotkeys = True
    End If
    mLoaded = True
    Exit Sub
InvalidProfile:
    DefaultHotkeys Hotkeys, False
    mLoaded = True
End Sub

Public Function SaveHotkeys(ByRef keys() As Integer) As Boolean
    Dim path As String, temporary As String, backup As String, i As Long, moved As Boolean
    On Error GoTo Failed
    If Len(ValidateHotkeys(keys)) > 0 Then Exit Function
    path = App.Path & DATA_PATH & "Hotkeys.ini"
    temporary = path & ".editing"
    backup = path & ".previous"
    If Len(Dir$(temporary)) > 0 Or Len(Dir$(backup)) > 0 Then Err.Raise 58, , "A Hotkeys.ini recovery file already exists."
    For i = 1 To HK_COUNT
        If WriteKeySetting("Keyboard", CStr(i), CStr(keys(i)), temporary) = 0 Then Err.Raise 75
    Next
    If WriteKeySetting("Keyboard", "Enabled", "1", temporary) = 0 Then Err.Raise 75
    If Len(Dir$(path)) > 0 Then
        Name path As backup
        moved = True
    End If
    Name temporary As path
    For i = 1 To HK_COUNT
        Hotkeys(i) = keys(i)
    Next
    CustomHotkeys = True
    mLoaded = True
    SaveHotkeys = True
    If moved Then Kill backup
    Exit Function
Failed:
    MsgBox "Could not save keyboard shortcuts: " & Err.Description, vbExclamation
    On Error Resume Next
    If moved And Len(Dir$(path)) = 0 Then Name backup As path
End Function

Public Function GameKeyMatches(ByVal action As Long, ByVal key As Integer) As Boolean
    If Not mLoaded Then LoadHotkeys
    If key = 0 Then Exit Function
    GameKeyMatches = (Hotkeys(action) = key)
    If Not CustomHotkeys And GameData.WASD <> 0 Then
        Select Case action
            Case HK_UP: GameKeyMatches = GameKeyMatches Or key = vbKeyW
            Case HK_DOWN: GameKeyMatches = GameKeyMatches Or key = vbKeyS
            Case HK_LEFT: GameKeyMatches = GameKeyMatches Or key = vbKeyA
            Case HK_RIGHT: GameKeyMatches = GameKeyMatches Or key = vbKeyD
            Case HK_PICKUP: GameKeyMatches = GameKeyMatches Or key = vbKeyE
        End Select
    End If
End Function

Public Function GameKeyDown(ByVal action As Long) As Boolean
    Dim alternate As Integer
    If Not mLoaded Then LoadHotkeys
    If EditingHotkeys Or Not TxtHasFocus Or frmMainGame.ChatUnlocked Then Exit Function
    If Hotkeys(action) <> 0 Then GameKeyDown = (GetAsyncKeyState(Hotkeys(action)) < 0)
    If Not CustomHotkeys And GameData.WASD <> 0 Then
        Select Case action
            Case HK_UP: alternate = vbKeyW
            Case HK_DOWN: alternate = vbKeyS
            Case HK_LEFT: alternate = vbKeyA
            Case HK_RIGHT: alternate = vbKeyD
            Case HK_PICKUP: alternate = vbKeyE
        End Select
        If alternate <> 0 Then GameKeyDown = GameKeyDown Or GetAsyncKeyState(alternate) < 0
    End If
End Function

Public Function KeyChatEnabled() As Boolean
    If Not mLoaded Then LoadHotkeys
    KeyChatEnabled = CustomHotkeys Or GameData.WASD <> 0
End Function

Public Sub ReleaseGameKeys()
    DirUp = False
    DirDown = False
    DirLeft = False
    DirRight = False
    ControlDown = False
    ShiftDown = False
End Sub
