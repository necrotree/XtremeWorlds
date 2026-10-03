$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$targets = @(
    (Join-Path $root "src\Server\src"),
    (Join-Path $root "src\src")
)

foreach ($target in $targets) {
    if (Test-Path $target) {
        Write-Host "Removing duplicate source tree: $target"
        Remove-Item -Recurse -Force $target
    }
}

Get-ChildItem $root -Directory -Recurse -Force |
    Where-Object { $_.Name -in @("bin","obj") } |
    Sort-Object FullName -Descending |
    ForEach-Object { Remove-Item -Recurse -Force $_.FullName }

Write-Host "Duplicate source/build cleanup complete."
