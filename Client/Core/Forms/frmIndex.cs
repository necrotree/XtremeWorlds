using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmIndex : EditForm
    {

        public readonly LegacyListBox lstIndex;
        public readonly LegacyButton cmdOk;
        public readonly LegacyButton cmdCancel;

        public frmIndex()
        {
            Title = "Index";
            ClientSize = new Size(353, 298);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lstIndex = new LegacyListBox();
            lstIndex.Size = new Size(337, 238);
            rootLayout.Add(lstIndex, 8, 8);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(161, 33);
            rootLayout.Add(cmdOk, 8, 256);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(161, 33);
            rootLayout.Add(cmdCancel, 184, 256);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}