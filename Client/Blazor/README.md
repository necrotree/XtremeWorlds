# Blazor client

Run from the repository root:

```powershell
dotnet run --project Client/Blazor/Client.Blazor.csproj
```

The root page opens `FrmMainMenu`, the browser counterpart of `frmMainMenu`,
using the original menu artwork. Login/register and character selection use
the circuit's Telepathy transport. The `ingame` server response switches the
page to `FrmMirage`, the browser counterpart of `frmMirage`.

FNA renders the original 950 × 700 game HUD into a render target on the web
host. The native window is hidden. PNG frames are captured at up to 10 FPS
and sent through Blazor's binary JavaScript interop to the browser canvas.
Only the latest frame is retained; slow browsers skip older frames.
Browser coordinates are scaled to the logical HUD coordinates. HUD clicks
and chat keys enter queues consumed on FNA's render thread. Network actions
return to the circuit thread. Escape logs out when no HUD panel is open.

The host needs a working native graphics device/display environment and the
FNA.NET native libraries supplied by NuGet. This is server-side rendering,
not a WebAssembly build of FNA. SDL has process-wide event state, so only
one browser circuit can lease the native renderer in a host process.
Concurrent game sessions require separate renderer worker processes.
Disconnect/navigation disposes the transport and releases the renderer.

Current game-server support sends character information and chat. This
change does not add missing legacy map decoding, movement simulation, or
server implementations of gameplay packets. The world viewport remains
empty until world data is submitted to the existing FNA scene pipeline.

Validation (requires native graphics):

```powershell
dotnet run --project Tests/BrowserFlow/BrowserFlow.csproj
dotnet run --project Tests/GameLoop/GameLoop.csproj
```

The browser-flow test uses a local mock game server and exercises login,
character selection, native frame capture, chat forwarding, renderer
isolation, disconnect, and renderer restart. An optional first argument
saves a captured PNG for inspection.
