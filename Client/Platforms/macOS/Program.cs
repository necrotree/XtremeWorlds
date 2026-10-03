using System;
using Eto.Forms;
using XtremeWorlds.Client.Engine.Runtime;
using XtremeWorlds.Client.Forms;
using XtremeWorlds.Client.Logic;

namespace XtremeWorlds.Client.macOS
{
    internal static class Program
    {
        [STAThread]
        public static void Main()
        {
            var platform = new Eto.Mac.Platform();
            var app = new Application(platform);
            app.Name = "XtremeWorlds";
            var runtime = new EngineGameClientRuntime();
            GameClientRuntime.Current = runtime;
            app.Run(new frmMainMenu(runtime));
        }
    }
}