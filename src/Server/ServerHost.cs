using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Net.Sockets;
using System.Threading;
using System.Threading.Tasks;

namespace Server;

public sealed class ServerHost : IDisposable
{
    public event Action<string>? LogMessage;
    public event Action<int>? PlayerCountChanged;
    public event Action? SessionsChanged;
    public event Action<BugReportInfo>? BugReportReceived;

    private readonly ServerSettings _settings;
    private readonly MirrorTcpHost _network;
    private readonly SpacetimeRepository _database;
    private readonly ConcurrentDictionary<int, PlayerSession> _sessions = new();
    private readonly PacketRouter _router;
    private readonly CancellationTokenSource _stop = new();
    private readonly ServerLogWriter _logs = new();
    private readonly SpacetimeLocalProcess _spacetimeProcess;

    public ServerHost(ServerSettings settings)
    {
        _settings = settings;
        _database = new SpacetimeRepository(settings);
        _spacetimeProcess = new SpacetimeLocalProcess(settings, Log);
        _network = new MirrorTcpHost(settings.Port, settings.MaxMessageSize, settings.TcpNoDelay);
        _router = new PacketRouter(settings, _network, _database, _sessions, Log, OnBugReport);

        _network.Connected += OnConnected;
        _network.DataReceived += OnData;
        _network.Disconnected += OnDisconnected;
    }

    public string LogDirectory => _logs.LogDirectory;

    public async Task RunAsync(CancellationToken externalToken)
    {
        Log($"{_settings.GameName} starting on TCP {_settings.Port}...");
        Log($"SpacetimeDB: {_settings.SpacetimeUri} / {_settings.SpacetimeDatabase}");

        bool spacetimeReady = await _spacetimeProcess
            .EnsureStartedAsync(_database.PingAsync, externalToken)
            .ConfigureAwait(false);

        if (externalToken.IsCancellationRequested)
            return;

        if (spacetimeReady)
        {
            Log("SpacetimeDB connection OK.");

            bool databaseReady = await _spacetimeProcess
                .EnsureDatabaseAsync(_database.DatabaseExistsAsync, externalToken)
                .ConfigureAwait(false);

            if (databaseReady)
            {
                await ConfigureSpacetimeDatabaseAuthorizationAsync(externalToken).ConfigureAwait(false);
            }
            else if (_settings.RequireSpacetimeDb)
            {
                throw new InvalidOperationException(
                    $"SpacetimeDB database '{_settings.SpacetimeDatabase}' is required but could not be created or reached.");
            }
        }
        else if (_settings.RequireSpacetimeDb)
        {
            throw new InvalidOperationException($"SpacetimeDB is required but could not be started or reached at {_settings.SpacetimeUri}.");
        }
        else
        {
            Log($"SpacetimeDB is unavailable at {_settings.SpacetimeUri}; the TCP game server will continue running, but database-backed actions will be unavailable.");
        }

        _network.Start();
        Log($"Mirror Telepathy TCP host active. TCPNoDelay={_settings.TcpNoDelay}");

        var tickLength = TimeSpan.FromSeconds(1.0d / Math.Max(1, _settings.TickRate));
        var sw = new Stopwatch();
        while (!_stop.IsCancellationRequested && !externalToken.IsCancellationRequested)
        {
            sw.Restart();
            _network.Tick(1000);
            _router.Tick();
            var delay = tickLength - sw.Elapsed;
            if (delay > TimeSpan.Zero)
                await Task.Delay(delay, _stop.Token).ConfigureAwait(false);
        }

        _network.Stop();
        Log("Server stopped.");
    }


