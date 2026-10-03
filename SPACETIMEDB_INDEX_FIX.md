# SpacetimeDB module index fix

Current SpacetimeDB C# field-level single-column indexes must use:

    [SpacetimeDB.Index.BTree]
    public string Field;

The previous module incorrectly used `Columns = ...` on field attributes, which
caused STDB0015 during `spacetime publish`.

The corrected fields are:
- Content.Kind
- Character.AccountLogin
- Ban.Ip
- Ban.HardwareId
