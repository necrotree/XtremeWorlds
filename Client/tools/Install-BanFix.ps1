$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$server = [IO.Path]::GetFullPath((Join-Path $root '../Server'))
$staging = Join-Path $root 'ServerMigration'
Invoke-Expression (Get-Content (Join-Path $PSScriptRoot 'TwinContainer.ps1') -Raw)
$names = @('modDatabase.bas','modHandleData.bas')
$projectPath = Join-Path $server 'Server.twinproj'
$project = [TwinNode]::Load($projectPath)
$backup = Join-Path $server ('.ban-init-backup/' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
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
try {
    Copy-Item -LiteralPath (Join-Path $staging 'Server-WinDevLib.exe') -Destination $exe
} catch [System.IO.IOException] {
    $pending = Join-Path $server 'Server-WinDevLib-updated.exe'
    Copy-Item -LiteralPath (Join-Path $staging 'Server-WinDevLib.exe') -Destination $pending
    Write-Output "Running executable is locked; updated executable saved as $pending"
}
$installed = [TwinNode]::Load($projectPath)
foreach ($name in $names) {
    $expected = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $staging ('Sources/Src/' + $name))))
    if ([Convert]::ToBase64String($installed.Find('Sources/Src/' + $name).Data) -ne $expected) {
        throw "Embedded source verification failed: $name"
    }
}
Copy-Item -LiteralPath (Join-Path $staging 'BanTestRun/result.txt') -Destination (Join-Path $server 'BanInitialization-test-result.txt')
"Installed and verified ban initialization and persistence. Backup: $backup"
