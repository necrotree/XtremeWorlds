using System;
using System.Windows;

namespace Server;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        var settings = ServerSettings.Load("appsettings.json");
        var app = new Application
        {
            ShutdownMode = ShutdownMode.OnMainWindowClose
        };

        app.Run(new ServerForm(settings));
    }
}
