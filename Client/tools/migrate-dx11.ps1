$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$ansi = [Text.Encoding]::GetEncoding(1252)
$utf8 = New-Object Text.UTF8Encoding($false)

$initialization = @'
Attribute VB_Name = "modDirectX"
Option Explicit

Public Sub InitDirectX()
    DestroyDirectX
    DX11Initialize frmMainGame.picScreen.hwnd
    InitSurfaces
End Sub

Private Function NewSurface(ByVal Width As Long, ByVal Height As Long) As clsDX11Surface
    Dim Surface As New clsDX11Surface
    Surface.Create Width, Height
    Set NewSurface = Surface
End Function

Private Function LoadSurface(ByVal FileName As String) As clsDX11Surface
    Dim Surface As New clsDX11Surface
    Surface.LoadFromFile FileName
    Surface.ColorKey = 0
    Set LoadSurface = Surface
End Function

Public Sub InitSurfaces()
    Dim Prefix As String
    Prefix = App.Path & GFX_PATH
    Set DD_BackBuffer = NewSurface((MAX_MAPX + 1) * PIC_X, (MAX_MAPY + 1) * PIC_Y)
    Set DD_LowerBuffer = NewSurface(DD_BackBuffer.Width, DD_BackBuffer.Height)
    Set DD_MiddleBuffer = NewSurface(DD_BackBuffer.Width, DD_BackBuffer.Height)
    Set DD_UpperBuffer = NewSurface(DD_BackBuffer.Width, DD_BackBuffer.Height)
    Set DD_SpriteSurf = LoadSurface(Prefix & "sprites" & GFX_EXT)
    Set DD_TileSurf = LoadSurface(Prefix & "tiles" & GFX_EXT)
    Set DD_ItemSurf = LoadSurface(Prefix & "items" & GFX_EXT)
    Set DD_SpellSurf = LoadSurface(Prefix & "spells" & GFX_EXT)
End Sub

Public Sub DestroyDirectX()
    Set DD_SpriteSurf = Nothing
    Set DD_TileSurf = Nothing
    Set DD_ItemSurf = Nothing
    Set DD_SpellSurf = Nothing
    Set DD_ArrowSurf = Nothing
    Set DD_BackBuffer = Nothing
    Set DD_LowerBuffer = Nothing
    Set DD_MiddleBuffer = Nothing
    Set DD_UpperBuffer = Nothing
    DX11Shutdown
End Sub

Public Function NeedToRestoreSurfaces() As Boolean
    NeedToRestoreSurfaces = DX11DeviceLost()
End Function

Public Sub CheckSurfaces()
    If NeedToRestoreSurfaces Then
        InitDirectX
        If Not GettingMap Then BltMap
    End If
End Sub

Public Sub PresentGameFrame()
    On Error GoTo Failed
    DX11Present DD_BackBuffer
    Exit Sub
Failed:
    Dim ErrorNumber As Long, ErrorText As String
    ErrorNumber = Err.Number
    ErrorText = Err.Description
    If DX11DeviceLost Then
        CheckSurfaces
    Else
        Err.Raise ErrorNumber, "Direct3D 11 presentation", ErrorText
    End If
End Sub

Public Sub SetMaskColorFromPixel(ByRef TheSurface As clsDX11Surface, ByVal X As Long, ByVal Y As Long)
    TheSurface.ColorKey = TheSurface.PixelColor(X, Y)
End Sub


'@

$alpha = @'
Public Sub vbDABLDraw16(surface As clsDX11Surface, srcRect As RECT, X As Long, Y As Long, alphaval As Long, ScreenWidth As Integer, ScreenHeight As Integer, Optional Clip As Boolean = True)
    ' Keep the old entry point for callers; blending now uses a 32-bit GPU texture.
    Dim Source As RECT, Destination As RECT
    Source = srcRect
    Destination.Left = X
    Destination.Top = Y
    Destination.Right = X + Source.Right - Source.Left
    Destination.Bottom = Y + Source.Bottom - Source.Top
    If Clip Then
        If Destination.Left < 0 Then
            Source.Left = Source.Left - Destination.Left
            Destination.Left = 0
        End If
        If Destination.Top < 0 Then
            Source.Top = Source.Top - Destination.Top
            Destination.Top = 0
        End If
        If Destination.Right > ScreenWidth Then
            Source.Right = Source.Right - (Destination.Right - ScreenWidth)
            Destination.Right = ScreenWidth
        End If
        If Destination.Bottom > ScreenHeight Then
            Source.Bottom = Source.Bottom - (Destination.Bottom - ScreenHeight)
            Destination.Bottom = ScreenHeight
        End If
    End If
    If Source.Right <= Source.Left Or Source.Bottom <= Source.Top Then Exit Sub
    DD_BackBuffer.Blt Destination, surface, Source, True, alphaval
