Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmMapKey
        Inherits Form

        Public ReadOnly lblName As LegacyLabel
        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly lblItem As LegacyLabel
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly scrlItem As LegacyScrollBar
        Public ReadOnly chkTake As LegacyCheckBox

        Public Sub New()
            Title = "Map Key"
            ClientSize = New Size(321, 154)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lblName = New LegacyLabel()
            lblName.Caption = ""
            lblName.Size = New Size(249, 25)
            rootLayout.Add(lblName, 56, 8)

            Label1 = New LegacyLabel()
            Label1.Caption = "Item"
            Label1.Size = New Size(41, 17)
            rootLayout.Add(Label1, 8, 8)

            lblItem = New LegacyLabel()
            lblItem.Caption = "1"
            lblItem.Size = New Size(33, 17)
            rootLayout.Add(lblItem, 272, 40)

            Label2 = New LegacyLabel()
            Label2.Caption = "Item"
            Label2.Size = New Size(41, 17)
            rootLayout.Add(Label2, 8, 40)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(145, 33)
            rootLayout.Add(cmdCancel, 168, 112)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(145, 33)
            rootLayout.Add(cmdOk, 8, 112)

            scrlItem = New LegacyScrollBar()
            scrlItem.MinValue = 1
            scrlItem.MaxValue = 500
            scrlItem.Value = 1
            scrlItem.Orientation = Orientation.Horizontal
            scrlItem.SmallChange = 1
            scrlItem.LargeChange = 1
            scrlItem.Size = New Size(217, 17)
            rootLayout.Add(scrlItem, 56, 40)

            chkTake = New LegacyCheckBox()
            chkTake.Caption = "Take key away upon use"
            chkTake.Checked = True
            chkTake.Size = New Size(297, 25)
            rootLayout.Add(chkTake, 8, 72)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
