Attribute VB_Name = "modText"
Option Explicit
Private EmoteSprite() As Long
Private EmoteMap() As Long
Private EmoteStarted() As Long
Private EmoteCapacity As Long
Private EmoteBounds() As RECT
Private EmoteSurface(1 To 30) As clsDX11Surface

Private Const SPRITE_DRAW_OFFSET_X As Long = 8
Private Const SPRITE_DRAW_OFFSET_Y As Long = 16
Private Const NAME_GAP As Long = 2

Public Sub SetFont(ByVal Font As String, ByVal Size As Byte)
    GameFont = CreateFont(Size, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Font)
End Sub

Public Sub DrawText(ByVal hDC As Long, ByVal X, ByVal Y, ByVal Text As String, Color As Long)
    Call SelectObject(hDC, GameFont)
    Call SetBkMode(hDC, vbTransparent)
    Call SetTextColor(hDC, RGB(50, 50, 50))
    Call TextOut(hDC, X - 1, Y - 1, Text, Len(Text))
    Call TextOut(hDC, X + 1, Y - 1, Text, Len(Text))
    Call TextOut(hDC, X - 1, Y + 1, Text, Len(Text))
    Call TextOut(hDC, X + 1, Y + 1, Text, Len(Text))
    Call SetTextColor(hDC, Color)
    Call TextOut(hDC, X, Y, Text, Len(Text))
End Sub

Public Function getSize(ByVal DC As Long, ByVal Text As String) As TextSize
    Dim lngReturn As Long
    Dim typSize As TextSize

    lngReturn = GetTextExtentPoint32(DC, Text, Len(Text), typSize)
    getSize = typSize
End Function

Private Sub GetPlayerSpriteDrawPosition(ByVal index As Long, ByRef SpriteX As Long, ByRef SpriteY As Long)
    Dim X As Long
    Dim Y As Long
    Dim SpriteWidth As Long
    Dim SpriteHeight As Long

    SpriteWidth = CLng(GameData.SpriteWidth) + 16
    SpriteHeight = CLng(PIC_Y) * 2

    X = CLng(GetPlayerPixelX(index))
    Y = CLng(GetPlayerPixelY(index))

    If GameData.SpriteWidth > 48 Then
        X = X - (CLng(GameData.SpriteWidth) \ 4)
    End If

    If X < 0 Then X = 0
    If Y < 0 Then Y = 0

    If X + SpriteWidth > CLng(DD_MiddleBuffer.Width) Then
        X = CLng(DD_MiddleBuffer.Width) - SpriteWidth
    End If

    If Y + SpriteHeight > CLng(DD_MiddleBuffer.Height) Then
        Y = CLng(DD_MiddleBuffer.Height) - SpriteHeight
    End If

    SpriteX = X - SPRITE_DRAW_OFFSET_X
    SpriteY = Y - SPRITE_DRAW_OFFSET_Y
End Sub

Private Sub GetNPCSpriteDrawPosition(ByVal index As Long, ByRef SpriteX As Long, ByRef SpriteY As Long)
    Dim X As Long
    Dim Y As Long
    Dim SpriteWidth As Long
    Dim SpriteHeight As Long

    SpriteWidth = CLng(GameData.SpriteWidth) + 16
    SpriteHeight = CLng(PIC_Y) * 2

    X = CLng(MapNpc(index).X) * CLng(PIC_X)
    X = X + CLng(MapNpc(index).XOffset)

    Y = CLng(MapNpc(index).Y) * CLng(PIC_Y)
    Y = Y + CLng(MapNpc(index).YOffset)

    If GameData.SpriteWidth > 48 Then
        X = X - (CLng(GameData.SpriteWidth) \ 4)
    End If

    If X < 0 Then X = 0
    If Y < 0 Then Y = 0

    If X + SpriteWidth > CLng(DD_MiddleBuffer.Width) Then
        X = CLng(DD_MiddleBuffer.Width) - SpriteWidth
    End If

    If Y + SpriteHeight > CLng(DD_MiddleBuffer.Height) Then
        Y = CLng(DD_MiddleBuffer.Height) - SpriteHeight
    End If

    If X < 0 Then X = 0
    If Y < 0 Then Y = 0

    SpriteX = X - SPRITE_DRAW_OFFSET_X
    SpriteY = Y - SPRITE_DRAW_OFFSET_Y