    private async Task ConfigureSpacetimeDatabaseAuthorizationAsync(CancellationToken cancellationToken)
    {
        // SpacetimeHttpClient already applies explicit appsettings credentials.
        // Verify those first so an explicitly configured token always wins.
        if (!string.IsNullOrWhiteSpace(_settings.SpacetimeToken) ||
            !string.IsNullOrWhiteSpace(_settings.SpacetimeUsername))
        {
            await _database.VerifyPrivateTableAccessAsync(cancellationToken).ConfigureAwait(false);
            Log("SpacetimeDB private-table authorization OK.");
            return;
        }

        try
        {
            // Reuse the CLI discovery/auth helper owned by SpacetimeLocalProcess.
            // The token is intentionally never written to the log.
            string? token = await _spacetimeProcess
                .TryGetCliAuthTokenAsync(cancellationToken)
                .ConfigureAwait(false);

            if (string.IsNullOrWhiteSpace(token))
                throw new InvalidOperationException(
                    "No SpacetimeDB owner token was configured and no token could be read from the local CLI login.");

            _database.SetBearerToken(token);
            await _database.VerifyPrivateTableAccessAsync(cancellationToken).ConfigureAwait(false);
            Log("SpacetimeDB private-table authorization OK using the local CLI login.");
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            string message = $"SpacetimeDB private-table authorization could not be configured: {ShortMessage(ex)}";
            if (_settings.RequireSpacetimeDb)
                throw new InvalidOperationException(message, ex);
            Log(message);
        }
    }

    public void RequestStop()
    {
        if (!_stop.IsCancellationRequested)
            _stop.Cancel();
    }

    public IReadOnlyList<PlayerSessionInfo> GetSessions() => _sessions.Values
        .Select(s => new PlayerSessionInfo(
            s.ConnectionId,
            s.Character?.Name ?? s.Login ?? string.Empty,
            s.Login ?? string.Empty,
            s.IpAddress ?? string.Empty,
            s.IsPlaying,
            s.Character?.Access ?? 0))
        .OrderBy(s => s.DisplayName, StringComparer.OrdinalIgnoreCase)
        .ToArray();

    public void WarnPlayer(int connectionId, string message)
    {
        if (!_sessions.ContainsKey(connectionId)) return;
        _network.SendText(connectionId, PacketCodec.Compose("alertmsg", message));
        Log($"Server warning sent to {DescribePlayer(connectionId)}: {message}");
    }

    public void KickPlayer(int connectionId)
    {
        if (!_sessions.ContainsKey(connectionId)) return;
        string player = DescribePlayer(connectionId);
        _network.SendText(connectionId, PacketCodec.Compose("alertmsg", "You have been kicked by the Server!"));
        _network.Disconnect(connectionId);
        Log($"The Server has kicked {player}.");
    }

    public async Task BanPlayerAsync(int connectionId)
    {
        if (!_sessions.TryGetValue(connectionId, out var session)) return;
        string player = session.Character?.Name ?? session.Login ?? $"#{connectionId}";
        try
        {
            await _database.AddBanAsync(new BanDefinition
            {
                BannedIP = session.IpAddress ?? string.Empty,
                BannedCharacter = session.Character?.Name ?? string.Empty,
                BannedBy = "Server",
                BannedHardwareId = session.HardwareId ?? string.Empty
            }).ConfigureAwait(false);
        }
        catch (Exception ex) when (IsConnectionFailure(ex))
        {
            Log($"Cannot ban {player}: SpacetimeDB is unavailable. ({ShortMessage(ex)})");
            return;
        }
        _network.SendText(connectionId, PacketCodec.Compose("alertmsg", "You have been banned by the Server!"));
        _network.Disconnect(connectionId);
        Log($"{player} has been banned by the Server.");
    }

    public async Task SetPlayerAccessAsync(int connectionId, byte access)
    {
        if (!_sessions.TryGetValue(connectionId, out var session) || session.Character is null) return;
        session.Character.Access = access;
        if (!string.IsNullOrWhiteSpace(session.Login) && session.CharacterSlot > 0)
        {
            try
            {
                await _database.SaveCharacterAsync(session.Login, session.CharacterSlot, session.Character).ConfigureAwait(false);
            }
            catch (Exception ex) when (IsConnectionFailure(ex))
            {
                Log($"Access changed in memory for {DescribePlayer(connectionId)}, but could not save because SpacetimeDB is unavailable. ({ShortMessage(ex)})");
                SessionsChanged?.Invoke();
                return;
            }
        }
        Log($"{DescribePlayer(connectionId)} access set to {access}.");
        SessionsChanged?.Invoke();
    }

