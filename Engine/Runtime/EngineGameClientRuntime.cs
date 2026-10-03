using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using Eto.Forms;
using XtremeWorlds.Client.Engine.Audio;
using XtremeWorlds.Client.Engine.Graphics;
using XtremeWorlds.Client.Engine.Networking;
using XtremeWorlds.Client.Forms;
using XtremeWorlds.Client.Logic;

namespace XtremeWorlds.Client.Engine.Runtime;

/// <summary>
/// Concrete client runtime replacing the old WinSock/BASS/DX11 integration.
/// Eto owns menus/editors, FNA owns game rendering, FAudio is used by FNA's
/// Audio/Media namespaces, and Mirror's Telepathy transport owns TCP.
/// </summary>
public sealed class EngineGameClientRuntime : IGameClientRuntime, IDisposable
{
    private readonly MirrorTcpClient _network = new();
    private readonly UITimer _networkTimer = new() { Interval = 0.02 };
    private readonly FnaAudioService _audio = new();
    private readonly FnaGraphicsService _graphics = new();
    private readonly List<GameClassInfo> _classes = new();
    private string _serverHost = "127.0.0.1";
    private int _serverPort = 7234;
    private bool _disposed;
    private bool _loginPending;
    private bool _loginConnectionEstablished;
    private bool _accountCreationPending;
    private DateTime _loginDeadline;

    public EngineGameClientRuntime()
    {
        Website = "https://www.xtremeworlds.com";
        CurrentSex = 1;
        _network.DataReceived += OnNetworkData;
        _network.Connected += (_, _) =>
        {
            _loginConnectionEstablished = true;
            Request("Connected", _serverHost, _serverPort);
        };
        _network.Disconnected += (_, _) =>
        {
            Request("Disconnected");
            if (_loginPending)
                FailLoginConnection(_loginConnectionEstablished
                    ? "The server accepted the connection, then disconnected. Check that you are running the matching Telepathy server. An older XtremeWorlds server uses an incompatible protocol; close it if it is also listening on port 7234."
                    : $"Unable to connect to {_serverHost}:{_serverPort}. Check the server address and that the game server is listening on this port.");
        };
        // Telepathy queues callbacks until Tick is called. Keep receiving replies
        // after a send returns, on the same UI thread as connection/menu actions.
        _networkTimer.Elapsed += (_, _) =>
        {
            _network.Tick();
            // This runtime consumes packets through DataReceived, not TryDequeue.
            while (_network.TryDequeue(out _)) { }
            if (_loginPending && DateTime.UtcNow >= _loginDeadline)
            {
                FailLoginConnection("The game server is not responding. Please try again in a few minutes.");
                _network.Disconnect();
            }
        };

        // Preserve the five current menu choices until the server sends class data.
        foreach (var name in new[] { "Fighter", "Wizard", "Celestial", "Guardian", "Assassin" })
            _classes.Add(new GameClassInfo { Name = name });
    }

