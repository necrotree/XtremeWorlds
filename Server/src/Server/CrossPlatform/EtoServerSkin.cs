using Eto.Drawing;
using Eto.Forms;

namespace Server;

// Palette shared with the browser client's new desert-themed account dialogs.
internal static class EtoServerSkin
{
    public static readonly Color Window = Color.FromArgb(108, 65, 41);
    public static readonly Color Panel = Color.FromArgb(190, 161, 109);
    public static readonly Color Input = Color.FromArgb(231, 212, 169);
    public static readonly Color Ink = Color.FromArgb(49, 32, 18);
    public static readonly Color Gold = Color.FromArgb(255, 240, 201);
    public static readonly Color Bronze = Color.FromArgb(73, 53, 28);
    public static readonly Color Green = Color.FromArgb(52, 104, 66);
    public static readonly Color Red = Color.FromArgb(124, 41, 41);

    public static TextBox TextBox(bool readOnly = false) => new()
    {
        ReadOnly = readOnly,
        BackgroundColor = Input,
        TextColor = Ink,
        Font = new Font("Georgia", 11)
    };

    public static TextArea TextArea(bool readOnly = true) => new()
    {
        ReadOnly = readOnly,
        BackgroundColor = Input,
        TextColor = Ink,
        Font = new Font("Monospace", 10)
    };

    public static ListBox ListBox() => new()
    {
        BackgroundColor = Input,
        TextColor = Ink,
        Font = new Font("Georgia", 11)
    };

    public static Button Button(string text, bool primary = true) => new()
    {
        Text = text,
        BackgroundColor = primary ? Green : Red,
        TextColor = Gold,
        Font = new Font("Georgia", 11, FontStyle.Bold)
    };

    public static Label Heading(string text) => new()
    {
        Text = text,
        TextColor = Gold,
        Font = new Font("Georgia", 21, FontStyle.Bold)
    };

    public static Label Subtitle(string text) => new()
    {
        Text = text,
        TextColor = Gold,
        Font = new Font("Georgia", 10, FontStyle.Bold)
    };
}
