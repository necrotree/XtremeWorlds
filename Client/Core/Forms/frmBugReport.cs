using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmBugReport : Form
    {

        public readonly LegacyFrame SSTab1;
        public readonly LegacyFrame Frame1;
        public readonly LegacyPictureBox Picture1;
        public readonly LegacyLabel Label4;
        public readonly LegacyLabel Label3;
        public readonly LegacyLabel Label1;
        public readonly LegacyPictureBox hosttxtBugReport;
        public readonly LegacyButton cmdSend;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyPictureBox picType;
        public readonly LegacyLabel Label5;
        public readonly LegacyRadioButton optOther;
        public readonly LegacyRadioButton optProgramming;
        public readonly LegacyRadioButton optMapping;
        public readonly LegacyPictureBox picOccurence;
        public readonly LegacyLabel Label2;
        public readonly LegacyRadioButton optOnce;
        public readonly LegacyRadioButton optSometimes;
        public readonly LegacyRadioButton optOften;

        public frmBugReport()
        {
            Title = "Bug Report";
            ClientSize = new Size(337, 352);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            SSTab1 = new LegacyFrame();
            SSTab1.Caption = "Bug Report";
            SSTab1.Size = new Size(321, 337);
            rootLayout.Add(SSTab1, 8, 8);
            var layout_SSTab1 = new PixelLayout();
            SSTab1.Content = layout_SSTab1;
            Frame1 = new LegacyFrame();
            Frame1.Caption = "Bug Report";
            Frame1.Size = new Size(305, 313);
            layout_SSTab1.Add(Frame1, 8, 16);
            var layout_Frame1 = new PixelLayout();
            Frame1.Content = layout_Frame1;
            Picture1 = new LegacyPictureBox();
            Picture1.Size = new Size(289, 289);
            layout_Frame1.Add(Picture1, 8, 16);
            var layout_Picture1 = new PixelLayout();
            Picture1.Content = layout_Picture1;
            Label4 = new LegacyLabel();
            Label4.Caption = "Can you repeat this bug?";
            Label4.Size = new Size(297, 17);
            layout_Picture1.Add(Label4, 0, 176);

            Label3 = new LegacyLabel();
            Label3.Caption = "Describe the bug here:";
            Label3.Size = new Size(265, 17);
            layout_Picture1.Add(Label3, 16, 128);

            Label1 = new LegacyLabel();
            Label1.Caption = "Hello players. This is the new bug report system. Please describe the type of bug, how severe the bug is to your gameplay, and if it can be avoided in any way. Please do not abuse!";
            Label1.Size = new Size(289, 41);
            layout_Picture1.Add(Label1, 0, 0);

            hosttxtBugReport = new LegacyPictureBox();
            hosttxtBugReport.Size = new Size(262, 95);
            layout_Picture1.Add(hosttxtBugReport, 16, 144);

            cmdSend = new LegacyButton();
            cmdSend.Caption = "Send Report";
            cmdSend.Size = new Size(129, 33);
            layout_Picture1.Add(cmdSend, 16, 248);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(129, 33);
            layout_Picture1.Add(cmdCancel, 152, 248);

            picType = new LegacyPictureBox();
            picType.Size = new Size(289, 65);
            layout_Picture1.Add(picType, 8, 40);
            var layout_picType = new PixelLayout();
            picType.Content = layout_picType;
            Label5 = new LegacyLabel();
            Label5.Caption = "Type of bug:";
            Label5.Size = new Size(292, 13);
            layout_picType.Add(Label5, -8, 0);

            optOther = new LegacyRadioButton();
            optOther.Caption = "Other";
            optOther.Size = new Size(57, 17);
            layout_picType.Add(optOther, 216, 16);

            optProgramming = new LegacyRadioButton(optOther);
            optProgramming.Caption = "Programming";
            optProgramming.Size = new Size(89, 17);
            layout_picType.Add(optProgramming, 104, 16);

            optMapping = new LegacyRadioButton(optOther);
            optMapping.Caption = "Mapping";
            optMapping.Value = true;
            optMapping.Size = new Size(65, 17);
            layout_picType.Add(optMapping, 16, 16);


            picOccurence = new LegacyPictureBox();
            picOccurence.Size = new Size(289, 49);
            layout_Picture1.Add(picOccurence, 8, 80);
            var layout_picOccurence = new PixelLayout();
            picOccurence.Content = layout_picOccurence;
            Label2 = new LegacyLabel();
            Label2.Caption = "How often does this bug occur?";
            Label2.Size = new Size(297, 17);
            layout_picOccurence.Add(Label2, 0, 0);

            optOnce = new LegacyRadioButton();
            optOnce.Caption = "Once";
            optOnce.Size = new Size(49, 17);
            layout_picOccurence.Add(optOnce, 216, 16);

            optSometimes = new LegacyRadioButton(optOnce);
            optSometimes.Caption = "Sometimes";
            optSometimes.Size = new Size(73, 17);
            layout_picOccurence.Add(optSometimes, 104, 16);

            optOften = new LegacyRadioButton(optOnce);
            optOften.Caption = "Often";
            optOften.Value = true;
            optOften.Size = new Size(49, 17);
            layout_picOccurence.Add(optOften, 16, 16);





            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}