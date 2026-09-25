VERSION 5.00
Begin VB.Form frmSpellEditor 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Spell Editor"
   ClientHeight    =   7575
   ClientLeft      =   5400
   ClientTop       =   2280
   ClientWidth     =   4980
   ControlBox      =   0   'False
   DrawMode        =   14  'Copy Pen
   BeginProperty Font 
      Name            =   "Arial"
      Size            =   12
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "frmSpellEditor.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7575
   ScaleWidth      =   4980
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox picSpells 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   1455
      Left            =   5640
      ScaleHeight     =   1425
      ScaleWidth      =   1305
      TabIndex        =   36
      Top             =   120
      Width           =   1335
   End
   Begin VB.Timer tmrSpellAnim 
      Interval        =   50
      Left            =   120
      Top             =   6960
   End
   Begin VB.CommandButton cmdOk 
      Caption         =   "Ok"
      Height          =   495
      Left            =   120
      TabIndex        =   8
      Top             =   6120
      Width           =   2295
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      Height          =   495
      Left            =   2640
      TabIndex        =   7
      Top             =   6120
      Width           =   2295
   End
   Begin VB.Frame fraWarp 
      Caption         =   "Warp"
      Height          =   1455
      Left            =   120
      TabIndex        =   24
      Top             =   3000
      Visible         =   0   'False
      Width           =   4815
      Begin VB.TextBox txtMap 
         Height          =   390
         Left            =   960
         TabIndex        =   27
         Top             =   360
         Width           =   2895
      End
      Begin VB.HScrollBar scrlMapX 
         Height          =   375
         Left            =   480
         Max             =   15
         TabIndex        =   26
         Top             =   960
         Width           =   1335
      End
      Begin VB.HScrollBar scrlMapY 
         Height          =   375
         Left            =   2880
         Max             =   11
         TabIndex        =   25
         Top             =   960
         Width           =   1335
      End
      Begin VB.Label Label9 
         Caption         =   "Map"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   32
         Top             =   360
         Width           =   1095
      End
      Begin VB.Label Label10 
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   31
         Top             =   960
         Width           =   735
      End
      Begin VB.Label lblmapX 
         Alignment       =   1  'Right Justify
         Caption         =   "1"
         Height          =   375
         Left            =   1440
         TabIndex        =   30
         Top             =   960
         Width           =   855
      End
      Begin VB.Label Label8 
         Caption         =   "Y"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   2520
         TabIndex        =   29
         Top             =   960
         Width           =   735
      End
      Begin VB.Label lblMapY 
         Alignment       =   1  'Right Justify
         Caption         =   "1"
         Height          =   375
         Left            =   3840
         TabIndex        =   28
         Top             =   960
         Width           =   855
      End
   End
   Begin VB.HScrollBar scrlMP 
      Height          =   375
      Left            =   960
      Max             =   255
      Min             =   1
      TabIndex        =   21
      Top             =   1800
      Value           =   1
      Width           =   3495
   End
   Begin VB.Frame fraMisc 
      Caption         =   "Animation"
      Height          =   1455
      Left            =   120
      TabIndex        =   20
      Top             =   4560
      Width           =   4815
      Begin VB.PictureBox picAnim 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         ForeColor       =   &H80000008&
         Height          =   495
         Left            =   240
         ScaleHeight     =   32
         ScaleMode       =   0  'User
         ScaleWidth      =   30.061
         TabIndex        =   35
         Top             =   720
         Width           =   495
      End
      Begin VB.HScrollBar scrlAnim 
         Height          =   255
         Left            =   120
         Max             =   100
         TabIndex        =   33
         Top             =   360
         Width           =   3615
      End
      Begin VB.Label lblAnim 
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   3960
         TabIndex        =   34
         Top             =   360
         Width           =   495
      End
   End
   Begin VB.HScrollBar scrlLevelReq 
      Height          =   375
      Left            =   960
      Max             =   255
      Min             =   1
      TabIndex        =   18
      Top             =   1320
      Value           =   1
      Width           =   3495
   End
   Begin VB.ComboBox cmbClassReq 
      Height          =   390
      ItemData        =   "frmSpellEditor.frx":030C
      Left            =   120
      List            =   "frmSpellEditor.frx":030E
      Style           =   2  'Dropdown List
      TabIndex        =   16
      Top             =   720
      Width           =   4815
   End
   Begin VB.Frame fraGiveItem 
      Caption         =   "Give Item"
      Height          =   1455
      Left            =   120
      TabIndex        =   9
      Top             =   3000
      Visible         =   0   'False
      Width           =   4815
      Begin VB.HScrollBar scrlItemValue 
         Height          =   375
         Left            =   960
         TabIndex        =   14
         Top             =   840
         Width           =   2895
      End
      Begin VB.HScrollBar scrlItemNum 
         Height          =   375
         Left            =   960
         Max             =   500
         Min             =   1
         TabIndex        =   10
         Top             =   360
         Value           =   1
         Width           =   2895
      End
      Begin VB.Label lblItemValue 
         Alignment       =   1  'Right Justify
         Caption         =   "0"
         Height          =   375
         Left            =   3840
         TabIndex        =   15
         Top             =   840
         Width           =   855
      End
      Begin VB.Label Label5 
         Caption         =   "Value"
         Height          =   375
         Left            =   120
         TabIndex        =   13
         Top             =   840
         Width           =   735
      End
      Begin VB.Label lblItemNum 
         Alignment       =   1  'Right Justify
         Caption         =   "1"
         Height          =   375
         Left            =   3840
         TabIndex        =   12
         Top             =   360
         Width           =   855
      End
      Begin VB.Label Label2 
         Caption         =   "Item"
         Height          =   375
         Left            =   120
         TabIndex        =   11
         Top             =   360
         Width           =   735
      End
   End
   Begin VB.ComboBox cmbType 
      Height          =   390
      ItemData        =   "frmSpellEditor.frx":0310
      Left            =   120
      List            =   "frmSpellEditor.frx":032C
      Style           =   2  'Dropdown List
      TabIndex        =   6
      Top             =   2400
      Width           =   4815
   End
   Begin VB.Frame fraVitals 
      Caption         =   "Vitals Data"
      Height          =   1455
      Left            =   120
      TabIndex        =   2
      Top             =   3000
      Visible         =   0   'False
      Width           =   4815
      Begin VB.HScrollBar scrlVitalMod 
         Height          =   375
         Left            =   1320
         Max             =   255
         TabIndex        =   3
         Top             =   360
         Value           =   1
         Width           =   2895
      End
      Begin VB.Label Label4 
         Caption         =   "Vital Mod"
         Height          =   375
         Left            =   120
         TabIndex        =   5
         Top             =   360
         Width           =   1095
      End
      Begin VB.Label lblVitalMod 
         Alignment       =   1  'Right Justify
         Caption         =   "1"
         Height          =   375
         Left            =   4200
         TabIndex        =   4
         Top             =   360
         Width           =   495
      End
   End
   Begin VB.TextBox txtName 
      Height          =   390
      Left            =   960
      TabIndex        =   0
      Top             =   120
      Width           =   3975
   End
   Begin VB.Label Label7 
      Caption         =   "MP"
      Height          =   375
      Left            =   120
      TabIndex        =   23
      Top             =   1800
      Width           =   735
   End
   Begin VB.Label lblMP 
      Alignment       =   1  'Right Justify
      Caption         =   "1"
      Height          =   375
      Left            =   4440
      TabIndex        =   22
      Top             =   1800
      Width           =   495
   End
   Begin VB.Label lblLevelReq 
      Alignment       =   1  'Right Justify
      Caption         =   "1"
      Height          =   375
      Left            =   4440
      TabIndex        =   19
      Top             =   1320
      Width           =   495
   End
   Begin VB.Label Label3 
      Caption         =   "Level"
      Height          =   375
      Left            =   120
      TabIndex        =   17
      Top             =   1320
      Width           =   735
   End
   Begin VB.Label Label1 
      Caption         =   "Name"
      Height          =   375
      Left            =   120
      TabIndex        =   1
      Top             =   120
      Width           =   735
   End
