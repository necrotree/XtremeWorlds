$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Add-Type -TypeDefinition @'
using System;
using System.Net.Sockets;
using System.Threading.Tasks;
public static class ServerSocketProbe {
    static async Task Client(int seed) {
        using (var client = new TcpClient()) {
            await client.ConnectAsync("127.0.0.1",19386);
            var bytes = new byte[524288];
            new Random(seed).NextBytes(bytes);
            var stream = client.GetStream();
            await stream.WriteAsync(bytes,0,bytes.Length);
            await Task.Delay(150);
            var received = new byte[bytes.Length];
            int offset = 0;
            while (offset < received.Length) {
                int count = await stream.ReadAsync(received,offset,received.Length-offset);
                if (count == 0) throw new Exception("Unexpected disconnect");
                offset += count;
            }
            for(int i=0;i<bytes.Length;i++) if(bytes[i]!=received[i]) throw new Exception("Binary echo mismatch at " + i);
        }
    }
    public static void Run() {
        var tasks = Task.WhenAll(Client(1),Client(2),Client(3));
        if (!tasks.Wait(15000)) throw new Exception("Echo test timed out");
    }
}
'@
$process = Start-Process (Join-Path $root 'ServerMigration/ServerSocketSmoke.exe') -WindowStyle Hidden -PassThru
Start-Sleep -Milliseconds 500
[ServerSocketProbe]::Run()
if (-not $process.WaitForExit(10000)) { throw 'Server test did not finish' }
$result = Get-Content (Join-Path $root 'ServerMigration/ServerSocket-smoke-result.txt') -Raw
$result.Trim()
if (-not $result.StartsWith('PASS:')) { exit 1 }
