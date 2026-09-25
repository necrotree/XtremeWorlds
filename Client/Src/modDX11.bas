Attribute VB_Name = "modDX11"
Option Explicit

' Native Direct3D 11 backend. Requires the WinDevLib package embedded in the
' twinBASIC project. All rendering and resource ownership stay on the UI thread.
Public DX11Device As WinDevLib.ID3D11Device
Public DX11Context As WinDevLib.ID3D11DeviceContext
Private mSwapChain As WinDevLib.IDXGISwapChain
Private mWindowTarget As WinDevLib.ID3D11RenderTargetView
Private mVertexShader As WinDevLib.ID3D11VertexShader
Private mPixelShader As WinDevLib.ID3D11PixelShader
Private mConstants As WinDevLib.ID3D11Buffer
Private mSampler As WinDevLib.ID3D11SamplerState
Private mBlend As WinDevLib.ID3D11BlendState
Private mRasterizer As WinDevLib.ID3D11RasterizerState
Private mWindow As LongPtr
Private mWidth As Long
Private mHeight As Long
Private mDCCount As Long

' Four float4 registers, matching the HLSL cbuffer below.
Private Type SpriteConstants
    DestLeft As Single
    DestTop As Single
    DestRight As Single
    DestBottom As Single
    SourceLeft As Single
    SourceTop As Single
    SourceRight As Single
    SourceBottom As Single
    Red As Single
    Green As Single
    Blue As Single
    Opacity As Single
    UseColorKey As Single
    SolidFill As Single
    Reserved1 As Single
    Reserved2 As Single
End Type

Public Sub DX11Check(ByVal Result As Long, ByVal Operation As String)
    If Result < 0 Then Err.Raise Result, "Direct3D 11", Operation & " failed (0x" & Hex$(Result) & ")."
End Sub

Private Function CompileSpriteShader(ByVal EntryPoint As String, ByVal Profile As String) As WinDevLib.ID3DBlob
    Dim Source As String
    Dim Bytes() As Byte
    Dim Code As WinDevLib.ID3DBlob
    Dim Errors As WinDevLib.ID3DBlob
    Dim Result As Long
    Source = "cbuffer Sprite : register(b0) { float4 dst; float4 uv; float4 tint; float4 options; };" & vbCrLf
    Source = Source & "Texture2D image : register(t0); SamplerState nearestPixel : register(s0);" & vbCrLf
    Source = Source & "struct V { float4 p : SV_POSITION; float2 t : TEXCOORD0; };" & vbCrLf
    Source = Source & "V VS(uint id : SV_VertexID) { V o; float2 c = float2(id & 1, id >> 1);" & vbCrLf
    Source = Source & "o.p = float4(lerp(dst.xy, dst.zw, c), 0, 1); o.t = lerp(uv.xy, uv.zw, c); return o; }" & vbCrLf
    Source = Source & "float4 PS(V i) : SV_TARGET { if(options.y > 0.5) return tint;" & vbCrLf
    Source = Source & "float3 rgb = image.Sample(nearestPixel, i.t).rgb;" & vbCrLf
    Source = Source & "if(options.x > 0.5 && all(abs(rgb-tint.rgb) < (0.5/255.0))) discard;" & vbCrLf
    Source = Source & "return float4(rgb, tint.a); }"
    Bytes = StrConv(Source, vbFromUnicode)
    Result = WinDevLib.D3DCompile(Bytes(0), UBound(Bytes) + 1, "Playerworlds sprites", ByVal vbNullPtr, ByVal vbNullPtr, EntryPoint, Profile, 0, 0, Code, Errors)
    If Result < 0 Then
        Dim Message As String
        If Not Errors Is Nothing Then
            ReDim Bytes(0 To Errors.GetBufferSize - 1)
            WinDevLib.CopyMemory Bytes(0), ByVal Errors.GetBufferPointer, UBound(Bytes) + 1
            Message = StrConv(Bytes, vbUnicode)
        End If
        Err.Raise Result, "Direct3D 11", "Shader compilation: " & Message
    End If
    Set CompileSpriteShader = Code
End Function

