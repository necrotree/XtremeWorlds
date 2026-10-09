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

Use **F11** or **Alt+Enter**
to toggle browser game fullscreen. The HUD keeps its original proportions,
including click targeting, chat, and the editor. **Escape** exits browser
fullscreen. The desktop game supports **F11** and **Alt+Enter** as well.

### Gameplay actions

Use the **Inventory** and **Spells** HUD tabs to browse all 75 inventory slots,
use or equip items, drop items, pick up an item at your feet, and cast known
spells. Item quantities and equipped markers update from the server. The HUD
can be minimized and moves below the game on narrow screens. Open **Actions**
in the game header to send one of 30 emotes or preview and select a player sprite. Spell targets are player names; leave
the target blank to cast a restorative spell on yourself. Combat spells require
a combat map (`Moral = 0`). A defeated player respawns on the current map with
restored health. Mana costs, range, requirements, and cooldowns are enforced
by the server. Player inventory, known spells, vitals, and avatar changes are
saved to the character database. Ground drops and short-lived effects are
in-memory map state and disappear when the server restarts.

Both clients accept `/emote 1`, `/use 1`, `/drop 1`, `/pickup`, `/cast 1`,
`/cast 2 Player Name`, and `/sprite 0` through chat. Inventory, spell slots,
and emote commands use numbers starting at 1; sprite IDs start at 0.

The server seeds Health Potion, Mana Potion, Spell Book, Heal, and Firebolt
only when the respective definition tables are empty. New characters receive
starter potions, a spell book, and Heal when those starter definitions exist.
Existing content and characters are preserved.

Artwork layouts: `items.png` has six 32x32 icons per row; `emote.png` has six
32x32 bubbles per row; `sprites.png` has twelve 48x64 frames per sprite
(four directions with three walking frames), plus its rightmost label column;
`spells.png` has twelve 96x128 frames per animation. `arrows.png` is retained
for future projectile delivery; current combat spells apply directly to their target.

Gameplay checks: `dotnet run --project Tests/Gameplay/Gameplay.csproj`.

### Vitals, targeting, speech, and quests

The supplied `misc/bars.png` displays live HP, MP, and SP beneath your
character in the world. Other players and combat NPCs show a health bar.
The top-left character card uses the original colored HP, MP, and SP display. Click a player to
select them: `misc/target.png` marks that actor and fills the spell target.
Click empty map space to clear selection. Target selection follows moving
actors and clears when the actor leaves the scene.

Map chat displays a five-second speech bubble above its sender using
`misc/chatbubble.png`. Longer text is shortened inside the bubble; the full
message remains in the chat history. Private, guild, and global messages stay
in their chat channels.

The **Quests** HUD tab lists objectives, progress, and giver coordinates.
Click a quest giver or the tab to open the journal. Move within two tiles of
the giver to **Accept quest** or **Turn in quest**. Animated
`misc/questblips.png` markers identify available (gold exclamation), active
(purple question), and ready-to-turn-in (gold question) quests. Completed
quests grant no further rewards and hide their overhead marker. Quest
acceptance and completion are saved with the character. Objective items and
inventory space are checked before granting item and experience rewards.

An empty quest table receives a starter collect-and-deliver quest at (2,2)
on the first loaded map when starter potion definitions exist. Existing quests
are preserved. `/quests`, `/acceptquest 1`, and `/completequest 1` also work
through chat. Quest definitions specify map, giver position/sprite, item
objective, item reward, experience reward, and minimum level.

### Normal attacks and map items

**Right-click an NPC or another player** to start repeating normal melee
attacks. Move within one tile of the target; attacks wait while out of reach.
Right-click the same target again, right-click empty ground, press **Escape**,
or use **Stop attack** in the HUD to stop. Changing target, opening an editor
or Actions panel, losing focus, leaving the map, or a target's death also stops
attacks. Normal attacks consume no mana. The server enforces attack timing,
range, damage, equipped weapon/armor bonuses, and safe-map player combat rules.
NPCs retaliate when attacked, respawn after their configured delay, and can
award experience and drop items. Damage spells also accept selected NPCs.

**Press E with the game canvas focused while standing on a ground item** to
pick it up. Chat input fields retain normal typing. Item icons appear on the
map; the HUD lists items at your feet. Pickup checks available inventory space
and merges compatible stacks. Items can come from player drops, NPC loot, or
map spawn definitions. Pickup removes a ground item for everyone; configured
spawns return after their respawn delay.

Administrators can add or remove persistent item spawns in **Edit ? Map item
spawns**, specifying item ID, quantity, coordinates, and respawn seconds.
These controls save directly to the server map, independently of the local
tile/event draft. Each map supports up to 20 ground items and 20 spawn templates.
Map JSON stores templates in `ItemSpawns`; NPC definitions are selected by the
map's existing `Npcs` list. An untouched starter map receives a Training Dummy
and a potion spawn when the matching starter definitions are created.
Ground drops and NPC health are transient; spawn definitions and character
inventory/rewards are persisted.

### Mana charging

Hold **Spacebar** with the game focused to charge mana. Recovery is controlled
by the server at ten percent of maximum mana per second (at least one MP per
second for small mana pools), and stops at full mana. The HUD shows **Charging**
while the channel is active. Release Space, move, attack, cast, switch focus,
or open an editor or Actions panel to interrupt charging. Starting a charge
stops autoattacking. Chat input fields retain normal spaces. The server expires
a charge if held-key pulses stop, checks that the player is alive and eligible,
and saves recovered mana periodically and when the channel ends.

### Item and NPC editors

Administrators see **Items** and **NPCs** buttons in the game header. Choose
an existing definition, or enter an unused definition ID and click **Load / New**.
The editors preview the graphic or sprite and save directly to the server database.

The item editor supports equipment, HP/MP/SP potions, currency, and spell books,
including equipment bonuses, restoration amount or spell ID, and level/class/guild
requirements. The NPC editor supports health, strength, defense, combat/friendly
behavior, experience, respawn timing, and item drops with quantity and chance.
**Add saved NPC to this map** persists the NPC in the current map's NPC list.

Definition saves validate administrator access, field limits, graphics, spell
references, and loot references. Failed database saves preserve the live definition
and keep the editor draft open. Successful saves update active gameplay without a
server restart; NPC edits preserve current damage while applying the new health
limit and stats. Existing legacy definition fields are retained when editing.
