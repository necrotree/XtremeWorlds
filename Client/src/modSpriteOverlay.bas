Attribute VB_Name = "modSpriteOverlays"
Option Explicit

Private BubbleSurface As clsDX11Surface
Private BarsSurface As clsDX11Surface
Private QuestSurface As clsDX11Surface
Private QuestMarkerMap(1 To MAX_MAP_NPCS) As Long
Private QuestMarkerNpc(1 To MAX_MAP_NPCS) As Long
Private QuestMarkerStatus(1 To MAX_MAP_NPCS) As Long
Private TargetSurface As clsDX11Surface
Private TargetMarkerVisible As Boolean
Private TargetMarkerMap As Long
Private Type TargetCursorPoint
    X As Long
    Y As Long
End Type
Private Declare Function TargetGetCursorPos Lib "user32" Alias "GetCursorPos" (ByRef point As TargetCursorPoint) As Long
Private Declare Function TargetScreenToClient Lib "user32" Alias "ScreenToClient" (ByVal hwnd As Long, ByRef point As TargetCursorPoint) As Long
Private Declare Function TargetGetClientRect Lib "user32" Alias "GetClientRect" (ByVal hwnd As Long, ByRef bounds As RECT) As Long
Private Const TARGET_FRAME_WIDTH As Long = 59
Private Const TARGET_FRAME_HEIGHT As Long = 64
Public TargetType As Long
Public TargetNum As Long
Private Const BAR_WIDTH As Long = 56
Private Const BAR_HEIGHT As Long = 7
Private Const BARS_HEIGHT As Long = 15
Private Const BUBBLE_WIDTH As Long = 160
Private Const BUBBLE_HEIGHT As Long = 48
Public Const BUBBLE_TEXT_LIMIT As Long = 240

Public Sub InitSpriteOverlays()
    Set BubbleSurface = New clsDX11Surface
    BubbleSurface.LoadFromFile App.Path & GFX_PATH & "misc\chatbubble.png"
    BubbleSurface.UseAlpha = True
    Set BarsSurface = New clsDX11Surface
    BarsSurface.LoadFromFile App.Path & GFX_PATH & "misc\bars.png"
    BarsSurface.UseAlpha = True
    Set QuestSurface = New clsDX11Surface
    QuestSurface.LoadFromFile App.Path & GFX_PATH & "misc\questblips.png"
    QuestSurface.UseAlpha = True
    If QuestSurface.Width <> 96 Or QuestSurface.Height <> 128 Then Err.Raise 5, "Sprite overlays", "questblips.png must be 96 x 128."
    Set TargetSurface = New clsDX11Surface
    TargetSurface.LoadFromFile App.Path & GFX_PATH & "misc\target.png"
    TargetSurface.ColorKey = RGB(255, 0, 255)
    TargetSurface.UseAlpha = True
    If BubbleSurface.Width <> 128 Or BubbleSurface.Height <> 64 Then Err.Raise 5, "Sprite overlays", "chatbubble.png must be 128 x 64."
    If BarsSurface.Width <> BAR_WIDTH Or BarsSurface.Height <> BAR_HEIGHT * 4 Then Err.Raise 5, "Sprite overlays", "bars.png must be 56 x 28."
    If TargetSurface.Width <> TARGET_FRAME_WIDTH * 2 Or TargetSurface.Height <> TARGET_FRAME_HEIGHT Then Err.Raise 5, "Sprite overlays", "target.png must be 118 x 64 (active left, preview right)."
End Sub

Public Sub DestroySpriteOverlays()
    Set BubbleSurface = Nothing
    Set BarsSurface = Nothing
    Set QuestSurface = Nothing
    ClearQuestMarkers
    Set TargetSurface = Nothing
    TargetMarkerVisible = False
End Sub

Public Sub SetTargetMarker(ByVal tileX As Long, ByVal tileY As Long)
    If tileX < 0 Or tileX > MAX_MAPX Or tileY < 0 Or tileY > MAX_MAPY Then Exit Sub
    TargetMarkerMap = GetPlayerMap(MyIndex)
    TargetMarkerVisible = True
End Sub

Public Sub ClearTargetMarker()
    TargetMarkerVisible = False
End Sub