End
Attribute VB_Name = "frmSpellEditor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Public i As Byte


Private Sub cmbType_Click()
    If cmbType.ListIndex <> SPELL_TYPE_GIVEITEM And cmbType.ListIndex <> SPELL_TYPE_WARP Then
        fraVitals.Visible = True
        fraGiveItem.Visible = False
        fraWarp.Visible = False
    ElseIf cmbType.ListIndex = SPELL_TYPE_GIVEITEM Then
        fraVitals.Visible = False
        fraGiveItem.Visible = True
        fraWarp.Visible = False
    ElseIf cmbType.ListIndex = SPELL_TYPE_WARP Then
        fraVitals.Visible = False
        fraGiveItem.Visible = False
        fraWarp.Visible = True
    End If
End Sub

Private Sub Label6_Click()

End Sub

Private Sub scrlAnim_Change()
    lblAnim.Caption = STR(scrlAnim.Value)
End Sub

Private Sub scrlItemNum_Change()
    fraGiveItem.Caption = "Give Item " & Trim$(Item(scrlItemNum.Value).name)
    lblItemNum.Caption = STR(scrlItemNum.Value)
End Sub

Private Sub scrlItemValue_Change()
    lblItemValue.Caption = STR(scrlItemValue.Value)
End Sub

Private Sub scrlLevelReq_Change()
    lblLevelReq.Caption = STR(scrlLevelReq.Value)
End Sub

Private Sub scrlMapX_Change()
    lblMapX.Caption = STR(scrlMapX.Value)
End Sub

Private Sub scrlMapY_Change()
    lblMapY.Caption = STR(scrlMapY.Value)
End Sub

Private Sub scrlMP_Change()
    lblMP.Caption = STR(scrlMP.Value)
End Sub

Private Sub scrlVitalMod_Change()
    lblVitalMod.Caption = STR(scrlVitalMod.Value)
End Sub

Private Sub cmdOK_Click()
    Call SpellEditorOk
End Sub

Private Sub cmdCancel_Click()
    Call SpellEditorCancel
End Sub

Private Sub tmrSpellAnim_Timer()

    If i > 13 Then i = 0
    i = i + 1
    Call SpellEditorBltAnim(i)
End Sub
