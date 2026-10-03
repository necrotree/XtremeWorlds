Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmOptions
        Inherits Form

        Public ReadOnly SSTab1 As LegacyFrame
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly cmdSave As LegacyButton
        Public ReadOnly Frame1 As LegacyFrame
        Public ReadOnly optPlayerOff As LegacyRadioButton
        Public ReadOnly optPlayerOn As LegacyRadioButton
        Public ReadOnly optPlayerMouse As LegacyRadioButton
        Public ReadOnly Frame2 As LegacyFrame
        Public ReadOnly optNPCOn As LegacyRadioButton
        Public ReadOnly optNPCMouse As LegacyRadioButton
        Public ReadOnly optNPCOff As LegacyRadioButton
        Public ReadOnly Frame3 As LegacyFrame
        Public ReadOnly optMusicOn As LegacyRadioButton
        Public ReadOnly optMusicOff As LegacyRadioButton
        Public ReadOnly Frame4 As LegacyFrame
        Public ReadOnly optSoundOn As LegacyRadioButton
        Public ReadOnly optSoundOff As LegacyRadioButton
        Public ReadOnly Frame5 As LegacyFrame
        Public ReadOnly optWASDOn As LegacyRadioButton
        Public ReadOnly optWASDOff As LegacyRadioButton
        Public ReadOnly cmdHotkeys As LegacyButton
        Public ReadOnly Frame6 As LegacyFrame
        Public ReadOnly optVitalsOn As LegacyRadioButton
        Public ReadOnly optVitalsOff As LegacyRadioButton

        Public Sub New()
            Title = "Options"
            ClientSize = New Size(288, 504)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            SSTab1 = New LegacyFrame()
            SSTab1.Caption = "Options"
            SSTab1.Size = New Size(273, 489)
            rootLayout.Add(SSTab1, 14, 2)
            Dim layout_SSTab1 As New PixelLayout()
            SSTab1.Content = layout_SSTab1
            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(97, 25)
            layout_SSTab1.Add(cmdCancel, 166, 455)

            cmdSave = New LegacyButton()
            cmdSave.Caption = "Save"
            cmdSave.Size = New Size(97, 25)
            layout_SSTab1.Add(cmdSave, 14, 455)

            Frame1 = New LegacyFrame()
            Frame1.Caption = "Player Names"
            Frame1.Size = New Size(241, 57)
            layout_SSTab1.Add(Frame1, 16, 40)
            Dim layout_Frame1 As New PixelLayout()
            Frame1.Content = layout_Frame1
            optPlayerOff = New LegacyRadioButton()
            optPlayerOff.Caption = "Off"
            optPlayerOff.Size = New Size(57, 17)
            layout_Frame1.Add(optPlayerOff, 176, 24)

            optPlayerOn = New LegacyRadioButton(optPlayerOff)
            optPlayerOn.Caption = "On"
            optPlayerOn.Value = True
            optPlayerOn.Size = New Size(57, 17)
            layout_Frame1.Add(optPlayerOn, 15, 24)

            optPlayerMouse = New LegacyRadioButton(optPlayerOff)
            optPlayerMouse.Caption = "Mouse Over"
            optPlayerMouse.Size = New Size(81, 17)
            layout_Frame1.Add(optPlayerMouse, 72, 24)


            Frame2 = New LegacyFrame()
            Frame2.Caption = "NPC Names"
            Frame2.Size = New Size(241, 57)
            layout_SSTab1.Add(Frame2, 16, 104)
            Dim layout_Frame2 As New PixelLayout()
            Frame2.Content = layout_Frame2
            optNPCOn = New LegacyRadioButton()
            optNPCOn.Caption = "On"
            optNPCOn.Value = True
            optNPCOn.Size = New Size(57, 17)
            layout_Frame2.Add(optNPCOn, 16, 24)

            optNPCMouse = New LegacyRadioButton(optNPCOn)
            optNPCMouse.Caption = "Mouse Over"
            optNPCMouse.Size = New Size(81, 17)
            layout_Frame2.Add(optNPCMouse, 72, 24)

            optNPCOff = New LegacyRadioButton(optNPCOn)
            optNPCOff.Caption = "Off"
            optNPCOff.Size = New Size(57, 17)
            layout_Frame2.Add(optNPCOff, 176, 24)


            Frame3 = New LegacyFrame()
            Frame3.Caption = "Music"
            Frame3.Size = New Size(241, 57)
            layout_SSTab1.Add(Frame3, 16, 168)
            Dim layout_Frame3 As New PixelLayout()
            Frame3.Content = layout_Frame3
            optMusicOn = New LegacyRadioButton()
            optMusicOn.Caption = "On"
            optMusicOn.Size = New Size(57, 17)
            layout_Frame3.Add(optMusicOn, 16, 24)

            optMusicOff = New LegacyRadioButton(optMusicOn)
            optMusicOff.Caption = "Off"
            optMusicOff.Value = True
            optMusicOff.Size = New Size(57, 17)
            layout_Frame3.Add(optMusicOff, 104, 23)


            Frame4 = New LegacyFrame()
            Frame4.Caption = "Sound"
            Frame4.Size = New Size(241, 57)
            layout_SSTab1.Add(Frame4, 17, 232)
            Dim layout_Frame4 As New PixelLayout()
            Frame4.Content = layout_Frame4
            optSoundOn = New LegacyRadioButton()
            optSoundOn.Caption = "On"
            optSoundOn.Value = True
            optSoundOn.Size = New Size(57, 17)
            layout_Frame4.Add(optSoundOn, 16, 24)

            optSoundOff = New LegacyRadioButton(optSoundOn)
            optSoundOff.Caption = "Off"
            optSoundOff.Size = New Size(57, 17)
            layout_Frame4.Add(optSoundOff, 104, 23)


            Frame5 = New LegacyFrame()
            Frame5.Caption = "WASD"
            Frame5.Size = New Size(241, 57)
            layout_SSTab1.Add(Frame5, 16, 293)
            Dim layout_Frame5 As New PixelLayout()
            Frame5.Content = layout_Frame5
            optWASDOn = New LegacyRadioButton()
            optWASDOn.Caption = "On"
            optWASDOn.Value = True
            optWASDOn.Size = New Size(57, 17)
            layout_Frame5.Add(optWASDOn, 16, 23)

            optWASDOff = New LegacyRadioButton(optWASDOn)
            optWASDOff.Caption = "Off"
            optWASDOff.Size = New Size(57, 17)
            layout_Frame5.Add(optWASDOff, 104, 21)


            cmdHotkeys = New LegacyButton()
            cmdHotkeys.Caption = "Keyboard Shortcuts..."
            cmdHotkeys.Size = New Size(256, 25)
            layout_SSTab1.Add(cmdHotkeys, 6, 420)

            Frame6 = New LegacyFrame()
            Frame6.Caption = "Vitals"
            Frame6.Size = New Size(241, 57)
            layout_SSTab1.Add(Frame6, 16, 354)
            Dim layout_Frame6 As New PixelLayout()
            Frame6.Content = layout_Frame6
            optVitalsOn = New LegacyRadioButton()
            optVitalsOn.Caption = "On"
            optVitalsOn.Value = True
            optVitalsOn.Size = New Size(57, 17)
            layout_Frame6.Add(optVitalsOn, 16, 21)

            optVitalsOff = New LegacyRadioButton(optVitalsOn)
            optVitalsOff.Caption = "Off"
            optVitalsOff.Size = New Size(57, 17)
            layout_Frame6.Add(optVitalsOff, 104, 21)



            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
