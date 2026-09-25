VERSION 5.00
Begin VB.Form frmSetSprite 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Sprite Change"
   ClientHeight    =   1845
   ClientLeft      =   7425
   ClientTop       =   6720
   ClientWidth     =   4350
   ControlBox      =   0   'False
   Icon            =   "frmSetSprite.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1845
   ScaleWidth      =   4350
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdCancel 
      Caption         =   "&Cancel"
      Height          =   375
      Left            =   2640
      TabIndex        =   5
      Top             =   1320
      Width           =   1095
   End
   Begin VB.CommandButton cmdSend 
      Caption         =   "&Send"
      Height          =   375
      Left            =   600
      TabIndex        =   4
      Top             =   1320
      Width           =   1095
   End
   Begin VB.Timer tmrSprite 
      Interval        =   50
      Left            =   3840
      Top             =   0
   End
   Begin VB.HScrollBar scrlSprite 
      Height          =   375
      Left            =   840
      Max             =   600
      TabIndex        =   1
      Top             =   720
      Width           =   2895
   End
   Begin VB.PictureBox picSprite 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H80000006&
      ForeColor       =   &H80000008&
      Height          =   495
      Left            =   120
      ScaleHeight     =   31
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   31
      TabIndex        =   0
      Top             =   120
      Width           =   495
   End
   Begin VB.Label lblSpriteNum 
      Alignment       =   1  'Right Justify
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   3720
      TabIndex        =   3
      Top             =   720
      Width           =   495
   End
   Begin VB.Label Label5 
      Caption         =   "Sprite"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   720
      Width           =   735
   End
End
Attribute VB_Name = "frmSetSprite"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdSend_Click()
    SpriteNum = scrlSprite.Value
    Unload Me
End Sub

Private Sub tmrsprite_Timer()
    Call SpriteChangeBltSprite
End Sub

Private Sub scrlSprite_Change()
    lblSpriteNum.Caption = STR(scrlSprite.Value)
End Sub
