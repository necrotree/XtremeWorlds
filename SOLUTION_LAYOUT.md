# XtremeWorlds.sln

`XtremeWorlds.sln` is now the single solution entry point.

It contains:

- Client.Common (shared Eto.Forms UI)
- Client.Engine
- Client.Windows
- Client.Linux
- Client.macOS
- Server.Common
- Server.Windows
- Server.GTK
- Server.macOS
- SpacetimeDB.Module

Solution configurations are Windows, Linux, and macOS. The platform launchers only build in their matching configuration. Shared projects build in every configuration. The SpacetimeDB module is loaded in the solution but is not part of the normal solution build because it uses its own WASI/SpacetimeDB toolchain.

For Windows:

```powershell
.\build-windows.ps1
```

Or open `XtremeWorlds.sln` in Visual Studio and select `Debug | Windows`.
