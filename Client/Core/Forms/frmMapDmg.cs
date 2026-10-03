using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmMapDmg : EditForm
    {

        public readonly LegacyLabel Label2;
        public readonly LegacyLabel lblItem;
        public readonly LegacyLabel lblName;
        public readonly LegacyLabel Label1;
        public readonly LegacyLabel Label3;
        public readonly LegacyLabel Label4;
        public readonly LegacyLabel Label5;
        public readonly LegacyLabel lblDamage;
        public readonly LegacyScrollBar scrlDamage;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyButton cmdOk;
        public readonly LegacyScrollBar scrlItem;

        public frmMapDmg()
        {
            Title = "Map Damage";
            ClientSize = new Size(326, 201);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            Label2 = new LegacyLabel();
            Label2.Caption = "Item";
            Label2.Size = new Size(41, 17);
            rootLayout.Add(Label2, 0, 32);

            lblItem = new LegacyLabel();
            lblItem.Caption = "0";
            lblItem.Size = new Size(57, 17);
            rootLayout.Add(lblItem, 264, 32);

            lblName = new LegacyLabel();
            lblName.Caption = "";
            lblName.Size = new Size(273, 25);
            rootLayout.Add(lblName, 48, 8);

            Label1 = new LegacyLabel();
            Label1.Caption = "Item";
            Label1.Size = new Size(41, 17);
            rootLayout.Add(Label1, 0, 8);

            Label3 = new LegacyLabel();
            Label3.Caption = "This item will make all of the damage void if the player has it equiped!";
            Label3.Size = new Size(321, 33);
            rootLayout.Add(Label3, 8, 56);

            Label4 = new LegacyLabel();
            Label4.Caption = "Damage";
            Label4.Size = new Size(49, 17);
            rootLayout.Add(Label4, 0, 96);

            Label5 = new LegacyLabel();
            Label5.Caption = "This is the ammount of damage that will be dealt if the player does not have the above item equiped!";
            Label5.Size = new Size(321, 33);
            rootLayout.Add(Label5, 8, 120);

            lblDamage = new LegacyLabel();
            lblDamage.Caption = "0";
            lblDamage.Size = new Size(57, 17);
            rootLayout.Add(lblDamage, 264, 96);

            scrlDamage = new LegacyScrollBar();
            scrlDamage.MinValue = 1;
            scrlDamage.MaxValue = 100;
            scrlDamage.Value = 1;
            scrlDamage.Orientation = Orientation.Horizontal;
            scrlDamage.SmallChange = 1;
            scrlDamage.LargeChange = 1;
            scrlDamage.Size = new Size(217, 17);
            rootLayout.Add(scrlDamage, 48, 96);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(153, 33);
            rootLayout.Add(cmdCancel, 168, 160);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(153, 33);
            rootLayout.Add(cmdOk, 8, 160);

            scrlItem = new LegacyScrollBar();
            scrlItem.MinValue = 1;
            scrlItem.MaxValue = 500;
            scrlItem.Value = 1;
            scrlItem.Orientation = Orientation.Horizontal;
            scrlItem.SmallChange = 1;
            scrlItem.LargeChange = 1;
            scrlItem.Size = new Size(217, 17);
            rootLayout.Add(scrlItem, 40, 32);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}