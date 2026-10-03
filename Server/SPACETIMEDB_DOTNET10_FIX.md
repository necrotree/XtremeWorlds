# SpacetimeDB .NET 10 publish fix

The bundled module now includes `spacetimedb/global.json`:

```json
{"sdk":{"version":"10.0.100","rollForward":"latestMinor"}}
```

Before publishing, the server now finds `dotnet`, verifies that a .NET 10 SDK is installed, and passes `DOTNET_ROOT`, `DOTNET_HOST_PATH`, and an updated `PATH` to the SpacetimeDB CLI.

If automatic detection still cannot find your SDK, set `SpacetimeDotNetPath` in `appsettings.json`, for example:

```json
"SpacetimeDotNetPath": "C:\\Program Files\\dotnet\\dotnet.exe"
```
