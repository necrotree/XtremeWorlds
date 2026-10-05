$ErrorActionPreference = "Stop"



# Repository defaults to the directory containing Build.ps1.
# No path command-line argument is required.
$Root = $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = (Get-Location).Path
}

$BuildRoot = Join-Path $Root "Build"



$ClientTwinProj = Join-Path $Root "Client\Client.twinproj"

$ServerTwinProj = Join-Path $Root "Server\Server.twinproj"



# ------------------------------------------------------------
# Find Python and get the twinBASIC import/export tool
# ------------------------------------------------------------

$PythonCommand = Get-Command "py.exe" -ErrorAction SilentlyContinue
if (-not $PythonCommand) { $PythonCommand = Get-Command "python.exe" -ErrorAction SilentlyContinue }
if (-not $PythonCommand) { throw "Python was not found on PATH." }
$Python = $PythonCommand.Source
$PythonPrefix = @()

# Keep build tools and generated staging files under Build\.
if (-not (Test-Path -LiteralPath $BuildRoot)) {
    New-Item -ItemType Directory -Path $BuildRoot -Force | Out-Null
}

$ImpExp = Join-Path $BuildRoot "impexp.py"
$ImpExpUrl = "https://docs.twinbasic.com/Features/Packages/downloads/impexp.py"

# Download the standalone twinBASIC import/export tool automatically.
# This avoids requiring impexp.py to be checked into the XtremeWorlds repo.
Write-Host "Getting twinBASIC impexp.py..."
try {
    Invoke-WebRequest -Uri $ImpExpUrl -OutFile $ImpExp -UseBasicParsing
}
catch {
    throw "Could not download impexp.py from $ImpExpUrl`n$($_.Exception.Message)"
}

if (-not (Test-Path -LiteralPath $ImpExp -PathType Leaf)) {
    throw "impexp.py was not created at: $ImpExp"
}

if ((Get-Item -LiteralPath $ImpExp).Length -eq 0) {
    throw "Downloaded impexp.py is empty: $ImpExp"
}

Write-Host ""
Write-Host "========================================"
Write-Host " twinBASIC Project Builder"
Write-Host "========================================"
Write-Host "Repository: $Root"
Write-Host "Python:     $Python"
Write-Host "impexp.py:  $ImpExp"
Write-Host ""

# ------------------------------------------------------------

# Build exported/importable twinBASIC folder

# ------------------------------------------------------------



function Build-TwinFolder {

    param(

        

        [string]$Name,



        

        [string]$SourcePath

    )



    if ([string]::IsNullOrWhiteSpace($Name)) { throw "Internal error: project name was not set." }
    if ([string]::IsNullOrWhiteSpace($SourcePath)) { throw "Internal error: source path was not set." }

    $Destination = Join-Path $BuildRoot ($Name + "Project")

    $SourcesRoot = Join-Path $Destination "Sources"

    $Sources = Join-Path $SourcesRoot "Src"



    Write-Host ""

    Write-Host "========================================"

    Write-Host " Building $Name folder"

    Write-Host "========================================"

    Write-Host "Source:"

    Write-Host "  $SourcePath"

    Write-Host ""

    Write-Host "Build folder:"

    Write-Host "  $Destination"

    Write-Host ""



    if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {

        throw "$Name source directory does not exist: $SourcePath"

    }



    # Start clean every time.

    if (Test-Path -LiteralPath $Destination) {

        Write-Host "Removing old build folder..."



        Remove-Item `
            -LiteralPath $Destination `
            -Recurse `
            -Force

    }



    # Create twinBASIC folder structure.

    New-Item `
        -ItemType Directory `
        -Path $Sources `
        -Force |

        Out-Null



    New-Item `
        -ItemType Directory `
        -Path (Join-Path $Destination "Resources") `
        -Force |

        Out-Null



    New-Item `
        -ItemType Directory `
        -Path (Join-Path $Destination "Miscellaneous") `
        -Force |

        Out-Null



    New-Item `
        -ItemType Directory `
        -Path (Join-Path $Destination "ImportedTypeLibraries") `
        -Force |

        Out-Null



    # IMPORTANT:

    # Only copy files directly inside Client\Src / Server\Src.

    # Do not recurse because there are duplicate source trees elsewhere.

    $Files = @(

        Get-ChildItem `
            -LiteralPath $SourcePath `
            -File |

        Where-Object {

            $_.Extension.ToLowerInvariant() -in @(

                ".twin",

                ".tbform",

                ".bas",

                ".cls",

                ".frm",

                ".ctl",

                ".res"

            )

        } |

        Sort-Object Name

    )



    if ($Files.Count -eq 0) {

        throw "No source files were found in: $SourcePath"

    }



    Write-Host "Found $($Files.Count) source files."



    foreach ($File in $Files) {

        $Target = Join-Path $Sources $File.Name



        Copy-Item `
            -LiteralPath $File.FullName `
            -Destination $Target `
            -Force

    }



    Write-Host "Copied $($Files.Count) files."



    # --------------------------------------------------------

    # Verify duplicate filenames

    # --------------------------------------------------------



    $Duplicates = @(

        Get-ChildItem -LiteralPath $Sources -File |

        Group-Object Name |

        Where-Object {

            $_.Count -gt 1

        }

    )



    if ($Duplicates.Count -gt 0) {

        Write-Host ""

        Write-Host "Duplicate source files detected:"



        foreach ($Duplicate in $Duplicates) {

            Write-Host "  $($Duplicate.Name)"

        }



        throw "$Name contains duplicate source files."

    }



    # --------------------------------------------------------

    # Verify modGlobals

    # --------------------------------------------------------



    $Globals = Join-Path $Sources "modGlobals.bas"



    if (Test-Path -LiteralPath $Globals -PathType Leaf) {

        Write-Host "modGlobals.bas: OK"

    }

    else {

        throw "$Name modGlobals.bas was not copied."

    }



    # --------------------------------------------------------

    # Settings

    # --------------------------------------------------------



    $Settings = Join-Path $Destination "Settings"



    $SettingsText = @"

{

    "project.name": "$Name"

}

"@



    $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)



    [System.IO.File]::WriteAllText(

        $Settings,

        $SettingsText,

        $Utf8NoBom

    )



    if (-not (Test-Path -LiteralPath $Settings)) {

        throw "Failed to create Settings for $Name."

    }



    Write-Host "Settings: OK"



    return $Destination

}