Public Sub DX11Initialize(ByVal WindowHandle As LongPtr)
    Dim Desc As WinDevLib.DXGI_SWAP_CHAIN_DESC
    Dim Level As WinDevLib.D3D_FEATURE_LEVEL
    Dim Levels(0 To 2) As WinDevLib.D3D_FEATURE_LEVEL
    Dim Result As Long
    Dim Bounds As WinDevLib.RECT
    Dim Code As WinDevLib.ID3DBlob
    Dim BufferDesc As WinDevLib.D3D11_BUFFER_DESC
    Dim SamplerDesc As WinDevLib.D3D11_SAMPLER_DESC
    Dim BlendDesc As WinDevLib.D3D11_BLEND_DESC
    Dim RasterDesc As WinDevLib.D3D11_RASTERIZER_DESC
    DX11Shutdown
    On Error GoTo Failed
    If WinDevLib.GetClientRect(WindowHandle, Bounds) = 0 Then Err.Raise 5, , "Invalid game window."
    mWindow = WindowHandle
    mWidth = Bounds.Right
    mHeight = Bounds.Bottom
    If mWidth < 1 Then mWidth = 1
    If mHeight < 1 Then mHeight = 1
    With Desc
        .BufferDesc.Width = mWidth
        .BufferDesc.Height = mHeight
        .BufferDesc.Format = WinDevLib.DXGI_FORMAT_B8G8R8A8_UNORM
        .SampleDesc.Count = 1
        .BufferUsage = WinDevLib.DXGI_USAGE_RENDER_TARGET_OUTPUT
        .BufferCount = 1
        .OutputWindow = mWindow
        .Windowed = 1
        .SwapEffect = WinDevLib.DXGI_SWAP_EFFECT_DISCARD
    End With
    Levels(0) = WinDevLib.D3D_FEATURE_LEVEL_11_0
    Levels(1) = WinDevLib.D3D_FEATURE_LEVEL_10_1
    Levels(2) = WinDevLib.D3D_FEATURE_LEVEL_10_0
    Result = WinDevLib.D3D11CreateDeviceAndSwapChain(Nothing, WinDevLib.D3D_DRIVER_TYPE_HARDWARE, 0, WinDevLib.D3D11_CREATE_DEVICE_BGRA_SUPPORT, Levels(0), 3, WinDevLib.D3D11_SDK_VERSION, Desc, mSwapChain, DX11Device, Level, DX11Context)
    If Result < 0 Then
        ' WARP supports machines without a suitable hardware driver.
        Set mSwapChain = Nothing
        Set DX11Context = Nothing
        Set DX11Device = Nothing
        Result = WinDevLib.D3D11CreateDeviceAndSwapChain(Nothing, WinDevLib.D3D_DRIVER_TYPE_WARP, 0, WinDevLib.D3D11_CREATE_DEVICE_BGRA_SUPPORT, Levels(0), 3, WinDevLib.D3D11_SDK_VERSION, Desc, mSwapChain, DX11Device, Level, DX11Context)
    End If
    DX11Check Result, "Creating device and swap chain"
    CreateWindowTarget
    Set Code = CompileSpriteShader("VS", "vs_4_0")
    DX11Device.CreateVertexShader ByVal Code.GetBufferPointer, Code.GetBufferSize, Nothing, mVertexShader
    Set Code = CompileSpriteShader("PS", "ps_4_0")
    DX11Device.CreatePixelShader ByVal Code.GetBufferPointer, Code.GetBufferSize, Nothing, mPixelShader
    BufferDesc.ByteWidth = 64
    BufferDesc.Usage = WinDevLib.D3D11_USAGE_DEFAULT
    BufferDesc.BindFlags = WinDevLib.D3D11_BIND_CONSTANT_BUFFER
    DX11Device.CreateBuffer BufferDesc, ByVal vbNullPtr, mConstants
    With SamplerDesc
        .Filter = WinDevLib.D3D11_FILTER_MIN_MAG_MIP_POINT
        .AddressU = WinDevLib.D3D11_TEXTURE_ADDRESS_CLAMP
        .AddressV = WinDevLib.D3D11_TEXTURE_ADDRESS_CLAMP
        .AddressW = WinDevLib.D3D11_TEXTURE_ADDRESS_CLAMP
        .ComparisonFunc = WinDevLib.D3D11_COMPARISON_NEVER
        .MaxLOD = 3.402823E+38
    End With
    DX11Device.CreateSamplerState SamplerDesc, mSampler
    With BlendDesc.renderTarget(0)
        .BlendEnable = 1
        .SrcBlend = WinDevLib.D3D11_BLEND_SRC_ALPHA
        .DestBlend = WinDevLib.D3D11_BLEND_INV_SRC_ALPHA
        .BlendOp = WinDevLib.D3D11_BLEND_OP_ADD
        .SrcBlendAlpha = WinDevLib.D3D11_BLEND_ONE
        .DestBlendAlpha = WinDevLib.D3D11_BLEND_INV_SRC_ALPHA
        .BlendOpAlpha = WinDevLib.D3D11_BLEND_OP_ADD
        .RenderTargetWriteMask = 15
    End With
    DX11Device.CreateBlendState BlendDesc, mBlend
    RasterDesc.FillMode = WinDevLib.D3D11_FILL_SOLID
    RasterDesc.CullMode = WinDevLib.D3D11_CULL_NONE
    RasterDesc.DepthClipEnable = 1
    DX11Device.CreateRasterizerState RasterDesc, mRasterizer
    Exit Sub