End Sub

Sub DrawPlayerName(ByVal index As Long)
    Dim TextX As Long
    Dim TextY As Long
    Dim Color As Long
    Dim SpriteX As Long
    Dim SpriteY As Long
    Dim SpriteWidth As Long
    Dim NameText As String
    Dim NameSize As TextSize

    NameText = GetPlayerName(index)
    NameSize = getSize(TexthDC, NameText)

    If GetPlayerPK(index) = NO Then
        Select Case GetPlayerAccess(index)
            Case 0
                Color = QBColor(DarkGrey)
            Case 1
                Color = QBColor(Yellow)
            Case 2
                Color = QBColor(BrightGreen)
            Case 3
                Color = QBColor(BrightBlue)
            Case 4
                Color = QBColor(BrightRed)
            Case 5
                Color = QBColor(Black)
            Case 6
                Color = QBColor(White)
            Case 7
                Color = QBColor(Blue)
            Case 8
                Color = QBColor(Green)
            Case 9
                Color = QBColor(BrightCyan)
            Case Else
                Color = QBColor(White)
        End Select
    Else
        Color = QBColor(BrightRed)
    End If

    SpriteWidth = CLng(GameData.SpriteWidth) + 16
    GetPlayerSpriteDrawPosition index, SpriteX, SpriteY

    TextX = SpriteX + (SpriteWidth \ 2) - (CLng(NameSize.Width) \ 2)
    TextY = SpriteY - CLng(NameSize.Height) - NAME_GAP

    Call DrawText(TexthDC, TextX, TextY, NameText, Color)
End Sub

Sub DrawPlayerGuildName(ByVal index As Long)
    Dim TextX As Long
    Dim TextY As Long
    Dim SpriteX As Long
    Dim SpriteY As Long
    Dim SpriteWidth As Long
    Dim GuildText As String
    Dim PlayerText As String
    Dim GuildSize As TextSize
    Dim PlayerSize As TextSize

    If Player(index).Guild = 0 Then Exit Sub

    GuildText = Trim$(Guild(Player(index).Guild).Abbreviation)
    PlayerText = GetPlayerName(index)

    GuildSize = getSize(TexthDC, GuildText)
    PlayerSize = getSize(TexthDC, PlayerText)

    SpriteWidth = CLng(GameData.SpriteWidth) + 16
    GetPlayerSpriteDrawPosition index, SpriteX, SpriteY

    TextX = SpriteX + (SpriteWidth \ 2) - (CLng(GuildSize.Width) \ 2)
    TextY = SpriteY _
          - CLng(PlayerSize.Height) _
          - CLng(GuildSize.Height) _
          - (NAME_GAP * 2)

    Call DrawText(TexthDC, TextX, TextY, GuildText, QBColor(White))
End Sub

Sub DrawMapNPCName(ByVal index As Long)
    Dim TextX As Long
    Dim TextY As Long
    Dim SpriteX As Long
    Dim SpriteY As Long
    Dim SpriteWidth As Long
    Dim NPCName As String
    Dim NPCNameSize As TextSize

    If MapNpc(index).Num <= 0 Then Exit Sub

    NPCName = Trim$(Npc(MapNpc(index).Num).name)
    NPCNameSize = getSize(TexthDC, NPCName)

    SpriteWidth = CLng(GameData.SpriteWidth) + 16
    GetNPCSpriteDrawPosition index, SpriteX, SpriteY

    TextX = SpriteX + (SpriteWidth \ 2) - (CLng(NPCNameSize.Width) \ 2)
    TextY = SpriteY - CLng(NPCNameSize.Height) - NAME_GAP

    Call DrawText(TexthDC, TextX, TextY, NPCName, QBColor(Brown))
End Sub

