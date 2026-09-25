$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'TwinContainer.ps1')
$root=Split-Path $PSScriptRoot -Parent
$tree=Join-Path $root 'ServerMigration'
$src=Join-Path $tree 'Sources/Src'
$types=Get-Content (Join-Path $src 'modTypes.bas') -Raw
$keep=@('PlayerInvRec','PlayerRec','TileRec','OldMapRec','MapRec','ClassRec','ItemRec','NpcRec','SignRec','QuestRec','TradeItemRec','ShopRec','SpellRec','GuildRec')
$lines=[Collections.Generic.List[string]]::new()
$lines.Add('Attribute VB_Name = "RecordIOTest"')
$lines.Add('Option Explicit')
$lines.Add('Private sequence As Long')
$main=[Collections.Generic.List[string]]::new()
$main.Add('Public Sub Main()')
$main.Add('    Dim stage As String, report As String, f As Integer')
$main.Add('    On Error GoTo Failed')
$main.Add('    MAX_GUILD_MEMBERS = 255: MAX_QUEST_PLAYERS = 255')
$main.Add('    stage = "Data directories": EnsureDataFolders App.Path & "\RecordIOFixtures\startup"')
foreach($type in [regex]::Matches($types,'(?ms)^Type (\w+)\r?\n(.*?)^End Type')) {
    $name=$type.Groups[1].Value
    if($name -notin $keep){continue}
    $main.Add("    stage = `"$name`": Test$name")
    $lines.Add("Private Sub Fill$name(ByRef value As $name)")
    $lines.Add('    Dim i0 As Long, i1 As Long')
    foreach($field in [regex]::Matches($type.Groups[2].Value,'(?m)^\s*(\w+)(?:\(([^)]*)\))?\s+As\s+(\w+)(?:\s*\*\s*(\w+))?\s*$')) {
        $property=$field.Groups[1].Value; $kind=$field.Groups[3].Value; $width=$field.Groups[4].Value
        $target="value.$property"; $loops=0
        if($field.Groups[2].Success){
            $dims=$field.Groups[2].Value
            if(-not $dims){$dims='1 To 255'; $lines.Add("    ReDim $target($dims) As String * $width")}
            $bounds=@($dims -split ',')
            for($d=$bounds.Count-1;$d -ge 0;$d--){$lines.Add("    For i$d = $($bounds[$d].Trim())")}
            $target+='('+((0..($bounds.Count-1)|ForEach-Object{"i$_"}) -join ', ')+')'; $loops=$bounds.Count
        }
        $lines.Add('    sequence = sequence + 1')
        if($kind -eq 'String'){$lines.Add("    $target = `"$property-`" & CStr(sequence)")}
        elseif($kind -eq 'Byte'){$lines.Add("    $target = sequence Mod 256")}
        elseif($kind -eq 'Integer'){$lines.Add("    $target = (sequence Mod 65536) - 32768")}
        elseif($kind -eq 'Long'){$lines.Add("    $target = sequence * 10001 - 123456")}
        else{$lines.Add("    Fill$kind $target")}
        for($d=0;$d -lt $loops;$d++){$lines.Add("    Next i$d")}
    }
    $lines.Add('End Sub')
    $lines.Add("Private Sub Test$name()")
    $lines.Add("    Dim original As $name, loaded As $name, f As Integer")
    $lines.Add('    Dim file As clsDataFile, path As String')
    $lines.Add("    Fill$name original")
    $lines.Add("    path = App.Path & `"\RecordIOFixtures\$name`"")
    $lines.Add('    f = FreeFile')
    $lines.Add('    Open path & ".legacy" For Binary As #f')
    $lines.Add('    Put #f, , original')
    $lines.Add('    Close #f')
    $lines.Add('    Set file = New clsDataFile')
    $lines.Add('    file.Load path & ".legacy"')
    $lines.Add("    Read$name file, loaded")
    $lines.Add('    file.RequireEnd')
    $lines.Add('    Set file = New clsDataFile')
    $lines.Add("    Write$name file, loaded")
    $lines.Add('    file.Save path & ".native"')
    $lines.Add("    Reset$name loaded")
    $lines.Add('    Set file = New clsDataFile')
    $lines.Add("    Write$name file, loaded")
    $lines.Add('    file.Save path & ".cleared"')
    $lines.Add('End Sub')
}
$main.Add('    stage = "Atomic save": TestFailedSave')
$main.Add('    stage = "Existing files and damaged data": TestExistingFiles')
$main.Add('    report = "PASS: native decoding/encoding and reset completed for all 14 record types; failed replacement preserves prior file."')
$main.Add('    GoTo Finished')
$main.Add('Failed:')
$main.Add('    report = "FAIL at " & stage & ": " & Err.Number & " " & Err.Description')
$main.Add('Finished:')
$main.Add('    f = FreeFile')
$main.Add('    Open App.Path & "\RecordIO-result.txt" For Output As #f')
$main.Add('    Print #f, report')
$main.Add('    Close #f')
$main.Add('End Sub')
$lines.AddRange($main)
$lines.Add(@'
Private Sub TestExistingFiles()
    Dim file As clsDataFile, guildValue As GuildRec, questValue As QuestRec, number As Long
    Set file = New clsDataFile
    file.Load App.Path & "\RecordIOFixtures\live-guild.gld"
    ReadGuildRec file, guildValue
    file.RequireEnd
    Set file = New clsDataFile
    WriteGuildRec file, guildValue
    file.Save App.Path & "\RecordIOFixtures\live-guild.roundtrip"
    Set file = New clsDataFile
    file.Load App.Path & "\RecordIOFixtures\live-quest.qst"
    ReadQuestRec file, questValue
    file.RequireEnd
    Set file = New clsDataFile
    WriteQuestRec file, questValue
    file.Save App.Path & "\RecordIOFixtures\live-quest.roundtrip"
    file.Load App.Path & "\RecordIOFixtures\truncated.gld"
    On Error Resume Next
    ReadGuildRec file, guildValue
    number = Err.Number
    Err.Clear
    On Error GoTo 0
    If number = 0 Then Err.Raise 5, , "Truncated record was accepted"
    file.Load App.Path & "\RecordIOFixtures\bad-header.gld"
    number = 0
    On Error Resume Next
    ReadGuildRec file, guildValue
    number = Err.Number
    Err.Clear
    On Error GoTo 0
    If number = 0 Then Err.Raise 5, , "Invalid array descriptor was accepted"
End Sub

Private Sub TestFailedSave()
    Dim path As String, handle As LongPtr, number As Long
    Dim file As clsDataFile
    path = App.Path & "\RecordIOFixtures\atomic.bin"
    Set file = New clsDataFile
    file.WriteLong 123
    file.Save path
    handle = WinDevLib.CreateFile(path, WinDevLib.GENERIC_READ, WinDevLib.FILE_SHARE_READ, ByVal vbNullPtr, WinDevLib.OPEN_EXISTING, 0, 0)
    If handle = -1 Then Err.Raise 5
    Set file = New clsDataFile
    file.WriteLong 456
    On Error Resume Next
    file.Save path
    number = Err.Number
    Err.Clear
    On Error GoTo 0
    WinDevLib.CloseHandle handle
    If number = 0 Then Err.Raise 5, , "Locked target unexpectedly replaced"
    file.Load path
    If file.ReadLong() <> 123 Then Err.Raise 5, , "Failed save damaged existing file"
End Sub
'@)
New-Item -ItemType Directory -Force (Join-Path $tree 'RecordIOFixtures') | Out-Null
New-Item -ItemType Directory -Force (Join-Path $tree 'RecordIOFixtures/startup') | Out-Null
$project=[TwinNode]::Load((Join-Path $tree 'Server.twinproj'))
$sources=$project.Find('Sources/Src')
$entries=@($sources.Children | Where-Object Name -in @('modTypes.bas','modConstants.bas','modRecordIO.bas','clsDataFile.twin'))
$sources.Children.Clear()
foreach($entry in $entries){$sources.Children.Add($entry)}
$project.AddSource('RecordIOTest.bas',[Text.Encoding]::UTF8.GetBytes(($lines -join "`r`n")))
$settings=[Text.Encoding]::UTF8.GetString($project.Find('Settings').Data)|ConvertFrom-Json
$settings.'project.name'='RecordIOTest'
$settings.'project.startupObject'='Sub Main'
$settings.'project.iconForm'=''
$settings.'project.buildPath'='${SourcePath}\RecordIOTest.exe'
$project.Replace('Settings',[Text.Encoding]::UTF8.GetBytes(($settings|ConvertTo-Json -Depth 40)))
$project.Save((Join-Path $tree 'RecordIOTest.twinproj'))
[IO.File]::WriteAllText((Join-Path $tree 'RecordIOTest.bas'),($lines -join "`r`n"))