Failed:
    Dim ErrorNumber As Long, ErrorText As String
    ErrorNumber = Err.Number
    ErrorText = Err.Description
    DX11Shutdown
    Err.Raise ErrorNumber, "Direct3D 11 initialization", ErrorText
End Sub

Private Sub CreateWindowTarget()
    Dim Texture As WinDevLib.ID3D11Texture2D
    mSwapChain.GetBuffer 0, WinDevLib.IID_ID3D11Texture2D, Texture
    DX11Device.CreateRenderTargetView Texture, ByVal vbNullPtr, mWindowTarget
End Sub

Public Sub DX11RequireGPU()
    If DX11Device Is Nothing Then Err.Raise 91, "Direct3D 11", "Renderer is not initialized."
    If mDCCount <> 0 Then Err.Raise 5, "Direct3D 11", "Release the GDI device context before rendering."
End Sub

Public Sub DX11AcquireDC()
    DX11RequireGPU
    DX11Context.ClearState
    mDCCount = mDCCount + 1
End Sub

Public Sub DX11ReleaseDC()
    If mDCCount > 0 Then mDCCount = mDCCount - 1
End Sub

Public Function DX11DeviceLost() As Boolean
    If DX11Device Is Nothing Then
        DX11DeviceLost = True
        Exit Function
    End If
    On Error GoTo Lost
    DX11Device.GetDeviceRemovedReason
    Exit Function
Lost:
    DX11DeviceLost = True
End Function

Private Sub DrawQuad(ByVal Target As WinDevLib.ID3D11RenderTargetView, ByVal Width As Long, ByVal Height As Long, ByVal Source As WinDevLib.ID3D11ShaderResourceView, ByRef Params As SpriteConstants)
    Dim Viewport As WinDevLib.D3D11_VIEWPORT
    Dim EmptyView As WinDevLib.ID3D11ShaderResourceView
    Dim EmptyClass As WinDevLib.ID3D11ClassInstance
    DX11RequireGPU
    Viewport.Width = Width
    Viewport.Height = Height
    Viewport.MaxDepth = 1
    DX11Context.PSSetShaderResources 0, 1, EmptyView
    DX11Context.OMSetRenderTargets 1, Target, Nothing
    DX11Context.RSSetViewports 1, Viewport
    DX11Context.RSSetState mRasterizer
    DX11Context.OMSetBlendState mBlend, ByVal vbNullPtr, -1
    DX11Context.IASetInputLayout Nothing
    DX11Context.IASetPrimitiveTopology WinDevLib.D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP
    DX11Context.UpdateSubresource mConstants, 0, ByVal vbNullPtr, Params, 0, 0
    DX11Context.VSSetConstantBuffers 0, 1, mConstants
    DX11Context.PSSetConstantBuffers 0, 1, mConstants
    DX11Context.VSSetShader mVertexShader, EmptyClass, 0
    DX11Context.PSSetShader mPixelShader, EmptyClass, 0
    DX11Context.PSSetSamplers 0, 1, mSampler
    DX11Context.PSSetShaderResources 0, 1, Source
    DX11Context.Draw 4, 0
    ' A layer may be a source now and a render target on the next call.
    DX11Context.PSSetShaderResources 0, 1, EmptyView
    DX11Context.OMSetRenderTargets 0, ByVal Nothing, Nothing
End Sub

Private Sub SetDestination(ByRef Params As SpriteConstants, ByRef Bounds As WinDevLib.RECT, ByVal Width As Long, ByVal Height As Long)
    Params.DestLeft = 2! * Bounds.Left / Width - 1!
    Params.DestRight = 2! * Bounds.Right / Width - 1!
    Params.DestTop = 1! - 2! * Bounds.Top / Height
    Params.DestBottom = 1! - 2! * Bounds.Bottom / Height