Public Sub ReceivePlayerEmote(ByRef parts() As String)
    Dim index As Long, mapNum As Long, sprite As Long
    If Not OverlayInteger(parts(1), MAX_PLAYERS, index) Then Exit Sub
    If Not OverlayInteger(parts(2), 32767, mapNum) Then Exit Sub
    If Not OverlayInteger(parts(3), 30, sprite) Then Exit Sub
    If index < 1 Or sprite < 1 Or MyIndex < 1 Then Exit Sub
    If mapNum <> GetPlayerMap(MyIndex) Then Exit Sub
    If EmoteCapacity <> MAX_PLAYERS Then
        ReDim EmoteSprite(1 To MAX_PLAYERS)
        ReDim EmoteMap(1 To MAX_PLAYERS)
        ReDim EmoteStarted(1 To MAX_PLAYERS)
        ReDim EmoteBounds(1 To MAX_PLAYERS)
        EmoteCapacity = MAX_PLAYERS
    End If
    EmoteSprite(index) = sprite
    EmoteMap(index) = mapNum
    EmoteStarted(index) = GetTickCount
End Sub

Public Sub ClearPlayerEmote(ByVal index As Long)
    If index < 1 Or index > EmoteCapacity Then Exit Sub
    EmoteSprite(index) = 0
End Sub

Public Sub DestroyPlayerEmotes()
    Dim sprite As Long
    For sprite = 1 To 30
        Set EmoteSurface(sprite) = Nothing
    Next sprite
    Erase EmoteSprite: Erase EmoteMap: Erase EmoteStarted: Erase EmoteBounds
    EmoteCapacity = 0
End Sub

Public Sub DrawPlayerEmote(ByVal index As Long)
    Dim elapsed As Double, sprite As Long, X As Long, Y As Long
    Dim nameSize As TextSize, guildSize As TextSize, source As RECT, destination As RECT
    If index < 1 Or index > EmoteCapacity Then Exit Sub
    sprite = EmoteSprite(index)
    If sprite = 0 Then Exit Sub
    elapsed = CDbl(GetTickCount) - CDbl(EmoteStarted(index))
    If elapsed < 0 Then elapsed = elapsed + 4294967296#
    If elapsed >= 3000 Or EmoteMap(index) <> GetPlayerMap(index) Then
        EmoteSprite(index) = 0
        Exit Sub
    End If
    GetPlayerSpriteDrawPosition index, X, Y
    nameSize = getSize(TexthDC, GetPlayerName(index))
    Y = Y - CLng(nameSize.Height) - NAME_GAP
    If Player(index).Guild > 0 And Player(index).Guild <= MAX_GUILDS Then
        guildSize = getSize(TexthDC, Trim$(Guild(Player(index).Guild).Abbreviation))
        Y = Y - CLng(guildSize.Height) - NAME_GAP
    End If
    destination.Left = X + (CLng(GameData.SpriteWidth) + 16) \ 2 - 16
    destination.Top = Y - 34
    destination.Right = destination.Left + 32
    destination.Bottom = destination.Top + 32
    EmoteBounds(index) = destination
End Sub
' Only called after the text device context has been released.
Public Sub BltPlayerEmotes()
    Dim index As Long
    For index = 1 To EmoteCapacity
        If EmoteSprite(index) > 0 Then
            If IsPlaying(index) And EmoteMap(index) = GetPlayerMap(MyIndex) Then BltPreparedEmote index
        End If
    Next index
End Sub

Private Sub BltPreparedEmote(ByVal index As Long)
    Dim sprite As Long, source As RECT
    On Error GoTo MissingImage
    sprite = EmoteSprite(index)
    If EmoteBounds(index).Right = 0 Then Exit Sub
    If EmoteSurface(sprite) Is Nothing Then
        Set EmoteSurface(sprite) = New clsDX11Surface
        EmoteSurface(sprite).LoadFromFile App.Path & "\Gfx\emoticons\" & sprite & ".png"
        EmoteSurface(sprite).UseAlpha = True
    End If
    source.Right = EmoteSurface(sprite).Width
    source.Bottom = EmoteSurface(sprite).Height
    DD_BackBuffer.Blt EmoteBounds(index), EmoteSurface(sprite), source, True
    Exit Sub
MissingImage:
    EmoteSprite(index) = 0
    Set EmoteSurface(sprite) = Nothing
End Sub