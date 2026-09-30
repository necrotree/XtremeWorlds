Attribute VB_Name = "modClassEditor"
Option Explicit
Public ClassEditorOpen As Boolean
Public InClassEditor As Boolean
Private ClassEditorRequested As Boolean

Public Sub RequestClassEditor()
    If Not InGame Or ClassEditorRequested Then Exit Sub
    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then Exit Sub
    If ClassEditorOpen Then
        frmClassEditor.Show
        Exit Sub
    End If
    ClassEditorRequested = True
    SendData "REQUESTEDITCLASS" & END_CHAR
End Sub

' Class packets share PlayerBuffer and are dispatched before the legacy handler.
Public Function HandleClassPacket(ByVal packet As String) As Boolean
    Dim parts() As String
    parts = Split(packet, SEP_CHAR)
    Select Case LCase$(parts(0))
        Case "classeditor", "editclass", "classsaved", "classerror", "newcharclasses", "classesdata"
            HandleClassPacket = True
        Case Else
            Exit Function
    End Select
    Select Case LCase$(parts(0))
        Case "classeditor": HandleClassIndex parts
        Case "editclass": HandleEditClass parts
        Case "classsaved"
            If UBound(parts) = 1 And ClassEditorOpen Then frmClassEditor.SaveComplete Val(parts(1))
        Case "classerror"
            ClassEditorRequested = False
            If UBound(parts) <> 1 Then Exit Function
            If ClassEditorOpen Then
                frmClassEditor.SaveFailed parts(1)
            Else
                GameMsgBox parts(1), vbExclamation, "Class Editor"
            End If
        Case "newcharclasses": HandleClasses parts, True
        Case "classesdata": HandleClasses parts, False
    End Select
End Function

Private Sub HandleClassIndex(ByRef parts() As String)
    Dim count As Long, I As Long, title As String
    If Not ClassEditorRequested Then Exit Sub
    ClassEditorRequested = False
    If UBound(parts) < 1 Then Exit Sub
    If Not ClassPacketInteger(parts(1), 1, 256, count) Then Exit Sub
    If UBound(parts) <> count + 1 Then Exit Sub
    MAX_CLASSES = count
    MaxClassIndex = count - 1
    ReDim Preserve Class(0 To MaxClassIndex) As ClassRec
    InClassEditor = True
    Load frmIndex
    frmIndex.Caption = "Class Editor"
    frmIndex.lstIndex.Clear
    For I = 0 To MaxClassIndex
        Class(I).Name = parts(I + 2)
        title = Trim$(Class(I).Name)
        If Len(title) = 0 Then title = "<Empty>"
        frmIndex.lstIndex.AddItem I & ": " & title
    Next I
    frmIndex.lstIndex.ListIndex = 0
    frmIndex.Show
End Sub

Private Sub HandleEditClass(ByRef parts() As String)
    Dim number As Long, I As Long, fields(0 To 5) As Long, upper As Long
    If Not ClassEditorRequested Then Exit Sub
    ClassEditorRequested = False
    If UBound(parts) <> 8 Then Exit Sub
    If Not ClassPacketInteger(parts(1), 0, MaxClassIndex, number) Then Exit Sub
    If number <> EditorIndex Then Exit Sub
    For I = 0 To 5
        upper = 255
        If I < 2 Then upper = 32767
        If Not ClassPacketInteger(parts(I + 3), 0, upper, fields(I)) Then Exit Sub
    Next I
    With Class(number)
        .Name = parts(2)
        .Sprite = fields(0): .FSprite = fields(1)
        .STR = fields(2): .DEF = fields(3): .speed = fields(4): .MAGI = fields(5)
    End With
    Load frmClassEditor
    frmClassEditor.LoadClass number
    frmClassEditor.Show
End Sub

Public Sub RequestEditClass(ByVal number As Long)
    If number < 0 Or number > MaxClassIndex Then Exit Sub
    EditorIndex = number
    InClassEditor = False
    ClassEditorRequested = True
    SendData "EDITCLASS" & SEP_CHAR & number & END_CHAR
End Sub

Public Function ClassPacketInteger(ByVal text As String, ByVal minimum As Long, ByVal maximum As Long, ByRef result As Long) As Boolean
    Dim value As Double
    On Error GoTo InvalidValue
    If Len(text) = 0 Or Len(text) > 10 Then Exit Function
    If Not IsNumeric(text) Then Exit Function
    value = CDbl(text)
    If value <> Fix(value) Or value < minimum Or value > maximum Then Exit Function
    result = CLng(value)
    ClassPacketInteger = True
InvalidValue:
End Function

Private Sub HandleClasses(ByRef parts() As String, ByVal newCharacter As Boolean)
    Dim last As Long, width As Long, I As Long, n As Long
    If UBound(parts) < 1 Then Exit Sub
    If Not ClassPacketInteger(parts(1), 0, 255, last) Then Exit Sub
    width = 8
    If newCharacter Then width = 10
    ' These legacy packets include a trailing separator.
    If UBound(parts) <> 2 + (last + 1) * width Then Exit Sub
    MaxClassIndex = last
    MAX_CLASSES = last + 1
    ReDim Preserve Class(0 To last) As ClassRec
    n = 2
    For I = 0 To last
        With Class(I)
            .Name = parts(n)
            .HP = Val(parts(n + 1)): .MP = Val(parts(n + 2)): .SP = Val(parts(n + 3))
            .STR = Val(parts(n + 4)): .DEF = Val(parts(n + 5))
            .speed = Val(parts(n + 6)): .MAGI = Val(parts(n + 7))
            If newCharacter Then
                .Sprite = Val(parts(n + 8)): .FSprite = Val(parts(n + 9))
            End If
        End With
        n = n + width
    Next I
    If newCharacter Then ShowNewCharacterClasses
End Sub

Private Sub ShowNewCharacterClasses()
    Dim I As Long
    With frmMainMenu
        .HideMenuPanels
        .Visible = True
        frmSendGetData.Visible = False
        .cmbClass.Clear
        For I = 0 To MaxClassIndex
            If Len(Trim$(Class(I).Name)) > 0 Then
                .cmbClass.AddItem Trim$(Class(I).Name)
                .cmbClass.ItemData(.cmbClass.NewIndex) = I
            End If
        Next I
        .optMale.Value = True
        .optFemale.Value = False
        If .cmbClass.ListCount > 0 Then .cmbClass.ListIndex = 0
        .ShowClassSelection
    End With
End Sub

Public Function SelectedClassNumber() As Long
    SelectedClassNumber = -1
    With frmMainMenu.cmbClass
        If .ListIndex >= 0 Then SelectedClassNumber = .ItemData(.ListIndex)
    End With
End Function

Public Sub ResetClassEditorConnection()
    ClassEditorRequested = False
    InClassEditor = False
    If ClassEditorOpen Then frmClassEditor.SaveFailed "Disconnected. Reconnect and reopen the editor before saving."
End Sub