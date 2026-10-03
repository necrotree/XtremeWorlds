Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmArrowEditor
        Inherits Form

        Public ReadOnly lblName As LegacyLabel
        Public ReadOnly txtName As LegacyTextBox
        Public ReadOnly picIcon As LegacyPictureBox
        Public ReadOnly lblArrow As LegacyLabel
        Public ReadOnly scrlSprite As LegacyScrollBar
        Public ReadOnly lblSprite As LegacyLabel
        Public ReadOnly lblRangeTitle As LegacyLabel
        Public ReadOnly scrlRange As LegacyScrollBar
        Public ReadOnly lblRange As LegacyLabel
        Public ReadOnly picPreview As LegacyPictureBox
        Public ReadOnly lblStatus As LegacyLabel
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton

        Public Sub New()
            Title = "Arrow Editor"
            ClientSize = New Size(351, 238)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lblName = New LegacyLabel()
            lblName.Caption = "Name"
            lblName.Size = New Size(49, 25)
            rootLayout.Add(lblName, 8, 8)

            txtName = New LegacyTextBox()
            txtName.Text = ""
            txtName.Size = New Size(265, 26)
            rootLayout.Add(txtName, 64, 8)

            picIcon = New LegacyPictureBox()
            picIcon.Size = New Size(32, 32)
            rootLayout.Add(picIcon, 296, 40)

            lblArrow = New LegacyLabel()
            lblArrow.Caption = "Arrow"
            lblArrow.Size = New Size(49, 25)
            rootLayout.Add(lblArrow, 8, 40)

            scrlSprite = New LegacyScrollBar()
            scrlSprite.MinValue = 0
            scrlSprite.MaxValue = 153
            scrlSprite.Value = 0
            scrlSprite.Orientation = Orientation.Horizontal
            scrlSprite.SmallChange = 1
            scrlSprite.LargeChange = 1
            scrlSprite.Size = New Size(193, 25)
            rootLayout.Add(scrlSprite, 64, 40)

            lblSprite = New LegacyLabel()
            lblSprite.Caption = "1"
            lblSprite.Size = New Size(33, 25)
            rootLayout.Add(lblSprite, 256, 40)

            lblRangeTitle = New LegacyLabel()
            lblRangeTitle.Caption = "Range"
            lblRangeTitle.Size = New Size(49, 25)
            rootLayout.Add(lblRangeTitle, 8, 80)

            scrlRange = New LegacyScrollBar()
            scrlRange.MinValue = 0
            scrlRange.MaxValue = 32
            scrlRange.Value = 0
            scrlRange.Orientation = Orientation.Horizontal
            scrlRange.SmallChange = 1
            scrlRange.LargeChange = 1
            scrlRange.Size = New Size(193, 25)
            rootLayout.Add(scrlRange, 64, 80)

            lblRange = New LegacyLabel()
            lblRange.Caption = "0"
            lblRange.Size = New Size(33, 25)
            rootLayout.Add(lblRange, 257, 80)

            picPreview = New LegacyPictureBox()
            picPreview.Size = New Size(321, 72)
            rootLayout.Add(picPreview, 12, 108)

            lblStatus = New LegacyLabel()
            lblStatus.Caption = ""
            lblStatus.Size = New Size(321, 16)
            rootLayout.Add(lblStatus, 8, 216)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "OK"
            cmdOk.Size = New Size(153, 33)
            rootLayout.Add(cmdOk, 10, 188)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(153, 33)
            rootLayout.Add(cmdCancel, 178, 189)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
