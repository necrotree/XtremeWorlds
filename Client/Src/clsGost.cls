VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Gost"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' Visual Basic Gost Implementation
' David Midkiff (mdj2023@hotmail.com)
' ActiveX Implementation Antonio Ramirez Cobos
'
' Standard Gost implementation with file support, hex conversion,
' speed string concatenation and overall optimisations for Visual Basic.
' Gost supports 256-bit keys and is a stable algorithm developed
' by the former Soviet Union but there are many notable weaknesses and
' it remains in question if it really is much stronger then DES.
'
' Recommended for medium risk level solutions.
'
' Information on the algorithm can be found at:
' http://www.jetico.sci.fi/index.htm#/gost.htm

Private Declare Sub addLongs Lib "myDLL" (ByRef number1 As Long, ByVal number2 As Long)
'
' MTS
Implements IAlgorithm

Event Process(percent As Long)
Event statuschanged(lStatus As Long)

Private m_KeyValue        As String
Private K(1 To 8)         As Long
Private k87(0 To 255)       As Byte
Private k65(0 To 255)       As Byte
Private k43(0 To 255)       As Byte
Private k21(0 To 255)       As Byte
Private sBox(0 To 7, 0 To 255)  As Byte
Private m_RunningCompiled     As Boolean
Private ByteArray()       As Byte
Private hiByte          As Long
Private hiBound         As Long
Private m_status        As Long

Private Function IAlgorithm_DecryptString(Text As String, Optional Key As String, Optional IsTextInHex As Boolean) As String

    On Error GoTo errhandler
    m_status = STAT_BUSY
    RaiseEvent statuschanged(m_status)
    Dim ByteArray() As Byte
    If IsTextInHex = True Then Text = DeHex(Text)
    ByteArray() = StrConv(Text, vbFromUnicode)
    Call DecryptByte(ByteArray(), Key)
    IAlgorithm_DecryptString = StrConv(ByteArray(), vbUnicode)
    m_status = STAT_READY
    RaiseEvent statuschanged(m_status)
    Exit Function
errhandler:
    m_status = STAT_ERROR
    RaiseEvent statuschanged(m_status)
    ' ---------------------------------------------------------------------------
    ' Raise friendly error to the handler
    ' ---------------------------------------------------------------------------
    Call Err.Raise(Err.Number, Err.Source, Err.Description)

End Function



Private Function IAlgorithm_EncryptString(Text As String, Optional Key As String, Optional OutputInHex As Boolean) As String


    Dim ByteArray() As Byte
    m_status = STAT_BUSY
    RaiseEvent statuschanged(m_status)
    On Error GoTo errhandler

    ByteArray() = StrConv(Text, vbFromUnicode)
    Call EncryptByte(ByteArray(), Key)
    IAlgorithm_EncryptString = StrConv(ByteArray(), vbUnicode)
    If OutputInHex = True Then IAlgorithm_EncryptString = EnHex(IAlgorithm_EncryptString)
    m_status = STAT_READY
    RaiseEvent statuschanged(m_status)
    Exit Function
errhandler:
    m_status = STAT_ERROR
    RaiseEvent statuschanged(m_status)
    ' ---------------------------------------------------------------------------
    ' Raise friendly error to the handler
    ' ---------------------------------------------------------------------------
    Call Err.Raise(Err.Number, Err.Source, Err.Description)
End Function

Public Function EncryptByte(ByteArray() As Byte, Optional Key As String)
    Dim Offset As Long, OrigLen As Long, LeftWord As Long, RightWord As Long, CipherLen As Long, CipherLeft As Long, CipherRight As Long, CurrPercent As Long, NextPercent As Long

    On Error GoTo errhandler

    If (Len(Key) > 0) Then IAlgorithm_Key = Key
    OrigLen = UBound(ByteArray) + 1
    CipherLen = OrigLen + 12
    If (CipherLen Mod 8 <> 0) Then CipherLen = CipherLen + 8 - (CipherLen Mod 8)
    ReDim Preserve ByteArray(CipherLen - 1)
    Call CopyMem(ByteArray(12), ByteArray(0), OrigLen)
    Call CopyMem(ByteArray(8), OrigLen, 4)
    Call Randomize
    Call CopyMem(ByteArray(0), CLng(2147483647 * Rnd), 4)
    Call CopyMem(ByteArray(4), CLng(2147483647 * Rnd), 4)
    For Offset = 0 To (CipherLen - 1) Step 8
        Call GetWord(LeftWord, ByteArray(), Offset)
        Call GetWord(RightWord, ByteArray(), Offset + 4)
        LeftWord = LeftWord Xor CipherLeft
        RightWord = RightWord Xor CipherRight
        Call EncryptBlock(LeftWord, RightWord)
        Call PutWord(LeftWord, ByteArray(), Offset)
        Call PutWord(RightWord, ByteArray(), Offset + 4)
        CipherLeft = LeftWord
        CipherRight = RightWord
        If (Offset >= NextPercent) Then
            CurrPercent = Int((Offset / CipherLen) * 100)
            NextPercent = (CipherLen * ((CurrPercent + 1) / 100)) + 1
            RaiseEvent Process(CurrPercent)
        End If
        DoEvents
    Next
    If (CurrPercent <> 100) Then RaiseEvent Process(100)

    Exit Function
