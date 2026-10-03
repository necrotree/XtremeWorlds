using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmAlert : Form
    {

        public readonly LegacyLabel lblTitle;
        public readonly LegacyTextArea txtMessage;
        public readonly ImageView imgOk;
        public readonly ImageView imgYes;
        public readonly ImageView imgNo;
        public readonly ImageView imgAlert;
        public readonly LegacyTextBox txtInput;

        public frmAlert()
        {
            Title = "Message";
            ClientSize = new Size(262, 128);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lblTitle = new LegacyLabel();
            lblTitle.Caption = "";
            lblTitle.Size = new Size(230, 20);
            rootLayout.Add(lblTitle, 16, 14);

            txtMessage = new LegacyTextArea();
            txtMessage.Text = "";
            txtMessage.Locked = true;
            txtMessage.Size = new Size(230, 44);
            rootLayout.Add(txtMessage, 16, 40);

            imgOk = new ImageView();
            imgOk.Visible = false;
            imgOk.Size = new Size(102, 24);
            rootLayout.Add(imgOk, 0, 0);

            imgYes = new ImageView();
            imgYes.Visible = false;
            imgYes.Size = new Size(102, 24);
            rootLayout.Add(imgYes, 0, 0);

            imgNo = new ImageView();
            imgNo.Visible = false;
            imgNo.Size = new Size(102, 24);
            rootLayout.Add(imgNo, 0, 0);

            imgAlert = new ImageView();
            imgAlert.Size = new Size(262, 128);
            rootLayout.Add(imgAlert, 0, 0);

            txtInput = new LegacyTextBox();
            txtInput.Text = "";
            txtInput.Visible = false;
            txtInput.Size = new Size(230, 24);
            rootLayout.Add(txtInput, 16, 76);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}