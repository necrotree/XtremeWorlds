#requires -Version 5.1
<#
Examples:
  .\Debug.ps1
      Launches Server\Server.exe and Client\Client.exe.
      The server is monitored for the crash and receives a full WER dump.

  .\Debug.ps1 -Target Server
      Launches and monitors only Server\Server.exe.

  .\Debug.ps1 -Target Client
      Launches and monitors only Client\Client.exe.

  .\Debug.ps1 -ExePath "C:\Other\Program.exe"
      Launches and monitors an explicit executable.
#>

[CmdletBinding()]
param(
    [string]$ExePath = "",
    [ValidateSet("Both","Server","Client")][string]$Target = "Both",
    [string]$Arguments = "",
    [string]$OutputRoot = "$env:USERPROFILE\Desktop\twinBASIC-Crash-Captures",
    [switch]$DontLaunch
)

$ErrorActionPreference = "Stop"

function Step([string]$s) { Write-Host "[tB Crash Debug] $s" -ForegroundColor Cyan }
function IsAdmin {
    $id=[Security.Principal.WindowsIdentity]::GetCurrent()
    $p=New-Object Security.Principal.WindowsPrincipal($id)
    $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (IsAdmin)) {
    Write-Host "Run PowerShell as Administrator." -ForegroundColor Red
    exit 1
}
# Resolve repository executables. By default, launch Server first and then Client.
$RepoRoot = $PSScriptRoot
$ServerPath = Join-Path $RepoRoot "Server\Server.exe"
$ClientPath = Join-Path $RepoRoot "Client\Client.exe"

if (-not [string]::IsNullOrWhiteSpace($ExePath)) {
    if (-not (Test-Path -LiteralPath $ExePath -PathType Leaf)) {
        throw "Executable not found: $ExePath"
    }
    $ExePath = (Resolve-Path -LiteralPath $ExePath).Path
    $Target = "Server"
} elseif ($Target -eq "Client") {
    $ExePath = $ClientPath
} else {
    $ExePath = $ServerPath
}

if (-not (Test-Path -LiteralPath $ExePath -PathType Leaf)) {
    Write-Host "Executable not found: $ExePath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Expected repository layout:"
    Write-Host "  $ServerPath"
    Write-Host "  $ClientPath"
    exit 1
}

$ExePath=(Resolve-Path -LiteralPath $ExePath).Path
$ExeName=[IO.Path]::GetFileName($ExePath)
$ProcessName=[IO.Path]::GetFileNameWithoutExtension($ExePath)
$stamp=Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$CaptureDir=Join-Path $OutputRoot "$ProcessName-$stamp"
$DumpDir=Join-Path $CaptureDir "Dumps"
New-Item -ItemType Directory -Force -Path $DumpDir | Out-Null

$Info=Join-Path $CaptureDir "capture-info.txt"
$Events=Join-Path $CaptureDir "windows-crash-events.txt"
$SystemEvents=Join-Path $CaptureDir "windows-system-events.txt"
$Modules=Join-Path $CaptureDir "loaded-modules.txt"
$start=Get-Date

@"
twinBASIC Native Crash Capture
==============================
Started:      $start
Executable:   $ExePath
Arguments:    $Arguments
Computer:     $env:COMPUTERNAME
Windows:      $([Environment]::OSVersion.VersionString)
PowerShell:   $($PSVersionTable.PSVersion)
Dump type:    Full user-mode dump (WER DumpType 2)
Capture dir:  $CaptureDir
"@ | Set-Content -LiteralPath $Info -Encoding UTF8

# Configure WER LocalDumps only for the selected executable.
$key="HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\$ExeName"
Step "Enabling full Windows Error Reporting dumps for $ExeName"
New-Item -Path $key -Force | Out-Null
New-ItemProperty -Path $key -Name DumpFolder -PropertyType ExpandString -Value $DumpDir -Force | Out-Null
New-ItemProperty -Path $key -Name DumpCount -PropertyType DWord -Value 10 -Force | Out-Null
New-ItemProperty -Path $key -Name DumpType -PropertyType DWord -Value 2 -Force | Out-Null