errhandler:


    ' ---------------------------------------------------------------------------
    ' Raise friendly error to the handler
    ' ---------------------------------------------------------------------------
    Call Err.Raise(Err.Number, Err.Source, Err.Description)
End Function

Public Function DecryptByte(ByteArray() As Byte, Optional Key As String)

    Dim Offset As Long, OrigLen As Long, LeftWord As Long, RightWord As Long, CipherLen As Long, CipherLeft As Long, CipherRight As Long, CurrPercent As Long, NextPercent As Long
    On Error GoTo errhandler

    If (Len(Key) > 0) Then IAlgorithm_Key = Key
    CipherLen = UBound(ByteArray) + 1
    For Offset = 0 To (CipherLen - 1) Step 8
        Call GetWord(LeftWord, ByteArray(), Offset)
        Call GetWord(RightWord, ByteArray(), Offset + 4)
        Call DecryptBlock(RightWord, LeftWord)
        LeftWord = LeftWord Xor CipherLeft
        RightWord = RightWord Xor CipherRight
        Call GetWord(CipherLeft, ByteArray(), Offset)
        Call GetWord(CipherRight, ByteArray(), Offset + 4)
        Call PutWord(LeftWord, ByteArray(), Offset)
        Call PutWord(RightWord, ByteArray(), Offset + 4)
        If (Offset >= NextPercent) Then
            CurrPercent = Int((Offset / CipherLen) * 100)
            NextPercent = (CipherLen * ((CurrPercent + 1) / 100)) + 1
            RaiseEvent Process(CurrPercent)
        End If
        DoEvents
    Next
    Call CopyMem(OrigLen, ByteArray(8), 4)
    If (CipherLen - OrigLen > 19) Or (CipherLen - OrigLen < 12) Then Call Err.Raise(vbObjectError, , "Incorrect size descriptor in Gost decryption")
    Call CopyMem(ByteArray(0), ByteArray(12), OrigLen)
    ReDim Preserve ByteArray(OrigLen - 1)
    If (CurrPercent <> 100) Then RaiseEvent Process(100)

    Exit Function
errhandler:


    ' ---------------------------------------------------------------------------
    ' Raise friendly error to the handler
    ' ---------------------------------------------------------------------------
    Call Err.Raise(Err.Number, Err.Source, Err.Description)
End Function


Private Function IAlgorithm_EncryptFile(InFile As String, OutFile As String, Overwrite As Boolean, Optional Key As String) As Boolean
    On Error GoTo errhandler
    m_status = STAT_BUSY
    RaiseEvent statuschanged(m_status)

    If FileExist(InFile) = False Then
        IAlgorithm_EncryptFile = False
        Exit Function
    End If
    If FileExist(OutFile) = True And Overwrite = False Then
        IAlgorithm_EncryptFile = False
        Exit Function
    End If
    Dim FileO As Integer, Buffer() As Byte
    FileO = FreeFile
    Open InFile For Binary As #FileO
    ReDim Buffer(0 To LOF(FileO) - 1)
    Get #FileO, , Buffer()
    Close #FileO
    Call EncryptByte(Buffer(), Key)
    If FileExist(OutFile) = True Then Kill OutFile
    FileO = FreeFile
    Open OutFile For Binary As #FileO
    Put #FileO, , Buffer()
    Close #FileO
    IAlgorithm_EncryptFile = True

    m_status = STAT_READY
    RaiseEvent statuschanged(m_status)
    Exit Function

    Exit Function
