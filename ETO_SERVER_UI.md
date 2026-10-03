# Eto.Forms server UI

The Server project is a Windows Eto.Forms application backed by Eto.Platform.Wpf 2.12.

Startup: `src/Server/Program.cs`
Main form: `src/Server/ServerForm.cs`
Server engine: `src/Server/ServerHost.cs`

The form provides Start/Stop controls, current status, player count, TCP settings, and a live server log. `ServerHost` runs off the UI thread and posts log/player updates back through Eto's application dispatcher.
