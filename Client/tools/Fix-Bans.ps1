$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'TwinContainer.ps1')
$root = Split-Path $PSScriptRoot -Parent
$project = [TwinNode]::Load((Join-Path $root '../Server/Server.twinproj'))
$database = [Text.Encoding]::UTF8.GetString($project.Find('Sources/Src/modDatabase.bas').Data)
$replacement = @'
Sub BanIndex(ByVal BanPlayerIndex As Long, Optional BannedByIndex As String)
    Dim I As Long, BNum As Long
    BNum = -1
    For I = 0 To MAX_BANS
        If Len(Ban(I).BannedIP) = 0 And Len(Ban(I).BannedHD) = 0 Then
            BNum = I
            Exit For
        End If
    Next I
    If BNum < 0 Then
        If MAX_BANS = 32767 Then Err.Raise 6, "BanIndex", "The ban list is full."
        MAX_BANS = MAX_BANS + 1
        ReDim Preserve Ban(0 To MAX_BANS) As BanRec
        BNum = MAX_BANS
    End If
    Ban(BNum).BannedIP = GetPlayerIP(BanPlayerIndex)
    Ban(BNum).BannedChar = GetPlayerName(BanPlayerIndex)
    Ban(BNum).BannedBy = Trim$(BannedByIndex)
    Ban(BNum).BannedHD = GetPlayerHD(BanPlayerIndex)
    SaveBan BNum
End Sub
'@
$database = [regex]::Replace($database, '(?s)Sub BanIndex\(.*?End Sub', $replacement)
$replacement = @'
Sub UnBanIndex(ByVal BannedPlayerName As String, ByVal DeBannedByIndex As Long)
    Dim I As Long
    For I = 0 To MAX_BANS
        If Len(Ban(I).BannedChar) > 0 And LCase$(Ban(I).BannedChar) = LCase$(BannedPlayerName) Then
            Ban(I).BannedIP = vbNullString
            Ban(I).BannedChar = vbNullString
            Ban(I).BannedBy = vbNullString
            Ban(I).BannedHD = vbNullString
            SaveBan I
            Call GlobalMsg(BannedPlayerName & " has been unbanned from " & GAME_NAME & " by " & GetPlayerName(DeBannedByIndex) & "!", White)
            Call AddLog(GetPlayerName(DeBannedByIndex) & " has unbanned " & BannedPlayerName & ".", ADMIN_LOG)
            Exit Sub
        End If
    Next I
    Call PlayerMsg(DeBannedByIndex, "Player is not banned!", White)
End Sub
'@
$database = [regex]::Replace($database, '(?s)Sub UnBanIndex\(.*?End Sub', $replacement)
$replacement = @'
Private Function BanListFile() As String
    ' Keep legacy root-level lists usable; all operations resolve the same file.
    BanListFile = App.Path & "\data\banlist.ini"
    If Not FileExist(BanListFile, True) Then
        If FileExist(App.Path & "\banlist.ini", True) Then BanListFile = App.Path & "\banlist.ini"
    End If
End Function

Sub LoadBans()
    Dim FileName As String, total As String
    Dim I As Long, lastSlot As Double
    EnsureDataFolders App.Path
    FileName = BanListFile()
    total = Trim$(GetVar(FileName, "Total", "Total"))
    If Len(total) = 0 Then
        lastSlot = 0
    Else
        If Not IsNumeric(total) Then Err.Raise 13, "LoadBans", "Invalid ban list total: " & FileName
        lastSlot = CDbl(total)
        If lastSlot < 0 Or lastSlot > 32767 Or lastSlot <> Fix(lastSlot) Then Err.Raise 13, "LoadBans", "Invalid ban list total: " & FileName
    End If
    ' Total is the highest allocated slot, not the number of active bans.
    MAX_BANS = CLng(lastSlot)
    ReDim Ban(0 To MAX_BANS) As BanRec
    For I = 0 To MAX_BANS
        Ban(I).BannedIP = GetVar(FileName, "Ban" & I, "BannedIP")
        Ban(I).BannedChar = GetVar(FileName, "Ban" & I, "BannedChar")
        Ban(I).BannedBy = GetVar(FileName, "Ban" & I, "BannedBy")
        Ban(I).BannedHD = GetVar(FileName, "Ban" & I, "BannedHD")
    Next I
    If Len(total) = 0 Then PutVar FileName, "Total", "Total", CStr(MAX_BANS)
End Sub
'@
$database = [regex]::Replace($database, '(?s)Sub LoadBans\(\).*?End Sub', $replacement)
$replacement = @'
Sub SaveBan(ByVal BanNum As Long)
    Dim FileName As String
    FileName = BanListFile()
    Call PutVar(FileName, "Ban" & BanNum, "BannedIP", Ban(BanNum).BannedIP)
    Call PutVar(FileName, "Ban" & BanNum, "BannedChar", Ban(BanNum).BannedChar)
    Call PutVar(FileName, "Ban" & BanNum, "BannedBy", Ban(BanNum).BannedBy)
    Call PutVar(FileName, "Ban" & BanNum, "BannedHD", Ban(BanNum).BannedHD)
    Call PutVar(FileName, "Total", "Total", CStr(MAX_BANS))
End Sub
'@
$database = [regex]::Replace($database, '(?s)Sub SaveBan\(.*?End Sub', $replacement)
$handler = [Text.Encoding]::UTF8.GetString($project.Find('Sources/Src/modHandleData.bas').Data)
$handler = [regex]::Replace($handler, '(?s)For N = 0 To MAX_BANS.*?Next N', { param($m) $m.Value.Replace('Ban(I)', 'Ban(N)').Replace('SaveBan(I)', 'SaveBan(N)') })
foreach ($entry in @{ 'modDatabase.bas'=$database; 'modHandleData.bas'=$handler }.GetEnumerator()) {
    $bytes = [Text.Encoding]::UTF8.GetBytes(($entry.Value -replace '\r?\n', "`r`n"))
    [IO.File]::WriteAllBytes((Join-Path $root ('ServerMigration/Sources/Src/' + $entry.Key)), $bytes)
    $project.AddSource($entry.Key, $bytes)
}
$project.Save((Join-Path $root 'ServerMigration/Server.twinproj'))
