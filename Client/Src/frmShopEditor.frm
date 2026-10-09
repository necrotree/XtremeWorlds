VERSION 5.00
Begin VB.Form frmShopEditor 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Shop Editor"
   ClientHeight    =   8145
   ClientLeft      =   7305
   ClientTop       =   2625
   ClientWidth     =   5535
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
   Icon            =   "frmShopEditor.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   543
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   369
   ShowInTaskbar   =   0   'False
   Begin VB.ComboBox cmbitem2Give 
      Enabled         =   0   'False
      Height          =   390
      Left            =   1440
      Style           =   2  'Dropdown List
      TabIndex        =   20
      Top             =   3360
      Width           =   3975
   End
   Begin VB.TextBox txtItem2GiveValue 
      Alignment       =   1  'Right Justify
      Enabled         =   0   'False
      Height          =   390
      Left            =   1440
      TabIndex        =   19
      Text            =   "1"
      Top             =   3840
      Width           =   1335
   End
   Begin VB.CheckBox chkFixesItems 
      Caption         =   "Fixes Items"
      Height          =   375
      Left            =   120
      TabIndex        =   18
      ToolTipText     =   "Check this box if you wat the shop to be able to fix items."
      Top             =   1680
      Width           =   5295
   End
   Begin VB.CommandButton cmdUpdate 
      Caption         =   "Update "
      Height          =   375
      Left            =   3000
      TabIndex        =   17
      Top             =   4920
      Width           =   2415
   End
   Begin VB.TextBox txtItemGetValue 
      Alignment       =   1  'Right Justify
      Height          =   390
      Left            =   1440
      TabIndex        =   6
      Text            =   "1"
      Top             =   4920
      Width           =   1335
   End
   Begin VB.ComboBox cmbItemGet 
      Height          =   390
      Left            =   1440
      Style           =   2  'Dropdown List
      TabIndex        =   5
      Top             =   4440
      Width           =   3975
   End
   Begin VB.CommandButton cmdOk 
      Caption         =   "Ok"
      Height          =   615
      Left            =   120
      TabIndex        =   8
      Top             =   7440
      Width           =   2535
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      Height          =   615
      Left            =   2880
      TabIndex        =   9
      Top             =   7440
      Width           =   2535
   End
   Begin VB.TextBox txtItemGiveValue 
      Alignment       =   1  'Right Justify
      Height          =   390
      Left            =   1440
      TabIndex        =   4
      Text            =   "1"
      Top             =   2760
      Width           =   1335
   End
   Begin VB.ComboBox cmbItemGive 
      Height          =   390
      Left            =   1440
      Style           =   2  'Dropdown List
      TabIndex        =   3
      Top             =   2280
      Width           =   3975
   End
   Begin VB.ListBox lstTradeItem 
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1740
      ItemData        =   "frmShopEditor.frx":030C
      Left            =   120
      List            =   "frmShopEditor.frx":0328
      TabIndex        =   7
      Top             =   5520
      Width           =   5295
   End
   Begin VB.TextBox txtLeaveSay 
      Height          =   390
      Left            =   1440
      TabIndex        =   2
      ToolTipText     =   "This is the goodbye message that will appear after a player is done shopping."
      Top             =   1080
      Width           =   3975
   End
   Begin VB.TextBox txtName 
      Height          =   390
      Left            =   1440
      TabIndex        =   0
      ToolTipText     =   "This is the name of the shop."
      Top             =   120
      Width           =   3975
   End
   Begin VB.TextBox txtJoinSay 
      Height          =   390
      Left            =   1440
      TabIndex        =   1
      ToolTipText     =   "This is what the shop will say when it opens."
      Top             =   600
      Width           =   3975
   End
   Begin VB.Label Label8 
      Caption         =   "Item Give 2"
      Height          =   375
      Left            =   120
      TabIndex        =   22
      Top             =   3360
      Width           =   1215
   End
   Begin VB.Label Label7 
      Caption         =   "Value 2"
      Height          =   375
      Left            =   120
      TabIndex        =   21
      Top             =   3840
      Width           =   1215
   End
   Begin VB.Label Label6 
      Caption         =   "Value"
      Height          =   375
      Left            =   120
      TabIndex        =   16
      Top             =   4920
      Width           =   1215
   End
   Begin VB.Label Label5 
      Caption         =   "Item Get"
      Height          =   375
      Left            =   120
      TabIndex        =   15
      Top             =   4440
      Width           =   1215
   End
   Begin VB.Label Label4 
      Caption         =   "Value"
      Height          =   375
      Left            =   120
      TabIndex        =   14
      Top             =   2760
      Width           =   1215
   End
   Begin VB.Label Label3 
      Caption         =   "Item Give"
      Height          =   375
      Left            =   120
      TabIndex        =   13
      Top             =   2280
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "Leave Say"
      Height          =   375
      Left            =   120
      TabIndex        =   12
      Top             =   1080
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "Name"
      Height          =   375
      Left            =   120
      TabIndex        =   11
      Top             =   120
      Width           =   1215
   End
   Begin VB.Label Label14 
      Caption         =   "Join Say"
      Height          =   375
      Left            =   120
      TabIndex        =   10
      Top             =   600
      Width           =   1215
   End
End
Attribute VB_Name = "frmShopEditor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmbItemGive_KeyUp(KeyCode As Integer, Shift As Integer)

    If cmbItemGive.ListIndex > 0 Then
        cmbitem2Give.Enabled = True
        txtItem2GiveValue.Enabled = True
    Else
        cmbitem2Give.Enabled = False
        txtItem2GiveValue.Enabled = False
    End If

End Sub

Private Sub cmdOK_Click()
    Call ShopEditorOk
End Sub

Private Sub cmdCancel_Click()
    Call ShopEditorCancel
End Sub

Private Sub cmdUpdate_Click()
    Dim index As Long

    index = lstTradeItem.ListIndex + 1
    Shop(EditorIndex).TradeItem(index).GiveItem = cmbItemGive.ListIndex
    Shop(EditorIndex).TradeItem(index).GiveValue = Val(txtItemGiveValue.Text)
    Shop(EditorIndex).TradeItem(index).GiveItem2 = cmbitem2Give.ListIndex
    Shop(EditorIndex).TradeItem(index).GiveValue2 = Val(txtItem2GiveValue.Text)
    Shop(EditorIndex).TradeItem(index).GetItem = cmbItemGet.ListIndex
    Shop(EditorIndex).TradeItem(index).GetValue = Val(txtItemGetValue.Text)

    Call UpdateShopTrade
End Sub
