param([string]$Expression, [string]$ExpressionFile, [int]$Port = 19444)
$ErrorActionPreference = 'Stop'
if ($ExpressionFile) { $Expression = [IO.File]::ReadAllText((Join-Path $PWD $ExpressionFile)) }
if (-not $Expression) { throw 'An expression or expression file is required.' }
Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Net.WebSockets;
using System.Text;
using System.Threading;
public static class TwinCDP {
    public static string Evaluate(string url, string request) {
        using (var socket = new ClientWebSocket())
        using (var timeout = new CancellationTokenSource(30000)) {
            socket.ConnectAsync(new Uri(url), timeout.Token).GetAwaiter().GetResult();
            var bytes = Encoding.UTF8.GetBytes(request);
            socket.SendAsync(new ArraySegment<byte>(bytes), WebSocketMessageType.Text, true, timeout.Token).GetAwaiter().GetResult();
            var buffer = new byte[65536];
            while (true) {
                using (var message = new MemoryStream()) {
                    WebSocketReceiveResult result;
                    do {
                        result = socket.ReceiveAsync(new ArraySegment<byte>(buffer), timeout.Token).GetAwaiter().GetResult();
                        if (result.MessageType == WebSocketMessageType.Close) throw new IOException("Debugger disconnected.");
                        message.Write(buffer, 0, result.Count);
                    } while (!result.EndOfMessage);
                    var text = Encoding.UTF8.GetString(message.ToArray());
                    if (text.Contains("\"id\":1")) return text;
                }
            }
        }
    }
}
'@
$pages = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/json/list" -TimeoutSec 5
$page = $pages | Where-Object { $_.url -match 'main.htm' } | Select-Object -First 1
if (-not $page) { throw 'twinBASIC IDE debugger page was not found.' }
$request = @{ id = 1; method = 'Runtime.evaluate'; params = @{ expression = $Expression; returnByValue = $true; awaitPromise = $true } } | ConvertTo-Json -Depth 10 -Compress
$response = [TwinCDP]::Evaluate($page.webSocketDebuggerUrl, $request) | ConvertFrom-Json
if ($response.result.exceptionDetails) { $response.result.exceptionDetails | ConvertTo-Json -Depth 10; exit 1 }
$response.result.result | ConvertTo-Json -Depth 30
