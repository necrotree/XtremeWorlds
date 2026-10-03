# XtremeWorlds server migration

## What was migrated

The twinBASIC container was unpacked into `LegacySource/` (30 application source units plus the original `.twinproj`). The new runtime is a .NET 10 VB.NET console server under `src/Server`.

### Networking

The old Win32/native socket classes (`clsNativeConnection`, `clsNativePacket`, `clsServer`, `clsSocket`, `modServerTCP`) are replaced by `MirrorTcpHost.vb`, which uses MirrorNetworking's standalone Telepathy TCP transport. `NoDelay` is explicitly set from `appsettings.json` and defaults to `true`. The legacy packet strings are kept as the application payload, but Telepathy adds message framing around each payload.

### Database

The old file persistence in `modDatabase.bas`/`modRecordIO.bas` is replaced by SpacetimeDB. The SpacetimeDB module is in `spacetimedb/Lib.cs`; it stores accounts, characters, bans, settings, and all game content. Static content is stored in a generic `content` table as versioned JSON (`kind:id`) so every original content family can be migrated without reproducing VB6 binary layouts inside the database.

Content kinds map to the old arrays/files: `class`, `item`, `npc`, `map`, `shop`, `sign`, `spell`, `guild`, `quest`, `arrow`.

The VB.NET host talks to SpacetimeDB through its documented HTTP reducer/SQL API (`SpacetimeHttpClient.vb`). Writes go through reducers; reads use authenticated SQL. Put the database-owner token in `appsettings.json` or inject it from deployment secrets.

### Game model

`Models/GameModels.vb` converts the core VB6 UDTs (`PlayerRec`, `MapRec`, `ClassRec`, `ItemRec`, `NpcRec`, `ShopRec`, `SpellRec`, `SignRec`, `GuildRec`, `QuestRec`, `BanRec`, arrows) to .NET classes. VB6 `Long` values are converted to 32-bit `Integer` where they represented the original 32-bit field.

### Packet handling

`PacketRouter.vb` implements account creation/login, class list, character creation/deletion/use. `LegacyGameService.vb` recognizes the remaining legacy packet names and provides the migration landing point for the large gameplay/editor surface. The original complete implementations remain in `LegacySource/modHandleData.bas`, `modGameLogic.bas`, `modGeneral.bas`, `modProjectiles.bas`, and `clsCommands.cls` for direct porting.

## SpacetimeDB language note

The main server is VB.NET. SpacetimeDB database modules do not support VB.NET; current server-module languages include C#, Rust, TypeScript and C++. Therefore `spacetimedb/Lib.cs` is C# by necessity and compiles to the SpacetimeDB WebAssembly module. The game host remains VB.NET.

## Setup

1. Install .NET 10 SDK and the SpacetimeDB CLI.
2. Run `scripts/setup-spacetimedb.ps1` (or `.sh`).
3. Put the owner token in `appsettings.json` for private account/character queries.
4. Run `scripts/run-server.ps1` or build `XtremeWorlds.sln`.

## Important protocol note

Telepathy is message-framed TCP. The client must also use Telepathy/Mirror framing. The upgraded client you requested earlier already moved to this transport. A legacy raw-Winsock client will not be wire-compatible until it is upgraded.

## Data migration

No external `data/` directory or live `.act/.dat` content files were included with the uploaded `Server.twinproj`, so there is no persisted world/account dataset to import in this archive. The SpacetimeDB schema and content API are ready for it. Copy/export the old `data` directory if you want the actual existing accounts/maps/items/classes/etc. migrated into the new database.
