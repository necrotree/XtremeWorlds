Attribute VB_Name = "modClassEditor"
Option Explicit

' Called for a complete packet by the shared TCP receive buffer.
Public Function HandleClassPacket(ByVal Index As Long, ByVal packet As String) As Boolean
    Dim parts() As String, command As String
    parts = Split(packet, SEP_CHAR)
    command = LCase$(parts(0))
    Select Case command
        Case "requesteditclass", "editclass", "saveclass"
            HandleClassPacket = True
        Case Else
            Exit Function
    End Select
    If Not IsPlaying(Index) Then Exit Function
    If GetPlayerAccess(Index) < ADMIN_DEVELOPER Then
        SendClassError Index, "Developer access is required."
        Exit Function
    End If
    Select Case command
        Case "requesteditclass": SendClassEditor Index
        Case "editclass": HandleEditClass Index, parts
        Case "saveclass": HandleSaveClass Index, parts
    End Select
End Function

Private Sub SendClassError(ByVal Index As Long, ByVal message As String)
    SendDataTo Index, "CLASSERROR" & SEP_CHAR & message & END_CHAR
End Sub

Private Sub SendClassEditor(ByVal Index As Long)
    Dim packet As String, I As Long
    packet = "CLASSEDITOR" & SEP_CHAR & MAX_CLASSES
    For I = 0 To MaxClassIndex
        packet = packet & SEP_CHAR & Trim$(Class(I).Name)
    Next I
    SendDataTo Index, packet & END_CHAR
End Sub

Private Sub HandleEditClass(ByVal Index As Long, ByRef parts() As String)
    Dim number As Long
    If UBound(parts) <> 1 Then Exit Sub
    If Not ClassPacketInteger(parts(1), 0, MaxClassIndex, number) Then Exit Sub
    With Class(number)
        SendDataTo Index, "EDITCLASS" & SEP_CHAR & number & SEP_CHAR & Trim$(.Name) & SEP_CHAR & .Sprite & SEP_CHAR & .FSprite & SEP_CHAR & .STR & SEP_CHAR & .DEF & SEP_CHAR & .SPEED & SEP_CHAR & .MAGI & END_CHAR
    End With
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

Private Function ReadClassPacket(ByRef parts() As String, ByRef number As Long, ByRef value As ClassRec) As Boolean
    Dim I As Long, fields(0 To 5) As Long, upper As Long, className As String
    If UBound(parts) <> 8 Then Exit Function
    If Not ClassPacketInteger(parts(1), 0, MaxClassIndex, number) Then Exit Function
    className = Trim$(parts(2))
    If Len(className) < 1 Or Len(className) > NAME_LENGTH Then Exit Function
    For I = 1 To Len(className)
        If AscW(Mid$(className, I, 1)) < 32 Or AscW(Mid$(className, I, 1)) > 126 Then Exit Function
    Next I
    For I = 0 To 5
        upper = 255
        If I < 2 Then upper = 32767
        If Not ClassPacketInteger(parts(I + 3), 0, upper, fields(I)) Then Exit Function
    Next I
    value.Name = className
    value.Sprite = fields(0): value.FSprite = fields(1)
    value.STR = fields(2): value.DEF = fields(3)
    value.SPEED = fields(4): value.MAGI = fields(5)
    ReadClassPacket = True
End Function

Private Sub HandleSaveClass(ByVal Index As Long, ByRef parts() As String)
    Dim number As Long, I As Long, updated As ClassRec, previous As ClassRec
    If Not ReadClassPacket(parts, number, updated) Then
        SendClassError Index, "Invalid class: enter a name, sprites 0-32767, and stats 0-255."
        Exit Sub
    End If
    For I = 0 To MaxClassIndex
        If I <> number And StrComp(Trim$(Class(I).Name), Trim$(updated.Name), vbTextCompare) = 0 Then
            SendClassError Index, "A class with that name already exists."
            Exit Sub
        End If
    Next I
    previous = Class(number)
    Class(number) = updated
    On Error GoTo SaveFailed
    SaveClass number
    On Error GoTo 0
    SendDataTo Index, "CLASSSAVED" & SEP_CHAR & number & END_CHAR
    For I = 1 To HighIndex
        If IsPlaying(I) Then SendClasses I
    Next I
    AddLog GetPlayerName(Index) & " saved class #" & number, ADMIN_LOG
    Exit Sub
SaveFailed:
    Class(number) = previous
    SendClassError Index, "Class could not be saved. Check the server class folder permissions."
End Sub
Public Function ClassAvailable(ByVal number As Long) As Boolean
    If number < 0 Or number > MaxClassIndex Then Exit Function
    ClassAvailable = (Len(Trim$(Class(number).Name)) > 0)
End Function
