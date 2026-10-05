# NPC quest dialogue

Reload and build both twinBASIC projects. Quest dialogue uses the existing NPCs,
items, classes, inventory, and quest markers. It does not modify legacy `.qst`
files or character record layouts.

## Authoring

Open **Quest Editor** from the developer admin panel, or enter `/questeditor`.
The server requires developer access for every editor request and save.

Choose a quest slot, name it, and choose its NPC. Set **NPC says**, **Completed**,
**Not had item**, **Not ready**, and **Already done** messages (up to 240 characters
each). Class and level requirements control availability. An optional required
item and quantity are consumed on completion; rewards can include an item and
experience. Quantities range from 1 to the inventory-slot limit. A blank name
disables the definition. Saving does not reset existing character progress.

**Full health**, **Full magic**, and **Full stamina** restore those vitals on
completion. **Once** prevents repeating the quest. Otherwise, a completed quest
can be accepted again. **On completion, unlock** enables the selected next quest;
the player talks to that quest's NPC to accept it. The server rejects cycles.

## Playing

Right-click the assigned NPC while standing within one tile. The dialogue shows
the quest title, NPC name, and message, with **Accept quest**, **Complete quest**,
or **Close**, according to progress and requirements. A quest without a required
item can be completed by talking to its NPC again after accepting.

Completion rechecks proximity, class, level, prior quest completion, required
items, and inventory capacity on the server. Full inventories do not consume
required items. Clicking Complete again cannot duplicate a completed reward.
Game hotkeys pause while the dialogue or editor is open.

Definitions are stored in `Server/data/QuestDialogue.ini`. Progress is stored per
account and character in `Server/data/QuestProgress.ini`, and survives reconnects
and server restarts. Back up both files along with character data. Existing script
markers remain in control for NPCs without a dialogue quest.

## In-game verification

1. Create a once-only quest with an NPC, required item, reward, and next quest.
2. Save, reopen the slot, and check that every field is retained.
3. Talk from more than one tile away; no dialogue action should be granted.
4. Accept with the correct class and level; missing items show Not had item.
5. Acquire the items, complete, and verify consumption, reward, and restored vitals.
6. Talk again; verify Already done and that rewards cannot be repeated.
7. Talk to the next quest's NPC; verify it becomes available.
8. Reconnect and restart the server; verify progress and definitions persist.
9. Repeat with a full inventory and with a non-developer editor request.

Automated project/design validation does not replace this in-game pass.
