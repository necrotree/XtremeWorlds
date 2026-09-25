$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 19385)
$listener.Start()
try {
    $testProcess = Start-Process -FilePath (Join-Path $root 'NativeControlsSmoke.exe') -WindowStyle Hidden -PassThru
    $accept = $listener.AcceptTcpClientAsync()
    $deadline = [DateTime]::UtcNow.AddSeconds(15)
    while (-not $accept.IsCompleted -and -not $testProcess.HasExited -and [DateTime]::UtcNow -lt $deadline) { Start-Sleep -Milliseconds 50 }
    if ($accept.IsCompleted) {
        $client = $accept.Result
        $stream = $client.GetStream()
        $stream.ReadTimeout = 8000
        $buffer = New-Object byte[] 137
        while (($count = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) { $stream.Write($buffer, 0, $count) }
        $client.Dispose()
    }
    if (-not $testProcess.WaitForExit(5000)) { throw 'Native controls test timed out.' }
    $result = Get-Content (Join-Path $root 'NativeControls-smoke-result.txt') -Raw
    $result.Trim()
    if (-not $result.StartsWith('PASS:')) { exit 1 }
} finally { $listener.Stop() }
