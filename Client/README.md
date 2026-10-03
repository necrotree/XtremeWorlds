# XtremeWorlds Eto/FNA client

Cross-platform VB.NET/Eto conversion of the XtremeWorlds twinBASIC client.

## Current stack

- UI/forms: Eto.Forms 2.12
- Windows UI backend: Eto.Platform.Wpf 2.12 with `Themes.System`
- Linux UI backend: Eto.Platform.Gtk 2.12
- macOS UI backend: Eto.Platform.macOS 2.12
- game graphics: FNA
- sound/music: FAudio through FNA Audio/Media
- TCP networking: Mirror's standalone Telepathy transport

The original twinBASIC menu art is preserved as a skin over real Eto controls. The new uploaded wide balloon-city image is the main-menu backdrop.

See `ENGINE_MIGRATION.md` for the engine changes and protocol compatibility note.

## Windows

Open `Client.Windows.sln` or run:

```powershell
./build-windows.ps1
```

The Windows project is x64 and includes the supplied XtremeWorlds icon.

## Important networking compatibility

The client now uses Mirror/Telepathy message framing. The server transport must be converted to the same framing before it can communicate with this client. The old raw Winsock server protocol is not byte-for-byte compatible with Telepathy framing.

## Legacy code

`LegacySource/` is kept for comparison/continued migration only and is excluded from all compiled projects.


## Client TCPNoDelay / compile fixes

- Telepathy client now explicitly sets `NoDelay = true` before connecting.
- `EngineGameClientRuntime.MenuState` switch cases now fully qualify the `XtremeWorlds.Client.Logic.MenuState` enum to avoid the method/type name collision.
- Eto menu hiding uses `Form.Visible = false` instead of the nonexistent `Form.Hide()`.
- Main-menu XtremeWorlds logo top spacer increased from 28 to 38 pixels.
