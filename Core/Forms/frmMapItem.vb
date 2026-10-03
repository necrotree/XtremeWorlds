Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmMapItem
        Inherits Form

        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly lblItem As LegacyLabel
        Public ReadOnly lblValue As LegacyLabel
        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly lblName As LegacyLabel
        Public ReadOnly scrlItem As LegacyScrollBar
        Public ReadOnly scrlValue As LegacyScrollBar
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton

        Public Sub New()
            Title = "Map Item"
            ClientSize = New Size(338, 139)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            Label2 = New LegacyLabel()
            Label2.Caption = "Item"
            Label2.Size = New Size(41, 17)
            rootLayout.Add(Label2, 8, 40)

            Label3 = New LegacyLabel()
            Label3.Caption = "Value"
            Label3.Size = New Size(41, 17)
            rootLayout.Add(Label3, 8, 64)

            lblItem = New LegacyLabel()
            lblItem.Caption = "1"
            lblItem.Size = New Size(57, 17)
            rootLayout.Add(lblItem, 272, 40)

            lblValue = New LegacyLabel()
            lblValue.Caption = "1"
            lblValue.Size = New Size(57, 17)
            rootLayout.Add(lblValue, 272, 64)

            Label1 = New LegacyLabel()
            Label1.Caption = "Item"
            Label1.Size = New Size(41, 17)
            rootLayout.Add(Label1, 8, 8)

            lblName = New LegacyLabel()
            lblName.Caption = ""
            lblName.Size = New Size(249, 25)
            rootLayout.Add(lblName, 56, 8)

            scrlItem = New LegacyScrollBar()
            scrlItem.MinValue = 1
            scrlItem.MaxValue = 500
            scrlItem.Value = 1
            scrlItem.Orientation = Orientation.Horizontal
            scrlItem.SmallChange = 1
            scrlItem.LargeChange = 1
            scrlItem.Size = New Size(217, 17)
            rootLayout.Add(scrlItem, 56, 40)

            scrlValue = New LegacyScrollBar()
            scrlValue.MinValue = 1
            scrlValue.MaxValue = 100
            scrlValue.Value = 1
            scrlValue.Orientation = Orientation.Horizontal
            scrlValue.SmallChange = 1
            scrlValue.LargeChange = 1
            scrlValue.Size = New Size(217, 17)
            rootLayout.Add(scrlValue, 56, 64)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(153, 33)
            rootLayout.Add(cmdOk, 8, 96)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(153, 33)
            rootLayout.Add(cmdCancel, 176, 96)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
