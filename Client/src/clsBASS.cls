VERSION 1.0 CLASS
BEGIN
    MultiUse = -1  'True
    Persistable = 0  'NotPersistable
    DataBindingBehavior = 0  'vbNone
    DataSourceBehavior  = 0  'vbNone
    MTSTransactionMode  = 0	'NotAnMTSObject
END
Attribute VB_Name = "clsBASS"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' ============================================================================
' clsBASS
'
' Object-oriented wrapper around the official modBass.bas BASS 2.4 declarations.
'
' Requires:
'   modBass.bas
'   bass.dll
'
' This class intentionally calls the existing modBass API instead of duplicating
' all 2000+ lines of BASS constants, structures and declarations.
' ============================================================================

Private mInitialized As Boolean
Private mLastError As Long
Private mDevice As Long
Private mFrequency As Long

Private Function CaptureError() As Long

    mLastError = BASS_ErrorGetCode()
    CaptureError = mLastError

End Function

Private Function FileExists(ByVal FilePath As String) As Boolean

    Dim Attr As Long

    On Error GoTo Missing

    If LenB(FilePath) = 0 Then Exit Function

    Attr = GetAttr(FilePath)

    If (Attr And vbDirectory) <> 0 Then Exit Function

    FileExists = True
    Exit Function

Missing:

    FileExists = False

End Function

Public Sub SwitchMusic(ByVal Music As Long)

    ' Stop and free the current music first
    If MusicHandle <> 0 Then
        Call Audio.FreeStream(MusicHandle)
        MusicHandle = 0
    End If

    Dim FileName As String
    FileName = App.Path & "\music\music" & CStr(Music) & ".ogg"

    MusicHandle = Audio.OpenStream(FileName, True)

    If MusicHandle = 0 Then
        GameMsgBox "BASS failed to open stream:" & vbCrLf & _
                   FileName & vbCrLf & _
                   Audio.LastErrorString()
        Exit Sub
    End If

    Call Audio.Play(MusicHandle)

End Sub

Public Function Initialize(Optional ByVal Device As Long = -1, Optional ByVal Frequency As Long = 44100, Optional ByVal Flags As Long = 0, Optional ByVal WindowHandle As LongPtr = 0) As Boolean

    If mInitialized Then
        Initialize = True
        Exit Function
    End If

    If Frequency <= 0 Then Frequency = 44100

    If BASS_Init(Device, Frequency, Flags, CLng(WindowHandle), 0) = 0 Then
        CaptureError
        Exit Function
    End If

    mDevice = Device
    mFrequency = Frequency
    mInitialized = True
    mLastError = BASS_OK

    Initialize = True

End Function

Public Sub Shutdown()

    If mInitialized Then
        BASS_Free
    End If

    mInitialized = False
    mDevice = 0
    mFrequency = 0
    mLastError = BASS_OK

End Sub

Public Function OpenStream(ByVal FileName As String, Optional ByVal Looping As Boolean = False, Optional ByVal PreScan As Boolean = True) As Long

    Dim Flags As Long
    Dim Handle As Long

    If mInitialized = False Then
        mLastError = BASS_ERROR_INIT
        Exit Function
    End If

    If FileExists(FileName) = False Then
        mLastError = BASS_ERROR_FILEOPEN
        Exit Function
    End If

    Flags = 0

    If Looping Then
        Flags = Flags Or BASS_SAMPLE_LOOP
    End If

    If PreScan Then
        Flags = Flags Or BASS_STREAM_PRESCAN
    End If

    Handle = BASS_StreamCreateFile(BASSFALSE, StrPtr(FileName), 0, 0, Flags)

    If Handle = 0 Then
        CaptureError
        Exit Function
    End If

    mLastError = BASS_OK
    OpenStream = Handle

End Function

Public Function LoadMusic(ByVal FileName As String, Optional ByVal Looping As Boolean = False, Optional ByVal Frequency As Long = 0) As Long

    Dim Flags As Long
    Dim Handle As Long

    If mInitialized = False Then
        mLastError = BASS_ERROR_INIT
        Exit Function
    End If

    If FileExists(FileName) = False Then
        mLastError = BASS_ERROR_FILEOPEN
        Exit Function
    End If

    Flags = BASS_MUSIC_PRESCAN

    If Looping Then
        Flags = Flags Or BASS_MUSIC_LOOP
    End If

    Handle = BASS_MusicLoad(BASSFALSE, StrPtr(FileName), 0, 0, Flags, Frequency)

    If Handle = 0 Then
        CaptureError
        Exit Function
    End If

    mLastError = BASS_OK
    LoadMusic = Handle

End Function

