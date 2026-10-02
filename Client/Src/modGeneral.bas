Attribute VB_Name = "modGeneral"
Option Explicit

Public SOffsetX As Integer
Public SOffsetY As Integer

Public Audio As clsBASS
Public BassInit As Boolean
Public MusicHandle As Long
Public CurrentSong As String

Public Enum ChatHistoryChannel
    ChatHistoryAll = 0
    ChatHistoryLocal = 1
    ChatHistoryGlobal = 2
    ChatHistoryEmote = 3
    ChatHistoryPrivate = 4
    ChatHistoryParty = 5
    ChatHistoryGuild = 6
    ChatHistorySystem = 7
End Enum

Private Const ChatHistoryLimit As Long = 256

Private Type ChatHistoryEntry
    Message As String
    Color As Integer
    Channel As Long
End Type
                                                                                                                                                                                                                                             
Private ChatHistory(0 To ChatHistoryLimit - 1) As ChatHistoryEntry
Private ChatHistoryStart As Long
Private ChatHistoryCount As Long
Private HiddenChatChannels(ChatHistoryLocal To ChatHistorySystem) As Boolean

Public Sub UnloadAllForms()
    Dim frm As Form

    For Each frm In VB.Forms
        Unload frm
    Next
End Sub

Sub GameDestroy()
    Audio.Shutdown
    InGame = False
    Call DestroyDirectX
    Call TcpDestroy
    Call UnloadAllForms

    End
End Sub

Public Sub SetFocusOnGame()
On Error Resume Next
    frmMainGame.picScreen.SetFocus
End Sub

Sub MovePicture(PB As PictureBox, Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Button = 1 Then
        PB.Left = PB.Left + X - SOffsetX
        PB.Top = PB.Top + Y - SOffsetY
    End If
End Sub

' This sub writes text to the chatbox
Public Sub AddText(ByVal Msg As String, ByVal Color As Integer, Optional ByVal Channel As Long = ChatHistorySystem)
    Dim slot As Long

    If Channel < ChatHistoryLocal Or Channel > ChatHistorySystem Then Channel = ChatHistorySystem

    If ChatHistoryCount < ChatHistoryLimit Then
        slot = (ChatHistoryStart + ChatHistoryCount) Mod ChatHistoryLimit
        ChatHistoryCount = ChatHistoryCount + 1
    Else
        slot = ChatHistoryStart
        ChatHistoryStart = (ChatHistoryStart + 1) Mod ChatHistoryLimit
    End If

    ChatHistory(slot).Message = Msg
    ChatHistory(slot).Color = Color
    ChatHistory(slot).Channel = Channel

    If IsChatHistoryChannelVisible(Channel) Then
        AppendChatLine Msg, Color
    End If
End Sub

Public Sub ResetChatHistoryChannels()
    Erase HiddenChatChannels
    RefreshChatHistory
End Sub

Public Sub ToggleChatHistoryChannel(ByVal Channel As Long)
    Select Case Channel
        Case ChatHistoryLocal, ChatHistoryGlobal, ChatHistoryGuild, ChatHistoryPrivate
            HiddenChatChannels(Channel) = Not HiddenChatChannels(Channel)
        Case Else
            Exit Sub
    End Select
    RefreshChatHistory
End Sub

Private Function IsChatHistoryChannelVisible(ByVal Channel As Long) As Boolean
    Select Case Channel
        Case ChatHistoryLocal, ChatHistoryEmote
            IsChatHistoryChannelVisible = Not HiddenChatChannels(ChatHistoryLocal)
        Case ChatHistoryGlobal, ChatHistoryGuild, ChatHistoryPrivate
            IsChatHistoryChannelVisible = Not HiddenChatChannels(Channel)
        Case Else
            ' Party and system messages are always visible.
            IsChatHistoryChannelVisible = True
    End Select
End Function

Private Function ChatChannelToolTip(ByVal Channel As Long, ByVal ChannelName As String) As String
    If IsChatHistoryChannelVisible(Channel) Then
        ChatChannelToolTip = ChannelName & " chat: visible (click to hide)"
    Else
        ChatChannelToolTip = ChannelName & " chat: hidden (click to show)"
    End If
End Function

Private Sub RefreshChatHistory()
    Dim i As Long, slot As Long

    frmMainGame.imgMap.ToolTipText = ChatChannelToolTip(ChatHistoryLocal, "Map")
    frmMainGame.imgGlobal.ToolTipText = ChatChannelToolTip(ChatHistoryGlobal, "Global")
    frmMainGame.imgGuild.ToolTipText = ChatChannelToolTip(ChatHistoryGuild, "Guild")
    frmMainGame.imgPM.ToolTipText = ChatChannelToolTip(ChatHistoryPrivate, "Private")
    frmMainGame.txtChat.Text = vbNullString

    For i = 0 To ChatHistoryCount - 1
        slot = (ChatHistoryStart + i) Mod ChatHistoryLimit

        If IsChatHistoryChannelVisible(ChatHistory(slot).Channel) Then
            AppendChatLine ChatHistory(slot).Message, ChatHistory(slot).Color
        End If
    Next i
End Sub

Private Sub AppendChatLine(ByVal Msg As String, ByVal Color As Integer)
    Dim S As String

    S = vbNewLine & Msg

    frmMainGame.txtChat.SelStart = Len(frmMainGame.txtChat.Text)
    frmMainGame.txtChat.SelColor = QBColor(Color)
    frmMainGame.txtChat.SelText = S
    frmMainGame.txtChat.SelStart = Len(frmMainGame.txtChat.Text) - 1

    ' Prevent players from name spoofing
    frmMainGame.txtChat.SelHangingIndent = 15
End Sub

' Used for debugger
Public Sub TextAdd(ByVal Txt As TextBox, Msg As String, NewLine As Boolean)
    If NewLine Then
        Txt.Text = Txt.Text + Msg + vbCrLf
    Else
        Txt.Text = Txt.Text + Msg
    End If

    Txt.SelStart = Len(Txt.Text) - 1
End Sub

Sub SetStatus(ByVal Caption As String)
    frmSendGetData.lblStatus.Caption = Caption
    DoEvents
End Sub