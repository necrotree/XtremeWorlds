using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmTrade : EditForm
    {

        public readonly LegacyLabel picFixItems;
        public readonly LegacyLabel picCancel;
        public readonly LegacyLabel picDeal;
        public readonly LegacyListBox lstTrade;
        public readonly LegacyPictureBox mnuFixItems;
        public readonly LegacyLabel picFix;
        public readonly LegacyLabel picFixCancel;
        public readonly LegacyComboBox cmbItem;

        public frmTrade()
        {
            Title = "Trade";
            ClientSize = new Size(260, 370);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            picFixItems = new LegacyLabel();
            picFixItems.Caption = "";
            picFixItems.Size = new Size(25, 17);
            rootLayout.Add(picFixItems, 120, 288);

            picCancel = new LegacyLabel();
            picCancel.Caption = "";
            picCancel.Size = new Size(73, 17);
            rootLayout.Add(picCancel, 96, 336);

            picDeal = new LegacyLabel();
            picDeal.Caption = "";
            picDeal.Size = new Size(41, 17);
            rootLayout.Add(picDeal, 112, 312);

            lstTrade = new LegacyListBox();
            lstTrade.Size = new Size(217, 128);
            rootLayout.Add(lstTrade, 22, 144);

            mnuFixItems = new LegacyPictureBox();
            mnuFixItems.Visible = false;
            mnuFixItems.Size = new Size(260, 370);
            rootLayout.Add(mnuFixItems, 0, 0);
            var layout_mnuFixItems = new PixelLayout();
            mnuFixItems.Content = layout_mnuFixItems;
            picFix = new LegacyLabel();
            picFix.Caption = "";
            picFix.Size = new Size(25, 17);
            layout_mnuFixItems.Add(picFix, 120, 312);

            picFixCancel = new LegacyLabel();
            picFixCancel.Caption = "";
            picFixCancel.Size = new Size(57, 17);
            layout_mnuFixItems.Add(picFixCancel, 104, 336);

            cmbItem = new LegacyComboBox();
            cmbItem.Size = new Size(209, 22);
            layout_mnuFixItems.Add(cmbItem, 24, 184);


            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}