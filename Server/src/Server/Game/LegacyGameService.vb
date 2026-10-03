Imports System.Collections.Concurrent

' Modern landing point for the remaining original modGameLogic/modHandleData behavior.
' The original packet names are all recognized here so the protocol surface is preserved.
Public NotInheritable Class LegacyGameService
    Private ReadOnly _settings As ServerSettings
    Private ReadOnly _network As MirrorTcpHost
    Private ReadOnly _db As SpacetimeRepository
    Private ReadOnly _sessions As ConcurrentDictionary(Of Integer, PlayerSession)

    Private Shared ReadOnly SupportedCommands As New HashSet(Of String)(StringComparer.OrdinalIgnoreCase) From {
        "delaccount","saymsg","emotemsg","broadcastmsg","globalmsg","adminmsg","playermsg",
        "playermove","playerdir","useitem","attack","usestatpoint","playerinforequest","warpmeto",
        "requesteditsign","editsign","savesign","requestsign","editarrow","savearrow","requesteditarrow",
        "requesteditclass","editclass","saveclass","warptome","warpto","setsprite","playersprite","getstats",
        "requestnewmap","mapdata","needmap","mapgetitem","mapdropitem","shutdown","rebootserver","innsleep",
        "maprespawn","mapreport","signnames","kickplayer","banlist","bandestroy","banplayer","unbanplayer",
        "hdserial","getgamename","getgamemaxes","getgamesite","requesteditmap","requestedititem","edititem",
        "saveitem","saveguild","requesteditnpc","editnpc","savenpc","requesteditshop","editshop","saveshop",
        "requesteditspell","editspell","savespell","setaccess","whosonline","onlinelist","setmotd","bugreport",
        "trade","traderequest","fixitem","search","warpsearch","party","joinparty","leaveparty","spells","cast",
        "forgetspell","resync","requestlocation"
    }

    Public Sub New(settings As ServerSettings, network As MirrorTcpHost, db As SpacetimeRepository, sessions As ConcurrentDictionary(Of Integer, PlayerSession))
        _settings = settings : _network = network : _db = db : _sessions = sessions
    End Sub

    Public Async Function HandleAsync(id As Integer, command As String, p As String()) As Task
        If Not SupportedCommands.Contains(command) Then
            Console.WriteLine($"[{id}] Unknown command: {command}")
            Return
        End If

        Select Case command
            Case "getgamename"
                _network.SendText(id, PacketCodec.Compose("gamename", _settings.GameName))
            Case "getgamesite"
                _network.SendText(id, PacketCodec.Compose("gamesite", _settings.Website))
            Case "hdserial"
                Dim session As PlayerSession = Nothing
                If _sessions.TryGetValue(id, session) AndAlso p.Length > 1 Then session.HardwareId = p(1)
            Case "saymsg", "emotemsg", "globalmsg", "broadcastmsg"
                If p.Length > 1 Then Broadcast(PacketCodec.Compose(command, p(1)))
            Case "requestlocation"
                Dim s As PlayerSession = Nothing
                If _sessions.TryGetValue(id, s) AndAlso s.Character IsNot Nothing Then
                    _network.SendText(id, PacketCodec.Compose("location", s.Character.Map, s.Character.X, s.Character.Y))
                End If
            Case Else
                ' The full legacy implementation remains in LegacySource/modHandleData.bas and modGameLogic.bas.
                ' This modern router deliberately keeps DB/network access asynchronous and isolated.
                Await Task.CompletedTask
        End Select
    End Function

    Public Sub Tick()
        ' World/NPC/projectile timers from the original server can be moved here incrementally.
    End Sub

    Private Sub Broadcast(packet As String)
        For Each id In _sessions.Keys
            _network.SendText(id, packet)
        Next
    End Sub
End Class
