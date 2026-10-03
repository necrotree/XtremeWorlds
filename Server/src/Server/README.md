# XtremeWorlds Server — .NET 10 + Mirror TCP + SpacetimeDB

This server is the C#/.NET 10 modernization of the original TwinBasic/VB server.

## UI platforms

The server now uses the same platform-project layout idea as the client:

- `Platforms/Windows/Server.Windows.csproj` — native WPF, TwinBasic-style layout and client theme.
- `Platforms/GTK/Server.GTK.csproj` — Eto.Forms + GTK 3 for Linux.
- `Platforms/macOS/Server.macOS.csproj` — Eto.Forms + Mac64 for macOS.
- `src/Server/Server.Common.csproj` — shared networking, game, database, logging, and bug-report code.

Open `XtremeWorlds.Server.sln` and select Windows, GTK, or macOS. See `PLATFORM_UI.md` for command-line launch options.

## Server features carried over

- File / Database / Log menus
- Chat, Bug Reports, and Game Information pages
- Players Online and Accounts Online
- Player right-click menu: Warn, Kick, Ban, Set Access 0-4
- Script Editor
- Persistent daily server logs under `logs/`
- Persistent bug-report logs under `logs/bugs-YYYY-MM-DD.log`
- MirrorNetworking Telepathy TCP transport
- SpacetimeDB-backed accounts/content

## SpacetimeDB offline behavior

A missing local SpacetimeDB service no longer kills the server with an `HttpRequestException`. With the default `RequireSpacetimeDb: false`, the TCP server starts and logs a clear warning. Database-backed actions become usable once SpacetimeDB is available. Set `RequireSpacetimeDb` to `true` for fail-fast startup.

The original TwinBasic sources are preserved under `LegacySource/`.

## Important: clean extraction
Extract this archive into a NEW empty folder. Do not copy it over an older Server folder.
If an older copy already produced duplicate-definition errors such as `Server\src\Server\src\Server`, run:

```powershell
.\scripts\clean-duplicate-source.ps1
```

The Windows server no longer contacts SpacetimeDB on startup by default. `ProbeSpacetimeOnStartup` is false and `RequireSpacetimeDb` is false in `appsettings.json`, so a stopped service at `127.0.0.1:3000` will not prevent the TCP game server from starting.
