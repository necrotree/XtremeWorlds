VERSION 5.00
Begin VB.Form frmCredits 
   BackColor       =   &H00000000&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Crystalion II :: Credits"
   ClientHeight    =   4560
   ClientLeft      =   2865
   ClientTop       =   2340
   ClientWidth     =   8190
   ControlBox      =   0   'False
   Icon            =   "frmCredits.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture         =   "frmCredits.frx":030C
   ScaleHeight     =   4560
   ScaleWidth      =   8190
   StartUpPosition =   2  'CenterScreen
   Begin VB.Label picCancel 
      BackStyle       =   0  'Transparent
      Height          =   495
      Left            =   4320
      TabIndex        =   0
      Top             =   3960
      Width           =   2775
   End
End
Attribute VB_Name = "frmCredits"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub picCancel_Click()
    frmMainMenu.Visible = True
    frmCredits.Visible = False
End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then Call picCancel_Click
    KeyAscii = 0
End Sub
