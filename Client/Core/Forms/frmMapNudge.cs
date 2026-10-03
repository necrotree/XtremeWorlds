using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmMapNudge : EditForm
    {

        public readonly LegacyFrame SSTab1;
        public readonly LegacyFrame Frame1;
        public readonly LegacyLabel Label1;
        public readonly LegacyLabel lblDir;
        public readonly LegacyScrollBar scrlDir;
        public readonly LegacyButton Command1;
        public readonly LegacyButton Command2;

        public frmMapNudge()
        {
            Title = "Nudge";
            ClientSize = new Size(241, 137);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            SSTab1 = new LegacyFrame();
            SSTab1.Caption = "Nudge";
            SSTab1.Size = new Size(225, 121);
            rootLayout.Add(SSTab1, 8, 8);
            var layout_SSTab1 = new PixelLayout();
            SSTab1.Content = layout_SSTab1;
            Frame1 = new LegacyFrame();
            Frame1.Caption = "Nudge";
            Frame1.Size = new Size(209, 57);
            layout_SSTab1.Add(Frame1, 8, 24);
            var layout_Frame1 = new PixelLayout();
            Frame1.Content = layout_Frame1;
            Label1 = new LegacyLabel();
            Label1.Caption = "Direction:";
            Label1.Size = new Size(185, 17);
            layout_Frame1.Add(Label1, 8, 19);

            lblDir = new LegacyLabel();
            lblDir.Caption = "Up";
            lblDir.Size = new Size(89, 16);
            layout_Frame1.Add(lblDir, 112, 35);

            scrlDir = new LegacyScrollBar();
            scrlDir.MinValue = 0;
            scrlDir.MaxValue = 3;
            scrlDir.Value = 0;
            scrlDir.Orientation = Orientation.Horizontal;
            scrlDir.SmallChange = 1;
            scrlDir.LargeChange = 1;
            scrlDir.Size = new Size(145, 17);
            layout_Frame1.Add(scrlDir, 56, 16);


            Command1 = new LegacyButton();
            Command1.Caption = "Ok";
            Command1.Size = new Size(105, 25);
            layout_SSTab1.Add(Command1, 8, 88);

            Command2 = new LegacyButton();
            Command2.Caption = "Cancel";
            Command2.Size = new Size(105, 25);
            layout_SSTab1.Add(Command2, 112, 88);


            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}