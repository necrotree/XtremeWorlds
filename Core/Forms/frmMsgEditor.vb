Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmMsgEditor
        Inherits Form

        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly optGlobal As LegacyRadioButton
        Public ReadOnly optPlayer As LegacyRadioButton
        Public ReadOnly cmdOK As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly txtMsgEditorText As LegacyTextBox

        Public Sub New()
            Title = "Map Message"
            ClientSize = New Size(292, 117)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            Label1 = New LegacyLabel()
            Label1.Caption = "Message Type"
            Label1.Size = New Size(81, 17)
            rootLayout.Add(Label1, 8, 64)

            Label2 = New LegacyLabel()
            Label2.Caption = "Message Text"
            Label2.Size = New Size(81, 17)
            rootLayout.Add(Label2, 8, 8)

            Label3 = New LegacyLabel()
            Label3.Caption = "The maximum length is 255 characters!"
            Label3.Size = New Size(185, 17)
            rootLayout.Add(Label3, 48, 32)

            optGlobal = New LegacyRadioButton()
            optGlobal.Caption = "Global"
            optGlobal.Size = New Size(89, 17)
            rootLayout.Add(optGlobal, 200, 64)

            optPlayer = New LegacyRadioButton(optGlobal)
            optPlayer.Caption = "Player"
            optPlayer.Value = True
            optPlayer.Size = New Size(89, 17)
            rootLayout.Add(optPlayer, 104, 64)

            cmdOK = New LegacyButton()
            cmdOK.Caption = "Ok"
            cmdOK.Size = New Size(97, 25)
            rootLayout.Add(cmdOK, 32, 88)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(97, 25)
            rootLayout.Add(cmdCancel, 176, 88)

            txtMsgEditorText = New LegacyTextBox()
            txtMsgEditorText.Text = "Your Text Here"
            txtMsgEditorText.Size = New Size(193, 19)
            rootLayout.Add(txtMsgEditorText, 96, 8)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
