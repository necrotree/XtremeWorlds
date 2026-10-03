Imports System.Text.Json

Public NotInheritable Class SpacetimeRepository
    Implements IDisposable

    Private ReadOnly _client As SpacetimeHttpClient

    Public Sub New(settings As ServerSettings)
        _client = New SpacetimeHttpClient(settings)
    End Sub

    Public Function PingAsync(ct As Threading.CancellationToken) As Task
        Return _client.PingAsync(ct)
    End Function

    Private Shared Function Q(value As String) As String
        Return "'" & value.Replace("'", "''") & "'"
    End Function

    Public Async Function AccountExistsAsync(login As String) As Task(Of Boolean)
        Using doc = Await _client.SqlAsync($"SELECT login FROM account WHERE login = {Q(login)} LIMIT 1")
            Return HasRows(doc)
        End Using
    End Function

    Public Async Function GetAccountAsync(login As String) As Task(Of AccountRecord)
        Using doc = Await _client.SqlAsync($"SELECT login, password_hash, password_salt, enc_key FROM account WHERE login = {Q(login)} LIMIT 1")
            Dim row = FirstRow(doc)
            If row Is Nothing Then Return Nothing
            Return New AccountRecord With {
                .Login = row.Value(0).GetString(),
                .PasswordHash = row.Value(1).GetString(),
                .PasswordSalt = row.Value(2).GetString(),
                .EncKey = row.Value(3).GetString()
            }
        End Using
    End Function

    Public Async Function CreateAccountAsync(login As String, password As String, encKey As String) As Task
        Dim p = PasswordHasher.Create(password)
        Await _client.CallReducerAsync("upsert_account", {login, p.Hash, p.Salt, encKey})
    End Function

    Public Async Function SaveCharacterAsync(login As String, slot As Integer, character As PlayerCharacter) As Task
        Dim key = $"{login.ToLowerInvariant()}:{slot}"
        Dim json = JsonSerializer.Serialize(character)
        Await _client.CallReducerAsync("upsert_character", {key, login, slot, character.Name, json})
    End Function

    Public Async Function GetCharactersAsync(login As String) As Task(Of List(Of CharacterRow))
        Dim result As New List(Of CharacterRow)()
        Using doc = Await _client.SqlAsync($"SELECT slot, name, json FROM character WHERE account_login = {Q(login)} ORDER BY slot")
            For Each row In Rows(doc)
                result.Add(New CharacterRow With {
                    .Slot = row(0).GetInt32(),
                    .Name = row(1).GetString(),
                    .Character = JsonSerializer.Deserialize(Of PlayerCharacter)(row(2).GetString())
                })
            Next
        End Using
        Return result
    End Function

    Public Async Function DeleteCharacterAsync(login As String, slot As Integer) As Task
        Dim key = $"{login.ToLowerInvariant()}:{slot}"
        Await _client.CallReducerAsync("delete_character", {key})
    End Function

    Public Async Function UpsertContentAsync(kind As String, id As Integer, name As String, value As Object, Optional revision As Integer = 0) As Task
        Dim key = $"{kind.ToLowerInvariant()}:{id}"
        Dim json = JsonSerializer.Serialize(value)
        Await _client.CallReducerAsync("upsert_content", {key, kind.ToLowerInvariant(), id, name, json, revision})
    End Function

    Public Async Function LoadContentAsync(Of T)(kind As String) As Task(Of Dictionary(Of Integer, T))
        Dim output As New Dictionary(Of Integer, T)()
        Using doc = Await _client.SqlAsync($"SELECT numeric_id, json FROM content WHERE kind = {Q(kind.ToLowerInvariant())} ORDER BY numeric_id")
            For Each row In Rows(doc)
                Dim value = JsonSerializer.Deserialize(Of T)(row(1).GetString())
                If value IsNot Nothing Then output(row(0).GetInt32()) = value
            Next
        End Using
        Return output
    End Function

    Public Async Function IsBannedAsync(ip As String, hardwareId As String) As Task(Of Boolean)
        Using doc = Await _client.SqlAsync($"SELECT ban_key FROM ban WHERE ip = {Q(ip)} OR hardware_id = {Q(hardwareId)} LIMIT 1")
            Return HasRows(doc)
        End Using
    End Function

    Public Async Function AddBanAsync(ban As BanDefinition) As Task
        Dim key = Guid.NewGuid().ToString("N")
        Await _client.CallReducerAsync("upsert_ban", {key, ban.BannedIP, ban.BannedCharacter, ban.BannedBy, ban.BannedHardwareId})
    End Function

    Private Shared Function HasRows(doc As JsonDocument) As Boolean
        Return Rows(doc).Any()
    End Function

    Private Shared Function FirstRow(doc As JsonDocument) As JsonElement?
        Return Rows(doc).Cast(Of JsonElement?).FirstOrDefault()
    End Function

    Private Shared Iterator Function Rows(doc As JsonDocument) As IEnumerable(Of JsonElement)
        If doc.RootElement.ValueKind <> JsonValueKind.Array Then Return
        For Each statement In doc.RootElement.EnumerateArray()
            Dim rowsElement As JsonElement
            If statement.TryGetProperty("rows", rowsElement) AndAlso rowsElement.ValueKind = JsonValueKind.Array Then
                For Each row In rowsElement.EnumerateArray()
                    Yield row
                Next
            End If
        Next
    End Function

    Public Sub Dispose() Implements IDisposable.Dispose
        _client.Dispose()
    End Sub
End Class

Public Class AccountRecord
    Public Property Login As String = ""
    Public Property PasswordHash As String = ""
    Public Property PasswordSalt As String = ""
    Public Property EncKey As String = ""
End Class

Public Class CharacterRow
    Public Property Slot As Integer
    Public Property Name As String = ""
    Public Property Character As PlayerCharacter
End Class
