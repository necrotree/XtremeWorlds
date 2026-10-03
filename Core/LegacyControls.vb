Imports Eto.Forms
Imports Eto.Drawing

Namespace XtremeWorlds.Client.UI
    ' Thin compatibility controls keep familiar VB6/twinBASIC property names
    ' while the underlying widgets are Eto.Forms controls.
    Public Class LegacyLabel
        Inherits Label
        Public Property Caption As String
            Get
                Return Text
            End Get
            Set(value As String)
                Text = If(value, String.Empty)
            End Set
        End Property
    End Class

    Public Class LegacyButton
        Inherits Button
        Public Property Caption As String
            Get
                Return Text
            End Get
            Set(value As String)
                Text = If(value, String.Empty)
            End Set
        End Property
    End Class

    Public Class LegacyRadioButton
        Inherits RadioButton
        Public Sub New()
            MyBase.New()
        End Sub
        Public Sub New(controller As RadioButton)
            MyBase.New(controller)
        End Sub
        Public Property Caption As String
            Get
                Return Text
            End Get
            Set(value As String)
                Text = If(value, String.Empty)
            End Set
        End Property
        Public Property Value As Boolean
            Get
                Return Me.Checked
            End Get
            Set(value As Boolean)
                Checked = value
            End Set
        End Property
    End Class

    Public Class LegacyCheckBox
        Inherits CheckBox
        Public Property Caption As String
            Get
                Return Text
            End Get
            Set(value As String)
                Text = If(value, String.Empty)
            End Set
        End Property
        Public Property Value As Integer
            Get
                Return If(Me.Checked, 1, 0)
            End Get
            Set(value As Integer)
                Checked = (value <> 0)
            End Set
        End Property
    End Class

    Public Class LegacyTextBox
        Inherits TextBox
        Public Property Locked As Boolean
            Get
                Return Me.ReadOnly
            End Get
            Set(value As Boolean)
                Me.ReadOnly = value
            End Set
        End Property
    End Class

    Public Class LegacyPasswordBox
        Inherits PasswordBox

        Public Property Locked As Boolean
            Get
                Return Me.ReadOnly
            End Get
            Set(value As Boolean)
                Me.ReadOnly = value
            End Set
        End Property
    End Class

    Public Class LegacyTextArea
        Inherits TextArea
        Public Property Locked As Boolean
            Get
                Return Me.ReadOnly
            End Get
            Set(value As Boolean)
                Me.ReadOnly = value
            End Set
        End Property
    End Class

    Public Class LegacyScrollBar
        Inherits Slider
        Public Property SmallChange As Integer = 1
        Public Property LargeChange As Integer = 1
    End Class

    Public Class LegacyComboBox
        Inherits ComboBox
        Public Property ListIndex As Integer
            Get
                Return SelectedIndex
            End Get
            Set(value As Integer)
                SelectedIndex = value
            End Set
        End Property
    End Class

    Public Class LegacyListBox
        Inherits ListBox
        Public Property ListIndex As Integer
            Get
                Return SelectedIndex
            End Get
            Set(value As Integer)
                SelectedIndex = value
            End Set
        End Property
    End Class

    Public Class LegacyPictureBox
        Inherits Panel
        Public ReadOnly Property Canvas As Drawable

        Public Sub New()
            Canvas = New Drawable()
            Content = Canvas
        End Sub
    End Class

    Public Class LegacyFrame
        Inherits GroupBox
        Public Property Caption As String
            Get
                Return Text
            End Get
            Set(value As String)
                Text = If(value, String.Empty)
            End Set
        End Property
    End Class
End Namespace
