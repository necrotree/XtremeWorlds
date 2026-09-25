$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$path = Join-Path $root 'ServerMigration/Sources/Src/modDatabase.bas'
$source = [IO.File]::ReadAllText($path)
foreach ($kind in @('Guild','Quest')) {
    if ($kind -eq 'Guild') {
        $folder='guilds'; $extension='gld'; $array='Member'; $maximum='MAX_GUILD_MEMBERS'; $header=110
        $readFields = "    Get #f, , Guild(GuildNum).Name`r`n    Get #f, , Guild(GuildNum).Founder`r`n    Get #f, , Guild(GuildNum).Abbreviation"
        $writeFields = $readFields.Replace('Get #f', 'Put #f')
    } else {
        $folder='quests'; $extension='qst'; $array='Player'; $maximum='MAX_QUEST_PLAYERS'; $header=255
        $readFields = '    Get #f, , Quest(QuestNum).Name'
        $writeFields = $readFields.Replace('Get #f', 'Put #f')
    }
    $index = $kind + 'Num'
    $record = "$kind($index)"
    $filename = 'App.Path & "\data\' + $folder + '\' + $kind.ToLower() + '" & ' + $index + ' & ".' + $extension + '"'
    $save = @"
Sub Save$kind(ByVal $index As Long)
    Dim FileName As String, memberName As String * NAME_LENGTH
    Dim f As Integer, I As Long, count As Long, dimensions As Integer, lower As Long
    Dim errorNumber As Long, errorText As String
    FileName = $filename
    On Error GoTo Failed
    lower = LBound($record.$array)
    count = UBound($record.$array) - lower + 1
    dimensions = 1
    f = FreeFile
    Open FileName For Binary Access Write As #f
$writeFields
    ' Preserve the VB6 dynamic-array descriptor and ANSI fixed-width strings.
    Put #f, , dimensions
    Put #f, , count
    Put #f, , lower
    For I = lower To lower + count - 1
        memberName = $record.$array(I)
        Put #f, , memberName
    Next I
    Close #f
    Exit Sub
Failed:
    errorNumber = Err.Number
    errorText = Err.Description
    On Error Resume Next
    If f <> 0 Then Close #f
    On Error GoTo 0
    Err.Raise errorNumber, "Save$kind", FileName & ": " & errorText
End Sub

Sub Load$kind(ByVal $index As Long)
    Dim FileName As String, memberName As String * NAME_LENGTH
    Dim f As Integer, I As Long, count As Long, capacity As Long
    Dim errorNumber As Long, errorText As String
    FileName = $filename
    On Error GoTo Failed
    f = FreeFile
    Open FileName For Binary Access Read As #f
    ' Validate before reading any fixed-width fields or allocating an array.
    If LOF(f) < $header + 10 Then Err.Raise 62, "Load$kind", "Truncated record header"
$readFields
    count = ReadStoredNameCount(f, $header)
    capacity = $maximum
    If count > capacity Then capacity = count
    ReDim $record.$array(1 To capacity) As String * NAME_LENGTH
    For I = 1 To capacity
        $record.$array(I) = vbNullString
    Next I
    For I = 1 To count
        Get #f, , memberName
        $record.$array(I) = memberName
    Next I
    Close #f
    Exit Sub
Failed:
    errorNumber = Err.Number
    errorText = Err.Description
    On Error Resume Next
    If f <> 0 Then Close #f
    On Error GoTo 0
    Err.Raise errorNumber, "Load$kind", FileName & ": " & errorText
End Sub
"@
    $source = [regex]::Replace($source, ('(?s)Sub Save' + $kind + '\(ByVal .*?End Sub'), [Text.RegularExpressions.MatchEvaluator]{ param($m) $save })
    $read = '        f = FreeFile' + "`r`n" + '        Open FileName For Binary As #f' + "`r`n" + "        Get #f, , $kind(I)" + "`r`n" + '        Close #f'
    if (-not $source.Contains($read)) { throw "Original $kind read not found." }
    $source = $source.Replace($read, "        Call Load$kind(I)")
}
$source += @'

' Dynamic arrays in VB6 binary records have a 2-byte dimension count followed
' by a 4-byte element count and a 4-byte lower bound for each dimension.
Private Function ReadStoredNameCount(ByVal f As Integer, ByVal headerBytes As Long) As Long
    Dim dimensions As Integer, count As Long, lower As Long
    Get #f, , dimensions
    Get #f, , count
    Get #f, , lower
    If dimensions <> 1 Or lower <> 1 Or count < 1 Or count > 32767 Then
        Err.Raise 5, "ReadStoredNameCount", "Invalid member/player array descriptor"
    End If
    If count > (LOF(f) - headerBytes - 10) \ NAME_LENGTH Then
        Err.Raise 62, "ReadStoredNameCount", "Truncated member/player list"
    End If
    ReadStoredNameCount = count
End Function
'@
$source = $source.Replace(') \ NAME_LENGTH', ') \ NAME_LENGTH')
[IO.File]::WriteAllText($path, ($source -replace '\r?\n', "`r`n"), (New-Object Text.UTF8Encoding($false)))
