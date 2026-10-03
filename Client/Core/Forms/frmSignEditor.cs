using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmSignEditor : Form
    {

        public readonly LegacyLabel Label1;
        public readonly LegacyLabel Label2;
        public readonly LegacyLabel Label3;
        public readonly LegacyLabel Label4;
        public readonly LegacyLabel Label5;
        public readonly LegacyTextBox txtSignName;
        public readonly LegacyTextBox txtSignLine3;
        public readonly LegacyTextBox txtSignLine2;
        public readonly LegacyTextBox txtSignLine1;
        public readonly LegacyRadioButton optWooden;
        public readonly LegacyRadioButton optScroll;
        public readonly LegacyButton cmdOK;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyButton cmdPrev;
        public readonly LegacyPictureBox picSign;
        public readonly LegacyLabel lblNameBtm;
        public readonly LegacyLabel lblNameTop;
        public readonly LegacyLabel lblLine3Btm;
        public readonly LegacyLabel lblLine2Btm;
        public readonly LegacyLabel lblLine1Btm;
        public readonly Drawable Line1;
        public readonly LegacyLabel lblLine3Top;
        public readonly LegacyLabel lblLine2Top;
        public readonly LegacyLabel lblLine1Top;
        public readonly LegacyLabel lblexit;

        public frmSignEditor()
        {
            Title = "Sign Editor";
            ClientSize = new Size(201, 505);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            Label1 = new LegacyLabel();
            Label1.Caption = "Sign Name";
            Label1.Size = new Size(137, 17);
            rootLayout.Add(Label1, 32, 144);

            Label2 = new LegacyLabel();
            Label2.Caption = "Background";
            Label2.Size = new Size(137, 17);
            rootLayout.Add(Label2, 32, 200);

            Label3 = new LegacyLabel();
            Label3.Caption = "Line 3";
            Label3.Size = new Size(137, 17);
            rootLayout.Add(Label3, 32, 384);

            Label4 = new LegacyLabel();
            Label4.Caption = "Line 2";
            Label4.Size = new Size(137, 17);
            rootLayout.Add(Label4, 32, 328);

            Label5 = new LegacyLabel();
            Label5.Caption = "Line 1";
            Label5.Size = new Size(137, 17);
            rootLayout.Add(Label5, 32, 272);

            txtSignName = new LegacyTextBox();
            txtSignName.Text = "Name";
            txtSignName.Size = new Size(137, 25);
            rootLayout.Add(txtSignName, 32, 168);

            txtSignLine3 = new LegacyTextBox();
            txtSignLine3.Text = "";
            txtSignLine3.Size = new Size(137, 25);
            rootLayout.Add(txtSignLine3, 32, 408);

            txtSignLine2 = new LegacyTextBox();
            txtSignLine2.Text = "";
            txtSignLine2.Size = new Size(137, 25);
            rootLayout.Add(txtSignLine2, 32, 352);

            txtSignLine1 = new LegacyTextBox();
            txtSignLine1.Text = "";
            txtSignLine1.Size = new Size(137, 25);
            rootLayout.Add(txtSignLine1, 32, 296);

            optWooden = new LegacyRadioButton();
            optWooden.Caption = "Wooden Sign";
            optWooden.Value = true;
            optWooden.Size = new Size(137, 17);
            rootLayout.Add(optWooden, 32, 224);

            optScroll = new LegacyRadioButton(optWooden);
            optScroll.Caption = "Parchment / Scroll";
            optScroll.Size = new Size(137, 17);
            rootLayout.Add(optScroll, 32, 248);

            cmdOK = new LegacyButton();
            cmdOK.Caption = "OK";
            cmdOK.Size = new Size(65, 25);
            rootLayout.Add(cmdOK, 32, 472);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(65, 25);
            rootLayout.Add(cmdCancel, 104, 472);

            cmdPrev = new LegacyButton();
            cmdPrev.Caption = "Preview Sign";
            cmdPrev.Size = new Size(137, 25);
            rootLayout.Add(cmdPrev, 32, 440);

            picSign = new LegacyPictureBox();
            picSign.Size = new Size(185, 121);
            rootLayout.Add(picSign, 8, 8);
            var layout_picSign = new PixelLayout();
            picSign.Content = layout_picSign;
            lblNameBtm = new LegacyLabel();
            lblNameBtm.Caption = "Name";
            lblNameBtm.Size = new Size(185, 25);
            layout_picSign.Add(lblNameBtm, 0, 11);

            lblNameTop = new LegacyLabel();
            lblNameTop.Caption = "Name";
            lblNameTop.Size = new Size(185, 25);
            layout_picSign.Add(lblNameTop, 3, 8);

            lblLine3Btm = new LegacyLabel();
            lblLine3Btm.Caption = "Line3";
            lblLine3Btm.Size = new Size(185, 25);
            layout_picSign.Add(lblLine3Btm, 0, 70);

            lblLine2Btm = new LegacyLabel();
            lblLine2Btm.Caption = "Line2";
            lblLine2Btm.Size = new Size(185, 25);
            layout_picSign.Add(lblLine2Btm, 0, 54);

            lblLine1Btm = new LegacyLabel();
            lblLine1Btm.Caption = "Line1";
            lblLine1Btm.Size = new Size(185, 25);
            layout_picSign.Add(lblLine1Btm, 0, 38);

            Line1 = new Drawable();
            Line1.Size = new Size(10, 10);
            layout_picSign.Add(Line1, 0, 0);

            lblLine3Top = new LegacyLabel();
            lblLine3Top.Caption = "Line3";
            lblLine3Top.Size = new Size(185, 25);
            layout_picSign.Add(lblLine3Top, 3, 67);

            lblLine2Top = new LegacyLabel();
            lblLine2Top.Caption = "Line2";
            lblLine2Top.Size = new Size(185, 25);
            layout_picSign.Add(lblLine2Top, 3, 51);

            lblLine1Top = new LegacyLabel();
            lblLine1Top.Caption = "Line1";
            lblLine1Top.Size = new Size(185, 25);
            layout_picSign.Add(lblLine1Top, 3, 35);

            lblexit = new LegacyLabel();
            lblexit.Caption = "Exit";
            lblexit.Size = new Size(57, 17);
            layout_picSign.Add(lblexit, 64, 104);


            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}