# Arrows and spell delivery

Developers can open **Spell Editor > Edit arrows…**, or type `/arrowedit` in
the client. Select one of 100 arrow definitions, enter its name, choose a sprite
and a travel range of 1–32 tiles. **OK** saves and closes after the server
confirms the save. **Cancel** discards unsaved changes. The form uses the Item
Editor's size, spacing, Name field, and bottom button layout. The preview shows all four
directions; the small preview shows the upward sprite.

`Client/Gfx/arrows.bmp` uses four 32×32 images per row: up, down, left, right.
Rows are stored from zero and displayed as Arrow 1, Arrow 2, and so on in the
editor. Black is transparent. The direction chooses one
static image; arrows have no animation. The supplied sheet has 154 rows.

Every spell type has the same **Spell delivery** options:

- **Range cast:** applies the spell to the selected valid target immediately
  if it is within the configured distance in tiles. This is a single-target
  cast, not an area effect. Beneficial/item/warp spells use the caster if no
  target is selected. Existing spells default to a 32-tile range cast.
- **Projectile hit:** launches the selected arrow in the caster's facing
  direction, using the arrow definition's travel range. It does not home in
  on the selected target. The first player/NPC in its path intercepts it;
  valid recipients receive the spell effect. Blocked tiles, closed doors,
  and the map border stop it. It expires at its travel limit.

Damage and other effects remain in the Spell Editor. Both modes share the
same effect code for HP/MP/SP addition and subtraction, give-item, and warp.
Give-item and warp require a player recipient; NPCs have no player inventory
or player warp state. PvP map, level, and access protections apply at impact.
Friendly/shop NPCs cannot be harmed. A protected or inapplicable target still
intercepts the projectile, without receiving an effect.

The server moves arrows at 200 pixels/second with a 4-pixel collision sweep,
and sends their authoritative positions to clients. Clients never report
hits. Mana and the one-second cast cooldown are charged once on launch,
including misses. Caster disconnect/map changes cancel owned arrows. Editing
a spell cancels its active arrows so an edit cannot change an in-flight hit.

Arrow definitions and delivery settings are stored in
`Server/data/Projectiles.ini`. Existing binary spell files retain their
original format. Rebuild and deploy both updated client and server together.

Validation tools live in `Client/tools`:

- `Test-ProjectileLogic.ps1` adapts the actual server delivery and shared effect
  code to a VB.NET compatibility harness with deterministic game/network
  stubs. It checks every spell effect in both modes, collisions, mana,
  permissions, range, cleanup, and settings reload. It is not a native build.
- `Test-ProjectileIntegration.ps1` verifies embedded project sources,
  integration hooks, editor controls/bounds, and the sprite sheet format.
- `Integrate-Projectiles.ps1` and `Build-ProjectileEditors.ps1` synchronize the
  targeted changes into the twinBASIC projects and VB6 source forms.

Native client/server builds and an in-game multiplayer visual check are still
required: verify the four directions, sprite previews, saved settings after
restart, moving targets, and damage/healing/warp/item effects on impact.
