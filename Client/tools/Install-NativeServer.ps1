$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$staging = Join-Path $root 'ServerMigration'
$server = [IO.Path]::GetFullPath((Join-Path $root '../Server'))
if ((Split-Path $server -Leaf) -ne 'Server' -or -not (Test-Path (Join-Path $server 'Server.vbp'))) { throw 'Unexpected server destination.' }
$backup = Join-Path $server ('.windevlib-backup/' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force (Join-Path $backup 'Src') | Out-Null
$files = @('clsServer.cls','clsSocket.cls','colSockets.cls','modServerTCP.bas','clsNativeConnection.cls','clsNativeAddress.cls','clsNativePacket.cls','frmServer.frm.twin','frmServer.frm.tbform')
foreach ($name in @('Server.vbp','Server.twinproj')) { Copy-Item -LiteralPath (Join-Path $server $name) -Destination (Join-Path $backup $name) }
foreach ($name in ($files + @('frmServer.frm'))) {
    $path = Join-Path $server "Src/$name"
    if (Test-Path -LiteralPath $path) { Copy-Item -LiteralPath $path -Destination (Join-Path $backup "Src/$name") }
}
foreach ($name in $files) { Copy-Item -LiteralPath (Join-Path $staging "Sources/Src/$name") -Destination (Join-Path $server "Src/$name") }
$encoding = New-Object Text.UTF8Encoding($false)
$formPath = Join-Path $server 'Src/frmServer.frm'
$form = [IO.File]::ReadAllText($formPath)
if ($form -notmatch 'Begin VB.Timer tmrNativeSockets') {
    $timer = "   Begin VB.Timer tmrNativeSockets`r`n      Enabled = -1`r`n      Interval = 10`r`n      Left = 4080`r`n      Top = 0`r`n   End`r`n"
    $form = [regex]::Replace($form, '(?m)^End\r?\n(?=Attribute VB_Name)', $timer + "End`r`n")
}
if ($form -notmatch 'Sub tmrNativeSockets_Timer') {
    $form += "`r`nPrivate Sub tmrNativeSockets_Timer()`r`n    If Not GameServer Is Nothing Then GameServer.Poll`r`nEnd Sub`r`n"
}
[IO.File]::WriteAllText($formPath, ($form -replace '\r?\n', "`r`n"), $encoding)
$vbpPath = Join-Path $server 'Server.vbp'
$vbp = [IO.File]::ReadAllText($vbpPath)
if ($vbp -notmatch 'Class=clsNativeConnection') {
    $vbp = $vbp.Replace('Class=clsServer;', "Class=clsNativeConnection; Src\clsNativeConnection.cls`r`nClass=clsNativeAddress; Src\clsNativeAddress.cls`r`nClass=clsNativePacket; Src\clsNativePacket.cls`r`nClass=clsServer;")
    [IO.File]::WriteAllText($vbpPath, $vbp, $encoding)
}
Copy-Item -LiteralPath (Join-Path $staging 'Server.twinproj') -Destination (Join-Path $server 'Server.twinproj')
Copy-Item -LiteralPath (Join-Path $staging 'Server-WinDevLib.exe') -Destination (Join-Path $server 'Server-WinDevLib.exe')
Copy-Item -LiteralPath (Join-Path $staging 'WINDEVLIB-SOCKETS.md') -Destination (Join-Path $server 'WINDEVLIB-SOCKETS.md')
Copy-Item -LiteralPath (Join-Path $staging 'ServerSocket-smoke-result.txt') -Destination (Join-Path $server 'ServerSocket-smoke-result.txt')
Write-Output "Installed native sockets in $server; backup: $backup"
