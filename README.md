# XtremeWorlds

XtremeWorlds is a 2D MMORPG maker inspired by the classic PlayerWorlds experience. This branch contains the modern **C# / .NET 10** client and server, desktop interfaces, a Blazor browser client, and SpacetimeDB persistence integration.

The default development branch is `main`. The `classic` branch contains the twinBASIC and legacy Visual Basic 6 projects.

## What's included

- Desktop client launchers for Windows, Linux, and macOS, with shared Eto.Forms interfaces and game engine code.
- A multiplayer server using MirrorNetworking's Telepathy TCP transport.
- A Blazor client using interactive server components to connect browser sessions to the game server.
- A C# SpacetimeDB module and HTTP database integration.
- Executable regression checks for game loops, browser flows, world scenes, moderation, and transport behavior.

## Repository layout

| Path | Purpose |
| --- | --- |
| `XtremeWorlds.sln` | Main client/server solution |
| `Client/Core/` | Shared desktop client interface |
| `Client/Engine/` | Desktop client engine project |
| `Client/Platforms/` | Windows, Linux, and macOS desktop launchers |
| `Client/Blazor/` | ASP.NET Core Blazor browser client |
| `Core/`, `Engine/` | Additional shared interface assets and engine code used by the browser client and checks |
| `Server/src/Server/` | Server game, networking, database, and interface source |
| `Server/Platforms/` | Server platform launchers used by the main solution |
| `Server/appsettings.json` | Configuration copied by the solution's server launchers |
| `SpacetimeDb/` | Database module and its separate toolchain configuration |
| `Tests/` | Regression check applications |

There are also older or parallel project layouts under `src/` and `Platforms/`. Use the paths referenced by `XtremeWorlds.sln` when working on the main applications.

## Quick start on Windows

Install a .NET 10 SDK. Desktop Windows projects target `net10.0-windows` and use WPF; build and run those launchers on Windows. Package restore requires access to the configured NuGet feeds.

```powershell
git clone --branch main https://github.com/necrotree/XtremeWorlds.git
cd XtremeWorlds

dotnet build .\Server\Platforms\Windows\Server.Windows.csproj -c Debug
dotnet build .\Client\Platforms\Windows\Client.Windows.csproj -c Debug
```

Start the server first:

```powershell
dotnet run --project .\Server\Platforms\Windows\Server.Windows.csproj -c Debug --no-build
```

Keep it running and launch the desktop client from a second terminal:

```powershell
dotnet run --project .\Client\Platforms\Windows\Client.Windows.csproj -c Debug --no-build
```

Use matching client and server builds. Telepathy uses framed TCP messages; an unmodified legacy Winsock client is not compatible with this transport.

You can also open `XtremeWorlds.sln` in your IDE and select the appropriate platform launcher. The current solution defines `Debug | Any CPU` and `Release | Any CPU`, with the Windows client mapped to x64. Building individual launchers avoids building the other desktop platforms.

## Browser client

Run the game server, then start the Blazor application:

```powershell
dotnet run --project .\Client\Blazor\Client.Blazor.csproj --launch-profile http
```

The HTTP launch profile uses `http://localhost:5106`. The HTTPS profile uses `https://localhost:7104` and requires a trusted development certificate.

Set `GameServer:Host` and `GameServer:Port` in [`Client/Blazor/appsettings.json`](Client/Blazor/appsettings.json). The supplied values are `127.0.0.1` and `7234`. The Blazor application connects to the TCP game server from its host process, so the address must be reachable from the machine running Blazor.

## Server configuration

The solution's server platform projects copy [`Server/appsettings.json`](Server/appsettings.json) to their output folders. Configure that file before building, and keep the generated configuration with the executable when distributing a build. Parallel server projects may copy the root `appsettings.json` instead; check the project you run.

| Setting | Supplied value | Purpose |
| --- | --- | --- |
| `Port` | `7234` | Game server TCP port |
| `MaxPlayers` | `100` | Player limit |
| `TickRate` | `60` | Server tick rate |
| `TcpNoDelay` | `true` | TCP latency setting |
| `SpacetimeUri` | `http://127.0.0.1:3000` | Database endpoint |
| `SpacetimeDatabase` | `xtremeworlds` | Database name |
| `RequireSpacetimeDb` | `false` | Whether database availability is required |
| `ProbeSpacetimeOnStartup` | `true` | Startup database probe |
| `AutoStartSpacetimeDb` | `true` | Local database startup attempt |
| `AutoCreateSpacetimeDatabase` | `true` | Automatic database creation option |

For connections from another machine, configure the client with the server's address and allow the configured TCP port through the server's firewall.

## SpacetimeDB

Database functionality requires the SpacetimeDB CLI, a running endpoint, and a published module. Configure the database name, endpoint, credentials, and tool paths in the server settings. `RequireSpacetimeDb=false` allows startup without requiring the database; this does not guarantee that persistence-dependent operations will work without it.

The module has its own SDK configuration in `SpacetimeDb/global.json` and a WASI/NativeAOT build configuration. Treat it as a separate toolchain from the desktop applications. See [`SPACETIMEDB_SETTINGS.md`](SPACETIMEDB_SETTINGS.md) for startup and publication settings and [`SPACETIMEDB_PRIVATE_TABLE_AUTH.md`](SPACETIMEDB_PRIVATE_TABLE_AUTH.md) for private-table authentication details.

## Development and verification

Make changes in the projects used by your selected launcher. Test networking and saved-data changes with both applications, and back up world data before changing persistence formats.

The regression checks are console applications. For example:

```powershell
dotnet run --project .\Tests\GameLoop\GameLoop.csproj
dotnet run --project .\Tests\WorldScene\WorldScene.csproj
dotnet run --project .\Tests\TransportRace\TransportRace.csproj
```

Check each test application's setup before running checks that need external processes or services.

Some older build and migration guides describe previous layouts or VB.NET implementations. Resolve discrepancies against the current `.sln`, `.csproj`, and configuration files. The `build-windows.ps1` helper stops running applications, removes build output, and uses a `Windows` solution platform that the current main solution does not define; use the explicit project commands above.

## Troubleshooting

- **Connection fails:** Confirm the server is listening, the client uses the correct host and port, and both applications use compatible Telepathy framing.
- **Database startup fails:** Check the SpacetimeDB endpoint, CLI path, module toolchain, and authentication settings. Inspect server output for the failing operation.
- **Wrong configuration is loaded:** Confirm which `appsettings.json` your launcher copies and inspect the file beside the built executable.
- **Graphics or interface assets are missing:** Keep copied assets with the build output and confirm the relevant project content files were included.
- **Solution build fails on another platform:** Build the matching platform project directly and check its native interface dependencies.

## License

Released under the **BSD 2-Clause License**. See [`LICENSE`](LICENSE).
