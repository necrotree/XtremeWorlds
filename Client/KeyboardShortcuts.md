# Keyboard shortcuts

Open **Options > Keyboard Shortcuts** while playing. Select an action, then
click its key on the keyboard diagram or choose it in the dropdown. Green marks
the selected action's key; blue marks other assigned keys. Gray system keys
are unavailable. Left/right Ctrl and Shift share a binding; both Enter keys
remain reserved for chat/pickup. **Save** applies changes for the next
session; **Cancel** discards changes made in the dialog.

Movement, attack, running, picking up items, casting the memorized spell,
toggling the admin panel, and quitting can be assigned individual keys.
All 75 inventory slots and 40 spell slots also appear in the action list.
An inventory binding uses/equips the item currently in that slot; a spell
binding casts the spell currently in that slot without changing the memorized
spell. Empty slots do nothing. Spell movement and cooldown rules still apply.
Bindings follow slot numbers, so moving/replacing an item changes what its key
uses. New slot bindings start unassigned; existing saved shortcuts are preserved.
Choose **Unassigned** to clear a binding. Duplicate keys are rejected; clear
an existing binding before assigning its key to a different action.

**Arrow defaults** and **WASD defaults** load presets into the dialog. Click
Save to apply one. Until you save a custom profile, the existing arrow/WASD
movement setting continues to work, including arrow aliases in WASD mode.
A custom profile replaces those aliases and takes precedence over that setting.
Loading either default preset also clears the inventory and spell bindings.

Enter remains the chat key. With a custom profile, press Enter to open chat,
then Enter again to send and return to gameplay. Game bindings are suspended
while chat or the shortcut editor is active. Enter can also be assigned to
pickup, which picks up an item when opening empty chat.

Settings are stored locally in `data/Hotkeys.ini`, separately from `Data.dat`.
An invalid profile falls back to the existing game controls. Binding an admin
action does not grant admin access.

For development, `tools/Update-KeyboardEditor.ps1` synchronizes the keyboard
layout and shortcut changes into `XtremeWorlds.twinproj` and the VB6 form.
