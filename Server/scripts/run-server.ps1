$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
dotnet run --project (Join-Path $root 'Platforms\Windows\Server.Windows.csproj')
