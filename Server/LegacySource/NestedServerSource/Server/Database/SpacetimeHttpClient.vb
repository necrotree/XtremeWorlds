Imports System.Net.Http
Imports System.Net.Http.Headers
Imports System.Text
Imports System.Text.Json

Public NotInheritable Class SpacetimeHttpClient
    Implements IDisposable

    Private ReadOnly _http As HttpClient
    Private ReadOnly _baseUri As String
    Private ReadOnly _database As String

    Public Sub New(settings As ServerSettings)
        _http = New HttpClient()
        _baseUri = settings.SpacetimeUri.TrimEnd("/"c)
        _database = Uri.EscapeDataString(settings.SpacetimeDatabase)
        If Not String.IsNullOrWhiteSpace(settings.SpacetimeToken) Then
            _http.DefaultRequestHeaders.Authorization = New AuthenticationHeaderValue("Bearer", settings.SpacetimeToken)
        End If
    End Sub

    Public Async Function PingAsync(ct As Threading.CancellationToken) As Task
        Using response = Await _http.GetAsync(_baseUri & "/v1/ping", ct)
            response.EnsureSuccessStatusCode()
        End Using
    End Function

    Public Async Function CallReducerAsync(name As String, args As Object(), Optional ct As Threading.CancellationToken = Nothing) As Task
        Dim url = $"{_baseUri}/v1/database/{_database}/call/{Uri.EscapeDataString(name)}"
        Dim body = JsonSerializer.Serialize(args)
        Using content = New StringContent(body, Encoding.UTF8, "application/json")
            Using response = Await _http.PostAsync(url, content, ct)
                Dim result = Await response.Content.ReadAsStringAsync(ct)
                If Not response.IsSuccessStatusCode Then Throw New InvalidOperationException($"SpacetimeDB reducer {name} failed ({CInt(response.StatusCode)}): {result}")
            End Using
        End Using
    End Function

    Public Async Function SqlAsync(sql As String, Optional ct As Threading.CancellationToken = Nothing) As Task(Of JsonDocument)
        Dim url = $"{_baseUri}/v1/database/{_database}/sql"
        Using content = New StringContent(sql, Encoding.UTF8, "text/plain")
            Using response = Await _http.PostAsync(url, content, ct)
                Dim result = Await response.Content.ReadAsStringAsync(ct)
                If Not response.IsSuccessStatusCode Then Throw New InvalidOperationException($"SpacetimeDB SQL failed ({CInt(response.StatusCode)}): {result}")
                Return JsonDocument.Parse(result)
            End Using
        End Using
    End Function

    Public Sub Dispose() Implements IDisposable.Dispose
        _http.Dispose()
    End Sub
End Class