End Sub

Public Sub DX11Draw(ByVal Target As WinDevLib.ID3D11RenderTargetView, ByVal Width As Long, ByVal Height As Long, ByVal Source As clsDX11Surface, ByRef Destination As WinDevLib.RECT, ByRef SourceRect As WinDevLib.RECT, ByVal Keyed As Boolean, Optional ByVal Opacity As Long = 255)
    Dim Params As SpriteConstants
    Dim Key As Long
    If Source Is Nothing Then Err.Raise 91, "Direct3D 11", "Missing source surface."
    If Destination.Right <= Destination.Left Or Destination.Bottom <= Destination.Top Then Exit Sub
    If SourceRect.Right <= SourceRect.Left Or SourceRect.Bottom <= SourceRect.Top Then Exit Sub
    If SourceRect.Left < 0 Or SourceRect.Top < 0 Or SourceRect.Right > Source.Width Or SourceRect.Bottom > Source.Height Then Err.Raise 5, "Direct3D 11", "Source rectangle is outside the texture."
    If Opacity <= 0 Then Exit Sub
    If Opacity > 255 Then Opacity = 255
    SetDestination Params, Destination, Width, Height
    Params.SourceLeft = CSng(SourceRect.Left) / Source.Width
    Params.SourceTop = CSng(SourceRect.Top) / Source.Height
    Params.SourceRight = CSng(SourceRect.Right) / Source.Width
    Params.SourceBottom = CSng(SourceRect.Bottom) / Source.Height
    Key = Source.ColorKey
    Params.Red = CSng(Key And &HFF&) / 255!
    Params.Green = CSng((Key \ &H100&) And &HFF&) / 255!
    Params.Blue = CSng((Key \ &H10000) And &HFF&) / 255!
    Params.Opacity = CSng(Opacity) / 255!
    If Keyed Then Params.UseColorKey = 1
    DrawQuad Target, Width, Height, Source.ShaderView, Params
End Sub

Public Sub DX11Fill(ByVal Target As WinDevLib.ID3D11RenderTargetView, ByVal Width As Long, ByVal Height As Long, ByRef Bounds As WinDevLib.RECT, ByVal Color As Long)
    Dim Params As SpriteConstants
    If Bounds.Right <= Bounds.Left Or Bounds.Bottom <= Bounds.Top Then Exit Sub
    SetDestination Params, Bounds, Width, Height
    Params.Red = CSng(Color And &HFF&) / 255!
    Params.Green = CSng((Color \ &H100&) And &HFF&) / 255!
    Params.Blue = CSng((Color \ &H10000) And &HFF&) / 255!
    Params.Opacity = 1
    Params.SolidFill = 1
    DrawQuad Target, Width, Height, Nothing, Params
End Sub

Public Sub DX11Present(ByVal Surface As clsDX11Surface)
    Dim Bounds As WinDevLib.RECT
    Dim SourceRect As WinDevLib.RECT
    DX11RequireGPU
    If WinDevLib.GetClientRect(mWindow, Bounds) = 0 Then Exit Sub
    If Bounds.Right <= 0 Or Bounds.Bottom <= 0 Then Exit Sub
    If Bounds.Right <> mWidth Or Bounds.Bottom <> mHeight Then
        DX11Context.ClearState
        Set mWindowTarget = Nothing
        mSwapChain.ResizeBuffers 0, Bounds.Right, Bounds.Bottom, WinDevLib.DXGI_FORMAT_UNKNOWN, 0
        mWidth = Bounds.Right
        mHeight = Bounds.Bottom
        CreateWindowTarget
    End If
    SourceRect.Right = Surface.Width
    SourceRect.Bottom = Surface.Height
    Surface.DrawTo mWindowTarget, mWidth, mHeight, Bounds, SourceRect, False
    mSwapChain.Present 0, 0
End Sub

Public Sub DX11Shutdown()
    If Not DX11Context Is Nothing Then DX11Context.ClearState
    Set mWindowTarget = Nothing
    Set mConstants = Nothing
    Set mVertexShader = Nothing
    Set mPixelShader = Nothing
    Set mSampler = Nothing
    Set mBlend = Nothing
    Set mRasterizer = Nothing
    Set mSwapChain = Nothing
    Set DX11Context = Nothing
    Set DX11Device = Nothing
    mWindow = 0
    mWidth = 0
    mHeight = 0
    mDCCount = 0
End Sub
