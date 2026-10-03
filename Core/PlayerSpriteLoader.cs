using System;
using System.IO;
using Eto.Drawing;

namespace XtremeWorlds.Client.UI
{
    internal static class PlayerSpriteLoader
    {
        // Each row has up, down, left, right groups of three 48x64 frames.
        public static Bitmap Load(int sprite)
        {
            if (sprite < 0) return null;
            string path = Path.Combine(AppContext.BaseDirectory, "gfx", "sprites.png");
            if (!File.Exists(path)) return null;
            using var sheet = new Bitmap(path);
            int y = sprite * 64;
            const int downFrameX = 3 * 48;
            if (sheet.Width < downFrameX + 48 || y + 64 > sheet.Height) return null;
            var frame = new Bitmap(48, 64, PixelFormat.Format32bppRgba);
            using (var graphics = new Graphics(frame))
            {
                graphics.Clear(Colors.Transparent);
                graphics.DrawImage(sheet, new RectangleF(downFrameX, y, 48, 64), new RectangleF(0, 0, 48, 64));
            }
            return frame;
        }
    }
}
