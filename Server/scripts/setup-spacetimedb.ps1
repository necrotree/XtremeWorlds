$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '..\SpacetimeDb')
try {
    spacetime build
    spacetime publish xtremeworlds -y
} finally { Pop-Location }
