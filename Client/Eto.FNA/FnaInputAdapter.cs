using Microsoft.Xna.Framework.Input;

namespace Eto.FNA;

/// <summary>
/// Polls native FNA input and emits messages for Eto's owning thread.
/// Execute Capture only on the FNA game thread.
/// </summary>
public sealed class FnaInputAdapter
{
    private MouseState _previousMouse;
    private KeyboardState _previousKeyboard;
    private bool _initialized;

    public void Capture(FnaUiBridge bridge, Func<int, int, (int X, int Y)>? transform = null)
    {
        ArgumentNullException.ThrowIfNull(bridge);
        var mouse = Mouse.GetState();
        var keyboard = Keyboard.GetState();
        if (!_initialized)
        {
            _previousMouse = mouse;
            _previousKeyboard = keyboard;
            _initialized = true;
            return;
        }
        var (x, y) = transform?.Invoke(mouse.X, mouse.Y) ?? (mouse.X, mouse.Y);
        if (mouse.X != _previousMouse.X || mouse.Y != _previousMouse.Y)
            bridge.PostPointer(new(FnaUiPointerKind.Move, x, y, 0));
        ButtonTransition(mouse.LeftButton, _previousMouse.LeftButton, 1);
        ButtonTransition(mouse.RightButton, _previousMouse.RightButton, 2);
        ButtonTransition(mouse.MiddleButton, _previousMouse.MiddleButton, 3);
        if (mouse.ScrollWheelValue != _previousMouse.ScrollWheelValue)
            bridge.PostPointer(new(FnaUiPointerKind.Wheel, x, y, 0, mouse.ScrollWheelValue - _previousMouse.ScrollWheelValue));
        foreach (var key in keyboard.GetPressedKeys())
            if (!_previousKeyboard.IsKeyDown(key)) bridge.PostKey(new((int)key, true));
        foreach (var key in _previousKeyboard.GetPressedKeys())
            if (!keyboard.IsKeyDown(key)) bridge.PostKey(new((int)key, false));
        _previousMouse = mouse;
        _previousKeyboard = keyboard;

        void ButtonTransition(ButtonState current, ButtonState previous, int button)
        {
            if (current == previous) return;
            bridge.PostPointer(new(current == ButtonState.Pressed ? FnaUiPointerKind.Down : FnaUiPointerKind.Up, x, y, button));
        }
    }
}
