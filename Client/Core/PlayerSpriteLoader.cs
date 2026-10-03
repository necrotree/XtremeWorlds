using System;
using System.IO;
using Eto.Drawing;

namespace XtremeWorlds.Client.UI
{
    internal static class PlayerSpriteLoader
    {
        // Sprite sheet layout: one 64px-tall row per sprite, with
        // up/down/left/right groups of three 48x64 frames.
        public static Bitmap Load(int sprite)
        {
            if (sprite < 0)
                return null;

            string[] candidates =
            {
                Path.Combine(AppContext.BaseDirectory, "gfx", "sprites.png"),
                Path.Combine(AppContext.BaseDirectory, "Assets", "gfx", "sprites.png")
            };

            string path = Array.Find(candidates, File.Exists);
            if (path is null)
                return null;

            using var sheet = new Bitmap(path);

            const int frameWidth = 48;
            const int frameHeight = 64;
            const int downFrameX = 3 * frameWidth;
            int y = sprite * frameHeight;

            if (sheet.Width < downFrameX + frameWidth || y + frameHeight > sheet.Height)
                return null;

            var frame = new Bitmap(frameWidth, frameHeight, PixelFormat.Format32bppRgba);
            using (var graphics = new Graphics(frame))
            {
                graphics.Clear(Colors.Transparent);
                graphics.DrawImage(
                    sheet,
                    new RectangleF(downFrameX, y, frameWidth, frameHeight),
                    new RectangleF(0, 0, frameWidth, frameHeight));
            }

            return frame;
        }
    }
}
