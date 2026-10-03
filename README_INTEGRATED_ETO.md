# XtremeWorlds integrated Eto client + server

## Client

The client uses Eto.Forms as the native cross-platform UI layer:

- Windows: Eto.Platform.Wpf
- Linux: Eto.Platform.Gtk
- macOS: Eto.Platform.macOS
- Shared forms: `Client/Core/Forms`
- FNA/FAudio game renderer/audio: `Client/Engine`
- Mirror/Telepathy game networking: `Client/Engine/Networking`

Windows entry point: `Client/Platforms/Windows/Program.cs`.

The latest FNA 640x480 viewport/chat rendering correction is included in
`Client/Engine/Graphics/FnaGraphicsService.cs`.

## Server

The server keeps the same Eto platform split:

- Windows: `Server/Platforms/Windows`
- GTK: `Server/Platforms/GTK`
- macOS: `Server/Platforms/macOS`
- Shared server code: `Server/src/Server`

`ServerHost.ConfigureSpacetimeDatabaseAuthorizationAsync` is implemented in
`Server/src/Server/ServerHost.cs` and is called after the SpacetimeDB database
has been started/created.

### Security boundary

SpacetimeDB owner/private-table credentials are intentionally server-only.
Do not copy `ConfigureSpacetimeDatabaseAuthorizationAsync` or owner tokens into
the client. The client authenticates to the XtremeWorlds game server; the
server performs privileged SpacetimeDB access.

## Solutions

- Client Windows: `Client/Client.Windows.sln`
- Client all-platform project tree: `Client/Client.EtoNative.sln`
- Server: `Server/XtremeWorlds.Server.sln`

