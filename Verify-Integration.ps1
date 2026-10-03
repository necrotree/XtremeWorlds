$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$client = Join-Path $root 'Client'
$server = Join-Path $root 'Server'
$required = @(
  (Join-Path $client 'Core/Client.Common.vbproj'),
  (Join-Path $client 'Platforms/Windows/Client.Windows.csproj'),
  (Join-Path $client 'Platforms/Linux/Client.Linux.vbproj'),
  (Join-Path $client 'Platforms/macOS/Client.macOS.vbproj'),
  (Join-Path $server 'src/Server/ServerHost.cs'),
  (Join-Path $server 'Platforms/Windows/Server.Windows.csproj')
)
foreach ($path in $required) {
  if (-not (Test-Path $path)) { throw "Missing integration file: $path" }
}
$hostText = Get-Content (Join-Path $server 'src/Server/ServerHost.cs') -Raw
if ($hostText -notmatch 'ConfigureSpacetimeDatabaseAuthorizationAsync') {
  throw 'SpacetimeDB authorization helper is missing.'
}
Write-Host 'Integrated Eto client/server source tree verified.' -ForegroundColor Green
