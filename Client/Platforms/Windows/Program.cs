using System;
using Eto.Forms;
using XtremeWorlds.Client.Forms;
using XtremeWorlds.Client.Engine.Runtime;
using XtremeWorlds.Client.Logic;

namespace XtremeWorlds.Client.Windows;

internal static class Program
{
    [STAThread]
    public static void Main()
    {
        var app = new Eto.Forms.Application(new Eto.Wpf.Platform())
        {
            Name = "XtremeWorlds"
        };

        // Register the XtremeWorlds skin against real Eto.Forms controls.
        // WPF is only the renderer; Core stays platform-neutral Eto.Forms.
        WpfMenuSkin.Register();

        // Eto.Forms 2.12 theme system.  System follows the Windows light/dark
        // setting and can be changed at runtime with Themes.Light/Themes.Dark.
        app.Theme = Themes.System;

        var runtime = new EngineGameClientRuntime();
        GameClientRuntime.Current = runtime;
        app.Run(new frmMainMenu(runtime));
    }
}
