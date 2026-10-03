Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI
Imports XtremeWorlds.Client.Logic

Namespace XtremeWorlds.Client.Forms
    ''' <summary>
    ''' XtremeWorlds menu using real Eto.Forms controls.
    ''' The twinBASIC PNGs are only the skin; all interactive elements remain
    ''' Button/TextBox/PasswordBox/RadioButton/ListBox/ImageView controls.
    ''' </summary>
    Public Class frmMainMenu
        Inherits Form

        Private ReadOnly _pageHost As Panel
        Private ReadOnly _client As IGameClientRuntime
        Private _mainPage As Control
        Private _loginPage As Control
        Private _registerPage As Control
        Private _charactersPage As Control
        Private _newCharacterPage As Control
        Private _classPage As Control

        Public ReadOnly lstChars As LegacyListBox
        Public ReadOnly picCharsCancel As LegacyButton
        Public ReadOnly picDelChar As LegacyButton
        Public ReadOnly picNewChar As LegacyButton
        Public ReadOnly picUseChar As LegacyButton
        Public ReadOnly imgSelectedCharacter As ImageView
        Public ReadOnly imgCharacter0 As ImageView
        Public ReadOnly lblCharacter0 As LegacyLabel
        Public ReadOnly imgCharacter1 As ImageView
        Public ReadOnly lblCharacter1 As LegacyLabel
        Public ReadOnly imgCharacter2 As ImageView
        Public ReadOnly lblCharacter2 As LegacyLabel
        Public ReadOnly imgCharacters As ImageView

        Public ReadOnly picLoginCancel As LegacyButton
        Public ReadOnly picLoginConnect As LegacyButton
        Public ReadOnly txtLoginName As LegacyTextBox
        Public ReadOnly txtLoginPassword As LegacyPasswordBox
        Public ReadOnly imgLogin As ImageView

        Public ReadOnly picNewAcctCancel As LegacyButton
        Public ReadOnly picNewAcctConnect As LegacyButton
        Public ReadOnly txtNewAcctPassword As LegacyPasswordBox
        Public ReadOnly txtNewAcctName As LegacyTextBox
        Public ReadOnly txtNewAcctVerify As LegacyPasswordBox
        Public ReadOnly imgRegister As ImageView

        Public ReadOnly picNewCharCancel As LegacyButton
        Public ReadOnly picNewCharAddChar As LegacyButton
        Public ReadOnly lblMAGI As LegacyLabel
        Public ReadOnly lblDEF As LegacyLabel
        Public ReadOnly lblSP As LegacyLabel
        Public ReadOnly lblSPEED As LegacyLabel
        Public ReadOnly lblMP As LegacyLabel
        Public ReadOnly lblSTR As LegacyLabel
        Public ReadOnly lblHP As LegacyLabel
        Public ReadOnly imgNewCharSprite As ImageView
        Public ReadOnly txtNewCharName As LegacyTextBox
        Public ReadOnly picPreviousClass As LegacyButton
        Public ReadOnly picNextClass As LegacyButton
        Public ReadOnly picMale As LegacyRadioButton
        Public ReadOnly picFemale As LegacyRadioButton

        Public ReadOnly picCredits As LegacyButton
        Public ReadOnly picQuit As LegacyButton
        Public ReadOnly picRegister As LegacyButton
        Public ReadOnly timerSprite As UITimer
        Public ReadOnly picWebsite As LegacyButton
        Public ReadOnly imgMainMenu As ImageView
        Public ReadOnly picLogin As LegacyButton
        Public ReadOnly imgBackground As ImageView

        Public ReadOnly imgClassSelection As ImageView
        Public ReadOnly picClassFighter As LegacyRadioButton
        Public ReadOnly picClassWizard As LegacyRadioButton
        Public ReadOnly picClassCelestial As LegacyRadioButton
        Public ReadOnly picClassGuardian As LegacyRadioButton
        Public ReadOnly picClassAssassin As LegacyRadioButton
        Public ReadOnly lblSelectedClass As LegacyLabel
        Public ReadOnly imgClassButtons As ImageView
        Public ReadOnly picClassContinue As LegacyButton
        Public ReadOnly picClassBack As LegacyButton
        Public ReadOnly imgNewChar As ImageView
        Public ReadOnly Label1 As LegacyLabel

        Private ReadOnly imgLogo As ImageView
        Private ReadOnly imgBottomButtons As ImageView

        Public Sub New(Optional client As IGameClientRuntime = Nothing)
            _client = If(client, GameClientRuntime.Current)
            Title = "XtremeWorlds"
            Style = "Window"
            Icon = AssetLoader.LoadIcon("Icon.ico")
            ClientSize = New Size(950, 700)
            MinimumSize = New Size(760, 560)
            Resizable = True

            imgBackground = MakeImage("frmMainMenu/imgBackground.png")
            imgLogo = MakeImage("frmMainMenu/imgLogo.png")
            imgBottomButtons = MakeImage("frmMainMenu/imgBottomButtons.png")
            imgMainMenu = MakeImage("frmMainMenu/imgMainMenu.png")
            imgLogin = MakeImage("frmMainMenu/imgLogin.png")
            imgRegister = MakeImage("frmMainMenu/imgRegister.png")
            imgCharacters = MakeImage("frmMainMenu/imgCharacters.png")
            imgNewChar = MakeImage("frmMainMenu/imgNewChar.png")
            imgClassSelection = MakeImage("frmMainMenu/imgClassSelection.png")
            imgClassButtons = MakeImage("frmMainMenu/imgClassButtons.png")

            picLogin = MakeSkinButton("Login")
            picRegister = MakeSkinButton("Register")
            picWebsite = MakeSkinButton("Website")
            picQuit = MakeSkinButton("Exit")
            picCredits = MakeSkinButton("Credits")

            txtLoginName = MakeSkinTextBox()
            txtLoginPassword = MakeSkinPasswordBox()
            picLoginConnect = MakeSkinButton("Accept")
            picLoginCancel = MakeSkinButton("Back")

            txtNewAcctName = MakeSkinTextBox()
            txtNewAcctPassword = MakeSkinPasswordBox()
            txtNewAcctVerify = MakeSkinPasswordBox()
            picNewAcctConnect = MakeSkinButton("Create")
            picNewAcctCancel = MakeSkinButton("Back")

            lstChars = New LegacyListBox With {.Style = "TransparentList"}
            imgCharacter0 = New ImageView()
            imgCharacter1 = New ImageView()
            imgCharacter2 = New ImageView()
            imgSelectedCharacter = New ImageView()
            lblCharacter0 = MakeSkinLabel(String.Empty)
            lblCharacter1 = MakeSkinLabel(String.Empty)
            lblCharacter2 = MakeSkinLabel(String.Empty)
            picUseChar = MakeSkinButton("Accept")
            picDelChar = MakeSkinButton("Delete")
            picNewChar = MakeSkinButton("Create")
            picCharsCancel = MakeSkinButton("Back")

            imgNewCharSprite = New ImageView With {.Size = New Size(48, 64)}
            txtNewCharName = MakeSkinTextBox()
            picPreviousClass = MakeSkinButton("<")
            picNextClass = MakeSkinButton(">")
            picMale = New LegacyRadioButton() With {.Caption = "Male", .Checked = True, .Style = "SkinRadio"}
            picFemale = New LegacyRadioButton(picMale) With {.Caption = "Female", .Style = "SkinRadio"}
            picNewCharAddChar = MakeSkinButton("Create")
            picNewCharCancel = MakeSkinButton("Back")

            lblHP = MakeValueLabel()
            lblMP = MakeValueLabel()
            lblSP = MakeValueLabel()
            lblSTR = MakeValueLabel()
            lblDEF = MakeValueLabel()
            lblSPEED = MakeValueLabel()
            lblMAGI = MakeValueLabel()

            picClassFighter = New LegacyRadioButton() With {.Caption = "Fighter", .Checked = True, .Style = "ClassChoice"}
            picClassWizard = New LegacyRadioButton(picClassFighter) With {.Caption = "Wizard", .Style = "ClassChoice"}
            picClassCelestial = New LegacyRadioButton(picClassFighter) With {.Caption = "Celestial", .Style = "ClassChoice"}
            picClassGuardian = New LegacyRadioButton(picClassFighter) With {.Caption = "Guardian", .Style = "ClassChoice"}
            picClassAssassin = New LegacyRadioButton(picClassFighter) With {.Caption = "Assassin", .Style = "ClassChoice"}
            lblSelectedClass = MakeSkinLabel("Fighter")
            picClassContinue = MakeSkinButton("Accept")
            picClassBack = MakeSkinButton("Cancel")
            Label1 = MakeSkinLabel(String.Empty)

            timerSprite = New UITimer() With {.Interval = 0.05}

            _pageHost = New Panel With {.Style = "PageHost"}

            Dim root As New TableLayout With {.Padding = New Padding(0), .Spacing = Size.Empty}
            Dim hostRow As New TableRow(New TableCell(_pageHost, True)) With {.ScaleHeight = True}
            root.Rows.Add(hostRow)
            Content = root

            _mainPage = BuildMainPage()
            _loginPage = BuildLoginPage()
            _registerPage = BuildRegisterPage()
            _charactersPage = BuildCharactersPage()
            _newCharacterPage = BuildNewCharacterPage()
            _classPage = BuildClassPage()

            WireNavigation()
            ShowPage(_mainPage)
            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Private Shared Function MakeImage(resourceName As String) As ImageView
            Return New ImageView With {.Image = AssetLoader.LoadImage(resourceName)}
        End Function

        Private Shared Function MakeSkinButton(text As String) As LegacyButton
            Return New LegacyButton With {.Caption = text, .Style = "SkinButton"}
        End Function

        Private Shared Function MakeSkinTextBox() As LegacyTextBox
            Return New LegacyTextBox With {.Style = "SkinTextBox"}
        End Function

        Private Shared Function MakeSkinPasswordBox() As LegacyPasswordBox
            Return New LegacyPasswordBox With {.PasswordChar = "*"c, .Style = "SkinPasswordBox"}
        End Function

        Private Shared Function MakeSkinLabel(text As String) As LegacyLabel
            Return New LegacyLabel With {.Caption = text, .Style = "SkinLabel", .VerticalAlignment = VerticalAlignment.Center}
        End Function

        Private Shared Function MakeValueLabel() As LegacyLabel
            Return New LegacyLabel With {.Caption = "0", .Style = "SkinLabel", .TextAlignment = TextAlignment.Right, .VerticalAlignment = VerticalAlignment.Center}
        End Function

        Private Shared Function Spacer(width As Integer, Optional height As Integer = 1) As Panel
            Return New Panel With {.Size = New Size(Math.Max(1, width), Math.Max(1, height))}
        End Function

        Private Shared Function Center(control As Control) As TableLayout
            Dim t As New TableLayout()
            t.Rows.Add(New TableRow(New TableCell(Nothing, True), New TableCell(control, False), New TableCell(Nothing, True)))
            Return t
        End Function

        Private Shared Function CenterPage(control As Control) As TableLayout
            Dim page As New TableLayout With {.Padding = New Padding(0), .Spacing = Size.Empty}
            Dim top As New TableRow(New TableCell(Nothing, True)) With {.ScaleHeight = True}
            Dim middle As New TableRow(New TableCell(Nothing, True), New TableCell(control, False), New TableCell(Nothing, True))
            Dim bottom As New TableRow(New TableCell(Nothing, True)) With {.ScaleHeight = True}
            page.Rows.Add(top)
            page.Rows.Add(middle)
            page.Rows.Add(bottom)
            Return page
        End Function

        Private Shared Function Horizontal(ParamArray controls() As Control) As StackLayout
            Dim s As New StackLayout With {.Orientation = Orientation.Horizontal, .Spacing = 0}
            For Each c In controls
                s.Items.Add(c)
            Next
            Return s
        End Function

        Private Shared Function Vertical(ParamArray controls() As Control) As StackLayout
            Dim s As New StackLayout With {.Orientation = Orientation.Vertical, .Spacing = 0}
            For Each c In controls
                s.Items.Add(c)
            Next
            Return s
        End Function

        Private Shared Function SkinPanel(styleName As String, width As Integer, height As Integer, content As Control) As Panel
            Return New Panel With {.Style = styleName, .Size = New Size(width, height), .Content = content}
        End Function

        Private Function BuildMainPage() As Control
            ' Dynamic Eto layout.  The WPF style supplies the 950x700 background.
            Dim mainButtons As New TableLayout With {.Spacing = Size.Empty}
            picLogin.Size = New Size(204, 38)
            picRegister.Size = New Size(204, 38)
            mainButtons.Rows.Add(New TableRow(New TableCell(Center(picLogin), True)))
            mainButtons.Rows.Add(New TableRow(New TableCell(Spacer(1, 21), True)))
            mainButtons.Rows.Add(New TableRow(New TableCell(Center(picRegister), True)))
            Dim mainPanel = SkinPanel("MainButtons", 219, 115, mainButtons)

            picWebsite.Size = New Size(115, 32)
            picQuit.Size = New Size(114, 32)
            Dim bottomRow = Horizontal(Spacer(3), picWebsite, Spacer(24), picQuit, Spacer(5))
            Dim bottomPanel = SkinPanel("BottomButtons", 261, 59, bottomRow)

            Dim page As New TableLayout With {.Padding = New Padding(0), .Spacing = Size.Empty}
            page.Rows.Add(New TableRow(New TableCell(Spacer(1, 72), True)))
            page.Rows.Add(New TableRow(New TableCell(Center(imgLogo), True)))
            Dim grow As New TableRow(New TableCell(Nothing, True)) With {.ScaleHeight = True}
            page.Rows.Add(grow)
            page.Rows.Add(New TableRow(New TableCell(Center(mainPanel), True)))
            Dim grow2 As New TableRow(New TableCell(Nothing, True)) With {.ScaleHeight = True}
            page.Rows.Add(grow2)
            ' Final row: keep Website / Exit flush with the bottom of the client area.
            page.Rows.Add(New TableRow(New TableCell(Center(bottomPanel), True)))
            Return page
        End Function

        Private Function BuildLoginPage() As Control
            txtLoginName.Size = New Size(122, 20)
            txtLoginPassword.Size = New Size(122, 20)
            picLoginConnect.Size = New Size(100, 22)
            picLoginCancel.Size = New Size(100, 22)

            Dim body = Vertical(
                Spacer(1, 41),
                Horizontal(Spacer(104), txtLoginName),
                Spacer(1, 20),
                Horizontal(Spacer(104), txtLoginPassword),
                Spacer(1, 19),
                Horizontal(Spacer(28), picLoginConnect, Spacer(10), picLoginCancel)
            )
            Return CenterPage(SkinPanel("LoginPanel", 266, 162, body))
        End Function

        Private Function BuildRegisterPage() As Control
            txtNewAcctName.Size = New Size(122, 20)
            txtNewAcctPassword.Size = New Size(122, 20)
            txtNewAcctVerify.Size = New Size(122, 20)
            picNewAcctConnect.Size = New Size(100, 22)
            picNewAcctCancel.Size = New Size(100, 22)

            Dim body = Vertical(
                Spacer(1, 41),
                Horizontal(Spacer(104), txtNewAcctName),
                Spacer(1, 20),
                Horizontal(Spacer(104), txtNewAcctPassword),
                Spacer(1, 20),
                Horizontal(Spacer(104), txtNewAcctVerify),
                Spacer(1, 19),
                Horizontal(Spacer(28), picNewAcctConnect, Spacer(10), picNewAcctCancel)
            )
            Return CenterPage(SkinPanel("RegisterPanel", 266, 199, body))
        End Function

        Private Function BuildCharactersPage() As Control
            picUseChar.Size = New Size(100, 22)
            picDelChar.Size = New Size(100, 22)
            picNewChar.Size = New Size(100, 22)
            picCharsCancel.Size = New Size(100, 22)
            lstChars.Size = New Size(210, 82)

            ' lstChars is a real Eto ListBox.  The WPF skin makes it transparent so
            ' the three twinBASIC character slots remain visible beneath it.
            Dim body = Vertical(
                Spacer(1, 39),
                Horizontal(Spacer(28), lstChars),
                Spacer(1, 14),
                Horizontal(Spacer(28), picUseChar, Spacer(10), picDelChar),
                Spacer(1, 3),
                Horizontal(Spacer(28), picNewChar, Spacer(10), picCharsCancel)
            )
            Return CenterPage(SkinPanel("CharactersPanel", 266, 199, body))
        End Function

        Private Function BuildNewCharacterPage() As Control
            txtNewCharName.Size = New Size(114, 20)
            picMale.Size = New Size(74, 24)
            picFemale.Size = New Size(82, 24)
            picNewCharAddChar.Size = New Size(101, 23)
            picNewCharCancel.Size = New Size(101, 23)
            picPreviousClass.Size = New Size(24, 24)
            picNextClass.Size = New Size(24, 24)

            Dim body = Vertical(
                Spacer(1, 45),
                Horizontal(Spacer(149), txtNewCharName),
                Spacer(1, 17),
                Horizontal(Spacer(100), picMale, Spacer(12), picFemale),
                Spacer(1, 23),
                Horizontal(Spacer(37), picPreviousClass, Spacer(18), picNextClass),
                Spacer(1, 17),
                Horizontal(Spacer(44), picNewCharAddChar, Spacer(11), picNewCharCancel)
            )
            Return CenterPage(SkinPanel("NewCharacterPanel", 297, 199, body))
        End Function

        Private Function BuildClassPage() As Control
            ' Five real Eto RadioButtons live inside the skinned class panel.
            ' The platform style makes their chrome transparent so the original
            ' twinBASIC class cards remain the visible selection surface.
            picClassFighter.Size = New Size(140, 190)
            picClassWizard.Size = New Size(140, 190)
            picClassCelestial.Size = New Size(140, 190)
            picClassGuardian.Size = New Size(140, 190)
            picClassAssassin.Size = New Size(140, 190)

            Dim choices As New TableLayout With {.Padding = New Padding(10, 10, 10, 11), .Spacing = New Size(5, 0)}
            choices.Rows.Add(New TableRow(
                New TableCell(picClassFighter, True),
                New TableCell(picClassWizard, True),
                New TableCell(picClassCelestial, True),
                New TableCell(picClassGuardian, True),
                New TableCell(picClassAssassin, True)))

            picClassContinue.Size = New Size(104, 25)
            picClassBack.Size = New Size(103, 25)
            Dim buttons = Horizontal(picClassContinue, Spacer(10), picClassBack)
            Dim buttonPanel = SkinPanel("ClassButtons", 217, 25, buttons)

            Dim visual = SkinPanel("ClassPanel", 774, 211, choices)
            Dim content As New TableLayout With {.Spacing = New Size(0, 15)}
            content.Rows.Add(New TableRow(New TableCell(visual, True)))
            content.Rows.Add(New TableRow(New TableCell(Nothing, True), New TableCell(buttonPanel, False), New TableCell(Nothing, True)))
            Return CenterPage(content)
        End Function

        Private Sub WireNavigation()
            AddHandler picLogin.Click, AddressOf HandleLoginPage
            AddHandler picRegister.Click, AddressOf HandleRegisterPage
            AddHandler picLoginConnect.Click, AddressOf HandleLoginConnect
            AddHandler picLoginCancel.Click, Sub(sender, e) ShowMenuHome()
            AddHandler picNewAcctConnect.Click, AddressOf HandleNewAccountConnect
            AddHandler picNewAcctCancel.Click, Sub(sender, e) ShowMenuHome()
            AddHandler picWebsite.Click, Sub(sender, e) _client.OpenWebsite()
            AddHandler picQuit.Click, Sub(sender, e) _client.GameDestroy()

            AddHandler picUseChar.Click, Sub(sender, e) _client.MenuState(MenuState.UseCharacter, selectedIndex:=lstChars.SelectedIndex)
            AddHandler picNewChar.Click, AddressOf HandleNewCharacter
            AddHandler picCharsCancel.Click, AddressOf HandleCharactersCancel
            AddHandler picDelChar.Click, AddressOf HandleDeleteCharacter
            AddHandler picNewCharAddChar.Click, AddressOf HandleAddCharacter
            AddHandler picNewCharCancel.Click, Sub(sender, e) ShowClassSelection()
            AddHandler picClassContinue.Click, AddressOf HandleClassContinue
            AddHandler picClassBack.Click, AddressOf HandleClassBack
            AddHandler picPreviousClass.Click, AddressOf HandlePreviousClass
            AddHandler picNextClass.Click, AddressOf HandleNextClass
            AddHandler picMale.CheckedChanged, AddressOf HandleSexChanged
            AddHandler picFemale.CheckedChanged, AddressOf HandleSexChanged

            AddHandler txtLoginName.KeyDown, AddressOf HandleLoginNameKeyDown
            AddHandler txtLoginPassword.KeyDown, AddressOf HandleLoginPasswordKeyDown
            AddHandler txtNewAcctVerify.KeyDown, AddressOf HandleNewAccountVerifyKeyDown
            AddHandler KeyDown, AddressOf HandleMenuKeyDown
            AddHandler timerSprite.Elapsed, Sub(sender, e) _client.RefreshWebsite()

            AddHandler imgCharacter0.MouseDown, Sub(sender, e) SelectCharacterSlot(0)
            AddHandler imgCharacter1.MouseDown, Sub(sender, e) SelectCharacterSlot(1)
            AddHandler imgCharacter2.MouseDown, Sub(sender, e) SelectCharacterSlot(2)
            AddHandler lblCharacter0.MouseDown, Sub(sender, e) SelectCharacterSlot(0)
            AddHandler lblCharacter1.MouseDown, Sub(sender, e) SelectCharacterSlot(1)
            AddHandler lblCharacter2.MouseDown, Sub(sender, e) SelectCharacterSlot(2)

            AddHandler picClassFighter.CheckedChanged, AddressOf HandleClassSelectionChanged
            AddHandler picClassWizard.CheckedChanged, AddressOf HandleClassSelectionChanged
            AddHandler picClassCelestial.CheckedChanged, AddressOf HandleClassSelectionChanged
            AddHandler picClassGuardian.CheckedChanged, AddressOf HandleClassSelectionChanged
            AddHandler picClassAssassin.CheckedChanged, AddressOf HandleClassSelectionChanged
        End Sub

        Private Sub HandleLoginPage(sender As Object, e As EventArgs)
            If _client.SaveLogin Then
                txtLoginName.Text = _client.Username
                txtLoginPassword.Text = _client.Password
            End If
            ShowPage(_loginPage)
            txtLoginName.Focus()
        End Sub

        Private Sub HandleRegisterPage(sender As Object, e As EventArgs)
            ShowPage(_registerPage)
            txtNewAcctName.Focus()
        End Sub

        Private Sub HandleLoginConnect(sender As Object, e As EventArgs)
            Dim username = If(txtLoginName.Text, String.Empty).Trim()
            Dim password = If(txtLoginPassword.Text, String.Empty).Trim()
            If username.Length = 0 AndAlso password.Length = 0 Then
                GameDialogs.Alert(Me, "Please enter your login name and password!", "Alert")
                Return
            End If
            If username.Length = 0 Then
                GameDialogs.Alert(Me, "Please enter your login name!", "Alert")
                txtLoginName.Focus()
                Return
            End If
            If password.Length = 0 Then
                GameDialogs.Alert(Me, "Please enter your password!", "Alert")
                txtLoginPassword.Focus()
                Return
            End If
            _client.SaveLoginCredentials(username, password)
            _client.MenuState(MenuState.Login)
        End Sub

        Private Sub HandleNewAccountConnect(sender As Object, e As EventArgs)
            Dim username = If(txtNewAcctName.Text, String.Empty).Trim()
            Dim password = If(txtNewAcctPassword.Text, String.Empty)
            Dim verify = If(txtNewAcctVerify.Text, String.Empty)
            If password <> verify Then
                GameDialogs.Alert(Me, "Passwords do not match.", "Alert")
                txtNewAcctVerify.Focus()
                Return
            End If
            If username.Length = 0 OrElse password.Trim().Length = 0 Then Return
            If Not IsPrintableAscii(username) Then
                GameDialogs.Alert(Me, "You cannot use high ascii chars in your name, please re-enter.", "Alert")
                txtNewAcctName.Text = String.Empty
                txtNewAcctName.Focus()
                Return
            End If
            _client.SaveLoginCredentials(username, password)
            _client.MenuState(MenuState.NewAccount, username)
        End Sub

        Private Sub HandleNewCharacter(sender As Object, e As EventArgs)
            _client.MenuState(MenuState.NewCharacter, selectedIndex:=lstChars.SelectedIndex)
            ShowClassSelection()
        End Sub

        Private Sub HandleCharactersCancel(sender As Object, e As EventArgs)
            _client.Disconnect()
            ShowPage(_loginPage)
        End Sub

        Private Sub HandleDeleteCharacter(sender As Object, e As EventArgs)
            If lstChars.SelectedIndex < 0 Then Return
            Dim result = GameDialogs.Confirm(Me, "Are you sure you wish to delete this character?", "Alert")
            If result = GameDialogResult.Yes Then _client.MenuState(MenuState.DeleteCharacter, selectedIndex:=lstChars.SelectedIndex)
        End Sub

        Private Sub HandleAddCharacter(sender As Object, e As EventArgs)
            Dim characterName = If(txtNewCharName.Text, String.Empty).Trim()
            If characterName.Length = 0 Then Return
            If Not IsPrintableAscii(characterName) Then
                GameDialogs.Alert(Me, "You cannot use high ascii chars in your name, please re-enter.", "Alert")
                txtNewCharName.Text = String.Empty
                txtNewCharName.Focus()
                Return
            End If
            _client.MenuState(MenuState.AddCharacter, characterName, lstChars.SelectedIndex)
        End Sub

        Private Sub HandleClassContinue(sender As Object, e As EventArgs)
            ShowPage(_newCharacterPage)
            RefreshSelectedClass()
            txtNewCharName.Focus()
        End Sub

        Private Sub HandleClassBack(sender As Object, e As EventArgs)
            _client.Disconnect()
            ShowMenuHome()
        End Sub

        Private Sub HandlePreviousClass(sender As Object, e As EventArgs)
            _client.CurrentSex = 1
            picMale.Checked = True
            RefreshSelectedClass()
        End Sub

        Private Sub HandleNextClass(sender As Object, e As EventArgs)
            _client.CurrentSex = 0
            picFemale.Checked = True
            RefreshSelectedClass()
        End Sub

        Private Sub HandleSexChanged(sender As Object, e As EventArgs)
            If picMale.Checked Then _client.CurrentSex = 1
            If picFemale.Checked Then _client.CurrentSex = 0
            _client.RefreshNewCharacterPreview(_client.CurrentClass, _client.CurrentSex)
        End Sub

        Private Sub HandleLoginNameKeyDown(sender As Object, e As KeyEventArgs)
            If e.Key = Keys.Enter Then
                txtLoginPassword.Focus()
                e.Handled = True
            End If
        End Sub

        Private Sub HandleLoginPasswordKeyDown(sender As Object, e As KeyEventArgs)
            If e.Key = Keys.Enter Then
                HandleLoginConnect(sender, EventArgs.Empty)
                e.Handled = True
            End If
        End Sub

        Private Sub HandleNewAccountVerifyKeyDown(sender As Object, e As KeyEventArgs)
            If e.Key = Keys.Enter Then
                HandleNewAccountConnect(sender, EventArgs.Empty)
                e.Handled = True
            End If
        End Sub

        Private Sub HandleMenuKeyDown(sender As Object, e As KeyEventArgs)
            If e.Key <> Keys.F1 Then Return
            ' twinBASIC opened an IP input box here.  Keep the engine request on
            ' the shared runtime so each platform can provide its preferred dialog.
            _client.MainGameAction("PromptServerIp")
            e.Handled = True
        End Sub

        Private Shared Function IsPrintableAscii(value As String) As Boolean
            For Each ch In value
                Dim code = AscW(ch)
                If code < 32 OrElse code > 126 Then Return False
            Next
            Return True
        End Function

        Public Sub ShowMenuHome()
            ShowPage(_mainPage)
        End Sub

        Public Sub ShowCharacters()
            ShowPage(_charactersPage)
        End Sub

        Public Sub ShowClassSelection()
            _client.CurrentClass = Math.Max(0, Math.Min(_client.CurrentClass, Math.Max(0, _client.Classes.Count - 1)))
            ShowPage(_classPage)
            RefreshSelectedClass()
        End Sub

        Private Sub RefreshSelectedClass()
            If _client.Classes.Count = 0 Then Return
            Dim index = Math.Max(0, Math.Min(_client.CurrentClass, _client.Classes.Count - 1))
            Dim info = _client.Classes(index)
            lblSelectedClass.Caption = info.Name
            lblSTR.Caption = info.STR.ToString()
            lblDEF.Caption = info.DEF.ToString()
            lblSPEED.Caption = info.Speed.ToString()
            lblMAGI.Caption = info.MAGI.ToString()
            _client.RefreshNewCharacterPreview(index, _client.CurrentSex)
        End Sub

        Public Sub SetCharacterSlot(slot As Integer, name As String, Optional sprite As Integer = 0)
            Dim label As LegacyLabel = Nothing
            Select Case slot
                Case 0 : label = lblCharacter0
                Case 1 : label = lblCharacter1
                Case 2 : label = lblCharacter2
                Case Else : Return
            End Select
            label.Caption = If(String.IsNullOrWhiteSpace(name), "Empty", name)
        End Sub

        Public Sub SelectCharacterSlot(slot As Integer)
            If slot < 0 Then Return
            lstChars.SelectedIndex = slot
        End Sub

        Private Sub HandleClassSelectionChanged(sender As Object, e As EventArgs)
            Dim selected = TryCast(sender, LegacyRadioButton)
            If selected Is Nothing OrElse Not selected.Checked Then Return
            lblSelectedClass.Caption = selected.Caption
            For i = 0 To _client.Classes.Count - 1
                If String.Equals(_client.Classes(i).Name, selected.Caption, StringComparison.OrdinalIgnoreCase) Then
                    _client.CurrentClass = i
                    Exit For
                End If
            Next
            RefreshSelectedClass()
        End Sub

        Private Sub ShowPage(page As Control)
            If page IsNot Nothing Then _pageHost.Content = page
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            _client.InitializeMenu()
            _client.RefreshWebsite()
            ShowMenuHome()
        End Sub
    End Class
End Namespace