    public string Website { get; set; }
    public bool SaveLogin { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public int CurrentClass { get; set; }
    public int CurrentSex { get; set; }
    public IReadOnlyList<GameClassInfo> Classes => _classes;

    public event EventHandler<GameClientActionEventArgs>? ActionRequested;

    public void InitializeMenu()
    {
        _networkTimer.Start();
        Request("InitializeMenu");
        // FNA/FAudio accepts WAV/OGG. Prefer menu.ogg, then fall back to the
        // supplied legacy numbered music library.
        var menuMusic = System.IO.Path.Combine(AppContext.BaseDirectory, "music", "menu.ogg");
        if (!System.IO.File.Exists(menuMusic))
            menuMusic = System.IO.Path.Combine(AppContext.BaseDirectory, "music", "Music1.ogg");
        if (System.IO.File.Exists(menuMusic))
            _audio.PlayMusic(menuMusic, true);
    }

    public void SaveLoginCredentials(string username, string password)
    {
        Username = (username ?? string.Empty).Trim();
        Password = password ?? string.Empty;
        Request("SaveLoginCredentials", Username, Password, SaveLogin);
    }

    public async void MenuState(MenuState state, string? text = null, int selectedIndex = -1)
    {
        Request("MenuState", state, text ?? string.Empty, selectedIndex, CurrentClass, CurrentSex);

        switch (state)
        {
            case XtremeWorlds.Client.Logic.MenuState.NewAccount:
                if (!EnsureConnected()) return;
                _accountCreationPending = true;
                SendPacket("newaccount", text ?? Username, Password, string.Empty);
                break;

            case XtremeWorlds.Client.Logic.MenuState.Login:
                if (_loginPending) return;
                _loginPending = true;
                _loginConnectionEstablished = _network.IsConnected;
                _loginDeadline = DateTime.UtcNow.AddSeconds(15);
                Request("LoginStatus", "Connecting to the game server…", true);
                try
                {
                    if (!_network.IsConnected)
                    {
                        _network.Connect(_serverHost, _serverPort);
                        var connectionDeadline = DateTime.UtcNow.AddSeconds(4);
                        while (!_network.IsConnected && DateTime.UtcNow < connectionDeadline && !_disposed && _loginPending)
                        {
                            _network.Tick();
                            await System.Threading.Tasks.Task.Delay(20);
                        }
                    }
                    if (_disposed || !_loginPending) return;
                    if (!_network.IsConnected)
                    {
                        FailLoginConnection();
                        _network.Disconnect();
                        return;
                    }
                    Request("LoginStatus", "Logging in…", true);
                    SendPacket("login", Username, Password, 1, 0, 0, string.Empty);
                }
                catch (Exception exception)
                {
                    if (!_disposed)
                    {
                        var message = _network.IsConnected
                            ? $"Connected to the server, but could not continue login: {exception.Message}"
                            : $"Unable to connect to {_serverHost}:{_serverPort}: {exception.Message}";
                        FinishLogin(message);
                        Ui(() => GameDialogs.Alert(Application.Instance?.MainForm, message, "Login error"));
                    }
                }
                break;

            case XtremeWorlds.Client.Logic.MenuState.NewCharacter:
                if (!EnsureConnected()) return;
                _classes.Clear();
                CurrentClass = 0;
                SendPacket("getclasses");
                break;

            case XtremeWorlds.Client.Logic.MenuState.AddCharacter:
                if (!EnsureConnected()) return;
                // Original client sent male=0/female=1 while CurrentSex was 1/0.
                var wireSex = CurrentSex == 1 ? 0 : 1;
                SendPacket("addchar", text ?? string.Empty, wireSex, CurrentClass, selectedIndex + 1);
                break;

            case XtremeWorlds.Client.Logic.MenuState.DeleteCharacter:
                if (!EnsureConnected()) return;
                SendPacket("delchar", selectedIndex + 1);
                break;

            case XtremeWorlds.Client.Logic.MenuState.UseCharacter:
                if (!EnsureConnected()) return;
                SendPacket("getgamename");
                SendPacket("getgamesite");
                SendPacket("getgamemaxes");
                SendPacket("usechar", selectedIndex + 1);
                break;
        }
    }

    public void Disconnect()
    {
        _accountCreationPending = false;
        FinishLogin(string.Empty);
        _network.Disconnect();
    }

    public void RefreshWebsite()
    {
        if (_network.IsConnected)
            SendPacket("getgamesite");
        Request("GetGameSite");
    }

    public void RefreshNewCharacterPreview(int classIndex, int sex)
    {
        Request("NewCharBltSprite", classIndex, sex);
    }

    public void OpenWebsite()
    {
        var address = (Website ?? string.Empty).Trim();
        if (address.Length == 0) return;
        if (!address.StartsWith("http://", StringComparison.OrdinalIgnoreCase) &&
            !address.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
            address = "https://" + address.TrimStart('/');

        try
        {
            System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo(address) { UseShellExecute = true });
        }
        catch
        {
            Request("OpenWebsite", address);
        }
    }

    public void GameDestroy()
    {
        Dispose();
        if (Application.Instance is not null)
            Application.Instance.Quit();
    }

    public void UpdateServerIp(string ipAddress)
    {
        if (!string.IsNullOrWhiteSpace(ipAddress))
            _serverHost = ipAddress.Trim();
        Request("UpdateServerIp", _serverHost);
    }

    public void MainGameAction(string actionName, params object[] arguments)
    {
        actionName ??= string.Empty;
        switch (actionName)
        {
            case "Form_Load":
                _graphics.Start(1024, 768);
                break;
            case "SendChat":
                SendPacket("saymsg", Arg(arguments, 0));
                break;
            case "UseInventoryItem":
                SendPacket("USEITEM", IntArg(arguments, 0) + 1);
                break;
            case "CastSpell":
                SendPacket("cast", IntArg(arguments, 0) + 1);
                break;
            case "PlaySound":
                _audio.PlaySound(Arg(arguments, 0));
                break;
            case "PlayMusic":
                _audio.PlayMusic(Arg(arguments, 0), true);
                break;
            case "StopMusic":
                _audio.StopMusic();
                break;
            case "Kick":
                SendPacket("KICKPLAYER", Arg(arguments, 0));
                break;
            case "Ban":
                SendPacket("BANPLAYER", Arg(arguments, 0));
                break;
            case "ClearBanList":
                SendPacket("BANDESTROY");
                break;
            case "RespawnMap":
                SendPacket("MAPRESPAWN");
                break;
            case "WarpTo":
                SendPacket("WARPTO", Arg(arguments, 0));
                break;
            case "SetAccess":
                SendPacket("SETACCESS", Arg(arguments, 0), Arg(arguments, 1));
                break;
            case "SetSprite":
                SendPacket("SETSPRITE", Arg(arguments, 0));
                break;
            case "PlayerSprite":
                SendPacket("PLAYERSPRITE", 0, Arg(arguments, 0));
                break;
            case "Location":
                SendPacket("REQUESTLOCATION");
                break;
            case "ItemEditor":
                SendPacket("REQUESTEDITITEM");
                break;
            case "NpcEditor":
                SendPacket("REQUESTEDITNPC");
                break;
            case "ShopEditor":
                SendPacket("REQUESTEDITSHOP");
                break;
            case "SpellEditor":
                SendPacket("REQUESTEDITSPELL");
                break;
            case "MapEditor":
                SendPacket("REQUESTEDITMAP");
                break;
            case "SignEditor":
                SendPacket("REQUESTEDITSIGN");
                break;
            case "ArrowEditor":
                SendPacket("REQUESTEDITARROW");
                break;
            case "ClassEditor":
                SendPacket("REQUESTEDITCLASS");
                break;
            case "PromptServerIp":
                PromptServerIp();
                break;
            default:
                Request(actionName, arguments);
                return;
        }

        Request(actionName, arguments);
    }

    private bool EnsureConnected()
    {
        if (_network.IsConnected) return true;
        var connected = _network.ConnectAndWait(_serverHost, _serverPort, TimeSpan.FromSeconds(4));
        if (!connected)
        {
            Ui(() => GameDialogs.Alert(Application.Instance?.MainForm, "Sorry, the server seems to be down. Please try again in a few minutes.", "Alert"));
        }
        return connected;
    }

    private void SendPacket(string command, params object?[] values)
    {
        if (!EnsureConnected()) return;
        _network.SendText(PacketCodec.Build(command, values));
        _network.Tick();
    }

    private void OnNetworkData(object? sender, NetworkDataEventArgs e)
    {
        var text = Encoding.UTF8.GetString(e.Data);
        var fields = PacketCodec.Parse(text);
        if (fields.Count == 0) return;

        var command = fields[0].Trim().ToLowerInvariant();
        switch (command)
        {
            case "alertmsg":
                if (string.Equals(Field(fields, 1), "Your account has been created!", StringComparison.OrdinalIgnoreCase))
                {
                    if (_accountCreationPending)
                    {
                        _accountCreationPending = false;
                        MenuState(XtremeWorlds.Client.Logic.MenuState.Login);
                    }
                    break;
                }
                if (_accountCreationPending)
                {
                    _accountCreationPending = false;
                }
                if (_loginPending) FinishLogin(Field(fields, 1));
                Ui(() => GameDialogs.Alert(Application.Instance?.MainForm, Field(fields, 1), "Alert"));
                break;
            case "allchars":
            case "chars":
                FinishLogin(string.Empty);
                HandleAllCharacters(fields);
                break;
            case "newcharclasses":
                // The current server sends one class per packet, keyed by class ID.
                if (fields.Count == 9)
                {
                    HandleClassDefinition(fields);
                    break;
                }
                HandleClasses(fields);
                break;
            case "classesdata":
                HandleClasses(fields);
                break;
            case "ingame":
                Ui(ShowMainGame);
                break;
            default:
                Request("PacketReceived", fields.ToArray());
                break;
        }
    }

    private void HandleAllCharacters(IReadOnlyList<string> fields)
    {
        Ui(() =>
        {
            if (Application.Instance?.MainForm is not frmMainMenu menu) return;
            menu.lstChars.Items.Clear();
            var hasCharacters = false;
            var firstCharacter = -1;
            var namesOnly = string.Equals(Field(fields, 0), "chars", StringComparison.OrdinalIgnoreCase);
            var offset = 1;
            for (var slot = 0; slot < 3; slot++)
            {
                var name = Field(fields, offset);
                var className = namesOnly ? string.Empty : Field(fields, offset + 1);
                var level = namesOnly ? 0 : IntField(fields, offset + 2);
                var sprite = namesOnly ? 0 : IntField(fields, offset + 3);
                hasCharacters |= !string.IsNullOrWhiteSpace(name);
                if (firstCharacter < 0 && !string.IsNullOrWhiteSpace(name)) firstCharacter = slot;
                menu.SetCharacterSlot(slot, name, sprite);
                menu.lstChars.Items.Add(string.IsNullOrWhiteSpace(name)
                    ? "Free Character Slot"
                    : namesOnly ? name : $"{name} a level {level} {className}");
                offset += namesOnly ? 1 : 4;
            }
            menu.SelectCharacterSlot(hasCharacters ? firstCharacter : 0);
            if (hasCharacters)
                menu.ShowCharacters();
            else
                menu.StartCharacterCreation();
        });
    }

    private void FailLoginConnection(string message = "Unable to connect to the game server. Check the server address and port, then try again.")
    {
        if (!_loginPending) return;
        FinishLogin(message);
        Ui(() => GameDialogs.Alert(Application.Instance?.MainForm, message, "Connection interrupted"));
    }

    private void FinishLogin(string message)
    {
        _loginPending = false;
        Request("LoginStatus", message, false);
    }

    private void HandleClassDefinition(IReadOnlyList<string> fields)
    {
        var classId = IntField(fields, 1);
        if (classId < 0) return;
        while (_classes.Count <= classId)
            _classes.Add(new GameClassInfo());
        _classes[classId] = new GameClassInfo
        {
            Name = Field(fields, 2),
            MaleSprite = IntField(fields, 3),
            FemaleSprite = IntField(fields, 4),
            STR = IntField(fields, 5),
            DEF = IntField(fields, 6),
            Speed = IntField(fields, 7),
            MAGI = IntField(fields, 8)
        };
        Ui(() =>
        {
            if (Application.Instance?.MainForm is frmMainMenu menu)
                menu.RefreshCharacterClasses();
        });
    }

    private void HandleClasses(IReadOnlyList<string> fields)
    {
        var count = IntField(fields, 1);
        if (count <= 0) return;

        _classes.Clear();
        var n = 2;
        for (var i = 0; i < count && n < fields.Count; i++)
        {
            var info = new GameClassInfo { Name = Field(fields, n) };
            // Known packet layouts include HP/MP/SP before STR/DEF/Speed/MAGI.
            if (n + 7 < fields.Count)
            {
                info.STR = IntField(fields, n + 4);
                info.DEF = IntField(fields, n + 5);
                info.Speed = IntField(fields, n + 6);
                info.MAGI = IntField(fields, n + 7);
            }
            _classes.Add(info);
            n += commandStride(fields, n);
        }
        CurrentClass = 0;
        Ui(() =>
        {
            if (Application.Instance?.MainForm is frmMainMenu menu)
                menu.RefreshCharacterClasses();
        });

        static int commandStride(IReadOnlyList<string> packet, int index)
        {
            // newcharclasses has sprite fields as well; classesdata usually does not.
            return index + 9 < packet.Count ? 10 : 8;
        }
    }

    private void ShowMainGame()
    {
        if (Application.Instance is null) return;
        var menu = Application.Instance.MainForm;
        var game = new frmMainGame(this);
        if (menu is not null) menu.Visible = false;
        game.Show();
    }

    private void PromptServerIp()
    {
        Ui(() =>
        {
            var dialog = new Dialog<string> { Title = "Server IP", ClientSize = new Eto.Drawing.Size(360, 100) };
            var text = new TextBox { Text = _serverHost };
            var ok = new Button { Text = "OK" };
            var cancel = new Button { Text = "Cancel" };
            ok.Click += (_, _) => { dialog.Close(text.Text?.Trim() ?? _serverHost); };
            cancel.Click += (_, _) => dialog.Close(_serverHost);
            var layout = new DynamicLayout
            {
                Padding = 10,
                Spacing = new Eto.Drawing.Size(5, 5)
            };
            layout.AddRow(new Label { Text = "Server address:" }, text);
            layout.AddRow(null, ok, cancel);
            dialog.Content = layout;
            var result = dialog.ShowModal(Application.Instance.MainForm);
            if (!string.IsNullOrWhiteSpace(result)) _serverHost = result.Trim();
        });
    }

    private static string Arg(object[] args, int index) => index < args.Length ? Convert.ToString(args[index], CultureInfo.InvariantCulture) ?? string.Empty : string.Empty;
    private static int IntArg(object[] args, int index) => int.TryParse(Arg(args, index), NumberStyles.Integer, CultureInfo.InvariantCulture, out var value) ? value : 0;
    private static string Field(IReadOnlyList<string> fields, int index) => index >= 0 && index < fields.Count ? fields[index] : string.Empty;
    private static int IntField(IReadOnlyList<string> fields, int index) => int.TryParse(Field(fields, index), NumberStyles.Integer, CultureInfo.InvariantCulture, out var value) ? value : 0;

    private static void Ui(Action action)
    {
        if (Application.Instance is null) return;
        Application.Instance.AsyncInvoke(action);
    }

    private void Request(string name, params object[] arguments)
    {
        ActionRequested?.Invoke(this, new GameClientActionEventArgs(name, arguments));
    }

    public void Dispose()
    {
        if (_disposed) return;
        _disposed = true;
        _networkTimer.Stop();
        _networkTimer.Dispose();
        _graphics.Dispose();
        _audio.Dispose();
        _network.Dispose();
    }
}
