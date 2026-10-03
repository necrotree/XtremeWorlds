# Server UI platform switch

The server now follows the same platform-project idea as the client. All gameplay/network/database code lives in `src/Server/Server.Common.csproj`, while each UI is a thin platform front end.

## Visual Studio / Rider

Open `XtremeWorlds.Server.sln` and choose the solution platform:

- **Windows** → `Platforms/Windows/Server.Windows.csproj` — native WPF, TwinBasic-style layout and client theme.
- **GTK** → `Platforms/GTK/Server.GTK.csproj` — Eto.Forms + GTK 3 for Linux.
- **macOS** → `Platforms/macOS/Server.macOS.csproj` — Eto.Forms + Mac64 for macOS.

Set the matching platform project as the startup project when debugging. Only that executable is mapped to build for its solution platform; `Server.Common` is shared by all three.

## One-command launcher

PowerShell:

`./scripts/run-server-platform.ps1 -UI Windows`

`./scripts/run-server-platform.ps1 -UI GTK`

`./scripts/run-server-platform.ps1 -UI macOS`

Bash:

`./scripts/run-server-platform.sh GTK`

`./scripts/run-server-platform.sh macOS`

GTK requires GTK 3 on the host system.

## SpacetimeDB startup behavior

`RequireSpacetimeDb` defaults to `false`. If `http://127.0.0.1:3000` is not running, the server now logs a short warning and still starts its TCP listener instead of dumping an `HttpRequestException` and stopping. Database-backed account/content operations remain unavailable until SpacetimeDB is running.

Set `RequireSpacetimeDb` to `true` in `appsettings.json` if you want the old fail-fast behavior. `SpacetimeConnectTimeoutSeconds` controls the initial connection timeout.
