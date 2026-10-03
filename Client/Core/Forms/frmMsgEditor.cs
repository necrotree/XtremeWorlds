using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmMsgEditor : EditForm
    {

        public readonly LegacyLabel Label1;
        public readonly LegacyLabel Label2;
        public readonly LegacyLabel Label3;
        public readonly LegacyRadioButton optGlobal;
        public readonly LegacyRadioButton optPlayer;
        public readonly LegacyButton cmdOK;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyTextBox txtMsgEditorText;

        public frmMsgEditor()
        {
            Title = "Map Message";
            ClientSize = new Size(292, 117);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            Label1 = new LegacyLabel();
            Label1.Caption = "Message Type";
            Label1.Size = new Size(81, 17);
            rootLayout.Add(Label1, 8, 64);

            Label2 = new LegacyLabel();
            Label2.Caption = "Message Text";
            Label2.Size = new Size(81, 17);
            rootLayout.Add(Label2, 8, 8);

            Label3 = new LegacyLabel();
            Label3.Caption = "The maximum length is 255 characters!";
            Label3.Size = new Size(185, 17);
            rootLayout.Add(Label3, 48, 32);

            optGlobal = new LegacyRadioButton();
            optGlobal.Caption = "Global";
            optGlobal.Size = new Size(89, 17);
            rootLayout.Add(optGlobal, 200, 64);

            optPlayer = new LegacyRadioButton(optGlobal);
            optPlayer.Caption = "Player";
            optPlayer.Value = true;
            optPlayer.Size = new Size(89, 17);
            rootLayout.Add(optPlayer, 104, 64);

            cmdOK = new LegacyButton();
            cmdOK.Caption = "Ok";
            cmdOK.Size = new Size(97, 25);
            rootLayout.Add(cmdOK, 32, 88);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(97, 25);
            rootLayout.Add(cmdCancel, 176, 88);

            txtMsgEditorText = new LegacyTextBox();
            txtMsgEditorText.Text = "Your Text Here";
            txtMsgEditorText.Size = new Size(193, 19);
            rootLayout.Add(txtMsgEditorText, 96, 8);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}