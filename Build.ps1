$ErrorActionPreference = "Stop"

# Build.ps1 belongs in the XtremeWorlds root beside Client\ and Server\.
$Root = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = (Get-Location).Path
}

$BuildRoot = Join-Path $Root "Build"
New-Item -ItemType Directory -Path $BuildRoot -Force | Out-Null

# Find Python automatically.
$PythonCommand = Get-Command "py.exe" -ErrorAction SilentlyContinue
if (-not $PythonCommand) {
    $PythonCommand = Get-Command "python.exe" -ErrorAction SilentlyContinue
}
if (-not $PythonCommand) {
    throw "Python was not found."
}
$Python = $PythonCommand.Source

# Get twinBASIC's import/export helper automatically.
$ImpExp = Join-Path $BuildRoot "impexp.py"
$ImpExpUrl = "https://docs.twinbasic.com/Features/Packages/downloads/impexp.py"

if (-not (Test-Path -LiteralPath $ImpExp -PathType Leaf)) {
    Write-Host "Getting twinBASIC impexp.py..."
    Invoke-WebRequest -Uri $ImpExpUrl -OutFile $ImpExp -UseBasicParsing
}

if (-not (Test-Path -LiteralPath $ImpExp -PathType Leaf)) {
    throw "Could not get impexp.py."
}

