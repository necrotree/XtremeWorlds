using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Controls.Primitives;
using System.Windows.Data;

namespace Server;

internal static class WpfServerSkin
{
    public static readonly Brush Window = Brush(20, 11, 13);
    public static readonly Brush Panel = Brush(43, 22, 25);
    public static readonly Brush PanelAlt = Brush(52, 25, 29);
    public static readonly Brush Input = Brush(31, 17, 19);
    public static readonly Brush Gold = Brush(255, 229, 151);
    public static readonly Brush MutedGold = Brush(205, 183, 127);
    public static readonly Brush Bronze = Brush(116, 102, 73);
    public static readonly Brush Button = Brush(67, 33, 37);
    public static readonly Brush Selection = Brush(91, 54, 57);
    public static readonly Brush MenuBar = Brushes.White;
    public static readonly Brush MenuText = Brushes.Black;

    public static void Apply(Window window)
    {
        window.Background = Window;
        window.Foreground = Gold;
        window.FontFamily = new FontFamily("Rockwell");
    }

    public static Button MakeButton(string text, double minWidth = 86)
    {
        return new Button
        {
            Content = text,
            MinWidth = minWidth,
            MinHeight = 28,
            Margin = new Thickness(3, 0, 3, 0),
            Padding = new Thickness(10, 3, 10, 3),
            Background = Button,
            Foreground = Gold,
            BorderBrush = Bronze,
            BorderThickness = new Thickness(1),
            FontFamily = new FontFamily("Rockwell"),
            FontWeight = FontWeights.SemiBold
        };
    }

    public static TextBox MakeTextBox(bool readOnly = false)
    {
        return new TextBox
        {
            IsReadOnly = readOnly,
            Background = Input,
            Foreground = Gold,
            BorderBrush = Bronze,
            BorderThickness = new Thickness(1),
            CaretBrush = Gold,
            SelectionBrush = Selection,
            Padding = new Thickness(5, 3, 5, 3),
            FontFamily = new FontFamily("Rockwell")
        };
    }

    public static ListBox MakeListBox()
    {
        return new ListBox
        {
            Background = Input,
            Foreground = Gold,
            BorderBrush = Bronze,
            BorderThickness = new Thickness(1),
            FontFamily = new FontFamily("Rockwell")
        };
    }

    public static GroupBox MakeGroup(string header, UIElement content)
    {
        return new GroupBox
        {
            Header = header,
            Content = content,
            Foreground = Gold,
            Background = Panel,
            BorderBrush = Bronze,
            BorderThickness = new Thickness(1),
            Padding = new Thickness(7),
            Margin = new Thickness(4)
        };
    }

    public static void StyleMenu(Menu menu)
    {
        menu.Background = MenuBar;
        menu.Foreground = MenuText;
        menu.FontFamily = new FontFamily("Rockwell");

        var itemStyle = new Style(typeof(MenuItem));
        itemStyle.Setters.Add(new Setter(Control.BackgroundProperty, MenuBar));
        itemStyle.Setters.Add(new Setter(Control.ForegroundProperty, MenuText));
        itemStyle.Setters.Add(new Setter(Control.FontFamilyProperty, new FontFamily("Rockwell")));
        menu.Resources[typeof(MenuItem)] = itemStyle;

        var separatorStyle = new Style(typeof(Separator));
        separatorStyle.Setters.Add(new Setter(Control.BackgroundProperty, Brush(210, 210, 210)));
        menu.Resources[typeof(Separator)] = separatorStyle;
    }


    public static void StylePlayerContextMenu(ContextMenu menu)
    {
        // Keep WPF's native popup and MenuItem templates for reliable mouse,
        // submenu and keyboard behavior. Use a clean, light menu palette that
        // contrasts with the dark server window instead of bordered dark rows.
        var surface = Brushes.White;
        var text = Brush(32, 32, 36);
        menu.Background = surface;
        menu.Foreground = text;
        menu.BorderBrush = Brush(206, 206, 211);
        menu.BorderThickness = new Thickness(1);
        menu.Padding = new Thickness(3);
        menu.FontFamily = new FontFamily("Segoe UI");
        menu.FontSize = 13;

        var itemStyle = new Style(typeof(MenuItem));
        itemStyle.Setters.Add(new Setter(Control.BackgroundProperty, surface));
        itemStyle.Setters.Add(new Setter(Control.ForegroundProperty, text));
        itemStyle.Setters.Add(new Setter(Control.FontFamilyProperty, new FontFamily("Segoe UI")));
        itemStyle.Setters.Add(new Setter(Control.FontSizeProperty, 13.0));
        itemStyle.Setters.Add(new Setter(Control.PaddingProperty, new Thickness(9, 5, 12, 5)));
        itemStyle.Setters.Add(new Setter(Control.MinHeightProperty, 28.0));
        menu.Resources[typeof(MenuItem)] = itemStyle;
    }

    public static void StyleTabs(TabControl tabs)
    {
        tabs.Background = Panel;
        tabs.Foreground = Gold;
        tabs.BorderBrush = Bronze;
        tabs.FontFamily = new FontFamily("Rockwell");
    }

    private static SolidColorBrush Brush(byte r, byte g, byte b)
    {
        var brush = new SolidColorBrush(Color.FromRgb(r, g, b));
        brush.Freeze();
        return brush;
    }
}
