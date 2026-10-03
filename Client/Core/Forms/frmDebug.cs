using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmDebug : EditForm
    {

        public readonly LegacyFrame SSTab1;
        public readonly LegacyFrame Frame1;
        public readonly LegacyTextArea txtDebug;

        public frmDebug()
        {
            Title = "Debug";
            ClientSize = new Size(473, 481);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            SSTab1 = new LegacyFrame();
            SSTab1.Caption = "Debug";
            SSTab1.Size = new Size(457, 465);
            rootLayout.Add(SSTab1, 8, 8);
            var layout_SSTab1 = new PixelLayout();
            SSTab1.Content = layout_SSTab1;
            Frame1 = new LegacyFrame();
            Frame1.Caption = "Debug";
            Frame1.Size = new Size(441, 441);
            layout_SSTab1.Add(Frame1, 8, 16);
            var layout_Frame1 = new PixelLayout();
            Frame1.Content = layout_Frame1;
            txtDebug = new LegacyTextArea();
            txtDebug.Text = "";
            txtDebug.Size = new Size(425, 417);
            layout_Frame1.Add(txtDebug, 8, 16);



            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}