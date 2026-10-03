Imports System.IO
Imports System.Text.Json

Public NotInheritable Class ServerSettings
    Public Property GameName As String = "XtremeWorlds"
    Public Property Port As Integer = 7234
    Public Property MaxPlayers As Integer = 100
    Public Property MaxMessageSize As Integer = 1024 * 1024
    Public Property TcpNoDelay As Boolean = True
    Public Property TickRate As Integer = 60
    Public Property Website As String = "https://example.com"
    Public Property SpacetimeUri As String = "http://127.0.0.1:3000"
    Public Property SpacetimeDatabase As String = "xtremeworlds"
    Public Property SpacetimeToken As String = ""

    Public Shared Function Load(path As String) As ServerSettings
        If Not File.Exists(path) Then Return New ServerSettings()
        Dim json = File.ReadAllText(path)
        Return JsonSerializer.Deserialize(Of ServerSettings)(json,
            New JsonSerializerOptions With {.PropertyNameCaseInsensitive = True}) Or New ServerSettings()
    End Function
End Class
