param(
    [ValidateSet("Windows","GTK","macOS")]
    [string]$UI = "Windows",
    [ValidateSet("Debug","Release")]
    [string]$Configuration = "Debug"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

switch ($UI) {
    "Windows" { $project = Join-Path $root "Platforms\Windows\Server.Windows.csproj" }
    "GTK"     { $project = Join-Path $root "Platforms\GTK\Server.GTK.csproj" }
    "macOS"   { $project = Join-Path $root "Platforms\macOS\Server.macOS.csproj" }
}

dotnet run --project $project -c $Configuration
