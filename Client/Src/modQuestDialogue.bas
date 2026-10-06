Attribute VB_Name = "modQuestDialogue"
Option Explicit
Public QuestDialogueOpen As Boolean
Public QuestEditorOpen As Boolean
Public QuestEditorPending As Long

Private ChatQuestId As Long
Private ChatNpcSlot As Long
Private ChatNpcNumber As Long
Private ChatMap As Long
Private ChatAction As Long

Public Sub ShowQuestChat(ByVal id As Long, ByVal slot As Long, ByVal title As String, ByVal npcName As String, ByVal message As String, ByVal action As Long)
    If slot < 1 Or slot > MAX_MAP_NPCS Then Exit Sub
    ChatQuestId = id
    ChatNpcSlot = slot
    ChatNpcNumber = MapNpc(slot).Num
    ChatMap = GetPlayerMap(MyIndex)
    ChatAction = action
    AddText "[Quest: " & title & "] " & npcName & ": " & message, Yellow
    frmMainGame.QuestText.Text = title & vbCrLf & npcName & ": " & message
    frmMainGame.imgQuestPanel.Visible = True
    frmMainGame.hostQuestText.Visible = True
    frmMainGame.imgQuestPanel.ZOrder 0
    frmMainGame.hostQuestText.ZOrder 0
    frmMainGame.lblQuestAction.ZOrder 0
    frmMainGame.lblQuestDismiss.ZOrder 0
    frmMainGame.lblQuestAction.Visible = action = 1 Or action = 2
    frmMainGame.lblQuestAction.Enabled = True
    If action = 1 Then frmMainGame.lblQuestAction.Caption = "Accept quest"
    If action = 2 Then frmMainGame.lblQuestAction.Caption = "Complete quest"
    frmMainGame.lblQuestDismiss.Visible = True
End Sub

Public Sub SubmitQuestChatAction()
    If ChatAction < 1 Or ChatAction > 2 Then Exit Sub
    If Not InGame Or Not IsConnected Then ClearQuestChat: Exit Sub
    If GetPlayerMap(MyIndex) <> ChatMap Then ClearQuestChat: Exit Sub
    If MapNpc(ChatNpcSlot).Num <> ChatNpcNumber Then ClearQuestChat: Exit Sub
    frmMainGame.lblQuestAction.Enabled = False
    frmMainGame.Socket.SendData "questaction" & SEP_CHAR & ChatQuestId & SEP_CHAR & ChatNpcSlot & SEP_CHAR & ChatAction & END_CHAR
    ChatAction = 0
End Sub

Public Sub ClearQuestChat()
    ChatQuestId = 0
    ChatNpcSlot = 0
    ChatAction = 0
        frmMainGame.lblQuestAction.Visible = False
    frmMainGame.lblQuestDismiss.Visible = False
    frmMainGame.hostQuestText.Visible = False
    frmMainGame.imgQuestPanel.Visible = False
End Sub

Public Sub ResetEditorIndexState()
    InEmoteEditor = False
    InItemsEditor = False
    InNpcEditor = False
    InShopEditor = False
    InSpellEditor = False
    InSignEditor = False
    InArrowEditor = False
    InClassEditor = False
    InQuestEditor = False
    QuestEditorPending = 0
End Sub

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
            If QuestEditorOpen Then Exit Sub
            ShowQuestChat CLng(Val(parts(1))), CLng(Val(parts(2))), parts(3), parts(4), parts(5), CLng(Val(parts(6)))
        Case "questeditorbegin"
            ClearQuestChat
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
            ResetEditorIndexState
            InQuestEditor = True
            frmIndex.lstIndex.Clear
            frmQuestEditor.FillIndex frmIndex.lstIndex
            If frmIndex.lstIndex.ListCount > 0 Then frmIndex.lstIndex.ListIndex = 0
            frmIndex.Show
        Case "questeditordata"
            If UBound(parts) <> 20 Then Exit Sub
            If QuestEditorPending = 0 Or CLng(Val(parts(1))) <> QuestEditorPending Then Exit Sub
            QuestEditorPending = 0
            frmQuestEditor.SelectQuest CLng(Val(parts(1)))
            ' Populate the lists before assigning the received selections.
            frmQuestEditor.OpenEditor
            frmQuestEditor.LoadDefinition parts
        Case "questeditorsaved"
            If UBound(parts) <> 1 Then Exit Sub
            If Not QuestEditorOpen Then Exit Sub
            frmQuestEditor.Saved CLng(Val(parts(1)))
        Case "questeditorerror"
            If UBound(parts) <> 1 Then Exit Sub
            If Not QuestEditorOpen Then Exit Sub
            frmQuestEditor.SaveFailed parts(1)
    End Select
End Sub