' Use the actual cursor position so previews disappear when leaving the map.
Private Sub DrawTargetMarker()
    Dim point As TargetCursorPoint, bounds As RECT, index As Long
    If TargetSurface Is Nothing Then Exit Sub
    If TargetMarkerVisible Then
        If TargetMarkerMap <> GetPlayerMap(MyIndex) Then ClearTargetMarker
    End If
    If TargetMarkerVisible Then
        If Not DrawEntityTarget(TargetType, TargetNum, False) Then ClearTargetMarker
    End If
    If TargetGetCursorPos(point) = 0 Then Exit Sub
    If TargetScreenToClient(frmMainGame.picScreen.hwnd, point) = 0 Then Exit Sub
    If TargetGetClientRect(frmMainGame.picScreen.hwnd, bounds) = 0 Then Exit Sub
    If bounds.Right <= 0 Or bounds.Bottom <= 0 Then Exit Sub
    If point.X < 0 Or point.Y < 0 Or point.X >= bounds.Right Or point.Y >= bounds.Bottom Then Exit Sub
    If InEditor Then Exit Sub
    ' DX11 stretches the map buffer to the client rectangle, independently of ScaleMode.
    point.X = CLng(CDbl(point.X) * DD_BackBuffer.Width / bounds.Right)
    point.Y = CLng(CDbl(point.Y) * DD_BackBuffer.Height / bounds.Bottom)
    For index = 1 To HighIndex
        If IsPlaying(index) And Player(index).Map = GetPlayerMap(MyIndex) Then
            If TargetSpriteContains(1, index, point.X, point.Y) Then
                If Not (TargetMarkerVisible And TargetType = 1 And TargetNum = index) Then
                    Call DrawEntityTarget(1, index, True)
                End If
                Exit Sub
            End If
        End If
    Next index
    For index = 1 To MAX_MAP_NPCS
        If MapNpc(index).Num > 0 And TargetSpriteContains(2, index, point.X, point.Y) Then
            If Not (TargetMarkerVisible And TargetType = 2 And TargetNum = index) Then
                Call DrawEntityTarget(2, index, True)
            End If
            Exit Sub
        End If
    Next index
End Sub

' Match the sprite renderer, including movement offsets and edge clamping.
Private Function TargetSpritePosition(ByVal kind As Long, ByVal index As Long, ByRef X As Long, ByRef Y As Long) As Boolean
    Dim spriteWidth As Long, spriteHeight As Long
    Select Case kind
        Case 1
            If index < 1 Or index > HighIndex Then Exit Function
            If Not IsPlaying(index) Or Player(index).Map <> GetPlayerMap(MyIndex) Then Exit Function
            X = GetPlayerPixelX(index)
            Y = GetPlayerPixelY(index)
        Case 2
            If index < 1 Or index > MAX_MAP_NPCS Then Exit Function
            If MapNpc(index).Num <= 0 Then Exit Function
            X = CLng(MapNpc(index).X) * PIC_X + MapNpc(index).XOffset
            Y = CLng(MapNpc(index).Y) * PIC_Y + MapNpc(index).YOffset
        Case Else
            Exit Function
    End Select
    spriteWidth = CLng(GameData.PlayerX) + 16
    spriteHeight = PIC_Y * 2
    If GameData.PlayerX > 48 Then X = X - CLng(GameData.PlayerX) \ 4
    If X < 0 Then X = 0
    If Y < 0 Then Y = 0
    If X + spriteWidth > DD_BackBuffer.Width Then X = DD_BackBuffer.Width - spriteWidth
    If Y + spriteHeight > DD_BackBuffer.Height Then Y = DD_BackBuffer.Height - spriteHeight
    If X < 0 Then X = 0
    If Y < 0 Then Y = 0
    TargetSpritePosition = True
End Function

Private Function TargetSpriteContains(ByVal kind As Long, ByVal index As Long, ByVal mouseX As Long, ByVal mouseY As Long) As Boolean
    Dim X As Long, Y As Long
    If Not TargetSpritePosition(kind, index, X, Y) Then Exit Function
    TargetSpriteContains = mouseX >= X - 8 And mouseX < X - 8 + CLng(GameData.PlayerX) + 16 And _
                           mouseY >= Y - 16 And mouseY < Y - 16 + PIC_Y * 2
