# SpacetimeDB index source sync fix

The active module used by the server is:

    src/Server/spacetimedb

That copy still contained the old field-level BTree index syntax and caused STDB0015.

This package fixes all copies of `Lib.cs` and adds a pre-build synchronization step so
`src/Server/spacetimedb` is recreated from the canonical root `spacetimedb` module on
each build.

The corrected field-level syntax is:

    [SpacetimeDB.Index.BTree]

No field-level index in `Lib.cs` uses `Columns = ...` anymore.
