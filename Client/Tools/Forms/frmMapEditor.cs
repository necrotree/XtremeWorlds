using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json.Nodes;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Tools;

namespace XtremeWorlds.Client.Tools
{
    public class frmMapEditor : ToolForm
    {
        private JsonObject working;
        private readonly Slider tileset = new Slider() { MinValue = 1, MaxValue = 9, Value = 1 };
        private readonly DropDown layer = new DropDown();
        private readonly DropDown mode = new DropDown();
        private readonly DropDown attributeLayer = new DropDown();
        private readonly NumericStepper data1 = new NumericStepper() { MinValue = 0d, MaxValue = int.MaxValue };
        private readonly NumericStepper data2 = new NumericStepper() { MinValue = 0d, MaxValue = int.MaxValue };
        private readonly NumericStepper data3 = new NumericStepper() { MinValue = 0d, MaxValue = int.MaxValue };
        private readonly TileCanvas palette;
        public event Action<int, string>? PreviewChanged;
        public int MapId => Definition?.Id ?? -1;
        private int anchorX;
        private int anchorY;
        private int brushX;
        private int brushY;
        private int brushWidth = 1;
        private int brushHeight = 1;
        private bool selecting;
        public frmMapEditor() : base("map")
        {
            Title = "Map Editor";
            ClientSize = new Size(520, 650);
            MinimumSize = new Size(470, 490);
            var layout = new DynamicLayout() { Padding = 10, Spacing = new Size(8, 8) };
            var name = new TextBox();
            RegisterControl("txtName", name);
            RegisterControl("scrlTileset", tileset);
            foreach (var item in MapEditing.Layers)
                layer.Items.Add(item);
            layer.SelectedIndex = 0;
            mode.Items.Add("Paint tiles");
            foreach (var item in new[] { "Walkable", "Blocked", "Warp", "Item", "NPC avoid", "Key", "Key open", "Heal", "Damage", "Door", "Sign", "Message", "Sprite", "NPC spawn", "Nudge" })
                mode.Items.Add(item);
            mode.SelectedIndex = 0;
            attributeLayer.Items.Add("Attributes 1");
            attributeLayer.Items.Add("Attributes 2");
            attributeLayer.SelectedIndex = 0;
            palette = new TileCanvas(this) { Size = new Size(384, 1024) };
            var scroll = new Scrollable() { Content = palette, Size = new Size(408, 400) };
            layout.AddRow(new Label() { Text = "Name" }, name, new Label() { Text = "Tileset" }, tileset);
            layout.AddRow(new Label() { Text = "Layer" }, layer, mode, attributeLayer);
            layout.AddRow(new Label() { Text = "Data 1" }, data1, new Label() { Text = "Data 2" }, data2, new Label() { Text = "Data 3" }, data3);
            layout.AddRow(scroll);
            layout.AddRow(new Label() { Text = "Select tiles here, then left-drag to paint or right-drag to erase in the game window." });
            var fill = new Button() { Text = "Fill layer" };
            fill.Click += (sender, args) =>
            {
                if (working is null) return;
                for (int y = 0; y < MapEditing.Height; y++)
                    for (int x = 0; x < MapEditing.Width; x++)
                        PaintAt(x, y, false, true, false);
                NotifyPreview();
            };
            var ok = new Button() { Text = "Save" };
            var cancel = new Button() { Text = "Cancel" };
            RegisterControl("cmdOk", ok);
            RegisterControl("cmdCancel", cancel);
            layout.AddRow(fill, null, ok, cancel);
            Content = layout;
            tileset.ValueChanged += (sender, args) =>
            {
                palette.LoadTileset(tileset.Value);
                palette.Invalidate();
            };
            InitializeTool();
        }
        protected override void LoadAdditional(JsonObject data)
        {
            working = (JsonObject)data.DeepClone();
            MapEditing.PreserveTilesets(working);
            palette.LoadTileset(tileset.Value);
            NotifyPreview();
        }
        protected override void StoreAdditional(JsonObject data)
        {
            data["Tiles"] = working["Tiles"].DeepClone();
            if (working["LayerTileset"] is not null)
                data["LayerTileset"] = working["LayerTileset"].DeepClone();
        }
        public void PaintAt(int x, int y, bool isErase, bool fill = false, bool publish = true)
        {
            if (working is null || x < 0 || y < 0 || x >= MapEditing.Width || y >= MapEditing.Height)
                return;
            if (mode.SelectedIndex == 0)
            {
                MapEditing.Paint(working, x, y, layer.SelectedIndex, brushX, brushY, fill ? 1 : brushWidth, fill ? 1 : brushHeight, tileset.Value, isErase);
            }
            else
            {
                MapEditing.Attribute(working, x, y, attributeLayer.SelectedIndex + 1, isErase ? 0 : mode.SelectedIndex - 1, isErase ? 0 : (int)Math.Round(data1.Value), isErase ? 0 : (int)Math.Round(data2.Value), isErase ? 0 : (int)Math.Round(data3.Value));
            }
            if (publish) NotifyPreview();
        }
        public void PublishPreview() => NotifyPreview();