# ------------------------------------------------------------

# Create actual .twinproj

# ------------------------------------------------------------



function New-TwinProject {

    param(

        

        [string]$Name,



        

        [string]$ImportFolder,



        

        [string]$OutputProject

    )



    Write-Host ""

    Write-Host "========================================"

    if ([string]::IsNullOrWhiteSpace($Name)) { throw "Internal error: project name was not set." }
    if ([string]::IsNullOrWhiteSpace($ImportFolder)) { throw "Internal error: import folder was not set." }
    if ([string]::IsNullOrWhiteSpace($OutputProject)) { throw "Internal error: output project was not set." }

    Write-Host " Creating $Name.twinproj"

    Write-Host "========================================"

    Write-Host ""

    Write-Host "Input:"

    Write-Host "  $ImportFolder"

    Write-Host ""

    Write-Host "Output:"

    Write-Host "  $OutputProject"

    Write-Host ""



    # Remove the previous generated project.

    if (Test-Path -LiteralPath $OutputProject) {

        Write-Host "Removing old $Name.twinproj..."



        Remove-Item `
            -LiteralPath $OutputProject `
            -Force

    }



    # Make sure output directory exists.

    $OutputDirectory = Split-Path -Parent $OutputProject



    if (-not (Test-Path -LiteralPath $OutputDirectory)) {

        New-Item `
            -ItemType Directory `
            -Path $OutputDirectory `
            -Force |

            Out-Null

    }



    Write-Host "Packing twinBASIC project..."
    Write-Host "  $ImportFolder"
    Write-Host "       ->"
    Write-Host "  $OutputProject"
    Write-Host ""

    # Current standalone impexp.py uses the same command order as twinBASIC:
    #   python impexp.py import <project.twinproj> <input-folder> --overwrite
    # "import" puts the folder contents into the project.
    & $Python @PythonPrefix `
        $ImpExp `
        import `
        $OutputProject `
        $ImportFolder `
        --overwrite

    $ExitCode = $LASTEXITCODE

    Write-Host ""
    Write-Host "impexp.py exit code: $ExitCode"

    # impexp.py documents 0 as success and 6 as success-with-warning.
    if (($ExitCode -ne 0) -and ($ExitCode -ne 6)) {
        throw "$Name.twinproj creation failed with exit code $ExitCode"
    }

    if (-not (Test-Path -LiteralPath $OutputProject -PathType Leaf)) {
        throw "impexp.py did not create: $OutputProject"
    }

    $ProjectFile = Get-Item -LiteralPath $OutputProject



    if ($ProjectFile.Length -eq 0) {

        throw "$OutputProject was created but is empty."

    }



    Write-Host ""

    Write-Host "$Name.twinproj: CREATED"

    Write-Host "  $OutputProject"

    Write-Host "  $($ProjectFile.Length) bytes"

}



# ------------------------------------------------------------

# Main

# ------------------------------------------------------------



if (-not (Test-Path -LiteralPath $BuildRoot)) {

    New-Item `
        -ItemType Directory `
        -Path $BuildRoot `
        -Force |

        Out-Null

}



$ClientSource = Join-Path $Root "Client\Src"

$ServerSource = Join-Path $Root "Server\Src"



$ClientBuild = Build-TwinFolder -Name "Client" -SourcePath $ClientSource
$ServerBuild = Build-TwinFolder -Name "Server" -SourcePath $ServerSource

New-TwinProject -Name "Client" -ImportFolder $ClientBuild -OutputProject $ClientTwinProj
New-TwinProject -Name "Server" -ImportFolder $ServerBuild -OutputProject $ServerTwinProj



# ------------------------------------------------------------

# Final verification

# ------------------------------------------------------------



Write-Host ""

Write-Host "========================================"

Write-Host " FINAL RESULTS"

Write-Host "========================================"

Write-Host ""



if (Test-Path -LiteralPath $ClientTwinProj) {

    $ClientInfo = Get-Item -LiteralPath $ClientTwinProj



    Write-Host "CLIENT: OK"

    Write-Host "  $($ClientInfo.FullName)"

    Write-Host "  $($ClientInfo.Length) bytes"

}

else {

    Write-Host "CLIENT: FAILED"

}



Write-Host ""



if (Test-Path -LiteralPath $ServerTwinProj) {

    $ServerInfo = Get-Item -LiteralPath $ServerTwinProj



    Write-Host "SERVER: OK"

    Write-Host "  $($ServerInfo.FullName)"

    Write-Host "  $($ServerInfo.Length) bytes"

}

else {

    Write-Host "SERVER: FAILED"

}



Write-Host ""

Write-Host "Done."
