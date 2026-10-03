using System;
using System.Collections.Generic;
using System.Diagnostics;
using Eto.Forms;

namespace XtremeWorlds.Client.Logic
{
    public enum MenuState
    {
        NewAccount,
        Login,
        NewCharacter,
        AddCharacter,
        DeleteCharacter,
        UseCharacter
    }

    public sealed class GameClassInfo
    {
        public int MaleSprite { get; set; }
        public int FemaleSprite { get; set; }
        public string Name { get; set; } = string.Empty;
        public int STR { get; set; }
        public int DEF { get; set; }
        public int Speed { get; set; }
        public int MAGI { get; set; }
    }

    public sealed class CharacterSlotInfo
    {
        public string Name { get; set; } = string.Empty;
        public int Sprite { get; set; }
    }

    public interface IGameClientRuntime
    {
        string Website { get; set; }
        bool SaveLogin { get; set; }
        string Username { get; set; }
        string Password { get; set; }
        int CurrentClass { get; set; }
        int CurrentSex { get; set; }
        IReadOnlyList<GameClassInfo> Classes { get; }

        event EventHandler<GameClientActionEventArgs> ActionRequested;

        void InitializeMenu();
        void SaveLoginCredentials(string username, string password);
        void MenuState(MenuState state, string text = null, int selectedIndex = -1);
        void Disconnect();
        void RefreshWebsite();
        void RefreshNewCharacterPreview(int classIndex, int sex);
        void OpenWebsite();
        void GameDestroy();
        void UpdateServerIp(string ipAddress);
        void MainGameAction(string actionName, params object[] arguments);
    }

    public sealed class GameClientActionEventArgs : EventArgs
    {

        public GameClientActionEventArgs(string name, params object[] arguments)
        {
            Name = name;
            Arguments = arguments ?? Array.Empty<object>();
        }

        public string Name { get; private set; }
        public object[] Arguments { get; private set; }
    }

    /// <summary>
    /// Shared controller used by the converted Eto forms.  It ports the form-level
    /// behavior from twinBASIC and provides one event boundary for the remaining
    /// networking/rendering engine while those modules are migrated.
    /// </summary>
    public sealed class GameClientRuntime : IGameClientRuntime
    {

        private static IGameClientRuntime _current = new GameClientRuntime();
        private readonly List<GameClassInfo> _classes;

        public static IGameClientRuntime Current
        {
            get
            {
                return _current;
            }
            set
            {
                _current = value ?? new GameClientRuntime();
            }
        }

        public GameClientRuntime()
        {
            _classes = new List<GameClassInfo>() { new GameClassInfo() { Name = "Fighter" }, new GameClassInfo() { Name = "Wizard" }, new GameClassInfo() { Name = "Celestial" }, new GameClassInfo() { Name = "Guardian" }, new GameClassInfo() { Name = "Assassin" } };
            Website = "https://www.xtremeworlds.com";
            CurrentClass = 0;
            CurrentSex = 1;
        }

        public string Website { get; set; }
        public bool SaveLogin { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public int CurrentClass { get; set; }
        public int CurrentSex { get; set; }
        public IReadOnlyList<GameClassInfo> Classes
        {
            get
            {
                return _classes;
            }
        }

        public event EventHandler<GameClientActionEventArgs> ActionRequested;

        public void InitializeMenu()
        {
            Request("InitializeMenu");
        }

        public void SaveLoginCredentials(string username, string password)
        {
            username = (username ?? string.Empty).Trim();
            password = password ?? string.Empty;
            Request("SaveLoginCredentials", username, password, SaveLogin);
        }

        public void MenuState(MenuState state, string text = null, int selectedIndex = -1)
        {
            Request("MenuState", state, text, selectedIndex, CurrentClass, CurrentSex);
        }

        public void Disconnect()
        {
            Request("TcpDestroy");
        }

        public void RefreshWebsite()
        {
            Request("GetGameSite");
        }

        public void RefreshNewCharacterPreview(int classIndex, int sex)
        {
            Request("NewCharBltSprite", classIndex, sex);
        }

        public void OpenWebsite()
        {
            string address = (Website ?? string.Empty).Trim();
            if (address.Length == 0)
                return;
            if (address.StartsWith("http://", StringComparison.OrdinalIgnoreCase))
            {
                address = address.Substring(7);
            }
            if (address.StartsWith("//", StringComparison.Ordinal))
            {
                address = address.Substring(2);
            }
            if (!address.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
            {
                address = "https://" + address;
            }

            try
            {
                Process.Start(new ProcessStartInfo(address) { UseShellExecute = true });
            }
            catch
            {
                Request("OpenWebsite", address);
            }
        }

        public void GameDestroy()
        {
            Request("GameDestroy");
            if (Application.Instance is not null)
                Application.Instance.Quit();
        }

        public void UpdateServerIp(string ipAddress)
        {
            Request("UpdateServerIp", ipAddress);
        }

        public void MainGameAction(string actionName, params object[] arguments)
        {
            Request(actionName, arguments);
        }

        private void Request(string name, params object[] arguments)
        {
            ActionRequested?.Invoke(this, new GameClientActionEventArgs(name, arguments));
        }
    }
}
