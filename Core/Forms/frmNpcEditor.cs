using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmNpcEditor : Form
    {

        public readonly LegacyLabel lblSprite;
        public readonly LegacyLabel Label5;
        public readonly LegacyLabel Label1;
        public readonly LegacyLabel Label2;
        public readonly LegacyLabel lblRange;
        public readonly LegacyLabel Label4;
        public readonly LegacyLabel lblSTR;
        public readonly LegacyLabel Label6;
        public readonly LegacyLabel lblDEF;
        public readonly LegacyLabel Label8;
        public readonly LegacyLabel lblSPEED;
        public readonly LegacyLabel Label10;
        public readonly LegacyLabel lblMAGI;
        public readonly LegacyLabel Label12;
        public readonly LegacyLabel Label3;
        public readonly LegacyLabel lblNum;
        public readonly LegacyLabel Label9;
        public readonly LegacyLabel Label11;
        public readonly LegacyLabel lblItemName;
        public readonly LegacyLabel Label7;
        public readonly LegacyLabel lblValue;
        public readonly LegacyLabel Label14;
        public readonly LegacyLabel Label16;
        public readonly LegacyLabel lbl17;
        public readonly LegacyLabel Label15;
        public readonly LegacyLabel Label13;
        public readonly LegacyScrollBar scrlSprite;
        public readonly LegacyTextBox txtName;
        public readonly LegacyComboBox cmbBehavior;
        public readonly LegacyScrollBar scrlRange;
        public readonly LegacyScrollBar scrlSTR;
        public readonly LegacyScrollBar scrlDEF;
        public readonly LegacyScrollBar scrlSPEED;
        public readonly LegacyScrollBar scrlMAGI;
        public readonly LegacyTextBox txtChance;
        public readonly LegacyScrollBar scrlNum;
        public readonly LegacyScrollBar scrlValue;
        public readonly LegacyButton cmdOk;
        public readonly LegacyButton cmdCancel;
        public readonly UITimer tmrSprite;
        public readonly LegacyTextBox txtAttackSay;
        public readonly LegacyTextBox txtSpawnSecs;
        public readonly LegacyComboBox cmbShop;
        public readonly LegacyTextBox txtGiveEXP;
        public readonly LegacyTextBox txtMaxHP;
        public readonly ImageView imgSprite;

        public frmNpcEditor()
        {
            Title = "Npc Editor";
            ClientSize = new Size(355, 630);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lblSprite = new LegacyLabel();
            lblSprite.Caption = "0";
            lblSprite.Size = new Size(33, 25);
            rootLayout.Add(lblSprite, 264, 80);

            Label5 = new LegacyLabel();
            Label5.Caption = "Sprite";
            Label5.Size = new Size(57, 25);
            rootLayout.Add(Label5, 16, 80);

            Label1 = new LegacyLabel();
            Label1.Caption = "Name";
            Label1.Size = new Size(49, 25);
            rootLayout.Add(Label1, 8, 8);

            Label2 = new LegacyLabel();
            Label2.Caption = "Behavior";
            Label2.Size = new Size(73, 25);
            rootLayout.Add(Label2, 16, 280);

            lblRange = new LegacyLabel();
            lblRange.Caption = "0";
            lblRange.Size = new Size(33, 25);
            rootLayout.Add(lblRange, 264, 112);

            Label4 = new LegacyLabel();
            Label4.Caption = "Range";
            Label4.Size = new Size(57, 25);
            rootLayout.Add(Label4, 16, 112);

            lblSTR = new LegacyLabel();
            lblSTR.Caption = "0";
            lblSTR.Size = new Size(33, 25);
            rootLayout.Add(lblSTR, 264, 144);

            Label6 = new LegacyLabel();
            Label6.Caption = "STR";
            Label6.Size = new Size(57, 25);
            rootLayout.Add(Label6, 16, 144);

            lblDEF = new LegacyLabel();
            lblDEF.Caption = "0";
            lblDEF.Size = new Size(33, 25);
            rootLayout.Add(lblDEF, 264, 176);

            Label8 = new LegacyLabel();
            Label8.Caption = "DEF";
            Label8.Size = new Size(57, 25);
            rootLayout.Add(Label8, 16, 176);

            lblSPEED = new LegacyLabel();
            lblSPEED.Caption = "0";
            lblSPEED.Size = new Size(33, 25);
            rootLayout.Add(lblSPEED, 264, 208);

            Label10 = new LegacyLabel();
            Label10.Caption = "SPD";
            Label10.Size = new Size(57, 25);
            rootLayout.Add(Label10, 16, 208);

            lblMAGI = new LegacyLabel();
            lblMAGI.Caption = "0";
            lblMAGI.Size = new Size(33, 25);
            rootLayout.Add(lblMAGI, 264, 240);

            Label12 = new LegacyLabel();
            Label12.Caption = "MAGI";
            Label12.Size = new Size(57, 25);
            rootLayout.Add(Label12, 16, 240);

            Label3 = new LegacyLabel();
            Label3.Caption = "Drop Item Chance 1 out of";
            Label3.Size = new Size(193, 25);
            rootLayout.Add(Label3, 16, 320);

            lblNum = new LegacyLabel();
            lblNum.Caption = "0";
            lblNum.Size = new Size(33, 25);
            rootLayout.Add(lblNum, 304, 432);

            Label9 = new LegacyLabel();
            Label9.Caption = "Num";
            Label9.Size = new Size(57, 25);
            rootLayout.Add(Label9, 16, 432);

            Label11 = new LegacyLabel();
            Label11.Caption = "Item";
            Label11.Size = new Size(41, 25);
            rootLayout.Add(Label11, 16, 400);

            lblItemName = new LegacyLabel();
            lblItemName.Caption = "";
            lblItemName.Size = new Size(273, 25);
            rootLayout.Add(lblItemName, 64, 400);

            Label7 = new LegacyLabel();
            Label7.Caption = "Value";
            Label7.Size = new Size(49, 25);
            rootLayout.Add(Label7, 16, 464);

            lblValue = new LegacyLabel();
            lblValue.Caption = "0";
            lblValue.Size = new Size(33, 25);
            rootLayout.Add(lblValue, 304, 464);

            Label14 = new LegacyLabel();
            Label14.Caption = "Say";
            Label14.Size = new Size(49, 25);
            rootLayout.Add(Label14, 8, 40);

            Label16 = new LegacyLabel();
            Label16.Caption = "Spawn Rate (in seconds)";
            Label16.Size = new Size(193, 25);
            rootLayout.Add(Label16, 16, 352);

            lbl17 = new LegacyLabel();
            lbl17.Caption = "Shopkeeper's Shop";
            lbl17.Visible = false;
            lbl17.Size = new Size(153, 25);
            rootLayout.Add(lbl17, 8, 544);

            Label15 = new LegacyLabel();
            Label15.Caption = "Exp Given";
            Label15.Size = new Size(81, 25);
            rootLayout.Add(Label15, 168, 504);

            Label13 = new LegacyLabel();
            Label13.Caption = "Start HP";
            Label13.Size = new Size(65, 25);
            rootLayout.Add(Label13, 8, 504);

            scrlSprite = new LegacyScrollBar();
            scrlSprite.MinValue = 0;
            scrlSprite.MaxValue = 500;
            scrlSprite.Value = 0;
            scrlSprite.Orientation = Orientation.Horizontal;
            scrlSprite.SmallChange = 1;
            scrlSprite.LargeChange = 1;
            scrlSprite.Size = new Size(193, 25);
            rootLayout.Add(scrlSprite, 74, 79);

            txtName = new LegacyTextBox();
            txtName.Text = "";
            txtName.Size = new Size(283, 26);
            rootLayout.Add(txtName, 64, 8);

            cmbBehavior = new LegacyComboBox();
            cmbBehavior.Items.Add("Attack on sight");
            cmbBehavior.Items.Add("Attack when attacked");
            cmbBehavior.Items.Add("Friendly");
            cmbBehavior.Items.Add("Shop keeper");
            cmbBehavior.Items.Add("Guard");
            cmbBehavior.Size = new Size(241, 26);
            rootLayout.Add(cmbBehavior, 96, 280);

            scrlRange = new LegacyScrollBar();
            scrlRange.MinValue = 0;
            scrlRange.MaxValue = 255;
            scrlRange.Value = 1;
            scrlRange.Orientation = Orientation.Horizontal;
            scrlRange.SmallChange = 1;
            scrlRange.LargeChange = 1;
            scrlRange.Size = new Size(193, 25);
            rootLayout.Add(scrlRange, 72, 112);

            scrlSTR = new LegacyScrollBar();
            scrlSTR.MinValue = 0;
            scrlSTR.MaxValue = 255;
            scrlSTR.Value = 0;
            scrlSTR.Orientation = Orientation.Horizontal;
            scrlSTR.SmallChange = 1;
            scrlSTR.LargeChange = 1;
            scrlSTR.Size = new Size(193, 25);
            rootLayout.Add(scrlSTR, 72, 144);

            scrlDEF = new LegacyScrollBar();
            scrlDEF.MinValue = 0;
            scrlDEF.MaxValue = 255;
            scrlDEF.Value = 0;
            scrlDEF.Orientation = Orientation.Horizontal;
            scrlDEF.SmallChange = 1;
            scrlDEF.LargeChange = 1;
            scrlDEF.Size = new Size(193, 25);
            rootLayout.Add(scrlDEF, 72, 176);

            scrlSPEED = new LegacyScrollBar();
            scrlSPEED.MinValue = 0;
            scrlSPEED.MaxValue = 255;
            scrlSPEED.Value = 0;
            scrlSPEED.Orientation = Orientation.Horizontal;
            scrlSPEED.SmallChange = 1;
            scrlSPEED.LargeChange = 1;
            scrlSPEED.Size = new Size(193, 25);
            rootLayout.Add(scrlSPEED, 72, 208);

            scrlMAGI = new LegacyScrollBar();
            scrlMAGI.MinValue = 0;
            scrlMAGI.MaxValue = 255;
            scrlMAGI.Value = 0;
            scrlMAGI.Orientation = Orientation.Horizontal;
            scrlMAGI.SmallChange = 1;
            scrlMAGI.LargeChange = 1;
            scrlMAGI.Size = new Size(193, 25);
            rootLayout.Add(scrlMAGI, 72, 240);

            txtChance = new LegacyTextBox();
            txtChance.Text = "0";
            txtChance.Size = new Size(121, 26);
            rootLayout.Add(txtChance, 216, 320);

            scrlNum = new LegacyScrollBar();
            scrlNum.MinValue = 0;
            scrlNum.MaxValue = 500;
            scrlNum.Value = 1;
            scrlNum.Orientation = Orientation.Horizontal;
            scrlNum.SmallChange = 1;
            scrlNum.LargeChange = 1;
            scrlNum.Size = new Size(225, 25);
            rootLayout.Add(scrlNum, 72, 432);

            scrlValue = new LegacyScrollBar();
            scrlValue.MinValue = 0;
            scrlValue.MaxValue = 255;
            scrlValue.Value = 1;
            scrlValue.Orientation = Orientation.Horizontal;
            scrlValue.SmallChange = 1;
            scrlValue.LargeChange = 1;
            scrlValue.Size = new Size(225, 25);
            rootLayout.Add(scrlValue, 72, 464);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(161, 41);
            rootLayout.Add(cmdOk, 8, 584);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(161, 41);
            rootLayout.Add(cmdCancel, 176, 584);

            tmrSprite = new UITimer() { Interval = 0.05d };
            tmrSprite.Start();
            txtAttackSay = new LegacyTextBox();
            txtAttackSay.Text = "";
            txtAttackSay.Size = new Size(284, 26);
            rootLayout.Add(txtAttackSay, 64, 40);

            txtSpawnSecs = new LegacyTextBox();
            txtSpawnSecs.Text = "0";
            txtSpawnSecs.Size = new Size(121, 26);
            rootLayout.Add(txtSpawnSecs, 216, 352);

            cmbShop = new LegacyComboBox();
            cmbShop.Visible = false;
            cmbShop.Size = new Size(169, 26);
            rootLayout.Add(cmbShop, 168, 544);

            txtGiveEXP = new LegacyTextBox();
            txtGiveEXP.Text = "";
            txtGiveEXP.Size = new Size(73, 26);
            rootLayout.Add(txtGiveEXP, 256, 504);

            txtMaxHP = new LegacyTextBox();
            txtMaxHP.Text = "";
            txtMaxHP.Size = new Size(81, 26);
            rootLayout.Add(txtMaxHP, 80, 504);

            imgSprite = new ImageView();
            imgSprite.Size = new Size(48, 64);
            rootLayout.Add(imgSprite, 305, 78);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}