Public Function Play(ByVal Handle As Long, Optional ByVal Restart As Boolean = False) As Boolean

    Dim RestartFlag As Long

    If Handle = 0 Then
        mLastError = BASS_ERROR_HANDLE
        Exit Function
    End If

    If Restart Then
        RestartFlag = BASSTRUE
    Else
        RestartFlag = BASSFALSE
    End If

    If BASS_ChannelPlay(Handle, RestartFlag) = 0 Then
        CaptureError
        Exit Function
    End If

    mLastError = BASS_OK
    Play = True

End Function

Public Function Pause(ByVal Handle As Long) As Boolean

    If Handle = 0 Then
        mLastError = BASS_ERROR_HANDLE
        Exit Function
    End If

    If BASS_ChannelPause(Handle) = 0 Then
        CaptureError
        Exit Function
    End If

    mLastError = BASS_OK
    Pause = True

End Function

Public Function StopChannel(ByVal Handle As Long) As Boolean

    If Handle = 0 Then
        mLastError = BASS_ERROR_HANDLE
        Exit Function
    End If

    If BASS_ChannelStop(Handle) = 0 Then
        CaptureError
        Exit Function
    End If

    mLastError = BASS_OK
    StopChannel = True

End Function

Public Function FreeStream(ByVal Handle As Long) As Boolean

    If Handle = 0 Then Exit Function

    BASS_ChannelStop Handle

    If BASS_StreamFree(Handle) = 0 Then
        CaptureError
        Exit Function
    End If

    mLastError = BASS_OK
    FreeStream = True

End Function

Public Function FreeMusic(ByVal Handle As Long) As Boolean

    If Handle = 0 Then Exit Function

    BASS_ChannelStop Handle

    If BASS_MusicFree(Handle) = 0 Then
        CaptureError
        Exit Function
    End If

    mLastError = BASS_OK
    FreeMusic = True

End Function

Public Function SetVolume(ByVal Handle As Long, ByVal Volume As Long) As Boolean

    Dim Value As Single

    If Handle = 0 Then
        mLastError = BASS_ERROR_HANDLE
        Exit Function
    End If

    If Volume < 0 Then Volume = 0
    If Volume > 255 Then Volume = 255

    Value = CSng(Volume) / 255!

    If BASS_ChannelSetAttribute(Handle, BASS_ATTRIB_VOL, Value) = 0 Then
        CaptureError
        Exit Function
    End If

    mLastError = BASS_OK
    SetVolume = True

End Function

Public Function GetVolume(ByVal Handle As Long) As Long

    Dim Value As Single

    If Handle = 0 Then
        mLastError = BASS_ERROR_HANDLE
        Exit Function
    End If

    If BASS_ChannelGetAttribute(Handle, BASS_ATTRIB_VOL, Value) = 0 Then
        CaptureError
        Exit Function
    End If

    If Value < 0! Then Value = 0!
    If Value > 1! Then Value = 1!

    mLastError = BASS_OK
    GetVolume = CLng((Value * 255!) + 0.5!)

End Function

Public Function SetPan(ByVal Handle As Long, ByVal Pan As Single) As Boolean

    If Handle = 0 Then
        mLastError = BASS_ERROR_HANDLE
        Exit Function
    End If

    If Pan < -1! Then Pan = -1!
    If Pan > 1! Then Pan = 1!

    If BASS_ChannelSetAttribute(Handle, BASS_ATTRIB_PAN, Pan) = 0 Then
        CaptureError
        Exit Function
    End If

    mLastError = BASS_OK
    SetPan = True

End Function

Public Function GetPan(ByVal Handle As Long) As Single

    Dim Value As Single

    If Handle = 0 Then
        mLastError = BASS_ERROR_HANDLE
        Exit Function
    End If

    If BASS_ChannelGetAttribute(Handle, BASS_ATTRIB_PAN, Value) = 0 Then
        CaptureError
        Exit Function
    End If

    mLastError = BASS_OK
    GetPan = Value

End Function

Public Function IsPlaying(ByVal Handle As Long) As Boolean

    If Handle = 0 Then Exit Function

    IsPlaying = (BASS_ChannelIsActive(Handle) = BASS_ACTIVE_PLAYING)

End Function

Public Function IsPaused(ByVal Handle As Long) As Boolean

    If Handle = 0 Then Exit Function

    IsPaused = (BASS_ChannelIsActive(Handle) = BASS_ACTIVE_PAUSED)

End Function

Public Function IsStopped(ByVal Handle As Long) As Boolean

    If Handle = 0 Then
        IsStopped = True
        Exit Function
    End If

    IsStopped = (BASS_ChannelIsActive(Handle) = BASS_ACTIVE_STOPPED)

End Function

