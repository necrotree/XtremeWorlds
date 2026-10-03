# SpacetimeDB settings

The server can now start SpacetimeDB and create the configured database automatically.

```json
{
  "SpacetimeUri": "http://127.0.0.1:3000",
  "SpacetimeDatabase": "xtremeworlds",
  "SpacetimeToken": "",
  "SpacetimeUsername": "",
  "SpacetimePassword": "",
  "SpacetimeCliPath": "",
  "SpacetimeDotNetPath": "",
  "SpacetimeModulePath": "spacetimedb",
  "AutoStartSpacetimeDb": true,
  "AutoCreateSpacetimeDatabase": true
}
```

`SpacetimeDatabase` controls the database name everywhere. Database names must use lowercase
letters/numbers with optional dashes, for example `xtremeworlds` or `xtreme-worlds-test`.

`SpacetimeCliPath` may be left blank when `spacetime` is available in PATH. On Windows you can
also point it directly at `spacetime.exe`.

`SpacetimeUsername` and `SpacetimePassword` are optional HTTP Basic Authentication credentials.
They are used only when `SpacetimeToken` is blank. `SpacetimeToken` takes precedence.

On first startup, once the local SpacetimeDB service answers, the server checks
`GET /v1/database/<SpacetimeDatabase>`. If the database is missing and
`AutoCreateSpacetimeDatabase` is true, it runs the equivalent of:

    spacetime publish <SpacetimeDatabase> --server <SpacetimeUri> --yes=all --no-config

from the configured `SpacetimeModulePath`.

`SpacetimeDotNetPath` can be set to the full path of `dotnet.exe` if the Spacetime CLI cannot discover the .NET 10 SDK. A `global.json` selecting .NET 10 is bundled with the module and copied to the output directory.
