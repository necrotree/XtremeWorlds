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
                    window.Background = ImageBrush("frmMainMenu/menu.png", SWM.Stretch.UniformToFill);
                }
            });
        });

        RegisterPanel("MainButtons", "frmMainMenu/main.png");
        RegisterPanel("BottomButtons", "frmMainMenu/exit.png", 10);

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
