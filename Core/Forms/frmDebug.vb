Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmDebug
        Inherits Form

        Public ReadOnly SSTab1 As LegacyFrame
        Public ReadOnly Frame1 As LegacyFrame
        Public ReadOnly txtDebug As LegacyTextArea

        Public Sub New()
            Title = "Debug"
            ClientSize = New Size(473, 481)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            SSTab1 = New LegacyFrame()
            SSTab1.Caption = "Debug"
            SSTab1.Size = New Size(457, 465)
            rootLayout.Add(SSTab1, 8, 8)
            Dim layout_SSTab1 As New PixelLayout()
            SSTab1.Content = layout_SSTab1
            Frame1 = New LegacyFrame()
            Frame1.Caption = "Debug"
            Frame1.Size = New Size(441, 441)
            layout_SSTab1.Add(Frame1, 8, 16)
            Dim layout_Frame1 As New PixelLayout()
            Frame1.Content = layout_Frame1
            txtDebug = New LegacyTextArea()
            txtDebug.Text = ""
            txtDebug.Size = New Size(425, 417)
            layout_Frame1.Add(txtDebug, 8, 16)



            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
