Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmShopEditor
        Inherits Form

        Public ReadOnly Label14 As LegacyLabel
        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly Label4 As LegacyLabel
        Public ReadOnly Label5 As LegacyLabel
        Public ReadOnly Label6 As LegacyLabel
        Public ReadOnly Label7 As LegacyLabel
        Public ReadOnly Label8 As LegacyLabel
        Public ReadOnly txtJoinSay As LegacyTextBox
        Public ReadOnly txtName As LegacyTextBox
        Public ReadOnly txtLeaveSay As LegacyTextBox
        Public ReadOnly lstTradeItem As LegacyListBox
        Public ReadOnly cmbItemGive As LegacyComboBox
        Public ReadOnly txtItemGiveValue As LegacyTextBox
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly cmbItemGet As LegacyComboBox
        Public ReadOnly txtItemGetValue As LegacyTextBox
        Public ReadOnly cmdUpdate As LegacyButton
        Public ReadOnly chkFixesItems As LegacyCheckBox
        Public ReadOnly txtItem2GiveValue As LegacyTextBox
        Public ReadOnly cmbitem2Give As LegacyComboBox

        Public Sub New()
            Title = "Shop Editor"
            ClientSize = New Size(369, 543)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            Label14 = New LegacyLabel()
            Label14.Caption = "Join Say"
            Label14.Size = New Size(81, 25)
            rootLayout.Add(Label14, 8, 40)

            Label1 = New LegacyLabel()
            Label1.Caption = "Name"
            Label1.Size = New Size(81, 25)
            rootLayout.Add(Label1, 8, 8)

            Label2 = New LegacyLabel()
            Label2.Caption = "Leave Say"
            Label2.Size = New Size(81, 25)
            rootLayout.Add(Label2, 8, 72)

            Label3 = New LegacyLabel()
            Label3.Caption = "Item Give"
            Label3.Size = New Size(81, 25)
            rootLayout.Add(Label3, 8, 152)

            Label4 = New LegacyLabel()
            Label4.Caption = "Value"
            Label4.Size = New Size(81, 25)
            rootLayout.Add(Label4, 8, 184)

            Label5 = New LegacyLabel()
            Label5.Caption = "Item Get"
            Label5.Size = New Size(81, 25)
            rootLayout.Add(Label5, 8, 296)

            Label6 = New LegacyLabel()
            Label6.Caption = "Value"
            Label6.Size = New Size(81, 25)
            rootLayout.Add(Label6, 8, 328)

            Label7 = New LegacyLabel()
            Label7.Caption = "Value 2"
            Label7.Size = New Size(81, 25)
            rootLayout.Add(Label7, 8, 256)

            Label8 = New LegacyLabel()
            Label8.Caption = "Item Give 2"
            Label8.Size = New Size(81, 25)
            rootLayout.Add(Label8, 8, 224)

            txtJoinSay = New LegacyTextBox()
            txtJoinSay.Text = ""
            txtJoinSay.ToolTip = "This is what the shop will say when it opens."
            txtJoinSay.Size = New Size(265, 26)
            rootLayout.Add(txtJoinSay, 96, 40)

            txtName = New LegacyTextBox()
            txtName.Text = ""
            txtName.ToolTip = "This is the name of the shop."
            txtName.Size = New Size(265, 26)
            rootLayout.Add(txtName, 96, 8)

            txtLeaveSay = New LegacyTextBox()
            txtLeaveSay.Text = ""
            txtLeaveSay.ToolTip = "This is the goodbye message that will appear after a player is done shopping."
            txtLeaveSay.Size = New Size(265, 26)
            rootLayout.Add(txtLeaveSay, 96, 72)

            lstTradeItem = New LegacyListBox()
            lstTradeItem.Items.Add("1.")
            lstTradeItem.Items.Add("2.")
            lstTradeItem.Items.Add("3.")
            lstTradeItem.Items.Add("4.")
            lstTradeItem.Items.Add("5.")
            lstTradeItem.Items.Add("6.")
            lstTradeItem.Items.Add("7.")
            lstTradeItem.Items.Add("8.")
            lstTradeItem.Size = New Size(353, 116)
            rootLayout.Add(lstTradeItem, 8, 368)

            cmbItemGive = New LegacyComboBox()
            cmbItemGive.Size = New Size(265, 26)
            rootLayout.Add(cmbItemGive, 96, 152)

            txtItemGiveValue = New LegacyTextBox()
            txtItemGiveValue.Text = "1"
            txtItemGiveValue.Size = New Size(89, 26)
            rootLayout.Add(txtItemGiveValue, 96, 184)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(169, 41)
            rootLayout.Add(cmdCancel, 192, 496)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(169, 41)
            rootLayout.Add(cmdOk, 8, 496)

            cmbItemGet = New LegacyComboBox()
            cmbItemGet.Size = New Size(265, 26)
            rootLayout.Add(cmbItemGet, 96, 296)

            txtItemGetValue = New LegacyTextBox()
            txtItemGetValue.Text = "1"
            txtItemGetValue.Size = New Size(89, 26)
            rootLayout.Add(txtItemGetValue, 96, 328)

            cmdUpdate = New LegacyButton()
            cmdUpdate.Caption = "Update "
            cmdUpdate.Size = New Size(161, 25)
            rootLayout.Add(cmdUpdate, 200, 328)

            chkFixesItems = New LegacyCheckBox()
            chkFixesItems.Caption = "Fixes Items"
            chkFixesItems.Checked = False
            chkFixesItems.ToolTip = "Check this box if you wat the shop to be able to fix items."
            chkFixesItems.Size = New Size(353, 25)
            rootLayout.Add(chkFixesItems, 8, 112)

            txtItem2GiveValue = New LegacyTextBox()
            txtItem2GiveValue.Text = "1"
            txtItem2GiveValue.Enabled = False
            txtItem2GiveValue.Size = New Size(89, 26)
            rootLayout.Add(txtItem2GiveValue, 96, 256)

            cmbitem2Give = New LegacyComboBox()
            cmbitem2Give.Enabled = False
            cmbitem2Give.Size = New Size(265, 26)
            rootLayout.Add(cmbitem2Give, 96, 224)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
