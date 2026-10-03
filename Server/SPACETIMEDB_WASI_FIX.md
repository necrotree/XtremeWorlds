# .NET 10 SpacetimeDB WASM build fix

The SpacetimeDB C# module now explicitly targets:

    <RuntimeIdentifier>wasi-wasm</RuntimeIdentifier>
    <UseAppHost>false</UseAppHost>

The automatic publish command also passes:

    --dotnet-version 10

This fixes the NativeAOT-LLVM error:

    RuntimeIdentifier is required for native compilation.
