VERSION 5.00
Begin VB.Form frmChars 
   BackColor       =   &H00000000&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Crystalion II :: Characters"
   ClientHeight    =   4560
   ClientLeft      =   4080
   ClientTop       =   5055
   ClientWidth     =   8190
   ControlBox      =   0   'False
   Icon            =   "frmChars.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture         =   "frmChars.frx":030C
   ScaleHeight     =   4560
   ScaleWidth      =   8190
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox picPic 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00800000&
      ForeColor       =   &H80000008&
      Height          =   495
      Left            =   5400
      ScaleHeight     =   465
      ScaleWidth      =   465
      TabIndex        =   5
      Top             =   1920
      Width           =   495
   End
   Begin VB.ListBox lstChars 
      Appearance      =   0  'Flat
      BackColor       =   &H00800000&
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   870
      ItemData        =   "frmChars.frx":28971
      Left            =   4200
      List            =   "frmChars.frx":28973
      TabIndex        =   0
      Top             =   960
      Width           =   2895
   End
   Begin VB.Label picCancel 
      BackStyle       =   0  'Transparent
      Height          =   495
      Left            =   4320
      TabIndex        =   4
      Top             =   3960
      Width           =   2775
   End
   Begin VB.Label picDelChar 
      BackStyle       =   0  'Transparent
      Height          =   375
      Left            =   4320
      TabIndex        =   3
      Top             =   3600
      Width           =   2775
   End
   Begin VB.Label picNewChar 
      BackStyle       =   0  'Transparent
      Height          =   375
      Left            =   4320
      TabIndex        =   2
      Top             =   3120
      Width           =   2775
   End
   Begin VB.Label picUseChar 
      BackStyle       =   0  'Transparent
      Height          =   375
      Left            =   4320
      TabIndex        =   1
      Top             =   2640
      Width           =   2775
   End
End
Attribute VB_Name = "frmChars"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'Private Sub lstChars_Click()
'    Call BltPlayerCharSprite
'End Sub

Private Sub picCancel_Click()
    Call TcpDestroy
    frmLogin.Visible = True
    Me.Visible = False
End Sub

Private Sub picNewChar_Click()
    Call MenuState(MENU_STATE_NEWCHAR)
End Sub

Private Sub picUseChar_Click()
Call StopMidi
    Call MenuState(MENU_STATE_USECHAR)
End Sub

Private Sub picDelChar_Click()
Dim Value As Long

    Value = MsgBox("Are you sure you wish to delete this character?", vbYesNo, GAME_NAME)
    If Value = vbYes Then
        Call MenuState(MENU_STATE_DELCHAR)
    End If
End Sub

