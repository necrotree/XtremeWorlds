# Master tool ports

Source: master commits from 083d15d6e1055b91301d674898363694799bce00 (inclusive) through 7e85d1462af14f1fda24fd2fb793eba8b75a4e6f.
Destination: c-sharp. Tool implementations are VB.NET with Option Strict On, using native Eto.Forms controls. Existing C# engine/server projects reference the VB.NET assemblies.

## Open the tools

Press F2 in the FNA game window, or enter /admin in chat. The server verifies the current player's admin access before showing the admin panel. /bookeditor, /questeditor, /emoteeditor, and /mapeditor also open their content-slot lists.

## Ports

- Book editor: every content slot, two page texts, header, next-book and quest IDs, native preview, save acknowledgment, and return to the index.
- Quest editor: the 19 dialogue, requirement, reward, vital, and chaining fields; 240-character single-line validation; actual referenced content IDs; save and return to the index.
- Emote editor: slash-command validation, the updated 6-column/30-icon emote sheet, preview, and protected pending saves.
- Arrow editor: name, sprite row, range, full-direction/icon preview, correlated save acknowledgment, and return to the index.
- Item editor: equipment, potion, spell, warp, and book-specific data; hides irrelevant controls.
- NPC editor: quest-giver behavior, quest ID in the legacy ShopCall field, shop links, correct empty drop-item label, and full 32-bit drop amounts.
- Spell editor: all 16 animation frames, named arrow selection, range/projectile delivery, and type-specific payloads.
- Class, shop, and sign editors: native controls, persistent fields, trade slot editing, and sign preview.
- Map editor: drag a rectangular palette selection; paint/erase the full selection; retain each tile layer's original tileset when switching palettes; edit either attribute layer; save and broadcast map changes.
- Admin panel and content index: native layouts, actual content IDs, access-aware groups, moderation, sprite/access editing, and ban controls.

The original designer JSON is retained under Designers for comparison. Group-box child coordinates are adjusted for Eto's native content area. The admin panel and map/class editors use native layouts rather than legacy window chrome.

## Integration

Client.Tools contains the Eto forms and controller. Tools/ToolProtocol contains the VB.NET schema, map operations, server editor service, and admin service. The existing EngineGameClientRuntime handles the network bridge; PacketRouter connects the services to SpacetimeDB.

Both migrated client and server must be rebuilt together. Editor records travel as base64-encoded JSON inside the existing Telepathy packet framing. This replaces the classic binary editor packets; it does not change login or gameplay packets. The tools preserve unedited properties when saving. Empty slots are insertable through the updated SpacetimeDB content reducer. Republish that module with your normal deployment workflow before using new empty slots.

These are content/admin tools. Quest dialogue gameplay, book item use, dynamic NPC respawn simulation, and other unfinished gameplay systems are not implemented by this port. The admin map refresh reloads the persisted map; it does not simulate NPC respawns. Jail settings and return locations last for the current server session.

## Validation

- dotnet build Client/Engine/Client.Engine.csproj
- dotnet build Server/src/Server/Server.Common.csproj
- dotnet run --project Tests/ToolPorts/ToolPorts.vbproj
- On Windows: dotnet run --project Tests/ToolForms/ToolForms.vbproj

ToolForms can also render the native layouts without opening windows by passing an output directory after --.
