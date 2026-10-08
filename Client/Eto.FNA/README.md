# Experimental Eto.FNA bridge

This directory contains the prototype rendering/input transport from the Eto.FNA fork, adapted for the XtremeWorlds client project layout.

**Status: prototype only.** This is not yet an implementation of `Eto.Platform` or the requisite Eto control handlers. Existing Eto forms continue to use their configured platform (such as WPF), and the module does not automatically render them in the FNA game window.

## Project
```bash
dotnet build Client/Eto.FNA/Eto.FNA.csproj
```

The package references Eto.Forms 2.12.0 and FNA.NET 2.2.11.2602 in line with the current XtremeWorlds client dependencies. The prototype isn't yet referenced by the game client, so it has no effect on existing rendering until explicitly integrated.

## Thread ownership

- FNA owns `GraphicsDevice`, `Texture2D`, `SpriteBatch`, and input polling.
- An Eto-owning thread may publish an immutable `FnaUiFrame`.
- FNA draws the most recent published snapshot via `FnaUiRenderer.Draw`.
- FNA posts input to `FnaUiBridge` queues; the Eto thread consumes these and implements control hit testing and event dispatch.
- SDL3 IME/text input must be passed explicitly via `PostText`; keyboard key codes are not text.

## Example host wiring

```csharp
// Eto thread:
var bridge = new Eto.FNA.FnaUiBridge();
bridge.Publish(new Eto.FNA.FnaUiFrame(new[]
{
    new Eto.FNA.FnaUiQuad(new Microsoft.Xna.Framework.Rectangle(12, 12, 200, 44),
        Microsoft.Xna.Framework.Color.DarkSlateGray)
}));

// FNA Game.LoadContent (game thread):
var renderer = new Eto.FNA.FnaUiRenderer(GraphicsDevice);
var input = new Eto.FNA.FnaInputAdapter();

// FNA Game.Update:
input.Capture(bridge);

// FNA Game.Draw:
spriteBatch.Begin(samplerState: SamplerState.PointClamp);
renderer.Draw(spriteBatch, bridge.Snapshot());
spriteBatch.End();

// Eto event pump:
while (bridge.TryReadPointer(out var pointer)) { /* hit test and dispatch */ }
while (bridge.TryReadKey(out var key)) { /* dispatch keyboard */ }
while (bridge.TryReadText(out var text)) { /* dispatch text/IME */ }
```

## Next stages

Implement Eto platform handlers, basic layout, button/label/text input, fonts and graphics primitives, focus, keyboard and SDL3 text input, and a demonstration FNA host. Do not access Eto controls directly from FNA's render thread.
