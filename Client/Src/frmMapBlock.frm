VERSION 5.00
Begin VB.Form frmMapBlock 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Block"
   ClientHeight    =   1845
   ClientLeft      =   5295
   ClientTop       =   4350
   ClientWidth     =   1725
   ControlBox      =   0   'False
   Icon            =   "frmMapBlock.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1845
   ScaleWidth      =   1725
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      Height          =   255
      Left            =   0
      TabIndex        =   7
      Top             =   1560
      Width           =   1695
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "Ok"
      Height          =   255
      Left            =   0
      TabIndex        =   6
      Top             =   1200
      Width           =   1695
   End
   Begin VB.CheckBox chkBlockType 
      Caption         =   "Check1"
      Height          =   255
      Index           =   2
      Left            =   1320
      TabIndex        =   5
      Top             =   840
      Width           =   255
   End
   Begin VB.CheckBox chkBlockType 
      Caption         =   "Check1"
      Height          =   255
      Index           =   1
      Left            =   1320
      TabIndex        =   4
      Top             =   480
      Width           =   255
   End
   Begin VB.CheckBox chkBlockType 
      Caption         =   "Check1"
      Height          =   255
      Index           =   0
      Left            =   1320
      TabIndex        =   3
      Top             =   120
      Width           =   255
   End
   Begin VB.Label lblBlockType 
      Caption         =   "Flight Block"
      Height          =   255
      Index           =   2
      Left            =   120
      TabIndex        =   2
      Top             =   840
      Width           =   975
   End
   Begin VB.Label lblBlockType 
      Caption         =   "NPC Block"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   1
      Top             =   480
      Width           =   975
   End
   Begin VB.Label lblBlockType 
      Caption         =   "Player Block"
      Height          =   255
      Index           =   0
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   975
   End
End
Attribute VB_Name = "frmMapBlock"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdOK_Click()
    ' Block Types: 0 = Player, 1 = NPC, 2 = Flight
    ' Data Values: 0 = Off, 1 = On
    ' Checkbox Values: 0 = Unchecked, 1 = Checked
    ' Simply save the checked value since it corresponds directly to the on off.
    EditorBlockPlayer = chkBlockType(0).Value
    EditorBlockNPC = chkBlockType(1).Value
    EditorBlockFlight = chkBlockType(2).Value
    Unload Me
End Sub
