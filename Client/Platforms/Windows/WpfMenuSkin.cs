using System;
using System.Collections.Generic;
using Eto;
using Eto.Forms;
using XtremeWorlds.Client.UI;
using SW = System.Windows;
using SWC = System.Windows.Controls;
using SWM = System.Windows.Media;

namespace XtremeWorlds.Client.Windows;

internal static class WpfMenuSkin
{
    private static readonly List<Eto.Drawing.Image> _images = new();

    public static void Register()
    {
        Style.Add<Form>("Window", form =>
        {
            ApplyWhenLoaded(form, () =>
            {
                if (form.ControlObject is SW.Window window)
                {
                    window.Background = ImageBrush("frmMainMenu/background.png", SWM.Stretch.UniformToFill);
                    ScaleScene(window, 950, 700);
                    FitWindow(form, window);
                    window.ContentRendered += (_, _) => FitWindow(form, window);
                }
            });
        });

        Style.Add<Form>("GameWindow", form => ApplyWhenLoaded(form, () =>
        {
            if (form.ControlObject is SW.Window window)
            {
                window.Background = SWM.Brushes.Black;
                if (form.Content?.ControlObject is SWC.Panel panel)
                    panel.Background = ImageBrush("frmMainGame/frmMainGame.jpg", SWM.Stretch.Fill);
                ScaleScene(window, 950, 700);
                FitWindow(form, window);
                window.ContentRendered += (_, _) => FitWindow(form, window);
            }
        }));

        RegisterPanel("MainButtons", "frmMainMenu/imgMainMenu.png");
        RegisterPanel("BottomButtons", "frmMainMenu/imgBottomButtons.png", 10);

        Style.Add<Panel>("PageHost", panel =>
        {
            ApplyWhenLoaded(panel, () =>
            {
                if (panel.ControlObject is SW.FrameworkElement native)
                    native.ClipToBounds = true;
            });
        });
        RegisterPanel("LoginPanel", "frmMainMenu/login.png");
        RegisterPanel("RegisterPanel", "frmMainMenu/register.png");
        RegisterPanel("CharactersPanel", "frmMainMenu/characters.png");
        RegisterPanel("NewCharacterPanel", "frmMainMenu/newchar.png");
        RegisterPanel("ClassPanel", "frmMainMenu/classselection.png");
        RegisterPanel("ClassButtons", "frmMainMenu/classbuttons.png");

        Style.Add<Dialog>("AlertWindow", dialog =>
        {
            ApplyWhenLoaded(dialog, () =>
            {
                if (dialog.ControlObject is SW.Window window)
                {
                    window.Background = ImageBrush("frmAlert/alert.png", SWM.Stretch.Fill);
                    window.BorderThickness = new SW.Thickness(0);
                }
            });
        });

        RegisterImageButton("AlertOkButton", "frmAlert/ok.png");
        RegisterImageButton("AlertYesButton", "frmAlert/yes.png");
        RegisterImageButton("AlertNoButton", "frmAlert/no.png");

        Style.Add<TextArea>("AlertMessage", area =>
        {
            ApplyWhenLoaded(area, () =>
            {
                if (area.ControlObject is SWC.TextBox native)
                {
                    native.Background = SWM.Brushes.Transparent;
                    native.BorderBrush = SWM.Brushes.Transparent;
                    native.BorderThickness = new SW.Thickness(0);
                    native.Foreground = new SWM.SolidColorBrush(SWM.Color.FromRgb(238, 216, 151));
                    native.FontFamily = new SWM.FontFamily("Rockwell");
                    native.FontSize = 12;
                    native.Padding = new SW.Thickness(2);
                    native.FocusVisualStyle = null;
                }
            });
        });

        Style.Add<TextBox>("AlertInput", box =>
        {
            ApplyWhenLoaded(box, () =>
            {
                if (box.ControlObject is SWC.TextBox native)
                {
                    native.Background = new SWM.SolidColorBrush(SWM.Color.FromArgb(150, 48, 20, 23));
                    native.BorderBrush = new SWM.SolidColorBrush(SWM.Color.FromRgb(116, 102, 73));
                    native.Foreground = new SWM.SolidColorBrush(SWM.Color.FromRgb(238, 216, 151));
                    native.CaretBrush = native.Foreground;
                    native.FontFamily = new SWM.FontFamily("Rockwell");
                    native.FontSize = 12;
                }
            });
        });

        Style.Add<Button>("SkinButton", button =>
        {
            ApplyWhenLoaded(button, () =>
            {
                if (button.ControlObject is SWC.Button native)
                {
                    native.Background = SWM.Brushes.Transparent;
                    native.BorderBrush = SWM.Brushes.Transparent;
                    native.BorderThickness = new SW.Thickness(0);
                    native.Padding = new SW.Thickness(0);
                    native.Opacity = 0.01;
                    native.FocusVisualStyle = null;
                }
            });
        });

        Style.Add<TextBox>("SkinTextBox", box =>
        {
            ApplyWhenLoaded(box, () =>
            {
                if (box.ControlObject is SWC.TextBox native)
                {
                    native.Background = SWM.Brushes.Transparent;
                    native.BorderBrush = SWM.Brushes.Transparent;
                    native.BorderThickness = new SW.Thickness(0);
                    native.Padding = new SW.Thickness(2, 0, 2, 0);
                    native.Foreground = new SWM.SolidColorBrush(SWM.Color.FromRgb(255, 229, 151));
                    native.CaretBrush = native.Foreground;
                    native.FontFamily = new SWM.FontFamily("Rockwell");
                    native.FontSize = 12;
                }
            });
        });

        Style.Add<PasswordBox>("SkinPasswordBox", box =>
        {
            ApplyWhenLoaded(box, () =>
            {
                if (box.ControlObject is SWC.PasswordBox native)
                {
                    native.Background = SWM.Brushes.Transparent;
                    native.BorderBrush = SWM.Brushes.Transparent;
                    native.BorderThickness = new SW.Thickness(0);
                    native.Padding = new SW.Thickness(2, 0, 2, 0);
                    native.Foreground = new SWM.SolidColorBrush(SWM.Color.FromRgb(255, 229, 151));
                    native.CaretBrush = native.Foreground;
                    native.FontFamily = new SWM.FontFamily("Rockwell");
                    native.FontSize = 12;
                }
            });
        });

        Style.Add<Label>("SkinLabel", label =>
        {
            label.TextColor = Eto.Drawing.Color.FromArgb(255, 229, 151);
            label.Font = new Eto.Drawing.Font("Rockwell", 9);
        });

        Style.Add<ListBox>("TransparentList", list =>
        {
            ApplyWhenLoaded(list, () =>
            {
                if (list.ControlObject is SWC.ListBox native)
                {
                    native.Background = SWM.Brushes.Transparent;
                    native.BorderBrush = SWM.Brushes.Transparent;
                    native.BorderThickness = new SW.Thickness(0);
                    native.Opacity = 0.01;
                    native.FocusVisualStyle = null;
                }
            });
        });

        Style.Add<RadioButton>("SkinRadio", radio =>
        {
            ApplyWhenLoaded(radio, () =>
            {
                if (radio.ControlObject is SWC.RadioButton native)
                {
                    native.Background = SWM.Brushes.Transparent;
                    native.BorderBrush = SWM.Brushes.Transparent;
                    native.Opacity = 0.01;
                    native.FocusVisualStyle = null;
                }
            });
        });

        Style.Add<RadioButton>("ClassChoice", radio =>
        {
            ApplyWhenLoaded(radio, () =>
            {
                if (radio.ControlObject is SWC.RadioButton native)
                {
                    native.Background = SWM.Brushes.Transparent;
                    native.BorderBrush = SWM.Brushes.Transparent;
                    native.Opacity = 0.01;
                    native.FocusVisualStyle = null;
                }
            });
        });
    }