if (-not $DontLaunch) {
    Step "Launching $ExeName"
    $wd=[IO.Path]::GetDirectoryName($ExePath)
    if ([string]::IsNullOrWhiteSpace($Arguments)) {
        $proc=Start-Process -FilePath $ExePath -WorkingDirectory $wd -PassThru
    } else {
        $proc=Start-Process -FilePath $ExePath -ArgumentList $Arguments -WorkingDirectory $wd -PassThru
    }

    Add-Content $Info "PID:          $($proc.Id)"
    Start-Sleep -Seconds 2

    # In Both mode the server is the monitored crash target, but the client
    # is also launched automatically so the editor crash can be reproduced.
    $clientProc = $null
    if ($Target -eq "Both") {
        if (Test-Path -LiteralPath $ClientPath -PathType Leaf) {
            Step "Launching Client.exe"
            $clientProc = Start-Process -FilePath $ClientPath `
                -WorkingDirectory ([IO.Path]::GetDirectoryName($ClientPath)) -PassThru
            Add-Content $Info "Client PID:   $($clientProc.Id)"
        } else {
            Write-Host "Client executable not found: $ClientPath" -ForegroundColor Yellow
        }
    }

    if (-not $proc.HasExited) {
        try {
            Get-Process -Id $proc.Id -Module -ErrorAction Stop |
                Select-Object ModuleName,FileName,@{N="Version";E={$_.FileVersionInfo.FileVersion}} |
                Format-Table -AutoSize | Out-String -Width 4096 |
                Set-Content -LiteralPath $Modules -Encoding UTF8
        } catch {
            "Module enumeration failed: $($_.Exception.Message)" | Set-Content $Modules
        }

        Write-Host "`nReproduce the crash now. Waiting for the process to exit..." -ForegroundColor Green
        $proc.WaitForExit()
    }

    $exit=$proc.ExitCode
    $hex = '0x' + ([Convert]::ToString(([int64]$exit -band 0xFFFFFFFFL), 16).PadLeft(8, '0').ToUpperInvariant())
    Add-Content $Info "Exit time:    $(Get-Date)"
    Add-Content $Info "Exit code:    $exit ($hex)"
    if ($hex -eq "0xC00000FD") {
        Add-Content $Info "Exception:    STATUS_STACK_OVERFLOW"
        Write-Host "CRASH: STATUS_STACK_OVERFLOW (0xC00000FD)" -ForegroundColor Red
    }
    Step "Process exited: $exit ($hex)"
} else {
    Step "WER is configured. Launch the program manually, reproduce the crash, then press Enter here."
    Read-Host | Out-Null
}

# WER may still be flushing the dump.
Start-Sleep -Seconds 5

Step "Collecting Windows crash events"
try {
    $ev=Get-WinEvent -FilterHashtable @{LogName="Application";StartTime=$start.AddMinutes(-1)} |
        Where-Object {
            $_.ProviderName -in @("Application Error","Windows Error Reporting",".NET Runtime") -and
            ($_.Message -match [regex]::Escape($ExeName) -or $_.Message -match [regex]::Escape($ProcessName))
        }
    if ($ev) {
        $ev | Select-Object TimeCreated,Id,LevelDisplayName,ProviderName,Message |
            Format-List | Out-String -Width 4096 | Set-Content $Events -Encoding UTF8
    } else {
        "No matching Application/WER events found." | Set-Content $Events
    }
} catch {
    "Event query failed: $($_.Exception.Message)" | Set-Content $Events
}

# Also collect Event Viewer -> Windows Logs -> System entries around the crash.
# This catches lower-level failures such as application termination, service,
# disk, driver, WHEA, bugcheck, and unexpected shutdown events.
Step "Collecting Event Viewer System log entries"
try {
    $systemEv = Get-WinEvent -FilterHashtable @{
        LogName   = "System"
        StartTime = $start.AddMinutes(-1)
    } -ErrorAction Stop | Where-Object {
        $_.Level -le 3 -or
        $_.ProviderName -match "WHEA|BugCheck|Kernel|Application Popup|Service Control Manager"
    }

    if ($systemEv) {
        $systemEv |
            Select-Object TimeCreated,Id,LevelDisplayName,ProviderName,Message |
            Format-List |
            Out-String -Width 8192 |
            Set-Content -LiteralPath $SystemEvents -Encoding UTF8
    } else {
        "No matching warning/error/critical System events found." |
            Set-Content -LiteralPath $SystemEvents -Encoding UTF8
    }
} catch {
    "System event query failed: $($_.Exception.Message)" |
        Set-Content -LiteralPath $SystemEvents -Encoding UTF8
}

$dumps=@(Get-ChildItem -LiteralPath $DumpDir -Filter "*.dmp" -ErrorAction SilentlyContinue)
Add-Content $Info "`nDump files: $($dumps.Count)"
foreach($d in $dumps) {
    Add-Content $Info "  $($d.FullName)  $([math]::Round($d.Length/1MB,2)) MB"
}

# Automatically analyze the newest dump with WinDbg/CDB if the debugger is installed.
# cdb.exe is preferred because it is designed for command-line dump analysis.
$StackTrace = Join-Path $CaptureDir "stacktrace.txt"
$Debugger = $null

$debuggerCandidates = @(
    "$env:ProgramFiles\Windows Kits\10\Debuggers\x64\cdb.exe",
    "$env:ProgramFiles\Windows Kits\10\Debuggers\x86\cdb.exe",
    "$env:ProgramFiles(x86)\Windows Kits\10\Debuggers\x64\cdb.exe",
    "$env:ProgramFiles(x86)\Windows Kits\10\Debuggers\x86\cdb.exe"
)

foreach ($candidate in $debuggerCandidates) {
    if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        $Debugger = $candidate
        break
    }
}

