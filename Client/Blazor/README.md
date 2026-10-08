# Blazor client

Run from the repository root:

```powershell
dotnet run --project Client/Blazor/Client.Blazor.csproj
```

The root page opens `FrmMainMenu`, the browser counterpart of `frmMainMenu`,
using the original menu artwork. Login/register and character selection use
the circuit's Telepathy transport. The `ingame` server response switches the
page to `FrmMirage`, the browser counterpart of `frmMirage`.

FNA renders the same 950 × 700 HUD and world pipeline used by the desktop
client into a hidden native render target. Capture targets 60 FPS. Binary PNG
frames are sent as soon as capture completes on a dedicated WebSocket rather than awaiting a Blazor JavaScript
interop acknowledgement for each frame. The renderer, sender and browser
decoder retain the latest frame, so slow decoding skips older images.

The interactive circuit pumps gameplay every 20 ms independently of frame
delivery, and rerenders status only when it changes. Both clients use
`GameClientConnection` in Client.Engine for world packet decoding, ticked
movement, gameplay action packets, acknowledgement heartbeats and rollback.
The shared FNA renderer owns input, map drawing, interpolation and prediction;
Blazor adds browser input and frame delivery.

Browser coordinates are scaled to the logical HUD coordinates. HUD clicks
and chat keys enter queues consumed on FNA's render thread. Escape logs out
when no HUD panel is open.

The host needs a working native graphics device/display environment and the
FNA.NET native libraries supplied by NuGet. This is server-side rendering,
not a WebAssembly build of FNA. SDL has process-wide event state, so only
one browser circuit can lease the native renderer in a host process.
Concurrent game sessions require separate renderer worker processes.
Disconnect/navigation disposes the transport and releases the renderer.

World snapshots enter the same map, sprite, interpolation and prediction pipeline
as the desktop client. Entering the game requests the current map; lightweight
tick snapshots reuse the cached map. Arrow keys move the player, and releasing
focus releases held keys. Acknowledgement heartbeats and inactive-connection
rollback use the shared tick protocol.

Menu artwork is served from the copied `Assets` directory at `/assets`.
The host output also includes all world textures from `gfx`. Restart the web
host after upgrading its engine assembly.

Validation (requires native graphics):

```powershell
dotnet run --project Tests/BrowserFlow/BrowserFlow.csproj
dotnet run --project Tests/GameLoop/GameLoop.csproj
```

The browser-flow test uses a local mock game server and exercises login,
character selection, native frame capture, chat forwarding, renderer
isolation, disconnect, and renderer restart. An optional first argument
saves a captured PNG for inspection.
