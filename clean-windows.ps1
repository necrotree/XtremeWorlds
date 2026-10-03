$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -in @('Server','Server.Windows','XtremeWorlds.Client.Windows','Client.Windows')
} | Stop-Process -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $root -Directory -Recurse -Force |
    Where-Object { $_.Name -in @('bin','obj','.vs') } |
    Sort-Object FullName -Descending |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Write-Host 'Stopped XtremeWorlds processes and removed stale bin/obj/.vs folders.'
