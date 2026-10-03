# XtremeWorlds client engine migration

This build removes the compiled client's dependence on the old DX11/BASS/WinSock-style engine path and introduces three replacement services.

## Graphics: FNA

`Engine/Graphics/FnaGraphicsService.cs` owns the game renderer. It creates an FNA `Game`, `GraphicsDeviceManager`, `SpriteBatch`, texture cache, and a thread-safe sprite command queue. `frmMirage`/`frmMainGame` starts the FNA renderer through `MainGameAction("Form_Load")`.

The Eto forms remain the UI/editor layer. FNA is the game-world renderer.

## Audio: FAudio through FNA

`Engine/Audio/FnaAudioService.cs` uses FNA's `SoundEffect`, `Song`, and `MediaPlayer` APIs. FNA's Audio/Media namespaces are implemented on top of FAudio, so the old BASS/FMOD path is not part of the compiled client.

Runtime actions supported by the new service:

- `PlaySound(path)`
- `PlayMusic(path)`
- `StopMusic()`

A `music/menu.ogg` file is automatically played at the menu when it exists.

## Networking: Mirror TCP / Telepathy

Mirror itself is a Unity high-level networking package. Its TCP transport, Telepathy, is standalone C# and is what this non-Unity client uses.

`Engine/Networking/MirrorTcpClient.cs` provides:

- connect/disconnect
- ordered framed TCP messages
- send/receive callbacks
- explicit `Tick()` processing

`Engine/Networking/XtremeWorldsPacketCodec.cs` preserves XtremeWorlds' NUL-separated packet payloads and the legacy END_CHAR during migration.

**Server note:** Telepathy adds its own length framing. The server must also use Telepathy/Mirror TCP framing (or equivalent framing) for this transport to communicate with it. A legacy raw Winsock server cannot consume Telepathy frames unchanged.

## Runtime integration

`Engine/Runtime/EngineGameClientRuntime.cs` replaces the previous event-only runtime for platform launchers. It now handles:

- menu TCP connection flow
- login/new-account/add/delete/use-character packets
- character list responses
- class list responses
- transition to `frmMainGame` on `ingame`
- editor/admin request packets used by the Eto form
- FNA renderer startup
- FAudio-backed sound/music
- server IP editing (F1)

Default server: `127.0.0.1:7234`, matching the original client.

## Main menu backdrop

The uploaded wide background is installed at:

`Core/Assets/frmMainMenu/imgBackground.png`

The WPF Eto skin uses `UniformToFill`, so the image remains proportional while filling the menu window.

## Legacy source

`LegacySource/` is retained only as a migration reference. It is not compiled. `modDX11.bas`, `clsDX11Surface.cls`, `modBASS.twin`, `clsBASS.cls`, `clsNativeSocket.twin`, and `modClientTCP.bas` are therefore no longer runtime dependencies.
