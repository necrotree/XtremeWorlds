Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmMapSpawnNPC
        Inherits Form

        Public ReadOnly lstNPC As LegacyListBox
        Public ReadOnly cmdOK As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly cmbNPCDir As LegacyComboBox
        Public ReadOnly chkStationary As LegacyCheckBox

        Public Sub New()
            Title = "NPC Spawn"
            ClientSize = New Size(306, 204)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lstNPC = New LegacyListBox()
            lstNPC.Size = New Size(289, 121)
            rootLayout.Add(lstNPC, 8, 8)

            cmdOK = New LegacyButton()
            cmdOK.Caption = "OK"
            cmdOK.Size = New Size(137, 33)
            rootLayout.Add(cmdOK, 8, 160)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(137, 33)
            rootLayout.Add(cmdCancel, 160, 160)

            cmbNPCDir = New LegacyComboBox()
            cmbNPCDir.Items.Add("Up")
            cmbNPCDir.Items.Add("Down")
            cmbNPCDir.Items.Add("Left")
            cmbNPCDir.Items.Add("Right")
            cmbNPCDir.Size = New Size(137, 21)
            rootLayout.Add(cmbNPCDir, 160, 136)

            chkStationary = New LegacyCheckBox()
            chkStationary.Caption = "Stationary"
            chkStationary.Checked = False
            chkStationary.Size = New Size(73, 17)
            rootLayout.Add(chkStationary, 8, 136)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