Public Function SetPositionBytes(ByVal Handle As Long, ByVal Position As Long) As Boolean

    If Handle = 0 Then
        mLastError = BASS_ERROR_HANDLE
        Exit Function
    End If

    If BASS_ChannelSetPosition(Handle, Position, BASS_POS_BYTE) = 0 Then
        CaptureError
        Exit Function
    End If

    mLastError = BASS_OK
    SetPositionBytes = True

End Function

Public Function GetPositionBytes(ByVal Handle As Long) As Long

    If Handle = 0 Then
        mLastError = BASS_ERROR_HANDLE
        Exit Function
    End If

    GetPositionBytes = BASS_ChannelGetPosition(Handle, BASS_POS_BYTE)

    If GetPositionBytes = -1 Then
        CaptureError
    Else
        mLastError = BASS_OK
    End If

End Function

Public Function GetLengthBytes(ByVal Handle As Long) As Long

    If Handle = 0 Then
        mLastError = BASS_ERROR_HANDLE
        Exit Function
    End If

    GetLengthBytes = BASS_ChannelGetLength(Handle, BASS_POS_BYTE)

    If GetLengthBytes = -1 Then
        CaptureError
    Else
        mLastError = BASS_OK
    End If

End Function

Public Function GetPositionSeconds(ByVal Handle As Long) As Double

    Dim Position As Long

    Position = GetPositionBytes(Handle)

    If mLastError <> BASS_OK Then Exit Function

    GetPositionSeconds = BASS_ChannelBytes2Seconds(Handle, Position)

End Function

Public Function GetLengthSeconds(ByVal Handle As Long) As Double

    Dim Length As Long

    Length = GetLengthBytes(Handle)

    If mLastError <> BASS_OK Then Exit Function

    GetLengthSeconds = BASS_ChannelBytes2Seconds(Handle, Length)

End Function

Public Property Get Initialized() As Boolean

    Initialized = mInitialized

End Property

Public Property Get LastError() As Long

    LastError = mLastError

End Property

Public Property Get Device() As Long

    Device = mDevice

End Property

Public Property Get Frequency() As Long

    Frequency = mFrequency

End Property

Public Function LastErrorString() As String

    Select Case mLastError

        Case BASS_OK
            LastErrorString = "No error."

        Case BASS_ERROR_MEM
            LastErrorString = "Memory error."

        Case BASS_ERROR_FILEOPEN
            LastErrorString = "Cannot open the file."

        Case BASS_ERROR_DRIVER
            LastErrorString = "Cannot find a free sound driver."

        Case BASS_ERROR_BUFLOST
            LastErrorString = "The sample buffer was lost."

        Case BASS_ERROR_HANDLE
            LastErrorString = "Invalid BASS handle."

        Case BASS_ERROR_FORMAT
            LastErrorString = "Unsupported sample format."

        Case BASS_ERROR_POSITION
            LastErrorString = "Invalid playback position."

        Case BASS_ERROR_INIT
            LastErrorString = "BASS_Init has not been successfully called."

        Case BASS_ERROR_START
            LastErrorString = "BASS_Start has not been successfully called."

        Case BASS_ERROR_ALREADY
            LastErrorString = "BASS is already initialized or already in the requested state."

        Case BASS_ERROR_NOTAUDIO
            LastErrorString = "The file does not contain audio."

        Case BASS_ERROR_NOCHAN
            LastErrorString = "No free playback channel is available."

        Case BASS_ERROR_ILLTYPE
            LastErrorString = "Illegal BASS type."

        Case BASS_ERROR_ILLPARAM
            LastErrorString = "Illegal BASS parameter."

        Case BASS_ERROR_DEVICE
            LastErrorString = "Illegal BASS device number."

        Case BASS_ERROR_NOPLAY
            LastErrorString = "The channel is not playing."

        Case BASS_ERROR_FREQ
            LastErrorString = "Illegal sample rate."

        Case BASS_ERROR_EMPTY
            LastErrorString = "The file has no sample data."

        Case BASS_ERROR_CREATE
            LastErrorString = "BASS could not create the requested object."

        Case BASS_ERROR_NOTAVAIL
            LastErrorString = "The requested BASS action is unavailable."

        Case BASS_ERROR_FILEFORM
            LastErrorString = "Unsupported file format."

        Case BASS_ERROR_VERSION
            LastErrorString = "Invalid BASS/add-on version."

        Case BASS_ERROR_CODEC
            LastErrorString = "Required codec is unavailable."

        Case BASS_ERROR_ENDED
            LastErrorString = "The channel or file has ended."

        Case BASS_ERROR_BUSY
            LastErrorString = "The audio device is busy."

        Case BASS_ERROR_DENIED
            LastErrorString = "Access denied."

        Case Else
            LastErrorString = "BASS error code " & CStr(mLastError) & "."

    End Select

End Function

Private Sub Class_Terminate()

    Shutdown

End Sub
