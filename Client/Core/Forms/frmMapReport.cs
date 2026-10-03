using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmMapReport : Form
    {

        public readonly LegacyListBox lstMapReport;
        public readonly LegacyButton cmdWarp;
        public readonly LegacyButton cmdExit;

        public frmMapReport()
        {
            Title = "Map Report";
            ClientSize = new Size(259, 206);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lstMapReport = new LegacyListBox();
            lstMapReport.Size = new Size(241, 160);
            rootLayout.Add(lstMapReport, 8, 8);

            cmdWarp = new LegacyButton();
            cmdWarp.Caption = "Warp";
            cmdWarp.Size = new Size(97, 25);
            rootLayout.Add(cmdWarp, 8, 176);

            cmdExit = new LegacyButton();
            cmdExit.Caption = "Close";
            cmdExit.Size = new Size(89, 25);
            rootLayout.Add(cmdExit, 160, 176);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}