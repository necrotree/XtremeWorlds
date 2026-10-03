Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmHotkeys
        Inherits Form

        Public ReadOnly lstActions As LegacyListBox
        Public ReadOnly lblKey As LegacyLabel
        Public ReadOnly cboKey As LegacyComboBox
        Public ReadOnly lblHelp As LegacyLabel
        Public ReadOnly cmdArrows As LegacyButton
        Public ReadOnly cmdWASD As LegacyButton
        Public ReadOnly cmdSave As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly picKeyboard As LegacyPictureBox

        Public Sub New()
            Title = "Keyboard Shortcuts"
            ClientSize = New Size(1004, 536)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lstActions = New LegacyListBox()
            lstActions.Size = New Size(550, 173)
            rootLayout.Add(lstActions, 12, 304)

            lblKey = New LegacyLabel()
            lblKey.Caption = "Key for selected action:"
            lblKey.Size = New Size(390, 20)
            rootLayout.Add(lblKey, 580, 304)

            cboKey = New LegacyComboBox()
            cboKey.Size = New Size(410, 21)
            rootLayout.Add(cboKey, 580, 328)

            lblHelp = New LegacyLabel()
            lblHelp.Caption = "Select an action or slot, then click a key above. Green: selected binding. Blue: assigned. Gray: system keys. Enter is reserved for chat/pickup. Choose Unassigned to clear a binding."
            lblHelp.Size = New Size(410, 68)
            rootLayout.Add(lblHelp, 580, 360)

            cmdArrows = New LegacyButton()
            cmdArrows.Caption = "Arrow defaults"
            cmdArrows.Size = New Size(196, 28)
            rootLayout.Add(cmdArrows, 580, 444)

            cmdWASD = New LegacyButton()
            cmdWASD.Caption = "WASD defaults"
            cmdWASD.Size = New Size(204, 28)
            rootLayout.Add(cmdWASD, 786, 444)

            cmdSave = New LegacyButton()
            cmdSave.Caption = "Save"
            cmdSave.Size = New Size(96, 28)
            rootLayout.Add(cmdSave, 786, 496)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(96, 28)
            rootLayout.Add(cmdCancel, 894, 496)

            picKeyboard = New LegacyPictureBox()
            picKeyboard.Size = New Size(996, 280)
            rootLayout.Add(picKeyboard, 6, 8)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
