Attribute VB_Name = "modQuestDialogue"
Option Explicit
Public QuestDialogueOpen As Boolean
Public QuestEditorOpen As Boolean

Public Sub RequestQuestTalk(ByVal X As Single, ByVal Y As Single)
    Dim slot As Long, tileX As Long, tileY As Long
    If Not InGame Or InEditor Or Not IsConnected Then Exit Sub
    tileX = Int(X / PIC_X): tileY = Int(Y / PIC_Y)
    For slot = 1 To MAX_MAP_NPCS
        If MapNpc(slot).Num > 0 And MapNpc(slot).X = tileX And MapNpc(slot).Y = tileY Then
            frmMainGame.Socket.SendData "questtalk" & SEP_CHAR & slot & END_CHAR
            Exit Sub
        End If
    Next slot
End Sub

Public Sub HandleQuestDialoguePacket(ByRef parts() As String)
    Dim id As Long
    Select Case LCase$(parts(0))
        Case "questdialogue"
            If Not InGame Or UBound(parts) <> 6 Then Exit Sub
            Load frmQuestDialogue
            frmQuestDialogue.Display CLng(Val(parts(1))), CLng(Val(parts(2))), parts(3), parts(4), parts(5), CLng(Val(parts(6)))
        Case "questeditorbegin"
            If UBound(parts) <> 1 Then Exit Sub
            Load frmQuestEditor
            frmQuestEditor.BeginList CLng(Val(parts(1)))
        Case "questeditorname"
            If UBound(parts) <> 2 Then Exit Sub
            frmQuestEditor.SetQuestName CLng(Val(parts(1))), parts(2)
        Case "questeditorclasses"
            If UBound(parts) < 2 Then Exit Sub
            frmQuestEditor.SetClassNames parts
        Case "questeditorready"
            InQuestEditor = True
            frmIndex.lstIndex.Clear
            frmQuestEditor.FillIndex frmIndex.lstIndex
            If frmIndex.lstIndex.ListCount > 0 Then frmIndex.lstIndex.ListIndex = 0
            frmIndex.Show
        Case "questeditordata"
            If UBound(parts) <> 20 Then Exit Sub
            frmQuestEditor.SelectQuest CLng(Val(parts(1)))
            frmQuestEditor.LoadDefinition parts
            frmQuestEditor.OpenEditor
        Case "questeditorsaved"
            If UBound(parts) <> 1 Then Exit Sub
            frmQuestEditor.Saved CLng(Val(parts(1)))
        Case "questeditorerror"
            If UBound(parts) <> 1 Then Exit Sub
            frmQuestEditor.SaveFailed parts(1)
    End Select
End Sub
