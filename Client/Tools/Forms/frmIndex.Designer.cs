using Eto.Drawing;
using Eto.Forms;

namespace XtremeWorlds.Client.Tools
{
    public partial class frmIndex : ToolForm
    {

        public readonly ListBox lstIndex;
        public readonly Button cmdOk;
        public readonly Button cmdCancel;

        public frmIndex() : base("index")
        {
            Title = "Index";
            ClientSize = new Size(353, 298);
            Resizable = false;
            var root = new PixelLayout();
            Content = root;
            lstIndex = new ListBox();
            lstIndex.Size = new Size(337, 238);
            RegisterControl("lstIndex", lstIndex);
            root.Add(lstIndex, 8, 8);
            cmdOk = new Button();
            cmdOk.Size = new Size(161, 33);
            cmdOk.Text = "Ok";
            RegisterControl("cmdOk", cmdOk);
            root.Add(cmdOk, 8, 256);
            cmdCancel = new Button();
            cmdCancel.Size = new Size(161, 33);
            cmdCancel.Text = "Cancel";
            RegisterControl("cmdCancel", cmdCancel);
            root.Add(cmdCancel, 184, 256);
            InitializeTool();
        }
    }
}