# Keyboard shortcuts

Open **Options > Keyboard Shortcuts** while playing. Select an action, then
choose its key. **Save** applies the changes and remembers them for the next
session; **Cancel** discards changes made in the dialog.

Movement, attack, running, picking up items, casting the memorized spell,
toggling the admin panel, and quitting can be assigned individual keys.
Choose **Unassigned** to clear a binding. Duplicate keys are rejected; clear
an existing binding before assigning its key to a different action.

**Arrow defaults** and **WASD defaults** load presets into the dialog. Click
Save to apply one. Until you save a custom profile, the existing arrow/WASD
movement setting continues to work, including arrow aliases in WASD mode.
A custom profile replaces those aliases and takes precedence over that setting.

Enter remains the chat key. With a custom profile, press Enter to open chat,
then Enter again to send and return to gameplay. Game bindings are suspended
while chat or the shortcut editor is active. Enter can also be assigned to
pickup, which picks up an item when opening empty chat.

Settings are stored locally in `data/Hotkeys.ini`, separately from `Data.dat`.
An invalid profile falls back to the existing game controls. Binding an admin
action does not grant admin access.

For development, `tools/Sync-Hotkeys.ps1` synchronizes the edited hotkey and
input source files into `XtremeWorlds.twinproj`. `tools/Build-HotkeysTest.ps1`
creates an isolated test project in `Build/HotkeysTest`; build and run it to
check validation, persistence, input matching, and dialog Save/Cancel behavior.
