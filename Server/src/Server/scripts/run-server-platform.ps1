param(
    [ValidateSet("Windows", "GTK", "macOS")]
    [string]$UI = "Windows"
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
switch ($UI) {
    "Windows" { $project = Join-Path $root "Platforms/Windows/Server.Windows.csproj" }
    "GTK"     { $project = Join-Path $root "Platforms/GTK/Server.GTK.csproj" }
    "macOS"   { $project = Join-Path $root "Platforms/macOS/Server.macOS.csproj" }
}
Write-Host "Starting XtremeWorlds Server UI: $UI"
dotnet run --project $project