End Function
Private Function DrawEntityTarget(ByVal kind As Long, ByVal index As Long, ByVal preview As Boolean) As Boolean
    Dim source As RECT, destination As RECT, targetX As Long, targetY As Long, pulse As Long
    If Not TargetSpritePosition(kind, index, targetX, targetY) Then Exit Function
    ' Grey brackets gently expand and contract until this entity is selected.
    If preview Then
        source.Left = TARGET_FRAME_WIDTH
        pulse = Abs(((GetTickCount And &H7FFFFFFF) \ 100) Mod 8 - 4)
    End If
    source.Right = source.Left + TARGET_FRAME_WIDTH
    source.Bottom = TARGET_FRAME_HEIGHT
    destination.Left = targetX + PIC_X \ 2 - TARGET_FRAME_WIDTH \ 2 - pulse
    destination.Top = targetY + PIC_Y \ 2 - TARGET_FRAME_HEIGHT \ 2 - pulse
    destination.Right = destination.Left + TARGET_FRAME_WIDTH + pulse * 2
    destination.Bottom = destination.Top + TARGET_FRAME_HEIGHT + pulse * 2
    DD_BackBuffer.Blt destination, TargetSurface, source, True
    DrawEntityTarget = True
End Function

Public Sub ClearSpriteOverlay(ByVal index As Long)
    Player(index).BubbleText = vbNullString
    Player(index).BubbleStarted = 0
    Player(index).BubbleMap = 0
    Player(index).VitalsKnown = False
End Sub

Public Function OverlayInteger(ByVal text As String, ByVal maximum As Long, ByRef result As Long) As Boolean
    Dim value As Double
    On Error GoTo InvalidValue
    If Len(text) = 0 Or Len(text) > 10 Then Exit Function
    If Not IsNumeric(text) Then Exit Function
    value = CDbl(text)
    If value < 0 Or value > maximum Or value <> Fix(value) Then Exit Function
    result = CLng(value)
    OverlayInteger = True
InvalidValue:
End Function

Private Function BubbleVisible(ByVal index As Long) As Boolean
    Dim elapsed As Double, duration As Long
    With Player(index)
        If Len(.BubbleText) = 0 Then Exit Function
        If .BubbleMap <> .Map Then
            .BubbleText = vbNullString
            Exit Function
        End If
        elapsed = CDbl(GetTickCount) - CDbl(.BubbleStarted)
        If elapsed < 0 Then elapsed = elapsed + 4294967296#
        duration = 4000 + Len(.BubbleText) * 40
        If duration > 10000 Then duration = 10000
        If elapsed >= duration Then
            .BubbleText = vbNullString
            Exit Function
        End If
    End With
    BubbleVisible = True
End Function

Private Function OverlayPlayerVisible(ByVal index As Long) As Boolean
    If Not IsPlaying(index) Then Exit Function
    OverlayPlayerVisible = (Player(index).Map = Player(MyIndex).Map)
End Function

Private Sub GetOverlayPlayerSpritePosition(ByVal index As Long, ByRef SpriteX As Long, ByRef SpriteY As Long)
    Dim X As Long
    Dim Y As Long
    Dim SpriteWidth As Long
    Dim SpriteHeight As Long

    SpriteWidth = CLng(GameData.PlayerX) + 16
    SpriteHeight = CLng(PIC_Y) * 2

    X = CLng(GetPlayerPixelX(index))
    Y = CLng(GetPlayerPixelY(index))

    If GameData.PlayerX > 48 Then
        X = X - (CLng(GameData.PlayerX) \ 4)
    End If

    ' Match BltPlayer's clamping exactly.
    If X < 0 Then X = 0
    If Y < 0 Then Y = 0

    If X + SpriteWidth > CLng(DD_MiddleBuffer.Width) Then
        X = CLng(DD_MiddleBuffer.Width) - SpriteWidth
    End If

    If Y + SpriteHeight > CLng(DD_MiddleBuffer.Height) Then
        Y = CLng(DD_MiddleBuffer.Height) - SpriteHeight
    End If

    ' BltPlayer draws the final sprite at X - 8, Y - 16.
    SpriteX = X - 8
    SpriteY = Y - 16
End Sub

