# XtremeWorlds

The project layout is ordered as **Client → Core → Server → Engine**, with **SpacetimeDb inside Server**.
These are sibling folders; the order describes the layout, not a circular dependency chain.

| Folder | Contents |
| --- | --- |
| Client | Blazor browser client, Windows host, game assets, menu image references, form definitions and client scripts |
| Core | Shared client forms, controllers and embedded UI assets |
| Server | Game server, platform hosts, configuration, scripts, SpacetimeDb module |
| Engine | Networking, FNA graphics and audio |

Build from this directory with the .NET 10 SDK: https://dotnet.microsoft.com/en-us/download/dotnet/10.0

```powershell
dotnet build XtremeWorlds.sln
```

Open the localhost URL printed by the app. Set `GameServer:Host` and `GameServer:Port`
in `Client/Blazor/appsettings.json` to the game server's address as seen by the Blazor host.
The browser uses interactive server rendering; each browser session owns its own TCP
connection to the game server. Login, registration, server alerts and character selection
use the existing Engine transport and game protocol. Full world rendering and editors
remain available in the Windows client.

Run the Windows client and game server:

```powershell
dotnet run --project Client\Platforms\Windows\Client.Windows.csproj
dotnet run --project Server\src\Server\Server.csproj
```

Install SpacetimeDB CLI:
https://spacetimedb.com/install
