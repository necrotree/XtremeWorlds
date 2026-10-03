using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public enum AlertButtons
    {
        Ok,
        YesNo
    }

    /// <summary>
    /// Pixel-art alert dialog using the original XtremeWorlds alert frame and
    /// OK/Yes/No button artwork at native resolution.
    /// </summary>
    public class frmAlert : Dialog<DialogResult>
    {
        private const int AlertWidth = 262;
        private const int AlertHeight = 128;

        private readonly PixelLayout _layout;
        private readonly AlertButtons _buttons;

        public readonly LegacyLabel lblTitle;
        public readonly LegacyTextArea txtMessage;
        public readonly ImageView imgOk;
        public readonly ImageView imgYes;
        public readonly ImageView imgNo;
        public readonly ImageView imgAlert;
        public readonly LegacyTextBox txtInput;

        private readonly LegacyButton _fallbackOk;
        private readonly LegacyButton _fallbackYes;
        private readonly LegacyButton _fallbackNo;

        public frmAlert(string message, string title = "Alert", AlertButtons buttons = AlertButtons.Ok)
        {
            _buttons = buttons;

            Title = string.IsNullOrWhiteSpace(title) ? "Alert" : title;
            Style = "AlertWindow";
            ClientSize = new Size(AlertWidth, AlertHeight);
            Resizable = false;
            Maximizable = false;
            Minimizable = false;
            ShowInTaskbar = false;
            WindowStyle = WindowStyle.None;

            _layout = new PixelLayout();
            Content = _layout;

            imgAlert = new ImageView
            {
                Image = LoadAlertImage("alert"),
                Size = new Size(AlertWidth, AlertHeight)
            };
            _layout.Add(imgAlert, 0, 0);

            // The supplied alert.png already contains the gold "Alert" header.
            // Keep the legacy title control available for compatibility without
            // drawing a second title over the pixel artwork.
            lblTitle = new LegacyLabel
            {
                Caption = Title,
                Visible = false,
                Size = new Size(220, 18)
            };
            _layout.Add(lblTitle, 10, 1);

            txtMessage = new LegacyTextArea
            {
                Text = message ?? string.Empty,
                Locked = true,
                Wrap = true,
                Style = "AlertMessage",
                Size = new Size(226, 58)
            };
            _layout.Add(txtMessage, 18, 27);

            txtInput = new LegacyTextBox
            {
                Text = string.Empty,
                Visible = false,
                Style = "AlertInput",
                Size = new Size(226, 22)
            };
            _layout.Add(txtInput, 18, 64);

            imgOk = MakeImageButton("ok", new Size(104, 23), (_, _) => Close(DialogResult.Ok));
            imgYes = MakeImageButton("yes", new Size(105, 23), (_, _) => Close(DialogResult.Yes));
            imgNo = MakeImageButton("no", new Size(109, 28), (_, _) => Close(DialogResult.No));

            _layout.Add(imgOk, 79, 94);
            _layout.Add(imgYes, 13, 94);
            _layout.Add(imgNo, 140, 91);

            _fallbackOk = MakeFallbackButton("OK", new Size(104, 23), (_, _) => Close(DialogResult.Ok));
            _fallbackYes = MakeFallbackButton("Yes", new Size(105, 23), (_, _) => Close(DialogResult.Yes));
            _fallbackNo = MakeFallbackButton("No", new Size(109, 28), (_, _) => Close(DialogResult.No));

            _layout.Add(_fallbackOk, 79, 94);
            _layout.Add(_fallbackYes, 13, 94);
            _layout.Add(_fallbackNo, 140, 91);

            bool okMode = buttons == AlertButtons.Ok;
            imgOk.Visible = okMode && imgOk.Image is not null;
            imgYes.Visible = !okMode && imgYes.Image is not null;
            imgNo.Visible = !okMode && imgNo.Image is not null;

            _fallbackOk.Visible = okMode && imgOk.Image is null;
            _fallbackYes.Visible = !okMode && imgYes.Image is null;
            _fallbackNo.Visible = !okMode && imgNo.Image is null;

            KeyDown += HandleKeyDown;
            Shown += HandleShown;
        }

        private static Image? LoadAlertImage(string name)
        {
            return AssetLoader.LoadImage($"frmAlert/{name}.png")
                ?? AssetLoader.LoadImage($"frmAlert/{name}.jpg")
                ?? AssetLoader.LoadImage($"frmAlert/{name}.bmp");
        }

        private static ImageView MakeImageButton(string assetName, Size size, EventHandler<MouseEventArgs> handler)
        {
            var view = new ImageView
            {
                Image = LoadAlertImage(assetName),
                Size = size
            };
            view.MouseDown += handler;
            return view;
        }

        private static LegacyButton MakeFallbackButton(string caption, Size size, EventHandler<EventArgs> handler)
        {
            var button = new LegacyButton
            {
                Caption = caption,
                Style = "XtremeWorldsSkinButton",
                Size = size
            };
            button.Click += handler;
            return button;
        }

        private void HandleShown(object? sender, EventArgs e)
        {
            if (_buttons == AlertButtons.YesNo)
            {
                if (_fallbackNo.Visible)
                    _fallbackNo.Focus();
            }
            else if (_fallbackOk.Visible)
            {
                _fallbackOk.Focus();
            }
        }

        private void HandleKeyDown(object? sender, KeyEventArgs e)
        {
            if (e.Key == Keys.Enter)
            {
                Close(_buttons == AlertButtons.YesNo ? DialogResult.No : DialogResult.Ok);
                e.Handled = true;
            }
            else if (e.Key == Keys.Escape)
            {
                Close(_buttons == AlertButtons.YesNo ? DialogResult.No : DialogResult.Cancel);
                e.Handled = true;
            }
        }

        public void ConfigureInput(string message, string defaultValue)
        {
            txtMessage.Text = message ?? string.Empty;
            txtMessage.Size = new Size(226, 31);
            _layout.Move(txtMessage, 18, 26);

            txtInput.Text = defaultValue ?? string.Empty;
            txtInput.Visible = true;
            _layout.Move(txtInput, 18, 60);

            if (_buttons == AlertButtons.YesNo)
            {
                _layout.Move(imgYes, 13, 94);
                _layout.Move(imgNo, 140, 91);
                _layout.Move(_fallbackYes, 13, 94);
                _layout.Move(_fallbackNo, 140, 91);
            }
        }

        public static void ShowAlert(Control? parent, string message, string title = "Alert")
        {
            using var dialog = new frmAlert(message, title, AlertButtons.Ok);
            if (parent is null)
                dialog.ShowModal();
            else
                dialog.ShowModal(parent);
        }

        public static DialogResult ShowConfirm(Control? parent, string message, string title = "Alert")
        {
            using var dialog = new frmAlert(message, title, AlertButtons.YesNo);
            return parent is null ? dialog.ShowModal() : dialog.ShowModal(parent);
        }
    }
}
