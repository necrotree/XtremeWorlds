# XtremeWorlds menu: real Eto controls + twinBASIC skin

This revision keeps the menu implemented with real Eto.Forms controls and dynamic layouts.

## UI controls

- Eto `Button` / `LegacyButton`
- Eto `TextBox`
- Eto `PasswordBox`
- Eto `RadioButton`
- Eto `ListBox`
- Eto `ImageView`
- Eto `Panel`
- Eto `TableLayout`
- Eto `StackLayout`

`frmMainMenu.vb` contains no `PixelLayout` and no `Drawable` click hitboxes.

## Skinning

The twinBASIC PNG artwork is used as the visual skin. On Windows, `WpfMenuSkin.cs` applies that artwork to the native rendering of the Eto panels while keeping the Eto widgets as the controls receiving focus, keyboard input, clicks, selection, and text entry.

The Windows backend remains `Eto.Platform.Wpf 2.12.0` and uses the Eto 2.12 theme system.

## Main menu

- `background.png` is the window background.
- `logo.png` is an Eto `ImageView`.
- `imgMainMenu.png` skins a real Eto panel containing real Login/Register Eto buttons.
- `exit.png` skins a real Eto panel containing real Website/Exit Eto buttons.

## Submenus

Login/Register/Characters/New Character/Class Select each use a real Eto `Panel` with TableLayout/StackLayout children. The panel receives the original twinBASIC image as its WPF background. Text inputs and buttons remain actual Eto controls and are positioned by layout rows/spacers over the artwork.

## Asset packaging fix

The source ZIP now contains the menu PNGs in two places intentionally:

- `Core/Assets/frmMainMenu/` is the canonical application asset tree used by Eto.
- `ProvidedMenuImages/` contains the original menu images supplied during conversion for easy visual comparison/replacement.

The Windows project also copies `Core/Assets/**` into `Assets/**` beside the executable during build/publish. `AssetLoader` first checks embedded Core resources and then falls back to those physical files. This removes the previous dependency on the exact embedded-resource name.
