# Script Editor

Open **Database > Script Editor** on the server. The resizable form has a script
file list on the left, a procedure selector above the code pane, and a SadScript
event selector below it. It opens `scripts/Main.as` when available.

- Select an `.as`, `.vbs`, or `.txt` file from the server's `scripts` folder.
- Use **Save**, **Save As**, or **New** to manage plain-text scripts. Switching
  files or closing the editor prompts to save modified text.
- The **Edit** menu and right-click menu provide cut, copy, paste, select all,
  undo, and redo. Shortcuts are Ctrl+X/C/V/A/Z/Y; Ctrl+S saves.
- Keywords, strings, comments, numbers, and SadScript directives have syntax
  colors. Coloring preserves the selection and does not enter undo history.
- The procedure selector navigates to `Sub` and `Function` declarations.
  **Insert event** adds the selected callback with the arguments used by this
  server, or navigates to it if it already exists.

The event list includes `ServerSet`, `JoinGame`, `LeftGame`, `JoinMap`,
`LeaveMap`, `OnScriptedTile`, NPC/player death events, `OnLevelUp`, item
equip/unequip/use/drop events, and `OnTime`. Existing SadScript support for
`#include`, `#define`, globals, and custom functions remains in the server's
script runtime. The editor does not execute scripts or validate them.

Save changes, then use **Database > Reload Scripts** to apply them. Additional
files must be included or otherwise loaded by the existing script runtime;
saving a file does not register new callbacks. Undo retains the last 100 text
states for the current file.

The twinBASIC project uses Windows Rich Edit (`msftedit.dll`) through
`clsScriptText`; the VB6 project uses `richtx32.ocx`. Files are saved in the
legacy server's ANSI plain-text format with CRLF line endings. A save writes
a temporary file before replacing the original; interrupted saves may leave
`.editing` or `.previous` recovery files beside the script.
