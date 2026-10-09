VERSION 5.00
Begin VB.Form frmMapDmg 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Map Damage"
   ClientHeight    =   3015
   ClientLeft      =   7590
   ClientTop       =   2415
   ClientWidth     =   4890
   ControlBox      =   0   'False
   Icon            =   "frmMapDmg.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3015
   ScaleWidth      =   4890
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.HScrollBar scrlItem 
      Height          =   255
      Left            =   600
      Max             =   500
      Min             =   1
      TabIndex        =   11
      Top             =   480
      Value           =   1
      Width           =   3255
   End
   Begin VB.CommandButton cmdOk 
      Caption         =   "Ok"
      Height          =   495
      Left            =   120
      TabIndex        =   10
      Top             =   2400
      Width           =   2295
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      Height          =   495
      Left            =   2520
      TabIndex        =   9
      Top             =   2400
      Width           =   2295
   End
   Begin VB.HScrollBar scrlDamage 
      Height          =   255
      Left            =   720
      Min             =   1
      TabIndex        =   5
      Top             =   1440
      Value           =   1
      Width           =   3255
   End
   Begin VB.Label lblDamage 
      Alignment       =   1  'Right Justify
      Caption         =   "0"
      Height          =   255
      Left            =   3960
      TabIndex        =   8
      Top             =   1440
      Width           =   855
   End
   Begin VB.Label Label5 
      Caption         =   "This is the ammount of damage that will be dealt if the player does not have the above item equiped!"
      ForeColor       =   &H000000FF&
      Height          =   495
      Left            =   120
      TabIndex        =   7
      Top             =   1800
      Width           =   4815
   End
   Begin VB.Label Label4 
      Caption         =   "Damage"
      Height          =   255
      Left            =   0
      TabIndex        =   6
      Top             =   1440
      Width           =   735
   End
   Begin VB.Label Label3 
      Caption         =   "This item will make all of the damage void if the player has it equiped!"
      ForeColor       =   &H000000FF&
      Height          =   495
      Left            =   120
      TabIndex        =   4
      Top             =   840
      Width           =   4815
   End
   Begin VB.Label Label1 
      Caption         =   "Item"
      Height          =   255
      Left            =   0
      TabIndex        =   3
      Top             =   120
      Width           =   615
   End
   Begin VB.Label lblName 
      BackStyle       =   0  'Transparent
      Height          =   375
      Left            =   720
      TabIndex        =   2
      Top             =   120
      Width           =   4095
   End
   Begin VB.Label lblItem 
      Alignment       =   1  'Right Justify
      Caption         =   "0"
      Height          =   255
      Left            =   3960
      TabIndex        =   1
      Top             =   480
      Width           =   855
   End
   Begin VB.Label Label2 
      Caption         =   "Item"
      Height          =   255
      Left            =   0
      TabIndex        =   0
      Top             =   480
      Width           =   615
   End
End
Attribute VB_Name = "frmMapDmg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdOK_Click()
    KillValue = scrlDamage.Value
    KillVoidItem = scrlItem.Value
    Unload Me
End Sub

Private Sub scrlDamage_Change()
    lblDamage.Caption = Trim$(scrlDamage.Value)
End Sub

Private Sub scrlItem_Change()
    lblItem.Caption = STR$(scrlItem.Value)
    lblName.Caption = Trim$(Item(scrlItem.Value).name)
End Sub

