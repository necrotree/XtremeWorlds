# FNA main-game UI

The main game window is now owned by FNA rather than the converted Eto `frmMainGame`.

## Layout

The renderer uses the original twinBASIC main-game skin (`Core/Assets/frmMainGame/frmMainGame.jpg`) at its native 949x700 size. The actual map is kept separate and clipped to the original `picScreen` rectangle:

- map viewport: x=18, y=18, width=640, height=480
- full interface: 949x700

World `FnaSpriteCommand` destinations are map-local and are offset into that viewport before drawing.

## Initial world data

Selecting a character sends `ingame`. The client then requests `needmap`; the server
loads only the session character's current map and replies with `worldstate` containing
a JSON snapshot of the stored map and selected player. `requestnewmap` also refreshes
the current snapshot. Missing or empty maps produce a `maperror` chat message and server
log entry identifying the map ID. The active Client/Engine renderer
draws ground, mask, second mask, player, fringe, second fringe, and the player name
inside the map viewport. Maps use 16 columns by 12 rows of 32px tiles, with zero-based
tile indices; sprite frames use the same 48x64 layout as the menu character preview.
This snapshot provides the initial scene; live movement and animated map layers
still require their gameplay packet handlers.

Both client and server must be rebuilt for this packet. When the character's map
is missing or contains no tiles, the viewport displays `NO MAP DATA RECEIVED FROM SERVER`.
Populate that map in the server content database to render terrain.

Protocol regression check: `dotnet run --project Tests/WorldScene/WorldScene.csproj`
from the repository root.

## FNA-side menu controls

The following original twinBASIC hit regions are handled directly by FNA:

- Character / Stats
- Inventory
- Guild
- Skills / Spells
- Options
- Who
- Training
- Notes
- Bug report
- Website
- Logout

Character, Inventory, Skills, Training, Notes, and Who toggle their original panel artwork directly in the FNA window. Menu actions are sent back through `EngineGameClientRuntime.MainGameAction`, so networking and Eto auxiliary dialogs stay outside the renderer.

## Architecture

- FNA: game window, map rendering, HUD skin, side panels, hit testing
- Eto: editors, options, bug-report and other auxiliary forms
- FAudio: audio
- Mirror/Telepathy: network transport

The old Eto `frmMainGame` remains in Core as a compatibility/layout reference but is no longer opened as the active game window.