errhandler:
    m_status = STAT_ERROR
    RaiseEvent statuschanged(m_status)
    ' ---------------------------------------------------------------------------
    ' Raise friendly error to the handler
    ' ---------------------------------------------------------------------------
    Call Err.Raise(Err.Number, Err.Source, Err.Description)
End Function

Private Function IAlgorithm_DecryptFile(InFile As String, OutFile As String, Overwrite As Boolean, Optional Key As String) As Boolean

    On Error GoTo errhandler
    m_status = STAT_BUSY
    RaiseEvent statuschanged(m_status)

    If FileExist(InFile) = False Then
        IAlgorithm_DecryptFile = False
        Exit Function
    End If
    If FileExist(OutFile) = True And Overwrite = False Then
        IAlgorithm_DecryptFile = False
        Exit Function
    End If
    Dim FileO As Integer, Buffer() As Byte
    FileO = FreeFile
    Open InFile For Binary As #FileO
    ReDim Buffer(0 To LOF(FileO) - 1)
    Get #FileO, , Buffer()
    Close #FileO
    Call DecryptByte(Buffer(), Key)
    If FileExist(OutFile) = True Then Kill OutFile
    If FileExist(OutFile) Then Kill OutFile

    FileO = FreeFile

    Open OutFile For Binary As #FileO
    Put #FileO, , Buffer()
    Close #FileO
    IAlgorithm_DecryptFile = True
    m_status = STAT_READY
    RaiseEvent statuschanged(m_status)
    Exit Function

    Exit Function
errhandler:
    m_status = STAT_ERROR
    RaiseEvent statuschanged(m_status)
    ' ---------------------------------------------------------------------------
    ' Raise friendly error to the handler
    ' ---------------------------------------------------------------------------
    Call Err.Raise(Err.Number, Err.Source, Err.Description)
End Function


Private Property Let IAlgorithm_Key(New_Value As String)
    Dim a As Long, Key() As Byte, KeyLen As Long, ByteArray() As Byte


    If (m_KeyValue = New_Value) Then Exit Property
    KeyLen = Len(New_Value)
    Key() = StrConv(New_Value, vbFromUnicode)
    ReDim ByteArray(0 To 31)
    For a = 0 To 31
        ByteArray(a) = Key(a Mod KeyLen)
    Next
    Call CopyMem(K(1), ByteArray(0), 32)
    m_KeyValue = New_Value
    Exit Property
errhandler:
    ' ---------------------------------------------------------------------------
    ' Raise friendly error to the handler
    ' ---------------------------------------------------------------------------
    Call Err.Raise(Err.Number, Err.Source, Err.Description)
End Property

Private Sub Append(ByRef StringData As String, Optional Length As Long)
    Dim DataLength As Long
    If Length > 0 Then DataLength = Length Else DataLength = Len(StringData)
    If DataLength + hiByte > hiBound Then
        hiBound = hiBound + 1024
        ReDim Preserve ByteArray(hiBound)
    End If
    CopyMem ByVal VarPtr(ByteArray(hiByte)), ByVal StringData, DataLength
    hiByte = hiByte + DataLength
End Sub

Private Function DeHex(Data As String) As String
    Dim iCount As Double
    Reset
    For iCount = 1 To Len(Data) Step 2
        Append Chr$(Val("&H" & Mid$(Data, iCount, 2)))
    Next
    DeHex = GData
    Reset
End Function

Private Function EnHex(Data As String) As String
    Dim iCount As Double, sTemp As String
    Reset
    For iCount = 1 To Len(Data)
        sTemp = Hex$(Asc(Mid$(Data, iCount, 1)))
        If Len(sTemp) < 2 Then sTemp = "0" & sTemp
        Append sTemp
    Next
    EnHex = GData
    Reset
End Function

Private Function FileExist(FileName As String) As Boolean
    On Error GoTo errorhandler
    Call FileLen(FileName)
    FileExist = True
    Exit Function

errorhandler:
    FileExist = False
End Function

Private Property Get GData() As String
    Dim StringData As String
    StringData = Space(hiByte)
    CopyMem ByVal StringData, ByVal VarPtr(ByteArray(0)), hiByte
    GData = StringData
End Property

