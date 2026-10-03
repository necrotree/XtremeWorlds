using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmMapItem : EditForm
    {

        public readonly LegacyLabel Label2;
        public readonly LegacyLabel Label3;
        public readonly LegacyLabel lblItem;
        public readonly LegacyLabel lblValue;
        public readonly LegacyLabel Label1;
        public readonly LegacyLabel lblName;
        public readonly LegacyScrollBar scrlItem;
        public readonly LegacyScrollBar scrlValue;
        public readonly LegacyButton cmdOk;
        public readonly LegacyButton cmdCancel;

        public frmMapItem()
        {
            Title = "Map Item";
            ClientSize = new Size(338, 139);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            Label2 = new LegacyLabel();
            Label2.Caption = "Item";
            Label2.Size = new Size(41, 17);
            rootLayout.Add(Label2, 8, 40);

            Label3 = new LegacyLabel();
            Label3.Caption = "Value";
            Label3.Size = new Size(41, 17);
            rootLayout.Add(Label3, 8, 64);

            lblItem = new LegacyLabel();
            lblItem.Caption = "1";
            lblItem.Size = new Size(57, 17);
            rootLayout.Add(lblItem, 272, 40);

            lblValue = new LegacyLabel();
            lblValue.Caption = "1";
            lblValue.Size = new Size(57, 17);
            rootLayout.Add(lblValue, 272, 64);

            Label1 = new LegacyLabel();
            Label1.Caption = "Item";
            Label1.Size = new Size(41, 17);
            rootLayout.Add(Label1, 8, 8);

            lblName = new LegacyLabel();
            lblName.Caption = "";
            lblName.Size = new Size(249, 25);
            rootLayout.Add(lblName, 56, 8);

            scrlItem = new LegacyScrollBar();
            scrlItem.MinValue = 1;
            scrlItem.MaxValue = 500;
            scrlItem.Value = 1;
            scrlItem.Orientation = Orientation.Horizontal;
            scrlItem.SmallChange = 1;
            scrlItem.LargeChange = 1;
            scrlItem.Size = new Size(217, 17);
            rootLayout.Add(scrlItem, 56, 40);

            scrlValue = new LegacyScrollBar();
            scrlValue.MinValue = 1;
            scrlValue.MaxValue = 100;
            scrlValue.Value = 1;
            scrlValue.Orientation = Orientation.Horizontal;
            scrlValue.SmallChange = 1;
            scrlValue.LargeChange = 1;
            scrlValue.Size = new Size(217, 17);
            rootLayout.Add(scrlValue, 56, 64);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(153, 33);
            rootLayout.Add(cmdOk, 8, 96);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(153, 33);
            rootLayout.Add(cmdCancel, 176, 96);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}