VERSION 5.00
Begin VB.Form frmSignEditor 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Sign Editor"
   ClientHeight    =   7575
   ClientLeft      =   7215
   ClientTop       =   3285
   ClientWidth     =   3015
   ControlBox      =   0   'False
   Icon            =   "frmSignEditor.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7575
   ScaleWidth      =   3015
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox picSign 
      Appearance      =   0  'Flat
      BackColor       =   &H0080FFFF&
      ForeColor       =   &H80000008&
      Height          =   1815
      Left            =   120
      Picture         =   "frmSignEditor.frx":030C
      ScaleHeight     =   1785
      ScaleWidth      =   2745
      TabIndex        =   14
      Top             =   120
      Width           =   2775
      Begin VB.Label lblexit 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Exit"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0080C0FF&
         Height          =   255
         Left            =   960
         TabIndex        =   23
         Top             =   1560
         Width           =   855
      End
      Begin VB.Label lblLine1Top 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Line1"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0080C0FF&
         Height          =   375
         Left            =   45
         TabIndex        =   19
         Top             =   525
         Width           =   2775
      End
      Begin VB.Label lblLine2Top 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Line2"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0080C0FF&
         Height          =   375
         Left            =   45
         TabIndex        =   17
         Top             =   765
         Width           =   2775
      End
      Begin VB.Label lblLine3Top 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Line3"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0080C0FF&
         Height          =   375
         Left            =   45
         TabIndex        =   15
         Top             =   1005
         Width           =   2775
      End
      Begin VB.Line Line1 
         BorderColor     =   &H00000080&
         X1              =   0
         X2              =   2760
         Y1              =   525
         Y2              =   525
      End
      Begin VB.Label lblLine1Btm 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Line1"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   375
         Left            =   0
         TabIndex        =   20
         Top             =   570
         Width           =   2775
      End
      Begin VB.Label lblLine2Btm 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Line2"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   375
         Left            =   0
         TabIndex        =   18
         Top             =   810
         Width           =   2775
      End
      Begin VB.Label lblLine3Btm 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Line3"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   375
         Left            =   0
         TabIndex        =   16
         Top             =   1050
         Width           =   2775
      End
      Begin VB.Label lblNameTop 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Name"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0080C0FF&
         Height          =   375
         Left            =   45
         TabIndex        =   21
         Top             =   120
         Width           =   2775
      End
      Begin VB.Label lblNameBtm 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Name"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00404040&
         Height          =   375
         Left            =   0
         TabIndex        =   22
         Top             =   165
         Width           =   2775
      End
   End
   Begin VB.CommandButton cmdPrev 
      Caption         =   "&Preview Sign"
      Height          =   375
      Left            =   480
      TabIndex        =   13
      Top             =   6600
      Width           =   2055
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "&Cancel"
      Height          =   375
      Left            =   1560
      TabIndex        =   12
      Top             =   7080
      Width           =   975
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   375
      Left            =   480
      TabIndex        =   11
      Top             =   7080
      Width           =   975
   End
   Begin VB.OptionButton optScroll 
      Caption         =   "Parchment / Scroll"
      Height          =   255
      Left            =   480
      TabIndex        =   10
      Top             =   3720
      Width           =   2055
   End
   Begin VB.OptionButton optWooden 
      Caption         =   "Wooden Sign"
      Height          =   255
      Left            =   480
      TabIndex        =   9
      Top             =   3360
      Value           =   -1  'True
      Width           =   2055
   End
   Begin VB.TextBox txtSignLine1 
      Height          =   375
      Left            =   480
      TabIndex        =   8
      Top             =   4440
      Width           =   2055
   End
   Begin VB.TextBox txtSignLine2 
      Height          =   375
      Left            =   480
      TabIndex        =   7
      Top             =   5280
      Width           =   2055
   End
   Begin VB.TextBox txtSignLine3 
      Height          =   375
      Left            =   480
      TabIndex        =   6
      Top             =   6120
      Width           =   2055
   End
   Begin VB.TextBox txtSignName 
      Height          =   375
      Left            =   480
      TabIndex        =   5
      Text            =   "Name"
      Top             =   2520
      Width           =   2055
   End
   Begin VB.Label Label5 
      Caption         =   "Line 1"
      Height          =   255
      Left            =   480
      TabIndex        =   4
      Top             =   4080
      Width           =   2055
   End
   Begin VB.Label Label4 
      Caption         =   "Line 2"
      Height          =   255
      Left            =   480
      TabIndex        =   3
      Top             =   4920
      Width           =   2055
   End
   Begin VB.Label Label3 
      Caption         =   "Line 3"
      Height          =   255
      Left            =   480
      TabIndex        =   2
      Top             =   5760
      Width           =   2055
   End
   Begin VB.Label Label2 
      Caption         =   "Background"
      Height          =   255
      Left            =   480
      TabIndex        =   1
      Top             =   3000
      Width           =   2055
   End
   Begin VB.Label Label1 
      Caption         =   "Sign Name"
      Height          =   255
      Left            =   480
      TabIndex        =   0
      Top             =   2160
      Width           =   2055
   End
End
Attribute VB_Name = "frmSignEditor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdCancel_Click()
    Call SignEditorCancel
End Sub

Private Sub cmdOK_Click()
    Call SignEditorOk
End Sub

Private Sub cmdPrev_Click()
    lblNameTop.Caption = Trim$(txtSignName.Text)
    lblNameBtm.Caption = Trim$(txtSignName.Text)
    lblLine1Top.Caption = Trim$(txtSignLine1.Text)
    lblLine1Btm.Caption = Trim$(txtSignLine1.Text)
    lblLine2Top.Caption = Trim$(txtSignLine2.Text)
    lblLine2Btm.Caption = Trim$(txtSignLine2.Text)
    lblLine3Top.Caption = Trim$(txtSignLine3.Text)
    lblLine3Btm.Caption = Trim$(txtSignLine3.Text)
End Sub

Private Sub optScroll_Click()
    If optWooden.Value = True Then
        optWooden.Value = False
        optScroll.Value = True
    End If
End Sub

Private Sub optWooden_Click()
    If optScroll.Value = True Then
        optScroll.Value = False
        optWooden.Value = True
    End If
End Sub
