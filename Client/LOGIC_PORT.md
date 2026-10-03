# twinBASIC form logic port

This build starts moving the original form event logic from `LegacySource/*.frm.twin` into the Eto.Forms forms.

## frmMainMenu

Ported/wired behavior includes:

- original login page flow and Enter-key handling
- login field validation
- register/new-account flow and password verification
- printable-ASCII username/character-name validation
- character selection, use/create/delete/back actions
- class selection and sex selection
- new-character preview requests
- website and exit actions
- F1 server-IP request hook
- menu initialization / website refresh hooks
- original-style character slot selection helpers

## frmMirage / frmMainGame

The original file is named `frmMirage.frm.twin`, while its twinBASIC class is `frmMainGame`.  The Eto project now contains both names (`frmMirage` derives from `frmMainGame`).

Wired behavior includes the main game window lifecycle, chat Enter handling, game key down/up forwarding, inventory/spell/player double-click actions, map-editor mouse actions, tileset scrolling, side-menu actions, and the editor/admin command buttons.

## Runtime boundary

`Core/ClientLogic/GameClientRuntime.vb` is the migration boundary between Eto forms and the remaining networking/rendering engine.  The forms now execute their original local UI logic and send engine operations through `IGameClientRuntime`.  Set `GameClientRuntime.Current` to the converted client engine implementation as the remaining twinBASIC modules are ported.  `ActionRequested` exposes the original operation names (`MenuState`, `CheckInput`, `EditorChooseTile`, `SendWhosOnline`, etc.) so the networking/game modules can be connected without putting platform-specific code back in the forms.

## Icon

The supplied icon is included at `Core/Assets/Icon.ico`, is embedded in the shared Eto assembly, is copied to application output, and is assigned to `frmMainMenu`, `frmMainGame`, and the compatibility `frmMirage` class.  The Windows executable also uses it via `<ApplicationIcon>`.
