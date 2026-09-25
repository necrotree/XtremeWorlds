$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'TwinContainer.ps1')
$root = Split-Path $PSScriptRoot -Parent
$src = Join-Path $root 'ServerMigration/Sources/Src'
$project = [TwinNode]::Load((Join-Path $root '../Server/Server.twinproj'))
$source = [Text.Encoding]::UTF8.GetString($project.Find('Sources/Src/modDatabase.bas').Data)
$script:blockNumber=0
$source = [regex]::Replace($source,'(?ms)^\s*(\w+) = FreeFile\r?\n\s*Open ([^\r\n]+) For Binary As #?\1\r?\n(.*?)^\s*Close #\1', [Text.RegularExpressions.MatchEvaluator]{
    param($m)
    $script:blockNumber++
    $object='dataFile'+$script:blockNumber
    $lines=[Collections.Generic.List[string]]::new()
    $lines.Add("`r`n    Dim $object As clsDataFile")
    $lines.Add("    Set $object = New clsDataFile")
    $write=$m.Groups[3].Value -match '(?m)^\s*Put #'
    if(-not $write){$lines.Add("    $object.Load $($m.Groups[2].Value)")}
    foreach($entry in [regex]::Matches($m.Groups[3].Value,'(?m)^\s*(Get|Put) #\w+,\s*([^,]*),\s*(.*?)\s*$')) {
        $action=if($write){'Write'}else{'Read'}
        $value=$entry.Groups[3].Value.Trim()
        $position=$entry.Groups[2].Value.Trim()
        if($position){$lines.Add("    $object.Position = NAME_LENGTH")}
        if($value -match '\.(Login|Password)$' -or $value -eq 'RightPassword') {
            if($write){$lines.Add("    $object.WriteText $value, NAME_LENGTH")}
            else{$lines.Add("    $value = $object.ReadText(NAME_LENGTH)")}
        } else {
            $kind=if($value -match '^Player\('){'Player'}elseif($value -eq 'OldMap'){'OldMap'}elseif($value -eq 'NewMap'){'Map'}elseif($value -match '^(\w+)\('){$Matches[1]}else{throw "Unknown record: $value"}
            $lines.Add("    $action${kind}Rec $object, $value")
        }
    }
    if($write){$lines.Add("    $object.Save $($m.Groups[2].Value)")}
    elseif(-not ($m.Groups[3].Value -match 'RightPassword')){$lines.Add("    $object.RequireEnd")}
    return ($lines -join "`r`n")
})
if($source -match 'For Binary|\b(Get|Put) #'){ [IO.File]::WriteAllText((Join-Path $root 'ServerMigration/data-migration-debug.bas'),$source); throw 'An unconverted database binary operation remains.' }
# Remove the unused FreeFile acquisition in PasswordOK; remaining acquisitions serve text logs/lists.
$source=$source.Replace("    nFileNum = FreeFile`r`n",'')
$source=$source.Replace("        ' Delete the old file`r`n        Call Kill(FileName)", "        ' Keep the old file until the native writer replaces it successfully.`r`n        ResetMapRec NewMap")
[IO.File]::WriteAllText((Join-Path $src 'modDatabase.bas'),($source -replace '\r?\n',"`r`n"),(New-Object Text.UTF8Encoding($false)))
$logic=[Text.Encoding]::UTF8.GetString($project.Find('Sources/Src/modGameLogic.bas').Data)
foreach($kind in @('Item','Npc','Shop','Sign','Spell','Guild','Quest','Map')) {
    $index=if($kind -eq 'Map'){'MapNum'}else{'Index'}
    $body="Sub Clear$kind(ByVal $index As Long)`r`n    Reset${kind}Rec $kind($index)`r`n"
    if($kind -eq 'Map'){$body+='    PlayersOnMap(MapNum) = NO'+"`r`n"}
    $body+='End Sub'
    $logic=[regex]::Replace($logic,('(?s)Sub Clear'+$kind+'\(ByVal .*?End Sub'),[Text.RegularExpressions.MatchEvaluator]{param($m) $body})
}
$logic=[regex]::Replace($logic,'(?s)Sub ClearClasses\(\).*?End Sub',@'
Sub ClearClasses()
    Dim I As Long
    ReDim Class(0 To Max_Classes) As ClassRec
    For I = 0 To Max_Classes
        ResetClassRec Class(I)
    Next I
End Sub
'@)
$logic=[regex]::Replace($logic,'(?s)Sub ClearChar\(ByVal .*?End Sub',@'
Sub ClearChar(ByVal Index As Long, ByVal CharNum As Long)
    ResetPlayerRec Player(Index).Char(CharNum)
End Sub
'@)
$logic=[regex]::Replace($logic,'(?s)Sub ClearPlayer\(ByVal .*?End Sub',@'
Sub ClearPlayer(ByVal Index As Long)
    Dim I As Long
    Player(Index).Login = vbNullString
    Player(Index).Password = vbNullString
    Player(Index).EncKey = vbNullString
    For I = 0 To MAX_CHARS
        ResetPlayerRec Player(Index).Char(I)
    Next I
    Player(Index).Buffer = vbNullString
    Player(Index).IncBuffer = vbNullString
    Player(Index).CharNum = 0
    Player(Index).InGame = False
    Player(Index).AttackTimer = 0
    Player(Index).DataTimer = 0
    Player(Index).DataBytes = 0
    Player(Index).DataPackets = 0
    Player(Index).PartyPlayer = 0
    Player(Index).InParty = 0
    Player(Index).TargetType = 0
    Player(Index).Target = 0
    Player(Index).CastedSpell = 0
    Player(Index).PartyStarter = 0
    Player(Index).GettingMap = 0
    Player(Index).HDSerial = vbNullString
    Player(Index).WarpTick = 0
End Sub
'@)
[IO.File]::WriteAllText((Join-Path $src 'modGameLogic.bas'),($logic -replace '\r?\n',"`r`n"),(New-Object Text.UTF8Encoding($false)))
$general=[Text.Encoding]::UTF8.GetString($project.Find('Sources/Src/modGeneral.bas').Data)
$general=[regex]::Replace($general,"(?s)    ' Check if the maps directory.*?(?=    SEP_CHAR =)","    EnsureDataFolders App.Path`r`n`r`n")
[IO.File]::WriteAllText((Join-Path $src 'modGeneral.bas'),($general -replace '\r?\n',"`r`n"),(New-Object Text.UTF8Encoding($false)))
foreach($name in @('modDatabase.bas','modGameLogic.bas','modGeneral.bas','modRecordIO.bas','clsDataFile.twin')){
    $project.AddSource($name,[IO.File]::ReadAllBytes((Join-Path $src $name)))
}
$project.Save((Join-Path $root 'ServerMigration/Server.twinproj'))
"Converted $script:blockNumber binary file operations and complete record resets."