Private Static Function UnsignedAdd(ByVal Data1 As Long, Data2 As Long) As Long
    Dim X1(0 To 3) As Byte, X2(0 To 3) As Byte, xx(0 To 3) As Byte, Rest As Long, Value As Long, a As Long
    Call CopyMem(X1(0), Data1, 4)
    Call CopyMem(X2(0), Data2, 4)
    Rest = 0
    For a = 0 To 3
        Value = CLng(X1(a)) + CLng(X2(a)) + Rest
        xx(a) = Value And 255
        Rest = Value \ 256
    Next
    Call CopyMem(UnsignedAdd, xx(0), 4)
End Function

Private Function UnsignedDel(Data1 As Long, Data2 As Long) As Long
    Dim X1(0 To 3) As Byte, X2(0 To 3) As Byte, xx(0 To 3) As Byte, Rest As Long, Value As Long, a As Long
    Call CopyMem(X1(0), Data1, 4)
    Call CopyMem(X2(0), Data2, 4)
    Call CopyMem(xx(0), UnsignedDel, 4)
    For a = 0 To 3
        Value = CLng(X1(a)) - CLng(X2(a)) - Rest
        If (Value < 0) Then
            Value = Value + 256
            Rest = 1
        Else
            Rest = 0
        End If
        xx(a) = Value
    Next
    Call CopyMem(UnsignedDel, xx(0), 4)
End Function

Private Sub Reset()
    hiByte = 0
    hiBound = 1024
    ReDim ByteArray(hiBound)
End Sub

Private Static Sub PutWord(LongValue As Long, CryptBuffer() As Byte, Offset As Long)
    Dim bb(0 To 3) As Byte
    Call CopyMem(bb(0), LongValue, 4)
    CryptBuffer(Offset) = bb(3)
    CryptBuffer(Offset + 1) = bb(2)
    CryptBuffer(Offset + 2) = bb(1)
    CryptBuffer(Offset + 3) = bb(0)
End Sub

Private Static Sub GetWord(LongValue As Long, CryptBuffer() As Byte, Offset As Long)
    Dim bb(0 To 3) As Byte
    bb(3) = CryptBuffer(Offset)
    bb(2) = CryptBuffer(Offset + 1)
    bb(1) = CryptBuffer(Offset + 2)
    bb(0) = CryptBuffer(Offset + 3)
    Call CopyMem(LongValue, bb(0), 4)
End Sub

Private Static Sub DecryptBlock(LeftWord As Long, RightWord As Long)
    Dim i As Long
    RightWord = RightWord Xor F(LeftWord, K(1))
    LeftWord = LeftWord Xor F(RightWord, K(2))
    RightWord = RightWord Xor F(LeftWord, K(3))
    LeftWord = LeftWord Xor F(RightWord, K(4))
    RightWord = RightWord Xor F(LeftWord, K(5))
    LeftWord = LeftWord Xor F(RightWord, K(6))
    RightWord = RightWord Xor F(LeftWord, K(7))
    LeftWord = LeftWord Xor F(RightWord, K(8))
    For i = 1 To 3
        RightWord = RightWord Xor F(LeftWord, K(8))
        LeftWord = LeftWord Xor F(RightWord, K(7))
        RightWord = RightWord Xor F(LeftWord, K(6))
        LeftWord = LeftWord Xor F(RightWord, K(5))
        RightWord = RightWord Xor F(LeftWord, K(4))
        LeftWord = LeftWord Xor F(RightWord, K(3))
        RightWord = RightWord Xor F(LeftWord, K(2))
        LeftWord = LeftWord Xor F(RightWord, K(1))
    Next
End Sub

Private Static Sub EncryptBlock(LeftWord As Long, RightWord As Long)
    Dim i As Long
    For i = 1 To 3
        RightWord = RightWord Xor F(LeftWord, K(1))
        LeftWord = LeftWord Xor F(RightWord, K(2))
        RightWord = RightWord Xor F(LeftWord, K(3))
        LeftWord = LeftWord Xor F(RightWord, K(4))
        RightWord = RightWord Xor F(LeftWord, K(5))
        LeftWord = LeftWord Xor F(RightWord, K(6))
        RightWord = RightWord Xor F(LeftWord, K(7))
        LeftWord = LeftWord Xor F(RightWord, K(8))
    Next
    RightWord = RightWord Xor F(LeftWord, K(8))
    LeftWord = LeftWord Xor F(RightWord, K(7))
    RightWord = RightWord Xor F(LeftWord, K(6))
    LeftWord = LeftWord Xor F(RightWord, K(5))
    RightWord = RightWord Xor F(LeftWord, K(4))
    LeftWord = LeftWord Xor F(RightWord, K(3))
    RightWord = RightWord Xor F(LeftWord, K(2))
    LeftWord = LeftWord Xor F(RightWord, K(1))
