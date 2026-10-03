using System;
using Eto.Forms;

namespace Server;

internal static class EtoProgram
{
    [STAThread]
    private static void Main()
    {
        var settings = ServerSettings.Load("appsettings.json");
        using var app = new Application(Eto.Platform.Detect);
        app.Run(new EtoServerForm(settings));
    }
}
