using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmSignChoose : EditForm
    {

        public readonly LegacyLabel lblSignNum;
        public readonly LegacyLabel lblSignName;
        public readonly LegacyScrollBar scrlSignNum;
        public readonly LegacyButton cmdOk;
        public readonly LegacyButton cmdCancel;

        public frmSignChoose()
        {
            Title = "Sign Chooser";
            ClientSize = new Size(262, 76);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lblSignNum = new LegacyLabel();
            lblSignNum.Caption = "1";
            lblSignNum.Size = new Size(33, 17);
            rootLayout.Add(lblSignNum, 224, 24);

            lblSignName = new LegacyLabel();
            lblSignName.Caption = "Name";
            lblSignName.Size = new Size(209, 17);
            rootLayout.Add(lblSignName, 8, 8);

            scrlSignNum = new LegacyScrollBar();
            scrlSignNum.MinValue = 1;
            scrlSignNum.MaxValue = 500;
            scrlSignNum.Value = 1;
            scrlSignNum.Orientation = Orientation.Horizontal;
            scrlSignNum.SmallChange = 1;
            scrlSignNum.LargeChange = 5;
            scrlSignNum.Size = new Size(209, 17);
            rootLayout.Add(scrlSignNum, 8, 24);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "OK";
            cmdOk.Size = new Size(81, 25);
            rootLayout.Add(cmdOk, 24, 48);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(81, 25);
            rootLayout.Add(cmdCancel, 160, 48);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}