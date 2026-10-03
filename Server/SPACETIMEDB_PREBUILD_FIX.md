# SpacetimeDB publish RID fix

The server no longer asks `spacetime publish` to build the C# module.

It now performs:

    dotnet publish StdbModule.csproj -c Release -f net10.0 -r wasi-wasm --self-contained true

and then publishes the resulting wasm file with:

    spacetime publish <database> --bin-path <module.wasm>

This guarantees the `wasi-wasm` RuntimeIdentifier reaches the .NET NativeAOT build.

The Windows project also deletes the old `bin/.../spacetimedb` copy before copying the
current module, preventing stale StdbModule.csproj files from surviving incremental builds.
