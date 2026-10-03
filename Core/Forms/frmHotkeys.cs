using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmHotkeys : Form
    {

        public readonly LegacyListBox lstActions;
        public readonly LegacyLabel lblKey;
        public readonly LegacyComboBox cboKey;
        public readonly LegacyLabel lblHelp;
        public readonly LegacyButton cmdArrows;
        public readonly LegacyButton cmdWASD;
        public readonly LegacyButton cmdSave;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyPictureBox picKeyboard;

        public frmHotkeys()
        {
            Title = "Keyboard Shortcuts";
            ClientSize = new Size(1004, 536);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lstActions = new LegacyListBox();
            lstActions.Size = new Size(550, 173);
            rootLayout.Add(lstActions, 12, 304);

            lblKey = new LegacyLabel();
            lblKey.Caption = "Key for selected action:";
            lblKey.Size = new Size(390, 20);
            rootLayout.Add(lblKey, 580, 304);

            cboKey = new LegacyComboBox();
            cboKey.Size = new Size(410, 21);
            rootLayout.Add(cboKey, 580, 328);

            lblHelp = new LegacyLabel();
            lblHelp.Caption = "Select an action or slot, then click a key above. Green: selected binding. Blue: assigned. Gray: system keys. Enter is reserved for chat/pickup. Choose Unassigned to clear a binding.";
            lblHelp.Size = new Size(410, 68);
            rootLayout.Add(lblHelp, 580, 360);

            cmdArrows = new LegacyButton();
            cmdArrows.Caption = "Arrow defaults";
            cmdArrows.Size = new Size(196, 28);
            rootLayout.Add(cmdArrows, 580, 444);

            cmdWASD = new LegacyButton();
            cmdWASD.Caption = "WASD defaults";
            cmdWASD.Size = new Size(204, 28);
            rootLayout.Add(cmdWASD, 786, 444);

            cmdSave = new LegacyButton();
            cmdSave.Caption = "Save";
            cmdSave.Size = new Size(96, 28);
            rootLayout.Add(cmdSave, 786, 496);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(96, 28);
            rootLayout.Add(cmdCancel, 894, 496);

            picKeyboard = new LegacyPictureBox();
            picKeyboard.Size = new Size(996, 280);
            rootLayout.Add(picKeyboard, 6, 8);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}