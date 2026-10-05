Attribute VB_Name = "modProjectiles"
Option Explicit

Public Const MAX_PROJECTILES As Long = 256

Public Type ArrowRec
    Name As String
    Sprite As Long
    Range As Long
End Type

Public Type SpellDeliveryRec
    Mode As Long
    Arrow As Long
    Range As Long
End Type

Private Type ProjectileRec
    Active As Boolean
    Map As Long
    Sprite As Long
    Direction As Long
    X As Long
    Y As Long
    Updated As Long
End Type

Public ArrowEditorActive As Boolean
Public SpellDelivery() As SpellDeliveryRec
Public Shots(1 To MAX_PROJECTILES) As ProjectileRec
Private DeliveryCount As Long

Public Sub EnsureSpellDelivery()
    Dim i As Long
    If MAX_SPELLS < 1 Or DeliveryCount = MAX_SPELLS Then Exit Sub
    ReDim SpellDelivery(1 To MAX_SPELLS)
    DeliveryCount = MAX_SPELLS
    For i = 1 To MAX_SPELLS
        SpellDelivery(i).Range = 32
        SpellDelivery(i).Arrow = 1
    Next
End Sub

Public Sub InitSpellDeliveryEditor()
    Dim i As Long
    EnsureSpellDelivery
    With frmSpellEditor
        .cmbDelivery.Clear
        .cmbDelivery.AddItem "Range cast (selected target)"
        .cmbDelivery.AddItem "Projectile hit"
        .cmbArrow.Clear
        For i = 1 To MAX_ARROWS
            If Len(Trim$(Arrow(i).Name)) > 0 Then
                .cmbArrow.AddItem Trim$(Arrow(i).Name)
            Else
                .cmbArrow.AddItem "(Unnamed Arrow)"
            End If
        Next
        .cmbDelivery.ListIndex = SpellDelivery(EditorIndex).Mode
        .cmbArrow.ListIndex = SpellDelivery(EditorIndex).Arrow - 1
        .txtCastRange.Text = CStr(SpellDelivery(EditorIndex).Range)
    End With
End Sub

Public Function SaveSpellDeliveryEditor() As Boolean
    Dim distance As Double
    With frmSpellEditor
        If Not IsNumeric(.txtCastRange.Text) Then GoTo InvalidRange
        distance = Val(.txtCastRange.Text)
        If distance <> Fix(distance) Or distance < 1 Or distance > 32 Then GoTo InvalidRange
        SpellDelivery(EditorIndex).Mode = .cmbDelivery.ListIndex
        SpellDelivery(EditorIndex).Arrow = .cmbArrow.ListIndex + 1
        SpellDelivery(EditorIndex).Range = CLng(distance)
    End With
    SaveSpellDeliveryEditor = True
    Exit Function
InvalidRange:
    GameMsgBox "Spell range must be a whole number from 1 to 32 tiles.", vbExclamation
End Function

Public Function SpellDeliveryPacket(ByVal number As Long) As String
    EnsureSpellDelivery
    With SpellDelivery(number)
        SpellDeliveryPacket = SEP_CHAR & .Mode & SEP_CHAR & .Arrow & SEP_CHAR & .Range
    End With
End Function


Public Sub ClearProjectiles()
    Dim i As Long
    For i = 1 To MAX_PROJECTILES
        Shots(i).Active = False
    Next
End Sub

Public Sub BltProjectiles()
    Dim i As Long, source As RECT, destination As RECT
    If DD_ArrowSurf Is Nothing Then Exit Sub
    For i = 1 To MAX_PROJECTILES
        With Shots(i)
            If .Active Then
                If .Map <> GetPlayerMap(MyIndex) Or GetTickCount - .Updated > 5000 Then
                    .Active = False
                ElseIf .Sprite >= 0 And (.Sprite + 1) * PIC_Y <= DD_ArrowSurf.Height Then
                    source.Left = .Direction * PIC_X
                    source.Top = .Sprite * PIC_Y
                    source.Right = source.Left + PIC_X
                    source.Bottom = source.Top + PIC_Y
                    destination.Left = .X - PIC_X \ 2
                    destination.Top = .Y - PIC_Y \ 2
                    destination.Right = destination.Left + PIC_X
                    destination.Bottom = destination.Top + PIC_Y
                    ' Clip at the map border so partially visible arrows render safely.
                    If destination.Left < 0 Then
                        source.Left = source.Left - destination.Left
                        destination.Left = 0
                    End If
                    If destination.Top < 0 Then
                        source.Top = source.Top - destination.Top
                        destination.Top = 0
                    End If
                    If destination.Right > DD_MiddleBuffer.Width Then
                        source.Right = source.Right - (destination.Right - DD_MiddleBuffer.Width)
                        destination.Right = DD_MiddleBuffer.Width
                    End If
                    If destination.Bottom > DD_MiddleBuffer.Height Then
                        source.Bottom = source.Bottom - (destination.Bottom - DD_MiddleBuffer.Height)
                        destination.Bottom = DD_MiddleBuffer.Height
                    End If
                    If source.Right > source.Left And source.Bottom > source.Top Then DD_MiddleBuffer.Blt destination, DD_ArrowSurf, source, True
                End If
            End If
        End With
    Next
End Sub
