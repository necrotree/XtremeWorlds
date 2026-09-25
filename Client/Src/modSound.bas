Attribute VB_Name = "modSound"
Option Explicit

' This module was written by solely by Dave Fairbanks
' You may use this module for any purpose
' However there is no warrenty, implied or otherwise.
' You assume all risk by using this source code.

' You need the FMod dll, and the FMod module in your project.

Public FModInit As Boolean         ' FMod started

Dim songHandle As Long             ' Keep track of songs
Dim StreamChannel As Long
Dim streamHandle As Long

Public CurrentSong As Integer      ' Handles the game songs and volumes
Dim IncreasingVolume As Boolean
Dim DecreasingVolume As Boolean
Dim NewSong As Integer

Public Sub SwitchSong(Song As Integer)
' Used to switch to a new song.  This starts fading it out.

    If CurrentSong = 0 And Song = 0 Then
        Exit Sub
    ElseIf CurrentSong = 0 And Song <> 0 Then
        PlaySong Song
    Else
        IncreasingVolume = False
        DecreasingVolume = True
        NewSong = Song
    End If
End Sub
Public Sub PlaySong(Song As Integer)   ' Start playing a new song

    ' f GetVar(App.Path & DATA_PATH & "Data.dat", "OPTIONS", "MUSIC") = "1" Then
    If GameData.Music = 1 Then
        If MUSIC_EXT = ".mid" Or MUSIC_EXT = ".midi" Then
            Call PlayMidi(Song)
        ElseIf MUSIC_EXT = ".mp3" Then
            Call PlayMP3(Song)
        End If
    End If
End Sub

Public Sub StopSong()              ' Stop playing the song...
    If MUSIC_EXT = ".mid" Or MUSIC_EXT = ".midi" Then
        Call StopMidi
    ElseIf MUSIC_EXT = ".mp3" Then
        Call StopMP3
    End If
End Sub


Public Sub PlayMidi(Song As Integer)
' Called by PlaySong... starts playing a MIDI file

    ' Dim i As Long
    Dim FilePath As String

    If FModInit = False Then Exit Sub


    FilePath = App.Path & "\music\music" & Song & MUSIC_EXT

    If Song = 0 Then
        CurrentSong = Song
        Exit Sub
    End If

    If Not FileExist(FilePath, True) Then
        MsgBox "Music file " & Song & " doesn't exist"
        Exit Sub
    End If

    songHandle = FMUSIC_LoadSong(FilePath)
    If songHandle <> 0 Then
        ' Loading was successful
        If FMUSIC_PlaySong(songHandle) = 0 Then
            ' Something went wrong
            MsgBox "An error occured playing the song!" & vbCrLf & _
                    FSOUND_GetErrorString(FSOUND_GetError), vbOKOnly
        End If
    Else
        ' Something went wrong
        MsgBox "An error occured opening the song!" & vbCrLf & _
                FSOUND_GetErrorString(FSOUND_GetError), vbOKOnly
    End If
    CurrentSong = Song


End Sub

Public Sub StopMidi()

    If FModInit = False Then Exit Sub

    FMUSIC_FreeSong songHandle
    songHandle = 0
    CurrentSong = 0

End Sub

Public Sub PlayMP3(Song As Integer)
' Called by PlaySong... starts playing a MP3 file

    Dim FilePath As String

    If FModInit = False Then Exit Sub

    FilePath = App.Path & "\music\music" & Song & MUSIC_EXT

    If Song = 0 Then
        CurrentSong = Song
        Exit Sub
    End If

    If Not FileExist(FilePath, True) Then
        MsgBox "Music file " & Song & " doesn't exist"
        Exit Sub
    End If

    streamHandle = FSOUND_Stream_Open(FilePath, FSOUND_LOOP_NORMAL, 0, 0)
    If streamHandle <> 0 Then
        StreamChannel = FSOUND_Stream_Play(FSOUND_FREE, streamHandle)
        If StreamChannel = 0 Then
            ' Error occured
            MsgBox "An error occured playing the stream!" & vbCrLf & _
                    FSOUND_GetErrorString(FSOUND_GetError), vbOKOnly
        End If
    Else
        MsgBox "An error occured opening the stream!" & vbCrLf & _
                FSOUND_GetErrorString(FSOUND_GetError), vbOKOnly
        Exit Sub
    End If

    CurrentSong = Song
    FSOUND_SetVolume StreamChannel, 1
    IncreasingVolume = True

End Sub

Public Sub StopMP3()
    If FModInit = False Then Exit Sub

    FSOUND_Stream_Close streamHandle
    streamHandle = 0
    CurrentSong = 0
End Sub

Public Sub IncreaseMP3Volume()
    ' Called by HandleVolume, increases volume by one "step"  Increase the step to make the volume change faster, decrease to make it slower.
    If FModInit = False Then Exit Sub

    FSOUND_SetVolume StreamChannel, FSOUND_GetVolume(StreamChannel) + 10
End Sub

Public Sub DecreaseMP3Volume()
    ' Called by HandleVolume, increases volume by one "step"  Increase the step to make the volume change faster, decrease to make it slower.
    If FModInit = False Then Exit Sub
    FSOUND_SetVolume StreamChannel, FSOUND_GetVolume(StreamChannel) - 10
End Sub

Public Sub IncreaseMIDVolume()
    ' Called by HandleVolume, increases volume by one "step"  Increase the step to make the volume change faster, decrease to make it slower.
    If FModInit = False Then Exit Sub

    FMUSIC_SetMasterVolume songHandle, FMUSIC_GetMasterVolume(songHandle) + 10
End Sub

Public Sub DecreaseMIDVolume()
    ' Called by HandleVolume, increases volume by one "step"  Increase the step to make the volume change faster, decrease to make it slower.
    If FModInit = False Then Exit Sub
    FMUSIC_SetMasterVolume songHandle, FMUSIC_GetMasterVolume(songHandle) - 10
End Sub

Public Sub HandleVolume()
    ' Called from the game loop.  Checks if we need to change our volume, and if we do does it.
    If FModInit = False Then Exit Sub

    If MUSIC_EXT = ".mp3" Then
        If FSOUND_GetVolume(StreamChannel) <= 255 And IncreasingVolume = True Then
            Call IncreaseMP3Volume
            If FSOUND_GetVolume(StreamChannel) > 254 Then IncreasingVolume = False
            Exit Sub
        End If

        If FSOUND_GetVolume(StreamChannel) > 1 And DecreasingVolume = True Then
            Call DecreaseMP3Volume
            If FSOUND_GetVolume(StreamChannel) < 2 Then
                DecreasingVolume = False
                Call StopMP3
                Call PlaySong(NewSong)
            End If
            Exit Sub
        End If
    ElseIf MUSIC_EXT = ".midi" Or MUSIC_EXT = ".mid" Then
        If FMUSIC_GetMasterVolume(songHandle) <= 255 And IncreasingVolume = True Then
            Call IncreaseMIDVolume
            If FMUSIC_GetMasterVolume(songHandle) > 254 Then IncreasingVolume = False
            Exit Sub
        End If

        If FMUSIC_GetMasterVolume(songHandle) > 1 And DecreasingVolume = True Then
            Call DecreaseMIDVolume
            If FMUSIC_GetMasterVolume(songHandle) < 2 Then
                DecreasingVolume = False
                Call StopMidi
                Call PlaySong(NewSong)
            End If
            Exit Sub
        End If
    End If
End Sub

