using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using Server;

static class MapRetrievalTest
{
    public static async Task Run()
    {
        var probe = new TcpListener(IPAddress.Loopback, 0);
        probe.Start();
        int port = ((IPEndPoint)probe.LocalEndpoint).Port;
        using var listener = probe;
        using var repository = new SpacetimeRepository(new ServerSettings
        {
            SpacetimeUri = $"http://127.0.0.1:{port}", SpacetimeDatabase = "test",
            SpacetimeConnectTimeoutSeconds = 5
        });
        var loaded = repository.GetContentAsync<MapDefinition>("map", 7);
        var request = await listener.AcceptTcpClientAsync().WaitAsync(TimeSpan.FromSeconds(5));
        string sql = await ReadRequest(request);
        if (!sql.Contains("kind = 'map' AND numeric_id = 7 LIMIT 1"))
            throw new Exception("Map lookup must select only the requested map.");
        // Imported JSON can use lowercase properties.
        await Respond(request, "[{\"rows\":[[\"{\\\"name\\\":\\\"Stored map\\\",\\\"tiles\\\":[{\\\"ground\\\":42}]}\"]]}]");
        var map = await loaded;
        if (map?.Name != "Stored map" || map.Tiles[0].Ground != 42)
            throw new Exception("Stored map JSON was not decoded.");
        var missing = repository.GetContentAsync<MapDefinition>("map", 8);
        request = await listener.AcceptTcpClientAsync().WaitAsync(TimeSpan.FromSeconds(5));
        await ReadRequest(request);
        await Respond(request, "[{\"rows\":[]}]");
        if (await missing is not null) throw new Exception("Absent map must return null.");
        Console.WriteLine("Targeted map database retrieval checks passed.");
    }

    private static async Task<string> ReadRequest(TcpClient request)
    {
        var reader = new StreamReader(request.GetStream(), Encoding.UTF8, leaveOpen: true);
        int length = 0;
        string? line;
        while (!string.IsNullOrEmpty(line = await reader.ReadLineAsync()))
            if (line.StartsWith("Content-Length:", StringComparison.OrdinalIgnoreCase))
                length = int.Parse(line.Split(':')[1].Trim());
        var body = new char[length];
        int offset = 0;
        while (offset < length)
        {
            int count = await reader.ReadAsync(body.AsMemory(offset));
            if (count == 0) throw new EndOfStreamException();
            offset += count;
        }
        return new string(body);
    }

    private static async Task Respond(TcpClient request, string body)
    {
        byte[] bytes = Encoding.UTF8.GetBytes(body);
        var header = Encoding.ASCII.GetBytes($"HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: {bytes.Length}\r\nConnection: close\r\n\r\n");
        await request.GetStream().WriteAsync(header);
        await request.GetStream().WriteAsync(bytes);
        request.Dispose();
    }
}
