Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmMapWarp
        Inherits Form

        Public ReadOnly lblY As LegacyLabel
        Public ReadOnly lblX As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly txtMap As LegacyTextBox
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly scrlY As LegacyScrollBar
        Public ReadOnly scrlX As LegacyScrollBar

        Public Sub New()
            Title = "Map Warp"
            ClientSize = New Size(314, 138)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lblY = New LegacyLabel()
            lblY.Caption = "0"
            lblY.Size = New Size(33, 17)
            rootLayout.Add(lblY, 272, 64)

            lblX = New LegacyLabel()
            lblX.Caption = "0"
            lblX.Size = New Size(33, 17)
            rootLayout.Add(lblX, 272, 40)

            Label3 = New LegacyLabel()
            Label3.Caption = "Y"
            Label3.Size = New Size(33, 17)
            rootLayout.Add(Label3, 8, 64)

            Label2 = New LegacyLabel()
            Label2.Caption = "X"
            Label2.Size = New Size(33, 17)
            rootLayout.Add(Label2, 8, 40)

            Label1 = New LegacyLabel()
            Label1.Caption = "Map"
            Label1.Size = New Size(33, 17)
            rootLayout.Add(Label1, 8, 8)

            txtMap = New LegacyTextBox()
            txtMap.Text = "1"
            txtMap.Size = New Size(257, 26)
            rootLayout.Add(txtMap, 48, 8)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(137, 33)
            rootLayout.Add(cmdCancel, 168, 96)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(137, 33)
            rootLayout.Add(cmdOk, 8, 96)

            scrlY = New LegacyScrollBar()
            scrlY.MinValue = 0
            scrlY.MaxValue = 11
            scrlY.Value = 0
            scrlY.Orientation = Orientation.Horizontal
            scrlY.SmallChange = 1
            scrlY.LargeChange = 1
            scrlY.Size = New Size(217, 17)
            rootLayout.Add(scrlY, 48, 64)

            scrlX = New LegacyScrollBar()
            scrlX.MinValue = 0
            scrlX.MaxValue = 15
            scrlX.Value = 0
            scrlX.Orientation = Orientation.Horizontal
            scrlX.SmallChange = 1
            scrlX.LargeChange = 1
            scrlX.Size = New Size(217, 17)
            rootLayout.Add(scrlX, 48, 40)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
