# Windows build fixes

This revision addresses the reported build failures:

- Client CS0006 missing `XtremeWorlds.Client.Engine.dll` / `XtremeWorlds.Client.Common.dll`: the Windows build now cleans stale outputs and builds Core -> Engine -> Windows explicitly so the actual dependency error is surfaced instead of cascading missing-metadata messages.
- MSB3277 `Microsoft.VisualBasic` conflict: demoted to an MSBuild message through shared `Directory.Build.props`, including nested SpacetimeDB/WASI builds.
- Locked server `apphost.exe`: the Windows server build stops old `Server` / `Server.Windows` processes before cleaning and rebuilding.
- Cross-platform Eto server worker: the background `Task.Run` is retained in `_runTask` rather than discarded.

From the integrated root, run `build-windows.ps1`. It builds Server first and then Client.
