Attribute VB_Name = "modClassEditor"
Option Explicit

Private Sub ClassEditorError(ByVal Index As Long, ByVal message As String)
    SendDataTo Index, "CLASS_EDIT_ERROR" & SEP_CHAR & message & END_CHAR
End Sub

Private Sub SendClassEditor(ByVal Index As Long)
    Dim packet As String, i As Long
    packet = "CLASS_EDIT_DATA" & SEP_CHAR & Max_Classes
    For i = 0 To Max_Classes
        With Class(i)
            packet = packet & SEP_CHAR & Trim$(.Name) & SEP_CHAR & .Sprite & SEP_CHAR & .FSprite & SEP_CHAR & .STR & SEP_CHAR & .DEF & SEP_CHAR & .SPEED & SEP_CHAR & .MAGI
        End With
    Next i
    SendDataTo Index, packet & END_CHAR
End Sub

Public Function HandleClassEditorPacket(ByVal Index As Long, ByRef parts() As String) As Boolean
    Dim command As String, i As Long, number As Long, upper As Long, value As Double
    Dim values(0 To 5) As Long, className As String, oldClass As ClassRec, appended As Boolean
    command = LCase$(parts(0))
    If command <> "requesteditclass" And command <> "saveclass" Then Exit Function
    HandleClassEditorPacket = True
    If Not IsPlaying(Index) Or GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
        ClassEditorError Index, "Developer access is required."
        Exit Function
    End If
    If command = "requesteditclass" Then
        SendClassEditor Index
        Exit Function
    End If
    On Error GoTo InvalidPacket
    If UBound(parts) <> 8 Then GoTo InvalidPacket
    If Not IsNumeric(parts(1)) Then GoTo InvalidPacket
    value = CDbl(parts(1))
    If value <> Fix(value) Or value < 0 Or value > Max_Classes + 1 Or value > 255 Then GoTo InvalidPacket
    number = CLng(value)
    className = Trim$(parts(2))
    If Len(className) < 1 Or Len(className) > NAME_LENGTH Then GoTo InvalidPacket
    For i = 1 To Len(className)
        If AscW(Mid$(className, i, 1)) < 32 Or AscW(Mid$(className, i, 1)) > 126 Then GoTo InvalidPacket
    Next i
    For i = 0 To 5
        If Not IsNumeric(parts(i + 3)) Then GoTo InvalidPacket
        value = CDbl(parts(i + 3))
        upper = 255
        If i < 2 Then upper = 32767
        If value <> Fix(value) Or value < 0 Or value > upper Then GoTo InvalidPacket
        values(i) = CLng(value)
    Next i
    For i = 0 To Max_Classes
        If i <> number And StrComp(Trim$(Class(i).Name), className, vbTextCompare) = 0 Then
            ClassEditorError Index, "A class with that name already exists."
            Exit Function
        End If
    Next i
    appended = (number = Max_Classes + 1)
    If appended Then
        Max_Classes = Max_Classes + 1
        ReDim Preserve Class(0 To Max_Classes) As ClassRec
    Else
        oldClass = Class(number)
    End If
    With Class(number)
        .Name = className
        .Sprite = values(0): .FSprite = values(1)
        .STR = values(2): .DEF = values(3): .SPEED = values(4): .MAGI = values(5)
    End With
    On Error GoTo SaveFailed
    SaveClasses
    On Error GoTo 0
    For i = 1 To HighIndex
        If IsPlaying(i) Then SendClasses i
    Next i
    SendClassEditor Index
    SendDataTo Index, "CLASS_EDIT_SAVED" & END_CHAR
    Exit Function
InvalidPacket:
    ClassEditorError Index, "Invalid class data. Sprites must be 0-32767 and stats 0-255."
    Exit Function
SaveFailed:
    If appended Then
        Max_Classes = Max_Classes - 1
        ReDim Preserve Class(0 To Max_Classes) As ClassRec
    Else
        Class(number) = oldClass
    End If
    ClassEditorError Index, "Class could not be saved. Check server data-file permissions."
End Function
