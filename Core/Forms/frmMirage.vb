Imports XtremeWorlds.Client.Logic

Namespace XtremeWorlds.Client.Forms
    ''' <summary>
    ''' Compatibility name for the original twinBASIC frmMirage form.
    ''' The twinBASIC source declares the class as frmMainGame; both names now
    ''' resolve to the same Eto game window and use the XtremeWorlds icon.
    ''' </summary>
    Public Class frmMirage
        Inherits frmMainGame

        Public Sub New(Optional client As IGameClientRuntime = Nothing)
            MyBase.New(client)
        End Sub
    End Class
End Namespace
