$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$serverSrc = Join-Path $root 'src\Server'
$nested = Join-Path $serverSrc 'src'
if (Test-Path $nested) {
    Write-Host "Removing accidental nested source tree: $nested"
    Remove-Item -Recurse -Force $nested
}
Get-ChildItem -Path $root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -in @('bin','obj') } |
    Sort-Object FullName -Descending |
    ForEach-Object { Remove-Item -Recurse -Force $_.FullName -ErrorAction SilentlyContinue }
Write-Host 'Duplicate source/build cleanup complete.'