End Sub
'@

foreach ($folder in @('Src', 'DX11Project/Sources/Src')) {
    $encoding = if ($folder -eq 'Src') { $ansi } else { $utf8 }
    foreach ($name in @('modGlobals.bas', 'modDirectX.bas', 'modGameLogic.bas', 'modGameEditors.bas', 'modDeclares.bas')) {
        $path = Join-Path $root "$folder/$name"
        $text = [IO.File]::ReadAllText($path, $encoding)
        switch ($name) {
            'modGlobals.bas' {
                $text = [regex]::Replace($text, "(?s)' Legacy DirectX 7 compatibility declarations.*?(?=' for MyEtxt)", '')
                $text = [regex]::Replace($text, '(?m)^Public (DX As New DirectX7|DD As DirectDraw7|DD_PrimarySurf As DirectDrawSurface7|DD_Clip As DirectDrawClipper|DDSD_\w+ As (?:modGlobals\.)?DDSURFACEDESC2|Ddsd2 As (?:modGlobals\.)?DDSURFACEDESC2)\r?\n', '')
                $text = $text.Replace('As DirectDrawSurface7', 'As clsDX11Surface').Replace("' DirectX variables", "' Direct3D 11 textures and map layers")
            }
            'modDirectX.bas' {
                if ($text.Contains('Public Sub BltMap()')) {
                    $text = $initialization.Replace("'@", '') + "`r`n" + $text.Substring($text.IndexOf('Public Sub BltMap()'))
                }
            }
            'modGameLogic.bas' {
                $text = $text.Replace('    Call InitSurfaces', "    ' InitDirectX creates all surfaces.")
                $text = [regex]::Replace($text, "(?s)            ' Get the rect to blit to.*?Call DD_PrimarySurf\.Blt\([^\r\n]+", "            ' Present to the game picture box through the DXGI swap chain.`r`n            Call PresentGameFrame")
                $text = [regex]::Replace($text, '(?s)Public Sub vbDABLDraw16\(.*?End Sub', $alpha)
                $text = $text.Replace('Call SetStatus("Initializing DirectX")', 'Call SetStatus("Initializing Direct3D 11")')
                $text = $text.Replace("            If Not GettingMap Then", "            Call CheckSurfaces`r`n`r`n            If Not GettingMap Then")
                $text = [regex]::Replace($text, '(?m)^                Call CheckSurfaces\r?\n', '')
            }
            'modGameEditors.bas' { $text = $text.Replace('DDSD_Tile.lHeight', 'DD_TileSurf.Height') }
            'modDeclares.bas' {
                $text = [regex]::Replace($text, '(?m)^(Public Declare Function vbDABL[^\r\n]*|Attribute vbDABL[^\r\n]*)\r?\n', '')
            }
        }
        $text = $text.Replace('DDBLTFAST_WAIT Or DDBLTFAST_SRCCOLORKEY', 'True').Replace('DDBLTFAST_WAIT', 'False')
        [IO.File]::WriteAllText($path, $text, $encoding)
    }
}
foreach ($name in @('modDX11.bas', 'clsDX11Surface.cls')) {
    Copy-Item -LiteralPath (Join-Path $root "Src/$name") -Destination (Join-Path $root "DX11Project/Sources/Src/$name")
}
$settingsPath = Join-Path $root 'DX11Project/Settings'
$settings = [IO.File]::ReadAllText($settingsPath, $utf8) | ConvertFrom-Json
$settings.'project.references' = @($settings.'project.references' | Where-Object { $_.symbolId -ne 'DxVBLib' })
$settings.'project.versionComments' = 'Direct3D 11 renderer'
[IO.File]::WriteAllText($settingsPath, ($settings | ConvertTo-Json -Depth 30), $utf8)