    private static void ScaleScene(SW.Window window, double width, double height)
    {
        if (window.Content is not SW.FrameworkElement content || content is SWC.Viewbox) return;
        window.Content = null;
        content.Width = width;
        content.Height = height;
        content.ClipToBounds = true;
        window.Content = new SWC.Viewbox { Stretch = SWM.Stretch.Uniform, Child = content };
    }

    private static void FitWindow(Form form, SW.Window window)
    {
        // Eto screen coordinates and WPF window dimensions are both logical units.
        // Leave room for the taskbar and window frame at high display scaling.
        var area = form.Screen.WorkingArea;
        var availableWidth = Math.Max(1, area.Width - 24);
        var availableHeight = Math.Max(1, area.Height - 24);
        var width = double.IsNaN(window.Width) ? 966 : window.Width;
        var height = double.IsNaN(window.Height) ? 739 : window.Height;
        var scale = Math.Min(1, Math.Min(availableWidth / width, availableHeight / height));
        window.MinWidth = Math.Min(window.MinWidth, availableWidth);
        window.MinHeight = Math.Min(window.MinHeight, availableHeight);
        window.Width = width * scale;
        window.Height = height * scale;
        window.WindowStartupLocation = SW.WindowStartupLocation.Manual;
        window.Left = area.X + (area.Width - window.Width) / 2;
        window.Top = area.Y + (area.Height - window.Height) / 2;
    }

