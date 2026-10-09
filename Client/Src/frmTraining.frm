VERSION 5.00
Begin VB.Form frmTraining 
   BackColor       =   &H00000000&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Training"
   ClientHeight    =   5550
   ClientLeft      =   11235
   ClientTop       =   2445
   ClientWidth     =   3900
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
   Icon            =   "frmTraining.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture         =   "frmTraining.frx":030C
   ScaleHeight     =   5550
   ScaleWidth      =   3900
   ShowInTaskbar   =   0   'False
   Begin VB.ComboBox cmbStat 
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   330
      ItemData        =   "frmTraining.frx":46AA8
      Left            =   600
      List            =   "frmTraining.frx":46AB8
      Style           =   2  'Dropdown List
      TabIndex        =   0
      Top             =   3360
      Width           =   2775
   End
   Begin VB.Label picCancel 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   2400
      TabIndex        =   2
      Top             =   5040
      Width           =   1095
   End
   Begin VB.Label picTrain 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   360
      TabIndex        =   1
      Top             =   5040
      Width           =   735
   End
End
Attribute VB_Name = "frmTraining"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
    cmbStat.ListIndex = 0
End Sub

Private Sub picTrain_Click()
    Call SendData("usestatpoint" & SEP_CHAR & cmbStat.ListIndex & SEP_CHAR & END_CHAR)
End Sub

Private Sub picCancel_Click()
    Unload Me
End Sub

