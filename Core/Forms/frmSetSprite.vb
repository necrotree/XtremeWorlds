Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmSetSprite
        Inherits Form

        Public ReadOnly Label5 As LegacyLabel
        Public ReadOnly lblSpriteNum As LegacyLabel
        Public ReadOnly picSprite As LegacyPictureBox
        Public ReadOnly scrlSprite As LegacyScrollBar
        Public ReadOnly tmrSprite As UITimer
        Public ReadOnly cmdSend As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton

        Public Sub New()
            Title = "Sprite Change"
            ClientSize = New Size(290, 123)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            Label5 = New LegacyLabel()
            Label5.Caption = "Sprite"
            Label5.Size = New Size(49, 25)
            rootLayout.Add(Label5, 8, 48)

            lblSpriteNum = New LegacyLabel()
            lblSpriteNum.Caption = "0"
            lblSpriteNum.Size = New Size(33, 25)
            rootLayout.Add(lblSpriteNum, 248, 48)

            picSprite = New LegacyPictureBox()
            picSprite.Size = New Size(33, 33)
            rootLayout.Add(picSprite, 8, 8)

            scrlSprite = New LegacyScrollBar()
            scrlSprite.MinValue = 0
            scrlSprite.MaxValue = 600
            scrlSprite.Value = 0
            scrlSprite.Orientation = Orientation.Horizontal
            scrlSprite.SmallChange = 1
            scrlSprite.LargeChange = 1
            scrlSprite.Size = New Size(193, 25)
            rootLayout.Add(scrlSprite, 56, 48)

            tmrSprite = New UITimer() With { .Interval = 0.05 }
            tmrSprite.Start()
            cmdSend = New LegacyButton()
            cmdSend.Caption = "Send"
            cmdSend.Size = New Size(73, 25)
            rootLayout.Add(cmdSend, 40, 88)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(73, 25)
            rootLayout.Add(cmdCancel, 176, 88)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
