VERSION 5.00
Begin VB.Form frmDrop 
   BackColor       =   &H00800000&
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Drop Item"
   ClientHeight    =   5550
   ClientLeft      =   8730
   ClientTop       =   4815
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
   Icon            =   "frmDrop.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture         =   "frmDrop.frx":030C
   ScaleHeight     =   5550
   ScaleWidth      =   3900
   ShowInTaskbar   =   0   'False
   Begin VB.Label cmdCancel 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   2280
      TabIndex        =   11
      Top             =   5040
      Width           =   1215
   End
   Begin VB.Label cmdOk 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   480
      TabIndex        =   10
      Top             =   5040
      Width           =   735
   End
   Begin VB.Label cmdMinus1000 
      BackStyle       =   0  'Transparent
      Height          =   135
      Left            =   2640
      TabIndex        =   9
      Top             =   4440
      Width           =   615
   End
   Begin VB.Label cmdPlus1000 
      BackStyle       =   0  'Transparent
      Height          =   135
      Left            =   360
      TabIndex        =   8
      Top             =   4440
      Width           =   615
   End
   Begin VB.Label cmdMinus100 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   2640
      TabIndex        =   7
      Top             =   4080
      Width           =   495
   End
   Begin VB.Label cmdPlus100 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   480
      TabIndex        =   6
      Top             =   4080
      Width           =   375
   End
   Begin VB.Label cmdMinus10 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   2640
      TabIndex        =   5
      Top             =   3720
      Width           =   375
   End
   Begin VB.Label cmdPlus10 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   360
      TabIndex        =   4
      Top             =   3720
      Width           =   495
   End
   Begin VB.Label cmdMinus1 
      BackStyle       =   0  'Transparent
      Height          =   135
      Left            =   2640
      TabIndex        =   3
      Top             =   3480
      Width           =   375
   End
   Begin VB.Label cmdPlus1 
      BackStyle       =   0  'Transparent
      Height          =   135
      Left            =   360
      TabIndex        =   2
      Top             =   3480
      Width           =   375
   End
   Begin VB.Label lblAmmount 
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      Caption         =   "1"
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
      Height          =   255
      Left            =   1080
      TabIndex        =   1
      Top             =   2800
      Width           =   2535
   End
   Begin VB.Label lblName 
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
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
      Height          =   255
      Left            =   1080
      TabIndex        =   0
      Top             =   2265
      Width           =   2535
   End
End
Attribute VB_Name = "frmDrop"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Ammount As Long

Private Sub Form_Load()
    Me.Caption = GAME_NAME & " :: Drop Item"
    Dim InvNum As Long

    Ammount = 1
    InvNum = frmMainGame.lstInv.ListIndex + 1

    frmDrop.lblName = Trim$(Item(GetPlayerInvItemNum(MyIndex, InvNum)).name)
    Call ProcessAmmount
End Sub

Private Sub cmdOK_Click()
    Dim InvNum As Long

    InvNum = frmMainGame.lstInv.ListIndex + 1

    Call SendDropItem(InvNum, Ammount)
    Unload Me
End Sub

Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdPlus1_Click()
    Ammount = Ammount + 1
    Call ProcessAmmount
End Sub

Private Sub cmdMinus1_Click()
    Ammount = Ammount - 1
    Call ProcessAmmount
End Sub

Private Sub cmdPlus10_Click()
    Ammount = Ammount + 10
    Call ProcessAmmount
End Sub

Private Sub cmdMinus10_Click()
    Ammount = Ammount - 10
    Call ProcessAmmount
End Sub

Private Sub cmdPlus100_Click()
    Ammount = Ammount + 100
    Call ProcessAmmount
End Sub

Private Sub cmdMinus100_Click()
    Ammount = Ammount - 100
    Call ProcessAmmount
End Sub

Private Sub cmdPlus1000_Click()
    Ammount = Ammount + 1000
    Call ProcessAmmount
End Sub

Private Sub cmdMinus1000_Click()
    Ammount = Ammount - 1000
    Call ProcessAmmount
End Sub

Private Sub ProcessAmmount()
    Dim InvNum As Long

    InvNum = frmMainGame.lstInv.ListIndex + 1

    ' Check if more then max and set back to max if so
    If Ammount > GetPlayerInvItemValue(MyIndex, InvNum) Then
        Ammount = GetPlayerInvItemValue(MyIndex, InvNum)
    End If

    ' Make sure its not 0
    If Ammount <= 0 Then
        Ammount = 1
    End If

    frmDrop.lblAmmount.Caption = Ammount & "/" & GetPlayerInvItemValue(MyIndex, InvNum)
End Sub
