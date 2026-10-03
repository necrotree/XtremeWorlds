Public Class PlayerSession
    Public Property ConnectionId As Integer
    Public Property IpAddress As String = ""
    Public Property Login As String = ""
    Public Property HardwareId As String = ""
    Public Property CharacterSlot As Integer
    Public Property Character As PlayerCharacter
    Public Property IsLoggedIn As Boolean
    Public Property IsPlaying As Boolean
End Class
