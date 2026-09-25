Attribute VB_Name = "GuildSmoke"
Option Explicit
Private Type GuildRec
    Name As String * 50
    Founder As String * 50
    Abbreviation As String * 10
    Member() As String * 50
End Type
Public Sub Main()
    Dim guild As GuildRec
    Dim dimensions As Integer, count As Long, lower As Long, i As Long
    Dim member As String * 50
    Dim f As Integer
    Dim result As String
    On Error GoTo Failed
    ReDim guild.Member(1 To 255) As String * 50
    f = FreeFile
    Open App.Path & "\GuildSmoke-fixture.gld" For Binary Access Read As #f
    Get #f, , guild.Name
    Get #f, , guild.Founder
    Get #f, , guild.Abbreviation
    Get #f, , dimensions
    Get #f, , count
    Get #f, , lower
    For i = 1 To count
        Get #f, , member
        guild.Member(i) = member
    Next i
    Close #f
    result = "PASS: original guild loader"
    GoTo Finished
Failed:
    result = "FAIL: " & Err.Number & " " & Err.Description
    Close #f
Finished:
    f = FreeFile
    Open App.Path & "\GuildSmoke-result.txt" For Output As #f
    Print #f, result
    Close #f
End Sub
