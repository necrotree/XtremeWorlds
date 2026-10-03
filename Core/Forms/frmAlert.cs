using System;
using Eto.Drawing;
using Eto.Forms;

namespace XtremeWorlds.Client.Forms
{
    public enum GameDialogButtons
    {
        Ok = 0,
        YesNo = 1
    }

    public enum GameDialogResult
    {
        None = 0,
        Ok = 1,
        Yes = 6,
        No = 7
    }

    /// <summary>
    /// TwinBASIC-style alert dialog. The artwork is the original game skin,
    /// while the message, input field and buttons remain real Eto controls.
    /// </summary>
    public class frmAlert : Dialog<GameDialogResult>
    {

        private readonly PixelLayout _layout;
        private readonly TextArea _message;
        private readonly TextBox _input;
        private readonly Button _ok;
        private readonly Button _yes;
        private readonly Button _no;
        private GameDialogResult _defaultResult = GameDialogResult.Ok;
        private GameDialogResult _escapeResult = GameDialogResult.Ok;

        public string InputValue
        {
            get
            {
                return _input.Text ?? string.Empty;
            }
        }

        public frmAlert()
        {
            Title = "Alert";
            Style = "AlertWindow";
            ClientSize = new Size(262, 128);
            Resizable = false;
            Maximizable = false;
            Minimizable = false;
            ShowInTaskbar = false;
            WindowStyle = WindowStyle.None;

            _layout = new PixelLayout();
            Content = _layout;

            _message = new TextArea()
            {
                ReadOnly = true,
                Wrap = true,
                Style = "AlertMessage",
                Size = new Size(226, 58)
            };
            _layout.Add(_message, 18, 27);

            _input = new TextBox()
            {
                Visible = false,
                Style = "AlertInput",
                Size = new Size(226, 22)
            };
            _layout.Add(_input, 18, 70);

            _ok = CreateButton("AlertOkButton", new Size(104, 23), HandleOk);
            _yes = CreateButton("AlertYesButton", new Size(105, 23), HandleYes);
            _no = CreateButton("AlertNoButton", new Size(109, 28), HandleNo);

            _layout.Add(_ok, 79, 96);
            _layout.Add(_yes, 20, 96);
            _layout.Add(_no, 133, 93);

            KeyDown += HandleKeyDown;
            Shown += HandleShown;
        }

        private Button CreateButton(string styleName, Size buttonSize, EventHandler<EventArgs> handler)
        {
            var button = new Button()
            {
                Text = string.Empty,
                Style = styleName,
                Size = buttonSize
            };
            button.Click += handler;
            return button;
        }

        public void Configure(string message, GameDialogButtons buttons, string titleText = "Alert")
        {
            Title = string.IsNullOrWhiteSpace(titleText) ? "Alert" : titleText;
            _message.Text = message ?? string.Empty;
            _message.Size = new Size(226, 58);
            _input.Visible = false;
            ClientSize = new Size(262, 128);

            _ok.Visible = buttons == GameDialogButtons.Ok;
            _yes.Visible = buttons == GameDialogButtons.YesNo;
            _no.Visible = buttons == GameDialogButtons.YesNo;

            if (buttons == GameDialogButtons.YesNo)
            {
                _defaultResult = GameDialogResult.No;
                _escapeResult = GameDialogResult.No;
            }
            else
            {
                _defaultResult = GameDialogResult.Ok;
                _escapeResult = GameDialogResult.Ok;
            }
        }

        public void ConfigureInput(string message, string defaultValue, string titleText = "Alert")
        {
            Configure(message, GameDialogButtons.YesNo, titleText);
            ClientSize = new Size(262, 152);
            _message.Size = new Size(226, 34);
            _input.Text = defaultValue ?? string.Empty;
            _input.Visible = true;
            _layout.Move(_input, 18, 66);
            _layout.Move(_yes, 20, 119);
            _layout.Move(_no, 133, 116);
        }

        private void HandleShown(object sender, EventArgs e)
        {
            if (_input.Visible)
            {
                _input.Focus();
            }
            else if (_defaultResult == GameDialogResult.No)
            {
                _no.Focus();
            }
            else
            {
                _ok.Focus();
            }
        }

        private void HandleOk(object sender, EventArgs e)
        {
            Close(GameDialogResult.Ok);
        }

        private void HandleYes(object sender, EventArgs e)
        {
            Close(GameDialogResult.Yes);
        }

        private void HandleNo(object sender, EventArgs e)
        {
            Close(GameDialogResult.No);
        }

        private void HandleKeyDown(object sender, KeyEventArgs e)
        {
            switch (e.Key)
            {
                case Keys.Enter:
                    {
                        Close(_defaultResult);
                        e.Handled = true;
                        break;
                    }
                case Keys.Escape:
                    {
                        Close(_escapeResult);
                        e.Handled = true;
                        break;
                    }
            }
        }
    }
}