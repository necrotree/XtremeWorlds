$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..\spacetimedb')
try {
    spacetime build
    spacetime publish xtremeworlds -y
} finally { Pop-Location }
