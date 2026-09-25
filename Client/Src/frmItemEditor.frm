VERSION 5.00
Begin VB.Form frmItemEditor 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Item Editor"
   ClientHeight    =   4275
   ClientLeft      =   4890
   ClientTop       =   1935
   ClientWidth     =   5055
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
   Icon            =   "frmItemEditor.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   285
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   337
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame fraWarp 
      Caption         =   "Warp Data"
      Height          =   1455
      Left            =   120
      TabIndex        =   26
      Top             =   1920
      Visible         =   0   'False
      Width           =   4815
      Begin VB.HScrollBar scrlMapY 
         Height          =   375
         Left            =   2880
         Max             =   11
         TabIndex        =   34
         Top             =   960
         Width           =   1335
      End
      Begin VB.HScrollBar scrlMapX 
         Height          =   375
         Left            =   480
         Max             =   15
         TabIndex        =   31
         Top             =   960
         Width           =   1335
      End
      Begin VB.TextBox txtMap 
         Height          =   390
         Left            =   960
         TabIndex        =   30
         Top             =   360
         Width           =   2895
      End
      Begin VB.Label lblMapY 
         Alignment       =   1  'Right Justify
         Caption         =   "1"
         Height          =   375
         Left            =   3840
         TabIndex        =   33
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
         TabIndex        =   32
         Top             =   960
         Width           =   735
      End
      Begin VB.Label lblmapX 
         Alignment       =   1  'Right Justify
         Caption         =   "1"
         Height          =   375
         Left            =   1440
         TabIndex        =   29
         Top             =   960
         Width           =   855
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
         TabIndex        =   28
         Top             =   960
         Width           =   735
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
         TabIndex        =   27
         Top             =   360
         Width           =   1095
      End
   End
   Begin VB.Frame fraSpell 
      Caption         =   "Spell Data"
      Height          =   1455
      Left            =   120
      TabIndex        =   20
      Top             =   1920
      Visible         =   0   'False
      Width           =   4815
      Begin VB.HScrollBar scrlSpell 
         Height          =   375
         Left            =   960
         Max             =   500
         TabIndex        =   21
         Top             =   840
         Value           =   1
         Width           =   2895
      End
      Begin VB.Label lblSpellName 
         Height          =   375
         Left            =   1320
         TabIndex        =   25
         Top             =   360
         Width           =   3375
      End
      Begin VB.Label Label6 
         Caption         =   "Name"
         Height          =   375
         Left            =   120
         TabIndex        =   24
         Top             =   360
         Width           =   1095
      End
      Begin VB.Label Label7 
         Caption         =   "Num"
         Height          =   375
         Left            =   120
         TabIndex        =   23
         Top             =   840
         Width           =   735
      End
      Begin VB.Label lblSpell 
         Alignment       =   1  'Right Justify
         Caption         =   "1"
         Height          =   375
         Left            =   3840
         TabIndex        =   22
         Top             =   840
         Width           =   855
      End
   End
   Begin VB.Timer tmrPic 
      Interval        =   50
      Left            =   0
      Top             =   0
   End
   Begin VB.PictureBox picPic 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   480
      Left            =   4440
      ScaleHeight     =   32
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   32
      TabIndex        =   19
      Top             =   600
      Width           =   480
   End
   Begin VB.HScrollBar scrlPic 
      Height          =   375
      Left            =   960
      Max             =   500
      TabIndex        =   17
      Top             =   600
      Width           =   2895
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      Height          =   495
      Left            =   2640
      TabIndex        =   15
      Top             =   3600
      Width           =   2295
   End
   Begin VB.CommandButton cmdOk 
      Caption         =   "Ok"
      Height          =   495
      Left            =   120
      TabIndex        =   14
      Top             =   3600
      Width           =   2295
   End
   Begin VB.Frame fraVitals 
      Caption         =   "Vitals Data"
      Height          =   1455
      Left            =   120
      TabIndex        =   10
      Top             =   1920
      Visible         =   0   'False
      Width           =   4815
      Begin VB.HScrollBar scrlVitalMod 
         Height          =   375
         Left            =   1320
         Max             =   255
         TabIndex        =   12
         Top             =   360
         Value           =   1
         Width           =   2895
      End
      Begin VB.Label lblVitalMod 
         Alignment       =   1  'Right Justify
         Caption         =   "1"
         Height          =   375
         Left            =   4200
         TabIndex        =   13
         Top             =   360
         Width           =   495
      End
      Begin VB.Label Label4 
         Caption         =   "Vital Mod"
         Height          =   375
         Left            =   120
         TabIndex        =   11
         Top             =   360
         Width           =   1095
      End
   End
   Begin VB.Frame fraEquipment 
      Caption         =   "Equipment Data"
      Height          =   1455
      Left            =   120
      TabIndex        =   3
      Top             =   1920
      Visible         =   0   'False
      Width           =   4815
      Begin VB.HScrollBar scrlStrength 
         Height          =   375
         Left            =   1320
         Max             =   255
         TabIndex        =   8
         Top             =   960
         Value           =   1
         Width           =   2895
      End
      Begin VB.HScrollBar scrlDurability 
         Height          =   375
         Left            =   1320
         Max             =   255
         TabIndex        =   6
         Top             =   480
         Value           =   1
         Width           =   2895
      End
      Begin VB.Label lblStrength 
         Alignment       =   1  'Right Justify
         Caption         =   "1"
         Height          =   375
         Left            =   4200
         TabIndex        =   9
         Top             =   960
         Width           =   495
      End
      Begin VB.Label lblDurability 
         Alignment       =   1  'Right Justify
         Caption         =   "1"
         Height          =   375
         Left            =   4200
         TabIndex        =   7
         Top             =   480
         Width           =   495
      End
      Begin VB.Label Label3 
         Caption         =   "Strength"
         Height          =   375
         Left            =   120
         TabIndex        =   5
         Top             =   960
         Width           =   975
      End
      Begin VB.Label Label2 
         Caption         =   "Durability"
         Height          =   375
         Left            =   120
         TabIndex        =   4
         Top             =   480
         Width           =   1095
      End
   End
   Begin VB.TextBox txtName 
      Height          =   390
      Left            =   960
      TabIndex        =   1
      Top             =   120
      Width           =   3975
   End
   Begin VB.ComboBox cmbType 
      Height          =   390
      ItemData        =   "frmItemEditor.frx":030C
      Left            =   120
      List            =   "frmItemEditor.frx":033D
      Style           =   2  'Dropdown List
      TabIndex        =   0
      Top             =   1320
      Width           =   4815
   End
   Begin VB.Label lblPic 
      Alignment       =   1  'Right Justify
      Caption         =   "0"
      Height          =   375
      Left            =   3840
      TabIndex        =   18
      Top             =   600
      Width           =   495
   End
   Begin VB.Label Label5 
      Caption         =   "Pic"
      Height          =   375
      Left            =   120
      TabIndex        =   16
      Top             =   600
      Width           =   855
   End
   Begin VB.Label Label1 
      Caption         =   "Name"
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   120
      Width           =   735
   End
