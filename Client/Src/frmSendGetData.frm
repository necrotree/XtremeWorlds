VERSION 5.00
Begin VB.Form frmSendGetData
   ScaleMode = 3 
   BackColor       =   &H00000000&
   BorderStyle     =   0  'None
   Caption         =   "Playerworlds"
   ClientHeight    =   960
   ClientLeft      =   5805
   ClientTop       =   5445
   ClientWidth     =   5040
   ControlBox      =   0   'False
   Icon            =   "frmSendGetData.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture = "frmSendGetData.frx":D190
   ScaleHeight     =   64
   ScaleWidth      =   336
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Label lblStatus 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   600
      Left            =   225
      TabIndex        =   0
      Top             =   195
      Width           =   4590
   End
End
Attribute VB_Name = "frmSendGetData"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_KeyPress(KeyAscii As Integer)
    If (KeyAscii = vbKeyEscape) Then
        Call GameDestroy
        End
    End If
End Sub

Private Sub Form_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call MoveForm(Me)
End Sub
