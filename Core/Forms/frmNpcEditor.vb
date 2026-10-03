Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmNpcEditor
        Inherits Form

        Public ReadOnly lblSprite As LegacyLabel
        Public ReadOnly Label5 As LegacyLabel
        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly lblRange As LegacyLabel
        Public ReadOnly Label4 As LegacyLabel
        Public ReadOnly lblSTR As LegacyLabel
        Public ReadOnly Label6 As LegacyLabel
        Public ReadOnly lblDEF As LegacyLabel
        Public ReadOnly Label8 As LegacyLabel
        Public ReadOnly lblSPEED As LegacyLabel
        Public ReadOnly Label10 As LegacyLabel
        Public ReadOnly lblMAGI As LegacyLabel
        Public ReadOnly Label12 As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly lblNum As LegacyLabel
        Public ReadOnly Label9 As LegacyLabel
        Public ReadOnly Label11 As LegacyLabel
        Public ReadOnly lblItemName As LegacyLabel
        Public ReadOnly Label7 As LegacyLabel
        Public ReadOnly lblValue As LegacyLabel
        Public ReadOnly Label14 As LegacyLabel
        Public ReadOnly Label16 As LegacyLabel
        Public ReadOnly lbl17 As LegacyLabel
        Public ReadOnly Label15 As LegacyLabel
        Public ReadOnly Label13 As LegacyLabel
        Public ReadOnly scrlSprite As LegacyScrollBar
        Public ReadOnly txtName As LegacyTextBox
        Public ReadOnly cmbBehavior As LegacyComboBox
        Public ReadOnly scrlRange As LegacyScrollBar
        Public ReadOnly scrlSTR As LegacyScrollBar
        Public ReadOnly scrlDEF As LegacyScrollBar
        Public ReadOnly scrlSPEED As LegacyScrollBar
        Public ReadOnly scrlMAGI As LegacyScrollBar
        Public ReadOnly txtChance As LegacyTextBox
        Public ReadOnly scrlNum As LegacyScrollBar
        Public ReadOnly scrlValue As LegacyScrollBar
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly tmrSprite As UITimer
        Public ReadOnly txtAttackSay As LegacyTextBox
        Public ReadOnly txtSpawnSecs As LegacyTextBox
        Public ReadOnly cmbShop As LegacyComboBox
        Public ReadOnly txtGiveEXP As LegacyTextBox
        Public ReadOnly txtMaxHP As LegacyTextBox
        Public ReadOnly imgSprite As ImageView

        Public Sub New()
            Title = "Npc Editor"
            ClientSize = New Size(355, 630)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lblSprite = New LegacyLabel()
            lblSprite.Caption = "0"
            lblSprite.Size = New Size(33, 25)
            rootLayout.Add(lblSprite, 264, 80)

            Label5 = New LegacyLabel()
            Label5.Caption = "Sprite"
            Label5.Size = New Size(57, 25)
            rootLayout.Add(Label5, 16, 80)

            Label1 = New LegacyLabel()
            Label1.Caption = "Name"
            Label1.Size = New Size(49, 25)
            rootLayout.Add(Label1, 8, 8)

            Label2 = New LegacyLabel()
            Label2.Caption = "Behavior"
            Label2.Size = New Size(73, 25)
            rootLayout.Add(Label2, 16, 280)

            lblRange = New LegacyLabel()
            lblRange.Caption = "0"
            lblRange.Size = New Size(33, 25)
            rootLayout.Add(lblRange, 264, 112)

            Label4 = New LegacyLabel()
            Label4.Caption = "Range"
            Label4.Size = New Size(57, 25)
            rootLayout.Add(Label4, 16, 112)

            lblSTR = New LegacyLabel()
            lblSTR.Caption = "0"
            lblSTR.Size = New Size(33, 25)
            rootLayout.Add(lblSTR, 264, 144)

            Label6 = New LegacyLabel()
            Label6.Caption = "STR"
            Label6.Size = New Size(57, 25)
            rootLayout.Add(Label6, 16, 144)

            lblDEF = New LegacyLabel()
            lblDEF.Caption = "0"
            lblDEF.Size = New Size(33, 25)
            rootLayout.Add(lblDEF, 264, 176)

            Label8 = New LegacyLabel()
            Label8.Caption = "DEF"
            Label8.Size = New Size(57, 25)
            rootLayout.Add(Label8, 16, 176)

            lblSPEED = New LegacyLabel()
            lblSPEED.Caption = "0"
            lblSPEED.Size = New Size(33, 25)
            rootLayout.Add(lblSPEED, 264, 208)

            Label10 = New LegacyLabel()
            Label10.Caption = "SPD"
            Label10.Size = New Size(57, 25)
            rootLayout.Add(Label10, 16, 208)

            lblMAGI = New LegacyLabel()
            lblMAGI.Caption = "0"
            lblMAGI.Size = New Size(33, 25)
            rootLayout.Add(lblMAGI, 264, 240)

            Label12 = New LegacyLabel()
            Label12.Caption = "MAGI"
            Label12.Size = New Size(57, 25)
            rootLayout.Add(Label12, 16, 240)

            Label3 = New LegacyLabel()
            Label3.Caption = "Drop Item Chance 1 out of"
            Label3.Size = New Size(193, 25)
            rootLayout.Add(Label3, 16, 320)

            lblNum = New LegacyLabel()
            lblNum.Caption = "0"
            lblNum.Size = New Size(33, 25)
            rootLayout.Add(lblNum, 304, 432)

            Label9 = New LegacyLabel()
            Label9.Caption = "Num"
            Label9.Size = New Size(57, 25)
            rootLayout.Add(Label9, 16, 432)

            Label11 = New LegacyLabel()
            Label11.Caption = "Item"
            Label11.Size = New Size(41, 25)
            rootLayout.Add(Label11, 16, 400)

            lblItemName = New LegacyLabel()
            lblItemName.Caption = ""
            lblItemName.Size = New Size(273, 25)
            rootLayout.Add(lblItemName, 64, 400)

            Label7 = New LegacyLabel()
            Label7.Caption = "Value"
            Label7.Size = New Size(49, 25)
            rootLayout.Add(Label7, 16, 464)

            lblValue = New LegacyLabel()
            lblValue.Caption = "0"
            lblValue.Size = New Size(33, 25)
            rootLayout.Add(lblValue, 304, 464)

            Label14 = New LegacyLabel()
            Label14.Caption = "Say"
            Label14.Size = New Size(49, 25)
            rootLayout.Add(Label14, 8, 40)

            Label16 = New LegacyLabel()
            Label16.Caption = "Spawn Rate (in seconds)"
            Label16.Size = New Size(193, 25)
            rootLayout.Add(Label16, 16, 352)

            lbl17 = New LegacyLabel()
            lbl17.Caption = "Shopkeeper's Shop"
            lbl17.Visible = False
            lbl17.Size = New Size(153, 25)
            rootLayout.Add(lbl17, 8, 544)

            Label15 = New LegacyLabel()
            Label15.Caption = "Exp Given"
            Label15.Size = New Size(81, 25)
            rootLayout.Add(Label15, 168, 504)

            Label13 = New LegacyLabel()
            Label13.Caption = "Start HP"
            Label13.Size = New Size(65, 25)
            rootLayout.Add(Label13, 8, 504)

            scrlSprite = New LegacyScrollBar()
            scrlSprite.MinValue = 0
            scrlSprite.MaxValue = 500
            scrlSprite.Value = 0
            scrlSprite.Orientation = Orientation.Horizontal
            scrlSprite.SmallChange = 1
            scrlSprite.LargeChange = 1
            scrlSprite.Size = New Size(193, 25)
            rootLayout.Add(scrlSprite, 74, 79)

            txtName = New LegacyTextBox()
            txtName.Text = ""
            txtName.Size = New Size(283, 26)
            rootLayout.Add(txtName, 64, 8)

            cmbBehavior = New LegacyComboBox()
            cmbBehavior.Items.Add("Attack on sight")
            cmbBehavior.Items.Add("Attack when attacked")
            cmbBehavior.Items.Add("Friendly")
            cmbBehavior.Items.Add("Shop keeper")
            cmbBehavior.Items.Add("Guard")
            cmbBehavior.Size = New Size(241, 26)
            rootLayout.Add(cmbBehavior, 96, 280)

            scrlRange = New LegacyScrollBar()
            scrlRange.MinValue = 0
            scrlRange.MaxValue = 255
            scrlRange.Value = 1
            scrlRange.Orientation = Orientation.Horizontal
            scrlRange.SmallChange = 1
            scrlRange.LargeChange = 1
            scrlRange.Size = New Size(193, 25)
            rootLayout.Add(scrlRange, 72, 112)

            scrlSTR = New LegacyScrollBar()
            scrlSTR.MinValue = 0
            scrlSTR.MaxValue = 255
            scrlSTR.Value = 0
            scrlSTR.Orientation = Orientation.Horizontal
            scrlSTR.SmallChange = 1
            scrlSTR.LargeChange = 1
            scrlSTR.Size = New Size(193, 25)
            rootLayout.Add(scrlSTR, 72, 144)

            scrlDEF = New LegacyScrollBar()
            scrlDEF.MinValue = 0
            scrlDEF.MaxValue = 255
            scrlDEF.Value = 0
            scrlDEF.Orientation = Orientation.Horizontal
            scrlDEF.SmallChange = 1
            scrlDEF.LargeChange = 1
            scrlDEF.Size = New Size(193, 25)
            rootLayout.Add(scrlDEF, 72, 176)

            scrlSPEED = New LegacyScrollBar()
            scrlSPEED.MinValue = 0
            scrlSPEED.MaxValue = 255
            scrlSPEED.Value = 0
            scrlSPEED.Orientation = Orientation.Horizontal
            scrlSPEED.SmallChange = 1
            scrlSPEED.LargeChange = 1
            scrlSPEED.Size = New Size(193, 25)
            rootLayout.Add(scrlSPEED, 72, 208)

            scrlMAGI = New LegacyScrollBar()
            scrlMAGI.MinValue = 0
            scrlMAGI.MaxValue = 255
            scrlMAGI.Value = 0
            scrlMAGI.Orientation = Orientation.Horizontal
            scrlMAGI.SmallChange = 1
            scrlMAGI.LargeChange = 1
            scrlMAGI.Size = New Size(193, 25)
            rootLayout.Add(scrlMAGI, 72, 240)

            txtChance = New LegacyTextBox()
            txtChance.Text = "0"
            txtChance.Size = New Size(121, 26)
            rootLayout.Add(txtChance, 216, 320)

            scrlNum = New LegacyScrollBar()
            scrlNum.MinValue = 0
            scrlNum.MaxValue = 500
            scrlNum.Value = 1
            scrlNum.Orientation = Orientation.Horizontal
            scrlNum.SmallChange = 1
            scrlNum.LargeChange = 1
            scrlNum.Size = New Size(225, 25)
            rootLayout.Add(scrlNum, 72, 432)

            scrlValue = New LegacyScrollBar()
            scrlValue.MinValue = 0
            scrlValue.MaxValue = 255
            scrlValue.Value = 1
            scrlValue.Orientation = Orientation.Horizontal
            scrlValue.SmallChange = 1
            scrlValue.LargeChange = 1
            scrlValue.Size = New Size(225, 25)
            rootLayout.Add(scrlValue, 72, 464)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(161, 41)
            rootLayout.Add(cmdOk, 8, 584)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(161, 41)
            rootLayout.Add(cmdCancel, 176, 584)

            tmrSprite = New UITimer() With { .Interval = 0.05 }
            tmrSprite.Start()
            txtAttackSay = New LegacyTextBox()
            txtAttackSay.Text = ""
            txtAttackSay.Size = New Size(284, 26)
            rootLayout.Add(txtAttackSay, 64, 40)

            txtSpawnSecs = New LegacyTextBox()
            txtSpawnSecs.Text = "0"
            txtSpawnSecs.Size = New Size(121, 26)
            rootLayout.Add(txtSpawnSecs, 216, 352)

            cmbShop = New LegacyComboBox()
            cmbShop.Visible = False
            cmbShop.Size = New Size(169, 26)
            rootLayout.Add(cmbShop, 168, 544)

            txtGiveEXP = New LegacyTextBox()
            txtGiveEXP.Text = ""
            txtGiveEXP.Size = New Size(73, 26)
            rootLayout.Add(txtGiveEXP, 256, 504)

            txtMaxHP = New LegacyTextBox()
            txtMaxHP.Text = ""
            txtMaxHP.Size = New Size(81, 26)
            rootLayout.Add(txtMaxHP, 80, 504)

            imgSprite = New ImageView()
            imgSprite.Size = New Size(48, 64)
            rootLayout.Add(imgSprite, 305, 78)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
