using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmGuildCreate : EditForm
    {

        public readonly LegacyLabel Label1;
        public readonly LegacyLabel lblGuild;
        public readonly LegacyLabel Label2;
        public readonly LegacyLabel Label3;
        public readonly LegacyLabel Label4;
        public readonly LegacyScrollBar scrlGuild;
        public readonly LegacyTextBox txtName;
        public readonly LegacyTextBox txtAbr;
        public readonly LegacyTextBox txtFounder;
        public readonly LegacyButton cmdSave;
        public readonly LegacyButton cmdCancel;

        public frmGuildCreate()
        {
            Title = "Create Guild";
            ClientSize = new Size(225, 245);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            Label1 = new LegacyLabel();
            Label1.Caption = "Guild";
            Label1.Size = new Size(97, 17);
            rootLayout.Add(Label1, 8, 8);

            lblGuild = new LegacyLabel();
            lblGuild.Caption = "0";
            lblGuild.Size = new Size(25, 17);
            rootLayout.Add(lblGuild, 200, 32);

            Label2 = new LegacyLabel();
            Label2.Caption = "Name:";
            Label2.Size = new Size(97, 17);
            rootLayout.Add(Label2, 8, 64);

            Label3 = new LegacyLabel();
            Label3.Caption = "Abbreviation:";
            Label3.Size = new Size(97, 17);
            rootLayout.Add(Label3, 8, 112);

            Label4 = new LegacyLabel();
            Label4.Caption = "Founder:";
            Label4.Size = new Size(97, 17);
            rootLayout.Add(Label4, 8, 160);

            scrlGuild = new LegacyScrollBar();
            scrlGuild.MinValue = 1;
            scrlGuild.MaxValue = 50;
            scrlGuild.Value = 1;
            scrlGuild.Orientation = Orientation.Horizontal;
            scrlGuild.SmallChange = 1;
            scrlGuild.LargeChange = 1;
            scrlGuild.Size = new Size(185, 17);
            rootLayout.Add(scrlGuild, 8, 32);

            txtName = new LegacyTextBox();
            txtName.Text = "";
            txtName.Size = new Size(193, 19);
            rootLayout.Add(txtName, 8, 88);

            txtAbr = new LegacyTextBox();
            txtAbr.Text = "";
            txtAbr.Size = new Size(193, 19);
            rootLayout.Add(txtAbr, 8, 136);

            txtFounder = new LegacyTextBox();
            txtFounder.Text = "";
            txtFounder.Size = new Size(193, 19);
            rootLayout.Add(txtFounder, 8, 184);

            cmdSave = new LegacyButton();
            cmdSave.Caption = "Save";
            cmdSave.Size = new Size(65, 25);
            rootLayout.Add(cmdSave, 8, 216);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(65, 25);
            rootLayout.Add(cmdCancel, 152, 216);

            Shown += OnFormShown;
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            // Hook point for migrated Form_Load logic.
        }
    }
}