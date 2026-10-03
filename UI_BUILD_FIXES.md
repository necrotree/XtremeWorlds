# UI and build fixes

- Players Online context menu is fully custom-skinned in WPF. It no longer reserves the stock icon/check gutter, so there is no empty white strip on the left.
- The Access submenu uses the same dark panel/button/gold theme as the rest of the server UI and exposes levels 0 through 9.
- Fixed the `Panel.IsItemsHostProperty` compile error by fully qualifying `System.Windows.Controls.Panel` (the skin also has a brush named `Panel`).
- Restored `ConfigureSpacetimeDatabaseAuthorizationAsync` using the existing SpacetimeDB CLI token helper and private-table verification.
- Cleaned nullable session/database annotations and JSON string handling that produced nullability warnings.
- Startup now awaits public-IP refresh in both WPF and Eto forms. The displayed Game IP remains the public ISP-facing IPv4 when available, with LAN fallback, never the listener wildcard `0.0.0.0`.
- The .NET 10 WASI Microsoft.VisualBasic framework-facade MSB3277 diagnostic is demoted to an MSBuild message in the SpacetimeDB module project.
- Generated `bin`, `obj`, and NativeAOT build-cache folders were removed from this archive so Visual Studio cannot launch stale UI binaries or reuse stale assembly-resolution results.
