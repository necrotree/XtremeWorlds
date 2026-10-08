# Tick synchronization

Both the FNA client and server must be updated to use the tick protocol.

The server stamps authoritative movement with its configured tick clock (60 Hz by default) and sends lightweight `worldtick` snapshots at `SnapshotRate` (20 Hz by default). Maps are cached and sent separately in `worldstate` on entry, map requests, teleports and editor saves. Each snapshot identifies the connection epoch, server tick and processed input sequence.

The client renders remote players with a 100 ms interpolation buffer, predicts local four-pixel movement, and reconciles the authoritative position by replaying inputs the server has not acknowledged. Small corrections blend over 100 ms; map changes, teleports and rollback epochs snap. Remote actors are never extrapolated beyond the latest snapshot.

Clients send acknowledgement heartbeats every 250 ms, including while the game window is unfocused. After two seconds without valid activity, prediction pauses and movement rolls back to the last acknowledged server snapshot. The server disconnects after ten seconds without valid activity. Invalid sequences or acknowledgements also trigger rollback. A fresh epoch invalidates queued packets from before the rollback; acknowledging that epoch resumes movement.

Rollback restores only map, pixel position, tile position and direction. It does not undo inventory, vitals, account changes or database writes. Teleports and jail transitions start a fresh history so a later network rollback cannot undo an authoritative relocation.

Packet handlers run in order per connection, with a 256-packet limit. Snapshot history, prediction input history and client receive/render queues are bounded.

## Packet fields

Fields use the existing NUL separator and packet terminator.

- `playermove`: direction, input sequence, client tick, acknowledged server tick, acknowledged input sequence, epoch.
- `netping` / `netresync`: epoch, acknowledged server tick, acknowledged input sequence, client tick.
- `worldstate` / `worldtick`: JSON with `MapId`, `Player`, `Players`, `ServerTick`, `AckInputSequence`, `NetworkEpoch`, `TickRate`, `NetworkFrozen`. Full snapshots additionally include `Map`.

## Verification

Run `dotnet run --project Tests/NetworkRollback/NetworkRollback.csproj`. The suite covers deterministic interpolation, prediction replay, bounded rollback, stale epochs, ordered asynchronous handlers, and actual loopback TCP snapshots through the production router. The wire tests seed a map cache and do not require SpacetimeDB.
