Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmKeyOpen
        Inherits Form

        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly lblX As LegacyLabel
        Public ReadOnly lblY As LegacyLabel
        Public ReadOnly scrlX As LegacyScrollBar
        Public ReadOnly scrlY As LegacyScrollBar
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton

        Public Sub New()
            Title = "Key Open"
            ClientSize = New Size(321, 130)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            Label1 = New LegacyLabel()
            Label1.Caption = "X"
            Label1.Size = New Size(17, 25)
            rootLayout.Add(Label1, 8, 16)

            Label2 = New LegacyLabel()
            Label2.Caption = "Y"
            Label2.Size = New Size(17, 25)
            rootLayout.Add(Label2, 8, 48)

            lblX = New LegacyLabel()
            lblX.Caption = "0"
            lblX.Size = New Size(25, 25)
            rootLayout.Add(lblX, 288, 16)

            lblY = New LegacyLabel()
            lblY.Caption = "0"
            lblY.Size = New Size(25, 25)
            rootLayout.Add(lblY, 288, 48)

            scrlX = New LegacyScrollBar()
            scrlX.MinValue = 0
            scrlX.MaxValue = 15
            scrlX.Value = 0
            scrlX.Orientation = Orientation.Horizontal
            scrlX.SmallChange = 1
            scrlX.LargeChange = 1
            scrlX.Size = New Size(249, 25)
            rootLayout.Add(scrlX, 32, 16)

            scrlY = New LegacyScrollBar()
            scrlY.MinValue = 0
            scrlY.MaxValue = 11
            scrlY.Value = 0
            scrlY.Orientation = Orientation.Horizontal
            scrlY.SmallChange = 1
            scrlY.LargeChange = 1
            scrlY.Size = New Size(249, 25)
            rootLayout.Add(scrlY, 32, 48)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(145, 33)
            rootLayout.Add(cmdOk, 8, 88)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(145, 33)
            rootLayout.Add(cmdCancel, 168, 88)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
