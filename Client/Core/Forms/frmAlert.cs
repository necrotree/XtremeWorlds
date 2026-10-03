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

    public class frmAlert : Dialog<DialogResult>
    {
        public readonly LegacyLabel lblTitle;
        public readonly LegacyTextArea txtMessage;
        public readonly LegacyButton btnOk;
        public readonly LegacyButton btnYes;
        public readonly LegacyButton btnNo;
        public readonly LegacyTextBox txtInput;

        public frmAlert(string message, string title = "XtremeWorlds", AlertButtons buttons = AlertButtons.Ok)
        {
            Title = title;
            ClientSize = new Size(330, 170);
            Resizable = false;

            lblTitle = new LegacyLabel
            {
                Caption = title,
                Style = "XtremeWorldsSkinLabel"
            };

            txtMessage = new LegacyTextArea
            {
                Text = message ?? string.Empty,
                Locked = true,
                Wrap = true,
                Size = new Size(286, 72)
            };

            txtInput = new LegacyTextBox
            {
                Visible = false,
                Size = new Size(286, 24)
            };

            btnOk = new LegacyButton
            {
                Caption = "OK",
                Style = "XtremeWorldsSkinButton",
                Size = new Size(92, 28),
                Visible = buttons == AlertButtons.Ok
            };

            btnYes = new LegacyButton
            {
                Caption = "Yes",
                Style = "XtremeWorldsSkinButton",
                Size = new Size(92, 28),
                Visible = buttons == AlertButtons.YesNo
            };

            btnNo = new LegacyButton
            {
                Caption = "No",
                Style = "XtremeWorldsSkinButton",
                Size = new Size(92, 28),
                Visible = buttons == AlertButtons.YesNo
            };

            btnOk.Click += (_, _) => Close(DialogResult.Ok);
            btnYes.Click += (_, _) => Close(DialogResult.Yes);
            btnNo.Click += (_, _) => Close(DialogResult.No);

            var buttonsRow = new StackLayout
            {
                Orientation = Orientation.Horizontal,
                Spacing = 10,
                HorizontalContentAlignment = HorizontalAlignment.Center,
                Items =
                {
                    btnYes,
                    btnNo,
                    btnOk
                }
            };

            Content = new StackLayout
            {
                Padding = new Padding(16),
                Spacing = 10,
                Items =
                {
                    lblTitle,
                    txtMessage,
                    txtInput,
                    buttonsRow
                }
            };
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
