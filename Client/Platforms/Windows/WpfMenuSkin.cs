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
        Style.Add<Form>("XtremeWorldsWindow", form =>
        {
            ApplyWhenLoaded(form, () =>
            {
                if (form.ControlObject is SW.Window window)
                {
                    window.Background = ImageBrush("frmMainMenu/background.png", SWM.Stretch.UniformToFill);
                }
            });
        });

        RegisterPanel("XtremeWorldsMainButtons", "frmMainMenu/main.png");
        RegisterPanel("XtremeWorldsBottomButtons", "frmMainMenu/exit.png");
        RegisterPanel("XtremeWorldsLoginPanel", "frmMainMenu/login.png");
        RegisterPanel("XtremeWorldsRegisterPanel", "frmMainMenu/register.png");
        RegisterPanel("XtremeWorldsCharactersPanel", "frmMainMenu/characters.png");
        RegisterPanel("XtremeWorldsNewCharacterPanel", "frmMainMenu/newchar.png");
        RegisterPanel("XtremeWorldsClassPanel", "frmMainMenu/classselection.png");
        RegisterPanel("XtremeWorldsClassButtons", "frmMainMenu/classbuttons.png");

        Style.Add<Button>("XtremeWorldsSkinButton", button =>
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

        Style.Add<TextBox>("XtremeWorldsSkinTextBox", box =>
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

        Style.Add<PasswordBox>("XtremeWorldsSkinPasswordBox", box =>
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

        Style.Add<Label>("XtremeWorldsSkinLabel", label =>
        {
            label.TextColor = Eto.Drawing.Color.FromArgb(255, 229, 151);
            label.Font = new Eto.Drawing.Font("Rockwell", 9);
        });

        Style.Add<ListBox>("XtremeWorldsTransparentList", list =>
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

        Style.Add<RadioButton>("XtremeWorldsSkinRadio", radio =>
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

        Style.Add<RadioButton>("XtremeWorldsClassChoice", radio =>
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

    private static void RegisterPanel(string style, string resource)
    {
        Style.Add<Panel>(style, panel =>
        {
            ApplyWhenLoaded(panel, () => SetPanelBackground(panel, resource));
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
