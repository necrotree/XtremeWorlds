Imports System
Imports System.Collections.Generic
Imports System.Diagnostics
Imports Eto.Forms

Namespace XtremeWorlds.Client.Logic
    Public Enum MenuState
        NewAccount
        Login
        NewCharacter
        AddCharacter
        DeleteCharacter
        UseCharacter
    End Enum

    Public NotInheritable Class GameClassInfo
        Public Property Name As String = String.Empty
        Public Property STR As Integer
        Public Property DEF As Integer
        Public Property Speed As Integer
        Public Property MAGI As Integer
    End Class

    Public NotInheritable Class CharacterSlotInfo
        Public Property Name As String = String.Empty
        Public Property Sprite As Integer
    End Class

    Public Interface IGameClientRuntime
        Property Website As String
        Property SaveLogin As Boolean
        Property Username As String
        Property Password As String
        Property CurrentClass As Integer
        Property CurrentSex As Integer
        ReadOnly Property Classes As IReadOnlyList(Of GameClassInfo)

        Event ActionRequested As EventHandler(Of GameClientActionEventArgs)

        Sub InitializeMenu()
        Sub SaveLoginCredentials(username As String, password As String)
        Sub MenuState(state As MenuState, Optional text As String = Nothing, Optional selectedIndex As Integer = -1)
        Sub Disconnect()
        Sub RefreshWebsite()
        Sub RefreshNewCharacterPreview(classIndex As Integer, sex As Integer)
        Sub OpenWebsite()
        Sub GameDestroy()
        Sub UpdateServerIp(ipAddress As String)
        Sub MainGameAction(actionName As String, ParamArray arguments() As Object)
    End Interface

    Public NotInheritable Class GameClientActionEventArgs
        Inherits EventArgs

        Public Sub New(name As String, ParamArray arguments() As Object)
            Me.Name = name
            Me.Arguments = If(arguments, Array.Empty(Of Object)())
        End Sub

        Public ReadOnly Property Name As String
        Public ReadOnly Property Arguments As Object()
    End Class

    ''' <summary>
    ''' Shared controller used by the converted Eto forms.  It ports the form-level
    ''' behavior from twinBASIC and provides one event boundary for the remaining
    ''' networking/rendering engine while those modules are migrated.
    ''' </summary>
    Public NotInheritable Class GameClientRuntime
        Implements IGameClientRuntime

        Private Shared _current As IGameClientRuntime = New GameClientRuntime()
        Private ReadOnly _classes As List(Of GameClassInfo)

        Public Shared Property Current As IGameClientRuntime
            Get
                Return _current
            End Get
            Set(value As IGameClientRuntime)
                _current = If(value, New GameClientRuntime())
            End Set
        End Property

        Public Sub New()
            _classes = New List(Of GameClassInfo) From {
                New GameClassInfo With {.Name = "Fighter"},
                New GameClassInfo With {.Name = "Wizard"},
                New GameClassInfo With {.Name = "Celestial"},
                New GameClassInfo With {.Name = "Guardian"},
                New GameClassInfo With {.Name = "Assassin"}
            }
            Website = "https://www.xtremeworlds.com"
            CurrentClass = 0
            CurrentSex = 1
        End Sub

        Public Property Website As String Implements IGameClientRuntime.Website
        Public Property SaveLogin As Boolean Implements IGameClientRuntime.SaveLogin
        Public Property Username As String Implements IGameClientRuntime.Username
        Public Property Password As String Implements IGameClientRuntime.Password
        Public Property CurrentClass As Integer Implements IGameClientRuntime.CurrentClass
        Public Property CurrentSex As Integer Implements IGameClientRuntime.CurrentSex
        Public ReadOnly Property Classes As IReadOnlyList(Of GameClassInfo) Implements IGameClientRuntime.Classes
            Get
                Return _classes
            End Get
        End Property

        Public Event ActionRequested As EventHandler(Of GameClientActionEventArgs) Implements IGameClientRuntime.ActionRequested

        Public Sub InitializeMenu() Implements IGameClientRuntime.InitializeMenu
            Request("InitializeMenu")
        End Sub

        Public Sub SaveLoginCredentials(username As String, password As String) Implements IGameClientRuntime.SaveLoginCredentials
            Username = If(username, String.Empty).Trim()
            Password = If(password, String.Empty)
            Request("SaveLoginCredentials", Username, Password, SaveLogin)
        End Sub

        Public Sub MenuState(state As MenuState, Optional text As String = Nothing, Optional selectedIndex As Integer = -1) Implements IGameClientRuntime.MenuState
            Request("MenuState", state, text, selectedIndex, CurrentClass, CurrentSex)
        End Sub

        Public Sub Disconnect() Implements IGameClientRuntime.Disconnect
            Request("TcpDestroy")
        End Sub

        Public Sub RefreshWebsite() Implements IGameClientRuntime.RefreshWebsite
            Request("GetGameSite")
        End Sub

        Public Sub RefreshNewCharacterPreview(classIndex As Integer, sex As Integer) Implements IGameClientRuntime.RefreshNewCharacterPreview
            Request("NewCharBltSprite", classIndex, sex)
        End Sub

        Public Sub OpenWebsite() Implements IGameClientRuntime.OpenWebsite
            Dim address = If(Website, String.Empty).Trim()
            If address.Length = 0 Then Return
            If address.StartsWith("http://", StringComparison.OrdinalIgnoreCase) Then
                address = address.Substring(7)
            End If
            If address.StartsWith("//", StringComparison.Ordinal) Then
                address = address.Substring(2)
            End If
            If Not address.StartsWith("https://", StringComparison.OrdinalIgnoreCase) Then
                address = "https://" & address
            End If

            Try
                Process.Start(New ProcessStartInfo(address) With {.UseShellExecute = True})
            Catch
                Request("OpenWebsite", address)
            End Try
        End Sub

        Public Sub GameDestroy() Implements IGameClientRuntime.GameDestroy
            Request("GameDestroy")
            If Application.Instance IsNot Nothing Then Application.Instance.Quit()
        End Sub

        Public Sub UpdateServerIp(ipAddress As String) Implements IGameClientRuntime.UpdateServerIp
            Request("UpdateServerIp", ipAddress)
        End Sub

        Public Sub MainGameAction(actionName As String, ParamArray arguments() As Object) Implements IGameClientRuntime.MainGameAction
            Request(actionName, arguments)
        End Sub

        Private Sub Request(name As String, ParamArray arguments() As Object)
            RaiseEvent ActionRequested(Me, New GameClientActionEventArgs(name, arguments))
        End Sub
    End Class
End Namespace