    public void BroadcastServerMessage(string message)
    {
        foreach (var id in _sessions.Keys)
            _network.SendText(id, PacketCodec.Compose("globalmsg", $"Server: {message}", 15));
        Log($"Server broadcast: {message}");
    }

    private void OnConnected(int connectionId, string address)
    {
        if (_sessions.Count >= _settings.MaxPlayers)
        {
            _network.SendText(connectionId, PacketCodec.Compose("alertmsg", "Server is full."));
            _network.Disconnect(connectionId);
            return;
        }
        _sessions[connectionId] = new PlayerSession { ConnectionId = connectionId, IpAddress = address };
        Log($"[{connectionId}] connected from {address}");
        RaiseSessionEvents();
    }

    private void OnData(int connectionId, ReadOnlyMemory<byte> payload)
    {
        string text = PacketCodec.Decode(payload.Span);
        _ = HandleAndRefreshAsync(connectionId, text);
    }

    private async Task HandleAndRefreshAsync(int connectionId, string text)
    {
        await _router.HandleAsync(connectionId, text).ConfigureAwait(false);
        SessionsChanged?.Invoke();
    }

    private void OnDisconnected(int connectionId)
    {
        _sessions.TryRemove(connectionId, out _);
        Log($"[{connectionId}] disconnected");
        RaiseSessionEvents();
    }

    private void OnBugReport(BugReportInfo report)
    {
        string line = _logs.WriteBug(report);
        LogMessage?.Invoke($"[BUG] {line}");
        BugReportReceived?.Invoke(report);
    }

    private void RaiseSessionEvents()
    {
        PlayerCountChanged?.Invoke(_sessions.Count);
        SessionsChanged?.Invoke();
    }

    private string DescribePlayer(int connectionId)
    {
        if (!_sessions.TryGetValue(connectionId, out var session)) return $"#{connectionId}";
        if (!string.IsNullOrWhiteSpace(session.Character?.Name)) return session.Character.Name;
        if (!string.IsNullOrWhiteSpace(session.Login)) return session.Login;
        return $"#{connectionId}";
    }

    private void Log(string message)
    {
        _logs.Write("SERVER", message);
        LogMessage?.Invoke(message);
    }

    private static bool IsConnectionFailure(Exception ex)
    {
        for (Exception? e = ex; e is not null; e = e.InnerException)
            if (e is HttpRequestException or SocketException or TimeoutException)
                return true;
        return false;
    }

    private static string ShortMessage(Exception ex)
    {
        Exception leaf = ex;
        while (leaf.InnerException is not null) leaf = leaf.InnerException;
        return leaf.Message;
    }

    public void Dispose()
    {
        _network.Dispose();
        _database.Dispose();
        _spacetimeProcess.Dispose();
        _logs.Dispose();
        _stop.Dispose();
    }
}

public sealed class PlayerSessionInfo
{
    public PlayerSessionInfo(int connectionId, string displayName, string login, string ipAddress, bool isPlaying, byte access)
    {
        ConnectionId = connectionId;
        DisplayName = string.IsNullOrWhiteSpace(displayName) ? $"Connection {connectionId}" : displayName;
        Login = login;
        IpAddress = ipAddress;
        IsPlaying = isPlaying;
        Access = access;
    }
    public int ConnectionId { get; }
    public string DisplayName { get; }
    public string Login { get; }
    public string IpAddress { get; }
    public bool IsPlaying { get; }
    public byte Access { get; }
    public override string ToString() => DisplayName;
}
