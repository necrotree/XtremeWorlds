Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmClassEditor
        Inherits Form

        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly cmdOk As LegacyButton
        Public ReadOnly lblMAGI As LegacyLabel
        Public ReadOnly lblMAGITitle As LegacyLabel
        Public ReadOnly scrlMAGI As LegacyScrollBar
        Public ReadOnly lblSPD As LegacyLabel
        Public ReadOnly lblSPDTitle As LegacyLabel
        Public ReadOnly scrlSPD As LegacyScrollBar
        Public ReadOnly lblDEF As LegacyLabel
        Public ReadOnly lblDEFTitle As LegacyLabel
        Public ReadOnly scrlDEF As LegacyScrollBar
        Public ReadOnly lblSTR As LegacyLabel
        Public ReadOnly lblSTRTitle As LegacyLabel
        Public ReadOnly scrlSTR As LegacyScrollBar
        Public ReadOnly lblSprite As LegacyLabel
        Public ReadOnly lblSpriteTitle As LegacyLabel
        Public ReadOnly scrlMSprite As LegacyScrollBar
        Public ReadOnly lblName As LegacyLabel
        Public ReadOnly txtName As LegacyTextBox
        Public ReadOnly lblMapTitle As LegacyLabel
        Public ReadOnly lblMap As LegacyLabel
        Public ReadOnly lblXTitle As LegacyLabel
        Public ReadOnly scrlX As LegacyScrollBar
        Public ReadOnly lblX As LegacyLabel
        Public ReadOnly lblYTitle As LegacyLabel
        Public ReadOnly scrlY As LegacyScrollBar
        Public ReadOnly lblY As LegacyLabel
        Public ReadOnly scrlMap As LegacyScrollBar
        Public ReadOnly lblStatus As LegacyLabel
        Public ReadOnly lblSprite2Title As LegacyLabel
        Public ReadOnly scrlFSprite As LegacyScrollBar
        Public ReadOnly lblSprite2 As LegacyLabel
        Public ReadOnly imgMSprite As ImageView
        Public ReadOnly imgFSprite As ImageView

        Public Sub New()
            Title = "Class Editor"
            ClientSize = New Size(355, 376)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(161, 41)
            rootLayout.Add(cmdCancel, 170, 331)

            cmdOk = New LegacyButton()
            cmdOk.Caption = "Ok"
            cmdOk.Size = New Size(161, 41)
            rootLayout.Add(cmdOk, 9, 330)

            lblMAGI = New LegacyLabel()
            lblMAGI.Caption = "0"
            lblMAGI.Size = New Size(33, 25)
            rootLayout.Add(lblMAGI, 262, 215)

            lblMAGITitle = New LegacyLabel()
            lblMAGITitle.Caption = "MAGI"
            lblMAGITitle.Size = New Size(57, 25)
            rootLayout.Add(lblMAGITitle, 14, 215)

            scrlMAGI = New LegacyScrollBar()
            scrlMAGI.MinValue = 0
            scrlMAGI.MaxValue = 255
            scrlMAGI.Value = 0
            scrlMAGI.Orientation = Orientation.Horizontal
            scrlMAGI.SmallChange = 1
            scrlMAGI.LargeChange = 1
            scrlMAGI.Size = New Size(193, 25)
            rootLayout.Add(scrlMAGI, 70, 215)

            lblSPD = New LegacyLabel()
            lblSPD.Caption = "0"
            lblSPD.Size = New Size(33, 25)
            rootLayout.Add(lblSPD, 260, 183)

            lblSPDTitle = New LegacyLabel()
            lblSPDTitle.Caption = "SPD"
            lblSPDTitle.Size = New Size(57, 25)
            rootLayout.Add(lblSPDTitle, 14, 183)

            scrlSPD = New LegacyScrollBar()
            scrlSPD.MinValue = 0
            scrlSPD.MaxValue = 255
            scrlSPD.Value = 0
            scrlSPD.Orientation = Orientation.Horizontal
            scrlSPD.SmallChange = 1
            scrlSPD.LargeChange = 1
            scrlSPD.Size = New Size(193, 25)
            rootLayout.Add(scrlSPD, 70, 183)

            lblDEF = New LegacyLabel()
            lblDEF.Caption = "0"
            lblDEF.Size = New Size(33, 25)
            rootLayout.Add(lblDEF, 262, 151)

            lblDEFTitle = New LegacyLabel()
            lblDEFTitle.Caption = "DEF"
            lblDEFTitle.Size = New Size(57, 25)
            rootLayout.Add(lblDEFTitle, 14, 151)

            scrlDEF = New LegacyScrollBar()
            scrlDEF.MinValue = 0
            scrlDEF.MaxValue = 255
            scrlDEF.Value = 0
            scrlDEF.Orientation = Orientation.Horizontal
            scrlDEF.SmallChange = 1
            scrlDEF.LargeChange = 1
            scrlDEF.Size = New Size(193, 25)
            rootLayout.Add(scrlDEF, 70, 151)

            lblSTR = New LegacyLabel()
            lblSTR.Caption = "0"
            lblSTR.Size = New Size(33, 25)
            rootLayout.Add(lblSTR, 262, 119)

            lblSTRTitle = New LegacyLabel()
            lblSTRTitle.Caption = "STR"
            lblSTRTitle.Size = New Size(57, 25)
            rootLayout.Add(lblSTRTitle, 14, 119)

            scrlSTR = New LegacyScrollBar()
            scrlSTR.MinValue = 0
            scrlSTR.MaxValue = 255
            scrlSTR.Value = 0
            scrlSTR.Orientation = Orientation.Horizontal
            scrlSTR.SmallChange = 1
            scrlSTR.LargeChange = 1
            scrlSTR.Size = New Size(193, 25)
            rootLayout.Add(scrlSTR, 70, 118)

            lblSprite = New LegacyLabel()
            lblSprite.Caption = "0"
            lblSprite.Size = New Size(33, 25)
            rootLayout.Add(lblSprite, 264, 48)

            lblSpriteTitle = New LegacyLabel()
            lblSpriteTitle.Caption = "M Sprite"
            lblSpriteTitle.Size = New Size(78, 25)
            rootLayout.Add(lblSpriteTitle, 8, 48)

            scrlMSprite = New LegacyScrollBar()
            scrlMSprite.MinValue = 0
            scrlMSprite.MaxValue = 500
            scrlMSprite.Value = 0
            scrlMSprite.Orientation = Orientation.Horizontal
            scrlMSprite.SmallChange = 1
            scrlMSprite.LargeChange = 1
            scrlMSprite.Size = New Size(193, 25)
            rootLayout.Add(scrlMSprite, 72, 48)

            lblName = New LegacyLabel()
            lblName.Caption = "Name"
            lblName.Size = New Size(65, 25)
            rootLayout.Add(lblName, 8, 8)

            txtName = New LegacyTextBox()
            txtName.Text = ""
            txtName.Size = New Size(249, 26)
            rootLayout.Add(txtName, 80, 8)

            lblMapTitle = New LegacyLabel()
            lblMapTitle.Caption = "Map"
            lblMapTitle.Size = New Size(57, 25)
            rootLayout.Add(lblMapTitle, 13, 240)

            lblMap = New LegacyLabel()
            lblMap.Caption = "0"
            lblMap.Size = New Size(33, 25)
            rootLayout.Add(lblMap, 262, 240)

            lblXTitle = New LegacyLabel()
            lblXTitle.Caption = "X"
            lblXTitle.Size = New Size(57, 25)
            rootLayout.Add(lblXTitle, 11, 267)

            scrlX = New LegacyScrollBar()
            scrlX.MinValue = 0
            scrlX.MaxValue = 255
            scrlX.Value = 0
            scrlX.Orientation = Orientation.Horizontal
            scrlX.SmallChange = 1
            scrlX.LargeChange = 1
            scrlX.Size = New Size(193, 25)
            rootLayout.Add(scrlX, 69, 270)

            lblX = New LegacyLabel()
            lblX.Caption = "0"
            lblX.Size = New Size(33, 25)
            rootLayout.Add(lblX, 261, 271)

            lblYTitle = New LegacyLabel()
            lblYTitle.Caption = "Y"
            lblYTitle.Size = New Size(57, 25)
            rootLayout.Add(lblYTitle, 11, 297)

            scrlY = New LegacyScrollBar()
            scrlY.MinValue = 0
            scrlY.MaxValue = 255
            scrlY.Value = 0
            scrlY.Orientation = Orientation.Horizontal
            scrlY.SmallChange = 1
            scrlY.LargeChange = 1
            scrlY.Size = New Size(193, 25)
            rootLayout.Add(scrlY, 67, 300)

            lblY = New LegacyLabel()
            lblY.Caption = "0"
            lblY.Size = New Size(33, 25)
            rootLayout.Add(lblY, 261, 301)

            scrlMap = New LegacyScrollBar()
            scrlMap.MinValue = 0
            scrlMap.MaxValue = 9999
            scrlMap.Value = 0
            scrlMap.Orientation = Orientation.Horizontal
            scrlMap.SmallChange = 1
            scrlMap.LargeChange = 1
            scrlMap.Size = New Size(193, 25)
            rootLayout.Add(scrlMap, 71, 240)

            lblStatus = New LegacyLabel()
            lblStatus.Caption = ""
            lblStatus.Size = New Size(321, 16)
            rootLayout.Add(lblStatus, 0, 0)

            lblSprite2Title = New LegacyLabel()
            lblSprite2Title.Caption = "F Sprite"
            lblSprite2Title.Size = New Size(78, 25)
            rootLayout.Add(lblSprite2Title, 8, 83)

            scrlFSprite = New LegacyScrollBar()
            scrlFSprite.MinValue = 0
            scrlFSprite.MaxValue = 500
            scrlFSprite.Value = 0
            scrlFSprite.Orientation = Orientation.Horizontal
            scrlFSprite.SmallChange = 1
            scrlFSprite.LargeChange = 1
            scrlFSprite.Size = New Size(193, 25)
            rootLayout.Add(scrlFSprite, 72, 83)

            lblSprite2 = New LegacyLabel()
            lblSprite2.Caption = "0"
            lblSprite2.Size = New Size(33, 25)
            rootLayout.Add(lblSprite2, 264, 83)

            imgMSprite = New ImageView()
            imgMSprite.Size = New Size(48, 64)
            rootLayout.Add(imgMSprite, 301, 45)

            imgFSprite = New ImageView()
            imgFSprite.Size = New Size(48, 64)
            rootLayout.Add(imgFSprite, 302, 115)

            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
