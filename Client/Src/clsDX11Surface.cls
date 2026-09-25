VERSION 1.0 CLASS
BEGIN
  MultiUse = -1
END
Attribute VB_Name = "clsDX11Surface"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' WinDevLib also exports a STRETCHBLT enum member; use an unambiguous alias.
Private Declare PtrSafe Function PreviewStretchBlt Lib "gdi32" Alias "StretchBlt" (ByVal DestDC As LongPtr, ByVal X As Long, ByVal Y As Long, ByVal Width As Long, ByVal Height As Long, ByVal SourceDC As LongPtr, ByVal SourceX As Long, ByVal SourceY As Long, ByVal SourceWidth As Long, ByVal SourceHeight As Long, ByVal RasterOperation As Long) As Long

Private mTexture As WinDevLib.ID3D11Texture2D
Private mTarget As WinDevLib.ID3D11RenderTargetView
Private mView As WinDevLib.ID3D11ShaderResourceView
Private mSurface As WinDevLib.IDXGISurface1
Private mWidth As Long
Private mHeight As Long
Private mColorKey As Long
Private mDC As LongPtr
Private mPages As Collection
Private Const PageHeight As Long = 4096

Public Property Get Width() As Long
    Width = mWidth
End Property

Public Property Get Height() As Long
    Height = mHeight
End Property

Public Property Get ShaderView() As WinDevLib.ID3D11ShaderResourceView
    Set ShaderView = mView
End Property

Public Property Get ColorKey() As Long
    ColorKey = mColorKey
End Property

Public Property Let ColorKey(ByVal Value As Long)
    mColorKey = Value And &HFFFFFF
End Property

Public Sub Create(ByVal Width As Long, ByVal Height As Long)
    Dim Desc As WinDevLib.D3D11_TEXTURE2D_DESC
    Dim Bounds As WinDevLib.RECT
    DX11RequireGPU
    If Width < 1 Or Height < 1 Then Err.Raise 5, , "Invalid surface dimensions."
    CloseSurface
    With Desc
        .Width = Width
        .Height = Height
        .MipLevels = 1
        .ArraySize = 1
        .Format = WinDevLib.DXGI_FORMAT_B8G8R8A8_UNORM
        .SampleDesc.Count = 1
        .Usage = WinDevLib.D3D11_USAGE_DEFAULT
        .BindFlags = WinDevLib.D3D11_BIND_RENDER_TARGET Or WinDevLib.D3D11_BIND_SHADER_RESOURCE
        .MiscFlags = WinDevLib.D3D11_RESOURCE_MISC_GDI_COMPATIBLE
    End With
    DX11Device.CreateTexture2D Desc, ByVal vbNullPtr, mTexture
    DX11Device.CreateRenderTargetView mTexture, ByVal vbNullPtr, mTarget
    DX11Device.CreateShaderResourceView mTexture, ByVal vbNullPtr, mView
    Set mSurface = mTexture
    mWidth = Width
    mHeight = Height
    Bounds.Right = Width
    Bounds.Bottom = Height
    BltColorFill Bounds, 0
End Sub

Public Sub LoadFromFile(ByVal FileName As String)
    Dim Factory As New WinDevLib.WICImagingFactory
    Dim Decoder As WinDevLib.IWICBitmapDecoder
    Dim Frame As WinDevLib.IWICBitmapFrameDecode
    Dim Converter As WinDevLib.IWICFormatConverter
    Dim Width As Long, Height As Long
    Dim Pixels() As Byte
    Dim Region As WinDevLib.WICRect
    Dim Page As clsDX11Surface, OffsetY As Long, Rows As Long
    Set Decoder = Factory.CreateDecoderFromFilename(StrPtr(FileName), ByVal vbNullPtr, WinDevLib.GENERIC_READ, WinDevLib.WICDecodeMetadataCacheOnLoad)
    Set Frame = Decoder.GetFrame(0)
    DX11Check Frame.GetSize(Width, Height), "Reading image dimensions"
    ' Original tile sheets exceed D3D11's 16384-pixel texture height. Store them
    ' in vertical pages, retaining the original coordinates used by the game.
    If Width < 1 Or Height < 1 Or Width > 8192 Or Height > 1048576 Then Err.Raise 5, , "Unsupported image dimensions: " & FileName
    Set Converter = Factory.CreateFormatConverter
    DX11Check Converter.Initialize(Frame, WinDevLib.GUID_WICPixelFormat32bppBGRA, WinDevLib.WICBitmapDitherTypeNone, Nothing, 0, WinDevLib.WICBitmapPaletteTypeCustom), "Decoding image"
    If Height <= PageHeight Then
        ReDim Pixels(0 To Width * Height * 4 - 1)
        DX11Check Converter.CopyPixels(ByVal vbNullPtr, Width * 4, Width * Height * 4, Pixels(0)), "Reading image pixels"
        Create Width, Height
        Upload Pixels
    Else
        CloseSurface
        Set mPages = New Collection
        mWidth = Width
        mHeight = Height
        For OffsetY = 0 To Height - 1 Step PageHeight
            Rows = Height - OffsetY
            If Rows > PageHeight Then Rows = PageHeight
            Region.X = 0
            Region.Y = OffsetY
            Region.Width = Width
            Region.Height = Rows
            ReDim Pixels(0 To Width * Rows * 4 - 1)
            DX11Check Converter.CopyPixels(Region, Width * 4, Width * Rows * 4, Pixels(0)), "Reading image page"
            Set Page = New clsDX11Surface
            Page.Create Width, Rows
            Page.Upload Pixels
            mPages.Add Page
        Next
    End If
