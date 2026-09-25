$ErrorActionPreference = 'Stop'
try {
    $control = New-Object -ComObject MSScriptControl.ScriptControl
    $control.Language = 'VBScript'
    $result = $control.Eval('1+1')
    "PASS: process bitness=$([IntPtr]::Size * 8), VBScript result=$result"
} catch {
    "FAIL: process bitness=$([IntPtr]::Size * 8), $($_.Exception.Message)"
    exit 1
}
