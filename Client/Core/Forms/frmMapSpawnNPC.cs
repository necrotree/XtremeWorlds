using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmMapSpawnNPC : EditForm
    {

        public readonly LegacyListBox lstNPC;
        public readonly LegacyButton cmdOK;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyComboBox cmbNPCDir;
        public readonly LegacyCheckBox chkStationary;

        public frmMapSpawnNPC()
        {
            Title = "NPC Spawn";
            ClientSize = new Size(306, 204);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lstNPC = new LegacyListBox();
            lstNPC.Size = new Size(289, 121);
            rootLayout.Add(lstNPC, 8, 8);

            cmdOK = new LegacyButton();
            cmdOK.Caption = "OK";
            cmdOK.Size = new Size(137, 33);
            rootLayout.Add(cmdOK, 8, 160);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(137, 33);
            rootLayout.Add(cmdCancel, 160, 160);

            cmbNPCDir = new LegacyComboBox();
            cmbNPCDir.Items.Add("Up");
            cmbNPCDir.Items.Add("Down");
            cmbNPCDir.Items.Add("Left");
            cmbNPCDir.Items.Add("Right");
            cmbNPCDir.Size = new Size(137, 21);
            rootLayout.Add(cmbNPCDir, 160, 136);

            chkStationary = new LegacyCheckBox();
            chkStationary.Caption = "Stationary";
            chkStationary.Checked = false;
            chkStationary.Size = new Size(73, 17);
            rootLayout.Add(chkStationary, 8, 136);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}