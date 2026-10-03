using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Eto.Drawing;
using Eto.Forms;

namespace Server;

public sealed class EtoServerForm : Form
{
    private readonly ServerSettings _settings;
    private readonly ListBox _players = EtoServerSkin.ListBox();
    private readonly ListBox _accounts = EtoServerSkin.ListBox();
    private readonly ListBox _bugs = EtoServerSkin.ListBox();
    private readonly TextArea _log = EtoServerSkin.TextArea();
    private readonly TextBox _chat = EtoServerSkin.TextBox();
    private readonly TextBox _port = EtoServerSkin.TextBox(true);
    private readonly TextBox _ip = EtoServerSkin.TextBox(true);
    private readonly TextBox _online = EtoServerSkin.TextBox(true);
    private ServerHost? _host;
    private CancellationTokenSource? _cts;
    private Task? _runTask;
    private List<PlayerSessionInfo> _sessions = new();

    public EtoServerForm(ServerSettings settings)
    {
        _settings = settings;
        Title = $"{settings.GameName} :: Server";
        ClientSize = new Size(780, 420);
        BackgroundColor = EtoServerSkin.Window;
        _port.Text = settings.Port.ToString();
        _ip.Text = "Detecting...";
        _online.Text = "0";

        Menu = BuildMenu();
        Content = new TabControl
        {
            Pages =
            {
                new TabPage { Text = "Chat", Content = BuildChat() },
                new TabPage { Text = "Bug Reports", Content = BuildBugs() },
                new TabPage { Text = "Game Information", Content = BuildInfo() }
            }
        };

        InstallPlayerMenu();
        Shown += async (_, _) =>
        {
            await StartAsync();
            await RefreshPublicIpAsync();
        };
        Closed += (_, _) => Stop();
    }

    private MenuBar BuildMenu()
    {
        var file = new ButtonMenuItem { Text = "File" };
        var exit = new ButtonMenuItem { Text = "Exit" };
        exit.Click += (_, _) => Close();
        file.Items.Add(exit);

        var database = new ButtonMenuItem { Text = "Database" };
        var scripts = new ButtonMenuItem { Text = "Script Editor..." };
        scripts.Click += (_, _) => new EtoScriptEditorForm().Show();
        var classes = new ButtonMenuItem { Text = "Reload Classes" };
        classes.Click += (_, _) => AppendLog("All classes reloaded.");
        var reload = new ButtonMenuItem { Text = "Reload Scripts" };
        reload.Click += (_, _) => AppendLog("Scripts reload requested.");
        database.Items.Add(scripts); database.Items.Add(classes); database.Items.Add(reload);

        var logs = new ButtonMenuItem { Text = "Log" };
        var open = new ButtonMenuItem { Text = "Open Logs Folder" };
        open.Click += (_, _) => OpenLogs();
        var clear = new ButtonMenuItem { Text = "Clear On-Screen Log" };
        clear.Click += (_, _) => _log.Text = string.Empty;
        var clearBugs = new ButtonMenuItem { Text = "Clear Bug Report List" };
        clearBugs.Click += (_, _) => _bugs.DataStore = Array.Empty<object>();
        logs.Items.Add(open); logs.Items.Add(clear); logs.Items.Add(clearBugs);

        return new MenuBar { Items = { file, database, logs } };
    }

    private Control BuildChat()
    {
        var send = new Button { Text = "Send" };
        send.Click += (_, _) => SendChat();
        _chat.KeyDown += (_, e) => { if (e.Key == Keys.Enter) { SendChat(); e.Handled = true; } };
        return new TableLayout
        {
            Padding = 8,
            Spacing = new Size(6, 6),
            Rows =
            {
                new TableRow(new TableCell(_log, true)) { ScaleHeight = true },
                new TableRow(new TableCell(_chat, true), send)
            }
        };
    }

    private Control BuildBugs() => new TableLayout { Padding = 8, Rows = { new TableRow(new TableCell(_bugs, true)) { ScaleHeight = true } } };

    private Control BuildInfo()
    {
        var left = new GroupBox { Text = "Players Online", Content = _players };
        var middle = new GroupBox { Text = "Accounts Online", Content = _accounts };
        var right = new StackLayout
        {
            Spacing = 6,
            Items =
            {
                new GroupBox { Text = "Game Port", Content = _port },
                new GroupBox { Text = "Total Online", Content = _online },
                new GroupBox { Text = "Game IP", Content = _ip }
            }
        };
        return new TableLayout
        {
            Padding = 7,
            Spacing = new Size(7, 0),
            Rows = { new TableRow(new TableCell(left, true), new TableCell(middle, true), new TableCell(right, false)) { ScaleHeight = true } }
        };
    }

