using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmKeyOpen : EditForm
    {

        public readonly LegacyLabel Label1;
        public readonly LegacyLabel Label2;
        public readonly LegacyLabel lblX;
        public readonly LegacyLabel lblY;
        public readonly LegacyScrollBar scrlX;
        public readonly LegacyScrollBar scrlY;
        public readonly LegacyButton cmdOk;
        public readonly LegacyButton cmdCancel;

        public frmKeyOpen()
        {
            Title = "Key Open";
            ClientSize = new Size(321, 130);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            Label1 = new LegacyLabel();
            Label1.Caption = "X";
            Label1.Size = new Size(17, 25);
            rootLayout.Add(Label1, 8, 16);

            Label2 = new LegacyLabel();
            Label2.Caption = "Y";
            Label2.Size = new Size(17, 25);
            rootLayout.Add(Label2, 8, 48);

            lblX = new LegacyLabel();
            lblX.Caption = "0";
            lblX.Size = new Size(25, 25);
            rootLayout.Add(lblX, 288, 16);

            lblY = new LegacyLabel();
            lblY.Caption = "0";
            lblY.Size = new Size(25, 25);
            rootLayout.Add(lblY, 288, 48);

            scrlX = new LegacyScrollBar();
            scrlX.MinValue = 0;
            scrlX.MaxValue = 15;
            scrlX.Value = 0;
            scrlX.Orientation = Orientation.Horizontal;
            scrlX.SmallChange = 1;
            scrlX.LargeChange = 1;
            scrlX.Size = new Size(249, 25);
            rootLayout.Add(scrlX, 32, 16);

            scrlY = new LegacyScrollBar();
            scrlY.MinValue = 0;
            scrlY.MaxValue = 11;
            scrlY.Value = 0;
            scrlY.Orientation = Orientation.Horizontal;
            scrlY.SmallChange = 1;
            scrlY.LargeChange = 1;
            scrlY.Size = new Size(249, 25);
            rootLayout.Add(scrlY, 32, 48);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(145, 33);
            rootLayout.Add(cmdOk, 8, 88);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(145, 33);
            rootLayout.Add(cmdCancel, 168, 88);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}