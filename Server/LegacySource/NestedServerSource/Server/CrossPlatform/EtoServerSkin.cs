using Eto.Drawing;
using Eto.Forms;

namespace Server;

internal static class EtoServerSkin
{
    public static readonly Color Window = Color.FromArgb(37, 20, 24);
    public static readonly Color Panel = Color.FromArgb(27, 14, 17);
    public static readonly Color Input = Color.FromArgb(18, 12, 13);
    public static readonly Color Gold = Color.FromArgb(224, 190, 118);
    public static readonly Color Bronze = Color.FromArgb(145, 100, 58);

    public static TextBox TextBox(bool readOnly = false)
    {
        var c = new TextBox { ReadOnly = readOnly, BackgroundColor = Input, TextColor = Gold, Font = new Font("Rockwell", 10) };
        return c;
    }

    public static TextArea TextArea(bool readOnly = true)
    {
        return new TextArea { ReadOnly = readOnly, BackgroundColor = Input, TextColor = Gold, Font = new Font("Monospace", 10) };
    }

    public static ListBox ListBox() => new() { BackgroundColor = Input, TextColor = Gold, Font = new Font("Rockwell", 10) };
}
