Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmItemEditor
        Inherits Form

        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly Label5 As LegacyLabel
        Public ReadOnly lblPic As LegacyLabel
        Public ReadOnly cmbType As LegacyComboBox
        Public ReadOnly txtName As LegacyTextBox
        Public ReadOnly fraEquipment As LegacyFrame
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly lblDurability As LegacyLabel
        Public ReadOnly lblStrength As LegacyLabel
        Public ReadOnly scrlDurability As LegacyScrollBar
        Public ReadOnly scrlStrength As LegacyScrollBar
        Public ReadOnly fraVitals As LegacyFrame
        Public ReadOnly Label4 As LegacyLabel
        Public ReadOnly lblVitalMod As LegacyLabel
        Public ReadOnly scrlVitalMod As LegacyScrollBar
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly scrlPic As LegacyScrollBar
        Public ReadOnly picPic As LegacyPictureBox
        Public ReadOnly tmrPic As UITimer
        Public ReadOnly fraSpell As LegacyFrame
        Public ReadOnly lblSpell As LegacyLabel
        Public ReadOnly Label7 As LegacyLabel
        Public ReadOnly Label6 As LegacyLabel
        Public ReadOnly lblSpellName As LegacyLabel
        Public ReadOnly scrlSpell As LegacyScrollBar
        Public ReadOnly fraWarp As LegacyFrame
        Public ReadOnly Label9 As LegacyLabel
        Public ReadOnly Label10 As LegacyLabel
        Public ReadOnly lblmapX As LegacyLabel
        Public ReadOnly Label8 As LegacyLabel
        Public ReadOnly lblMapY As LegacyLabel
        Public ReadOnly txtMap As LegacyTextBox
        Public ReadOnly scrlMapX As LegacyScrollBar
        Public ReadOnly scrlMapY As LegacyScrollBar

        Public Sub New()
            Title = "Item Editor"
            ClientSize = New Size(337, 285)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            Label1 = New LegacyLabel()
            Label1.Caption = "Name"
            Label1.Size = New Size(49, 25)
            rootLayout.Add(Label1, 8, 8)

            Label5 = New LegacyLabel()
            Label5.Caption = "Pic"
            Label5.Size = New Size(57, 25)
            rootLayout.Add(Label5, 8, 40)

            lblPic = New LegacyLabel()
            lblPic.Caption = "0"
            lblPic.Size = New Size(33, 25)
            rootLayout.Add(lblPic, 256, 40)

            cmbType = New LegacyComboBox()
            cmbType.Items.Add("None")
            cmbType.Items.Add("Weapon")
            cmbType.Items.Add("Armor")
            cmbType.Items.Add("Helmet")
            cmbType.Items.Add("Shield")
            cmbType.Items.Add("Potion Add HP")
            cmbType.Items.Add("Potion Add MP")
            cmbType.Items.Add("Potion Add SP")
            cmbType.Items.Add("Potion Sub HP")
            cmbType.Items.Add("Potion Sub MP")
            cmbType.Items.Add("Potion Sub SP")
            cmbType.Items.Add("Key")
            cmbType.Items.Add("Currency")
            cmbType.Items.Add("Spell")
            cmbType.Items.Add("Warp")
            cmbType.Size = New Size(321, 26)
            rootLayout.Add(cmbType, 8, 88)

            txtName = New LegacyTextBox()
            txtName.Text = ""
            txtName.Size = New Size(265, 26)
            rootLayout.Add(txtName, 64, 8)

            fraEquipment = New LegacyFrame()
            fraEquipment.Caption = "Equipment Data"
            fraEquipment.Visible = False
            fraEquipment.Size = New Size(321, 97)
            rootLayout.Add(fraEquipment, 8, 128)
            Dim layout_fraEquipment As New PixelLayout()
            fraEquipment.Content = layout_fraEquipment
            Label2 = New LegacyLabel()
            Label2.Caption = "Durability"
            Label2.Size = New Size(73, 25)
            layout_fraEquipment.Add(Label2, 8, 32)

            Label3 = New LegacyLabel()
            Label3.Caption = "Strength"
            Label3.Size = New Size(65, 25)
            layout_fraEquipment.Add(Label3, 8, 64)

            lblDurability = New LegacyLabel()
            lblDurability.Caption = "1"
            lblDurability.Size = New Size(33, 25)
            layout_fraEquipment.Add(lblDurability, 280, 32)

            lblStrength = New LegacyLabel()
            lblStrength.Caption = "1"
            lblStrength.Size = New Size(33, 25)
            layout_fraEquipment.Add(lblStrength, 280, 64)

            scrlDurability = New LegacyScrollBar()
            scrlDurability.MinValue = 0
            scrlDurability.MaxValue = 255
            scrlDurability.Value = 1
            scrlDurability.Orientation = Orientation.Horizontal
            scrlDurability.SmallChange = 1
            scrlDurability.LargeChange = 1
            scrlDurability.Size = New Size(193, 25)
            layout_fraEquipment.Add(scrlDurability, 88, 32)

            scrlStrength = New LegacyScrollBar()
            scrlStrength.MinValue = 0
            scrlStrength.MaxValue = 255
            scrlStrength.Value = 1
            scrlStrength.Orientation = Orientation.Horizontal
            scrlStrength.SmallChange = 1
            scrlStrength.LargeChange = 1
            scrlStrength.Size = New Size(193, 25)
            layout_fraEquipment.Add(scrlStrength, 88, 64)


            fraVitals = New LegacyFrame()
            fraVitals.Caption = "Vitals Data"
            fraVitals.Visible = False
            fraVitals.Size = New Size(321, 97)
            rootLayout.Add(fraVitals, 8, 128)
            Dim layout_fraVitals As New PixelLayout()
            fraVitals.Content = layout_fraVitals
            Label4 = New LegacyLabel()
            Label4.Caption = "Vital Mod"
            Label4.Size = New Size(73, 25)
            layout_fraVitals.Add(Label4, 8, 24)

            lblVitalMod = New LegacyLabel()
            lblVitalMod.Caption = "1"
            lblVitalMod.Size = New Size(33, 25)
            layout_fraVitals.Add(lblVitalMod, 280, 24)

            scrlVitalMod = New LegacyScrollBar()
            scrlVitalMod.MinValue = 0
            scrlVitalMod.MaxValue = 255
            scrlVitalMod.Value = 1
            scrlVitalMod.Orientation = Orientation.Horizontal
            scrlVitalMod.SmallChange = 1
            scrlVitalMod.LargeChange = 1
            scrlVitalMod.Size = New Size(193, 25)
            layout_fraVitals.Add(scrlVitalMod, 88, 24)


            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(153, 33)
            rootLayout.Add(cmdOk, 11, 240)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(153, 33)
            rootLayout.Add(cmdCancel, 176, 240)

            scrlPic = New LegacyScrollBar()
            scrlPic.MinValue = 0
            scrlPic.MaxValue = 500
            scrlPic.Value = 0
            scrlPic.Orientation = Orientation.Horizontal
            scrlPic.SmallChange = 1
            scrlPic.LargeChange = 1
            scrlPic.Size = New Size(193, 25)
            rootLayout.Add(scrlPic, 64, 40)

            picPic = New LegacyPictureBox()
            picPic.Size = New Size(32, 32)
            rootLayout.Add(picPic, 296, 40)

            tmrPic = New UITimer() With { .Interval = 0.05 }
            tmrPic.Start()
            fraSpell = New LegacyFrame()
            fraSpell.Caption = "Spell Data"
            fraSpell.Visible = False
            fraSpell.Size = New Size(321, 97)
            rootLayout.Add(fraSpell, 8, 128)
            Dim layout_fraSpell As New PixelLayout()
            fraSpell.Content = layout_fraSpell
            lblSpell = New LegacyLabel()
            lblSpell.Caption = "1"
            lblSpell.Size = New Size(57, 25)
            layout_fraSpell.Add(lblSpell, 256, 56)

            Label7 = New LegacyLabel()
            Label7.Caption = "Num"
            Label7.Size = New Size(49, 25)
            layout_fraSpell.Add(Label7, 8, 56)

            Label6 = New LegacyLabel()
            Label6.Caption = "Name"
            Label6.Size = New Size(73, 25)
            layout_fraSpell.Add(Label6, 8, 24)

            lblSpellName = New LegacyLabel()
            lblSpellName.Caption = ""
            lblSpellName.Size = New Size(225, 25)
            layout_fraSpell.Add(lblSpellName, 88, 24)

            scrlSpell = New LegacyScrollBar()
            scrlSpell.MinValue = 0
            scrlSpell.MaxValue = 500
            scrlSpell.Value = 1
            scrlSpell.Orientation = Orientation.Horizontal
            scrlSpell.SmallChange = 1
            scrlSpell.LargeChange = 1
            scrlSpell.Size = New Size(193, 25)
            layout_fraSpell.Add(scrlSpell, 64, 56)


            fraWarp = New LegacyFrame()
            fraWarp.Caption = "Warp Data"
            fraWarp.Visible = False
            fraWarp.Size = New Size(321, 97)
            rootLayout.Add(fraWarp, 8, 128)
            Dim layout_fraWarp As New PixelLayout()
            fraWarp.Content = layout_fraWarp
            Label9 = New LegacyLabel()
            Label9.Caption = "Map"
            Label9.Size = New Size(73, 25)
            layout_fraWarp.Add(Label9, 8, 24)

            Label10 = New LegacyLabel()
            Label10.Caption = "X"
            Label10.Size = New Size(49, 25)
            layout_fraWarp.Add(Label10, 8, 64)

            lblmapX = New LegacyLabel()
            lblmapX.Caption = "1"
            lblmapX.Size = New Size(57, 25)
            layout_fraWarp.Add(lblmapX, 96, 64)

            Label8 = New LegacyLabel()
            Label8.Caption = "Y"
            Label8.Size = New Size(49, 25)
            layout_fraWarp.Add(Label8, 168, 64)

            lblMapY = New LegacyLabel()
            lblMapY.Caption = "1"
            lblMapY.Size = New Size(57, 25)
            layout_fraWarp.Add(lblMapY, 256, 64)

            txtMap = New LegacyTextBox()
            txtMap.Text = ""
            txtMap.Size = New Size(193, 26)
            layout_fraWarp.Add(txtMap, 64, 24)

            scrlMapX = New LegacyScrollBar()
            scrlMapX.MinValue = 0
            scrlMapX.MaxValue = 15
            scrlMapX.Value = 0
            scrlMapX.Orientation = Orientation.Horizontal
            scrlMapX.SmallChange = 1
            scrlMapX.LargeChange = 1
            scrlMapX.Size = New Size(89, 25)
            layout_fraWarp.Add(scrlMapX, 32, 64)

            scrlMapY = New LegacyScrollBar()
            scrlMapY.MinValue = 0
            scrlMapY.MaxValue = 11
            scrlMapY.Value = 0
            scrlMapY.Orientation = Orientation.Horizontal
            scrlMapY.SmallChange = 1
            scrlMapY.LargeChange = 1
            scrlMapY.Size = New Size(89, 25)
            layout_fraWarp.Add(scrlMapY, 192, 64)


            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
