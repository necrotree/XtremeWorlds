Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmSignChoose
        Inherits Form

        Public ReadOnly lblSignNum As LegacyLabel
        Public ReadOnly lblSignName As LegacyLabel
        Public ReadOnly scrlSignNum As LegacyScrollBar
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton

        Public Sub New()
            Title = "Sign Chooser"
            ClientSize = New Size(262, 76)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lblSignNum = New LegacyLabel()
            lblSignNum.Caption = "1"
            lblSignNum.Size = New Size(33, 17)
            rootLayout.Add(lblSignNum, 224, 24)

            lblSignName = New LegacyLabel()
            lblSignName.Caption = "Name"
            lblSignName.Size = New Size(209, 17)
            rootLayout.Add(lblSignName, 8, 8)

            scrlSignNum = New LegacyScrollBar()
            scrlSignNum.MinValue = 1
            scrlSignNum.MaxValue = 500
            scrlSignNum.Value = 1
            scrlSignNum.Orientation = Orientation.Horizontal
            scrlSignNum.SmallChange = 1
            scrlSignNum.LargeChange = 5
            scrlSignNum.Size = New Size(209, 17)
            rootLayout.Add(scrlSignNum, 8, 24)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "OK"
            cmdOk.Size = New Size(81, 25)
            rootLayout.Add(cmdOk, 24, 48)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(81, 25)
            rootLayout.Add(cmdCancel, 160, 48)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
