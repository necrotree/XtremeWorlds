using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;

namespace Server;

public sealed class ServerForm : Window
{
    private readonly ServerSettings _settings;
    private readonly ListBox _playersList;
    private readonly ListBox _accountsList;
    private readonly ListBox _bugReports;
    private readonly TextBox _chatLog;
    private readonly TextBox _chatInput;
    private readonly TextBox _portText;
    private readonly TextBox _ipText;
    private readonly TextBox _onlineText;
    private readonly TabControl _tabs;

    private ServerHost? _host;
    private CancellationTokenSource? _runCts;
    private Task? _runTask;
    private List<PlayerSessionInfo> _sessions = new();
    private int? _contextPlayerConnectionId;
    private bool _serverLogEnabled = true;

    public ServerForm(ServerSettings settings)
    {
        _settings = settings;
        Title = $"{settings.GameName} :: Server";
        Width = 790;
        Height = 445;
        MinWidth = 670;
        MinHeight = 390;
        WindowStartupLocation = WindowStartupLocation.CenterScreen;
        WpfServerSkin.Apply(this);

        var iconPath = System.IO.Path.Combine(AppContext.BaseDirectory, "Icon.ico");
        if (System.IO.File.Exists(iconPath))
            Icon = new System.Windows.Media.Imaging.BitmapImage(new Uri(iconPath));

        _playersList = WpfServerSkin.MakeListBox();
        _accountsList = WpfServerSkin.MakeListBox();
        _bugReports = WpfServerSkin.MakeListBox();
        _chatLog = MakeMultilineLog();
        _chatInput = WpfServerSkin.MakeTextBox();
        _chatInput.ToolTip = "Server chat message";
        _portText = WpfServerSkin.MakeTextBox(true);
        _ipText = WpfServerSkin.MakeTextBox(true);
        _onlineText = WpfServerSkin.MakeTextBox(true);
        _portText.Text = settings.Port.ToString();
        _ipText.Text = "Detecting...";
        _onlineText.Text = "0";

        _tabs = new TabControl { Margin = new Thickness(7) };
        WpfServerSkin.StyleTabs(_tabs);
        _tabs.Items.Add(new TabItem { Header = "Chat", Content = BuildChatPage() });
        _tabs.Items.Add(new TabItem { Header = "Bug Reports", Content = BuildBugPage() });
        _tabs.Items.Add(new TabItem { Header = "Game Information", Content = BuildGameInfoPage() });

        var root = new DockPanel { Background = WpfServerSkin.Window };
        var menu = BuildMenu();
        DockPanel.SetDock(menu, Dock.Top);
        root.Children.Add(menu);
        root.Children.Add(_tabs);
        Content = root;

        InstallPlayerContextMenu();

        _chatInput.KeyDown += (_, e) =>
        {
            if (e.Key == Key.Enter)
            {
                SendServerChat();
                e.Handled = true;
            }
        };

        Loaded += async (_, _) =>
        {
            await StartServerAsync();
            await RefreshPublicIpAsync();
        };
        Closing += (_, _) => StopServer();
        Closed += (_, _) =>
        {
            _host?.Dispose();
            _host = null;
            _runCts?.Dispose();
        };
    }

    private Menu BuildMenu()
    {
        var menu = new Menu();
        WpfServerSkin.StyleMenu(menu);

        var file = new MenuItem { Header = "File" };
        var exit = new MenuItem { Header = "Exit" };
        exit.Click += (_, _) => Close();
        file.Items.Add(exit);

        var database = new MenuItem { Header = "Database" };
        var scriptEditor = new MenuItem { Header = "Script Editor..." };
        scriptEditor.Click += (_, _) =>
        {
            var editor = new ScriptEditorForm { Owner = this };
            editor.Show();
        };
        var reloadClasses = new MenuItem { Header = "Reload Classes" };
        reloadClasses.Click += (_, _) => AppendServerLog("All classes reloaded.");
        var reloadScripts = new MenuItem { Header = "Reload Scripts" };
        reloadScripts.Click += (_, _) => AppendServerLog("Scripts reload requested.");
        database.Items.Add(scriptEditor);
        database.Items.Add(reloadClasses);
        database.Items.Add(reloadScripts);

        var log = new MenuItem { Header = "Log" };
        var serverLog = new MenuItem { Header = "Server Log", IsCheckable = true, IsChecked = true };
        serverLog.Click += (_, _) => _serverLogEnabled = serverLog.IsChecked;
        var openLogs = new MenuItem { Header = "Open Logs Folder" };
        openLogs.Click += (_, _) => OpenLogsFolder();
        var clearLog = new MenuItem { Header = "Clear On-Screen Log" };
        clearLog.Click += (_, _) => _chatLog.Clear();
        var clearBugs = new MenuItem { Header = "Clear Bug Report List" };
        clearBugs.Click += (_, _) => _bugReports.Items.Clear();
        log.Items.Add(serverLog);
        log.Items.Add(new Separator());
        log.Items.Add(openLogs);
        log.Items.Add(clearLog);
        log.Items.Add(clearBugs);

        menu.Items.Add(file);
        menu.Items.Add(database);
        menu.Items.Add(log);
        return menu;
    }

