VERSION 5.00
Begin VB.Form frmMapReport 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Map Report"
   ClientHeight    =   3090
   ClientLeft      =   10860
   ClientTop       =   7575
   ClientWidth     =   3885
   ControlBox      =   0   'False
   Icon            =   "frmMapReport.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3090
   ScaleWidth      =   3885
   ShowInTaskbar   =   0   'False
   Visible         =   0   'False
   Begin VB.CommandButton cmdExit 
      Caption         =   "&Close"
      Height          =   375
      Left            =   2400
      TabIndex        =   2
      Top             =   2640
      Width           =   1335
   End
   Begin VB.CommandButton cmdWarp 
      Caption         =   "&Warp"
      Height          =   375
      Left            =   120
      TabIndex        =   1
      Top             =   2640
      Width           =   1455
   End
   Begin VB.ListBox lstMapReport 
      Height          =   2400
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   3615
   End
End
Attribute VB_Name = "frmMapReport"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdExit_Click()
    Me.Visible = False
End Sub

Private Sub cmdWarp_Click()
    If lstMapReport.ListIndex > -1 And lstMapReport.ListIndex <= MAX_MAPS Then
        Call WarpTo(lstMapReport.ListIndex + 1)
    End If
End Sub

Private Sub lstMapReport_DblClick()
    If lstMapReport.ListIndex > -1 And lstMapReport.ListIndex <= MAX_MAPS Then
        Call WarpTo(lstMapReport.ListIndex + 1)
    End If
End Sub
