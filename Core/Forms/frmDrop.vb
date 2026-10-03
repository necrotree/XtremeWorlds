Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmDrop
        Inherits Form

        Public ReadOnly lblName As LegacyLabel
        Public ReadOnly lblAmmount As LegacyLabel
        Public ReadOnly cmdPlus1 As LegacyLabel
        Public ReadOnly cmdMinus1 As LegacyLabel
        Public ReadOnly cmdPlus10 As LegacyLabel
        Public ReadOnly cmdMinus10 As LegacyLabel
        Public ReadOnly cmdPlus100 As LegacyLabel
        Public ReadOnly cmdMinus100 As LegacyLabel
        Public ReadOnly cmdPlus1000 As LegacyLabel
        Public ReadOnly cmdMinus1000 As LegacyLabel
        Public ReadOnly cmdOk As LegacyLabel
        Public ReadOnly cmdCancel As LegacyLabel

        Public Sub New()
            Title = "Drop Item"
            ClientSize = New Size(260, 370)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lblName = New LegacyLabel()
            lblName.Caption = ""
            lblName.Size = New Size(169, 17)
            rootLayout.Add(lblName, 72, 151)

            lblAmmount = New LegacyLabel()
            lblAmmount.Caption = "1"
            lblAmmount.Size = New Size(169, 17)
            rootLayout.Add(lblAmmount, 72, 187)

            cmdPlus1 = New LegacyLabel()
            cmdPlus1.Caption = ""
            cmdPlus1.Size = New Size(25, 9)
            rootLayout.Add(cmdPlus1, 24, 232)

            cmdMinus1 = New LegacyLabel()
            cmdMinus1.Caption = ""
            cmdMinus1.Size = New Size(25, 9)
            rootLayout.Add(cmdMinus1, 176, 232)

            cmdPlus10 = New LegacyLabel()
            cmdPlus10.Caption = ""
            cmdPlus10.Size = New Size(33, 17)
            rootLayout.Add(cmdPlus10, 24, 248)

            cmdMinus10 = New LegacyLabel()
            cmdMinus10.Caption = ""
            cmdMinus10.Size = New Size(25, 17)
            rootLayout.Add(cmdMinus10, 176, 248)

            cmdPlus100 = New LegacyLabel()
            cmdPlus100.Caption = ""
            cmdPlus100.Size = New Size(25, 17)
            rootLayout.Add(cmdPlus100, 32, 272)

            cmdMinus100 = New LegacyLabel()
            cmdMinus100.Caption = ""
            cmdMinus100.Size = New Size(33, 17)
            rootLayout.Add(cmdMinus100, 176, 272)

            cmdPlus1000 = New LegacyLabel()
            cmdPlus1000.Caption = ""
            cmdPlus1000.Size = New Size(41, 9)
            rootLayout.Add(cmdPlus1000, 24, 296)

            cmdMinus1000 = New LegacyLabel()
            cmdMinus1000.Caption = ""
            cmdMinus1000.Size = New Size(41, 9)
            rootLayout.Add(cmdMinus1000, 176, 296)

            cmdOk = New LegacyLabel()
            cmdOk.Caption = ""
            cmdOk.Size = New Size(49, 17)
            rootLayout.Add(cmdOk, 32, 336)

            cmdCancel = New LegacyLabel()
            cmdCancel.Caption = ""
            cmdCancel.Size = New Size(81, 17)
            rootLayout.Add(cmdCancel, 152, 336)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
