Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmTrade
        Inherits Form

        Public ReadOnly picFixItems As LegacyLabel
        Public ReadOnly picCancel As LegacyLabel
        Public ReadOnly picDeal As LegacyLabel
        Public ReadOnly lstTrade As LegacyListBox
        Public ReadOnly mnuFixItems As LegacyPictureBox
        Public ReadOnly picFix As LegacyLabel
        Public ReadOnly picFixCancel As LegacyLabel
        Public ReadOnly cmbItem As LegacyComboBox

        Public Sub New()
            Title = "Trade"
            ClientSize = New Size(260, 370)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            picFixItems = New LegacyLabel()
            picFixItems.Caption = ""
            picFixItems.Size = New Size(25, 17)
            rootLayout.Add(picFixItems, 120, 288)

            picCancel = New LegacyLabel()
            picCancel.Caption = ""
            picCancel.Size = New Size(73, 17)
            rootLayout.Add(picCancel, 96, 336)

            picDeal = New LegacyLabel()
            picDeal.Caption = ""
            picDeal.Size = New Size(41, 17)
            rootLayout.Add(picDeal, 112, 312)

            lstTrade = New LegacyListBox()
            lstTrade.Size = New Size(217, 128)
            rootLayout.Add(lstTrade, 22, 144)

            mnuFixItems = New LegacyPictureBox()
            mnuFixItems.Visible = False
            mnuFixItems.Size = New Size(260, 370)
            rootLayout.Add(mnuFixItems, 0, 0)
            Dim layout_mnuFixItems As New PixelLayout()
            mnuFixItems.Content = layout_mnuFixItems
            picFix = New LegacyLabel()
            picFix.Caption = ""
            picFix.Size = New Size(25, 17)
            layout_mnuFixItems.Add(picFix, 120, 312)

            picFixCancel = New LegacyLabel()
            picFixCancel.Caption = ""
            picFixCancel.Size = New Size(57, 17)
            layout_mnuFixItems.Add(picFixCancel, 104, 336)

            cmbItem = New LegacyComboBox()
            cmbItem.Size = New Size(209, 22)
            layout_mnuFixItems.Add(cmbItem, 24, 184)


            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
