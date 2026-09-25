VERSION 5.00
Begin VB.Form frmTrade 
   BackColor       =   &H00000000&
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Trade"
   ClientHeight    =   5550
   ClientLeft      =   5865
   ClientTop       =   4395
   ClientWidth     =   3900
   ControlBox      =   0   'False
   BeginProperty Font 
      Name            =   "Arial"
      Size            =   12
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "frmTrade.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture         =   "frmTrade.frx":030C
   ScaleHeight     =   5550
   ScaleWidth      =   3900
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox mnuFixItems 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   5550
      Left            =   0
      Picture         =   "frmTrade.frx":46AA8
      ScaleHeight     =   5550
      ScaleWidth      =   3900
      TabIndex        =   4
      Top             =   0
      Visible         =   0   'False
      Width           =   3900
      Begin VB.ComboBox cmbItem 
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   330
         Left            =   360
         Style           =   2  'Dropdown List
         TabIndex        =   5
         Top             =   2760
         Width           =   3135
      End
      Begin VB.Label picFixCancel 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   1560
         TabIndex        =   7
         Top             =   5040
         Width           =   855
      End
      Begin VB.Label picFix 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   1800
         TabIndex        =   6
         Top             =   4680
         Width           =   375
      End
   End
   Begin VB.ListBox lstTrade 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   1920
      ItemData        =   "frmTrade.frx":8D244
      Left            =   330
      List            =   "frmTrade.frx":8D246
      TabIndex        =   0
      Top             =   2160
      Width           =   3255
   End
   Begin VB.Label picDeal 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   1680
      TabIndex        =   3
      Top             =   4680
      Width           =   615
   End
   Begin VB.Label picCancel 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   1440
      TabIndex        =   2
      Top             =   5040
      Width           =   1095
   End
   Begin VB.Label picFixItems 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   1800
      TabIndex        =   1
      Top             =   4320
      Width           =   375
   End
End
Attribute VB_Name = "frmTrade"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmbStat_Change()
    Call SendData("usestatpoint" & SEP_CHAR & cmbStat.ListIndex & END_CHAR)
End Sub

Private Sub Form_Load()
' cmbStat.ListIndex = 0
End Sub

Private Sub picDeal_Click()
    If lstTrade.ListCount > 0 Then
        Call SendData("traderequest" & SEP_CHAR & lstTrade.ListIndex + 1 & END_CHAR)
    End If
End Sub

Private Sub picFix_Click()
    Call SendData("fixitem" & SEP_CHAR & cmbItem.ListIndex + 1 & END_CHAR)
End Sub

Private Sub picFixCancel_Click()
    Unload Me
End Sub

Private Sub picFixItems_Click()
    Dim i As Long

    For i = 1 To MAX_INV
        If GetPlayerInvItemNum(MyIndex, i) > 0 Then
            cmbItem.AddItem i & ": " & Trim$(Item(GetPlayerInvItemNum(MyIndex, i)).name)
        Else
            cmbItem.AddItem "Unused Slot"
        End If
    Next i
    cmbItem.ListIndex = 0
    mnuFixItems.Visible = True
    Me.Caption = GAME_NAME & " :: Fix Items"
End Sub

Private Sub picCancel_Click()
    Unload Me
End Sub

Private Sub picTrainCancel_Click()
    Unload Me
End Sub
