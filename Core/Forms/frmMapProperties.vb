Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmMapProperties
        Inherits Form

        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly Label4 As LegacyLabel
        Public ReadOnly Label5 As LegacyLabel
        Public ReadOnly Label6 As LegacyLabel
        Public ReadOnly Label7 As LegacyLabel
        Public ReadOnly Label8 As LegacyLabel
        Public ReadOnly Label9 As LegacyLabel
        Public ReadOnly Label10 As LegacyLabel
        Public ReadOnly lblMusic As LegacyLabel
        Public ReadOnly Label11 As LegacyLabel
        Public ReadOnly Label12 As LegacyLabel
        Public ReadOnly lblInOutStat As LegacyLabel
        Public ReadOnly txtName As LegacyTextBox
        Public ReadOnly txtUp As LegacyTextBox
        Public ReadOnly txtDown As LegacyTextBox
        Public ReadOnly txtRight As LegacyTextBox
        Public ReadOnly txtLeft As LegacyTextBox
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly cmbMoral As LegacyComboBox
        Public ReadOnly cmbNpc As LegacyComboBox
        Public ReadOnly cmbNpc_1 As LegacyComboBox
        Public ReadOnly cmbNpc_2 As LegacyComboBox
        Public ReadOnly cmbNpc_3 As LegacyComboBox
        Public ReadOnly cmbNpc_4 As LegacyComboBox
        Public ReadOnly txtBootMap As LegacyTextBox
        Public ReadOnly txtBootX As LegacyTextBox
        Public ReadOnly txtBootY As LegacyTextBox
        Public ReadOnly scrlMusic As LegacyScrollBar
        Public ReadOnly cmbShop As LegacyComboBox
        Public ReadOnly cmbNpc_5 As LegacyComboBox
        Public ReadOnly cmbNpc_6 As LegacyComboBox
        Public ReadOnly cmbNpc_7 As LegacyComboBox
        Public ReadOnly cmbNpc_8 As LegacyComboBox
        Public ReadOnly cmbNpc_9 As LegacyComboBox
        Public ReadOnly cmdTest As LegacyButton
        Public ReadOnly cmdStop As LegacyButton
        Public ReadOnly frmType As LegacyFrame
        Public ReadOnly optOutside As LegacyRadioButton
        Public ReadOnly optInside As LegacyRadioButton

        Public Sub New()
            Title = "Map Properties"
            ClientSize = New Size(563, 420)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            Label1 = New LegacyLabel()
            Label1.Caption = "Name"
            Label1.Size = New Size(49, 25)
            rootLayout.Add(Label1, 8, 8)

            Label2 = New LegacyLabel()
            Label2.Caption = "Up"
            Label2.Size = New Size(49, 25)
            rootLayout.Add(Label2, 8, 48)

            Label3 = New LegacyLabel()
            Label3.Caption = "Down"
            Label3.Size = New Size(49, 25)
            rootLayout.Add(Label3, 8, 80)

            Label4 = New LegacyLabel()
            Label4.Caption = "Left"
            Label4.Size = New Size(49, 25)
            rootLayout.Add(Label4, 128, 48)

            Label5 = New LegacyLabel()
            Label5.Caption = "Right"
            Label5.Size = New Size(49, 25)
            rootLayout.Add(Label5, 128, 80)

            Label6 = New LegacyLabel()
            Label6.Caption = "Moral"
            Label6.Size = New Size(49, 25)
            rootLayout.Add(Label6, 8, 120)

            Label7 = New LegacyLabel()
            Label7.Caption = "Boot Map"
            Label7.Size = New Size(73, 25)
            rootLayout.Add(Label7, 8, 256)

            Label8 = New LegacyLabel()
            Label8.Caption = "Boot X"
            Label8.Size = New Size(73, 25)
            rootLayout.Add(Label8, 8, 288)

            Label9 = New LegacyLabel()
            Label9.Caption = "Boot Y"
            Label9.Size = New Size(73, 25)
            rootLayout.Add(Label9, 8, 320)

            Label10 = New LegacyLabel()
            Label10.Caption = "Music"
            Label10.Size = New Size(49, 25)
            rootLayout.Add(Label10, 8, 192)

            lblMusic = New LegacyLabel()
            lblMusic.Caption = "0"
            lblMusic.Size = New Size(33, 25)
            rootLayout.Add(lblMusic, 232, 192)

            Label11 = New LegacyLabel()
            Label11.Caption = "NPC's"
            Label11.Size = New Size(273, 25)
            rootLayout.Add(Label11, 280, 8)

            Label12 = New LegacyLabel()
            Label12.Caption = "Shop"
            Label12.Size = New Size(49, 25)
            rootLayout.Add(Label12, 8, 152)

            lblInOutStat = New LegacyLabel()
            lblInOutStat.Caption = "Inside maps are not affected by day and night, while outside maps are!"
            lblInOutStat.Size = New Size(265, 25)
            rootLayout.Add(lblInOutStat, 8, 352)

            txtName = New LegacyTextBox()
            txtName.Text = ""
            txtName.Size = New Size(201, 26)
            rootLayout.Add(txtName, 64, 8)

            txtUp = New LegacyTextBox()
            txtUp.Text = "0"
            txtUp.Size = New Size(49, 26)
            rootLayout.Add(txtUp, 64, 48)

            txtDown = New LegacyTextBox()
            txtDown.Text = "0"
            txtDown.Size = New Size(49, 26)
            rootLayout.Add(txtDown, 64, 80)

            txtRight = New LegacyTextBox()
            txtRight.Text = "0"
            txtRight.Size = New Size(49, 26)
            rootLayout.Add(txtRight, 176, 80)

            txtLeft = New LegacyTextBox()
            txtLeft.Text = "0"
            txtLeft.Size = New Size(49, 26)
            rootLayout.Add(txtLeft, 176, 48)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(265, 33)
            rootLayout.Add(cmdOk, 8, 384)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(265, 33)
            rootLayout.Add(cmdCancel, 288, 384)

            cmbMoral = New LegacyComboBox()
            cmbMoral.Items.Add("None")
            cmbMoral.Items.Add("Safe Zone")
            cmbMoral.Items.Add("Inn")
            cmbMoral.Items.Add("Arena")
            cmbMoral.Size = New Size(161, 26)
            rootLayout.Add(cmbMoral, 64, 120)

            cmbNpc = New LegacyComboBox()
            cmbNpc.Size = New Size(273, 26)
            rootLayout.Add(cmbNpc, 280, 32)

            cmbNpc_1 = New LegacyComboBox()
            cmbNpc_1.Size = New Size(273, 26)
            rootLayout.Add(cmbNpc_1, 280, 64)

            cmbNpc_2 = New LegacyComboBox()
            cmbNpc_2.Size = New Size(273, 26)
            rootLayout.Add(cmbNpc_2, 280, 96)

            cmbNpc_3 = New LegacyComboBox()
            cmbNpc_3.Size = New Size(273, 26)
            rootLayout.Add(cmbNpc_3, 280, 128)

            cmbNpc_4 = New LegacyComboBox()
            cmbNpc_4.Size = New Size(273, 26)
            rootLayout.Add(cmbNpc_4, 280, 160)

            txtBootMap = New LegacyTextBox()
            txtBootMap.Text = "0"
            txtBootMap.Size = New Size(49, 26)
            rootLayout.Add(txtBootMap, 88, 256)

            txtBootX = New LegacyTextBox()
            txtBootX.Text = "0"
            txtBootX.Size = New Size(49, 26)
            rootLayout.Add(txtBootX, 88, 288)

            txtBootY = New LegacyTextBox()
            txtBootY.Text = "0"
            txtBootY.Size = New Size(49, 26)
            rootLayout.Add(txtBootY, 88, 320)

            scrlMusic = New LegacyScrollBar()
            scrlMusic.MinValue = 0
            scrlMusic.MaxValue = 255
            scrlMusic.Value = 1
            scrlMusic.Orientation = Orientation.Horizontal
            scrlMusic.SmallChange = 1
            scrlMusic.LargeChange = 1
            scrlMusic.Size = New Size(161, 25)
            rootLayout.Add(scrlMusic, 64, 192)

            cmbShop = New LegacyComboBox()
            cmbShop.Size = New Size(161, 26)
            rootLayout.Add(cmbShop, 64, 152)

            cmbNpc_5 = New LegacyComboBox()
            cmbNpc_5.Size = New Size(273, 26)
            rootLayout.Add(cmbNpc_5, 280, 192)

            cmbNpc_6 = New LegacyComboBox()
            cmbNpc_6.Size = New Size(273, 26)
            rootLayout.Add(cmbNpc_6, 280, 224)

            cmbNpc_7 = New LegacyComboBox()
            cmbNpc_7.Size = New Size(273, 26)
            rootLayout.Add(cmbNpc_7, 280, 256)

            cmbNpc_8 = New LegacyComboBox()
            cmbNpc_8.Size = New Size(273, 26)
            rootLayout.Add(cmbNpc_8, 280, 288)

            cmbNpc_9 = New LegacyComboBox()
            cmbNpc_9.Size = New Size(273, 26)
            rootLayout.Add(cmbNpc_9, 280, 320)

            cmdTest = New LegacyButton()
            cmdTest.Caption = "Test Song"
            cmdTest.Size = New Size(81, 25)
            rootLayout.Add(cmdTest, 8, 224)

            cmdStop = New LegacyButton()
            cmdStop.Caption = "Stop Song"
            cmdStop.Size = New Size(89, 25)
            rootLayout.Add(cmdStop, 184, 224)

            frmType = New LegacyFrame()
            frmType.Caption = "Map Type"
            frmType.Size = New Size(121, 81)
            rootLayout.Add(frmType, 152, 256)

            optOutside = New LegacyRadioButton()
            optOutside.Caption = "Outer"
            optOutside.Value = True
            optOutside.Size = New Size(105, 18)
            rootLayout.Add(optOutside, 160, 304)

            optInside = New LegacyRadioButton(optOutside)
            optInside.Caption = "Inner"
            optInside.Size = New Size(105, 18)
            rootLayout.Add(optInside, 160, 280)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
