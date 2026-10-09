VERSION 5.00
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "tabctl32.ocx"
Begin VB.Form frmMapNudge 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Nudge"
   ClientHeight    =   2055
   ClientLeft      =   8265
   ClientTop       =   5730
   ClientWidth     =   3615
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   6.75
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   137
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   241
   ShowInTaskbar   =   0   'False
   Begin TabDlg.SSTab SSTab1 
      Height          =   1815
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   3375
      _ExtentX        =   5953
      _ExtentY        =   3201
      _Version        =   393216
      Tabs            =   1
      TabHeight       =   370
      TabCaption(0)   =   "Nudge"
      TabPicture(0)   =   "frmNudge.frx":0000
      Tab(0).ControlEnabled=   -1  'True
      Tab(0).Control(0)=   "Frame1"
      Tab(0).Control(0).Enabled=   0   'False
      Tab(0).Control(1)=   "Command1"
      Tab(0).Control(1).Enabled=   0   'False
      Tab(0).Control(2)=   "Command2"
      Tab(0).Control(2).Enabled=   0   'False
      Tab(0).ControlCount=   3
      Begin VB.CommandButton Command2 
         Caption         =   "Cancel"
         Height          =   375
         Left            =   1680
         TabIndex        =   6
         Top             =   1320
         Width           =   1575
      End
      Begin VB.CommandButton Command1 
         Caption         =   "Ok"
         Height          =   375
         Left            =   120
         TabIndex        =   5
         Top             =   1320
         Width           =   1575
      End
      Begin VB.Frame Frame1 
         Caption         =   "Nudge"
         Height          =   855
         Left            =   120
         TabIndex        =   1
         Top             =   360
         Width           =   3135
         Begin VB.HScrollBar scrlDir 
            Height          =   255
            Left            =   840
            Max             =   3
            TabIndex        =   3
            Top             =   240
            Width           =   2175
         End
         Begin VB.Label lblDir 
            Alignment       =   1  'Right Justify
            Caption         =   "Up"
            Height          =   240
            Left            =   1680
            TabIndex        =   4
            Top             =   525
            Width           =   1335
         End
         Begin VB.Label Label1 
            Caption         =   "Direction:"
            Height          =   255
            Left            =   120
            TabIndex        =   2
            Top             =   285
            Width           =   2775
         End
      End
   End
End
Attribute VB_Name = "frmMapNudge"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
    EditorNudge = scrlDir.Value
End Sub

Private Sub scrlDir_Change()
    Select Case scrlDir.Value
        Case 0
            lblDir.Caption = "Up"
        Case 1
            lblDir.Caption = "Down"
        Case 2
            lblDir.Caption = "Left"
        Case 3
            lblDir.Caption = "Right"
    End Select
End Sub
