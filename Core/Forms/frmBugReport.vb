Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Class frmBugReport
        Inherits Form

        Public ReadOnly SSTab1 As LegacyFrame
        Public ReadOnly Frame1 As LegacyFrame
        Public ReadOnly Picture1 As LegacyPictureBox
        Public ReadOnly Label4 As LegacyLabel
        Public ReadOnly Label3 As LegacyLabel
        Public ReadOnly Label1 As LegacyLabel
        Public ReadOnly hosttxtBugReport As LegacyPictureBox
        Public ReadOnly cmdSend As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly picType As LegacyPictureBox
        Public ReadOnly Label5 As LegacyLabel
        Public ReadOnly optOther As LegacyRadioButton
        Public ReadOnly optProgramming As LegacyRadioButton
        Public ReadOnly optMapping As LegacyRadioButton
        Public ReadOnly picOccurence As LegacyPictureBox
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly optOnce As LegacyRadioButton
        Public ReadOnly optSometimes As LegacyRadioButton
        Public ReadOnly optOften As LegacyRadioButton

        Public Sub New()
            Title = "Bug Report"
            ClientSize = New Size(337, 352)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            SSTab1 = New LegacyFrame()
            SSTab1.Caption = "Bug Report"
            SSTab1.Size = New Size(321, 337)
            rootLayout.Add(SSTab1, 8, 8)
            Dim layout_SSTab1 As New PixelLayout()
            SSTab1.Content = layout_SSTab1
            Frame1 = New LegacyFrame()
            Frame1.Caption = "Bug Report"
            Frame1.Size = New Size(305, 313)
            layout_SSTab1.Add(Frame1, 8, 16)
            Dim layout_Frame1 As New PixelLayout()
            Frame1.Content = layout_Frame1
            Picture1 = New LegacyPictureBox()
            Picture1.Size = New Size(289, 289)
            layout_Frame1.Add(Picture1, 8, 16)
            Dim layout_Picture1 As New PixelLayout()
            Picture1.Content = layout_Picture1
            Label4 = New LegacyLabel()
            Label4.Caption = "Can you repeat this bug?"
            Label4.Size = New Size(297, 17)
            layout_Picture1.Add(Label4, 0, 176)

            Label3 = New LegacyLabel()
            Label3.Caption = "Describe the bug here:"
            Label3.Size = New Size(265, 17)
            layout_Picture1.Add(Label3, 16, 128)

            Label1 = New LegacyLabel()
            Label1.Caption = "Hello players. This is the new bug report system. Please describe the type of bug, how severe the bug is to your gameplay, and if it can be avoided in any way. Please do not abuse!"
            Label1.Size = New Size(289, 41)
            layout_Picture1.Add(Label1, 0, 0)

            hosttxtBugReport = New LegacyPictureBox()
            hosttxtBugReport.Size = New Size(262, 95)
            layout_Picture1.Add(hosttxtBugReport, 16, 144)

            cmdSend = New LegacyButton()
            cmdSend.Caption = "Send Report"
            cmdSend.Size = New Size(129, 33)
            layout_Picture1.Add(cmdSend, 16, 248)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(129, 33)
            layout_Picture1.Add(cmdCancel, 152, 248)

            picType = New LegacyPictureBox()
            picType.Size = New Size(289, 65)
            layout_Picture1.Add(picType, 8, 40)
            Dim layout_picType As New PixelLayout()
            picType.Content = layout_picType
            Label5 = New LegacyLabel()
            Label5.Caption = "Type of bug:"
            Label5.Size = New Size(292, 13)
            layout_picType.Add(Label5, -8, 0)

            optOther = New LegacyRadioButton()
            optOther.Caption = "Other"
            optOther.Size = New Size(57, 17)
            layout_picType.Add(optOther, 216, 16)

            optProgramming = New LegacyRadioButton(optOther)
            optProgramming.Caption = "Programming"
            optProgramming.Size = New Size(89, 17)
            layout_picType.Add(optProgramming, 104, 16)

            optMapping = New LegacyRadioButton(optOther)
            optMapping.Caption = "Mapping"
            optMapping.Value = True
            optMapping.Size = New Size(65, 17)
            layout_picType.Add(optMapping, 16, 16)


            picOccurence = New LegacyPictureBox()
            picOccurence.Size = New Size(289, 49)
            layout_Picture1.Add(picOccurence, 8, 80)
            Dim layout_picOccurence As New PixelLayout()
            picOccurence.Content = layout_picOccurence
            Label2 = New LegacyLabel()
            Label2.Caption = "How often does this bug occur?"
            Label2.Size = New Size(297, 17)
            layout_picOccurence.Add(Label2, 0, 0)

            optOnce = New LegacyRadioButton()
            optOnce.Caption = "Once"
            optOnce.Size = New Size(49, 17)
            layout_picOccurence.Add(optOnce, 216, 16)

            optSometimes = New LegacyRadioButton(optOnce)
            optSometimes.Caption = "Sometimes"
            optSometimes.Size = New Size(73, 17)
            layout_picOccurence.Add(optSometimes, 104, 16)

            optOften = New LegacyRadioButton(optOnce)
            optOften.Caption = "Often"
            optOften.Value = True
            optOften.Size = New Size(49, 17)
            layout_picOccurence.Add(optOften, 16, 16)





            AddHandler Shown, AddressOf OnFormShown
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            ' Hook point for migrated Form_Load logic.
        End Sub
    End Class
End Namespace
