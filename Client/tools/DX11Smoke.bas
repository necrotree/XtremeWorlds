Attribute VB_Name = "DX11Smoke"
Option Explicit

Private Sub Require(ByVal Condition As Boolean, ByVal Description As String)
    If Not Condition Then Err.Raise 5, "DX11 smoke test", Description
End Sub

Public Sub Main()
    Dim Window As LongPtr, DC As LongPtr
    Dim Source As clsDX11Surface, Target As clsDX11Surface, Image As clsDX11Surface
    Dim Bounds As WinDevLib.RECT, Pixel As WinDevLib.RECT, Destination As WinDevLib.RECT
    Dim Color As Long, FileNumber As Integer, Report As String, ErrorNumber As Long
    On Error GoTo Failed
    Window = WinDevLib.CreateWindowEx(0, "STATIC", "Playerworlds renderer test", 0, 0, 0, 64, 64, 0, 0, 0, ByVal vbNullPtr)
    Require Window <> 0, "Creating hidden test window"
    DX11Initialize Window
    Set Source = New clsDX11Surface
    Set Target = New clsDX11Surface
    Source.Create 4, 4
    Target.Create 8, 8
    Bounds.Right = 4
    Bounds.Bottom = 4
    Source.BltColorFill Bounds, RGB(255, 0, 0)
    Pixel.Right = 1
    Pixel.Bottom = 1
    Source.BltColorFill Pixel, 0
    Destination.Right = 8
    Destination.Bottom = 8
    Target.BltColorFill Destination, RGB(0, 0, 255)
    Target.BltFast 1, 1, Source, Bounds, True
    Require Target.PixelColor(1, 1) = RGB(0, 0, 255), "Black color-key transparency"
    Require Target.PixelColor(2, 1) = RGB(255, 0, 0), "Sprite pixel coordinates / channel order"
    Target.BltFast 0, 0, Source, Pixel, False
    Require Target.PixelColor(0, 0) = 0, "Opaque black pixels"
    Target.BltColorFill Destination, RGB(0, 0, 255)
    Target.Blt Destination, Source, Bounds, True, 128
    Color = Target.PixelColor(4, 4)
    Require Abs((Color And &HFF&) - 128) <= 1, "Alpha blend red channel"
    Require Abs(((Color \ &H10000) And &HFF&) - 127) <= 1, "Alpha blend blue channel"
    Target.BltFast -2, -2, Source, Bounds, False
    Require Target.PixelColor(0, 0) = RGB(255, 0, 0), "Negative destination clipping"
    DC = Target.GetDC
    WinDevLib.SetPixel DC, 7, 7, RGB(0, 255, 0)
    Target.ReleaseDC DC
    DC = 0
    Require Target.PixelColor(7, 7) = RGB(0, 255, 0), "GDI surface round trip"
    Set Image = New clsDX11Surface
    Image.LoadFromFile App.Path & "\Gfx\sprites.bmp"
    Require Image.Width > 0 And Image.Height > 0, "WIC sprite loading"
    Image.LoadFromFile App.Path & "\Gfx\tiles.bmp"
    Require Image.Height > 16384, "Oversize tile sheet dimensions preserved"
    Bounds.Left = 0
    Bounds.Top = 4094
    Bounds.Right = 4
    Bounds.Bottom = 4098
    Target.BltFast 0, 0, Image, Bounds, False
    Require Target.PixelColor(0, 0) = Image.PixelColor(0, 4094), "First page boundary pixel"
    Require Target.PixelColor(0, 3) = Image.PixelColor(0, 4097), "Second page boundary pixel"
    Bounds.Top = Image.Height - 4
    Bounds.Bottom = Image.Height
    Target.BltFast 0, 0, Image, Bounds, False
    Require Target.PixelColor(0, 3) = Image.PixelColor(0, Image.Height - 1), "Last texture page"
    Image.LoadFromFile App.Path & "\Gfx\items.bmp"
    Image.LoadFromFile App.Path & "\Gfx\spells.bmp"
    DX11Present Target
    WinDevLib.SetWindowPos Window, 0, 0, 0, 96, 80, WinDevLib.SWP_NOMOVE Or WinDevLib.SWP_NOZORDER Or WinDevLib.SWP_NOACTIVATE
    DX11Present Target
    Require Not DX11DeviceLost(), "Present and resize"
    Set Image = Nothing
    Set Source = Nothing
    Set Target = Nothing
    DX11Shutdown
    DX11Initialize Window
    Set Target = New clsDX11Surface
    Target.Create 8, 8
    Target.BltColorFill Destination, RGB(255, 255, 0)
    Require Target.PixelColor(3, 3) = RGB(255, 255, 0), "Device recreation"
    Report = "PASS: texture creation, sprite coordinates, color key, opaque black, alpha, clipping, GDI, WIC assets, present, resize, device recreation."
    GoTo Cleanup
Failed:
    ErrorNumber = Err.Number
    Report = "FAIL 0x" & Hex$(ErrorNumber) & ": " & Err.Source & " - " & Err.Description
Cleanup:
    On Error Resume Next
    If DC <> 0 Then Target.ReleaseDC DC
    Set Image = Nothing
    Set Source = Nothing
    Set Target = Nothing
    DX11Shutdown
    If Window <> 0 Then WinDevLib.DestroyWindow Window
    FileNumber = FreeFile
    Open App.Path & "\DX11-smoke-result.txt" For Output As #FileNumber
    Print #FileNumber, Report
    Close #FileNumber
End Sub