    private static void RegisterImageButton(string style, string resource)
    {
        Style.Add<Button>(style, button =>
        {
            ApplyWhenLoaded(button, () =>
            {
                if (button.ControlObject is SWC.Button native)
                {
                    native.Background = ImageBrush(resource, SWM.Stretch.Fill);
                    native.BorderBrush = SWM.Brushes.Transparent;
                    native.BorderThickness = new SW.Thickness(0);
                    native.Padding = new SW.Thickness(0);
                    native.FocusVisualStyle = null;
                    native.HorizontalContentAlignment = SW.HorizontalAlignment.Stretch;
                    native.VerticalContentAlignment = SW.VerticalAlignment.Stretch;
                }
            });
        });
    }

    private static void RegisterPanel(string style, string resource, double translateY = 0)
    {
        Style.Add<Panel>(style, panel =>
        {
            ApplyWhenLoaded(panel, () =>
            {
                SetPanelBackground(panel, resource);
                if (translateY != 0 && panel.ControlObject is SW.FrameworkElement native)
                    native.RenderTransform = new SWM.TranslateTransform(0, translateY);
            });
        });
    }

    private static void SetPanelBackground(Panel panel, string resource)
    {
        var brush = ImageBrush(resource, SWM.Stretch.Fill);

        switch (panel.ControlObject)
        {
            case SWC.Border border:
                border.Background = brush;
                break;
            case SWC.Panel nativePanel:
                nativePanel.Background = brush;
                break;
            case SWC.Control control:
                control.Background = brush;
                break;
        }
    }

    private static SWM.ImageBrush ImageBrush(string resource, SWM.Stretch stretch)
    {
        var image = AssetLoader.LoadImage(resource)
            ?? throw new InvalidOperationException($"Unable to load embedded menu asset '{resource}'.");
        _images.Add(image);

        if (image.ControlObject is not SWM.ImageSource source)
            throw new InvalidOperationException($"Menu asset '{resource}' did not produce a WPF ImageSource.");

        return new SWM.ImageBrush(source)
        {
            Stretch = stretch,
            AlignmentX = SWM.AlignmentX.Center,
            AlignmentY = SWM.AlignmentY.Center
        };
    }

    private static void ApplyWhenLoaded(Control control, Action action)
    {
        var applied = false;
        void ApplyOnce()
        {
            if (applied) return;
            applied = true;
            action();
        }

        control.Load += (_, _) => ApplyOnce();
        if (control.Loaded)
            ApplyOnce();
    }
}
