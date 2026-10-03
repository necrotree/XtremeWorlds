Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmMapReport
        Inherits Form

        Public ReadOnly lstMapReport As LegacyListBox
        Public ReadOnly cmdWarp As LegacyButton
        Public ReadOnly cmdExit As LegacyButton

        Public Sub New()
            Title = "Map Report"
            ClientSize = New Size(259, 206)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lstMapReport = New LegacyListBox()
            lstMapReport.Size = New Size(241, 160)
            rootLayout.Add(lstMapReport, 8, 8)

            cmdWarp = New LegacyButton()
            cmdWarp.Caption = "Warp"
            cmdWarp.Size = New Size(97, 25)
            rootLayout.Add(cmdWarp, 8, 176)

            cmdExit = New LegacyButton()
            cmdExit.Caption = "Close"
            cmdExit.Size = New Size(89, 25)
            rootLayout.Add(cmdExit, 160, 176)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
