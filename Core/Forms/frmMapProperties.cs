using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmMapProperties : Form
    {

        public readonly LegacyLabel Label1;
        public readonly LegacyLabel Label2;
        public readonly LegacyLabel Label3;
        public readonly LegacyLabel Label4;
        public readonly LegacyLabel Label5;
        public readonly LegacyLabel Label6;
        public readonly LegacyLabel Label7;
        public readonly LegacyLabel Label8;
        public readonly LegacyLabel Label9;
        public readonly LegacyLabel Label10;
        public readonly LegacyLabel lblMusic;
        public readonly LegacyLabel Label11;
        public readonly LegacyLabel Label12;
        public readonly LegacyLabel lblInOutStat;
        public readonly LegacyTextBox txtName;
        public readonly LegacyTextBox txtUp;
        public readonly LegacyTextBox txtDown;
        public readonly LegacyTextBox txtRight;
        public readonly LegacyTextBox txtLeft;
        public readonly LegacyButton cmdOk;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyComboBox cmbMoral;
        public readonly LegacyComboBox cmbNpc;
        public readonly LegacyComboBox cmbNpc_1;
        public readonly LegacyComboBox cmbNpc_2;
        public readonly LegacyComboBox cmbNpc_3;
        public readonly LegacyComboBox cmbNpc_4;
        public readonly LegacyTextBox txtBootMap;
        public readonly LegacyTextBox txtBootX;
        public readonly LegacyTextBox txtBootY;
        public readonly LegacyScrollBar scrlMusic;
        public readonly LegacyComboBox cmbShop;
        public readonly LegacyComboBox cmbNpc_5;
        public readonly LegacyComboBox cmbNpc_6;
        public readonly LegacyComboBox cmbNpc_7;
        public readonly LegacyComboBox cmbNpc_8;
        public readonly LegacyComboBox cmbNpc_9;
        public readonly LegacyButton cmdTest;
        public readonly LegacyButton cmdStop;
        public readonly LegacyFrame frmType;
        public readonly LegacyRadioButton optOutside;
        public readonly LegacyRadioButton optInside;

        public frmMapProperties()
        {
            Title = "Map Properties";
            ClientSize = new Size(563, 420);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            Label1 = new LegacyLabel();
            Label1.Caption = "Name";
            Label1.Size = new Size(49, 25);
            rootLayout.Add(Label1, 8, 8);

            Label2 = new LegacyLabel();
            Label2.Caption = "Up";
            Label2.Size = new Size(49, 25);
            rootLayout.Add(Label2, 8, 48);

            Label3 = new LegacyLabel();
            Label3.Caption = "Down";
            Label3.Size = new Size(49, 25);
            rootLayout.Add(Label3, 8, 80);

            Label4 = new LegacyLabel();
            Label4.Caption = "Left";
            Label4.Size = new Size(49, 25);
            rootLayout.Add(Label4, 128, 48);

            Label5 = new LegacyLabel();
            Label5.Caption = "Right";
            Label5.Size = new Size(49, 25);
            rootLayout.Add(Label5, 128, 80);

            Label6 = new LegacyLabel();
            Label6.Caption = "Moral";
            Label6.Size = new Size(49, 25);
            rootLayout.Add(Label6, 8, 120);

            Label7 = new LegacyLabel();
            Label7.Caption = "Boot Map";
            Label7.Size = new Size(73, 25);
            rootLayout.Add(Label7, 8, 256);

            Label8 = new LegacyLabel();
            Label8.Caption = "Boot X";
            Label8.Size = new Size(73, 25);
            rootLayout.Add(Label8, 8, 288);

            Label9 = new LegacyLabel();
            Label9.Caption = "Boot Y";
            Label9.Size = new Size(73, 25);
            rootLayout.Add(Label9, 8, 320);

            Label10 = new LegacyLabel();
            Label10.Caption = "Music";
            Label10.Size = new Size(49, 25);
            rootLayout.Add(Label10, 8, 192);

            lblMusic = new LegacyLabel();
            lblMusic.Caption = "0";
            lblMusic.Size = new Size(33, 25);
            rootLayout.Add(lblMusic, 232, 192);

            Label11 = new LegacyLabel();
            Label11.Caption = "NPC's";
            Label11.Size = new Size(273, 25);
            rootLayout.Add(Label11, 280, 8);

            Label12 = new LegacyLabel();
            Label12.Caption = "Shop";
            Label12.Size = new Size(49, 25);
            rootLayout.Add(Label12, 8, 152);

            lblInOutStat = new LegacyLabel();
            lblInOutStat.Caption = "Inside maps are not affected by day and night, while outside maps are!";
            lblInOutStat.Size = new Size(265, 25);
            rootLayout.Add(lblInOutStat, 8, 352);

            txtName = new LegacyTextBox();
            txtName.Text = "";
            txtName.Size = new Size(201, 26);
            rootLayout.Add(txtName, 64, 8);

            txtUp = new LegacyTextBox();
            txtUp.Text = "0";
            txtUp.Size = new Size(49, 26);
            rootLayout.Add(txtUp, 64, 48);

            txtDown = new LegacyTextBox();
            txtDown.Text = "0";
            txtDown.Size = new Size(49, 26);
            rootLayout.Add(txtDown, 64, 80);

            txtRight = new LegacyTextBox();
            txtRight.Text = "0";
            txtRight.Size = new Size(49, 26);
            rootLayout.Add(txtRight, 176, 80);

            txtLeft = new LegacyTextBox();
            txtLeft.Text = "0";
            txtLeft.Size = new Size(49, 26);
            rootLayout.Add(txtLeft, 176, 48);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(265, 33);
            rootLayout.Add(cmdOk, 8, 384);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(265, 33);
            rootLayout.Add(cmdCancel, 288, 384);

            cmbMoral = new LegacyComboBox();
            cmbMoral.Items.Add("None");
            cmbMoral.Items.Add("Safe Zone");
            cmbMoral.Items.Add("Inn");
            cmbMoral.Items.Add("Arena");
            cmbMoral.Size = new Size(161, 26);
            rootLayout.Add(cmbMoral, 64, 120);

            cmbNpc = new LegacyComboBox();
            cmbNpc.Size = new Size(273, 26);
            rootLayout.Add(cmbNpc, 280, 32);

            cmbNpc_1 = new LegacyComboBox();
            cmbNpc_1.Size = new Size(273, 26);
            rootLayout.Add(cmbNpc_1, 280, 64);

            cmbNpc_2 = new LegacyComboBox();
            cmbNpc_2.Size = new Size(273, 26);
            rootLayout.Add(cmbNpc_2, 280, 96);

            cmbNpc_3 = new LegacyComboBox();
            cmbNpc_3.Size = new Size(273, 26);
            rootLayout.Add(cmbNpc_3, 280, 128);

            cmbNpc_4 = new LegacyComboBox();
            cmbNpc_4.Size = new Size(273, 26);
            rootLayout.Add(cmbNpc_4, 280, 160);

            txtBootMap = new LegacyTextBox();
            txtBootMap.Text = "0";
            txtBootMap.Size = new Size(49, 26);
            rootLayout.Add(txtBootMap, 88, 256);

            txtBootX = new LegacyTextBox();
            txtBootX.Text = "0";
            txtBootX.Size = new Size(49, 26);
            rootLayout.Add(txtBootX, 88, 288);

            txtBootY = new LegacyTextBox();
            txtBootY.Text = "0";
            txtBootY.Size = new Size(49, 26);
            rootLayout.Add(txtBootY, 88, 320);

            scrlMusic = new LegacyScrollBar();
            scrlMusic.MinValue = 0;
            scrlMusic.MaxValue = 255;
            scrlMusic.Value = 1;
            scrlMusic.Orientation = Orientation.Horizontal;
            scrlMusic.SmallChange = 1;
            scrlMusic.LargeChange = 1;
            scrlMusic.Size = new Size(161, 25);
            rootLayout.Add(scrlMusic, 64, 192);

            cmbShop = new LegacyComboBox();
            cmbShop.Size = new Size(161, 26);
            rootLayout.Add(cmbShop, 64, 152);

            cmbNpc_5 = new LegacyComboBox();
            cmbNpc_5.Size = new Size(273, 26);
            rootLayout.Add(cmbNpc_5, 280, 192);

            cmbNpc_6 = new LegacyComboBox();
            cmbNpc_6.Size = new Size(273, 26);
            rootLayout.Add(cmbNpc_6, 280, 224);

            cmbNpc_7 = new LegacyComboBox();
            cmbNpc_7.Size = new Size(273, 26);
            rootLayout.Add(cmbNpc_7, 280, 256);

            cmbNpc_8 = new LegacyComboBox();
            cmbNpc_8.Size = new Size(273, 26);
            rootLayout.Add(cmbNpc_8, 280, 288);

            cmbNpc_9 = new LegacyComboBox();
            cmbNpc_9.Size = new Size(273, 26);
            rootLayout.Add(cmbNpc_9, 280, 320);

            cmdTest = new LegacyButton();
            cmdTest.Caption = "Test Song";
            cmdTest.Size = new Size(81, 25);
            rootLayout.Add(cmdTest, 8, 224);

            cmdStop = new LegacyButton();
            cmdStop.Caption = "Stop Song";
            cmdStop.Size = new Size(89, 25);
            rootLayout.Add(cmdStop, 184, 224);

            frmType = new LegacyFrame();
            frmType.Caption = "Map Type";
            frmType.Size = new Size(121, 81);
            rootLayout.Add(frmType, 152, 256);

            optOutside = new LegacyRadioButton();
            optOutside.Caption = "Outer";
            optOutside.Value = true;
            optOutside.Size = new Size(105, 18);
            rootLayout.Add(optOutside, 160, 304);

            optInside = new LegacyRadioButton(optOutside);
            optInside.Caption = "Inner";
            optInside.Size = new Size(105, 18);
            rootLayout.Add(optInside, 160, 280);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}