    private UIElement BuildChatPage()
    {
        var grid = new Grid { Margin = new Thickness(8) };
        grid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });
        grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });

        var logBorder = MakeInset(_chatLog);
        Grid.SetRow(logBorder, 0);
        grid.Children.Add(logBorder);

        var entry = new Grid { Margin = new Thickness(0, 6, 0, 0) };
        entry.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        entry.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        entry.Children.Add(_chatInput);
        var send = WpfServerSkin.MakeButton("Send", 72);
        send.Click += (_, _) => SendServerChat();
        Grid.SetColumn(send, 1);
        entry.Children.Add(send);
        Grid.SetRow(entry, 1);
        grid.Children.Add(entry);
        return grid;
    }

    private UIElement BuildBugPage()
    {
        return new Border
        {
            Margin = new Thickness(8),
            Background = WpfServerSkin.Panel,
            BorderBrush = WpfServerSkin.Bronze,
            BorderThickness = new Thickness(1),
            Padding = new Thickness(4),
            Child = _bugReports
        };
    }

    private UIElement BuildGameInfoPage()
    {
        var grid = new Grid { Margin = new Thickness(7) };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star), MinWidth = 190 });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star), MinWidth = 190 });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(250) });

        var players = WpfServerSkin.MakeGroup("Players Online", _playersList);
        Grid.SetColumn(players, 0);
        grid.Children.Add(players);

        var accounts = WpfServerSkin.MakeGroup("Accounts Online", _accountsList);
        Grid.SetColumn(accounts, 1);
        grid.Children.Add(accounts);

        var info = new Grid { Margin = new Thickness(2, 0, 0, 0) };
        info.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
        info.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
        info.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
        info.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });

        var port = WpfServerSkin.MakeGroup("Game Port", _portText);
        Grid.SetRow(port, 0);
        info.Children.Add(port);
        var online = WpfServerSkin.MakeGroup("Total Online", _onlineText);
        Grid.SetRow(online, 1);
        info.Children.Add(online);
        var ip = WpfServerSkin.MakeGroup("Game IP", _ipText);
        Grid.SetRow(ip, 2);
        info.Children.Add(ip);

        Grid.SetColumn(info, 2);
        grid.Children.Add(info);
        return grid;
    }

    private static Border MakeInset(UIElement content)
    {
        return new Border
        {
            Background = WpfServerSkin.Panel,
            BorderBrush = WpfServerSkin.Bronze,
            BorderThickness = new Thickness(1),
            Padding = new Thickness(4),
            Child = content
        };
    }

    private static TextBox MakeMultilineLog()
    {
        var box = WpfServerSkin.MakeTextBox(true);
        box.AcceptsReturn = true;
        box.AcceptsTab = true;
        box.TextWrapping = TextWrapping.NoWrap;
        box.VerticalScrollBarVisibility = ScrollBarVisibility.Auto;
        box.HorizontalScrollBarVisibility = ScrollBarVisibility.Auto;
        box.FontFamily = new FontFamily("Consolas");
        return box;
    }

    private async Task StartServerAsync()
    {
        if (_runTask is { IsCompleted: false })
            return;

        _runCts?.Dispose();
        _runCts = new CancellationTokenSource();
        _host?.Dispose();
        _host = new ServerHost(_settings);
        _host.LogMessage += message => Dispatcher.BeginInvoke(new Action(() => AppendServerLog(message)));
        _host.PlayerCountChanged += count => Dispatcher.BeginInvoke(new Action(() => _onlineText.Text = count.ToString()));
        _host.SessionsChanged += () => Dispatcher.BeginInvoke(new Action(RefreshSessions));
        _host.BugReportReceived += report => Dispatcher.BeginInvoke(new Action(() => _bugReports.Items.Insert(0, report)));

        _runTask = Task.Run(async () =>
        {
            try
            {
                await _host.RunAsync(_runCts.Token).ConfigureAwait(false);
            }
            catch (OperationCanceledException)
            {
            }
            catch (Exception ex)
            {
                Dispatcher.BeginInvoke(new Action(() => AppendServerLog(ex.ToString())));
            }
        });

        await Task.CompletedTask;
    }

    private void StopServer()
    {
        _host?.RequestStop();
        _runCts?.Cancel();
    }

    private void RefreshSessions()
    {
        _sessions = _host?.GetSessions().ToList() ?? new List<PlayerSessionInfo>();
        var selectedConnectionId = SelectedPlayer()?.ConnectionId;
        _playersList.ItemsSource = _sessions;
        if (selectedConnectionId is not null)
        {
            var matchingPlayer = _sessions.FirstOrDefault(p => p.ConnectionId == selectedConnectionId.Value);
            if (matchingPlayer is not null)
                _playersList.SelectedItem = matchingPlayer;
        }
        _accountsList.ItemsSource = _sessions
            .Where(s => !string.IsNullOrWhiteSpace(s.Login))
            .Select(s => s.Login)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();
        _onlineText.Text = _sessions.Count.ToString();
    }

    private PlayerSessionInfo? SelectedPlayer() => _playersList.SelectedItem as PlayerSessionInfo;

    private PlayerSessionInfo? ContextPlayer()
    {
        if (_contextPlayerConnectionId is not int connectionId)
            return SelectedPlayer();
        return _sessions.FirstOrDefault(player => player.ConnectionId == connectionId);
    }

    private void InstallPlayerContextMenu()
    {
        _playersList.PreviewMouseRightButtonDown += (_, e) =>
        {
            var element = e.OriginalSource as DependencyObject;
            while (element is not null && element is not ListBoxItem)
                element = VisualTreeHelper.GetParent(element);
            if (element is ListBoxItem item)
                item.IsSelected = true;
        };

        var menu = new ContextMenu
        {
            Background = WpfServerSkin.PanelAlt,
            Foreground = WpfServerSkin.Gold,
            BorderBrush = WpfServerSkin.Bronze,
            BorderThickness = new Thickness(1),
            Padding = new Thickness(2)
        };
        WpfServerSkin.StylePlayerContextMenu(menu);
        menu.Opened += (_, _) => _contextPlayerConnectionId = SelectedPlayer()?.ConnectionId;
        menu.Closed += (_, _) => Dispatcher.BeginInvoke(new Action(() => _contextPlayerConnectionId = null),
            System.Windows.Threading.DispatcherPriority.Background);

        var access = new MenuItem { Header = "Access" };
        for (byte i = 0; i <= 9; i++)
        {
            byte level = i;
            var accessItem = new MenuItem
            {
                Header = level.ToString(),
                MinWidth = 42,
                HorizontalContentAlignment = HorizontalAlignment.Center
            };
            accessItem.Click += async (_, _) => await SetSelectedAccessAsync(level);
            access.Items.Add(accessItem);
        }

        var kick = new MenuItem { Header = "Kick" };
        kick.Click += (_, _) => KickSelectedPlayer();
        var ban = new MenuItem { Header = "Ban" };
        ban.Click += async (_, _) => await BanSelectedPlayerAsync();

        menu.Items.Add(access);
        foreach (var (label, mute, enabled) in new[] { ("Mute", true, true), ("Unmute", true, false), ("Jail", false, true), ("Release", false, false) })
        {
            var item = new MenuItem { Header = label };
            item.Click += (_, _) =>
            {
                var player = ContextPlayer();
                if (player is null || _host is null) return;
                if (mute) _host.SetPlayerMuted(player.ConnectionId, enabled);
                else _host.SetPlayerJailed(player.ConnectionId, enabled);
            };
            menu.Items.Add(item);
        }
        menu.Items.Add(kick);
        menu.Items.Add(ban);
        _playersList.ContextMenu = menu;
    }

    private async Task RefreshPublicIpAsync()
    {
        string address = await PublicIpResolver.ResolveAsync();
        if (!Dispatcher.HasShutdownStarted)
            Dispatcher.BeginInvoke(new Action(() => _ipText.Text = address));
    }

    private void KickSelectedPlayer()
    {
        var player = ContextPlayer();
        if (player is null || _host is null)
            return;
        _host.KickPlayer(player.ConnectionId);
    }

    private async Task BanSelectedPlayerAsync()
    {
        var player = ContextPlayer();
        if (player is null || _host is null)
            return;
        if (MessageBox.Show(this, $"Ban {player.DisplayName}?", "Ban Player", MessageBoxButton.YesNo, MessageBoxImage.Warning) == MessageBoxResult.Yes)
            await _host.BanPlayerAsync(player.ConnectionId);
    }

    private async Task SetSelectedAccessAsync(byte access)
    {
        var player = ContextPlayer();
        if (player is null || _host is null)
            return;
        await _host.SetPlayerAccessAsync(player.ConnectionId, access);
    }

    private void SendServerChat()
    {
        string message = _chatInput.Text.Trim();
        if (message.Length == 0)
            return;
        _host?.BroadcastServerMessage(message);
        _chatLog.AppendText($"Server: {message}{Environment.NewLine}");
        _chatLog.ScrollToEnd();
        _chatInput.Clear();
    }

    private void OpenLogsFolder()
    {
        string path = _host?.LogDirectory ?? System.IO.Path.Combine(AppContext.BaseDirectory, "logs");
        System.IO.Directory.CreateDirectory(path);
        System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo { FileName = path, UseShellExecute = true });
    }

    private void AppendServerLog(string message)
    {
        if (!_serverLogEnabled)
            return;
        _chatLog.AppendText(message + Environment.NewLine);
        _chatLog.ScrollToEnd();
    }
}
