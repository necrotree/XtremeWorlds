$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'TwinContainer.ps1')
$root = Split-Path $PSScriptRoot -Parent
$tree = Join-Path $root 'ServerMigration'
$project = [TwinNode]::Load((Join-Path $root '../Server/Server.twinproj'))
$settings = [Text.Encoding]::UTF8.GetString($project.Find('Settings').Data) | ConvertFrom-Json
$settings.'project.name' = 'GuildSmoke'
$settings.'project.startupObject' = 'Sub Main'
$settings.'project.iconForm' = ''
$settings.'project.buildPath' = '${SourcePath}\GuildSmoke.exe'
$project.Replace('Settings', [Text.Encoding]::UTF8.GetBytes(($settings | ConvertTo-Json -Depth 40)))
$project.Find('Sources/Src').Children.Clear()
$test = [IO.File]::ReadAllText((Join-Path $root 'tools/GuildSmoke.bas')) -replace '\r?\n', "`r`n"
$project.AddSource('GuildSmoke.bas', [Text.Encoding]::UTF8.GetBytes($test))
$project.Save((Join-Path $tree 'GuildSmoke.twinproj'))
