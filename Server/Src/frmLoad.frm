VERSION 5.00
Begin VB.Form frmLoad 
   BorderStyle     =   0  'None
   Caption         =   "Playerworlds"
   ClientHeight    =   840
   ClientLeft      =   7215
   ClientTop       =   6975
   ClientWidth     =   4800
   ControlBox      =   0   'False
   Icon            =   "frmLoad.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture         =   "frmLoad.frx":030C
   ScaleHeight     =   840
   ScaleWidth      =   4800
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Label lblStatus 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   255
      Left            =   360
      TabIndex        =   0
      Top             =   315
      Width           =   4095
   End
End
Attribute VB_Name = "frmLoad"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()

    Me.Show
    DoEvents
    Call InitServer
End Sub

