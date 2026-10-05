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

In **NPC Editor**, set the NPC's behavior to **Quest giver** and set **Quest ID**
to its slot in **Quest Editor**. Use `0` for no quest. Place the NPC on the map.
This quest ID controls its dialogue and blip; multiple quest givers can offer
the same quest. Quest givers stay in place
and cannot be damaged by melee attacks or harmful spells. Existing NPC behavior
IDs and record layouts are unchanged.

**Full health**, **Full magic**, and **Full stamina** restore those vitals on
completion. **Once** prevents repeating the quest. Otherwise, a completed quest
can be accepted again. **On completion, unlock** enables the selected next quest;
the player talks to that quest's NPC to accept it. The server rejects cycles.

## Playing

Face an adjacent quest giver and use the normal attack/interact action to chat,
or right-click the assigned NPC while standing within one tile. The chat box
shows the quest title, NPC name, and message. **Accept quest** or **Complete quest**
appears beside the chat controls according to progress and requirements.
**Dismiss** clears the current interaction while retaining the chat history.
A quest without a required
item can be completed by talking to its NPC again after accepting.

Completion rechecks proximity, class, level, prior quest completion, required
items, and inventory capacity on the server. Full inventories do not consume
required items. Clicking Complete again cannot duplicate a completed reward.
Quest chat leaves gameplay available. Game hotkeys pause while the quest editor
is open. Changing maps clears the active quest chat buttons.

Quest blips show a yellow **?** for an available quest, a grey **?** while its
required items are missing, and a yellow **?** when it is ready to complete.
Quests whose requirements are not met show a grey **!**. Completed once-only
quests have no blip. Quest givers without an assigned enabled quest clear their
dialogue blip. Quest givers can be interacted with even when their Max HP is zero.

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
