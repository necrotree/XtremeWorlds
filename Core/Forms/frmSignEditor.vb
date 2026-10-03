Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmSignEditor
        Inherits Form

        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly Label4 As LegacyLabel
        Public ReadOnly Label5 As LegacyLabel
        Public ReadOnly txtSignName As LegacyTextBox
        Public ReadOnly txtSignLine3 As LegacyTextBox
        Public ReadOnly txtSignLine2 As LegacyTextBox
        Public ReadOnly txtSignLine1 As LegacyTextBox
        Public ReadOnly optWooden As LegacyRadioButton
        Public ReadOnly optScroll As LegacyRadioButton
        Public ReadOnly cmdOK As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly cmdPrev As LegacyButton
        Public ReadOnly picSign As LegacyPictureBox
        Public ReadOnly lblNameBtm As LegacyLabel
        Public ReadOnly lblNameTop As LegacyLabel
        Public ReadOnly lblLine3Btm As LegacyLabel
        Public ReadOnly lblLine2Btm As LegacyLabel
        Public ReadOnly lblLine1Btm As LegacyLabel
        Public ReadOnly Line1 As Drawable
        Public ReadOnly lblLine3Top As LegacyLabel
        Public ReadOnly lblLine2Top As LegacyLabel
        Public ReadOnly lblLine1Top As LegacyLabel
        Public ReadOnly lblexit As LegacyLabel

        Public Sub New()
            Title = "Sign Editor"
            ClientSize = New Size(201, 505)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            Label1 = New LegacyLabel()
            Label1.Caption = "Sign Name"
            Label1.Size = New Size(137, 17)
            rootLayout.Add(Label1, 32, 144)

            Label2 = New LegacyLabel()
            Label2.Caption = "Background"
            Label2.Size = New Size(137, 17)
            rootLayout.Add(Label2, 32, 200)

            Label3 = New LegacyLabel()
            Label3.Caption = "Line 3"
            Label3.Size = New Size(137, 17)
            rootLayout.Add(Label3, 32, 384)

            Label4 = New LegacyLabel()
            Label4.Caption = "Line 2"
            Label4.Size = New Size(137, 17)
            rootLayout.Add(Label4, 32, 328)

            Label5 = New LegacyLabel()
            Label5.Caption = "Line 1"
            Label5.Size = New Size(137, 17)
            rootLayout.Add(Label5, 32, 272)

            txtSignName = New LegacyTextBox()
            txtSignName.Text = "Name"
            txtSignName.Size = New Size(137, 25)
            rootLayout.Add(txtSignName, 32, 168)

            txtSignLine3 = New LegacyTextBox()
            txtSignLine3.Text = ""
            txtSignLine3.Size = New Size(137, 25)
            rootLayout.Add(txtSignLine3, 32, 408)

            txtSignLine2 = New LegacyTextBox()
            txtSignLine2.Text = ""
            txtSignLine2.Size = New Size(137, 25)
            rootLayout.Add(txtSignLine2, 32, 352)

            txtSignLine1 = New LegacyTextBox()
            txtSignLine1.Text = ""
            txtSignLine1.Size = New Size(137, 25)
            rootLayout.Add(txtSignLine1, 32, 296)

            optWooden = New LegacyRadioButton()
            optWooden.Caption = "Wooden Sign"
            optWooden.Value = True
            optWooden.Size = New Size(137, 17)
            rootLayout.Add(optWooden, 32, 224)

            optScroll = New LegacyRadioButton(optWooden)
            optScroll.Caption = "Parchment / Scroll"
            optScroll.Size = New Size(137, 17)
            rootLayout.Add(optScroll, 32, 248)

            cmdOK = New LegacyButton()
            cmdOK.Caption = "OK"
            cmdOK.Size = New Size(65, 25)
            rootLayout.Add(cmdOK, 32, 472)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(65, 25)
            rootLayout.Add(cmdCancel, 104, 472)

            cmdPrev = New LegacyButton()
            cmdPrev.Caption = "Preview Sign"
            cmdPrev.Size = New Size(137, 25)
            rootLayout.Add(cmdPrev, 32, 440)

            picSign = New LegacyPictureBox()
            picSign.Size = New Size(185, 121)
            rootLayout.Add(picSign, 8, 8)
            Dim layout_picSign As New PixelLayout()
            picSign.Content = layout_picSign
            lblNameBtm = New LegacyLabel()
            lblNameBtm.Caption = "Name"
            lblNameBtm.Size = New Size(185, 25)
            layout_picSign.Add(lblNameBtm, 0, 11)

            lblNameTop = New LegacyLabel()
            lblNameTop.Caption = "Name"
            lblNameTop.Size = New Size(185, 25)
            layout_picSign.Add(lblNameTop, 3, 8)

            lblLine3Btm = New LegacyLabel()
            lblLine3Btm.Caption = "Line3"
            lblLine3Btm.Size = New Size(185, 25)
            layout_picSign.Add(lblLine3Btm, 0, 70)

            lblLine2Btm = New LegacyLabel()
            lblLine2Btm.Caption = "Line2"
            lblLine2Btm.Size = New Size(185, 25)
            layout_picSign.Add(lblLine2Btm, 0, 54)

            lblLine1Btm = New LegacyLabel()
            lblLine1Btm.Caption = "Line1"
            lblLine1Btm.Size = New Size(185, 25)
            layout_picSign.Add(lblLine1Btm, 0, 38)

            Line1 = New Drawable()
            Line1.Size = New Size(10, 10)
            layout_picSign.Add(Line1, 0, 0)

            lblLine3Top = New LegacyLabel()
            lblLine3Top.Caption = "Line3"
            lblLine3Top.Size = New Size(185, 25)
            layout_picSign.Add(lblLine3Top, 3, 67)

            lblLine2Top = New LegacyLabel()
            lblLine2Top.Caption = "Line2"
            lblLine2Top.Size = New Size(185, 25)
            layout_picSign.Add(lblLine2Top, 3, 51)

            lblLine1Top = New LegacyLabel()
            lblLine1Top.Caption = "Line1"
            lblLine1Top.Size = New Size(185, 25)
            layout_picSign.Add(lblLine1Top, 3, 35)

            lblexit = New LegacyLabel()
            lblexit.Caption = "Exit"
            lblexit.Size = New Size(57, 17)
            layout_picSign.Add(lblexit, 64, 104)


            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
