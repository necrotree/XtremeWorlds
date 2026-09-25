param([switch]$SmokeTest)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'TwinContainer.ps1')
$root = Split-Path $PSScriptRoot -Parent
$tree = Join-Path $root 'ServerMigration'
$project = [TwinNode]::Load((Join-Path $root '../Server/Server.twinproj'))
$client = [TwinNode]::Load((Join-Path $root 'Playerworlds.twinproj'))
$packages = $project.Find('Packages')
if (-not ($packages.Children | Where-Object Name -eq 'WinDevLib')) { $packages.Children.Add($client.Find('Packages/WinDevLib')) }
$settings = Get-Content (Join-Path $tree 'Settings') -Raw | ConvertFrom-Json
$clientSettings = [Text.Encoding]::UTF8.GetString($client.Find('Settings').Data) | ConvertFrom-Json
$settings.'project.references' = @($settings.'project.references' | Where-Object { $_.symbolId -ne 'WinDevLib' }) + @($clientSettings.'project.references' | Where-Object symbolId -eq 'WinDevLib')
$settings.'project.buildPath' = '${SourcePath}\Server-WinDevLib.exe'
foreach ($file in Get-ChildItem (Join-Path $tree 'Sources/Src') -File) {
    $text = [IO.File]::ReadAllText($file.FullName) -replace '\r?\n', "`r`n"
    $project.AddSource($file.Name, [Text.Encoding]::UTF8.GetBytes($text))
}
$output = Join-Path $tree 'Server.twinproj'
if ($SmokeTest) {
    $settings.'project.startupObject' = 'Sub Main'
    $settings.'project.iconForm' = ''
    $settings.'project.buildPath' = '${SourcePath}\ServerSocketSmoke.exe'
    $settings.'project.name' = 'ServerSocketSmoke'
    $src = $project.Find('Sources/Src')
    $keep = @($src.Children | Where-Object { $_.Name -in @('clsServer.cls','clsNativeConnection.cls','clsNativeAddress.cls','clsNativePacket.cls','clsSocket.cls','colSockets.cls') })
    $src.Children.Clear()
    foreach ($entry in $keep) { $src.Children.Add($entry) }
    $project.AddSource('ServerSocketSmoke.twin', [IO.File]::ReadAllBytes((Join-Path $root 'tools/ServerSocketSmoke.twin')))
    $output = Join-Path $tree 'ServerSocketSmoke.twinproj'
}
$project.Replace('Settings', [Text.Encoding]::UTF8.GetBytes(($settings | ConvertTo-Json -Depth 40)))
$project.Save($output)
Write-Output "Updated $output"
