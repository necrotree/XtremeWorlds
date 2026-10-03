using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmDrop : Form
    {

        public readonly LegacyLabel lblName;
        public readonly LegacyLabel lblAmmount;
        public readonly LegacyLabel cmdPlus1;
        public readonly LegacyLabel cmdMinus1;
        public readonly LegacyLabel cmdPlus10;
        public readonly LegacyLabel cmdMinus10;
        public readonly LegacyLabel cmdPlus100;
        public readonly LegacyLabel cmdMinus100;
        public readonly LegacyLabel cmdPlus1000;
        public readonly LegacyLabel cmdMinus1000;
        public readonly LegacyLabel cmdOk;
        public readonly LegacyLabel cmdCancel;

        public frmDrop()
        {
            Title = "Drop Item";
            ClientSize = new Size(260, 370);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lblName = new LegacyLabel();
            lblName.Caption = "";
            lblName.Size = new Size(169, 17);
            rootLayout.Add(lblName, 72, 151);

            lblAmmount = new LegacyLabel();
            lblAmmount.Caption = "1";
            lblAmmount.Size = new Size(169, 17);
            rootLayout.Add(lblAmmount, 72, 187);

            cmdPlus1 = new LegacyLabel();
            cmdPlus1.Caption = "";
            cmdPlus1.Size = new Size(25, 9);
            rootLayout.Add(cmdPlus1, 24, 232);

            cmdMinus1 = new LegacyLabel();
            cmdMinus1.Caption = "";
            cmdMinus1.Size = new Size(25, 9);
            rootLayout.Add(cmdMinus1, 176, 232);

            cmdPlus10 = new LegacyLabel();
            cmdPlus10.Caption = "";
            cmdPlus10.Size = new Size(33, 17);
            rootLayout.Add(cmdPlus10, 24, 248);

            cmdMinus10 = new LegacyLabel();
            cmdMinus10.Caption = "";
            cmdMinus10.Size = new Size(25, 17);
            rootLayout.Add(cmdMinus10, 176, 248);

            cmdPlus100 = new LegacyLabel();
            cmdPlus100.Caption = "";
            cmdPlus100.Size = new Size(25, 17);
            rootLayout.Add(cmdPlus100, 32, 272);

            cmdMinus100 = new LegacyLabel();
            cmdMinus100.Caption = "";
            cmdMinus100.Size = new Size(33, 17);
            rootLayout.Add(cmdMinus100, 176, 272);

            cmdPlus1000 = new LegacyLabel();
            cmdPlus1000.Caption = "";
            cmdPlus1000.Size = new Size(41, 9);
            rootLayout.Add(cmdPlus1000, 24, 296);

            cmdMinus1000 = new LegacyLabel();
            cmdMinus1000.Caption = "";
            cmdMinus1000.Size = new Size(41, 9);
            rootLayout.Add(cmdMinus1000, 176, 296);

            cmdOk = new LegacyLabel();
            cmdOk.Caption = "";
            cmdOk.Size = new Size(49, 17);
            rootLayout.Add(cmdOk, 32, 336);

            cmdCancel = new LegacyLabel();
            cmdCancel.Caption = "";
            cmdCancel.Size = new Size(81, 17);
            rootLayout.Add(cmdCancel, 152, 336);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}