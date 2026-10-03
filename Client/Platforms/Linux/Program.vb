Imports System
Imports Eto.Forms
Imports XtremeWorlds.Client.Forms
Imports XtremeWorlds.Client.Logic
Imports XtremeWorlds.Client.Engine.Runtime

Namespace XtremeWorlds.Client.Linux
    Friend Module Program
        <STAThread>
        Public Sub Main()
            Dim platform As New Eto.GtkSharp.Platform()
            Dim app As New Application(platform)
            app.Name = "XtremeWorlds"
            Dim runtime As New EngineGameClientRuntime()
            GameClientRuntime.Current = runtime
            app.Run(New frmMainMenu(runtime))
        End Sub
    End Module
End Namespace