    private void InstallPlayerMenu()
    {
        var access = new ButtonMenuItem { Text = "Access" };
        for (byte n = 0; n <= 9; n++)
        {
            byte level = n;
            var item = new ButtonMenuItem { Text = level.ToString() };
            item.Click += async (_, _) =>
            {
                var p = Selected();
                if (p is not null && _host is not null)
                    await _host.SetPlayerAccessAsync(p.ConnectionId, level);
            };
            access.Items.Add(item);
        }

        var kick = new ButtonMenuItem { Text = "Kick" };
        kick.Click += (_, _) => { var p = Selected(); if (p is not null) _host?.KickPlayer(p.ConnectionId); };
        var ban = new ButtonMenuItem { Text = "Ban" };
        ban.Click += async (_, _) => { var p = Selected(); if (p is not null && _host is not null) await _host.BanPlayerAsync(p.ConnectionId); };
        var menu = new ContextMenu { Items = { access, kick, ban } };
        foreach (var (label, mute, enabled) in new[] { ("Mute", true, true), ("Unmute", true, false), ("Jail", false, true), ("Release", false, false) })
        {
            var item = new ButtonMenuItem { Text = label };
            item.Click += (_, _) =>
            {
                var player = Selected();
                if (player is null || _host is null) return;
                if (mute) _host.SetPlayerMuted(player.ConnectionId, enabled);
                else _host.SetPlayerJailed(player.ConnectionId, enabled);
            };
            menu.Items.Add(item);
        }
        _players.ContextMenu = menu;
    }

    private async Task RefreshPublicIpAsync()
    {
        string address = await PublicIpResolver.ResolveAsync();
        Application.Instance.AsyncInvoke(() => _ip.Text = address);
    }

    private PlayerSessionInfo? Selected() => _players.SelectedIndex >= 0 && _players.SelectedIndex < _sessions.Count ? _sessions[_players.SelectedIndex] : null;

    private async Task StartAsync()
    {
        _cts = new CancellationTokenSource();
        _host = new ServerHost(_settings);
        _host.LogMessage += m => Application.Instance.AsyncInvoke(() => AppendLog(m));
        _host.PlayerCountChanged += n => Application.Instance.AsyncInvoke(() => _online.Text = n.ToString());
        _host.SessionsChanged += () => Application.Instance.AsyncInvoke(RefreshSessions);
        _host.BugReportReceived += b => Application.Instance.AsyncInvoke(() => AddBug(b));
        _runTask = Task.Run(async () =>
        {
            try { await _host.RunAsync(_cts.Token).ConfigureAwait(false); }
            catch (OperationCanceledException) { }
            catch (Exception ex) { Application.Instance.AsyncInvoke(() => AppendLog(ex.Message)); }
        });
        await Task.CompletedTask;
    }

    private void Stop()
    {
        _host?.RequestStop();
        _cts?.Cancel();
        _host?.Dispose();
        _cts?.Dispose();
    }

    private void RefreshSessions()
    {
        _sessions = _host?.GetSessions().ToList() ?? new List<PlayerSessionInfo>();
        _players.DataStore = _sessions;
        _accounts.DataStore = _sessions.Where(s => !string.IsNullOrWhiteSpace(s.Login)).Select(s => s.Login).Distinct(StringComparer.OrdinalIgnoreCase).ToList();
        _online.Text = _sessions.Count.ToString();
    }

    private void AddBug(BugReportInfo bug)
    {
        var all = new List<object> { bug };
        if (_bugs.DataStore is IEnumerable<object> existing) all.AddRange(existing);
        _bugs.DataStore = all;
    }

    private void SendChat()
    {
        string message = _chat.Text.Trim();
        if (message.Length == 0) return;
        _host?.BroadcastServerMessage(message);
        AppendLog($"Server: {message}");
        _chat.Text = string.Empty;
    }

    private void AppendLog(string message)
    {
        _log.Append(message + Environment.NewLine, true);
    }

    private void OpenLogs()
    {
        string path = _host?.LogDirectory ?? Path.Combine(AppContext.BaseDirectory, "logs");
        Directory.CreateDirectory(path);
        Process.Start(new ProcessStartInfo { FileName = path, UseShellExecute = true });
    }
}
