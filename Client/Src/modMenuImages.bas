Attribute VB_Name = "modMenuImages"
Option Explicit

' Image controls have no hDC. Render into an owned bitmap, then hand its
' IPictureDisp to the Image control; no hidden PictureBox is required.
Private Type MenuPictureGuid
    Data1 As Long
    Data2 As Integer
    Data3 As Integer
    Data4(0 To 7) As Byte
End Type

Private Type MenuPictureDescriptor
    Size As Long
    Kind As Long
    Bitmap As LongPtr
    Palette As LongPtr
#If Not Win64 Then
    Reserved As Long
#End If
End Type

Private Declare PtrSafe Function MenuCreatePicture Lib "oleaut32.dll" Alias "OleCreatePictureIndirect" (ByRef Description As MenuPictureDescriptor, ByRef InterfaceID As MenuPictureGuid, ByVal OwnsBitmap As Long, ByRef Picture As IPictureDisp) As Long

Public Function MenuSpritePicture(ByVal Sprite As Long) As IPictureDisp
    Dim screenDC As LongPtr, memoryDC As LongPtr, bitmap As LongPtr, previous As LongPtr
    Dim source As WinDevLib.RECT, destination As WinDevLib.RECT
    Dim description As MenuPictureDescriptor, iid As MenuPictureGuid
    Dim picture As IPictureDisp
    Dim errorNumber As Long, errorText As String
    If DD_SpriteSurf Is Nothing Then Exit Function
    If Sprite < 0 Or (Sprite + 1) * PIC_Y > DD_SpriteSurf.Height Then Exit Function
    If 4 * PIC_X > DD_SpriteSurf.Width Then Exit Function
    On Error GoTo Failed
    screenDC = WinDevLib.GetDC(0)
    If screenDC = 0 Then Err.Raise 5, , "Cannot create sprite preview DC."
    memoryDC = WinDevLib.CreateCompatibleDC(screenDC)
    bitmap = WinDevLib.CreateCompatibleBitmap(screenDC, 48, 48)
    WinDevLib.ReleaseDC 0, screenDC
    screenDC = 0
    If memoryDC = 0 Or bitmap = 0 Then Err.Raise 7, , "Cannot allocate sprite preview."
    previous = WinDevLib.SelectObject(memoryDC, bitmap)
    WinDevLib.PatBlt memoryDC, 0, 0, 48, 48, WinDevLib.BLACKNESS
    source.Left = 3 * PIC_X
    source.Top = Sprite * PIC_Y
    source.Right = source.Left + PIC_X
    source.Bottom = source.Top + PIC_Y
    destination.Left = 8: destination.Top = 8
    destination.Right = 40: destination.Bottom = 40
    DD_SpriteSurf.BltToDC memoryDC, source, destination
    WinDevLib.SelectObject memoryDC, previous
    previous = 0
    WinDevLib.DeleteDC memoryDC
    memoryDC = 0
    description.Size = LenB(description)
    description.Kind = 1 ' PICTYPE_BITMAP
    description.Bitmap = bitmap
    iid.Data1 = &H7BF80981
    iid.Data2 = &HBF32
    iid.Data3 = &H101A
    iid.Data4(0) = &H8B: iid.Data4(1) = &HBB
    iid.Data4(2) = &H0: iid.Data4(3) = &HAA
    iid.Data4(4) = &H0: iid.Data4(5) = &H30
    iid.Data4(6) = &HC: iid.Data4(7) = &HAB
    If MenuCreatePicture(description, iid, 1, picture) < 0 Then Err.Raise 5, , "Cannot create sprite picture."
    bitmap = 0 ' The returned picture now owns the bitmap.
    Set MenuSpritePicture = picture
    Exit Function
Failed:
    errorNumber = Err.Number
    errorText = Err.Description
    If previous <> 0 And memoryDC <> 0 Then WinDevLib.SelectObject memoryDC, previous
    If bitmap <> 0 Then WinDevLib.DeleteObject bitmap
    If memoryDC <> 0 Then WinDevLib.DeleteDC memoryDC
    If screenDC <> 0 Then WinDevLib.ReleaseDC 0, screenDC
    Err.Raise errorNumber, "MenuSpritePicture", errorText
End Function
