using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmMapKey : Form
    {

        public readonly LegacyLabel lblName;
        public readonly LegacyLabel Label1;
        public readonly LegacyLabel lblItem;
        public readonly LegacyLabel Label2;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyButton cmdOk;
        public readonly LegacyScrollBar scrlItem;
        public readonly LegacyCheckBox chkTake;

        public frmMapKey()
        {
            Title = "Map Key";
            ClientSize = new Size(321, 154);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lblName = new LegacyLabel();
            lblName.Caption = "";
            lblName.Size = new Size(249, 25);
            rootLayout.Add(lblName, 56, 8);

            Label1 = new LegacyLabel();
            Label1.Caption = "Item";
            Label1.Size = new Size(41, 17);
            rootLayout.Add(Label1, 8, 8);

            lblItem = new LegacyLabel();
            lblItem.Caption = "1";
            lblItem.Size = new Size(33, 17);
            rootLayout.Add(lblItem, 272, 40);

            Label2 = new LegacyLabel();
            Label2.Caption = "Item";
            Label2.Size = new Size(41, 17);
            rootLayout.Add(Label2, 8, 40);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(145, 33);
            rootLayout.Add(cmdCancel, 168, 112);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(145, 33);
            rootLayout.Add(cmdOk, 8, 112);

            scrlItem = new LegacyScrollBar();
            scrlItem.MinValue = 1;
            scrlItem.MaxValue = 500;
            scrlItem.Value = 1;
            scrlItem.Orientation = Orientation.Horizontal;
            scrlItem.SmallChange = 1;
            scrlItem.LargeChange = 1;
            scrlItem.Size = new Size(217, 17);
            rootLayout.Add(scrlItem, 56, 40);

            chkTake = new LegacyCheckBox();
            chkTake.Caption = "Take key away upon use";
            chkTake.Checked = true;
            chkTake.Size = new Size(297, 25);
            rootLayout.Add(chkTake, 8, 72);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}