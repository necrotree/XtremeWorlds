Attribute VB_Name = "modSpriteOverlays"
Option Explicit

Private BubbleSurface As clsDX11Surface
Private BarsSurface As clsDX11Surface
Private Const BAR_WIDTH As Long = 56
Private Const BAR_HEIGHT As Long = 7
Private Const BARS_HEIGHT As Long = 23
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
    If BubbleSurface.Width <> 128 Or BubbleSurface.Height <> 64 Then Err.Raise 5, "Sprite overlays", "chatbubble.png must be 128 x 64."
    If BarsSurface.Width <> BAR_WIDTH Or BarsSurface.Height <> BAR_HEIGHT * 4 Then Err.Raise 5, "Sprite overlays", "bars.png must be 56 x 28."
End Sub

Public Sub DestroySpriteOverlays()
    Set BubbleSurface = Nothing
    Set BarsSurface = Nothing
End Sub

Public Sub ClearSpriteOverlay(ByVal index As Long)
    Player(index).BubbleText = vbNullString
    Player(index).BubbleStarted = 0
    Player(index).BubbleMap = 0
    Player(index).VitalsKnown = False
End Sub

' Complete messages arrive through the existing shared TCP packet buffer.
Public Function HandleSpriteOverlayPacket(ByVal packet As String) As Boolean
    Dim command As String, separator As Long, parts() As String
    separator = InStr(packet, SEP_CHAR)
    command = LCase$(packet)
    If separator > 0 Then command = LCase$(Left$(packet, separator - 1))
    Select Case command
        Case "spritebubble", "spritevitals": HandleSpriteOverlayPacket = True
        Case Else: Exit Function
    End Select
    parts = Split(packet, SEP_CHAR)
    If command = "spritebubble" Then
        ReceiveSpriteBubble parts
    Else
        ReceiveSpriteVitals parts
    End If
End Function

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

Private Sub ReceiveSpriteBubble(ByRef parts() As String)
    Dim index As Long, mapNumber As Long
    If UBound(parts) <> 3 Then Exit Sub
    If Not OverlayInteger(parts(1), MAX_PLAYERS, index) Then Exit Sub
    If index < 1 Then Exit Sub
    If Not OverlayInteger(parts(2), MAX_MAPS, mapNumber) Then Exit Sub
    If mapNumber = 0 Or Player(index).Map <> mapNumber Then Exit Sub
    Player(index).BubbleText = Left$(Trim$(Replace(Replace(parts(3), vbCr, " "), vbLf, " ")), BUBBLE_TEXT_LIMIT)
    Player(index).BubbleStarted = GetTickCount
    Player(index).BubbleMap = mapNumber
End Sub

Private Sub ReceiveSpriteVitals(ByRef parts() As String)
    Dim index As Long, mapNumber As Long, values(0 To 5) As Long, i As Long
    If UBound(parts) <> 8 Then Exit Sub
    If Not OverlayInteger(parts(1), MAX_PLAYERS, index) Then Exit Sub
    If index < 1 Then Exit Sub
    If Not OverlayInteger(parts(2), MAX_MAPS, mapNumber) Then Exit Sub
    If mapNumber = 0 Or Player(index).Map <> mapNumber Then Exit Sub
    For i = 0 To 5
        If Not OverlayInteger(parts(i + 3), &H7FFFFFFF, values(i)) Then Exit Sub
    Next i
    With Player(index)
        .HP = values(0): .MaxHP = values(1)
        .MP = values(2): .MaxMP = values(3)
        .SP = values(4): .MaxSP = values(5)
        .VitalsKnown = True
    End With
End Sub

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

Private Sub OverlayLayout(ByVal index As Long, ByVal hasBubble As Boolean, ByRef bars As RECT, ByRef bubble As RECT)
    Dim centerX As Long, playerTop As Long, barTop As Long, bubbleTop As Long
    ' Match BltPlayer's actual source frame width, feet, and walking offsets.
    centerX = Player(index).X * PIC_X + Player(index).XOffset
    If GameData.PlayerX > 48 Then centerX = centerX - GameData.PlayerX / 4
    centerX = centerX + (GameData.PlayerX + 16) \ 2
    playerTop = Player(index).Y * PIC_Y + Player(index).YOffset
    barTop = playerTop + PIC_Y * 2 + 2
    If barTop + BARS_HEIGHT > DD_BackBuffer.Height Then barTop = DD_BackBuffer.Height - BARS_HEIGHT
    If barTop < 0 Then barTop = 0
    bubbleTop = playerTop - Int(GameData.PlayerY / 2) - 6 - BUBBLE_HEIGHT - 4
    If bubbleTop < 0 Then bubbleTop = 0
    bars.Left = centerX - BAR_WIDTH \ 2
    If bars.Left < 0 Then bars.Left = 0
    If bars.Left + BAR_WIDTH > DD_BackBuffer.Width Then bars.Left = DD_BackBuffer.Width - BAR_WIDTH
    bars.Top = barTop: bars.Right = bars.Left + BAR_WIDTH: bars.Bottom = barTop + BARS_HEIGHT
    bubble.Left = centerX - BUBBLE_WIDTH \ 2
    If bubble.Left < 0 Then bubble.Left = 0
    If bubble.Left + BUBBLE_WIDTH > DD_BackBuffer.Width Then bubble.Left = DD_BackBuffer.Width - BUBBLE_WIDTH
    bubble.Top = bubbleTop
    bubble.Right = bubble.Left + BUBBLE_WIDTH
    bubble.Bottom = bubble.Top + BUBBLE_HEIGHT
End Sub

Public Sub BltSpriteOverlays()
    Dim index As Long, bars As RECT, bubble As RECT, hasBubble As Boolean
    If GettingMap Or MyIndex < 1 Or MyIndex > MAX_PLAYERS Then Exit Sub
    If BubbleSurface Is Nothing Or BarsSurface Is Nothing Then Exit Sub
    For index = 1 To HighIndex
        If OverlayPlayerVisible(index) Then
            hasBubble = BubbleVisible(index)
            OverlayLayout index, hasBubble, bars, bubble
            If index = MyIndex Or Player(index).VitalsKnown Then
                DrawVitalBar bars.Left, bars.Top, 0, Player(index).HP, Player(index).MaxHP
                DrawVitalBar bars.Left, bars.Top + 8, 1, Player(index).MP, Player(index).MaxMP
                DrawVitalBar bars.Left, bars.Top + 16, 2, Player(index).SP, Player(index).MaxSP
            End If
            If hasBubble Then DrawBubbleSkin bubble
        End If
    Next index
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