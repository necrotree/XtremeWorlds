Imports System.Collections.Concurrent
Imports System.Globalization

Public NotInheritable Class PacketRouter
    Private ReadOnly _settings As ServerSettings
    Private ReadOnly _network As MirrorTcpHost
    Private ReadOnly _db As SpacetimeRepository
    Private ReadOnly _sessions As ConcurrentDictionary(Of Integer, PlayerSession)
    Private ReadOnly _legacy As LegacyGameService

    Public Sub New(settings As ServerSettings, network As MirrorTcpHost, db As SpacetimeRepository, sessions As ConcurrentDictionary(Of Integer, PlayerSession))
        _settings = settings
        _network = network
        _db = db
        _sessions = sessions
        _legacy = New LegacyGameService(settings, network, db, sessions)
    End Sub

    Public Async Function HandleAsync(connectionId As Integer, data As String) As Task
        Dim p = PacketCodec.SplitPacket(data)
        If p.Length = 0 Then Return
        Dim command = p(0).Trim().ToLowerInvariant()
        Try
            Select Case command
                Case "getclasses" : Await SendClassesAsync(connectionId)
                Case "newaccount" : Await NewAccountAsync(connectionId, p)
                Case "login" : Await LoginAsync(connectionId, p)
                Case "addchar" : Await AddCharacterAsync(connectionId, p)
                Case "delchar" : Await DeleteCharacterAsync(connectionId, p)
                Case "usechar" : Await UseCharacterAsync(connectionId, p)
                Case Else : Await _legacy.HandleAsync(connectionId, command, p)
            End Select
        Catch ex As Exception
            Console.Error.WriteLine($"[{connectionId}] {command}: {ex.Message}")
            _network.SendText(connectionId, PacketCodec.Compose("alertmsg", "Server error handling packet."))
        End Try
    End Function

    Public Sub Tick()
        _legacy.Tick()
    End Sub

    Private Async Function NewAccountAsync(id As Integer, p As String()) As Task
        If p.Length < 3 Then Return
        Dim login = p(1).Trim()
        Dim password = p(2)
        If Not ValidName(login) OrElse password.Length < 3 Then
            _network.SendText(id, PacketCodec.Compose("alertmsg", "Your name and password must be at least three characters in length."))
            Return
        End If
        If Await _db.AccountExistsAsync(login) Then
            _network.SendText(id, PacketCodec.Compose("alertmsg", "Sorry, that account name is already taken!"))
            Return
        End If
        Await _db.CreateAccountAsync(login, password, "")
        _network.SendText(id, PacketCodec.Compose("alertmsg", "Your account has been created!"))
    End Function

    Private Async Function LoginAsync(id As Integer, p As String()) As Task
        If p.Length < 3 Then Return
        Dim session As PlayerSession = Nothing
        If Not _sessions.TryGetValue(id, session) Then Return
        Dim login = p(1).Trim()
        Dim password = p(2)
        Dim account = Await _db.GetAccountAsync(login)
        If account Is Nothing OrElse Not PasswordHasher.Verify(password, account.PasswordHash, account.PasswordSalt) Then
            _network.SendText(id, PacketCodec.Compose("alertmsg", "Incorrect account name or password."))
            Return
        End If
        If Await _db.IsBannedAsync(session.IpAddress, session.HardwareId) Then
            _network.SendText(id, PacketCodec.Compose("alertmsg", $"You have been banned from {_settings.GameName}."))
            Return
        End If
        session.Login = account.Login
        session.IsLoggedIn = True
        Await SendCharactersAsync(id, account.Login)
    End Function

    Private Async Function AddCharacterAsync(id As Integer, p As String()) As Task
        If p.Length < 5 Then Return
        Dim session As PlayerSession = Nothing
        If Not _sessions.TryGetValue(id, session) OrElse Not session.IsLoggedIn Then Return
        Dim name = p(1).Trim()
        Dim sex = Byte.Parse(p(2), CultureInfo.InvariantCulture)
        Dim classId = Byte.Parse(p(3), CultureInfo.InvariantCulture)
        Dim slot = Integer.Parse(p(4), CultureInfo.InvariantCulture)
        If slot < 1 OrElse slot > GameLimits.MaxCharacters OrElse Not ValidName(name) Then
            _network.SendText(id, PacketCodec.Compose("alertmsg", "Invalid character."))
            Return
        End If
        Dim character As New PlayerCharacter With {.Name = name, .Sex = sex, .ClassId = classId, .Level = 1}
        Await _db.SaveCharacterAsync(session.Login, slot, character)
        Await SendCharactersAsync(id, session.Login)
    End Function

    Private Async Function DeleteCharacterAsync(id As Integer, p As String()) As Task
        If p.Length < 2 Then Return
        Dim session As PlayerSession = Nothing
        If Not _sessions.TryGetValue(id, session) OrElse Not session.IsLoggedIn Then Return
        Dim slot = Integer.Parse(p(1), CultureInfo.InvariantCulture)
        Await _db.DeleteCharacterAsync(session.Login, slot)
        Await SendCharactersAsync(id, session.Login)
    End Function

    Private Async Function UseCharacterAsync(id As Integer, p As String()) As Task
        If p.Length < 2 Then Return
        Dim session As PlayerSession = Nothing
        If Not _sessions.TryGetValue(id, session) OrElse Not session.IsLoggedIn Then Return
        Dim slot = Integer.Parse(p(1), CultureInfo.InvariantCulture)
        Dim chars = Await _db.GetCharactersAsync(session.Login)
        Dim selected = chars.FirstOrDefault(Function(c) c.Slot = slot)
        If selected Is Nothing OrElse selected.Character Is Nothing Then Return
        session.CharacterSlot = slot
        session.Character = selected.Character
        session.IsPlaying = True
        _network.SendText(id, PacketCodec.Compose("ingame"))
        _network.SendText(id, PacketCodec.Compose("playerdata", selected.Character.Name, selected.Character.Level, selected.Character.Map, selected.Character.X, selected.Character.Y, selected.Character.Direction))
    End Function

    Private Async Function SendCharactersAsync(id As Integer, login As String) As Task
        Dim chars = Await _db.GetCharactersAsync(login)
        Dim args As New List(Of Object)()
        For slot = 1 To GameLimits.MaxCharacters
            Dim c = chars.FirstOrDefault(Function(x) x.Slot = slot)
            args.Add(If(c?.Name, ""))
        Next
        _network.SendText(id, PacketCodec.Compose("chars", args.ToArray()))
    End Function

    Private Async Function SendClassesAsync(id As Integer) As Task
        Dim classes = Await _db.LoadContentAsync(Of ClassDefinition)("class")
        For Each kv In classes.OrderBy(Function(x) x.Key)
            Dim c = kv.Value
            _network.SendText(id, PacketCodec.Compose("newcharclasses", kv.Key, c.Name, c.MaleSprite, c.FemaleSprite, c.Strength, c.Defense, c.Speed, c.Magic))
        Next
    End Function

    Private Shared Function ValidName(value As String) As Boolean
        If value.Length < 3 OrElse value.Length > GameLimits.NameLength Then Return False
        Return value.All(Function(ch) Char.IsLetterOrDigit(ch) OrElse ch = "_"c OrElse ch = " "c)
    End Function
End Class