function Update-TwinProject {
    param([string]$Name)

    $ProjectDir = Join-Path $Root $Name
    $ProjectFile = Join-Path $ProjectDir ($Name + ".twinproj")
    $RepoSource = Join-Path $ProjectDir "Src"
    $Stage = Join-Path $BuildRoot ($Name + "Project")
    $Backup = Join-Path $BuildRoot ($Name + ".twinproj.backup")

    Write-Host ""
    Write-Host "========================================"
    Write-Host " Updating $Name"
    Write-Host "========================================"
    Write-Host "Reference project: $ProjectFile"
    Write-Host "Repository source: $RepoSource"

    if (-not (Test-Path -LiteralPath $ProjectFile -PathType Leaf)) {
        throw "Reference project does not exist: $ProjectFile"
    }
    if (-not (Test-Path -LiteralPath $RepoSource -PathType Container)) {
        throw "Source directory does not exist: $RepoSource"
    }

    Copy-Item -LiteralPath $ProjectFile -Destination $Backup -Force

    if (Test-Path -LiteralPath $Stage) {
        Remove-Item -LiteralPath $Stage -Recurse -Force
    }

    # The existing twinproj is authoritative. Export it first so its exact
    # source layout, Settings, resources, type libraries and metadata survive.
    Write-Host "Exporting current $Name.twinproj..."
    & $Python $ImpExp export $ProjectFile $Stage --overwrite
    $ExitCode = $LASTEXITCODE
    if (($ExitCode -ne 0) -and ($ExitCode -ne 6)) {
        throw "Export of $Name.twinproj failed with exit code $ExitCode"
    }

    if (-not (Test-Path -LiteralPath $Stage -PathType Container)) {
        throw "Export did not create: $Stage"
    }

    $StageSources = Join-Path $Stage "Sources"
    if (-not (Test-Path -LiteralPath $StageSources -PathType Container)) {
        throw "Exported project has no Sources directory: $StageSources"
    }

    # IMPORTANT:
    # Do not copy every file from Src. That reintroduces legacy .cls/.frm/.bas
    # files beside their .twin equivalents and creates duplicate modules.
    #
    # Instead, walk only files that already exist in the exported twinproj.
    # For each exported source, look for the best matching repository source
    # and replace only that one file.
    $ProjectSources = @(
        Get-ChildItem -LiteralPath $StageSources -File -Recurse |
        Where-Object {
            $_.Extension.ToLowerInvariant() -in @(
                ".twin", ".tbform", ".bas", ".cls", ".frm", ".ctl", ".res"
            )
        }
    )

    $Updated = 0
    $Kept = 0

    foreach ($Existing in $ProjectSources) {
        $ExistingName = $Existing.Name
        $ExistingBase = [System.IO.Path]::GetFileNameWithoutExtension($ExistingName)
        $ExistingExt = $Existing.Extension.ToLowerInvariant()

        # Exact filename wins.
        $Candidate = Join-Path $RepoSource $ExistingName

        if (-not (Test-Path -LiteralPath $Candidate -PathType Leaf)) {
            # twinBASIC forms may be exported as *.frm.twin while the repo has
            # *.twin, or vice versa. Only consider equivalent names for the
            # source already present in the reference project.
            $Candidates = @()

            if ($ExistingName.ToLowerInvariant().EndsWith(".frm.twin")) {
                $ShortName = $ExistingName.Substring(0, $ExistingName.Length - 9) + ".twin"
                $Candidates += (Join-Path $RepoSource $ShortName)
            }
            elseif ($ExistingExt -eq ".twin") {
                $FormTwin = $ExistingBase + ".frm.twin"
                $Candidates += (Join-Path $RepoSource $FormTwin)
            }

            foreach ($Possible in $Candidates) {
                if (Test-Path -LiteralPath $Possible -PathType Leaf) {
                    $Candidate = $Possible
                    break
                }
            }
        }

        if (Test-Path -LiteralPath $Candidate -PathType Leaf) {
            Copy-Item -LiteralPath $Candidate -Destination $Existing.FullName -Force
            $Updated++
        }
        else {
            # If the repository has no matching source, keep the version that
            # came from the known-good twinproj instead of deleting it.
            $Kept++
        }
    }

    Write-Host "Updated existing project sources: $Updated"
    Write-Host "Kept reference-only sources:       $Kept"

    # Safety check: detect duplicate logical module names before repacking.
    # .frm.twin -> frmFoo, .twin -> frmFoo, .cls -> clsFoo, etc.
    $Logical = @{}
    $Duplicates = @()

    $FinalSources = @(
        Get-ChildItem -LiteralPath $StageSources -File -Recurse |
        Where-Object {
            $_.Extension.ToLowerInvariant() -in @(
                ".twin", ".bas", ".cls", ".frm", ".ctl"
            )
        }
    )

    foreach ($File in $FinalSources) {
        $LogicalName = $File.Name.ToLowerInvariant()
        if ($LogicalName.EndsWith(".frm.twin")) {
            $LogicalName = $LogicalName.Substring(0, $LogicalName.Length - 9)
        }
        else {
            $LogicalName = [System.IO.Path]::GetFileNameWithoutExtension($LogicalName)
        }

        if ($Logical.ContainsKey($LogicalName)) {
            $Duplicates += "$LogicalName : $($Logical[$LogicalName]) AND $($File.FullName)"
        }
        else {
            $Logical[$LogicalName] = $File.FullName
        }
    }

    if ($Duplicates.Count -gt 0) {
        Write-Host ""
        Write-Host "Duplicate logical modules still exist in the REFERENCE twinproj:"
        foreach ($Duplicate in $Duplicates) {
            Write-Host "  $Duplicate"
        }
        Write-Host ""
        throw "$Name reference project contains duplicate logical modules. The project was NOT overwritten."
    }

    Write-Host "Repacking $Name.twinproj from its reference structure..."
    & $Python $ImpExp import $ProjectFile $Stage --overwrite
    $ExitCode = $LASTEXITCODE

    if (($ExitCode -ne 0) -and ($ExitCode -ne 6)) {
        Copy-Item -LiteralPath $Backup -Destination $ProjectFile -Force
        throw "$Name.twinproj import failed with exit code $ExitCode. Backup restored."
    }

    if (-not (Test-Path -LiteralPath $ProjectFile -PathType Leaf)) {
        Copy-Item -LiteralPath $Backup -Destination $ProjectFile -Force
        throw "$Name.twinproj was not created. Backup restored."
    }

    $Info = Get-Item -LiteralPath $ProjectFile
    if ($Info.Length -eq 0) {
        Copy-Item -LiteralPath $Backup -Destination $ProjectFile -Force
        throw "$Name.twinproj became empty. Backup restored."
    }

    Write-Host "$Name.twinproj updated successfully: $($Info.Length) bytes"
}

Write-Host ""
Write-Host "========================================"
Write-Host " twinBASIC Reference Project Builder"
Write-Host "========================================"
Write-Host "Repository: $Root"

Update-TwinProject -Name "Client"
Update-TwinProject -Name "Server"

Write-Host ""
Write-Host "========================================"
Write-Host " PROJECTS UPDATED"
Write-Host "========================================"
Write-Host (Join-Path $Root "Client\Client.twinproj")
Write-Host (Join-Path $Root "Server\Server.twinproj")
Write-Host ""
Write-Host "Done."
