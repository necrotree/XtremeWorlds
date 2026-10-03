# Building the server

Open `XtremeWorlds.Server.sln`.

Select the solution platform:
- `Windows` for the WPF server UI
- `GTK` for Linux/GTK
- `macOS` for the Eto macOS UI

Do not open or build an old `src/Server/Server.csproj`; the fixed package intentionally has no such project.
The shared game/network/database code lives in `src/Server/Server.Common.csproj`.

SpacetimeDB is not probed at startup by default. The TCP game server starts even when
`http://127.0.0.1:3000` is not running. Set `ProbeSpacetimeOnStartup` or
`RequireSpacetimeDb` to `true` in `appsettings.json` only when wanted.
