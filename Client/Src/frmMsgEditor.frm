VERSION 5.00
Begin VB.Form frmMsgEditor 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Map Message"
   ClientHeight    =   1755
   ClientLeft      =   4125
   ClientTop       =   3075
   ClientWidth     =   4380
   ControlBox      =   0   'False
   Icon            =   "frmMsgEditor.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1755
   ScaleWidth      =   4380
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Visible         =   0   'False
   Begin VB.TextBox txtMsgEditorText 
      Height          =   285
      Left            =   1440
      MaxLength       =   255
      TabIndex        =   6
      Text            =   "Your Text Here"
      Top             =   120
      Width           =   2895
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   2640
      TabIndex        =   3
      Top             =   1320
      Width           =   1455
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "Ok"
      Height          =   375
      Left            =   480
      TabIndex        =   2
      Top             =   1320
      Width           =   1455
   End
   Begin VB.OptionButton optPlayer 
      Caption         =   "Player"
      Height          =   255
      Left            =   1560
      TabIndex        =   1
      Top             =   960
      Value           =   -1  'True
      Width           =   1335
   End
   Begin VB.OptionButton optGlobal 
      Caption         =   "Global"
      Height          =   255
      Left            =   3000
      TabIndex        =   0
      Top             =   960
      Width           =   1335
   End
   Begin VB.Label Label3 
      Caption         =   "The maximum length is 255 characters!"
      ForeColor       =   &H000000FF&
      Height          =   255
      Left            =   720
      TabIndex        =   7
      Top             =   480
      Width           =   2775
   End
   Begin VB.Label Label2 
      Caption         =   "Message Text"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      Top             =   120
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Message Type"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   960
      Width           =   1215
   End
End
Attribute VB_Name = "frmMsgEditor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdOK_Click()
    MsgEditorText = Trim$(txtMsgEditorText.Text)
    If optPlayer.Value = True Then
        MsgEditorType = 0
    ElseIf optGlobal.Value = True Then
        MsgEditorType = 1
    End If
    Unload Me
End Sub

Private Sub optGlobal_Click()
    If optPlayer.Value = True Then
        optPlayer.Value = False
        optGlobal.Value = True
    End If
End Sub

Private Sub optPlayer_Click()
    If optGlobal.Value = True Then
        optGlobal.Value = False
        optPlayer.Value = True
    End If
End Sub