Private Sub OverlayLayout(ByVal index As Long, ByVal hasBubble As Boolean, ByRef bars As RECT, ByRef bubble As RECT)
    Dim SpriteX As Long
    Dim SpriteY As Long
    Dim SpriteWidth As Long
    Dim SpriteHeight As Long
    Dim centerX As Long
    Dim barTop As Long
    Dim bubbleTop As Long

    SpriteWidth = CLng(GameData.PlayerX) + 16
    SpriteHeight = CLng(PIC_Y) * 2

    ' Use the exact final position used by BltPlayer.
    GetOverlayPlayerSpritePosition index, SpriteX, SpriteY

    centerX = SpriteX + (SpriteWidth \ 2)

    ' Vitals stay attached directly below the final sprite position.
    barTop = SpriteY + SpriteHeight + 2

    bars.Left = centerX - (BAR_WIDTH \ 2)
    bars.Top = barTop
    bars.Right = bars.Left + BAR_WIDTH
    bars.Bottom = bars.Top + BARS_HEIGHT

    ' Bubble stays attached directly above the final sprite position.
    bubbleTop = SpriteY - BUBBLE_HEIGHT - 4

    bubble.Left = centerX - (BUBBLE_WIDTH \ 2)
    bubble.Top = bubbleTop
    bubble.Right = bubble.Left + BUBBLE_WIDTH
    bubble.Bottom = bubble.Top + BUBBLE_HEIGHT

    ' Do not clamp bars or bubble independently.
    ' Independent clamping makes overlays slide away from the sprite at edges.
End Sub

Public Sub BltSpriteOverlays()
    Dim index As Long, bars As RECT, bubble As RECT, hasBubble As Boolean
    If GettingMap Or MyIndex < 1 Or MyIndex > MAX_PLAYERS Then Exit Sub
    If BubbleSurface Is Nothing Or BarsSurface Is Nothing Then Exit Sub
    For index = 1 To HighIndex
        If OverlayPlayerVisible(index) Then
            hasBubble = BubbleVisible(index)
            OverlayLayout index, hasBubble, bars, bubble
            If GameData.Vitals = 1 Then
                If index = MyIndex Or Player(index).VitalsKnown Then
                    DrawVitalBar bars.Left, bars.Top, 0, Player(index).HP, Player(index).MaxHP
                    DrawVitalBar bars.Left, bars.Top + 8, 1, Player(index).MP, Player(index).MaxMP
                End If
            End If
            If hasBubble Then DrawBubbleSkin bubble
        End If
    Next index
    DrawQuestMarkers
    DrawTargetMarker
End Sub

Private Sub DrawVitalBar(ByVal X As Long, ByVal Y As Long, ByVal row As Long, ByVal value As Long, ByVal maximum As Long)
    Dim source As RECT, filled As Long
    source.Right = BAR_WIDTH
    source.Top = 3 * BAR_HEIGHT: source.Bottom = 4 * BAR_HEIGHT
    DD_BackBuffer.BltFast X, Y, BarsSurface, source
    If maximum <= 0 Or value <= 0 Then Exit Sub
    If value > maximum Then value = maximum
    filled = Fix(CDbl(value) / maximum * BAR_WIDTH)
    If filled < 1 Then filled = 1
    source.Right = filled
    source.Top = row * BAR_HEIGHT: source.Bottom = source.Top + BAR_HEIGHT
    DD_BackBuffer.BltFast X, Y, BarsSurface, source
End Sub

Private Sub DrawBubbleSkin(ByRef bounds As RECT)
    Dim column As Long, row As Long, source As RECT, target As RECT
    Dim sx(0 To 3) As Long, sy(0 To 3) As Long, dx(0 To 3) As Long, dy(0 To 3) As Long
    ' Nine slices retain the rounded corners; only the first 32 rows contain art.
    sx(0) = 0: sx(1) = 8: sx(2) = 120: sx(3) = 128
    sy(0) = 0: sy(1) = 8: sy(2) = 16: sy(3) = 32
    dx(0) = bounds.Left: dx(1) = bounds.Left + 8: dx(2) = bounds.Right - 8: dx(3) = bounds.Right
    dy(0) = bounds.Top: dy(1) = bounds.Top + 8: dy(2) = bounds.Bottom - 16: dy(3) = bounds.Bottom
    For row = 0 To 2
        For column = 0 To 2
            source.Left = sx(column): source.Right = sx(column + 1)
            source.Top = sy(row): source.Bottom = sy(row + 1)
            target.Left = dx(column): target.Right = dx(column + 1)
            target.Top = dy(row): target.Bottom = dy(row + 1)
            DD_BackBuffer.Blt target, BubbleSurface, source
        Next column
    Next row
