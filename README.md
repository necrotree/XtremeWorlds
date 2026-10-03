# XtremeWorlds

The project layout is ordered as **Client → Core → Server → Engine**, with **SpacetimeDb inside Server**.
These are sibling folders; the order describes the layout, not a circular dependency chain.

| Folder | Contents |
| --- | --- |
| Client | Blazor browser client, Windows host, game assets, menu image references, form definitions and client scripts |
| Core | Shared client forms, controllers and embedded UI assets |
| Server | Game server, platform hosts, configuration, scripts, SpacetimeDb module and legacy source archives |
| Engine | Networking, FNA graphics and audio |

Build from this directory with the .NET 10 SDK:

```powershell
dotnet build XtremeWorlds.sln
```

Run the browser client:

```powershell
dotnet run --project Client/Blazor/Client.Blazor.csproj
```

Open the localhost URL printed by the app. Set `GameServer:Host` and `GameServer:Port`
in `Client/Blazor/appsettings.json` to the game server's address as seen by the Blazor host.
The browser uses interactive server rendering; each browser session owns its own TCP
connection to the game server. Login, registration, server alerts and character selection
use the existing Engine transport and game protocol. Full world rendering and editors
remain available in the Windows client.

Run the Windows client and game server:

```powershell
dotnet run --project Client/Platforms/Windows/Client.Windows.csproj
dotnet run --project Server/src/Server/Server.csproj
```

The canonical module is in `Server/SpacetimeDb`. Publish it using `Server/scripts/setup-spacetimedb.ps1` or its shell
equivalent. Server builds copy the canonical module into the application output's
`spacetimedb` directory, excluding `bin` and `obj`. Builds no longer recreate source
copies under `Server/src/Server`.

Older nested server source copies are preserved under `Server/LegacySource` for reference.
The root solution and this README describe the current layout; archived solutions and
historical migration notes may describe earlier paths.

Validation: the root solution builds with zero errors (31 existing server warnings),
and the browser home page responds with HTTP 200. Live account/database operations
require a running game server and SpacetimeDB and have not been verified end to end.