End Sub

Friend Sub Upload(ByRef Pixels() As Byte)
    DX11RequireGPU
    DX11Context.UpdateSubresource mTexture, 0, ByVal vbNullPtr, Pixels(0), mWidth * 4, 0
End Sub

Private Function PageRectangles(ByVal PageIndex As Long, ByRef SourceRect As WinDevLib.RECT, ByRef Destination As WinDevLib.RECT, ByRef PageSource As WinDevLib.RECT, ByRef PageDestination As WinDevLib.RECT) As Boolean
    Dim OffsetY As Long, FirstRow As Long, LastRow As Long
    Dim Page As clsDX11Surface
    Set Page = mPages.Item(PageIndex)
    OffsetY = (PageIndex - 1) * PageHeight
    FirstRow = SourceRect.Top
    If FirstRow < OffsetY Then FirstRow = OffsetY
    LastRow = SourceRect.Bottom
    If LastRow > OffsetY + Page.Height Then LastRow = OffsetY + Page.Height
    If LastRow <= FirstRow Or SourceRect.Right <= SourceRect.Left Then Exit Function
    PageSource = SourceRect
    PageSource.Top = FirstRow - OffsetY
    PageSource.Bottom = LastRow - OffsetY
    PageDestination = Destination
    PageDestination.Top = Destination.Top + CLng(CDbl(FirstRow - SourceRect.Top) * (Destination.Bottom - Destination.Top) / (SourceRect.Bottom - SourceRect.Top))
    PageDestination.Bottom = Destination.Top + CLng(CDbl(LastRow - SourceRect.Top) * (Destination.Bottom - Destination.Top) / (SourceRect.Bottom - SourceRect.Top))
    PageRectangles = True
End Function

Public Sub DrawTo(ByVal Target As WinDevLib.ID3D11RenderTargetView, ByVal TargetWidth As Long, ByVal TargetHeight As Long, ByRef Destination As WinDevLib.RECT, ByRef SourceRect As WinDevLib.RECT, ByVal Keyed As Boolean, Optional ByVal Opacity As Long = 255)
    Dim I As Long, Page As clsDX11Surface
    Dim PageSource As WinDevLib.RECT, PageDestination As WinDevLib.RECT
    If mPages Is Nothing Then
        DX11Draw Target, TargetWidth, TargetHeight, Me, Destination, SourceRect, Keyed, Opacity
    Else
        If SourceRect.Left < 0 Or SourceRect.Top < 0 Or SourceRect.Right > mWidth Or SourceRect.Bottom > mHeight Then Err.Raise 5, , "Source rectangle is outside the image."
        For I = 1 To mPages.Count
            If PageRectangles(I, SourceRect, Destination, PageSource, PageDestination) Then
                Set Page = mPages.Item(I)
                Page.ColorKey = mColorKey
                DX11Draw Target, TargetWidth, TargetHeight, Page, PageDestination, PageSource, Keyed, Opacity
            End If
        Next
    End If
End Sub

Public Sub BltFast(ByVal X As Long, ByVal Y As Long, ByVal Source As clsDX11Surface, ByRef SourceRect As WinDevLib.RECT, Optional ByVal Keyed As Boolean = False)
    Dim Destination As WinDevLib.RECT
    Destination.Left = X
    Destination.Top = Y
    Destination.Right = X + SourceRect.Right - SourceRect.Left
    Destination.Bottom = Y + SourceRect.Bottom - SourceRect.Top
    Blt Destination, Source, SourceRect, Keyed
