using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

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
    /// Pixel-art alert dialog based on the original XtremeWorlds frmAlert skin.
    /// The frame and buttons use the supplied game artwork at native resolution.
    /// </summary>
    public class frmAlert : Dialog<GameDialogResult>
    {
        private const int AlertWidth = 262;
        private const int AlertHeight = 128;

        private readonly PixelLayout _layout;
        private readonly ImageView _background;
        private readonly TextArea _message;
        private readonly TextBox _input;
        private readonly ImageView _ok;
        private readonly ImageView _yes;
        private readonly ImageView _no;

        private GameDialogResult _defaultResult = GameDialogResult.Ok;
        private GameDialogResult _escapeResult = GameDialogResult.Ok;

        public string InputValue => _input.Text ?? string.Empty;

        public frmAlert()
        {
            Title = "Alert";
            ClientSize = new Size(AlertWidth, AlertHeight);
            Resizable = false;
            Maximizable = false;
            Minimizable = false;
            ShowInTaskbar = false;
            WindowStyle = WindowStyle.None;
            BackgroundColor = Colors.Black;

            _layout = new PixelLayout();
            Content = _layout;

            _background = new ImageView
            {
                Image = RequireImage("frmAlert/alert.png"),
                Size = new Size(AlertWidth, AlertHeight)
            };
            _layout.Add(_background, 0, 0);

            _message = new TextArea
            {
                ReadOnly = true,
                Wrap = true,
                Size = new Size(226, 58),
                BackgroundColor = Colors.Transparent,
                TextColor = Color.FromArgb(238, 224, 186),
                Font = new Font(SystemFont.Default, 9f)
            };
            _layout.Add(_message, 18, 27);

            _input = new TextBox
            {
                Visible = false,
                Size = new Size(226, 22),
                BackgroundColor = Color.FromArgb(31, 20, 20),
                TextColor = Color.FromArgb(238, 224, 186)
            };
            _layout.Add(_input, 18, 65);

            _ok = CreateImageButton("frmAlert/ok.png", new Size(104, 23), HandleOk);
            _yes = CreateImageButton("frmAlert/yes.png", new Size(105, 23), HandleYes);
            _no = CreateImageButton("frmAlert/no.png", new Size(109, 28), HandleNo);

            _layout.Add(_ok, 79, 94);
            _layout.Add(_yes, 13, 94);
            _layout.Add(_no, 140, 91);

            KeyDown += HandleKeyDown;
            Shown += HandleShown;
        }

        public void Configure(string message, GameDialogButtons buttons, string titleText = "Alert")
        {
            Title = string.IsNullOrWhiteSpace(titleText) ? "Alert" : titleText;
            _message.Text = message ?? string.Empty;
            _message.Size = new Size(226, 58);
            _layout.Move(_message, 18, 27);

            _input.Visible = false;
            ClientSize = new Size(AlertWidth, AlertHeight);

            _ok.Visible = buttons == GameDialogButtons.Ok;
            _yes.Visible = buttons == GameDialogButtons.YesNo;
            _no.Visible = buttons == GameDialogButtons.YesNo;

            if (buttons == GameDialogButtons.YesNo)
            {
                _defaultResult = GameDialogResult.No;
                _escapeResult = GameDialogResult.No;

                _layout.Move(_yes, 13, 94);
                _layout.Move(_no, 140, 91);
            }
            else
            {
                _defaultResult = GameDialogResult.Ok;
                _escapeResult = GameDialogResult.Ok;

                _layout.Move(_ok, 79, 94);
            }
        }

        public void ConfigureInput(string message, string defaultValue, string titleText = "Alert")
        {
            Configure(message, GameDialogButtons.YesNo, titleText);

            // Keep the supplied 262x128 skin at its exact native size.
            // The input field fits inside the red message panel rather than
            // stretching the artwork vertically.
            _message.Size = new Size(226, 31);
            _layout.Move(_message, 18, 26);

            _input.Text = defaultValue ?? string.Empty;
            _input.Visible = true;
            _layout.Move(_input, 18, 60);

            _layout.Move(_yes, 13, 94);
            _layout.Move(_no, 140, 91);
        }

        private static Image RequireImage(string relativePath)
        {
            var image = AssetLoader.LoadImage(relativePath);
            if (image is null)
                throw new InvalidOperationException($"Unable to load frmAlert pixel-art asset '{relativePath}'.");

            return image;
        }

        private static ImageView CreateImageButton(
            string assetPath,
            Size size,
            EventHandler<MouseEventArgs> handler)
        {
            var image = new ImageView
            {
                Image = RequireImage(assetPath),
                Size = size,
                Cursor = Cursors.Pointer
            };

            image.MouseDown += handler;
            return image;
        }

        private void HandleShown(object sender, EventArgs e)
        {
            if (_input.Visible)
                _input.Focus();
        }

        private void HandleOk(object sender, MouseEventArgs e)
        {
            if (e.Buttons.HasFlag(MouseButtons.Primary))
                Close(GameDialogResult.Ok);
        }

        private void HandleYes(object sender, MouseEventArgs e)
        {
            if (e.Buttons.HasFlag(MouseButtons.Primary))
                Close(GameDialogResult.Yes);
        }

        private void HandleNo(object sender, MouseEventArgs e)
        {
            if (e.Buttons.HasFlag(MouseButtons.Primary))
                Close(GameDialogResult.No);
        }

        private void HandleKeyDown(object sender, KeyEventArgs e)
        {
            switch (e.Key)
            {
                case Keys.Enter:
                    Close(_defaultResult);
                    e.Handled = true;
                    break;

                case Keys.Escape:
                    Close(_escapeResult);
                    e.Handled = true;
                    break;

                case Keys.Left:
                case Keys.Right:
                case Keys.Tab:
                    if (_yes.Visible && _no.Visible)
                    {
                        _defaultResult = _defaultResult == GameDialogResult.Yes
                            ? GameDialogResult.No
                            : GameDialogResult.Yes;
                        e.Handled = true;
                    }
                    break;
            }
        }
    }
}
