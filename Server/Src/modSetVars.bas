Attribute VB_Name = "modSetVars"
Sub SetServerName(ByVal Name As String)
    GAME_NAME = Trim$(Name)
End Sub

Sub SetServerPort(ByVal Port As Long)
    GAME_PORT = Port
End Sub

Sub SetMaxPlayers(ByVal Players As Integer)
    MAX_PLAYERS = Val(Players)
End Sub

Sub SetMaxMaps(ByVal Maps As Integer)
    MAX_MAPS_SET = Val(Maps)
End Sub

Sub SetMaxItems(ByVal Items As Integer)
    MAX_ITEMS = Val(Items)
End Sub

Sub SetMaxShops(ByVal Shops As Integer)
    MAX_SHOPS = Val(Shops)
End Sub

Sub SetMaxSpells(ByVal Spells As Integer)
    MAX_SPELLS = Val(Spells)
End Sub

Sub SetMaxSigns(ByVal Signs As Integer)
    MAX_SIGNS = Val(Signs)
End Sub

Sub SetMaxNPCs(ByVal NPCs As Integer)
    MAX_NPCS = Val(NPCs)
End Sub

Sub SetMaxGuilds(ByVal Guilds As Integer)
    MAX_GUILDS = Val(Guilds)
End Sub

Sub SetMaxGuildMembers(ByVal Members As Integer)
    MAX_GUILD_MEMBERS = Val(Members)
End Sub

Sub SetMaxQuests(ByVal Quests As Integer)
    MAX_QUESTS = Val(Quests)
End Sub

Sub SetMaxQuestPlayers(ByVal Players As Integer)
    MAX_QUEST_PLAYERS = Val(Players)
End Sub

Sub SetWebsite(ByVal Site As String)
    GAME_WEBSITE = Trim$(Site)
End Sub

Sub SetStartPosition(ByVal Map As Integer, ByVal X As Byte, ByVal y As Byte)
    START_MAP = Val(Map)
    START_X = Val(X)
    START_Y = Val(y)
End Sub

Sub InitTray(ByVal Name As String)
    nid.cbSize = Len(nid)
    nid.hWnd = frmServer.hWnd
    nid.uId = vbNull
    nid.uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
    nid.uCallBackMessage = WM_MOUSEMOVE
    nid.hIcon = frmServer.Icon
    nid.szTip = GAME_NAME & " Server" & vbNullChar
    ' Add to the sys tray
    Call Shell_NotifyIcon(NIM_ADD, nid)
End Sub
