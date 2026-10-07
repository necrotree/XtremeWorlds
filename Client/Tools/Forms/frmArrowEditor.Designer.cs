using Eto.Drawing;
using Eto.Forms;

namespace XtremeWorlds.Client.Tools
{
    public partial class frmArrowEditor : ToolForm
    {

        public readonly Label lblName;
        public readonly TextBox txtName;
        public readonly SpritePreview picIcon;
        public readonly Label lblArrow;
        public readonly Slider scrlSprite;
        public readonly Label lblSprite;
        public readonly Label lblRangeTitle;
        public readonly Slider scrlRange;
        public readonly Label lblRange;
        public readonly SpritePreview picPreview;
        public readonly Button cmdOk;
        public readonly Button cmdCancel;

        public frmArrowEditor() : base("arrow")
        {
            Title = "Arrow Editor";
            ClientSize = new Size(351, 238);
            Resizable = false;
            var root = new PixelLayout();
            Content = root;
            lblName = new Label();
            lblName.Size = new Size(49, 25);
            lblName.Text = "Name";
            RegisterControl("lblName", lblName);
            root.Add(lblName, 8, 8);
            txtName = new TextBox();
            txtName.Size = new Size(265, 26);
            txtName.MaxLength = 50;
            RegisterControl("txtName", txtName);
            root.Add(txtName, 64, 8);
            picIcon = new SpritePreview();
            picIcon.Size = new Size(32, 32);
            RegisterControl("picIcon", picIcon);
            root.Add(picIcon, 296, 40);
            lblArrow = new Label();
            lblArrow.Size = new Size(49, 25);
            lblArrow.Text = "Arrow";
            RegisterControl("lblArrow", lblArrow);
            root.Add(lblArrow, 8, 40);
            scrlSprite = new Slider();
            scrlSprite.Size = new Size(193, 25);
            scrlSprite.MinValue = 0;
            scrlSprite.MaxValue = 153;
            scrlSprite.Value = 0;
            RegisterControl("scrlSprite", scrlSprite);
            root.Add(scrlSprite, 64, 40);
            lblSprite = new Label();
            lblSprite.Size = new Size(33, 25);
            lblSprite.Text = "1";
            RegisterControl("lblSprite", lblSprite);
            root.Add(lblSprite, 256, 40);
            lblRangeTitle = new Label();
            lblRangeTitle.Size = new Size(49, 25);
            lblRangeTitle.Text = "Range";
            RegisterControl("lblRangeTitle", lblRangeTitle);
            root.Add(lblRangeTitle, 8, 80);
            scrlRange = new Slider();
            scrlRange.Size = new Size(193, 25);
            scrlRange.MinValue = 0;
            scrlRange.MaxValue = 32;
            scrlRange.Value = 0;
            RegisterControl("scrlRange", scrlRange);
            root.Add(scrlRange, 64, 80);
            lblRange = new Label();
            lblRange.Size = new Size(33, 25);
            lblRange.Text = "0";
            RegisterControl("lblRange", lblRange);
            root.Add(lblRange, 257, 80);
            picPreview = new SpritePreview();
            picPreview.Size = new Size(321, 72);
            RegisterControl("picPreview", picPreview);
            root.Add(picPreview, 12, 108);
            cmdOk = new Button();
            cmdOk.Size = new Size(153, 33);
            cmdOk.Text = "OK";
            RegisterControl("cmdOk", cmdOk);
            root.Add(cmdOk, 10, 188);
            cmdCancel = new Button();
            cmdCancel.Size = new Size(153, 33);
            cmdCancel.Text = "Cancel";
            RegisterControl("cmdCancel", cmdCancel);
            root.Add(cmdCancel, 178, 189);
            InitializeTool();
        }
    }
}