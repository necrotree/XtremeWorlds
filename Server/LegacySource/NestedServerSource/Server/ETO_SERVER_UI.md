# Server desktop UI

The Windows server shell uses native WPF to match the TwinBasic `frmServer` layout as closely as possible. Linux and macOS use a shared Eto.Forms front end backed by GTK 3 and Mac64 respectively.

Shared engine: `src/Server/Server.Common.csproj`

Windows UI:
- `Platforms/Windows/Server.Windows.csproj`
- `src/Server/ServerForm.cs`
- `src/Server/ScriptEditorForm.cs`
- `src/Server/WpfServerSkin.cs`

GTK/macOS UI:
- `Platforms/GTK/Server.GTK.csproj`
- `Platforms/macOS/Server.macOS.csproj`
- `src/Server/CrossPlatform/`

All front ends expose the Chat, Bug Reports, Game Information, Database, Log, Script Editor, and player-management functions.
