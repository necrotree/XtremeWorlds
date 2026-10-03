using System;
using System.IO;
using System.Text;

namespace Server;

public sealed class ServerLogWriter : IDisposable
{
    private readonly object _sync = new();
    public string LogDirectory { get; }

    public ServerLogWriter(string? directory = null)
    {
        LogDirectory = directory ?? Path.Combine(AppContext.BaseDirectory, "logs");
        Directory.CreateDirectory(LogDirectory);
    }

    public string Write(string category, string message)
    {
        var now = DateTimeOffset.Now;
        string line = $"[{now:yyyy-MM-dd HH:mm:ss}] [{category}] {message}";
        string daily = Path.Combine(LogDirectory, $"server-{now:yyyy-MM-dd}.log");
        lock (_sync)
            File.AppendAllText(daily, line + Environment.NewLine, Encoding.UTF8);
        return line;
    }

    public string WriteBug(BugReportInfo report)
    {
        var now = report.Timestamp;
        string line = $"[{now:yyyy-MM-dd HH:mm:ss}] {report.PlayerName}: Type[{report.Type}] - Occurs[{report.Occurs}] - Repeat?[{report.Repeat}]: {report.Message}";
        lock (_sync)
        {
            File.AppendAllText(Path.Combine(LogDirectory, $"bugs-{now:yyyy-MM-dd}.log"), line + Environment.NewLine, Encoding.UTF8);
            File.AppendAllText(Path.Combine(LogDirectory, $"server-{now:yyyy-MM-dd}.log"), $"[{now:yyyy-MM-dd HH:mm:ss}] [BUG] {report.PlayerName}: {report.Message}" + Environment.NewLine, Encoding.UTF8);
        }
        return line;
    }

    public void Dispose() { }
}

public sealed record BugReportInfo(
    DateTimeOffset Timestamp,
    int ConnectionId,
    string PlayerName,
    string Type,
    string Occurs,
    string Repeat,
    string Message)
{
    public override string ToString() => $"{Timestamp:HH:mm:ss} {PlayerName}: Type[{Type}] - Occurs[{Occurs}] - Repeat?[{Repeat}]: {Message}";
}
