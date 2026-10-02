Attribute VB_Name = "modSpriteOverlays"
Option Explicit

Private BubbleSurface As clsDX11Surface
Private BarsSurface As clsDX11Surface
Private TargetSurface As clsDX11Surface
Private TargetMarkerVisible As Boolean
Private TargetMarkerX As Long
Private TargetMarkerY As Long
Private TargetMarkerMap As Long
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
    Set TargetSurface = New clsDX11Surface
    TargetSurface.LoadFromFile App.Path & GFX_PATH & "misc\target.png"
    TargetSurface.ColorKey = RGB(255, 0, 255)
    If BubbleSurface.Width <> 128 Or BubbleSurface.Height <> 64 Then Err.Raise 5, "Sprite overlays", "chatbubble.png must be 128 x 64."
    If BarsSurface.Width <> BAR_WIDTH Or BarsSurface.Height <> BAR_HEIGHT * 4 Then Err.Raise 5, "Sprite overlays", "bars.png must be 56 x 28."
    If TargetSurface.Width <> PIC_X Or TargetSurface.Height <> PIC_Y Then Err.Raise 5, "Sprite overlays", "target.png must be 32 x 32."
End Sub

Public Sub DestroySpriteOverlays()
    Set BubbleSurface = Nothing
    Set BarsSurface = Nothing
    Set TargetSurface = Nothing
    TargetMarkerVisible = False
End Sub

Public Sub SetTargetMarker(ByVal tileX As Long, ByVal tileY As Long)
    If tileX < 0 Or tileX > MAX_MAPX Or tileY < 0 Or tileY > MAX_MAPY Then Exit Sub
    TargetMarkerX = tileX
    TargetMarkerY = tileY
    TargetMarkerMap = GetPlayerMap(MyIndex)
    TargetMarkerVisible = True
End Sub

Public Sub ClearTargetMarker()
    TargetMarkerVisible = False
End Sub

Private Sub DrawTargetMarker()
    Dim source As RECT, targetX As Long, targetY As Long
    If Not TargetMarkerVisible Then Exit Sub
    If TargetMarkerMap <> GetPlayerMap(MyIndex) Then
        TargetMarkerVisible = False
        Exit Sub
    End If
    If TargetSurface Is Nothing Then Exit Sub
    source.Right = PIC_X
    source.Bottom = PIC_Y
    Select Case TargetType
        Case 1
            If TargetNum < 1 Or TargetNum > HighIndex Then GoTo InvalidTarget
            If Not IsPlaying(TargetNum) Or Player(TargetNum).Map <> TargetMarkerMap Then GoTo InvalidTarget
            targetX = GetPlayerPixelX(TargetNum)
            targetY = GetPlayerPixelY(TargetNum)
        Case 2
            If TargetNum < 1 Or TargetNum > MAX_MAP_NPCS Then GoTo InvalidTarget
            If MapNpc(TargetNum).Num <= 0 Then GoTo InvalidTarget
            targetX = MapNpc(TargetNum).X * PIC_X + MapNpc(TargetNum).XOffset
            targetY = MapNpc(TargetNum).Y * PIC_Y + MapNpc(TargetNum).YOffset
        Case Else
            GoTo InvalidTarget
    End Select
    ' Center the 32x32 marker on the shared sprite foot anchor.
    targetY = GetSpriteFeetY(targetY) - PIC_Y
    DD_BackBuffer.BltFast targetX, targetY, TargetSurface, source, True
    Exit Sub

InvalidTarget:
    ClearTargetMarker
End Sub

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
    GetSpriteDrawPosition GetPlayerSprite(index), GetPlayerPixelX(index), GetPlayerPixelY(index), SpriteX, SpriteY
End Sub

Private Sub OverlayLayout(ByVal index As Long, ByVal hasBubble As Boolean, ByRef bars As RECT, ByRef bubble As RECT)
    Dim SpriteX As Long
    Dim SpriteY As Long
    Dim SpriteWidth As Long
    Dim SpriteHeight As Long
    Dim centerX As Long
    Dim barTop As Long
    Dim bubbleTop As Long

    GetSpriteDimensions GetPlayerSprite(index), SpriteWidth, SpriteHeight

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
