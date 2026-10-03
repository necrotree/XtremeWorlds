Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmMapDmg
        Inherits Form

        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly lblItem As LegacyLabel
        Public ReadOnly lblName As LegacyLabel
        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly Label4 As LegacyLabel
        Public ReadOnly Label5 As LegacyLabel
        Public ReadOnly lblDamage As LegacyLabel
        Public ReadOnly scrlDamage As LegacyScrollBar
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly scrlItem As LegacyScrollBar

        Public Sub New()
            Title = "Map Damage"
            ClientSize = New Size(326, 201)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            Label2 = New LegacyLabel()
            Label2.Caption = "Item"
            Label2.Size = New Size(41, 17)
            rootLayout.Add(Label2, 0, 32)

            lblItem = New LegacyLabel()
            lblItem.Caption = "0"
            lblItem.Size = New Size(57, 17)
            rootLayout.Add(lblItem, 264, 32)

            lblName = New LegacyLabel()
            lblName.Caption = ""
            lblName.Size = New Size(273, 25)
            rootLayout.Add(lblName, 48, 8)

            Label1 = New LegacyLabel()
            Label1.Caption = "Item"
            Label1.Size = New Size(41, 17)
            rootLayout.Add(Label1, 0, 8)

            Label3 = New LegacyLabel()
            Label3.Caption = "This item will make all of the damage void if the player has it equiped!"
            Label3.Size = New Size(321, 33)
            rootLayout.Add(Label3, 8, 56)

            Label4 = New LegacyLabel()
            Label4.Caption = "Damage"
            Label4.Size = New Size(49, 17)
            rootLayout.Add(Label4, 0, 96)

            Label5 = New LegacyLabel()
            Label5.Caption = "This is the ammount of damage that will be dealt if the player does not have the above item equiped!"
            Label5.Size = New Size(321, 33)
            rootLayout.Add(Label5, 8, 120)

            lblDamage = New LegacyLabel()
            lblDamage.Caption = "0"
            lblDamage.Size = New Size(57, 17)
            rootLayout.Add(lblDamage, 264, 96)

            scrlDamage = New LegacyScrollBar()
            scrlDamage.MinValue = 1
            scrlDamage.MaxValue = 100
            scrlDamage.Value = 1
            scrlDamage.Orientation = Orientation.Horizontal
            scrlDamage.SmallChange = 1
            scrlDamage.LargeChange = 1
            scrlDamage.Size = New Size(217, 17)
            rootLayout.Add(scrlDamage, 48, 96)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(153, 33)
            rootLayout.Add(cmdCancel, 168, 160)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(153, 33)
            rootLayout.Add(cmdOk, 8, 160)

            scrlItem = New LegacyScrollBar()
            scrlItem.MinValue = 1
            scrlItem.MaxValue = 500
            scrlItem.Value = 1
            scrlItem.Orientation = Orientation.Horizontal
            scrlItem.SmallChange = 1
            scrlItem.LargeChange = 1
            scrlItem.Size = New Size(217, 17)
            rootLayout.Add(scrlItem, 40, 32)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
