using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmMapBlock : EditForm
    {

        public readonly LegacyLabel lblBlockType;
        public readonly LegacyLabel lblBlockType_1;
        public readonly LegacyLabel lblBlockType_2;
        public readonly LegacyCheckBox chkBlockType;
        public readonly LegacyCheckBox chkBlockType_1;
        public readonly LegacyCheckBox chkBlockType_2;
        public readonly LegacyButton cmdOK;
        public readonly LegacyButton cmdCancel;

        public frmMapBlock()
        {
            Title = "Block";
            ClientSize = new Size(115, 123);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lblBlockType = new LegacyLabel();
            lblBlockType.Caption = "Player Block";
            lblBlockType.Size = new Size(65, 17);
            rootLayout.Add(lblBlockType, 8, 8);

            lblBlockType_1 = new LegacyLabel();
            lblBlockType_1.Caption = "NPC Block";
            lblBlockType_1.Size = new Size(65, 17);
            rootLayout.Add(lblBlockType_1, 8, 32);

            lblBlockType_2 = new LegacyLabel();
            lblBlockType_2.Caption = "Flight Block";
            lblBlockType_2.Size = new Size(65, 17);
            rootLayout.Add(lblBlockType_2, 8, 56);

            chkBlockType = new LegacyCheckBox();
            chkBlockType.Caption = "Check1";
            chkBlockType.Checked = false;
            chkBlockType.Size = new Size(17, 17);
            rootLayout.Add(chkBlockType, 88, 8);

            chkBlockType_1 = new LegacyCheckBox();
            chkBlockType_1.Caption = "Check1";
            chkBlockType_1.Checked = false;
            chkBlockType_1.Size = new Size(17, 17);
            rootLayout.Add(chkBlockType_1, 88, 32);

            chkBlockType_2 = new LegacyCheckBox();
            chkBlockType_2.Caption = "Check1";
            chkBlockType_2.Checked = false;
            chkBlockType_2.Size = new Size(17, 17);
            rootLayout.Add(chkBlockType_2, 88, 56);

            cmdOK = new LegacyButton();
            cmdOK.Caption = "Ok";
            cmdOK.Size = new Size(113, 17);
            rootLayout.Add(cmdOK, 0, 80);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(113, 17);
            rootLayout.Add(cmdCancel, 0, 104);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}