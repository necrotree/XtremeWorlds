# FNA main-game UI

The main game window is now owned by FNA rather than the converted Eto `frmMainGame`.

## Layout

The renderer uses the original twinBASIC main-game skin (`Core/Assets/frmMainGame/frmMainGame.jpg`) at its native 949x700 size. The actual map is kept separate and clipped to the original `picScreen` rectangle:

- map viewport: x=18, y=18, width=640, height=480
- full interface: 949x700

World `FnaSpriteCommand` destinations are map-local and are offset into that viewport before drawing.

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
