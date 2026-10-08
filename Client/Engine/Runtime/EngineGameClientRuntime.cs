using XtremeWorlds.Networking;
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
    private readonly GameClientConnection _connection;
    private MirrorTcpClient _network => _connection.Transport;
    private readonly XtremeWorlds.Client.Tools.ToolController _tools;
    private readonly UITimer _networkTimer = new() { Interval = 0.02 };
    private readonly FnaAudioService _audio = new();
    private readonly FnaGraphicsService _graphics = new();
    private readonly List<GameClassInfo> _classes = new();
    private string _serverHost = "127.0.0.1";
    private int _serverPort = 7234;
    private bool _disposed;
    private readonly HashSet<EditForm> _editForms = new();
    public void ShowEditForm(EditForm form)
    {
        ArgumentNullException.ThrowIfNull(form);
        ObjectDisposedException.ThrowIf(_disposed, this);
        Ui(() =>
        {
            if (_disposed) return;
            if (_editForms.Add(form))
            {
                form.PreviewRequested += OnEditorPreview;
                form.Closed += OnEditorClosed;
            }
            if (!form.Visible) form.Show();
            form.BringToFront();
        });
    }
    private void OnEditorPreview(object? sender, EditorPreviewEventArgs preview)
    {
        if (_disposed || !_graphics.IsRunning) return;
        _graphics.Submit(new FnaSpriteCommand(preview.TexturePath,
            new Microsoft.Xna.Framework.Rectangle(preview.X, preview.Y, preview.Width, preview.Height),
            null, Microsoft.Xna.Framework.Color.White));
    }
    private void OnEditorClosed(object? sender, EventArgs args)
    {
        if (sender is not EditForm form) return;
        form.PreviewRequested -= OnEditorPreview;
        form.Closed -= OnEditorClosed;
        _editForms.Remove(form);
    }

    public EngineGameClientRuntime()
    {
        _connection = new GameClientConnection(_graphics);
        _connection.PacketReceived += OnNetworkPacket;
        _tools = new XtremeWorlds.Client.Tools.ToolController((command, arguments) => SendPacket(command, arguments), MainGameAction);
        Website = "https://www.xtremeworlds.com";
        CurrentSex = 1;
        _network.Connected += (_, _) => Request("Connected", _serverHost, _serverPort);
        _network.Disconnected += (_, _) =>
        {
            _graphics.NetworkState.Rollback();
            Request("Disconnected");

            if (_disposed)
                return;

            Ui(ReturnToLogin);
        };

        // Telepathy queues received messages until Tick() runs. Pump continuously
        // while the menu is active so a response to Register cannot sit queued
        // until the next Login click and appear to be a login response.
        _networkTimer.Elapsed += (_, _) => _connection.Tick();

        _graphics.MainGameActionRequested += OnFnaMainGameAction;

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
        // FNA/FAudio accepts WAV/OGG; keep startup silent when no menu track exists.
        var menuMusic = System.IO.Path.Combine(AppContext.BaseDirectory, "music", "menu.ogg");
        if (System.IO.File.Exists(menuMusic))
            _audio.PlayMusic(menuMusic, true);
    }

    public void SaveLoginCredentials(string username, string password)
    {
        Username = (username ?? string.Empty).Trim();
        Password = password ?? string.Empty;
        Request("SaveLoginCredentials", Username, Password, SaveLogin);
    }

    public void MenuState(MenuState state, string? text = null, int selectedIndex = -1)
    {
        Request("MenuState", state, text ?? string.Empty, selectedIndex, CurrentClass, CurrentSex);

        switch (state)
        {
            case XtremeWorlds.Client.Logic.MenuState.NewAccount:
                if (!EnsureConnected()) return;
                SendPacket("newaccount", text ?? Username, Password, string.Empty);
                break;

            case XtremeWorlds.Client.Logic.MenuState.Login:
                if (!EnsureConnected()) return;
                SendPacket("login", Username, Password, 1, 0, 0, string.Empty);
                break;

            case XtremeWorlds.Client.Logic.MenuState.NewCharacter:
                if (!EnsureConnected()) return;
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

    public void Disconnect() => _network.Disconnect();

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
        if (_connection.HandleAction(actionName, arguments)) { Request(actionName, arguments); return; }
        switch (actionName)
        {
            case "Form_Load":
                _graphics.Start(FnaGraphicsService.InterfaceWidth, FnaGraphicsService.InterfaceHeight);
                break;
            case "ToggleGuild":
                Request("GuildInfo");
                break;
            case "ShowOptions":
                Ui(() => new frmOptions().Show());
                break;
            case "ShowBugReport":
                Ui(() => new frmBugReport().Show());
                break;
            case "OpenWebsite":
                OpenWebsite();
                break;
            case "GameDestroy":
                GameDestroy();
                break;
            case "SendChatChannel":
                SendChat(Arg(arguments, 1));
                break;
            case "SendChat":
                SendChat(Arg(arguments, 0));
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
            case "Mute":
                SendPacket("MUTEPLAYER", Arg(arguments, 0));
                break;
            case "Unmute":
                SendPacket("UNMUTEPLAYER", Arg(arguments, 0));
                break;
            case "Jail":
                SendPacket("JAILPLAYER", Arg(arguments, 0));
                break;
            case "Unjail":
                SendPacket("UNJAILPLAYER", Arg(arguments, 0));
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
            case "WarpToTile":
                SendPacket("WARPTOTILE", Arg(arguments, 0), Arg(arguments, 1));
                break;
            case "SetAccess":
                SendPacket("SETACCESS", Arg(arguments, 0), Arg(arguments, 1));
                break;
            case "SetSprite":
                SendPacket("SETSPRITE", Arg(arguments, 0));
                break;
            case "PlayerSprite":
                SendPacket("PLAYERSPRITE", Arg(arguments, 1), Arg(arguments, 0));
                break;
            case "Location":
                SendPacket("REQUESTLOCATION");
                break;
            case "ItemEditor":
                Ui(() => _tools.Open("item"));
                break;
            case "NpcEditor":
                Ui(() => _tools.Open("npc"));
                break;
            case "ShopEditor":
                Ui(() => _tools.Open("shop"));
                break;
            case "SpellEditor":
                Ui(() => _tools.Open("spell"));
                break;
            case "MapEditor":
                Ui(() => _tools.Open("map"));
                break;
            case "SignEditor":
                Ui(() => _tools.Open("sign"));
                break;
            case "ArrowEditor":
                Ui(() => _tools.Open("arrow"));
                break;
            case "ClassEditor":
                Ui(() => _tools.Open("class"));
                break;
            case "BookEditor":
                Ui(() => _tools.Open("book"));
                break;
            case "QuestEditor":
                Ui(() => _tools.Open("quest"));
                break;
            case "EmoteEditor":
                Ui(() => _tools.Open("emote"));
                break;
            case "ShowAdminPanel":
                Ui(_tools.OpenAdmin);
                break;
            case "MapReport":
                SendPacket("mapreport");
                break;
            case "SetJail":
                SendPacket("moderation", "setjail", "");
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

    private void OnFnaMainGameAction(string actionName, object[] arguments)
    {
        // FNA owns the main-game hit testing. Keep all game/network actions routed
        // through the same runtime API used by the converted twinBASIC form.
        MainGameAction(actionName, arguments);
    }

    private bool EnsureConnected()
    {
        if (_network.IsConnected) return true;
        var connected = _network.ConnectAndWait(_serverHost, _serverPort, TimeSpan.FromSeconds(4));
        if (!connected)
        {
            Ui(() => frmAlert.ShowAlert(Application.Instance?.MainForm, "Sorry, the server seems to be down. Please try again in a few minutes.", "XtremeWorlds"));
        }
        return connected;
    }

    private void SendChat(string text)
    {
        string trimmed = text.Trim();
        int separator = trimmed.IndexOf(' ');
        string command = (separator < 0 ? trimmed : trimmed[..separator]).ToLowerInvariant();
        if (command is "/admin" or "/bookeditor" or "/questeditor" or "/emoteeditor" or "/mapeditor")
        {
            MainGameAction(command switch { "/admin" => "ShowAdminPanel", "/bookeditor" => "BookEditor", "/questeditor" => "QuestEditor", "/emoteeditor" => "EmoteEditor", _ => "MapEditor" });
            return;
        }
        if (command is "/mute" or "/unmute" or "/jail" or "/unjail")
        {
            string player = separator < 0 ? string.Empty : trimmed[(separator + 1)..].Trim();
            SendPacket(command[1..] + "player", player);
            return;
        }
        if (command is "/warpmeto" or "/warptome")
        {
            SendPacket(command[1..], separator < 0 ? string.Empty : trimmed[(separator + 1)..].Trim());
            return;
        }
        if (command == "/warpto")
        {
            SendPacket("warpto", trimmed.Split(' ', StringSplitOptions.RemoveEmptyEntries).Skip(1).Cast<object?>().ToArray());
            return;
        }
        SendPacket("saymsg", text);
    }

    private void SendPacket(string command, params object?[] values)
    {
        if (!EnsureConnected()) return;

        // Do not call Tick() from inside SendPacket. Telepathy invokes
        // OnNetworkData while Tick() is draining its receive queue, and a
        // receive handler that sends another packet would recursively re-enter
        // Tick -> OnNetworkData -> SendPacket until the stack overflows.
        // The menu UITimer / game loop already pumps the network continuously.
        _network.SendText(PacketCodec.Build(command, values));
    }

    private void OnNetworkPacket(IReadOnlyList<string> fields)
    {
        var command = fields[0].Trim().ToLowerInvariant();
        if (command is "toolaccess" or "toolindex" or "toolrecord" or "toolsaved" or "toolerror")
        {
            Ui(() => _tools.HandlePacket(fields));
            return;
        }
        switch (command)
        {
            case "alertmsg":
                Ui(() => frmAlert.ShowAlert(Application.Instance?.MainForm, Field(fields, 1), "XtremeWorlds"));
                break;
            case "allchars":
            case "chars":
                HandleAllCharacters(fields);
                break;
            case "newcharclasses":
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
            case "playermsg":
                _graphics.AddChatMessage("System", Field(fields, 1));
                break;
            case "maperror":
                _graphics.AddChatMessage("System", Field(fields, 2));
                break;
            case "ingame":
                _graphics.SetWorldScene(new FnaWorldScene());
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

            bool namesOnly = string.Equals(Field(fields, 0), "chars", StringComparison.OrdinalIgnoreCase);
            int offset = 1;

            for (var slot = 0; slot < 3; slot++)
            {
                var name = Field(fields, offset);
                var className = namesOnly ? string.Empty : Field(fields, offset + 1);
                var level = namesOnly ? 0 : IntField(fields, offset + 2);
                var sprite = namesOnly ? 0 : IntField(fields, offset + 3);

                menu.SetCharacterSlot(slot, name, sprite);
                menu.lstChars.Items.Add(string.IsNullOrWhiteSpace(name)
                    ? "Free Character Slot"
                    : namesOnly ? name : $"{name} a level {level} {className}");

                offset += namesOnly ? 1 : 4;
            }

            int firstOccupied = -1;
            for (var slot = 0; slot < 3; slot++)
            {
                var name = namesOnly
                    ? Field(fields, 1 + slot)
                    : Field(fields, 1 + slot * 4);

                if (!string.IsNullOrWhiteSpace(name))
                {
                    firstOccupied = slot;
                    break;
                }
            }

            menu.SelectCharacterSlot(firstOccupied >= 0 ? firstOccupied : 0);
            menu.ShowCharacters();
        });
    }

    private void HandleClassDefinition(IReadOnlyList<string> fields)
    {
        int classId = IntField(fields, 1);
        if (classId < 0)
            return;

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
                menu.ShowClassSelection();
        });

        static int commandStride(IReadOnlyList<string> packet, int index)
        {
            // newcharclasses has sprite fields as well; classesdata usually does not.
            return index + 9 < packet.Count ? 10 : 8;
        }
    }

    private void ReturnToLogin()
    {
        if (_disposed || Application.Instance is null)
            return;

        // A kick, ban, server shutdown, or other forced disconnect must tear
        // down the FNA game window and restore the Eto login screen.
        _graphics.Stop();
        _connection.Reset();
        _tools.Reset();
        _networkTimer.Start();

        if (Application.Instance.MainForm is frmMainMenu menu)
        {
            menu.Visible = true;
            menu.ShowLogin();
            menu.BringToFront();
        }
    }

    private void ShowMainGame()
    {
        // The main game is now the FNA window. Eto remains available for editors,
        // dialogs and auxiliary forms, but no longer draws a second copy of the HUD.
        if (Application.Instance is null) return;
        var menu = Application.Instance.MainForm;
        if (menu is not null) menu.Visible = false;
        _graphics.Start(FnaGraphicsService.InterfaceWidth, FnaGraphicsService.InterfaceHeight);
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
        Ui(() =>
        {
            _tools.Dispose();
            foreach (var form in _editForms.ToArray())
            {
                form.PreviewRequested -= OnEditorPreview;
                form.Closed -= OnEditorClosed;
                form.Close();
            }
            _editForms.Clear();
        });
        _networkTimer.Stop();
        _graphics.Dispose();
        _audio.Dispose();
        _connection.Dispose();
    }
}