End Sub

Public Sub Blt(ByRef Destination As WinDevLib.RECT, ByVal Source As clsDX11Surface, ByRef SourceRect As WinDevLib.RECT, Optional ByVal Keyed As Boolean = False, Optional ByVal Opacity As Long = 255)
    If Source Is Me Then Err.Raise 5, , "Cannot draw a texture onto itself."
    Source.DrawTo mTarget, mWidth, mHeight, Destination, SourceRect, Keyed, Opacity
End Sub

Public Sub BltColorFill(ByRef Bounds As WinDevLib.RECT, ByVal Color As Long)
    DX11Fill mTarget, mWidth, mHeight, Bounds, Color
End Sub

Public Function GetDC() As LongPtr
    If Not mPages Is Nothing Then Err.Raise 5, , "Use BltToDC or PixelColor for a paged image."
    If mDC <> 0 Then Err.Raise 5, , "Surface DC is already acquired."
    DX11AcquireDC
    On Error GoTo Failed
    mSurface.GetDC 0, mDC
    GetDC = mDC
    Exit Function
Failed:
    Dim ErrorNumber As Long, ErrorText As String
    ErrorNumber = Err.Number
    ErrorText = Err.Description
    DX11ReleaseDC
    Err.Raise ErrorNumber, "Direct3D 11 GetDC", ErrorText
End Function

Public Sub ReleaseDC(ByVal DC As LongPtr)
    If mDC = 0 Or DC <> mDC Then Err.Raise 5, , "Surface DC does not match."
    On Error GoTo Failed
    mSurface.ReleaseDC ByVal vbNullPtr
    mDC = 0
    DX11ReleaseDC
    Exit Sub
Failed:
    Dim ErrorNumber As Long, ErrorText As String
    ErrorNumber = Err.Number
    ErrorText = Err.Description
    mDC = 0
    DX11ReleaseDC
    Err.Raise ErrorNumber, "Direct3D 11 ReleaseDC", ErrorText
End Sub

' Preserve the client's source-rectangle, destination-rectangle call order.
Public Sub BltToDC(ByVal DestinationDC As LongPtr, ByRef SourceRect As WinDevLib.RECT, ByRef Destination As WinDevLib.RECT)
    Dim DC As LongPtr, OldMode As Long, Result As Long
    Dim I As Long, Page As clsDX11Surface
    Dim PageSource As WinDevLib.RECT, PageDestination As WinDevLib.RECT
    If Not mPages Is Nothing Then
        For I = 1 To mPages.Count
            If PageRectangles(I, SourceRect, Destination, PageSource, PageDestination) Then
                Set Page = mPages.Item(I)
                Page.BltToDC DestinationDC, PageSource, PageDestination
            End If
        Next
        Exit Sub
    End If
    DC = GetDC
    OldMode = WinDevLib.SetStretchBltMode(DestinationDC, WinDevLib.COLORONCOLOR)
    Result = PreviewStretchBlt(DestinationDC, Destination.Left, Destination.Top, Destination.Right - Destination.Left, Destination.Bottom - Destination.Top, DC, SourceRect.Left, SourceRect.Top, SourceRect.Right - SourceRect.Left, SourceRect.Bottom - SourceRect.Top, WinDevLib.SRCCOPY)
    If OldMode <> 0 Then WinDevLib.SetStretchBltMode DestinationDC, OldMode
    ReleaseDC DC
    If Result = 0 Then Err.Raise 5, "Direct3D 11", "Editor preview copy failed."
End Sub

Public Function PixelColor(ByVal X As Long, ByVal Y As Long) As Long
    Dim DC As LongPtr
    Dim Page As clsDX11Surface
    If X < 0 Or Y < 0 Or X >= mWidth Or Y >= mHeight Then Err.Raise 5, , "Pixel is outside surface."
    If Not mPages Is Nothing Then
        Set Page = mPages.Item(Y \ PageHeight + 1)
        PixelColor = Page.PixelColor(X, Y Mod PageHeight)
        Exit Function
    End If
    DC = GetDC
    PixelColor = WinDevLib.GetPixel(DC, X, Y)
    ReleaseDC DC
End Function

Public Sub CloseSurface()
    On Error Resume Next
    If mDC <> 0 Then ReleaseDC mDC
    Set mPages = Nothing
    Set mSurface = Nothing
    Set mView = Nothing
    Set mTarget = Nothing
    Set mTexture = Nothing
    mWidth = 0
    mHeight = 0
End Sub

Private Sub Class_Terminate()
    CloseSurface
End Sub
