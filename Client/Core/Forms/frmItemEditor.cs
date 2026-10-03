using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmItemEditor : EditForm
    {

        public readonly LegacyLabel Label1;
        public readonly LegacyLabel Label5;
        public readonly LegacyLabel lblPic;
        public readonly LegacyComboBox cmbType;
        public readonly LegacyTextBox txtName;
        public readonly LegacyFrame fraEquipment;
        public readonly LegacyLabel Label2;
        public readonly LegacyLabel Label3;
        public readonly LegacyLabel lblDurability;
        public readonly LegacyLabel lblStrength;
        public readonly LegacyScrollBar scrlDurability;
        public readonly LegacyScrollBar scrlStrength;
        public readonly LegacyFrame fraVitals;
        public readonly LegacyLabel Label4;
        public readonly LegacyLabel lblVitalMod;
        public readonly LegacyScrollBar scrlVitalMod;
        public readonly LegacyButton cmdOk;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyScrollBar scrlPic;
        public readonly LegacyPictureBox picPic;
        public readonly UITimer tmrPic;
        public readonly LegacyFrame fraSpell;
        public readonly LegacyLabel lblSpell;
        public readonly LegacyLabel Label7;
        public readonly LegacyLabel Label6;
        public readonly LegacyLabel lblSpellName;
        public readonly LegacyScrollBar scrlSpell;
        public readonly LegacyFrame fraWarp;
        public readonly LegacyLabel Label9;
        public readonly LegacyLabel Label10;
        public readonly LegacyLabel lblmapX;
        public readonly LegacyLabel Label8;
        public readonly LegacyLabel lblMapY;
        public readonly LegacyTextBox txtMap;
        public readonly LegacyScrollBar scrlMapX;
        public readonly LegacyScrollBar scrlMapY;

        public frmItemEditor()
        {
            Title = "Item Editor";
            ClientSize = new Size(337, 285);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            Label1 = new LegacyLabel();
            Label1.Caption = "Name";
            Label1.Size = new Size(49, 25);
            rootLayout.Add(Label1, 8, 8);

            Label5 = new LegacyLabel();
            Label5.Caption = "Pic";
            Label5.Size = new Size(57, 25);
            rootLayout.Add(Label5, 8, 40);

            lblPic = new LegacyLabel();
            lblPic.Caption = "0";
            lblPic.Size = new Size(33, 25);
            rootLayout.Add(lblPic, 256, 40);

            cmbType = new LegacyComboBox();
            cmbType.Items.Add("None");
            cmbType.Items.Add("Weapon");
            cmbType.Items.Add("Armor");
            cmbType.Items.Add("Helmet");
            cmbType.Items.Add("Shield");
            cmbType.Items.Add("Potion Add HP");
            cmbType.Items.Add("Potion Add MP");
            cmbType.Items.Add("Potion Add SP");
            cmbType.Items.Add("Potion Sub HP");
            cmbType.Items.Add("Potion Sub MP");
            cmbType.Items.Add("Potion Sub SP");
            cmbType.Items.Add("Key");
            cmbType.Items.Add("Currency");
            cmbType.Items.Add("Spell");
            cmbType.Items.Add("Warp");
            cmbType.Size = new Size(321, 26);
            rootLayout.Add(cmbType, 8, 88);

            txtName = new LegacyTextBox();
            txtName.Text = "";
            txtName.Size = new Size(265, 26);
            rootLayout.Add(txtName, 64, 8);

            fraEquipment = new LegacyFrame();
            fraEquipment.Caption = "Equipment Data";
            fraEquipment.Visible = false;
            fraEquipment.Size = new Size(321, 97);
            rootLayout.Add(fraEquipment, 8, 128);
            var layout_fraEquipment = new PixelLayout();
            fraEquipment.Content = layout_fraEquipment;
            Label2 = new LegacyLabel();
            Label2.Caption = "Durability";
            Label2.Size = new Size(73, 25);
            layout_fraEquipment.Add(Label2, 8, 32);

            Label3 = new LegacyLabel();
            Label3.Caption = "Strength";
            Label3.Size = new Size(65, 25);
            layout_fraEquipment.Add(Label3, 8, 64);

            lblDurability = new LegacyLabel();
            lblDurability.Caption = "1";
            lblDurability.Size = new Size(33, 25);
            layout_fraEquipment.Add(lblDurability, 280, 32);

            lblStrength = new LegacyLabel();
            lblStrength.Caption = "1";
            lblStrength.Size = new Size(33, 25);
            layout_fraEquipment.Add(lblStrength, 280, 64);

            scrlDurability = new LegacyScrollBar();
            scrlDurability.MinValue = 0;
            scrlDurability.MaxValue = 255;
            scrlDurability.Value = 1;
            scrlDurability.Orientation = Orientation.Horizontal;
            scrlDurability.SmallChange = 1;
            scrlDurability.LargeChange = 1;
            scrlDurability.Size = new Size(193, 25);
            layout_fraEquipment.Add(scrlDurability, 88, 32);

            scrlStrength = new LegacyScrollBar();
            scrlStrength.MinValue = 0;
            scrlStrength.MaxValue = 255;
            scrlStrength.Value = 1;
            scrlStrength.Orientation = Orientation.Horizontal;
            scrlStrength.SmallChange = 1;
            scrlStrength.LargeChange = 1;
            scrlStrength.Size = new Size(193, 25);
            layout_fraEquipment.Add(scrlStrength, 88, 64);


            fraVitals = new LegacyFrame();
            fraVitals.Caption = "Vitals Data";
            fraVitals.Visible = false;
            fraVitals.Size = new Size(321, 97);
            rootLayout.Add(fraVitals, 8, 128);
            var layout_fraVitals = new PixelLayout();
            fraVitals.Content = layout_fraVitals;
            Label4 = new LegacyLabel();
            Label4.Caption = "Vital Mod";
            Label4.Size = new Size(73, 25);
            layout_fraVitals.Add(Label4, 8, 24);

            lblVitalMod = new LegacyLabel();
            lblVitalMod.Caption = "1";
            lblVitalMod.Size = new Size(33, 25);
            layout_fraVitals.Add(lblVitalMod, 280, 24);

            scrlVitalMod = new LegacyScrollBar();
            scrlVitalMod.MinValue = 0;
            scrlVitalMod.MaxValue = 255;
            scrlVitalMod.Value = 1;
            scrlVitalMod.Orientation = Orientation.Horizontal;
            scrlVitalMod.SmallChange = 1;
            scrlVitalMod.LargeChange = 1;
            scrlVitalMod.Size = new Size(193, 25);
            layout_fraVitals.Add(scrlVitalMod, 88, 24);


            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(153, 33);
            rootLayout.Add(cmdOk, 11, 240);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(153, 33);
            rootLayout.Add(cmdCancel, 176, 240);

            scrlPic = new LegacyScrollBar();
            scrlPic.MinValue = 0;
            scrlPic.MaxValue = 500;
            scrlPic.Value = 0;
            scrlPic.Orientation = Orientation.Horizontal;
            scrlPic.SmallChange = 1;
            scrlPic.LargeChange = 1;
            scrlPic.Size = new Size(193, 25);
            rootLayout.Add(scrlPic, 64, 40);

            picPic = new LegacyPictureBox();
            picPic.Size = new Size(32, 32);
            rootLayout.Add(picPic, 296, 40);

            tmrPic = new UITimer() { Interval = 0.05d };
            tmrPic.Start();
            fraSpell = new LegacyFrame();
            fraSpell.Caption = "Spell Data";
            fraSpell.Visible = false;
            fraSpell.Size = new Size(321, 97);
            rootLayout.Add(fraSpell, 8, 128);
            var layout_fraSpell = new PixelLayout();
            fraSpell.Content = layout_fraSpell;
            lblSpell = new LegacyLabel();
            lblSpell.Caption = "1";
            lblSpell.Size = new Size(57, 25);
            layout_fraSpell.Add(lblSpell, 256, 56);

            Label7 = new LegacyLabel();
            Label7.Caption = "Num";
            Label7.Size = new Size(49, 25);
            layout_fraSpell.Add(Label7, 8, 56);

            Label6 = new LegacyLabel();
            Label6.Caption = "Name";
            Label6.Size = new Size(73, 25);
            layout_fraSpell.Add(Label6, 8, 24);

            lblSpellName = new LegacyLabel();
            lblSpellName.Caption = "";
            lblSpellName.Size = new Size(225, 25);
            layout_fraSpell.Add(lblSpellName, 88, 24);

            scrlSpell = new LegacyScrollBar();
            scrlSpell.MinValue = 0;
            scrlSpell.MaxValue = 500;
            scrlSpell.Value = 1;
            scrlSpell.Orientation = Orientation.Horizontal;
            scrlSpell.SmallChange = 1;
            scrlSpell.LargeChange = 1;
            scrlSpell.Size = new Size(193, 25);
            layout_fraSpell.Add(scrlSpell, 64, 56);


            fraWarp = new LegacyFrame();
            fraWarp.Caption = "Warp Data";
            fraWarp.Visible = false;
            fraWarp.Size = new Size(321, 97);
            rootLayout.Add(fraWarp, 8, 128);
            var layout_fraWarp = new PixelLayout();
            fraWarp.Content = layout_fraWarp;
            Label9 = new LegacyLabel();
            Label9.Caption = "Map";
            Label9.Size = new Size(73, 25);
            layout_fraWarp.Add(Label9, 8, 24);

            Label10 = new LegacyLabel();
            Label10.Caption = "X";
            Label10.Size = new Size(49, 25);
            layout_fraWarp.Add(Label10, 8, 64);

            lblmapX = new LegacyLabel();
            lblmapX.Caption = "1";
            lblmapX.Size = new Size(57, 25);
            layout_fraWarp.Add(lblmapX, 96, 64);

            Label8 = new LegacyLabel();
            Label8.Caption = "Y";
            Label8.Size = new Size(49, 25);
            layout_fraWarp.Add(Label8, 168, 64);

            lblMapY = new LegacyLabel();
            lblMapY.Caption = "1";
            lblMapY.Size = new Size(57, 25);
            layout_fraWarp.Add(lblMapY, 256, 64);

            txtMap = new LegacyTextBox();
            txtMap.Text = "";
            txtMap.Size = new Size(193, 26);
            layout_fraWarp.Add(txtMap, 64, 24);

            scrlMapX = new LegacyScrollBar();
            scrlMapX.MinValue = 0;
            scrlMapX.MaxValue = 15;
            scrlMapX.Value = 0;
            scrlMapX.Orientation = Orientation.Horizontal;
            scrlMapX.SmallChange = 1;
            scrlMapX.LargeChange = 1;
            scrlMapX.Size = new Size(89, 25);
            layout_fraWarp.Add(scrlMapX, 32, 64);

            scrlMapY = new LegacyScrollBar();
            scrlMapY.MinValue = 0;
            scrlMapY.MaxValue = 11;
            scrlMapY.Value = 0;
            scrlMapY.Orientation = Orientation.Horizontal;
            scrlMapY.SmallChange = 1;
            scrlMapY.LargeChange = 1;
            scrlMapY.Size = new Size(89, 25);
            layout_fraWarp.Add(scrlMapY, 192, 64);


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