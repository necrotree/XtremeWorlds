using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmSpellEditor : EditForm
    {

        public readonly LegacyLabel Label1;
        public readonly LegacyLabel Label3;
        public readonly LegacyLabel lblLevelReq;
        public readonly LegacyLabel lblMP;
        public readonly LegacyLabel Label7;
        public readonly LegacyTextBox txtName;
        public readonly LegacyFrame fraVitals;
        public readonly LegacyLabel lblVitalMod;
        public readonly LegacyLabel Label4;
        public readonly LegacyScrollBar scrlVitalMod;
        public readonly LegacyComboBox cmbType;
        public readonly LegacyFrame fraGiveItem;
        public readonly LegacyLabel Label2;
        public readonly LegacyLabel lblItemNum;
        public readonly LegacyLabel Label5;
        public readonly LegacyLabel lblItemValue;
        public readonly LegacyScrollBar scrlItemNum;
        public readonly LegacyScrollBar scrlItemValue;
        public readonly LegacyComboBox cmbClassReq;
        public readonly LegacyScrollBar scrlLevelReq;
        public readonly LegacyFrame fraMisc;
        public readonly LegacyLabel lblAnim;
        public readonly LegacyScrollBar scrlAnim;
        public readonly LegacyPictureBox picAnim;
        public readonly LegacyScrollBar scrlMP;
        public readonly LegacyFrame fraWarp;
        public readonly LegacyLabel lblMapY;
        public readonly LegacyLabel Label8;
        public readonly LegacyLabel lblmapX;
        public readonly LegacyLabel Label10;
        public readonly LegacyLabel Label9;
        public readonly LegacyScrollBar scrlMapY;
        public readonly LegacyScrollBar scrlMapX;
        public readonly LegacyTextBox txtMap;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyButton cmdOk;
        public readonly UITimer tmrSpellAnim;
        public readonly LegacyPictureBox picSpells;
        public readonly LegacyLabel lblDelivery;
        public readonly LegacyComboBox cmbDelivery;
        public readonly LegacyLabel lblCastRange;
        public readonly LegacyTextBox txtCastRange;
        public readonly LegacyComboBox cmbArrow;

        public frmSpellEditor()
        {
            Title = "Spell Editor";
            ClientSize = new Size(332, 561);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            Label1 = new LegacyLabel();
            Label1.Caption = "Name";
            Label1.Size = new Size(49, 25);
            rootLayout.Add(Label1, 8, 8);

            Label3 = new LegacyLabel();
            Label3.Caption = "Level";
            Label3.Size = new Size(49, 25);
            rootLayout.Add(Label3, 8, 88);

            lblLevelReq = new LegacyLabel();
            lblLevelReq.Caption = "1";
            lblLevelReq.Size = new Size(33, 25);
            rootLayout.Add(lblLevelReq, 296, 88);

            lblMP = new LegacyLabel();
            lblMP.Caption = "1";
            lblMP.Size = new Size(33, 25);
            rootLayout.Add(lblMP, 296, 120);

            Label7 = new LegacyLabel();
            Label7.Caption = "MP";
            Label7.Size = new Size(49, 25);
            rootLayout.Add(Label7, 8, 120);

            txtName = new LegacyTextBox();
            txtName.Text = "";
            txtName.Size = new Size(265, 26);
            rootLayout.Add(txtName, 64, 8);

            fraVitals = new LegacyFrame();
            fraVitals.Caption = "Vitals Data";
            fraVitals.Visible = false;
            fraVitals.Size = new Size(321, 97);
            rootLayout.Add(fraVitals, 8, 200);
            var layout_fraVitals = new PixelLayout();
            fraVitals.Content = layout_fraVitals;
            lblVitalMod = new LegacyLabel();
            lblVitalMod.Caption = "1";
            lblVitalMod.Size = new Size(33, 25);
            layout_fraVitals.Add(lblVitalMod, 280, 24);

            Label4 = new LegacyLabel();
            Label4.Caption = "Vital Mod";
            Label4.Size = new Size(73, 25);
            layout_fraVitals.Add(Label4, 8, 24);

            scrlVitalMod = new LegacyScrollBar();
            scrlVitalMod.MinValue = 0;
            scrlVitalMod.MaxValue = 255;
            scrlVitalMod.Value = 1;
            scrlVitalMod.Orientation = Orientation.Horizontal;
            scrlVitalMod.SmallChange = 1;
            scrlVitalMod.LargeChange = 1;
            scrlVitalMod.Size = new Size(193, 25);
            layout_fraVitals.Add(scrlVitalMod, 88, 24);


            cmbType = new LegacyComboBox();
            cmbType.Items.Add("Add HP");
            cmbType.Items.Add("Add MP");
            cmbType.Items.Add("Add SP");
            cmbType.Items.Add("Sub HP");
            cmbType.Items.Add("Sub MP");
            cmbType.Items.Add("Sub SP");
            cmbType.Items.Add("Give Item");
            cmbType.Items.Add("Warp");
            cmbType.Size = new Size(321, 26);
            rootLayout.Add(cmbType, 8, 160);

            fraGiveItem = new LegacyFrame();
            fraGiveItem.Caption = "Give Item";
            fraGiveItem.Visible = false;
            fraGiveItem.Size = new Size(321, 97);
            rootLayout.Add(fraGiveItem, 8, 200);
            var layout_fraGiveItem = new PixelLayout();
            fraGiveItem.Content = layout_fraGiveItem;
            Label2 = new LegacyLabel();
            Label2.Caption = "Item";
            Label2.Size = new Size(49, 25);
            layout_fraGiveItem.Add(Label2, 8, 24);

            lblItemNum = new LegacyLabel();
            lblItemNum.Caption = "1";
            lblItemNum.Size = new Size(57, 25);
            layout_fraGiveItem.Add(lblItemNum, 256, 24);

            Label5 = new LegacyLabel();
            Label5.Caption = "Value";
            Label5.Size = new Size(49, 25);
            layout_fraGiveItem.Add(Label5, 8, 56);

            lblItemValue = new LegacyLabel();
            lblItemValue.Caption = "0";
            lblItemValue.Size = new Size(57, 25);
            layout_fraGiveItem.Add(lblItemValue, 256, 56);

            scrlItemNum = new LegacyScrollBar();
            scrlItemNum.MinValue = 1;
            scrlItemNum.MaxValue = 500;
            scrlItemNum.Value = 1;
            scrlItemNum.Orientation = Orientation.Horizontal;
            scrlItemNum.SmallChange = 1;
            scrlItemNum.LargeChange = 1;
            scrlItemNum.Size = new Size(193, 25);
            layout_fraGiveItem.Add(scrlItemNum, 64, 24);

            scrlItemValue = new LegacyScrollBar();
            scrlItemValue.MinValue = 0;
            scrlItemValue.MaxValue = 32767;
            scrlItemValue.Value = 0;
            scrlItemValue.Orientation = Orientation.Horizontal;
            scrlItemValue.SmallChange = 1;
            scrlItemValue.LargeChange = 1;
            scrlItemValue.Size = new Size(193, 25);
            layout_fraGiveItem.Add(scrlItemValue, 64, 56);


            cmbClassReq = new LegacyComboBox();
            cmbClassReq.Size = new Size(321, 26);
            rootLayout.Add(cmbClassReq, 8, 48);

            scrlLevelReq = new LegacyScrollBar();
            scrlLevelReq.MinValue = 1;
            scrlLevelReq.MaxValue = 255;
            scrlLevelReq.Value = 1;
            scrlLevelReq.Orientation = Orientation.Horizontal;
            scrlLevelReq.SmallChange = 1;
            scrlLevelReq.LargeChange = 1;
            scrlLevelReq.Size = new Size(233, 25);
            rootLayout.Add(scrlLevelReq, 64, 88);

            fraMisc = new LegacyFrame();
            fraMisc.Caption = "Animation";
            fraMisc.Size = new Size(321, 97);
            rootLayout.Add(fraMisc, 8, 304);
            var layout_fraMisc = new PixelLayout();
            fraMisc.Content = layout_fraMisc;
            lblAnim = new LegacyLabel();
            lblAnim.Caption = "0";
            lblAnim.Size = new Size(33, 17);
            layout_fraMisc.Add(lblAnim, 264, 24);

            scrlAnim = new LegacyScrollBar();
            scrlAnim.MinValue = 0;
            scrlAnim.MaxValue = 100;
            scrlAnim.Value = 0;
            scrlAnim.Orientation = Orientation.Horizontal;
            scrlAnim.SmallChange = 1;
            scrlAnim.LargeChange = 1;
            scrlAnim.Size = new Size(241, 17);
            layout_fraMisc.Add(scrlAnim, 8, 24);

            picAnim = new LegacyPictureBox();
            picAnim.Size = new Size(33, 33);
            layout_fraMisc.Add(picAnim, 16, 48);


            scrlMP = new LegacyScrollBar();
            scrlMP.MinValue = 1;
            scrlMP.MaxValue = 255;
            scrlMP.Value = 1;
            scrlMP.Orientation = Orientation.Horizontal;
            scrlMP.SmallChange = 1;
            scrlMP.LargeChange = 1;
            scrlMP.Size = new Size(233, 25);
            rootLayout.Add(scrlMP, 64, 120);

            fraWarp = new LegacyFrame();
            fraWarp.Caption = "Warp";
            fraWarp.Visible = false;
            fraWarp.Size = new Size(321, 97);
            rootLayout.Add(fraWarp, 8, 200);
            var layout_fraWarp = new PixelLayout();
            fraWarp.Content = layout_fraWarp;
            lblMapY = new LegacyLabel();
            lblMapY.Caption = "1";
            lblMapY.Size = new Size(57, 25);
            layout_fraWarp.Add(lblMapY, 256, 64);

            Label8 = new LegacyLabel();
            Label8.Caption = "Y";
            Label8.Size = new Size(49, 25);
            layout_fraWarp.Add(Label8, 168, 64);

            lblmapX = new LegacyLabel();
            lblmapX.Caption = "1";
            lblmapX.Size = new Size(57, 25);
            layout_fraWarp.Add(lblmapX, 96, 64);

            Label10 = new LegacyLabel();
            Label10.Caption = "X";
            Label10.Size = new Size(49, 25);
            layout_fraWarp.Add(Label10, 8, 64);

            Label9 = new LegacyLabel();
            Label9.Caption = "Map";
            Label9.Size = new Size(73, 25);
            layout_fraWarp.Add(Label9, 8, 24);

            scrlMapY = new LegacyScrollBar();
            scrlMapY.MinValue = 0;
            scrlMapY.MaxValue = 11;
            scrlMapY.Value = 0;
            scrlMapY.Orientation = Orientation.Horizontal;
            scrlMapY.SmallChange = 1;
            scrlMapY.LargeChange = 1;
            scrlMapY.Size = new Size(89, 25);
            layout_fraWarp.Add(scrlMapY, 192, 64);

            scrlMapX = new LegacyScrollBar();
            scrlMapX.MinValue = 0;
            scrlMapX.MaxValue = 15;
            scrlMapX.Value = 0;
            scrlMapX.Orientation = Orientation.Horizontal;
            scrlMapX.SmallChange = 1;
            scrlMapX.LargeChange = 1;
            scrlMapX.Size = new Size(89, 25);
            layout_fraWarp.Add(scrlMapX, 32, 64);

            txtMap = new LegacyTextBox();
            txtMap.Text = "";
            txtMap.Size = new Size(193, 26);
            layout_fraWarp.Add(txtMap, 64, 24);


            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(153, 33);
            rootLayout.Add(cmdCancel, 172, 515);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(153, 33);
            rootLayout.Add(cmdOk, 13, 515);

            tmrSpellAnim = new UITimer() { Interval = 0.05d };
            tmrSpellAnim.Start();
            picSpells = new LegacyPictureBox();
            picSpells.Size = new Size(89, 97);
            rootLayout.Add(picSpells, 376, 8);

            lblDelivery = new LegacyLabel();
            lblDelivery.Caption = "Spell delivery (all spell types)";
            lblDelivery.Size = new Size(320, 20);
            rootLayout.Add(lblDelivery, 8, 412);

            cmbDelivery = new LegacyComboBox();
            cmbDelivery.Size = new Size(320, 22);
            rootLayout.Add(cmbDelivery, 8, 436);

            lblCastRange = new LegacyLabel();
            lblCastRange.Caption = "Range cast: distance in tiles";
            lblCastRange.Size = new Size(178, 20);
            rootLayout.Add(lblCastRange, 8, 468);

            txtCastRange = new LegacyTextBox();
            txtCastRange.Text = "32";
            txtCastRange.Size = new Size(90, 24);
            rootLayout.Add(txtCastRange, 238, 466);

            cmbArrow = new LegacyComboBox();
            cmbArrow.Size = new Size(178, 22);
            rootLayout.Add(cmbArrow, 12, 489);

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