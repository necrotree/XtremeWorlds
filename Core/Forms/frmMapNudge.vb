Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmMapNudge
        Inherits Form

        Public ReadOnly SSTab1 As LegacyFrame
        Public ReadOnly Frame1 As LegacyFrame
        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly lblDir As LegacyLabel
        Public ReadOnly scrlDir As LegacyScrollBar
        Public ReadOnly Command1 As LegacyButton
        Public ReadOnly Command2 As LegacyButton

        Public Sub New()
            Title = "Nudge"
            ClientSize = New Size(241, 137)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            SSTab1 = New LegacyFrame()
            SSTab1.Caption = "Nudge"
            SSTab1.Size = New Size(225, 121)
            rootLayout.Add(SSTab1, 8, 8)
            Dim layout_SSTab1 As New PixelLayout()
            SSTab1.Content = layout_SSTab1
            Frame1 = New LegacyFrame()
            Frame1.Caption = "Nudge"
            Frame1.Size = New Size(209, 57)
            layout_SSTab1.Add(Frame1, 8, 24)
            Dim layout_Frame1 As New PixelLayout()
            Frame1.Content = layout_Frame1
            Label1 = New LegacyLabel()
            Label1.Caption = "Direction:"
            Label1.Size = New Size(185, 17)
            layout_Frame1.Add(Label1, 8, 19)

            lblDir = New LegacyLabel()
            lblDir.Caption = "Up"
            lblDir.Size = New Size(89, 16)
            layout_Frame1.Add(lblDir, 112, 35)

            scrlDir = New LegacyScrollBar()
            scrlDir.MinValue = 0
            scrlDir.MaxValue = 3
            scrlDir.Value = 0
            scrlDir.Orientation = Orientation.Horizontal
            scrlDir.SmallChange = 1
            scrlDir.LargeChange = 1
            scrlDir.Size = New Size(145, 17)
            layout_Frame1.Add(scrlDir, 56, 16)


            Command1 = New LegacyButton()
            Command1.Caption = "Ok"
            Command1.Size = New Size(105, 25)
            layout_SSTab1.Add(Command1, 8, 88)

            Command2 = New LegacyButton()
            Command2.Caption = "Cancel"
            Command2.Size = New Size(105, 25)
            layout_SSTab1.Add(Command2, 112, 88)


            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