End
Attribute VB_Name = "frmItemEditor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdOK_Click()
    Call ItemEditorOk
End Sub

Private Sub cmdCancel_Click()
    Call ItemEditorCancel
End Sub

Private Sub cmbType_Click()
    If (cmbType.ListIndex >= ITEM_TYPE_WEAPON) And (cmbType.ListIndex <= ITEM_TYPE_SHIELD) Then
        fraEquipment.Visible = True
    Else
        fraEquipment.Visible = False
    End If

    If (cmbType.ListIndex >= ITEM_TYPE_POTIONADDHP) And (cmbType.ListIndex <= ITEM_TYPE_POTIONSUBSP) Then
        fraVitals.Visible = True
    Else
        fraVitals.Visible = False
    End If

    If (cmbType.ListIndex = ITEM_TYPE_SPELL) Then
        fraSpell.Visible = True
    Else
        fraSpell.Visible = False
    End If

    If (cmbType.ListIndex = ITEM_TYPE_WARP) Then
        fraWarp.Visible = True
    Else
        fraWarp.Visible = False
    End If
End Sub

Private Sub scrlMapX_Change()
    lblMapX.Caption = STR(scrlMapX.Value)
End Sub

Private Sub scrlMapY_Change()
    lblMapY.Caption = STR(scrlMapY.Value)
End Sub

Private Sub scrlPic_Change()
    lblPic.Caption = STR(scrlPic.Value)
End Sub

Private Sub scrlVitalMod_Change()
    lblVitalMod.Caption = STR(scrlVitalMod.Value)
End Sub

Private Sub scrlVitalAdd_Change()
End Sub

Private Sub scrlDurability_Change()
    lblDurability.Caption = STR(scrlDurability.Value)
End Sub

Private Sub scrlStrength_Change()
    lblStrength.Caption = STR(scrlStrength.Value)
End Sub

Private Sub scrlSpell_Change()
    If scrlSpell.Value > 0 Then
        lblSpellName.Caption = Trim$(Spell(scrlSpell.Value).name)
        lblSpell.Caption = STR(scrlSpell.Value)
    ElseIf scrlSpell.Value = 0 Then
        lblSpellName.Caption = "Select a Spell"
        lblSpell.Caption = STR(scrlSpell.Value)
    End If
End Sub

Private Sub tmrPic_Timer()
    Call ItemEditorBltItem
End Sub

Private Sub txtMap_Change()
    If Val(txtMap.Text) <= 0 Or Val(txtMap.Text) > MAX_MAPS Then
        txtMap.Text = "1"
    End If
End Sub