End Sub


Private Static Function F(R As Long, K As Long) As Long
    Dim X As Long, xb(0 To 3) As Byte, xx(0 To 3) As Byte, a As Byte, B As Byte, C As Byte, D As Byte
    If (m_RunningCompiled) Then X = R + K Else X = UnsignedAdd(R, K)
    D = X And &HFF
    X = X \ 256
    C = X And &HFF
    X = X \ 256
    B = X And &HFF
    X = X \ 256
    a = X And &HFF
    xb(0) = k21(a)
    xb(1) = k43(B)
    xb(2) = k65(C)
    xb(3) = k87(D)
    xx(0) = ((xb(3) And 31) * 8) Or ((xb(2) And 224) \ 32)
    xx(1) = ((xb(0) And 31) * 8) Or ((xb(3) And 224) \ 32)
    xx(2) = ((xb(1) And 31) * 8) Or ((xb(0) And 224) \ 32)
    xx(3) = ((xb(2) And 31) * 8) Or ((xb(1) And 224) \ 32)
    Call CopyMem(F, xx(0), 4)
End Function

Private Static Function lBSL(ByVal lInput As Long, bShiftBits As Byte) As Long
    lBSL = (lInput And (2 ^ (31 - bShiftBits) - 1)) * 2 ^ bShiftBits
    If (lInput And 2 ^ (31 - bShiftBits)) = 2 ^ (31 - bShiftBits) Then lBSL = (lBSL Or &H80000000)
End Function
Private Static Function lBSR(ByVal lInput As Long, bShiftBits As Byte) As Long
    If bShiftBits = 31 Then
        If lInput < 0 Then lBSR = &HFFFFFFFF Else lBSR = 0
    Else
        lBSR = (lInput And Not (2 ^ bShiftBits - 1)) \ 2 ^ bShiftBits
    End If
End Function


Private Sub Class_Initialize()
    Dim a As Long, B As Long, C As Long, LeftWord As Long, S(0 To 7) As Variant

    On Local Error Resume Next
    m_RunningCompiled = ((2147483647 + 1) < 0)

    S(0) = Array(6, 5, 1, 7, 14, 0, 4, 10, 11, 9, 3, 13, 8, 12, 2, 15)
    S(1) = Array(14, 13, 9, 0, 8, 10, 12, 4, 7, 15, 6, 11, 3, 1, 5, 2)
    S(2) = Array(6, 5, 1, 7, 2, 4, 10, 0, 11, 13, 14, 3, 8, 12, 15, 9)
    S(3) = Array(8, 7, 3, 9, 6, 4, 14, 5, 2, 13, 0, 12, 1, 11, 10, 15)
    S(4) = Array(10, 9, 6, 11, 5, 1, 8, 4, 0, 13, 7, 2, 14, 3, 15, 12)
    S(5) = Array(5, 3, 0, 6, 11, 13, 4, 14, 10, 7, 1, 12, 2, 8, 15, 9)
    S(6) = Array(2, 1, 12, 3, 11, 13, 15, 7, 10, 6, 9, 14, 0, 8, 4, 5)
    S(7) = Array(6, 5, 1, 7, 8, 9, 4, 2, 15, 3, 13, 12, 10, 14, 11, 0)

    For a = 0 To 15
        For B = 0 To 7
            sBox(B, a) = S(B)(a)
        Next
    Next
    For a = 0 To 255
        k87(a) = lBSL(CLng(sBox(7, lBSR(a, 4))), 4) Or sBox(6, a And 15)
        k65(a) = lBSL(CLng(sBox(5, lBSR(a, 4))), 4) Or sBox(4, a And 15)
        k43(a) = lBSL(CLng(sBox(3, lBSR(a, 4))), 4) Or sBox(2, a And 15)
        k21(a) = lBSL(CLng(sBox(1, lBSR(a, 4))), 4) Or sBox(0, a And 15)
    Next
    m_status = STAT_READY
End Sub

Private Function IAlgorithm_ToString() As String
    IAlgorithm_ToString = "Gost"
End Function


Private Property Get IAlgorithm_Status() As Long
    IAlgorithm_Status = m_status
End Property

Private Property Let IAlgorithm_Status(lStatus As Long)

    m_status = lStatus
    RaiseEvent statuschanged(lStatus)

End Property
