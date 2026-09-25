$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$server = [IO.Path]::GetFullPath((Join-Path $root '../Server'))
$staging = Join-Path $root 'ServerMigration'
Invoke-Expression (Get-Content (Join-Path $PSScriptRoot 'TwinContainer.ps1') -Raw)
$names = @('modDatabase.bas','modGameLogic.bas','modGeneral.bas','modRecordIO.bas','clsDataFile.twin')
$projectPath = Join-Path $server 'Server.twinproj'
$project = [TwinNode]::Load($projectPath)
$backup = Join-Path $server ('.native-data-backup/' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force $backup | Out-Null
Copy-Item -LiteralPath $projectPath -Destination (Join-Path $backup 'Server.twinproj')
foreach ($name in $names) {
    $destination = Join-Path $server ('Src/' + $name)
    if (Test-Path -LiteralPath $destination) {
        Copy-Item -LiteralPath $destination -Destination (Join-Path $backup $name)
    }
    $source = Join-Path $staging ('Sources/Src/' + $name)
    $project.AddSource($name, [IO.File]::ReadAllBytes($source))
    Copy-Item -LiteralPath $source -Destination $destination
}
$exe = Join-Path $server 'Server-WinDevLib.exe'
if (Test-Path -LiteralPath $exe) {
    Copy-Item -LiteralPath $exe -Destination (Join-Path $backup 'Server-WinDevLib.exe')
}
$project.Save($projectPath)
Copy-Item -LiteralPath (Join-Path $staging 'Server-WinDevLib.exe') -Destination $exe
$installed = [TwinNode]::Load($projectPath)
foreach ($name in $names) {
    $expected = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $staging ('Sources/Src/' + $name))))
    if ([Convert]::ToBase64String($installed.Find('Sources/Src/' + $name).Data) -ne $expected) {
        throw "Embedded source verification failed: $name"
    }
}
Copy-Item -LiteralPath (Join-Path $staging 'RecordIO-result.txt') -Destination (Join-Path $server 'NativeData-test-result.txt')
"Installed and verified native record IO. Backup: $backup"
