Write-Host ""
Write-Host "Creating Client.twinproj..."

& $Python @PythonPrefix `
    $ImpExp `
    export `
    $ClientProject `
    $ClientFolder `
    --overwrite

if (($LASTEXITCODE -ne 0) -and ($LASTEXITCODE -ne 6)) {
    throw "Client.twinproj creation failed with exit code $LASTEXITCODE"
}

Write-Host ""
Write-Host "Creating Server.twinproj..."

& $Python @PythonPrefix `
    $ImpExp `
    export `
    $ServerProject `
    $ServerFolder `
    --overwrite

if (($LASTEXITCODE -ne 0) -and ($LASTEXITCODE -ne 6)) {
    throw "Server.twinproj creation failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -LiteralPath $ClientProject)) {
    throw "Client\Client.twinproj was not created."
}

if (-not (Test-Path -LiteralPath $ServerProject)) {
    throw "Server\Server.twinproj was not created."
}

Write-Host ""
Write-Host "========================================"
Write-Host " PROJECTS CREATED"
Write-Host "========================================"
Write-Host "Client: $ClientProject"
Write-Host "Server: $ServerProject"