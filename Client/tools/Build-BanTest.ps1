$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'TwinContainer.ps1')
$root=Split-Path $PSScriptRoot -Parent
$tree=Join-Path $root 'ServerMigration'
$project=[TwinNode]::Load((Join-Path $tree 'Server.twinproj'))
$settings=[Text.Encoding]::UTF8.GetString($project.Find('Settings').Data) | ConvertFrom-Json
$settings.'project.name'='BanTest'
$settings.'project.startupObject'='Sub Main'
$settings.'project.iconForm'=''
$settings.'project.buildPath'='${SourcePath}\BanTestRun\BanTest.exe'
$project.Replace('Settings',[Text.Encoding]::UTF8.GetBytes(($settings | ConvertTo-Json -Depth 40)))
$database=[Text.Encoding]::UTF8.GetString($project.Find('Sources/Src/modDatabase.bas').Data)
$types=[Text.Encoding]::UTF8.GetString($project.Find('Sources/Src/modTypes.bas').Data)
$declares=[Text.Encoding]::UTF8.GetString($project.Find('Sources/Src/modDeclares.bas').Data)
$io=[Text.Encoding]::UTF8.GetString($project.Find('Sources/Src/modRecordIO.bas').Data)
$project.Find('Sources/Src').Children.Clear()
$code="Attribute VB_Name = `"BanTest`"`r`nOption Explicit`r`nPublic MAX_BANS As Integer`r`nPublic Ban() As BanRec`r`nPrivate Const GAME_NAME = `"Test`"`r`nPrivate Const White = 0`r`nPrivate Const ADMIN_LOG = `"Test`"`r`n"
$code += [regex]::Match($types,'(?s)Type BanRec\r?\n.*?End Type').Value + "`r`n"
$code += ([regex]::Matches($declares,'(?m)^Declare Function (Write|Get)PrivateProfileString.*$') | ForEach-Object Value) -join "`r`n"
foreach($name in @('GetVar','PutVar','FileExist','BanListFile','LoadBans','SaveBan','BanIndex','UnBanIndex')) {
    $code += "`r`n" + [regex]::Match($database,"(?ms)^(?:(?:Public|Private) )?(?:Sub|Function) $name\(.*?^End (?:Sub|Function)").Value
}
$code += "`r`n" + [regex]::Match($io,'(?s)Public Sub EnsureDataFolders\(.*?End Sub').Value
$code += @'

Private Function GetPlayerIP(ByVal index As Long) As String
    GetPlayerIP = "192.0.2." & index
End Function
Private Function GetPlayerName(ByVal index As Long) As String
    GetPlayerName = "Player" & index
End Function
Private Function GetPlayerHD(ByVal index As Long) As String
    GetPlayerHD = "Disk" & index
End Function
Private Sub GlobalMsg(ByVal message As String, ByVal color As Long)
End Sub
Private Sub PlayerMsg(ByVal index As Long, ByVal message As String, ByVal color As Long)
End Sub
Private Sub AddLog(ByVal message As String, ByVal filename As String)
End Sub
Private Sub Require(ByVal condition As Boolean, ByVal message As String)
    If Not condition Then Err.Raise 5, "BanTest", message
End Sub
Public Sub Main()
    Dim report As String, f As Integer, path As String, legacy As String
    On Error GoTo Failed
    path = App.Path & "\data\banlist.ini"
    legacy = App.Path & "\banlist.ini"
    Require Not FileExist(path, True) And Not FileExist(legacy, True), "Fresh isolated test directory required"
    LoadBans
    Require MAX_BANS = 0 And UBound(Ban) = 0, "Empty list allocation"
    Require GetVar(path, "Total", "Total") = "0", "Missing file initialized"
    BanIndex 1, "Admin"
    BanIndex 2, "Admin"
    BanIndex 3, "Admin"
    Erase Ban
    LoadBans
    Require MAX_BANS = 2, "List grows without dropping entries"
    Require Ban(0).BannedIP = "192.0.2.1" And Ban(2).BannedChar = "Player3", "First and last bans reload"
    Require Ban(1).BannedBy = "Admin" And Ban(1).BannedHD = "Disk2", "All ban fields reload"
    UnBanIndex "Player2", 9
    LoadBans
    Require Ban(1).BannedIP = "" And Ban(2).BannedChar = "Player3", "Unban preserves other slots"
    BanIndex 4, "OtherAdmin"
    LoadBans
    Require MAX_BANS = 2 And Ban(1).BannedChar = "Player4", "Vacant slot reused"
    Name path As legacy
    LoadBans
    Require Ban(2).BannedChar = "Player3", "Legacy root list loads"
    BanIndex 5, "Admin"
    LoadBans
    Require Ban(3).BannedChar = "Player5" And Not FileExist(path, True), "Legacy saves use same path"
    report = "PASS: first-run initialization, array growth, all fields persisted, unban, slot reuse, legacy path and restart reload."
    GoTo Finished
Failed:
    report = "FAIL: " & Err.Number & " " & Err.Description
Finished:
    f = FreeFile
    Open App.Path & "\result.txt" For Output As #f
    Print #f, report
    Close #f
End Sub
'@
$project.AddSource('BanTest.bas',[Text.Encoding]::UTF8.GetBytes(($code -replace '\r?\n',"`r`n")))
New-Item -ItemType Directory -Force (Join-Path $tree 'BanTestRun') | Out-Null
$project.Save((Join-Path $tree 'BanTest.twinproj'))
$path=(Join-Path $tree 'BanTest.twinproj') | ConvertTo-Json -Compress
[IO.File]::WriteAllText((Join-Path $root 'tools/load-ban-test.js'),"closeProjectNow(() => root.loadProject($path, undefined, false));")
