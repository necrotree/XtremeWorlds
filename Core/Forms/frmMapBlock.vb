Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmMapBlock
        Inherits Form

        Public ReadOnly lblBlockType As LegacyLabel
        Public ReadOnly lblBlockType_1 As LegacyLabel
        Public ReadOnly lblBlockType_2 As LegacyLabel
        Public ReadOnly chkBlockType As LegacyCheckBox
        Public ReadOnly chkBlockType_1 As LegacyCheckBox
        Public ReadOnly chkBlockType_2 As LegacyCheckBox
        Public ReadOnly cmdOK As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton

        Public Sub New()
            Title = "Block"
            ClientSize = New Size(115, 123)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lblBlockType = New LegacyLabel()
            lblBlockType.Caption = "Player Block"
            lblBlockType.Size = New Size(65, 17)
            rootLayout.Add(lblBlockType, 8, 8)

            lblBlockType_1 = New LegacyLabel()
            lblBlockType_1.Caption = "NPC Block"
            lblBlockType_1.Size = New Size(65, 17)
            rootLayout.Add(lblBlockType_1, 8, 32)

            lblBlockType_2 = New LegacyLabel()
            lblBlockType_2.Caption = "Flight Block"
            lblBlockType_2.Size = New Size(65, 17)
            rootLayout.Add(lblBlockType_2, 8, 56)

            chkBlockType = New LegacyCheckBox()
            chkBlockType.Caption = "Check1"
            chkBlockType.Checked = False
            chkBlockType.Size = New Size(17, 17)
            rootLayout.Add(chkBlockType, 88, 8)

            chkBlockType_1 = New LegacyCheckBox()
            chkBlockType_1.Caption = "Check1"
            chkBlockType_1.Checked = False
            chkBlockType_1.Size = New Size(17, 17)
            rootLayout.Add(chkBlockType_1, 88, 32)

            chkBlockType_2 = New LegacyCheckBox()
            chkBlockType_2.Caption = "Check1"
            chkBlockType_2.Checked = False
            chkBlockType_2.Size = New Size(17, 17)
            rootLayout.Add(chkBlockType_2, 88, 56)

            cmdOK = New LegacyButton()
            cmdOK.Caption = "Ok"
            cmdOK.Size = New Size(113, 17)
            rootLayout.Add(cmdOK, 0, 80)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(113, 17)
            rootLayout.Add(cmdCancel, 0, 104)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
