VERSION 5.00
Begin VB.Form frmMapSpawnNPC 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "NPC Spawn"
   ClientHeight    =   3060
   ClientLeft      =   4920
   ClientTop       =   4500
   ClientWidth     =   4590
   ControlBox      =   0   'False
   Icon            =   "frmMapSpawnNPC.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3060
   ScaleWidth      =   4590
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CheckBox chkStationary 
      Caption         =   "Stationary"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   2040
      Width           =   1095
   End
   Begin VB.ComboBox cmbNPCDir 
      Height          =   315
      ItemData        =   "frmMapSpawnNPC.frx":030C
      Left            =   2400
      List            =   "frmMapSpawnNPC.frx":031C
      TabIndex        =   3
      Text            =   "NPC Direction"
      Top             =   2040
      Width           =   2055
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      Height          =   495
      Left            =   2400
      TabIndex        =   2
      Top             =   2400
      Width           =   2055
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Height          =   495
      Left            =   120
      TabIndex        =   1
      Top             =   2400
      Width           =   2055
   End
   Begin VB.ListBox lstNPC 
      Height          =   1815
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   4335
   End
End
Attribute VB_Name = "frmMapSpawnNPC"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdOK_Click()
    SpawnNpcNum = lstNPC.ListIndex + 1
    SpawnNpcDir = cmbNPCDir.ListIndex
    SpawnNpcStill = chkStationary.Value
    Unload Me
End Sub

Private Sub Form_Load()
    Dim n As Long

    For n = 1 To MAX_MAP_NPCS
        If Map.Npc(n) > 0 Then
            lstNPC.AddItem n & ": " & Npc(Map.Npc(n)).name
        Else
            lstNPC.AddItem n & ": No Npc"
        End If
    Next n
End Sub

