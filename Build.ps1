$ErrorActionPreference = "Stop"

# ALWAYS use the directory PowerShell is currently in.
$Root = (Get-Location).Path

Write-Host ""
Write-Host "Working directory:"
Write-Host "  $Root"
Write-Host ""

$ClientSrc = Join-Path $Root "Client\Src"
$ServerSrc = Join-Path $Root "Server\Src"

$ClientProject = Join-Path $Root "Client\Client.twinproj"
$ServerProject = Join-Path $Root "Server\Server.twinproj"

$BuildRoot = Join-Path $Root "Build"
$ClientBuild = Join-Path $BuildRoot "ClientProject"
$ServerBuild = Join-Path $BuildRoot "ServerProject"

Write-Host "Existing twinBASIC projects:"
Write-Host ""

$ExistingProjects = @(
    Get-ChildItem `
        -Path $Root `
        -Filter "*.twinproj" `
        -File `
        -Recurse `
        -ErrorAction SilentlyContinue
)

if ($ExistingProjects.Count -eq 0) {
    Write-Host "  None found."
}
else {
    foreach ($Project in $ExistingProjects) {
        Write-Host "  $($Project.FullName)"
    }
}

Write-Host ""