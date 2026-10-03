Imports System
Imports Eto.Forms

Namespace XtremeWorlds.Client.Forms
    Public NotInheritable Class GameDialogs
        Private Sub New()
        End Sub

        Public Shared Function Alert(owner As Window, message As String, Optional title As String = "Alert") As GameDialogResult
            Using dialog As New frmAlert()
                dialog.Configure(message, GameDialogButtons.Ok, title)
                Return ShowDialog(dialog, owner)
            End Using
        End Function

        Public Shared Function Confirm(owner As Window, message As String, Optional title As String = "Alert") As GameDialogResult
            Using dialog As New frmAlert()
                dialog.Configure(message, GameDialogButtons.YesNo, title)
                Return ShowDialog(dialog, owner)
            End Using
        End Function

        Public Shared Function Input(owner As Window, message As String, defaultValue As String, Optional title As String = "Alert") As String
            Using dialog As New frmAlert()
                dialog.ConfigureInput(message, defaultValue, title)
                Dim result = ShowDialog(dialog, owner)
                If result = GameDialogResult.Yes Then Return dialog.InputValue
                Return String.Empty
            End Using
        End Function

        Private Shared Function ShowDialog(dialog As frmAlert, owner As Window) As GameDialogResult
            If owner IsNot Nothing Then Return dialog.ShowModal(owner)
            If Application.Instance IsNot Nothing AndAlso Application.Instance.MainForm IsNot Nothing Then
                Return dialog.ShowModal(Application.Instance.MainForm)
            End If
            Return dialog.ShowModal()
        End Function
    End Class
End Namespace
