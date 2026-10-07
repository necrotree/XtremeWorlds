using Eto.Drawing;
using Eto.Forms;

namespace XtremeWorlds.Client.Tools
{
    public partial class frmEmoticonEditor : ToolForm
    {

        public readonly Label lblName;
        public readonly TextBox txtCommand;
        public readonly SpritePreview picIcon;
        public readonly Label lblArrow;
        public readonly Slider scrlSprite;
        public readonly Label lblSprite;
        public readonly Label lblStatus;
        public readonly Button cmdOk;
        public readonly Button cmdCancel;

        public frmEmoticonEditor() : base("emote")
        {
            Title = "Emote Editor";
            ClientSize = new Size(351, 182);
            Resizable = false;
            var root = new PixelLayout();
            Content = root;
            lblName = new Label();
            lblName.Size = new Size(70, 25);
            lblName.Text = "Command";
            RegisterControl("lblName", lblName);
            root.Add(lblName, 8, 8);
            txtCommand = new TextBox();
            txtCommand.Size = new Size(249, 26);
            txtCommand.MaxLength = 32;
            RegisterControl("txtCommand", txtCommand);
            root.Add(txtCommand, 80, 8);
            picIcon = new SpritePreview();
            picIcon.Size = new Size(48, 48);
            RegisterControl("picIcon", picIcon);
            root.Add(picIcon, 286, 35);
            lblArrow = new Label();
            lblArrow.Size = new Size(65, 25);
            lblArrow.Text = "Emoticon";
            RegisterControl("lblArrow", lblArrow);
            root.Add(lblArrow, 8, 40);
            scrlSprite = new Slider();
            scrlSprite.Size = new Size(168, 25);
            scrlSprite.MinValue = 0;
            scrlSprite.MaxValue = 30;
            scrlSprite.Value = 0;
            RegisterControl("scrlSprite", scrlSprite);
            root.Add(scrlSprite, 80, 40);
            lblSprite = new Label();
            lblSprite.Size = new Size(33, 25);
            lblSprite.Text = "0";
            RegisterControl("lblSprite", lblSprite);
            root.Add(lblSprite, 248, 40);
            lblStatus = new Label();
            lblStatus.Size = new Size(320, 30);
            lblStatus.Text = "";
            RegisterControl("lblStatus", lblStatus);
            root.Add(lblStatus, 8, 101);
            cmdOk = new Button();
            cmdOk.Size = new Size(153, 33);
            cmdOk.Text = "Save";
            RegisterControl("cmdOk", cmdOk);
            root.Add(cmdOk, 10, 144);
            cmdCancel = new Button();
            cmdCancel.Size = new Size(153, 33);
            cmdCancel.Text = "Close";
            RegisterControl("cmdCancel", cmdCancel);
            root.Add(cmdCancel, 178, 144);
            InitializeTool();
        }
    }
}