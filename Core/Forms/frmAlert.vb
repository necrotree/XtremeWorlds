Imports System
Imports Eto.Drawing
Imports Eto.Forms
Imports XtremeWorlds.Client.UI

Namespace XtremeWorlds.Client.Forms
    Public Enum GameDialogButtons
        Ok = 0
        YesNo = 1
    End Enum

    Public Enum GameDialogResult
        None = 0
        Ok = 1
        Yes = 6
        No = 7
    End Enum

    ''' <summary>
    ''' TwinBASIC-style alert dialog. The artwork is the original game skin,
    ''' while the message, input field and buttons remain real Eto controls.
    ''' </summary>
    Public Class frmAlert
        Inherits Dialog(Of GameDialogResult)

        Private ReadOnly _layout As PixelLayout
        Private ReadOnly _message As TextArea
        Private ReadOnly _input As TextBox
        Private ReadOnly _ok As Button
        Private ReadOnly _yes As Button
        Private ReadOnly _no As Button
        Private _defaultResult As GameDialogResult = GameDialogResult.Ok
        Private _escapeResult As GameDialogResult = GameDialogResult.Ok

        Public ReadOnly Property InputValue As String
            Get
                Return If(_input.Text, String.Empty)
            End Get
        End Property

        Public Sub New()
            Title = "Alert"
            Style = "AlertWindow"
            ClientSize = New Size(262, 128)
            Resizable = False
            Maximizable = False
            Minimizable = False
            ShowInTaskbar = False
            WindowStyle = WindowStyle.None

            _layout = New PixelLayout()
            Content = _layout

            _message = New TextArea With {
                .ReadOnly = True,
                .Wrap = True,
                .Style = "AlertMessage",
                .Size = New Size(226, 58)
            }
            _layout.Add(_message, 18, 27)

            _input = New TextBox With {
                .Visible = False,
                .Style = "AlertInput",
                .Size = New Size(226, 22)
            }
            _layout.Add(_input, 18, 70)

            _ok = CreateButton("AlertOkButton", New Size(104, 23), AddressOf HandleOk)
            _yes = CreateButton("AlertYesButton", New Size(105, 23), AddressOf HandleYes)
            _no = CreateButton("AlertNoButton", New Size(109, 28), AddressOf HandleNo)

            _layout.Add(_ok, 79, 96)
            _layout.Add(_yes, 20, 96)
            _layout.Add(_no, 133, 93)

            AddHandler KeyDown, AddressOf HandleKeyDown
            AddHandler Shown, AddressOf HandleShown
        End Sub

        Private Function CreateButton(styleName As String, buttonSize As Size, handler As EventHandler(Of EventArgs)) As Button
            Dim button As New Button With {
                .Text = String.Empty,
                .Style = styleName,
                .Size = buttonSize
            }
            AddHandler button.Click, handler
            Return button
        End Function

        Public Sub Configure(message As String, buttons As GameDialogButtons, Optional titleText As String = "Alert")
            Title = If(String.IsNullOrWhiteSpace(titleText), "Alert", titleText)
            _message.Text = If(message, String.Empty)
            _message.Size = New Size(226, 58)
            _input.Visible = False
            ClientSize = New Size(262, 128)

            _ok.Visible = buttons = GameDialogButtons.Ok
            _yes.Visible = buttons = GameDialogButtons.YesNo
            _no.Visible = buttons = GameDialogButtons.YesNo

            If buttons = GameDialogButtons.YesNo Then
                _defaultResult = GameDialogResult.No
                _escapeResult = GameDialogResult.No
            Else
                _defaultResult = GameDialogResult.Ok
                _escapeResult = GameDialogResult.Ok
            End If
        End Sub

        Public Sub ConfigureInput(message As String, defaultValue As String, Optional titleText As String = "Alert")
            Configure(message, GameDialogButtons.YesNo, titleText)
            ClientSize = New Size(262, 152)
            _message.Size = New Size(226, 34)
            _input.Text = If(defaultValue, String.Empty)
            _input.Visible = True
            _layout.Move(_input, 18, 66)
            _layout.Move(_yes, 20, 119)
            _layout.Move(_no, 133, 116)
        End Sub

        Private Sub HandleShown(sender As Object, e As EventArgs)
            If _input.Visible Then
                _input.Focus()
            ElseIf _defaultResult = GameDialogResult.No Then
                _no.Focus()
            Else
                _ok.Focus()
            End If
        End Sub

        Private Sub HandleOk(sender As Object, e As EventArgs)
            Close(GameDialogResult.Ok)
        End Sub

        Private Sub HandleYes(sender As Object, e As EventArgs)
            Close(GameDialogResult.Yes)
        End Sub

        Private Sub HandleNo(sender As Object, e As EventArgs)
            Close(GameDialogResult.No)
        End Sub

        Private Sub HandleKeyDown(sender As Object, e As KeyEventArgs)
            Select Case e.Key
                Case Keys.Enter
                    Close(_defaultResult)
                    e.Handled = True
                Case Keys.Escape
                    Close(_escapeResult)
                    e.Handled = True
            End Select
        End Sub
    End Class
End Namespace
