Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmGuildCreate
        Inherits Form

        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly lblGuild As LegacyLabel
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly Label4 As LegacyLabel
        Public ReadOnly scrlGuild As LegacyScrollBar
        Public ReadOnly txtName As LegacyTextBox
        Public ReadOnly txtAbr As LegacyTextBox
        Public ReadOnly txtFounder As LegacyTextBox
        Public ReadOnly cmdSave As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton

        Public Sub New()
            Title = "Create Guild"
            ClientSize = New Size(225, 245)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            Label1 = New LegacyLabel()
            Label1.Caption = "Guild"
            Label1.Size = New Size(97, 17)
            rootLayout.Add(Label1, 8, 8)

            lblGuild = New LegacyLabel()
            lblGuild.Caption = "0"
            lblGuild.Size = New Size(25, 17)
            rootLayout.Add(lblGuild, 200, 32)

            Label2 = New LegacyLabel()
            Label2.Caption = "Name:"
            Label2.Size = New Size(97, 17)
            rootLayout.Add(Label2, 8, 64)

            Label3 = New LegacyLabel()
            Label3.Caption = "Abbreviation:"
            Label3.Size = New Size(97, 17)
            rootLayout.Add(Label3, 8, 112)

            Label4 = New LegacyLabel()
            Label4.Caption = "Founder:"
            Label4.Size = New Size(97, 17)
            rootLayout.Add(Label4, 8, 160)

            scrlGuild = New LegacyScrollBar()
            scrlGuild.MinValue = 1
            scrlGuild.MaxValue = 50
            scrlGuild.Value = 1
            scrlGuild.Orientation = Orientation.Horizontal
            scrlGuild.SmallChange = 1
            scrlGuild.LargeChange = 1
            scrlGuild.Size = New Size(185, 17)
            rootLayout.Add(scrlGuild, 8, 32)

            txtName = New LegacyTextBox()
            txtName.Text = ""
            txtName.Size = New Size(193, 19)
            rootLayout.Add(txtName, 8, 88)

            txtAbr = New LegacyTextBox()
            txtAbr.Text = ""
            txtAbr.Size = New Size(193, 19)
            rootLayout.Add(txtAbr, 8, 136)

            txtFounder = New LegacyTextBox()
            txtFounder.Text = ""
            txtFounder.Size = New Size(193, 19)
            rootLayout.Add(txtFounder, 8, 184)

            cmdSave = New LegacyButton()
            cmdSave.Caption = "Save"
            cmdSave.Size = New Size(65, 25)
            rootLayout.Add(cmdSave, 8, 216)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(65, 25)
            rootLayout.Add(cmdCancel, 152, 216)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
