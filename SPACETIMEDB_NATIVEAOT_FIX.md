# SpacetimeDB .NET 10 NativeAOT-LLVM fix

The module project now follows the official SpacetimeDB .NET 10 C# template:

- RuntimeIdentifier = wasi-wasm
- PublishTrimmed = true
- SelfContained = true
- MSBuildEnableWorkloadResolver = false
- Microsoft.DotNet.ILCompiler.LLVM 10.0.0-*
- runtime.$(NETCoreSdkPortableRuntimeIdentifier).Microsoft.DotNet.ILCompiler.LLVM 10.0.0-*

The server bootstrapper now searches both obj/Release and bin/Release for the
generated WebAssembly module, preferring the NativeAOT publish location:

    obj/Release/net10.0/wasi-wasm/wasm/for-publish/StdbModule.wasm
