Attribute VB_Name = "modText"
Option Explicit

Public Sub SetFont(ByVal Font As String, ByVal Size As Byte)
    GameFont = CreateFont(Size, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Font)
End Sub

' GDI text drawing
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

Sub DrawPlayerName(ByVal index As Long)
    Dim TextX As Long
    Dim TextY As Long
    Dim Color As Long

    ' Check access level
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

    ' Draw name
    TextX = GetPlayerX(index) * PIC_X + Player(index).XOffset + Int(PIC_X / 2) - (getSize(TexthDC, GetPlayerName(index)).Width / 2)   ' - ((Len(Trim$(GetPlayerName(index))) / 2) * 6)
    TextY = GetPlayerY(index) * PIC_Y + Player(index).YOffset - Int(GameData.PlayerY / 2) - 6
    Call DrawText(TexthDC, TextX, TextY, GetPlayerName(index), Color)
End Sub

Sub DrawPlayerGuildName(ByVal index As Long)
    Dim TextX As Long
    Dim TextY As Long

    ' make sure there is a Guild!
    If Player(index).Guild = 0 Then
        Exit Sub
    End If

    ' Draw name
    TextX = GetPlayerX(index) * PIC_X + Player(index).XOffset + Int(PIC_X / 2) - (getSize(TexthDC, (Guild(Player(index).Guild).Abbreviation)).Width / 2)   ' - ((Len(Trim$(Guild(Player(index).Guild).Abbreviation)) / 2) * 4.5)
    TextY = GetPlayerY(index) * PIC_Y + Player(index).YOffset - Int(PIC_Y) - 2
    Call DrawText(TexthDC, TextX, TextY, Trim$(Guild(Player(index).Guild).Abbreviation), QBColor(White))
End Sub

Sub DrawMapNPCName(ByVal index As Long)
    Dim TextX As Long
    Dim TextY As Long

    With Npc(MapNpc(index).Num)
        ' Draw name
        TextX = MapNpc(index).X * PIC_X + MapNpc(index).XOffset + Int(PIC_X / 2) - (getSize(TexthDC, Trim$(.name)).Width / 2)   ' - ((Len(Trim$(.name)) / 2) * 6)
        TextY = MapNpc(index).Y * PIC_Y + MapNpc(index).YOffset - Int(PIC_Y / 2) - 2
        DrawText TexthDC, TextX, TextY, Trim$(.name), QBColor(Brown)
    End With
End Sub
