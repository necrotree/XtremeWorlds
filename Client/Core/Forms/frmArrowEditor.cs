using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmArrowEditor : Form
    {

        public readonly LegacyLabel lblName;
        public readonly LegacyTextBox txtName;
        public readonly LegacyPictureBox picIcon;
        public readonly LegacyLabel lblArrow;
        public readonly LegacyScrollBar scrlSprite;
        public readonly LegacyLabel lblSprite;
        public readonly LegacyLabel lblRangeTitle;
        public readonly LegacyScrollBar scrlRange;
        public readonly LegacyLabel lblRange;
        public readonly LegacyPictureBox picPreview;
        public readonly LegacyLabel lblStatus;
        public readonly LegacyButton cmdOk;
        public readonly LegacyButton cmdCancel;

        public frmArrowEditor()
        {
            Title = "Arrow Editor";
            ClientSize = new Size(351, 238);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lblName = new LegacyLabel();
            lblName.Caption = "Name";
            lblName.Size = new Size(49, 25);
            rootLayout.Add(lblName, 8, 8);

            txtName = new LegacyTextBox();
            txtName.Text = "";
            txtName.Size = new Size(265, 26);
            rootLayout.Add(txtName, 64, 8);

            picIcon = new LegacyPictureBox();
            picIcon.Size = new Size(32, 32);
            rootLayout.Add(picIcon, 296, 40);

            lblArrow = new LegacyLabel();
            lblArrow.Caption = "Arrow";
            lblArrow.Size = new Size(49, 25);
            rootLayout.Add(lblArrow, 8, 40);

            scrlSprite = new LegacyScrollBar();
            scrlSprite.MinValue = 0;
            scrlSprite.MaxValue = 153;
            scrlSprite.Value = 0;
            scrlSprite.Orientation = Orientation.Horizontal;
            scrlSprite.SmallChange = 1;
            scrlSprite.LargeChange = 1;
            scrlSprite.Size = new Size(193, 25);
            rootLayout.Add(scrlSprite, 64, 40);

            lblSprite = new LegacyLabel();
            lblSprite.Caption = "1";
            lblSprite.Size = new Size(33, 25);
            rootLayout.Add(lblSprite, 256, 40);

            lblRangeTitle = new LegacyLabel();
            lblRangeTitle.Caption = "Range";
            lblRangeTitle.Size = new Size(49, 25);
            rootLayout.Add(lblRangeTitle, 8, 80);

            scrlRange = new LegacyScrollBar();
            scrlRange.MinValue = 0;
            scrlRange.MaxValue = 32;
            scrlRange.Value = 0;
            scrlRange.Orientation = Orientation.Horizontal;
            scrlRange.SmallChange = 1;
            scrlRange.LargeChange = 1;
            scrlRange.Size = new Size(193, 25);
            rootLayout.Add(scrlRange, 64, 80);

            lblRange = new LegacyLabel();
            lblRange.Caption = "0";
            lblRange.Size = new Size(33, 25);
            rootLayout.Add(lblRange, 257, 80);

            picPreview = new LegacyPictureBox();
            picPreview.Size = new Size(321, 72);
            rootLayout.Add(picPreview, 12, 108);

            lblStatus = new LegacyLabel();
            lblStatus.Caption = "";
            lblStatus.Size = new Size(321, 16);
            rootLayout.Add(lblStatus, 8, 216);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "OK";
            cmdOk.Size = new Size(153, 33);
            rootLayout.Add(cmdOk, 10, 188);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(153, 33);
            rootLayout.Add(cmdCancel, 178, 189);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}