        private void NotifyPreview()
        {
            if (working is not null && Definition is not null)
                PreviewChanged?.Invoke(Definition.Id, working.ToJsonString());
        }

        private class TileCanvas : Drawable
        {
            private readonly frmMapEditor owner;
            private readonly Dictionary<int, Bitmap> sheets = new Dictionary<int, Bitmap>();
            private int paletteSheet;
            public TileCanvas(frmMapEditor owner)
            {
                this.owner = owner;
                MouseDown += Down;
                MouseMove += MovePointer;
                MouseUp += (sender, args) => owner.selecting = false;
            }
            private Bitmap Sheet(int number)
            {
                if (number < 1 || number > 9)
                    return null;
                Bitmap bitmap = null;
                if (!sheets.TryGetValue(number, out bitmap))
                {
                    string imagePath = Path.Combine(AppContext.BaseDirectory, "tool-assets", "tiles" + number.ToString() + ".png");
                    if (!File.Exists(imagePath))
                        return null;
                    bitmap = new Bitmap(imagePath);
                    sheets[number] = bitmap;
                }
                return bitmap;
            }
            public void LoadTileset(int number)
            {
                paletteSheet = number;
                var bitmap = Sheet(number);
                if (bitmap is not null)
                    Height = bitmap.Height;
            }
            private void Down(object sender, MouseEventArgs args)
            {
                int x = (int)Math.Round(Math.Floor((double)(args.Location.X / 32f)));
                int y = (int)Math.Round(Math.Floor((double)(args.Location.Y / 32f)));
                {
                    if ((args.Buttons & MouseButtons.Primary) == 0)
                        return;
                    var bitmap = Sheet(paletteSheet);
                    if (bitmap is null || x < 0 || x >= 12 || y < 0 || y >= bitmap.Height / 32)
                        return;
                    owner.anchorX = x;
                    owner.anchorY = y;
                    owner.brushX = x;
                    owner.brushY = y;
                    owner.brushWidth = 1;
                    owner.brushHeight = 1;
                    owner.selecting = true;
                    Invalidate();
                }

            }
            private void MovePointer(object sender, MouseEventArgs args)
            {
                if ((args.Buttons & MouseButtons.Primary) == 0 && (args.Buttons & MouseButtons.Alternate) == 0)
                    return;
                int x = (int)Math.Round(Math.Floor((double)(args.Location.X / 32f)));
                int y = (int)Math.Round(Math.Floor((double)(args.Location.Y / 32f)));
                {
                    if (!owner.selecting)
                        return;
                    var bitmap = Sheet(paletteSheet);
                    if (bitmap is null)
                        return;
                    x = Math.Clamp(x, 0, 11);
                    y = Math.Clamp(y, 0, bitmap.Height / 32 - 1);
                    owner.brushX = Math.Min(x, owner.anchorX);
                    owner.brushY = Math.Min(y, owner.anchorY);
                    owner.brushWidth = Math.Abs(x - owner.anchorX) + 1;
                    owner.brushHeight = Math.Abs(y - owner.anchorY) + 1;
                    Invalidate();
                }

            }
            protected override void OnPaint(PaintEventArgs e)
            {
                base.OnPaint(e);
                e.Graphics.ImageInterpolation = ImageInterpolation.None;
                e.Graphics.FillRectangle(Colors.Black, new RectangleF(0f, 0f, Width, Height));
                {
                    var bitmap = Sheet(paletteSheet);
                    if (bitmap is not null)
                        e.Graphics.DrawImage(bitmap, 0f, 0f);
                    e.Graphics.DrawRectangle(Colors.Red, owner.brushX * 32, owner.brushY * 32, owner.brushWidth * 32, owner.brushHeight * 32);
                    return;
                }

            }
            protected override void Dispose(bool disposing)
            {
                if (disposing)
                {
                    foreach (var bitmap in sheets.Values)
                        bitmap.Dispose();
                }
                base.Dispose(disposing);
            }
        }
    }
}