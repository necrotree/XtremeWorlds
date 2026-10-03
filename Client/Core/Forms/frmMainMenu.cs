using System;
using Eto.Drawing;
using Eto.Forms;
using Microsoft.VisualBasic;
using XtremeWorlds.Client.Logic;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    /// <summary>
    /// XtremeWorlds menu using real Eto.Forms controls.
    /// The twinBASIC PNGs are only the skin; all interactive elements remain
    /// Button/TextBox/PasswordBox/RadioButton/ListBox/ImageView controls.
    /// </summary>
    public class frmMainMenu : Form
    {

        private readonly Panel _pageHost;
        private readonly IGameClientRuntime _client;
        private Control _mainPage;
        private Control _loginPage;
        private Control _registerPage;
        private Control _charactersPage;
        private Control _newCharacterPage;
        private Control _classPage;

        public readonly LegacyListBox lstChars;
        public readonly LegacyButton picCharsCancel;
        public readonly LegacyButton picDelChar;
        public readonly LegacyButton picNewChar;
        public readonly LegacyButton picUseChar;
        public readonly ImageView imgSelectedCharacter;
        public readonly ImageView imgCharacter0;
        public readonly LegacyLabel lblCharacter0;
        public readonly ImageView imgCharacter1;
        public readonly LegacyLabel lblCharacter1;
        public readonly ImageView imgCharacter2;
        public readonly LegacyLabel lblCharacter2;
        public readonly ImageView imgCharacters;

        public readonly LegacyButton picLoginCancel;
        public readonly LegacyButton picLoginConnect;
        public readonly LegacyTextBox txtLoginName;
        public readonly LegacyPasswordBox txtLoginPassword;
        public readonly ImageView imgLogin;

        public readonly LegacyButton picNewAcctCancel;
        public readonly LegacyButton picNewAcctConnect;
        public readonly LegacyPasswordBox txtNewAcctPassword;
        public readonly LegacyTextBox txtNewAcctName;
        public readonly LegacyPasswordBox txtNewAcctVerify;
        public readonly ImageView imgRegister;

        public readonly LegacyButton picNewCharCancel;
        public readonly LegacyButton picNewCharAddChar;
        public readonly LegacyLabel lblMAGI;
        public readonly LegacyLabel lblDEF;
        public readonly LegacyLabel lblSP;
        public readonly LegacyLabel lblSPEED;
        public readonly LegacyLabel lblMP;
        public readonly LegacyLabel lblSTR;
        public readonly LegacyLabel lblHP;
        public readonly ImageView imgNewCharSprite;
        public readonly LegacyTextBox txtNewCharName;
        public readonly LegacyButton picPreviousClass;
        public readonly LegacyButton picNextClass;
        public readonly LegacyRadioButton picMale;
        public readonly LegacyRadioButton picFemale;

        public readonly LegacyButton picCredits;
        public readonly LegacyButton picQuit;
        public readonly LegacyButton picRegister;
        public readonly UITimer timerSprite;
        public readonly LegacyButton picWebsite;
        public readonly ImageView imgMainMenu;
        public readonly LegacyButton picLogin;
        public readonly ImageView imgBackground;

        public readonly ImageView imgClassSelection;
        public readonly LegacyRadioButton picClassFighter;
        public readonly LegacyRadioButton picClassWizard;
        public readonly LegacyRadioButton picClassCelestial;
        public readonly LegacyRadioButton picClassGuardian;
        public readonly LegacyRadioButton picClassAssassin;
        public readonly LegacyLabel lblSelectedClass;
        public readonly ImageView imgClassButtons;
        public readonly LegacyButton picClassContinue;
        public readonly LegacyButton picClassBack;
        public readonly ImageView imgNewChar;
        public readonly LegacyLabel Label1;

        private readonly ImageView imgLogo;
        private readonly ImageView imgBottomButtons;

        public frmMainMenu(IGameClientRuntime client = null)
        {
            _client = client ?? GameClientRuntime.Current;
            Title = "XtremeWorlds";
            Style = "XtremeWorldsWindow";
            Icon = AssetLoader.LoadIcon("Icon.ico");
            ClientSize = new Size(950, 700);
            MinimumSize = new Size(760, 560);
            Resizable = true;

            imgBackground = MakeImage("frmMainMenu/imgBackground.png");
            imgLogo = MakeImage("frmMainMenu/imgLogo.png");
            imgBottomButtons = MakeImage("frmMainMenu/imgBottomButtons.png");
            imgMainMenu = MakeImage("frmMainMenu/imgMainMenu.png");
            imgLogin = MakeImage("frmMainMenu/imgLogin.png");
            imgRegister = MakeImage("frmMainMenu/imgRegister.png");
            imgCharacters = MakeImage("frmMainMenu/imgCharacters.png");
            imgNewChar = MakeImage("frmMainMenu/imgNewChar.png");
            imgClassSelection = MakeImage("frmMainMenu/imgClassSelection.png");
            imgClassButtons = MakeImage("frmMainMenu/imgClassButtons.png");

            picLogin = MakeSkinButton("Login");
            picRegister = MakeSkinButton("Register");
            picWebsite = MakeSkinButton("Website");
            picQuit = MakeSkinButton("Exit");
            picCredits = MakeSkinButton("Credits");

            txtLoginName = MakeSkinTextBox();
            txtLoginPassword = MakeSkinPasswordBox();
            picLoginConnect = MakeSkinButton("Accept");
            picLoginCancel = MakeSkinButton("Back");

            txtNewAcctName = MakeSkinTextBox();
            txtNewAcctPassword = MakeSkinPasswordBox();
            txtNewAcctVerify = MakeSkinPasswordBox();
            picNewAcctConnect = MakeSkinButton("Create");
            picNewAcctCancel = MakeSkinButton("Back");

            lstChars = new LegacyListBox() { Style = "XtremeWorldsTransparentList" };
            imgCharacter0 = new ImageView();
            imgCharacter1 = new ImageView();
            imgCharacter2 = new ImageView();
            imgSelectedCharacter = new ImageView();
            lblCharacter0 = MakeSkinLabel(string.Empty);
            lblCharacter1 = MakeSkinLabel(string.Empty);
            lblCharacter2 = MakeSkinLabel(string.Empty);
            picUseChar = MakeSkinButton("Accept");
            picDelChar = MakeSkinButton("Delete");
            picNewChar = MakeSkinButton("Create");
            picCharsCancel = MakeSkinButton("Back");

            imgNewCharSprite = new ImageView() { Size = new Size(48, 64) };
            txtNewCharName = MakeSkinTextBox();
            picPreviousClass = MakeSkinButton("<");
            picNextClass = MakeSkinButton(">");
            picMale = new LegacyRadioButton() { Caption = "Male", Checked = true, Style = "XtremeWorldsSkinRadio" };
            picFemale = new LegacyRadioButton(picMale) { Caption = "Female", Style = "XtremeWorldsSkinRadio" };
            picNewCharAddChar = MakeSkinButton("Create");
            picNewCharCancel = MakeSkinButton("Back");

            lblHP = MakeValueLabel();
            lblMP = MakeValueLabel();
            lblSP = MakeValueLabel();
            lblSTR = MakeValueLabel();
            lblDEF = MakeValueLabel();
            lblSPEED = MakeValueLabel();
            lblMAGI = MakeValueLabel();

            picClassFighter = new LegacyRadioButton() { Caption = "Fighter", Checked = true, Style = "XtremeWorldsClassChoice" };
            picClassWizard = new LegacyRadioButton(picClassFighter) { Caption = "Wizard", Style = "XtremeWorldsClassChoice" };
            picClassCelestial = new LegacyRadioButton(picClassFighter) { Caption = "Celestial", Style = "XtremeWorldsClassChoice" };
            picClassGuardian = new LegacyRadioButton(picClassFighter) { Caption = "Guardian", Style = "XtremeWorldsClassChoice" };
            picClassAssassin = new LegacyRadioButton(picClassFighter) { Caption = "Assassin", Style = "XtremeWorldsClassChoice" };
            lblSelectedClass = MakeSkinLabel("Fighter");
            picClassContinue = MakeSkinButton("Accept");
            picClassBack = MakeSkinButton("Cancel");
            Label1 = MakeSkinLabel(string.Empty);

            timerSprite = new UITimer() { Interval = 0.05d };

            _pageHost = new Panel() { Style = "XtremeWorldsPageHost" };

            var root = new TableLayout() { Padding = new Padding(0), Spacing = Size.Empty };
            var hostRow = new TableRow(new TableCell(_pageHost, true)) { ScaleHeight = true };
            root.Rows.Add(hostRow);
            Content = root;

            _mainPage = BuildMainPage();
            _loginPage = BuildLoginPage();
            _registerPage = BuildRegisterPage();
            _charactersPage = BuildCharactersPage();
            _newCharacterPage = BuildNewCharacterPage();
            _classPage = BuildClassPage();

            WireNavigation();
            ShowPage(_mainPage);
            Shown += OnFormShown;
        }

        private static ImageView MakeImage(string resourceName)
        {
            return new ImageView() { Image = AssetLoader.LoadImage(resourceName) };
        }

        private static LegacyButton MakeSkinButton(string text)
        {
            return new LegacyButton() { Caption = text, Style = "XtremeWorldsSkinButton" };
        }

        private static LegacyTextBox MakeSkinTextBox()
        {
            return new LegacyTextBox() { Style = "XtremeWorldsSkinTextBox" };
        }

        private static LegacyPasswordBox MakeSkinPasswordBox()
        {
            return new LegacyPasswordBox() { PasswordChar = '*', Style = "XtremeWorldsSkinPasswordBox" };
        }

        private static LegacyLabel MakeSkinLabel(string text)
        {
            return new LegacyLabel() { Caption = text, Style = "XtremeWorldsSkinLabel", VerticalAlignment = VerticalAlignment.Center };
        }

        private static LegacyLabel MakeValueLabel()
        {
            return new LegacyLabel() { Caption = "0", Style = "XtremeWorldsSkinLabel", TextAlignment = TextAlignment.Right, VerticalAlignment = VerticalAlignment.Center };
        }

        private static Panel Spacer(int width, int height = 1)
        {
            return new Panel() { Size = new Size(Math.Max(1, width), Math.Max(1, height)) };
        }

        private static TableLayout Center(Control control)
        {
            var t = new TableLayout();
            t.Rows.Add(new TableRow(new TableCell(null, true), new TableCell(control, false), new TableCell(null, true)));
            return t;
        }

        private static TableLayout CenterPage(Control control)
        {
            var page = new TableLayout() { Padding = new Padding(0), Spacing = Size.Empty };
            var top = new TableRow(new TableCell(null, true)) { ScaleHeight = true };
            var middle = new TableRow(new TableCell(null, true), new TableCell(control, false), new TableCell(null, true));
            var bottom = new TableRow(new TableCell(null, true)) { ScaleHeight = true };
            page.Rows.Add(top);
            page.Rows.Add(middle);
            page.Rows.Add(bottom);
            return page;
        }

        private static StackLayout Horizontal(params Control[] controls)
        {
            var s = new StackLayout() { Orientation = Orientation.Horizontal, Spacing = 0 };
            foreach (var c in controls)
                s.Items.Add(c);
            return s;
        }

        private static StackLayout Vertical(params Control[] controls)
        {
            var s = new StackLayout() { Orientation = Orientation.Vertical, Spacing = 0 };
            foreach (var c in controls)
                s.Items.Add(c);
            return s;
        }

        private static Panel SkinPanel(string styleName, int width, int height, Control content)
        {
            return new Panel() { Style = styleName, Size = new Size(width, height), Content = content };
        }

        private Control BuildMainPage()
        {
            // Dynamic Eto layout.  The WPF style supplies the 950x700 background.
            var mainButtons = new TableLayout() { Spacing = Size.Empty };
            picLogin.Size = new Size(204, 38);
            picRegister.Size = new Size(204, 38);
            mainButtons.Rows.Add(new TableRow(new TableCell(Center(picLogin), true)));
            mainButtons.Rows.Add(new TableRow(new TableCell(Spacer(1, 21), true)));
            mainButtons.Rows.Add(new TableRow(new TableCell(Center(picRegister), true)));
            var mainPanel = SkinPanel("XtremeWorldsMainButtons", 219, 115, mainButtons);

            picWebsite.Size = new Size(115, 32);
            picQuit.Size = new Size(114, 32);
            var bottomRow = Horizontal(Spacer(3), picWebsite, Spacer(24), picQuit, Spacer(5));
            var bottomPanel = SkinPanel("XtremeWorldsBottomButtons", 261, 59, bottomRow);

            var page = new TableLayout() { Padding = new Padding(0), Spacing = Size.Empty };
            page.Rows.Add(new TableRow(new TableCell(Spacer(1, 72), true)));
            page.Rows.Add(new TableRow(new TableCell(Center(imgLogo), true)));
            var grow = new TableRow(new TableCell(null, true)) { ScaleHeight = true };
            page.Rows.Add(grow);
            page.Rows.Add(new TableRow(new TableCell(Center(mainPanel), true)));
            var grow2 = new TableRow(new TableCell(null, true)) { ScaleHeight = true };
            page.Rows.Add(grow2);
            // Keep the Website / Exit artwork and the real Eto buttons aligned,
            // but let the whole bottom panel sit 4 pixels lower like the twinBASIC menu.
            page.Rows.Add(new TableRow(new TableCell(Center(bottomPanel), true)));
            page.Rows.Add(new TableRow(new TableCell(Spacer(1, 0), true)));
            return page;
        }

        private Control BuildLoginPage()
        {
            txtLoginName.Size = new Size(122, 20);
            txtLoginPassword.Size = new Size(122, 20);
            picLoginConnect.Size = new Size(100, 22);
            picLoginCancel.Size = new Size(100, 22);

            var body = Vertical(Spacer(1, 41), Horizontal(Spacer(104), txtLoginName), Spacer(1, 20), Horizontal(Spacer(104), txtLoginPassword), Spacer(1, 19), Horizontal(Spacer(28), picLoginConnect, Spacer(10), picLoginCancel));
            return CenterPage(SkinPanel("XtremeWorldsLoginPanel", 266, 162, body));
        }

        private Control BuildRegisterPage()
        {
            txtNewAcctName.Size = new Size(122, 20);
            txtNewAcctPassword.Size = new Size(122, 20);
            txtNewAcctVerify.Size = new Size(122, 20);
            picNewAcctConnect.Size = new Size(100, 22);
            picNewAcctCancel.Size = new Size(100, 22);

            var body = Vertical(Spacer(1, 41), Horizontal(Spacer(104), txtNewAcctName), Spacer(1, 20), Horizontal(Spacer(104), txtNewAcctPassword), Spacer(1, 20), Horizontal(Spacer(104), txtNewAcctVerify), Spacer(1, 19), Horizontal(Spacer(28), picNewAcctConnect, Spacer(10), picNewAcctCancel));
            return CenterPage(SkinPanel("XtremeWorldsRegisterPanel", 266, 199, body));
        }

        private Control BuildCharactersPage()
        {
            picUseChar.Size = new Size(100, 22);
            picDelChar.Size = new Size(100, 22);
            picNewChar.Size = new Size(100, 22);
            picCharsCancel.Size = new Size(100, 22);
            lstChars.Size = new Size(210, 82);

            // lstChars is a real Eto ListBox.  The WPF skin makes it transparent so
            // the three twinBASIC character slots remain visible beneath it.
            var body = Vertical(Spacer(1, 39), Horizontal(Spacer(28), lstChars), Spacer(1, 14), Horizontal(Spacer(28), picUseChar, Spacer(10), picDelChar), Spacer(1, 3), Horizontal(Spacer(28), picNewChar, Spacer(10), picCharsCancel));
            return CenterPage(SkinPanel("XtremeWorldsCharactersPanel", 266, 199, body));
        }

        private Control BuildNewCharacterPage()
        {
            txtNewCharName.Size = new Size(114, 20);
            picMale.Size = new Size(74, 24);
            picFemale.Size = new Size(82, 24);
            picNewCharAddChar.Size = new Size(101, 23);
            picNewCharCancel.Size = new Size(101, 23);
            picPreviousClass.Size = new Size(24, 24);
            picNextClass.Size = new Size(24, 24);

            var body = Vertical(Spacer(1, 45), Horizontal(Spacer(149), txtNewCharName), Spacer(1, 17), Horizontal(Spacer(100), picMale, Spacer(12), picFemale), Spacer(1, 23), Horizontal(Spacer(37), picPreviousClass, Spacer(18), picNextClass), Spacer(1, 17), Horizontal(Spacer(44), picNewCharAddChar, Spacer(11), picNewCharCancel));
            return CenterPage(SkinPanel("XtremeWorldsNewCharacterPanel", 297, 199, body));
        }

        private Control BuildClassPage()
        {
            // Five real Eto RadioButtons live inside the skinned class panel.
            // The platform style makes their chrome transparent so the original
            // twinBASIC class cards remain the visible selection surface.
            picClassFighter.Size = new Size(140, 190);
            picClassWizard.Size = new Size(140, 190);
            picClassCelestial.Size = new Size(140, 190);
            picClassGuardian.Size = new Size(140, 190);
            picClassAssassin.Size = new Size(140, 190);

            var choices = new TableLayout() { Padding = new Padding(10, 10, 10, 11), Spacing = new Size(5, 0) };
            choices.Rows.Add(new TableRow(new TableCell(picClassFighter, true), new TableCell(picClassWizard, true), new TableCell(picClassCelestial, true), new TableCell(picClassGuardian, true), new TableCell(picClassAssassin, true)));

            picClassContinue.Size = new Size(104, 25);
            picClassBack.Size = new Size(103, 25);
            var buttons = Horizontal(picClassContinue, Spacer(10), picClassBack);
            var buttonPanel = SkinPanel("XtremeWorldsClassButtons", 217, 25, buttons);

            var visual = SkinPanel("XtremeWorldsClassPanel", 774, 211, choices);
            var content = new TableLayout() { Spacing = new Size(0, 15) };
            content.Rows.Add(new TableRow(new TableCell(visual, true)));
            content.Rows.Add(new TableRow(new TableCell(null, true), new TableCell(buttonPanel, false), new TableCell(null, true)));
            return CenterPage(content);
        }

        private void WireNavigation()
        {
            picLogin.Click += HandleLoginPage;
            picRegister.Click += HandleRegisterPage;
            picLoginConnect.Click += HandleLoginConnect;
            picLoginCancel.Click += (sender, e) => ShowMenuHome();
            picNewAcctConnect.Click += HandleNewAccountConnect;
            picNewAcctCancel.Click += (sender, e) => ShowMenuHome();
            picWebsite.Click += (sender, e) => _client.OpenWebsite();
            picQuit.Click += (sender, e) => _client.GameDestroy();

            picUseChar.Click += (sender, e) => _client.MenuState(MenuState.UseCharacter, selectedIndex: lstChars.SelectedIndex);
            picNewChar.Click += HandleNewCharacter;
            picCharsCancel.Click += HandleCharactersCancel;
            picDelChar.Click += HandleDeleteCharacter;
            picNewCharAddChar.Click += HandleAddCharacter;
            picNewCharCancel.Click += (sender, e) => ShowClassSelection();
            picClassContinue.Click += HandleClassContinue;
            picClassBack.Click += HandleClassBack;
            picPreviousClass.Click += HandlePreviousClass;
            picNextClass.Click += HandleNextClass;
            picMale.CheckedChanged += HandleSexChanged;
            picFemale.CheckedChanged += HandleSexChanged;

            txtLoginName.KeyDown += HandleLoginNameKeyDown;
            txtLoginPassword.KeyDown += HandleLoginPasswordKeyDown;
            txtNewAcctVerify.KeyDown += HandleNewAccountVerifyKeyDown;
            KeyDown += HandleMenuKeyDown;
            timerSprite.Elapsed += (sender, e) => _client.RefreshWebsite();

            imgCharacter0.MouseDown += (sender, e) => SelectCharacterSlot(0);
            imgCharacter1.MouseDown += (sender, e) => SelectCharacterSlot(1);
            imgCharacter2.MouseDown += (sender, e) => SelectCharacterSlot(2);
            lblCharacter0.MouseDown += (sender, e) => SelectCharacterSlot(0);
            lblCharacter1.MouseDown += (sender, e) => SelectCharacterSlot(1);
            lblCharacter2.MouseDown += (sender, e) => SelectCharacterSlot(2);

            picClassFighter.CheckedChanged += HandleClassSelectionChanged;
            picClassWizard.CheckedChanged += HandleClassSelectionChanged;
            picClassCelestial.CheckedChanged += HandleClassSelectionChanged;
            picClassGuardian.CheckedChanged += HandleClassSelectionChanged;
            picClassAssassin.CheckedChanged += HandleClassSelectionChanged;
        }

        private void HandleLoginPage(object sender, EventArgs e)
        {
            if (_client.SaveLogin)
            {
                txtLoginName.Text = _client.Username;
                txtLoginPassword.Text = _client.Password;
            }
            ShowPage(_loginPage);
            txtLoginName.Focus();
        }

        private void HandleRegisterPage(object sender, EventArgs e)
        {
            ShowPage(_registerPage);
            txtNewAcctName.Focus();
        }

        private void HandleLoginConnect(object sender, EventArgs e)
        {
            string username = (txtLoginName.Text ?? string.Empty).Trim();
            string password = (txtLoginPassword.Text ?? string.Empty).Trim();
            if (username.Length == 0 && password.Length == 0)
            {
                frmAlert.ShowAlert(this, "Please enter your login name and password!", "XtremeWorlds");
                return;
            }
            if (username.Length == 0)
            {
                frmAlert.ShowAlert(this, "Please enter your login name!", "XtremeWorlds");
                txtLoginName.Focus();
                return;
            }
            if (password.Length == 0)
            {
                frmAlert.ShowAlert(this, "Please enter your password!", "XtremeWorlds");
                txtLoginPassword.Focus();
                return;
            }
            _client.SaveLoginCredentials(username, password);
            _client.MenuState(MenuState.Login);
        }

        private void HandleNewAccountConnect(object sender, EventArgs e)
        {
            string username = (txtNewAcctName.Text ?? string.Empty).Trim();
            string password = txtNewAcctPassword.Text ?? string.Empty;
            string verify = txtNewAcctVerify.Text ?? string.Empty;
            if ((password ?? "") != (verify ?? ""))
            {
                frmAlert.ShowAlert(this, "Passwords do not match.", "XtremeWorlds");
                txtNewAcctVerify.Focus();
                return;
            }
            if (username.Length == 0 || password.Trim().Length == 0)
                return;
            if (!IsPrintableAscii(username))
            {
                frmAlert.ShowAlert(this, "You cannot use high ascii chars in your name, please re-enter.", "XtremeWorlds");
                txtNewAcctName.Text = string.Empty;
                txtNewAcctName.Focus();
                return;
            }
            _client.MenuState(MenuState.NewAccount, username);
        }

        private void HandleNewCharacter(object sender, EventArgs e)
        {
            _client.MenuState(MenuState.NewCharacter, selectedIndex: lstChars.SelectedIndex);
            ShowClassSelection();
        }

        private void HandleCharactersCancel(object sender, EventArgs e)
        {
            _client.Disconnect();
            ShowPage(_loginPage);
        }

        private void HandleDeleteCharacter(object sender, EventArgs e)
        {
            if (lstChars.SelectedIndex < 0)
                return;
            var result = frmAlert.ShowConfirm(this, "Are you sure you wish to delete this character?", "XtremeWorlds");
            if (result == DialogResult.Yes)
                _client.MenuState(MenuState.DeleteCharacter, selectedIndex: lstChars.SelectedIndex);
        }

        private void HandleAddCharacter(object sender, EventArgs e)
        {
            string characterName = (txtNewCharName.Text ?? string.Empty).Trim();
            if (characterName.Length == 0)
                return;
            if (!IsPrintableAscii(characterName))
            {
                MessageBox.Show(this, "You cannot use high ascii chars in your name, please re-enter.", "XtremeWorlds", MessageBoxType.Warning);
                txtNewCharName.Text = string.Empty;
                txtNewCharName.Focus();
                return;
            }
            _client.MenuState(MenuState.AddCharacter, characterName, lstChars.SelectedIndex);
        }

        private void HandleClassContinue(object sender, EventArgs e)
        {
            ShowPage(_newCharacterPage);
            RefreshSelectedClass();
            txtNewCharName.Focus();
        }

        private void HandleClassBack(object sender, EventArgs e)
        {
            _client.Disconnect();
            ShowMenuHome();
        }

        private void HandlePreviousClass(object sender, EventArgs e)
        {
            _client.CurrentSex = 1;
            picMale.Checked = true;
            RefreshSelectedClass();
        }

        private void HandleNextClass(object sender, EventArgs e)
        {
            _client.CurrentSex = 0;
            picFemale.Checked = true;
            RefreshSelectedClass();
        }

        private void HandleSexChanged(object sender, EventArgs e)
        {
            if (picMale.Checked)
                _client.CurrentSex = 1;
            if (picFemale.Checked)
                _client.CurrentSex = 0;
            _client.RefreshNewCharacterPreview(_client.CurrentClass, _client.CurrentSex);
        }

        private void HandleLoginNameKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Keys.Enter)
            {
                txtLoginPassword.Focus();
                e.Handled = true;
            }
        }

        private void HandleLoginPasswordKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Keys.Enter)
            {
                HandleLoginConnect(sender, EventArgs.Empty);
                e.Handled = true;
            }
        }

        private void HandleNewAccountVerifyKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Keys.Enter)
            {
                HandleNewAccountConnect(sender, EventArgs.Empty);
                e.Handled = true;
            }
        }

        private void HandleMenuKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key != Keys.F1)
                return;
            // twinBASIC opened an IP input box here.  Keep the engine request on
            // the shared runtime so each platform can provide its preferred dialog.
            _client.MainGameAction("PromptServerIp");
            e.Handled = true;
        }

        private static bool IsPrintableAscii(string value)
        {
            foreach (var ch in value)
            {
                int code = Strings.AscW(ch);
                if (code < 32 || code > 126)
                    return false;
            }
            return true;
        }

        public void ShowMenuHome()
        {
            ShowPage(_mainPage);
        }

        public void ShowCharacters()
        {
            ShowPage(_charactersPage);
        }

        public void ShowClassSelection()
        {
            _client.CurrentClass = Math.Max(0, Math.Min(_client.CurrentClass, Math.Max(0, _client.Classes.Count - 1)));
            ShowPage(_classPage);
            RefreshSelectedClass();
        }

        private void RefreshSelectedClass()
        {
            if (_client.Classes.Count == 0)
                return;
            int index = Math.Max(0, Math.Min(_client.CurrentClass, _client.Classes.Count - 1));
            var info = _client.Classes[index];
            lblSelectedClass.Caption = info.Name;
            lblSTR.Caption = info.STR.ToString();
            lblDEF.Caption = info.DEF.ToString();
            lblSPEED.Caption = info.Speed.ToString();
            lblMAGI.Caption = info.MAGI.ToString();
            _client.RefreshNewCharacterPreview(index, _client.CurrentSex);
        }

        public void SetCharacterSlot(int slot, string name, int sprite = 0)
        {
            LegacyLabel label = null;
            switch (slot)
            {
                case 0:
                    {
                        label = lblCharacter0;
                        break;
                    }
                case 1:
                    {
                        label = lblCharacter1;
                        break;
                    }
                case 2:
                    {
                        label = lblCharacter2;
                        break;
                    }

                default:
                    {
                        return;
                    }
            }
            label.Caption = string.IsNullOrWhiteSpace(name) ? "Empty" : name;
        }

        public void SelectCharacterSlot(int slot)
        {
            if (slot < 0)
                return;
            lstChars.SelectedIndex = slot;
        }

        private void HandleClassSelectionChanged(object sender, EventArgs e)
        {
            LegacyRadioButton selected = sender as LegacyRadioButton;
            if (selected is null || !selected.Checked)
                return;
            lblSelectedClass.Caption = selected.Caption;
            for (int i = 0, loopTo = _client.Classes.Count - 1; i <= loopTo; i++)
            {
                if (string.Equals(_client.Classes[i].Name, selected.Caption, StringComparison.OrdinalIgnoreCase))
                {
                    _client.CurrentClass = i;
                    break;
                }
            }
            RefreshSelectedClass();
        }

        private void ShowPage(Control page)
        {
            if (page is not null)
                _pageHost.Content = page;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            _client.InitializeMenu();
            _client.RefreshWebsite();
            ShowMenuHome();
        }
    }
}