End Sub

Public Sub DrawSpriteBubbleText(ByVal DC As LongPtr)
    Dim index As Long, bars As RECT, bubble As RECT, textBounds As RECT
    Dim previousFont As LongPtr, previousColor As Long, previousMode As Long
    If GettingMap Or MyIndex < 1 Or MyIndex > MAX_PLAYERS Then Exit Sub
    previousFont = WinDevLib.SelectObject(DC, GameFont)
    previousColor = WinDevLib.SetTextColor(DC, RGB(35, 32, 22))
    previousMode = WinDevLib.SetBkMode(DC, WinDevLib.TRANSPARENT)
    For index = 1 To HighIndex
        If OverlayPlayerVisible(index) Then
            If BubbleVisible(index) Then
                OverlayLayout index, True, bars, bubble
                textBounds = bubble
                textBounds.Left = textBounds.Left + 8
                textBounds.Right = textBounds.Right - 8
                textBounds.Top = textBounds.Top + 4
                textBounds.Bottom = textBounds.Bottom - 8
                WinDevLib.DrawTextW DC, StrPtr(Player(index).BubbleText), Len(Player(index).BubbleText), textBounds, WinDevLib.DT_CENTER Or WinDevLib.DT_WORDBREAK Or WinDevLib.DT_END_ELLIPSIS Or WinDevLib.DT_NOPREFIX
            End If
        End If
    Next index
    WinDevLib.SetBkMode DC, previousMode
    WinDevLib.SetTextColor DC, previousColor
    WinDevLib.SelectObject DC, previousFont
End Sub
Public Sub ClearQuestMarkers()
    Dim index As Long
    For index = 1 To MAX_MAP_NPCS
        QuestMarkerMap(index) = 0
        QuestMarkerNpc(index) = 0
        QuestMarkerStatus(index) = 0
    Next index
End Sub

Public Sub HandleQuestMarker(ByRef parts() As String)
    Dim mapNum As Long, slot As Long, npcNum As Long, status As Long
    If UBound(parts) <> 4 Then Exit Sub
    If Not OverlayInteger(parts(1), 2147483647, mapNum) Then Exit Sub
    If Not OverlayInteger(parts(2), MAX_MAP_NPCS, slot) Then Exit Sub
    If Not OverlayInteger(parts(3), MAX_NPCS, npcNum) Then Exit Sub
    If Not OverlayInteger(parts(4), 4, status) Then Exit Sub
    If mapNum < 1 Or slot < 1 Then Exit Sub
    If status > 0 And npcNum < 1 Then Exit Sub
    QuestMarkerMap(slot) = mapNum
    QuestMarkerNpc(slot) = npcNum
    QuestMarkerStatus(slot) = status
End Sub

Private Sub DrawQuestMarkers()
    Dim index As Long, source As RECT, X As Long, Y As Long, row As Long, frame As Long
    If QuestSurface Is Nothing Then Exit Sub
    frame = ((GetTickCount And &H7FFFFFFF) \ 180) Mod 4
    If frame = 3 Then frame = 1
    source.Left = frame * PIC_X
    source.Right = source.Left + PIC_X
    For index = 1 To MAX_MAP_NPCS
        If QuestMarkerStatus(index) > 0 And QuestMarkerMap(index) = GetPlayerMap(MyIndex) Then
            If MapNpc(index).Num > 0 And MapNpc(index).Num = QuestMarkerNpc(index) Then
                If TargetSpritePosition(2, index, X, Y) Then
                    Select Case QuestMarkerStatus(index)
                        Case 1: row = 3 ' Available: yellow !
                        Case 2: row = 0 ' In progress: grey ?
                        Case 3: row = 1 ' Ready to turn in: yellow ?
                        Case 4: row = 2 ' Unavailable: grey !
                    End Select
                    source.Top = row * PIC_Y
                    source.Bottom = source.Top + PIC_Y
                    X = X - 8 + (CLng(GameData.PlayerX) + 16 - PIC_X) \ 2
                    Y = Y - 16 - PIC_Y
                    If X < 0 Then X = 0
                    If X + PIC_X > DD_BackBuffer.Width Then X = DD_BackBuffer.Width - PIC_X
                    If Y < 0 Then Y = 0
                    DD_BackBuffer.BltFast X, Y, QuestSurface, source, False
                End If
            End If
        End If
    Next index
End Sub