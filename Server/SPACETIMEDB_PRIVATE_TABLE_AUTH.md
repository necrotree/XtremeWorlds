# SpacetimeDB private-table authorization

The `account` table intentionally remains private because it stores password hashes,
salts, and account encryption-key data.

SpacetimeDB tables are private by default. Anonymous `/sql` requests cannot query
private tables and SpacetimeDB may report them as `no such table`.

At startup, after the database exists, XtremeWorlds now:

1. Uses `SpacetimeToken` from appsettings.json when provided.
2. Otherwise, for the normal local setup, runs:
       spacetime login show --token
   and applies that CLI owner's token as HTTP Bearer authentication.
3. Verifies private-table access with:
       SELECT login FROM account LIMIT 1

The token itself is never written to the server log.

If automatic CLI credential loading is not desired, set `SpacetimeToken` explicitly.
