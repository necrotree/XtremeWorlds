using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmShopEditor : Form
    {

        public readonly LegacyLabel Label14;
        public readonly LegacyLabel Label1;
        public readonly LegacyLabel Label2;
        public readonly LegacyLabel Label3;
        public readonly LegacyLabel Label4;
        public readonly LegacyLabel Label5;
        public readonly LegacyLabel Label6;
        public readonly LegacyLabel Label7;
        public readonly LegacyLabel Label8;
        public readonly LegacyTextBox txtJoinSay;
        public readonly LegacyTextBox txtName;
        public readonly LegacyTextBox txtLeaveSay;
        public readonly LegacyListBox lstTradeItem;
        public readonly LegacyComboBox cmbItemGive;
        public readonly LegacyTextBox txtItemGiveValue;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyButton cmdOk;
        public readonly LegacyComboBox cmbItemGet;
        public readonly LegacyTextBox txtItemGetValue;
        public readonly LegacyButton cmdUpdate;
        public readonly LegacyCheckBox chkFixesItems;
        public readonly LegacyTextBox txtItem2GiveValue;
        public readonly LegacyComboBox cmbitem2Give;

        public frmShopEditor()
        {
            Title = "Shop Editor";
            ClientSize = new Size(369, 543);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            Label14 = new LegacyLabel();
            Label14.Caption = "Join Say";
            Label14.Size = new Size(81, 25);
            rootLayout.Add(Label14, 8, 40);

            Label1 = new LegacyLabel();
            Label1.Caption = "Name";
            Label1.Size = new Size(81, 25);
            rootLayout.Add(Label1, 8, 8);

            Label2 = new LegacyLabel();
            Label2.Caption = "Leave Say";
            Label2.Size = new Size(81, 25);
            rootLayout.Add(Label2, 8, 72);

            Label3 = new LegacyLabel();
            Label3.Caption = "Item Give";
            Label3.Size = new Size(81, 25);
            rootLayout.Add(Label3, 8, 152);

            Label4 = new LegacyLabel();
            Label4.Caption = "Value";
            Label4.Size = new Size(81, 25);
            rootLayout.Add(Label4, 8, 184);

            Label5 = new LegacyLabel();
            Label5.Caption = "Item Get";
            Label5.Size = new Size(81, 25);
            rootLayout.Add(Label5, 8, 296);

            Label6 = new LegacyLabel();
            Label6.Caption = "Value";
            Label6.Size = new Size(81, 25);
            rootLayout.Add(Label6, 8, 328);

            Label7 = new LegacyLabel();
            Label7.Caption = "Value 2";
            Label7.Size = new Size(81, 25);
            rootLayout.Add(Label7, 8, 256);

            Label8 = new LegacyLabel();
            Label8.Caption = "Item Give 2";
            Label8.Size = new Size(81, 25);
            rootLayout.Add(Label8, 8, 224);

            txtJoinSay = new LegacyTextBox();
            txtJoinSay.Text = "";
            txtJoinSay.ToolTip = "This is what the shop will say when it opens.";
            txtJoinSay.Size = new Size(265, 26);
            rootLayout.Add(txtJoinSay, 96, 40);

            txtName = new LegacyTextBox();
            txtName.Text = "";
            txtName.ToolTip = "This is the name of the shop.";
            txtName.Size = new Size(265, 26);
            rootLayout.Add(txtName, 96, 8);

            txtLeaveSay = new LegacyTextBox();
            txtLeaveSay.Text = "";
            txtLeaveSay.ToolTip = "This is the goodbye message that will appear after a player is done shopping.";
            txtLeaveSay.Size = new Size(265, 26);
            rootLayout.Add(txtLeaveSay, 96, 72);

            lstTradeItem = new LegacyListBox();
            lstTradeItem.Items.Add("1.");
            lstTradeItem.Items.Add("2.");
            lstTradeItem.Items.Add("3.");
            lstTradeItem.Items.Add("4.");
            lstTradeItem.Items.Add("5.");
            lstTradeItem.Items.Add("6.");
            lstTradeItem.Items.Add("7.");
            lstTradeItem.Items.Add("8.");
            lstTradeItem.Size = new Size(353, 116);
            rootLayout.Add(lstTradeItem, 8, 368);

            cmbItemGive = new LegacyComboBox();
            cmbItemGive.Size = new Size(265, 26);
            rootLayout.Add(cmbItemGive, 96, 152);

            txtItemGiveValue = new LegacyTextBox();
            txtItemGiveValue.Text = "1";
            txtItemGiveValue.Size = new Size(89, 26);
            rootLayout.Add(txtItemGiveValue, 96, 184);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(169, 41);
            rootLayout.Add(cmdCancel, 192, 496);

            cmdOk = new LegacyButton();
            cmdOk.Caption = "Ok";
            cmdOk.Size = new Size(169, 41);
            rootLayout.Add(cmdOk, 8, 496);

            cmbItemGet = new LegacyComboBox();
            cmbItemGet.Size = new Size(265, 26);
            rootLayout.Add(cmbItemGet, 96, 296);

            txtItemGetValue = new LegacyTextBox();
            txtItemGetValue.Text = "1";
            txtItemGetValue.Size = new Size(89, 26);
            rootLayout.Add(txtItemGetValue, 96, 328);

            cmdUpdate = new LegacyButton();
            cmdUpdate.Caption = "Update ";
            cmdUpdate.Size = new Size(161, 25);
            rootLayout.Add(cmdUpdate, 200, 328);

            chkFixesItems = new LegacyCheckBox();
            chkFixesItems.Caption = "Fixes Items";
            chkFixesItems.Checked = false;
            chkFixesItems.ToolTip = "Check this box if you wat the shop to be able to fix items.";
            chkFixesItems.Size = new Size(353, 25);
            rootLayout.Add(chkFixesItems, 8, 112);

            txtItem2GiveValue = new LegacyTextBox();
            txtItem2GiveValue.Text = "1";
            txtItem2GiveValue.Enabled = false;
            txtItem2GiveValue.Size = new Size(89, 26);
            rootLayout.Add(txtItem2GiveValue, 96, 256);

            cmbitem2Give = new LegacyComboBox();
            cmbitem2Give.Enabled = false;
            cmbitem2Give.Size = new Size(265, 26);
            rootLayout.Add(cmbitem2Give, 96, 224);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}