Attribute VB_Name = "SurfUtil"
Option Explicit

' WIC decodes BMP/PNG/JPEG into a Direct3D 11 texture without PaintX or DX7.
Public Function LoadImage(ByVal FileName As String) As clsDX11Surface
    Dim Surface As New clsDX11Surface
    Surface.LoadFromFile FileName
    Set LoadImage = Surface
End Function

Public Function LoadImageStretch(ByVal FileName As String, ByVal Height As Long, ByVal Width As Long) As clsDX11Surface
    Dim Source As clsDX11Surface
    Dim Target As New clsDX11Surface
    Dim SourceRect As WinDevLib.RECT, Destination As WinDevLib.RECT
    Set Source = LoadImage(FileName)
    Target.Create Width, Height
    SourceRect.Right = Source.Width
    SourceRect.Bottom = Source.Height
    Destination.Right = Width
    Destination.Bottom = Height
    Target.Blt Destination, Source, SourceRect
    Set LoadImageStretch = Target
End Function