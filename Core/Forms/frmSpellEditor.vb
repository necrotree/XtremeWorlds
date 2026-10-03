Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmSpellEditor
        Inherits Form

        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly lblLevelReq As LegacyLabel
        Public ReadOnly lblMP As LegacyLabel
        Public ReadOnly Label7 As LegacyLabel
        Public ReadOnly txtName As LegacyTextBox
        Public ReadOnly fraVitals As LegacyFrame
        Public ReadOnly lblVitalMod As LegacyLabel
        Public ReadOnly Label4 As LegacyLabel
        Public ReadOnly scrlVitalMod As LegacyScrollBar
        Public ReadOnly cmbType As LegacyComboBox
        Public ReadOnly fraGiveItem As LegacyFrame
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly lblItemNum As LegacyLabel
        Public ReadOnly Label5 As LegacyLabel
        Public ReadOnly lblItemValue As LegacyLabel
        Public ReadOnly scrlItemNum As LegacyScrollBar
        Public ReadOnly scrlItemValue As LegacyScrollBar
        Public ReadOnly cmbClassReq As LegacyComboBox
        Public ReadOnly scrlLevelReq As LegacyScrollBar
        Public ReadOnly fraMisc As LegacyFrame
        Public ReadOnly lblAnim As LegacyLabel
        Public ReadOnly scrlAnim As LegacyScrollBar
        Public ReadOnly picAnim As LegacyPictureBox
        Public ReadOnly scrlMP As LegacyScrollBar
        Public ReadOnly fraWarp As LegacyFrame
        Public ReadOnly lblMapY As LegacyLabel
        Public ReadOnly Label8 As LegacyLabel
        Public ReadOnly lblmapX As LegacyLabel
        Public ReadOnly Label10 As LegacyLabel
        Public ReadOnly Label9 As LegacyLabel
        Public ReadOnly scrlMapY As LegacyScrollBar
        Public ReadOnly scrlMapX As LegacyScrollBar
        Public ReadOnly txtMap As LegacyTextBox
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly tmrSpellAnim As UITimer
        Public ReadOnly picSpells As LegacyPictureBox
        Public ReadOnly lblDelivery As LegacyLabel
        Public ReadOnly cmbDelivery As LegacyComboBox
        Public ReadOnly lblCastRange As LegacyLabel
        Public ReadOnly txtCastRange As LegacyTextBox
        Public ReadOnly cmbArrow As LegacyComboBox

        Public Sub New()
            Title = "Spell Editor"
            ClientSize = New Size(332, 561)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            Label1 = New LegacyLabel()
            Label1.Caption = "Name"
            Label1.Size = New Size(49, 25)
            rootLayout.Add(Label1, 8, 8)

            Label3 = New LegacyLabel()
            Label3.Caption = "Level"
            Label3.Size = New Size(49, 25)
            rootLayout.Add(Label3, 8, 88)

            lblLevelReq = New LegacyLabel()
            lblLevelReq.Caption = "1"
            lblLevelReq.Size = New Size(33, 25)
            rootLayout.Add(lblLevelReq, 296, 88)

            lblMP = New LegacyLabel()
            lblMP.Caption = "1"
            lblMP.Size = New Size(33, 25)
            rootLayout.Add(lblMP, 296, 120)

            Label7 = New LegacyLabel()
            Label7.Caption = "MP"
            Label7.Size = New Size(49, 25)
            rootLayout.Add(Label7, 8, 120)

            txtName = New LegacyTextBox()
            txtName.Text = ""
            txtName.Size = New Size(265, 26)
            rootLayout.Add(txtName, 64, 8)

            fraVitals = New LegacyFrame()
            fraVitals.Caption = "Vitals Data"
            fraVitals.Visible = False
            fraVitals.Size = New Size(321, 97)
            rootLayout.Add(fraVitals, 8, 200)
            Dim layout_fraVitals As New PixelLayout()
            fraVitals.Content = layout_fraVitals
            lblVitalMod = New LegacyLabel()
            lblVitalMod.Caption = "1"
            lblVitalMod.Size = New Size(33, 25)
            layout_fraVitals.Add(lblVitalMod, 280, 24)

            Label4 = New LegacyLabel()
            Label4.Caption = "Vital Mod"
            Label4.Size = New Size(73, 25)
            layout_fraVitals.Add(Label4, 8, 24)

            scrlVitalMod = New LegacyScrollBar()
            scrlVitalMod.MinValue = 0
            scrlVitalMod.MaxValue = 255
            scrlVitalMod.Value = 1
            scrlVitalMod.Orientation = Orientation.Horizontal
            scrlVitalMod.SmallChange = 1
            scrlVitalMod.LargeChange = 1
            scrlVitalMod.Size = New Size(193, 25)
            layout_fraVitals.Add(scrlVitalMod, 88, 24)


            cmbType = New LegacyComboBox()
            cmbType.Items.Add("Add HP")
            cmbType.Items.Add("Add MP")
            cmbType.Items.Add("Add SP")
            cmbType.Items.Add("Sub HP")
            cmbType.Items.Add("Sub MP")
            cmbType.Items.Add("Sub SP")
            cmbType.Items.Add("Give Item")
            cmbType.Items.Add("Warp")
            cmbType.Size = New Size(321, 26)
            rootLayout.Add(cmbType, 8, 160)

            fraGiveItem = New LegacyFrame()
            fraGiveItem.Caption = "Give Item"
            fraGiveItem.Visible = False
            fraGiveItem.Size = New Size(321, 97)
            rootLayout.Add(fraGiveItem, 8, 200)
            Dim layout_fraGiveItem As New PixelLayout()
            fraGiveItem.Content = layout_fraGiveItem
            Label2 = New LegacyLabel()
            Label2.Caption = "Item"
            Label2.Size = New Size(49, 25)
            layout_fraGiveItem.Add(Label2, 8, 24)

            lblItemNum = New LegacyLabel()
            lblItemNum.Caption = "1"
            lblItemNum.Size = New Size(57, 25)
            layout_fraGiveItem.Add(lblItemNum, 256, 24)

            Label5 = New LegacyLabel()
            Label5.Caption = "Value"
            Label5.Size = New Size(49, 25)
            layout_fraGiveItem.Add(Label5, 8, 56)

            lblItemValue = New LegacyLabel()
            lblItemValue.Caption = "0"
            lblItemValue.Size = New Size(57, 25)
            layout_fraGiveItem.Add(lblItemValue, 256, 56)

            scrlItemNum = New LegacyScrollBar()
            scrlItemNum.MinValue = 1
            scrlItemNum.MaxValue = 500
            scrlItemNum.Value = 1
            scrlItemNum.Orientation = Orientation.Horizontal
            scrlItemNum.SmallChange = 1
            scrlItemNum.LargeChange = 1
            scrlItemNum.Size = New Size(193, 25)
            layout_fraGiveItem.Add(scrlItemNum, 64, 24)

            scrlItemValue = New LegacyScrollBar()
            scrlItemValue.MinValue = 0
            scrlItemValue.MaxValue = 32767
            scrlItemValue.Value = 0
            scrlItemValue.Orientation = Orientation.Horizontal
            scrlItemValue.SmallChange = 1
            scrlItemValue.LargeChange = 1
            scrlItemValue.Size = New Size(193, 25)
            layout_fraGiveItem.Add(scrlItemValue, 64, 56)


            cmbClassReq = New LegacyComboBox()
            cmbClassReq.Size = New Size(321, 26)
            rootLayout.Add(cmbClassReq, 8, 48)

            scrlLevelReq = New LegacyScrollBar()
            scrlLevelReq.MinValue = 1
            scrlLevelReq.MaxValue = 255
            scrlLevelReq.Value = 1
            scrlLevelReq.Orientation = Orientation.Horizontal
            scrlLevelReq.SmallChange = 1
            scrlLevelReq.LargeChange = 1
            scrlLevelReq.Size = New Size(233, 25)
            rootLayout.Add(scrlLevelReq, 64, 88)

            fraMisc = New LegacyFrame()
            fraMisc.Caption = "Animation"
            fraMisc.Size = New Size(321, 97)
            rootLayout.Add(fraMisc, 8, 304)
            Dim layout_fraMisc As New PixelLayout()
            fraMisc.Content = layout_fraMisc
            lblAnim = New LegacyLabel()
            lblAnim.Caption = "0"
            lblAnim.Size = New Size(33, 17)
            layout_fraMisc.Add(lblAnim, 264, 24)

            scrlAnim = New LegacyScrollBar()
            scrlAnim.MinValue = 0
            scrlAnim.MaxValue = 100
            scrlAnim.Value = 0
            scrlAnim.Orientation = Orientation.Horizontal
            scrlAnim.SmallChange = 1
            scrlAnim.LargeChange = 1
            scrlAnim.Size = New Size(241, 17)
            layout_fraMisc.Add(scrlAnim, 8, 24)

            picAnim = New LegacyPictureBox()
            picAnim.Size = New Size(33, 33)
            layout_fraMisc.Add(picAnim, 16, 48)


            scrlMP = New LegacyScrollBar()
            scrlMP.MinValue = 1
            scrlMP.MaxValue = 255
            scrlMP.Value = 1
            scrlMP.Orientation = Orientation.Horizontal
            scrlMP.SmallChange = 1
            scrlMP.LargeChange = 1
            scrlMP.Size = New Size(233, 25)
            rootLayout.Add(scrlMP, 64, 120)

            fraWarp = New LegacyFrame()
            fraWarp.Caption = "Warp"
            fraWarp.Visible = False
            fraWarp.Size = New Size(321, 97)
            rootLayout.Add(fraWarp, 8, 200)
            Dim layout_fraWarp As New PixelLayout()
            fraWarp.Content = layout_fraWarp
            lblMapY = New LegacyLabel()
            lblMapY.Caption = "1"
            lblMapY.Size = New Size(57, 25)
            layout_fraWarp.Add(lblMapY, 256, 64)

            Label8 = New LegacyLabel()
            Label8.Caption = "Y"
            Label8.Size = New Size(49, 25)
            layout_fraWarp.Add(Label8, 168, 64)

            lblmapX = New LegacyLabel()
            lblmapX.Caption = "1"
            lblmapX.Size = New Size(57, 25)
            layout_fraWarp.Add(lblmapX, 96, 64)

            Label10 = New LegacyLabel()
            Label10.Caption = "X"
            Label10.Size = New Size(49, 25)
            layout_fraWarp.Add(Label10, 8, 64)

            Label9 = New LegacyLabel()
            Label9.Caption = "Map"
            Label9.Size = New Size(73, 25)
            layout_fraWarp.Add(Label9, 8, 24)

            scrlMapY = New LegacyScrollBar()
            scrlMapY.MinValue = 0
            scrlMapY.MaxValue = 11
            scrlMapY.Value = 0
            scrlMapY.Orientation = Orientation.Horizontal
            scrlMapY.SmallChange = 1
            scrlMapY.LargeChange = 1
            scrlMapY.Size = New Size(89, 25)
            layout_fraWarp.Add(scrlMapY, 192, 64)

            scrlMapX = New LegacyScrollBar()
            scrlMapX.MinValue = 0
            scrlMapX.MaxValue = 15
            scrlMapX.Value = 0
            scrlMapX.Orientation = Orientation.Horizontal
            scrlMapX.SmallChange = 1
            scrlMapX.LargeChange = 1
            scrlMapX.Size = New Size(89, 25)
            layout_fraWarp.Add(scrlMapX, 32, 64)

            txtMap = New LegacyTextBox()
            txtMap.Text = ""
            txtMap.Size = New Size(193, 26)
            layout_fraWarp.Add(txtMap, 64, 24)


            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(153, 33)
            rootLayout.Add(cmdCancel, 172, 515)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(153, 33)
            rootLayout.Add(cmdOk, 13, 515)

            tmrSpellAnim = New UITimer() With { .Interval = 0.05 }
            tmrSpellAnim.Start()
            picSpells = New LegacyPictureBox()
            picSpells.Size = New Size(89, 97)
            rootLayout.Add(picSpells, 376, 8)

            lblDelivery = New LegacyLabel()
            lblDelivery.Caption = "Spell delivery (all spell types)"
            lblDelivery.Size = New Size(320, 20)
            rootLayout.Add(lblDelivery, 8, 412)

            cmbDelivery = New LegacyComboBox()
            cmbDelivery.Size = New Size(320, 22)
            rootLayout.Add(cmbDelivery, 8, 436)

            lblCastRange = New LegacyLabel()
            lblCastRange.Caption = "Range cast: distance in tiles"
            lblCastRange.Size = New Size(178, 20)
            rootLayout.Add(lblCastRange, 8, 468)

            txtCastRange = New LegacyTextBox()
            txtCastRange.Text = "32"
            txtCastRange.Size = New Size(90, 24)
            rootLayout.Add(txtCastRange, 238, 466)

            cmbArrow = New LegacyComboBox()
            cmbArrow.Size = New Size(178, 22)
            rootLayout.Add(cmbArrow, 12, 489)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
