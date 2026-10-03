$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$badNested = Join-Path $root "src\Server\src"
if (Test-Path $badNested) {
    Write-Host "Removing accidental nested source tree: $badNested"
    Remove-Item -Recurse -Force $badNested
}

Get-ChildItem $root -Directory -Recurse -Force |
    Where-Object { $_.Name -in @("bin","obj") } |
    Sort-Object FullName -Descending |
    ForEach-Object { Remove-Item -Recurse -Force $_.FullName }

Write-Host "Clean complete."