if (-not $Debugger) {
    $cmd = Get-Command cdb.exe -ErrorAction SilentlyContinue
    if ($cmd) { $Debugger = $cmd.Source }
}

if ($dumps.Count -gt 0) {
    $NewestDump = $dumps | Sort-Object LastWriteTime -Descending | Select-Object -First 1

    if ($Debugger) {
        Step "Generating native stack trace from $($NewestDump.Name)"
        Add-Content $Info "Debugger:     $Debugger"

        # !analyze -v gives the exception analysis.
        # .ecxr switches to the crashing exception context.
        # kv gives the native call stack with parameters.
        # ~* kv dumps every thread, useful for recursion/stack-overflow crashes.
        $commands = "!analyze -v; .ecxr; kv; ~* kv; lm; q"

        try {
            & $Debugger -z $NewestDump.FullName -c $commands 2>&1 |
                Out-String -Width 8192 |
                Set-Content -LiteralPath $StackTrace -Encoding UTF8

            Add-Content $Info "Stack trace:  $StackTrace"
            Step "Stack trace written to $StackTrace"
        }
        catch {
            "Automatic WinDbg/CDB analysis failed: $($_.Exception.Message)" |
                Set-Content -LiteralPath $StackTrace -Encoding UTF8
        }
    }
    else {
        @"
A dump was captured, but cdb.exe was not found.

Dump:
$($NewestDump.FullName)

Install Microsoft WinDbg / Debugging Tools for Windows, then rerun the
capture. The script will automatically execute:

  !analyze -v
  .ecxr
  kv
  ~* kv
  lm

For this crash, 0xC00000FD means STATUS_STACK_OVERFLOW. The repeating
frames in the stack are especially important.
"@ | Set-Content -LiteralPath $StackTrace -Encoding UTF8

        Add-Content $Info "Stack trace:  debugger not installed; see $StackTrace"
    }
}

@"

Common native exception codes
=============================
0xC0000005  Access violation
0xC000001D  Illegal instruction
0xC0000094  Integer divide by zero
0xC00000FD  Stack overflow
0xC0000374  Heap corruption
0xC0000409  Stack buffer overrun / fail-fast
0x80000003  Breakpoint

WinDbg commands:
  !analyze -v
  .ecxr
  k
  lm
"@ | Add-Content $Info

# Do not duplicate the potentially huge full dump inside the ZIP.
$zip=Join-Path $OutputRoot "$ProcessName-$stamp-diagnostics.zip"
$files=@($Info,$Events,$SystemEvents,$Modules,$StackTrace) | Where-Object { Test-Path $_ }
if ($files.Count) { Compress-Archive -LiteralPath $files -DestinationPath $zip -Force }

Write-Host ""
Write-Host "================ EVENT VIEWER: APPLICATION ================" -ForegroundColor Magenta
if (Test-Path -LiteralPath $Events) {
    Get-Content -LiteralPath $Events | Write-Host
}

Write-Host ""
Write-Host "================== EVENT VIEWER: SYSTEM ===================" -ForegroundColor Magenta
if (Test-Path -LiteralPath $SystemEvents) {
    Get-Content -LiteralPath $SystemEvents | Write-Host
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta

Write-Host "`nCapture complete." -ForegroundColor Green
Write-Host "Application Event Viewer log: $Events"
Write-Host "System Event Viewer log:      $SystemEvents"
Write-Host "Diagnostics ZIP: $zip"
Write-Host "Full dump folder: $DumpDir"
if ($dumps.Count) {
    Write-Host "`nOpen the newest .dmp in WinDbg and run:" -ForegroundColor Yellow
    if (Test-Path -LiteralPath $StackTrace) {
        Write-Host "Automatic stack trace: $StackTrace" -ForegroundColor Green
    }
    Write-Host "Manual WinDbg commands:"
    Write-Host "  !analyze -v"
    Write-Host "  .ecxr"
    Write-Host "  kv"
    Write-Host "  ~* kv"
    Write-Host "  lm"
} else {
    Write-Host "`nNo dump was generated. Inspect windows-crash-events.txt." -ForegroundColor Yellow
}
