using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmMapWarp : EditForm
    {

        public readonly LegacyLabel lblY;
        public readonly LegacyLabel lblX;
        public readonly LegacyLabel Label3;
        public readonly LegacyLabel Label2;
        public readonly LegacyLabel Label1;
        public readonly LegacyTextBox txtMap;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyButton cmdOk;
        public readonly LegacyScrollBar scrlY;
        public readonly LegacyScrollBar scrlX;

        public frmMapWarp()
        {
            Title = "Map Warp";
            ClientSize = new Size(314, 138);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lblY = new LegacyLabel();
            lblY.Caption = "0";
            lblY.Size = new Size(33, 17);
            rootLayout.Add(lblY, 272, 64);

            lblX = new LegacyLabel();
            lblX.Caption = "0";
            lblX.Size = new Size(33, 17);
            rootLayout.Add(lblX, 272, 40);

            Label3 = new LegacyLabel();
            Label3.Caption = "Y";
            Label3.Size = new Size(33, 17);
            rootLayout.Add(Label3, 8, 64);

            Label2 = new LegacyLabel();
            Label2.Caption = "X";
            Label2.Size = new Size(33, 17);
            rootLayout.Add(Label2, 8, 40);

            Label1 = new LegacyLabel();
            Label1.Caption = "Map";
            Label1.Size = new Size(33, 17);
            rootLayout.Add(Label1, 8, 8);

            txtMap = new LegacyTextBox();
            txtMap.Text = "1";
            txtMap.Size = new Size(257, 26);
            rootLayout.Add(txtMap, 48, 8);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(137, 33);
            rootLayout.Add(cmdCancel, 168, 96);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(137, 33);
            rootLayout.Add(cmdOk, 8, 96);

            scrlY = new LegacyScrollBar();
            scrlY.MinValue = 0;
            scrlY.MaxValue = 11;
            scrlY.Value = 0;
            scrlY.Orientation = Orientation.Horizontal;
            scrlY.SmallChange = 1;
            scrlY.LargeChange = 1;
            scrlY.Size = new Size(217, 17);
            rootLayout.Add(scrlY, 48, 64);

            scrlX = new LegacyScrollBar();
            scrlX.MinValue = 0;
            scrlX.MaxValue = 15;
            scrlX.Value = 0;
            scrlX.Orientation = Orientation.Horizontal;
            scrlX.SmallChange = 1;
            scrlX.LargeChange = 1;
            scrlX.Size = new Size(217, 17);
            rootLayout.Add(scrlX, 48, 40);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}