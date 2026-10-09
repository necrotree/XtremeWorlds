VERSION 5.00
Begin VB.Form frmSignChoose 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Sign Chooser"
   ClientHeight    =   1140
   ClientLeft      =   5550
   ClientTop       =   6690
   ClientWidth     =   3930
   ControlBox      =   0   'False
   Icon            =   "frmSignChoose.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1140
   ScaleWidth      =   3930
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   2400
      TabIndex        =   3
      Top             =   720
      Width           =   1215
   End
   Begin VB.CommandButton cmdOk 
      Caption         =   "OK"
      Height          =   375
      Left            =   360
      TabIndex        =   2
      Top             =   720
      Width           =   1215
   End
   Begin VB.HScrollBar scrlSignNum 
      Height          =   255
      LargeChange     =   5
      Left            =   120
      Max             =   500
      Min             =   1
      TabIndex        =   0
      Top             =   360
      Value           =   1
      Width           =   3135
   End
   Begin VB.Label lblSignName 
      Caption         =   "Name"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   120
      Width           =   3135
   End
   Begin VB.Label lblSignNum 
      Alignment       =   1  'Right Justify
      Caption         =   "1"
      ForeColor       =   &H000000FF&
      Height          =   255
      Left            =   3360
      TabIndex        =   1
      Top             =   360
      Width           =   495
   End
End
Attribute VB_Name = "frmSignChoose"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdOK_Click()
    SignNum = scrlSignNum.Value
    Unload Me
End Sub

Private Sub Form_Load()
    scrlSignNum.max = MAX_SIGNS
End Sub

Private Sub scrlSignNum_Change()
    lblSignNum.Caption = STR$(scrlSignNum.Value)
    lblSignName.Caption = Trim$(Sign(scrlSignNum.Value).name)
End Sub
