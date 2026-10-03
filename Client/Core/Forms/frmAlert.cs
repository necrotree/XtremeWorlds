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
    /// TwinBASIC-style alert dialog.
    /// The original frmAlert background and OK/Yes/No artwork are used as the
    /// visible controls; the ImageViews themselves are the click targets.
    /// </summary>
    public class frmAlert : Dialog<DialogResult>
    {
        private readonly PixelLayout _layout;
        private readonly AlertButtons _buttons;

        public readonly LegacyLabel lblTitle;
        public readonly LegacyTextArea txtMessage;
        public readonly ImageView imgOk;
        public readonly ImageView imgYes;
        public readonly ImageView imgNo;
        public readonly ImageView imgAlert;
        public readonly LegacyTextBox txtInput;

        // Fallback buttons are only shown when a converted image asset is missing.
        private readonly LegacyButton _fallbackOk;
        private readonly LegacyButton _fallbackYes;
        private readonly LegacyButton _fallbackNo;

        public frmAlert(string message, string title = "XtremeWorlds", AlertButtons buttons = AlertButtons.Ok)
        {
            _buttons = buttons;

            Title = string.IsNullOrWhiteSpace(title) ? "XtremeWorlds" : title;
            Style = "AlertWindow";
            ClientSize = new Size(262, 128);
            Resizable = false;
            Maximizable = false;
            Minimizable = false;
            ShowInTaskbar = false;
            WindowStyle = WindowStyle.None;

            _layout = new PixelLayout();
            Content = _layout;

            // TwinBASIC background image sits behind everything else.
            imgAlert = new ImageView
            {
                Image = LoadAlertImage("imgAlert"),
                Size = new Size(262, 128)
            };
            _layout.Add(imgAlert, 0, 0);

            lblTitle = new LegacyLabel
            {
                Caption = Title,
                Style = "XtremeWorldsSkinLabel",
                Size = new Size(230, 20)
            };
            _layout.Add(lblTitle, 16, 14);

            txtMessage = new LegacyTextArea
            {
                Text = message ?? string.Empty,
                Locked = true,
                Wrap = true,
                Style = "AlertMessage",
                Size = new Size(230, 44)
            };
            _layout.Add(txtMessage, 16, 40);

            txtInput = new LegacyTextBox
            {
                Text = string.Empty,
                Visible = false,
                Style = "AlertInput",
                Size = new Size(230, 24)
            };
            _layout.Add(txtInput, 16, 76);

            // Original TwinBASIC positions/sizes.
            imgOk = MakeImageButton("imgOk", new Size(104, 23), (_, _) => Close(DialogResult.Ok));
            imgYes = MakeImageButton("imgYes", new Size(105, 23), (_, _) => Close(DialogResult.Yes));
            imgNo = MakeImageButton("imgNo", new Size(109, 28), (_, _) => Close(DialogResult.No));

            _layout.Add(imgOk, 79, 96);
            _layout.Add(imgYes, 20, 96);
            _layout.Add(imgNo, 133, 93);

            _fallbackOk = MakeFallbackButton("OK", new Size(104, 23), (_, _) => Close(DialogResult.Ok));
            _fallbackYes = MakeFallbackButton("Yes", new Size(105, 23), (_, _) => Close(DialogResult.Yes));
            _fallbackNo = MakeFallbackButton("No", new Size(109, 28), (_, _) => Close(DialogResult.No));

            _layout.Add(_fallbackOk, 79, 96);
            _layout.Add(_fallbackYes, 20, 96);
            _layout.Add(_fallbackNo, 133, 93);

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

        public static void ShowAlert(Control? parent, string message, string title = "XtremeWorlds")
        {
            var dialog = new frmAlert(message, title, AlertButtons.Ok);
            if (parent is null)
                dialog.ShowModal();
            else
                dialog.ShowModal(parent);
        }

        public static DialogResult ShowConfirm(Control? parent, string message, string title = "XtremeWorlds")
        {
            var dialog = new frmAlert(message, title, AlertButtons.YesNo);
            return parent is null ? dialog.ShowModal() : dialog.ShowModal(parent);
        }
    }
}
