Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmIndex
        Inherits Form

        Public ReadOnly lstIndex As LegacyListBox
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton

        Public Sub New()
            Title = "Index"
            ClientSize = New Size(353, 298)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lstIndex = New LegacyListBox()
            lstIndex.Size = New Size(337, 238)
            rootLayout.Add(lstIndex, 8, 8)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(161, 33)
            rootLayout.Add(cmdOk, 8, 256)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(161, 33)
            rootLayout.Add(cmdCancel, 184, 256)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
