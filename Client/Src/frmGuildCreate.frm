VERSION 5.00
Begin VB.Form frmGuildCreate 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Create Guild"
   ClientHeight    =   3675
   ClientLeft      =   3270
   ClientTop       =   5070
   ClientWidth     =   3375
   ControlBox      =   0   'False
   Icon            =   "frmGuildCreate.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3675
   ScaleWidth      =   3375
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   2280
      TabIndex        =   10
      Top             =   3240
      Width           =   975
   End
   Begin VB.CommandButton cmdSave 
      Caption         =   "Save"
      Height          =   375
      Left            =   120
      TabIndex        =   9
      Top             =   3240
      Width           =   975
   End
   Begin VB.TextBox txtFounder 
      Height          =   285
      Left            =   120
      MaxLength       =   50
      TabIndex        =   8
      Top             =   2760
      Width           =   2895
   End
   Begin VB.TextBox txtAbr 
      Height          =   285
      Left            =   120
      MaxLength       =   10
      TabIndex        =   6
      Top             =   2040
      Width           =   2895
   End
   Begin VB.TextBox txtName 
      Height          =   285
      Left            =   120
      MaxLength       =   50
      TabIndex        =   5
      Top             =   1320
      Width           =   2895
   End
   Begin VB.HScrollBar scrlGuild 
      Height          =   255
      Left            =   120
      Max             =   50
      Min             =   1
      TabIndex        =   1
      Top             =   480
      Value           =   1
      Width           =   2775
   End
   Begin VB.Label Label4 
      Caption         =   "Founder:"
      Height          =   255
      Left            =   120
      TabIndex        =   7
      Top             =   2400
      Width           =   1455
   End
   Begin VB.Label Label3 
      Caption         =   "Abbreviation:"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   1680
      Width           =   1455
   End
   Begin VB.Label Label2 
      Caption         =   "Name:"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   960
      Width           =   1455
   End
   Begin VB.Label lblGuild 
      Alignment       =   1  'Right Justify
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   3000
      TabIndex        =   2
      Top             =   480
      Width           =   375
   End
   Begin VB.Label Label1 
      Caption         =   "Guild"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1455
   End
End
Attribute VB_Name = "frmGuildCreate"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdSave_Click()
    Call SendSaveGuild(scrlGuild.Value, Trim$(txtName.Text), Trim$(txtAbr.Text), Trim$(txtFounder.Text))

    If FindPlayer(Trim$(txtFounder.Text)) > 0 Then
        Player(FindPlayer(Trim$(txtFounder.Text))).Guild = scrlGuild.Value
    End If
    Unload Me
End Sub

Private Sub scrlGuild_Change()
    lblGuild.Caption = STR$(scrlGuild.Value)
End Sub
