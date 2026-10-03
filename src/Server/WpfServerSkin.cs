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
        menu.Background = PanelAlt;
        menu.Foreground = Gold;
        menu.BorderBrush = Bronze;
        menu.BorderThickness = new Thickness(1);
        menu.Padding = new Thickness(2);
        menu.FontFamily = new FontFamily("Rockwell");

        // Replace WPF's stock ContextMenu chrome completely.  The default
        // template reserves a check/icon gutter on the left and paints parts
        // of the popup white.  XtremeWorlds does not use icons here, so the
        // menu is a single full-width dark items host instead.
        var menuTemplate = new ControlTemplate(typeof(ContextMenu));
        var menuBorder = new FrameworkElementFactory(typeof(Border));
        menuBorder.SetBinding(Border.BackgroundProperty, new Binding("Background") { RelativeSource = RelativeSource.TemplatedParent });
        menuBorder.SetBinding(Border.BorderBrushProperty, new Binding("BorderBrush") { RelativeSource = RelativeSource.TemplatedParent });
        menuBorder.SetBinding(Border.BorderThicknessProperty, new Binding("BorderThickness") { RelativeSource = RelativeSource.TemplatedParent });
        menuBorder.SetBinding(Border.PaddingProperty, new Binding("Padding") { RelativeSource = RelativeSource.TemplatedParent });

        var menuHost = new FrameworkElementFactory(typeof(StackPanel));
        menuHost.SetValue(System.Windows.Controls.Panel.IsItemsHostProperty, true);
        menuBorder.AppendChild(menuHost);
        menuTemplate.VisualTree = menuBorder;
        menu.Template = menuTemplate;

        menu.Resources[typeof(MenuItem)] = CreateFlatContextMenuItemStyle();
    }

    private static Style CreateFlatContextMenuItemStyle()
    {
        var style = new Style(typeof(MenuItem));
        style.Setters.Add(new Setter(Control.BackgroundProperty, Button));
        style.Setters.Add(new Setter(Control.ForegroundProperty, Gold));
        style.Setters.Add(new Setter(Control.BorderBrushProperty, Bronze));
        style.Setters.Add(new Setter(Control.BorderThicknessProperty, new Thickness(1)));
        style.Setters.Add(new Setter(Control.FontFamilyProperty, new FontFamily("Rockwell")));
        style.Setters.Add(new Setter(Control.FontWeightProperty, FontWeights.SemiBold));
        style.Setters.Add(new Setter(Control.PaddingProperty, new Thickness(10, 5, 10, 5)));
        style.Setters.Add(new Setter(FrameworkElement.MarginProperty, new Thickness(1)));
        style.Setters.Add(new Setter(Control.HorizontalContentAlignmentProperty, HorizontalAlignment.Left));

        var template = new ControlTemplate(typeof(MenuItem));
        var root = new FrameworkElementFactory(typeof(Grid));

        var border = new FrameworkElementFactory(typeof(Border));
        border.Name = "ItemBorder";
        border.SetBinding(Border.BackgroundProperty, new Binding("Background") { RelativeSource = RelativeSource.TemplatedParent });
        border.SetBinding(Border.BorderBrushProperty, new Binding("BorderBrush") { RelativeSource = RelativeSource.TemplatedParent });
        border.SetBinding(Border.BorderThicknessProperty, new Binding("BorderThickness") { RelativeSource = RelativeSource.TemplatedParent });
        border.SetBinding(Border.PaddingProperty, new Binding("Padding") { RelativeSource = RelativeSource.TemplatedParent });

        var headerGrid = new FrameworkElementFactory(typeof(Grid));
        var header = new FrameworkElementFactory(typeof(ContentPresenter));
        header.SetBinding(ContentPresenter.ContentProperty, new Binding("Header") { RelativeSource = RelativeSource.TemplatedParent });
        header.SetBinding(ContentPresenter.ContentTemplateProperty, new Binding("HeaderTemplate") { RelativeSource = RelativeSource.TemplatedParent });
        header.SetBinding(ContentPresenter.HorizontalAlignmentProperty, new Binding("HorizontalContentAlignment") { RelativeSource = RelativeSource.TemplatedParent });
        header.SetValue(ContentPresenter.RecognizesAccessKeyProperty, true);
        headerGrid.AppendChild(header);
        border.AppendChild(headerGrid);
        root.AppendChild(border);

        var popup = new FrameworkElementFactory(typeof(Popup));
        popup.Name = "PART_Popup";
        popup.SetValue(Popup.PlacementProperty, PlacementMode.Right);
        popup.SetBinding(Popup.PlacementTargetProperty, new Binding { RelativeSource = RelativeSource.TemplatedParent });
        popup.SetValue(Popup.AllowsTransparencyProperty, true);
        popup.SetValue(UIElement.FocusableProperty, false);
        popup.SetBinding(Popup.IsOpenProperty, new Binding("IsSubmenuOpen") { RelativeSource = RelativeSource.TemplatedParent });

        var popupBorder = new FrameworkElementFactory(typeof(Border));
        popupBorder.SetValue(Border.BackgroundProperty, PanelAlt);
        popupBorder.SetValue(Border.BorderBrushProperty, Bronze);
        popupBorder.SetValue(Border.BorderThicknessProperty, new Thickness(1));
        popupBorder.SetValue(Border.PaddingProperty, new Thickness(2));

        var host = new FrameworkElementFactory(typeof(StackPanel));
        host.SetValue(System.Windows.Controls.Panel.IsItemsHostProperty, true);
        popupBorder.AppendChild(host);
        popup.AppendChild(popupBorder);
        root.AppendChild(popup);

        template.VisualTree = root;

        var highlighted = new Trigger { Property = MenuItem.IsHighlightedProperty, Value = true };
        highlighted.Setters.Add(new Setter(Border.BackgroundProperty, Selection, "ItemBorder"));
        template.Triggers.Add(highlighted);

        var disabled = new Trigger { Property = UIElement.IsEnabledProperty, Value = false };
        disabled.Setters.Add(new Setter(UIElement.OpacityProperty, 0.55));
        template.Triggers.Add(disabled);

        style.Setters.Add(new Setter(Control.TemplateProperty, template));
        return style;
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
