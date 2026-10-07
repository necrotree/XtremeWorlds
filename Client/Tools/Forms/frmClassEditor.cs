using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Tools;

namespace XtremeWorlds.Client.Tools
{
    public class frmClassEditor : ToolForm
    {
        public frmClassEditor() : base("class")
        {
            Title = "Class Editor";
            ClientSize = new Size(440, 520);
            var layout = new DynamicLayout() { Padding = 12, Spacing = new Size(8, 8) };
            foreach (var @field in ToolSchema.Fields("class"))
            {
                Control control;
                if (@field.Kind == "text")
                {
                    control = new TextBox();
                }
                else
                {
                    control = new Slider() { MinValue = @field.Minimum, MaxValue = @field.Maximum };
                }
                RegisterControl(@field.Control, control);
                var label = new Label() { Text = "0" };
                RegisterControl("lbl" + (@field.Control.StartsWith("scrl", StringComparison.Ordinal) ? @field.Control.Substring(4) : @field.Key), label);
                layout.AddRow(new Label() { Text = @field.Key }, control, label);
            }
            var ok = new Button() { Text = "Save" };
            var cancel = new Button() { Text = "Cancel" };
            RegisterControl("cmdOk", ok);
            RegisterControl("cmdCancel", cancel);
            layout.AddRow(null, ok, cancel);
            Content = layout;
            InitializeTool();
        }
    }
}