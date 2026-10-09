VERSION 5.00
Object = "{3B7C8863-D78F-101B-B9B5-04021C009402}#1.2#0"; "richtx32.ocx"
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "tabctl32.ocx"
Begin VB.Form frmBugReport 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Bug Report"
   ClientHeight    =   5280
   ClientLeft      =   3540
   ClientTop       =   2790
   ClientWidth     =   5055
   ControlBox      =   0   'False
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   6.75
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "frmBugReport.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   352
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   337
   ShowInTaskbar   =   0   'False
   Begin TabDlg.SSTab SSTab1 
      Height          =   5055
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   4815
      _ExtentX        =   8493
      _ExtentY        =   8916
      _Version        =   393216
      Tabs            =   1
      TabHeight       =   370
      TabCaption(0)   =   "Bug Report"
      TabPicture(0)   =   "frmBugReport.frx":030C
      Tab(0).ControlEnabled=   -1  'True
      Tab(0).Control(0)=   "Frame1"
      Tab(0).Control(0).Enabled=   0   'False
      Tab(0).ControlCount=   1
      Begin VB.Frame Frame1 
         Caption         =   "Bug Report"
         Height          =   4695
         Left            =   120
         TabIndex        =   1
         Top             =   240
         Width           =   4575
         Begin VB.PictureBox Picture1 
            BorderStyle     =   0  'None
            Height          =   4335
            Left            =   120
            ScaleHeight     =   4335
            ScaleWidth      =   4335
            TabIndex        =   2
            Top             =   240
            Width           =   4335
            Begin VB.PictureBox picOccurence 
               BorderStyle     =   0  'None
               Height          =   735
               Left            =   120
               ScaleHeight     =   735
               ScaleWidth      =   4335
               TabIndex        =   10
               Top             =   1200
               Width           =   4335
               Begin VB.OptionButton optOften 
                  Caption         =   "Often"
                  Height          =   255
                  Left            =   240
                  TabIndex        =   13
                  Top             =   240
                  Value           =   -1  'True
                  Width           =   735
               End
               Begin VB.OptionButton optSometimes 
                  Caption         =   "Sometimes"
                  Height          =   255
                  Left            =   1560
                  TabIndex        =   12
                  Top             =   240
                  Width           =   1095
               End
               Begin VB.OptionButton optOnce 
                  Caption         =   "Once"
                  Height          =   255
                  Left            =   3240
                  TabIndex        =   11
                  Top             =   240
                  Width           =   735
               End
               Begin VB.Label Label2 
                  Alignment       =   2  'Center
                  Caption         =   "How often does this bug occur?"
                  Height          =   255
                  Left            =   0
                  TabIndex        =   14
                  Top             =   0
                  Width           =   4455
               End
            End
            Begin VB.PictureBox picType 
               BorderStyle     =   0  'None
               Height          =   975
               Left            =   120
               ScaleHeight     =   975
               ScaleWidth      =   4335
               TabIndex        =   5
               Top             =   600
               Width           =   4335
               Begin VB.OptionButton optMapping 
                  Caption         =   "Mapping"
                  Height          =   255
                  Left            =   240
                  TabIndex        =   8
                  Top             =   240
                  Value           =   -1  'True
                  Width           =   975
               End
               Begin VB.OptionButton optProgramming 
                  Caption         =   "Programming"
                  Height          =   255
                  Left            =   1560
                  TabIndex        =   7
                  Top             =   240
                  Width           =   1335
               End
               Begin VB.OptionButton optOther 
                  Caption         =   "Other"
                  Height          =   255
                  Left            =   3240
                  TabIndex        =   6
                  Top             =   240
                  Width           =   855
               End
               Begin VB.Label Label5 
                  Alignment       =   2  'Center
                  Caption         =   "Type of bug:"
                  Height          =   195
                  Left            =   -120
                  TabIndex        =   9
                  Top             =   0
                  Width           =   4380
               End
            End
            Begin VB.CommandButton cmdCancel 
               Caption         =   "Cancel"
               Height          =   495
               Left            =   2280
               TabIndex        =   4
               Top             =   3720
               Width           =   1935
            End
            Begin VB.CommandButton cmdSend 
               Caption         =   "Send Report"
               Height          =   495
               Left            =   240
               TabIndex        =   3
               Top             =   3720
               Width           =   1935
            End
            Begin RichTextLib.RichTextBox txtBugReport 
               Height          =   1425
               Left            =   240
               TabIndex        =   15
               Top             =   2160
               Width           =   3930
               _ExtentX        =   6932
               _ExtentY        =   2514
               _Version        =   393217
               BackColor       =   16777215
               Enabled         =   -1  'True
               Appearance      =   0
               OLEDragMode     =   0
               OLEDropMode     =   0
               TextRTF         =   $"frmBugReport.frx":0328
            End
            Begin VB.Label Label1 
               Alignment       =   2  'Center
               Caption         =   $"frmBugReport.frx":03A3
               Height          =   615
               Left            =   0
               TabIndex        =   18
               Top             =   0
               Width           =   4335
            End
            Begin VB.Label Label3 
               Caption         =   "Describe the bug here:"
               Height          =   255
               Left            =   240
               TabIndex        =   17
               Top             =   1920
               Width           =   3975
            End
            Begin VB.Label Label4 
               Alignment       =   2  'Center
               Caption         =   "Can you repeat this bug?"
               Height          =   255
               Left            =   0
               TabIndex        =   16
               Top             =   2640
               Width           =   4455
            End
         End
      End
   End
End
Attribute VB_Name = "frmBugReport"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdSend_Click()
    Dim BugType As Byte
    Dim BugOccur As Byte
    Dim BugRepeat As Byte

    If optMapping.Value = True Then
        BugType = 1
    ElseIf optProgramming.Value = True Then
        BugType = 2
    ElseIf optOther.Value = True Then
        BugType = 3
    End If

    If optOften.Value = True Then
        BugOccur = 1
    ElseIf optSometimes.Value = True Then
        BugOccur = 2
    ElseIf optOnce.Value = True Then
        BugOccur = 3
    End If

    BugRepeat = 1

    If LenB(Trim$(txtBugReport.Text)) > 0 Then
        Call SendBugReport(Trim$(txtBugReport.Text), BugType, BugOccur, BugRepeat)
        txtBugReport.Text = vbNullString
        frmBugReport.Visible = False
    End If
End Sub

Private Sub Form_Load()
    Me.Caption = GAME_NAME & " : Bug Report"
End Sub

Private Sub optMapping_Click()
    optProgramming.Value = False
    optOther.Value = False
End Sub

Private Sub optNo_Click()
    optYes.Value = False
End Sub

Private Sub optOften_Click()
    optSometimes.Value = False
    optOnce.Value = False
End Sub

Private Sub optOnce_Click()
    optSometimes.Value = False
    optOften.Value = False
End Sub

Private Sub optOther_Click()
    optMapping.Value = False
    optProgramming.Value = False
End Sub

Private Sub optProgramming_Click()
    optMapping.Value = False
    optOther.Value = False
End Sub

Private Sub optSometimes_Click()
    optOften.Value = False
    optOnce.Value = False
End Sub

Private Sub optYes_Click()
    optNo.Value = False
End Sub

