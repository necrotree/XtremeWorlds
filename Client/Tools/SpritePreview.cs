using System;
using System.IO;
using Eto.Drawing;
using Eto.Forms;

namespace XtremeWorlds.Client.Tools
{
    public class SpritePreview : Drawable
    {
        private Bitmap sheet;
        private RectangleF source;
        private string sheetName;
        public void SetFrame(string fileName, int x, int y, int width, int height)
        {
            if ((sheetName ?? "") != (fileName ?? ""))
            {
                sheet?.Dispose();
                sheet = null;
                sheetName = fileName;
                string imagePath = Path.Combine(AppContext.BaseDirectory, "tool-assets", fileName);
                if (File.Exists(imagePath))
                    sheet = new Bitmap(imagePath);
            }
            source = new RectangleF(x, y, width, height);
            Invalidate();
        }
        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            e.Graphics.FillRectangle(Colors.Black, new RectangleF(0f, 0f, Width, Height));
            if (sheet is null || source.Right > sheet.Width || source.Bottom > sheet.Height || source.Width <= 0f || source.Height <= 0f)
                return;
            e.Graphics.ImageInterpolation = ImageInterpolation.None;
            e.Graphics.DrawImage(sheet, source, new RectangleF(0f, 0f, Width, Height));
        }
        protected override void Dispose(bool disposing)
        {
            if (disposing)
                sheet?.Dispose();
            base.Dispose(disposing);
        }
    }
}