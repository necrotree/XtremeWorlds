using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmSendGetData : Form
    {

        public readonly LegacyLabel lblStatus;

        public frmSendGetData()
        {
            Title = "XtremeWorlds";
            ClientSize = new Size(319, 55);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lblStatus = new LegacyLabel();
            lblStatus.Caption = "";
            lblStatus.Size = new Size(265, 17);
            rootLayout.Add(lblStatus, 31, 29);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}