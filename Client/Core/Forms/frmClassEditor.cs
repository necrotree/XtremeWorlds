using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmClassEditor : EditForm
    {

        public readonly LegacyButton cmdCancel;
        public readonly LegacyButton cmdOk;
        public readonly LegacyLabel lblMAGI;
        public readonly LegacyLabel lblMAGITitle;
        public readonly LegacyScrollBar scrlMAGI;
        public readonly LegacyLabel lblSPD;
        public readonly LegacyLabel lblSPDTitle;
        public readonly LegacyScrollBar scrlSPD;
        public readonly LegacyLabel lblDEF;
        public readonly LegacyLabel lblDEFTitle;
        public readonly LegacyScrollBar scrlDEF;
        public readonly LegacyLabel lblSTR;
        public readonly LegacyLabel lblSTRTitle;
        public readonly LegacyScrollBar scrlSTR;
        public readonly LegacyLabel lblSprite;
        public readonly LegacyLabel lblSpriteTitle;
        public readonly LegacyScrollBar scrlMSprite;
        public readonly LegacyLabel lblName;
        public readonly LegacyTextBox txtName;
        public readonly LegacyLabel lblMapTitle;
        public readonly LegacyLabel lblMap;
        public readonly LegacyLabel lblXTitle;
        public readonly LegacyScrollBar scrlX;
        public readonly LegacyLabel lblX;
        public readonly LegacyLabel lblYTitle;
        public readonly LegacyScrollBar scrlY;
        public readonly LegacyLabel lblY;
        public readonly LegacyScrollBar scrlMap;
        public readonly LegacyLabel lblStatus;
        public readonly LegacyLabel lblSprite2Title;
        public readonly LegacyScrollBar scrlFSprite;
        public readonly LegacyLabel lblSprite2;
        public readonly ImageView imgMSprite;
        public readonly ImageView imgFSprite;

        public frmClassEditor()
        {
            Title = "Class Editor";
            ClientSize = new Size(355, 376);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(161, 41);
            rootLayout.Add(cmdCancel, 170, 331);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(161, 41);
            rootLayout.Add(cmdOk, 9, 330);

            lblMAGI = new LegacyLabel();
            lblMAGI.Caption = "0";
            lblMAGI.Size = new Size(33, 25);
            rootLayout.Add(lblMAGI, 262, 215);

            lblMAGITitle = new LegacyLabel();
            lblMAGITitle.Caption = "MAGI";
            lblMAGITitle.Size = new Size(57, 25);
            rootLayout.Add(lblMAGITitle, 14, 215);

            scrlMAGI = new LegacyScrollBar();
            scrlMAGI.MinValue = 0;
            scrlMAGI.MaxValue = 255;
            scrlMAGI.Value = 0;
            scrlMAGI.Orientation = Orientation.Horizontal;
            scrlMAGI.SmallChange = 1;
            scrlMAGI.LargeChange = 1;
            scrlMAGI.Size = new Size(193, 25);
            rootLayout.Add(scrlMAGI, 70, 215);

            lblSPD = new LegacyLabel();
            lblSPD.Caption = "0";
            lblSPD.Size = new Size(33, 25);
            rootLayout.Add(lblSPD, 260, 183);

            lblSPDTitle = new LegacyLabel();
            lblSPDTitle.Caption = "SPD";
            lblSPDTitle.Size = new Size(57, 25);
            rootLayout.Add(lblSPDTitle, 14, 183);

            scrlSPD = new LegacyScrollBar();
            scrlSPD.MinValue = 0;
            scrlSPD.MaxValue = 255;
            scrlSPD.Value = 0;
            scrlSPD.Orientation = Orientation.Horizontal;
            scrlSPD.SmallChange = 1;
            scrlSPD.LargeChange = 1;
            scrlSPD.Size = new Size(193, 25);
            rootLayout.Add(scrlSPD, 70, 183);

            lblDEF = new LegacyLabel();
            lblDEF.Caption = "0";
            lblDEF.Size = new Size(33, 25);
            rootLayout.Add(lblDEF, 262, 151);

            lblDEFTitle = new LegacyLabel();
            lblDEFTitle.Caption = "DEF";
            lblDEFTitle.Size = new Size(57, 25);
            rootLayout.Add(lblDEFTitle, 14, 151);

            scrlDEF = new LegacyScrollBar();
            scrlDEF.MinValue = 0;
            scrlDEF.MaxValue = 255;
            scrlDEF.Value = 0;
            scrlDEF.Orientation = Orientation.Horizontal;
            scrlDEF.SmallChange = 1;
            scrlDEF.LargeChange = 1;
            scrlDEF.Size = new Size(193, 25);
            rootLayout.Add(scrlDEF, 70, 151);

            lblSTR = new LegacyLabel();
            lblSTR.Caption = "0";
            lblSTR.Size = new Size(33, 25);
            rootLayout.Add(lblSTR, 262, 119);

            lblSTRTitle = new LegacyLabel();
            lblSTRTitle.Caption = "STR";
            lblSTRTitle.Size = new Size(57, 25);
            rootLayout.Add(lblSTRTitle, 14, 119);

            scrlSTR = new LegacyScrollBar();
            scrlSTR.MinValue = 0;
            scrlSTR.MaxValue = 255;
            scrlSTR.Value = 0;
            scrlSTR.Orientation = Orientation.Horizontal;
            scrlSTR.SmallChange = 1;
            scrlSTR.LargeChange = 1;
            scrlSTR.Size = new Size(193, 25);
            rootLayout.Add(scrlSTR, 70, 118);

            lblSprite = new LegacyLabel();
            lblSprite.Caption = "0";
            lblSprite.Size = new Size(33, 25);
            rootLayout.Add(lblSprite, 264, 48);

            lblSpriteTitle = new LegacyLabel();
            lblSpriteTitle.Caption = "M Sprite";
            lblSpriteTitle.Size = new Size(78, 25);
            rootLayout.Add(lblSpriteTitle, 8, 48);

            scrlMSprite = new LegacyScrollBar();
            scrlMSprite.MinValue = 0;
            scrlMSprite.MaxValue = 500;
            scrlMSprite.Value = 0;
            scrlMSprite.Orientation = Orientation.Horizontal;
            scrlMSprite.SmallChange = 1;
            scrlMSprite.LargeChange = 1;
            scrlMSprite.Size = new Size(193, 25);
            rootLayout.Add(scrlMSprite, 72, 48);

            lblName = new LegacyLabel();
            lblName.Caption = "Name";
            lblName.Size = new Size(65, 25);
            rootLayout.Add(lblName, 8, 8);

            txtName = new LegacyTextBox();
            txtName.Text = "";
            txtName.Size = new Size(249, 26);
            rootLayout.Add(txtName, 80, 8);

            lblMapTitle = new LegacyLabel();
            lblMapTitle.Caption = "Map";
            lblMapTitle.Size = new Size(57, 25);
            rootLayout.Add(lblMapTitle, 13, 240);

            lblMap = new LegacyLabel();
            lblMap.Caption = "0";
            lblMap.Size = new Size(33, 25);
            rootLayout.Add(lblMap, 262, 240);

            lblXTitle = new LegacyLabel();
            lblXTitle.Caption = "X";
            lblXTitle.Size = new Size(57, 25);
            rootLayout.Add(lblXTitle, 11, 267);

            scrlX = new LegacyScrollBar();
            scrlX.MinValue = 0;
            scrlX.MaxValue = 255;
            scrlX.Value = 0;
            scrlX.Orientation = Orientation.Horizontal;
            scrlX.SmallChange = 1;
            scrlX.LargeChange = 1;
            scrlX.Size = new Size(193, 25);
            rootLayout.Add(scrlX, 69, 270);

            lblX = new LegacyLabel();
            lblX.Caption = "0";
            lblX.Size = new Size(33, 25);
            rootLayout.Add(lblX, 261, 271);

            lblYTitle = new LegacyLabel();
            lblYTitle.Caption = "Y";
            lblYTitle.Size = new Size(57, 25);
            rootLayout.Add(lblYTitle, 11, 297);

            scrlY = new LegacyScrollBar();
            scrlY.MinValue = 0;
            scrlY.MaxValue = 255;
            scrlY.Value = 0;
            scrlY.Orientation = Orientation.Horizontal;
            scrlY.SmallChange = 1;
            scrlY.LargeChange = 1;
            scrlY.Size = new Size(193, 25);
            rootLayout.Add(scrlY, 67, 300);

            lblY = new LegacyLabel();
            lblY.Caption = "0";
            lblY.Size = new Size(33, 25);
            rootLayout.Add(lblY, 261, 301);

            scrlMap = new LegacyScrollBar();
            scrlMap.MinValue = 0;
            scrlMap.MaxValue = 9999;
            scrlMap.Value = 0;
            scrlMap.Orientation = Orientation.Horizontal;
            scrlMap.SmallChange = 1;
            scrlMap.LargeChange = 1;
            scrlMap.Size = new Size(193, 25);
            rootLayout.Add(scrlMap, 71, 240);

            lblStatus = new LegacyLabel();
            lblStatus.Caption = "";
            lblStatus.Size = new Size(321, 16);
            rootLayout.Add(lblStatus, 0, 0);

            lblSprite2Title = new LegacyLabel();
            lblSprite2Title.Caption = "F Sprite";
            lblSprite2Title.Size = new Size(78, 25);
            rootLayout.Add(lblSprite2Title, 8, 83);

            scrlFSprite = new LegacyScrollBar();
            scrlFSprite.MinValue = 0;
            scrlFSprite.MaxValue = 500;
            scrlFSprite.Value = 0;
            scrlFSprite.Orientation = Orientation.Horizontal;
            scrlFSprite.SmallChange = 1;
            scrlFSprite.LargeChange = 1;
            scrlFSprite.Size = new Size(193, 25);
            rootLayout.Add(scrlFSprite, 72, 83);

            lblSprite2 = new LegacyLabel();
            lblSprite2.Caption = "0";
            lblSprite2.Size = new Size(33, 25);
            rootLayout.Add(lblSprite2, 264, 83);

            imgMSprite = new ImageView();
            imgMSprite.Size = new Size(48, 64);
            rootLayout.Add(imgMSprite, 301, 45);

            imgFSprite = new ImageView();
            imgFSprite.Size = new Size(48, 64);
            rootLayout.Add(imgFSprite, 302, 115);

            cmdOk.Click += (_, _) => { if (ApplyChanges()) Close(); };
            cmdCancel.Click += (_, _) => CancelChanges();
            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}