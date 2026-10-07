using Eto.Drawing;
using Eto.Forms;

namespace XtremeWorlds.Client.Tools
{
    public partial class frmBookEditor : ToolForm
    {

        public readonly Label lblBookTitle;
        public readonly Label lblBookHeader;
        public readonly Label Label1;
        public readonly Label Label2;
        public readonly GroupBox fraPage1;
        public readonly TextArea txtPage1;
        public readonly GroupBox fraPage2;
        public readonly TextArea txtPage2;
        public readonly Button cmdCancel;
        public readonly Button cmdOk;
        public readonly Button cmdPreview;
        public readonly TextBox txtBookTitle;
        public readonly TextBox txtBookHeader;
        public readonly DropDown cmbBook;
        public readonly DropDown cmbQuest;

        public frmBookEditor() : base("book")
        {
            Title = "Book Editor";
            ClientSize = new Size(500, 414);
            Resizable = false;
            var root = new PixelLayout();
            Content = root;
            lblBookTitle = new Label();
            lblBookTitle.Size = new Size(81, 33);
            lblBookTitle.Text = "Book Name";
            RegisterControl("lblBookTitle", lblBookTitle);
            root.Add(lblBookTitle, 8, 8);
            lblBookHeader = new Label();
            lblBookHeader.Size = new Size(89, 25);
            lblBookHeader.Text = "Book Header";
            RegisterControl("lblBookHeader", lblBookHeader);
            root.Add(lblBookHeader, 256, 8);
            Label1 = new Label();
            Label1.Size = new Size(121, 33);
            Label1.Text = "Connecting Book";
            RegisterControl("Label1", Label1);
            root.Add(Label1, 0, 312);
            Label2 = new Label();
            Label2.Size = new Size(121, 33);
            Label2.Text = "Quest";
            RegisterControl("Label2", Label2);
            root.Add(Label2, 0, 344);
            fraPage1 = new GroupBox();
            fraPage1.Size = new Size(241, 265);
            fraPage1.Text = "Book Page 1";
            RegisterControl("fraPage1", fraPage1);
            root.Add(fraPage1, 8, 40);
            var fraPage1Layout = new PixelLayout();
            fraPage1.Content = fraPage1Layout;
            txtPage1 = new TextArea();
            txtPage1.Size = new Size(225, 241);
            RegisterControl("txtPage1", txtPage1);
            fraPage1Layout.Add(txtPage1, 8, 0);
            fraPage2 = new GroupBox();
            fraPage2.Size = new Size(241, 265);
            fraPage2.Text = "Book Page 2";
            RegisterControl("fraPage2", fraPage2);
            root.Add(fraPage2, 256, 40);
            var fraPage2Layout = new PixelLayout();
            fraPage2.Content = fraPage2Layout;
            txtPage2 = new TextArea();
            txtPage2.Size = new Size(225, 241);
            RegisterControl("txtPage2", txtPage2);
            fraPage2Layout.Add(txtPage2, 8, 0);
            cmdCancel = new Button();
            cmdCancel.Size = new Size(153, 33);
            cmdCancel.Text = "Cancel";
            RegisterControl("cmdCancel", cmdCancel);
            root.Add(cmdCancel, 344, 376);
            cmdOk = new Button();
            cmdOk.Size = new Size(153, 33);
            cmdOk.Text = "Save";
            RegisterControl("cmdOk", cmdOk);
            root.Add(cmdOk, 8, 376);
            cmdPreview = new Button();
            cmdPreview.Size = new Size(153, 33);
            cmdPreview.Text = "Preview";
            RegisterControl("cmdPreview", cmdPreview);
            root.Add(cmdPreview, 176, 376);
            txtBookTitle = new TextBox();
            txtBookTitle.Size = new Size(153, 24);
            txtBookTitle.MaxLength = 25;
            RegisterControl("txtBookTitle", txtBookTitle);
            root.Add(txtBookTitle, 96, 8);
            txtBookHeader = new TextBox();
            txtBookHeader.Size = new Size(137, 24);
            txtBookHeader.MaxLength = 25;
            RegisterControl("txtBookHeader", txtBookHeader);
            root.Add(txtBookHeader, 352, 8);
            cmbBook = new DropDown();
            cmbBook.Size = new Size(209, 24);
            RegisterControl("cmbBook", cmbBook);
            root.Add(cmbBook, 128, 312);
            cmbQuest = new DropDown();
            cmbQuest.Size = new Size(209, 24);
            RegisterControl("cmbQuest", cmbQuest);
            root.Add(cmbQuest, 128, 344);
            InitializeTool();
        }
    }
}