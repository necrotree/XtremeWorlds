$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$server = [IO.Path]::GetFullPath((Join-Path $root '../Server'))
$staging = Join-Path $root 'ServerMigration'
if (-not (Test-Path (Join-Path $server 'Server.twinproj'))) { throw 'Server project missing.' }
$backup = Join-Path $server ('.putvar-backup/' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force $backup | Out-Null
Copy-Item -LiteralPath (Join-Path $server 'Server.twinproj') -Destination (Join-Path $backup 'Server.twinproj')
$sourcePath = Join-Path $server 'Src/modDatabase.bas'
Copy-Item -LiteralPath $sourcePath -Destination (Join-Path $backup 'modDatabase.bas')
$source = [IO.File]::ReadAllText($sourcePath) -replace '\r?\n', "`r`n"
if ($source -notmatch 'First startup reaches here') {
    $before = '    If Not FileExist("data\classes.ini") Then' + "`r`n" + '        Call SaveClasses'
    $after = '    If Not FileExist("data\classes.ini") Then' + "`r`n" + "        ' First startup reaches here before LoadClasses allocates the array.`r`n" + '        ReDim Class(0 To Max_Classes) As ClassRec' + "`r`n" + '        Call ClearClasses' + "`r`n" + '        Call SaveClasses'
    if (-not $source.Contains($before)) { throw 'CheckClasses differs from the reviewed source.' }
    $source = $source.Replace($before, $after)
    $before = '    FileName = App.Path & "\data\classes.ini"' + "`r`n`r`n" + '    For I = 0 To Max_Classes'
    $after = '    FileName = App.Path & "\data\classes.ini"' + "`r`n`r`n" + '    Call PutVar(FileName, "INIT", "MaxClasses", CStr(Max_Classes))' + "`r`n`r`n" + '    For I = 0 To Max_Classes'
    if (-not $source.Contains($before)) { throw 'SaveClasses differs from the reviewed source.' }
    $source = $source.Replace($before, $after)
    [IO.File]::WriteAllText($sourcePath, $source, (New-Object Text.UTF8Encoding($false)))
}
Copy-Item -LiteralPath (Join-Path $staging 'Server.twinproj') -Destination (Join-Path $server 'Server.twinproj')
Copy-Item -LiteralPath (Join-Path $staging 'Server-WinDevLib.exe') -Destination (Join-Path $server 'Server-WinDevLib.exe')
Copy-Item -LiteralPath (Join-Path $staging 'IniSmoke-result.txt') -Destination (Join-Path $server 'ClassInitialization-test-result.txt')
"Installed class initialization fix. Backup: $backup"
