Attribute VB_Name = "modDeclares"
Public Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hWnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Public Const GWL_EXSTYLE = (-20)
Public Const WS_EX_TRANSPARENT = &H20&
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Created module.
' ****************************************************************

Option Explicit

Public Declare Function GetAsyncKeyState Lib "user32" (ByVal vKey As Long) As Integer
Attribute GetAsyncKeyState.VB_UserMemId = 1879048228
Public Declare Function GetKeyState Lib "user32" (ByVal nVirtKey As Long) As Integer
Attribute GetKeyState.VB_UserMemId = 1879048268
Public Declare Function GetTickCount Lib "kernel32" () As Long
Attribute GetTickCount.VB_UserMemId = 1879048300
Public Declare Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, ByVal X As Long, ByVal Y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal dwRop As Long) As Long
Attribute BitBlt.VB_UserMemId = 1879048336
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Attribute Sleep.VB_UserMemId = 1879048364

' Sound declares
Public Declare Function mciSendString Lib "winmm.dll" Alias "mciSendStringA" (ByVal lpstrCommand As String, ByVal lpstrReturnString As String, ByVal uReturnLength As Long, ByVal hwndCallback As Long) As Long
Attribute mciSendString.VB_UserMemId = 1879048392
Public Declare Function sndPlaySound Lib "winmm.dll" Alias "sndPlaySoundA" (ByVal lpszSoundName As String, ByVal uFlags As Long) As Long
Attribute sndPlaySound.VB_UserMemId = 1879048428

' Text declares
Public Declare Function CreateFont Lib "gdi32" Alias "CreateFontA" (ByVal H As Long, ByVal W As Long, ByVal E As Long, ByVal O As Long, ByVal W As Long, ByVal i As Long, ByVal u As Long, ByVal S As Long, ByVal C As Long, ByVal OP As Long, ByVal CP As Long, ByVal Q As Long, ByVal PAF As Long, ByVal F As String) As Long
Attribute CreateFont.VB_UserMemId = 1879048464
Public Declare Function SetBkMode Lib "gdi32" (ByVal hDC As Long, ByVal nBkMode As Long) As Long
Attribute SetBkMode.VB_UserMemId = 1879048496
Public Declare Function SetTextColor Lib "gdi32" (ByVal hDC As Long, ByVal crColor As Long) As Long
Attribute SetTextColor.VB_UserMemId = 1879048528
Public Declare Function TextOut Lib "gdi32" Alias "TextOutA" (ByVal hDC As Long, ByVal X As Long, ByVal Y As Long, ByVal lpString As String, ByVal nCount As Long) As Long
Attribute TextOut.VB_UserMemId = 1879048564
Public Declare Function SelectObject Lib "gdi32" (ByVal hDC As Long, ByVal hObject As Long) As Long
Attribute SelectObject.VB_UserMemId = 1879048596

' Alpha Belnding Delcares
Public Declare Function timeGetTime Lib "winmm.dll" () As Long
Attribute timeGetTime.VB_UserMemId = 1879048632

Public Declare Function asmShl Lib "Shift" (ByVal PassedVar As Long, ByVal NumBits As Long)
Attribute asmShl.VB_UserMemId = 1879048664
Public Declare Function asmShr Lib "Shift" (ByVal PassedVar As Long, ByVal NumBits As Long)
Attribute asmShr.VB_UserMemId = 1879048692


' Move Form Declares
Public Declare Function ReleaseCapture Lib "user32" () As Long
Attribute ReleaseCapture.VB_UserMemId = 1879048936
Public Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
Attribute SendMessage.VB_UserMemId = 1879048972
Public Declare Function GetTextExtentPoint32 Lib "gdi32" Alias "GetTextExtentPoint32A" (ByVal hDC As Long, ByVal lpsz As String, ByVal cbString As Long, lpSize As TextSize) As Long
Attribute GetTextExtentPoint32.VB_UserMemId = 1879049008
