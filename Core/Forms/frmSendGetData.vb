Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmSendGetData
        Inherits Form

        Public ReadOnly lblStatus As LegacyLabel

        Public Sub New()
            Title = "XtremeWorlds"
            ClientSize = New Size(319, 55)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lblStatus = New LegacyLabel()
            lblStatus.Caption = ""
            lblStatus.Size = New Size(265, 17)
            rootLayout.Add(lblStatus, 31, 29)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
