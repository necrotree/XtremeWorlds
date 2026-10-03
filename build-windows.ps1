$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $root
try {
    Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -in @('Server','Server.Windows','XtremeWorlds.Client.Windows','Client.Windows')
    } | Stop-Process -Force -ErrorAction SilentlyContinue

    Start-Sleep -Milliseconds 200

    Get-ChildItem -Path $root -Directory -Recurse -Force |
        Where-Object { $_.Name -in @('bin','obj','.vs') } |
        Sort-Object FullName -Descending |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

    dotnet restore .\XtremeWorlds.sln -p:Configuration=Debug -p:Platform=Windows
    dotnet build .\XtremeWorlds.sln -c Debug -p:Platform=Windows --no-restore
}
finally {
    Pop-Location
}
