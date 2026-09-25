VERSION 5.00
Object = "{3B7C8863-D78F-101B-B9B5-04021C009402}#1.2#0"; "richtx32.ocx"
Begin VB.Form frmMainMenu 
   BackColor       =   &H00000000&
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Playerworlds"
   ClientHeight    =   5550
   ClientLeft      =   7665
   ClientTop       =   3615
   ClientWidth     =   3900
   ControlBox      =   0   'False
   Icon            =   "frmMainMenu.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture         =   "frmMainMenu.frx":030A
   ScaleHeight     =   5550
   ScaleWidth      =   3900
   StartUpPosition =   2  'CenterScreen
   Visible         =   0   'False
   Begin VB.TextBox txtEncKey 
      Height          =   375
      Left            =   0
      TabIndex        =   46
      Text            =   "Text1"
      Top             =   5640
      Visible         =   0   'False
      Width           =   2655
   End
   Begin VB.Timer timerSprite 
      Enabled         =   0   'False
      Interval        =   50
      Left            =   0
      Top             =   0
   End
   Begin VB.PictureBox mnuNewAccount 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   5550
      Left            =   0
      Picture         =   "frmMainMenu.frx":46AA6
      ScaleHeight     =   5550
      ScaleWidth      =   3900
      TabIndex        =   29
      Top             =   0
      Visible         =   0   'False
      Width           =   3900
      Begin VB.TextBox txtNewAcctName 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   6.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   240
         Left            =   600
         MaxLength       =   20
         TabIndex        =   8
         Top             =   3480
         Width           =   2415
      End
      Begin VB.TextBox txtNewAcctPassword 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   6.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   240
         IMEMode         =   3  'DISABLE
         Left            =   600
         MaxLength       =   20
         PasswordChar    =   "*"
         TabIndex        =   9
         Top             =   4140
         Width           =   2415
      End
      Begin VB.Label picNewAcctConnect 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   360
         TabIndex        =   31
         Top             =   5040
         Width           =   1215
      End
      Begin VB.Label picNewAcctCancel 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   2760
         TabIndex        =   30
         Top             =   5040
         Width           =   855
      End
   End
   Begin VB.PictureBox mnuIPConfig 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   5550
      Left            =   0
      Picture         =   "frmMainMenu.frx":8D242
      ScaleHeight     =   5565.041
      ScaleMode       =   0  'User
      ScaleWidth      =   3855.513
      TabIndex        =   42
      Top             =   0
      Visible         =   0   'False
      Width           =   3900
      Begin VB.TextBox txtPort 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   6.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   225
         IMEMode         =   3  'DISABLE
         Left            =   600
         MaxLength       =   20
         TabIndex        =   7
         Top             =   4080
         Width           =   1695
      End
      Begin VB.TextBox txtIP 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   6.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   225
         Left            =   600
         MaxLength       =   20
         TabIndex        =   6
         Top             =   3510
         Width           =   1695
      End
      Begin VB.Label picIPCancel 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   2520
         TabIndex        =   44
         Top             =   5040
         Width           =   735
      End
      Begin VB.Label picIPSave 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   600
         TabIndex        =   43
         Top             =   5040
         Width           =   735
      End
   End
   Begin VB.PictureBox mnuLogin 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   5550
      Left            =   0
      Picture         =   "frmMainMenu.frx":D39DE
      ScaleHeight     =   5550
      ScaleWidth      =   3900
      TabIndex        =   26
      Top             =   0
      Visible         =   0   'False
      Width           =   3900
      Begin VB.CheckBox chkSaveUser 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFC0C0&
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   200
         Left            =   600
         TabIndex        =   5
         Top             =   2950
         Width           =   200
      End
      Begin VB.TextBox txtLoginPassword 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   6.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   240
         IMEMode         =   3  'DISABLE
         Left            =   480
         MaxLength       =   20
         PasswordChar    =   "*"
         TabIndex        =   4
         Top             =   4440
         Width           =   1455
      End
      Begin VB.TextBox txtLoginName 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   6.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   240
         Left            =   480
         MaxLength       =   20
         TabIndex        =   3
         Top             =   3810
         Width           =   1455
      End
      Begin VB.Label picLoginConnect 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   480
         TabIndex        =   28
         Top             =   5040
         Width           =   1215
      End
      Begin VB.Label picLoginCancel 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   2640
         TabIndex        =   27
         Top             =   5040
         Width           =   855
      End
   End
   Begin VB.PictureBox mnuCredits 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   5550
      Left            =   0
      Picture         =   "frmMainMenu.frx":11A17A
      ScaleHeight     =   5550
      ScaleWidth      =   3900
      TabIndex        =   0
      Top             =   0
      Visible         =   0   'False
      Width           =   3900
      Begin RichTextLib.RichTextBox txtSpecial 
         Height          =   975
         Left            =   1080
         TabIndex        =   49
         ToolTipText     =   "Special Contributers to Playerworlds"
         Top             =   3960
         Width           =   2055
         _ExtentX        =   3625
         _ExtentY        =   1720
         _Version        =   393217
         BackColor       =   0
         BorderStyle     =   0
         Enabled         =   -1  'True
         ReadOnly        =   -1  'True
         ScrollBars      =   2
         Appearance      =   0
         TextRTF         =   $"frmMainMenu.frx":160916
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
      End
      Begin VB.Label Label2 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "James Eaton"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1440
         TabIndex        =   48
         Top             =   3240
         Width           =   1215
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "James Eaton"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1440
         TabIndex        =   47
         Top             =   2520
         Width           =   1215
      End
      Begin VB.Label picCreditsCancel 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   1560
         TabIndex        =   25
         Top             =   5040
         Width           =   855
      End
   End
   Begin VB.PictureBox mnuChars 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   5550
      Left            =   0
      Picture         =   "frmMainMenu.frx":160992
      ScaleHeight     =   5550
      ScaleWidth      =   3900
      TabIndex        =   18
      Top             =   0
      Visible         =   0   'False
      Width           =   3900
      Begin VB.ListBox lstChars 
         Appearance      =   0  'Flat
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
         Height          =   870
         ItemData        =   "frmMainMenu.frx":1A712E
         Left            =   510
         List            =   "frmMainMenu.frx":1A7130
         TabIndex        =   13
         Top             =   2520
         Width           =   2895
      End
      Begin VB.PictureBox picSelChar 
         Appearance      =   0  'Flat
         AutoRedraw      =   -1  'True
         BackColor       =   &H00FFFFFF&
         ForeColor       =   &H80000008&
         Height          =   495
         Left            =   1680
         ScaleHeight     =   465
         ScaleWidth      =   465
         TabIndex        =   19
         Top             =   3720
         Visible         =   0   'False
         Width           =   495
      End
      Begin VB.Label picUseChar 
         BackStyle       =   0  'Transparent
         Height          =   375
         Left            =   960
         TabIndex        =   23
         Top             =   4560
         Width           =   495
      End
      Begin VB.Label picNewChar 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   2280
         TabIndex        =   22
         Top             =   4680
         Width           =   735
      End
      Begin VB.Label picDelChar 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   720
         TabIndex        =   21
         Top             =   5040
         Width           =   975
      End
      Begin VB.Label picCharsCancel 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   2280
         TabIndex        =   20
         Top             =   5040
         Width           =   855
      End
   End
   Begin VB.PictureBox mnuNewCharacter 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   5550
      Left            =   0
      Picture         =   "frmMainMenu.frx":1A7132
      ScaleHeight     =   5550
      ScaleWidth      =   3900
      TabIndex        =   32
      Top             =   0
      Visible         =   0   'False
      Width           =   3900
      Begin VB.TextBox txtNewCharName 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   6.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   225
         Left            =   600
         MaxLength       =   20
         TabIndex        =   14
         Top             =   2280
         Width           =   1935
      End
      Begin VB.ComboBox cmbClass 
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
         ItemData        =   "frmMainMenu.frx":1ED8CE
         Left            =   600
         List            =   "frmMainMenu.frx":1ED8D0
         Style           =   2  'Dropdown List
         TabIndex        =   10
         Top             =   3000
         Width           =   1935
      End
      Begin VB.OptionButton optMale 
         BackColor       =   &H00FFFFFF&
         Caption         =   "Male"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   360
         Picture         =   "frmMainMenu.frx":1ED8D2
         Style           =   1  'Graphical
         TabIndex        =   11
         Top             =   3600
         Value           =   -1  'True
         Width           =   735
      End
      Begin VB.OptionButton optFemale 
         BackColor       =   &H00FFFFFF&
         Caption         =   "Female"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   1200
         Picture         =   "frmMainMenu.frx":1F0D9E
         Style           =   1  'Graphical
         TabIndex        =   12
         Top             =   3600
         Width           =   855
      End
      Begin VB.PictureBox picPic 
         Appearance      =   0  'Flat
         AutoRedraw      =   -1  'True
         BackColor       =   &H00FFFFFF&
         ForeColor       =   &H00FFFFFF&
         Height          =   480
         Left            =   2910
         ScaleHeight     =   30
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   30
         TabIndex        =   1
         TabStop         =   0   'False
         Top             =   2280
         Width           =   480
      End
      Begin VB.Label lblHP 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   840
         TabIndex        =   41
         Top             =   3840
         Width           =   375
      End
      Begin VB.Label lblSTR 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   2640
         TabIndex        =   40
         Top             =   3600
         Width           =   375
      End
      Begin VB.Label lblMP 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   840
         TabIndex        =   39
         Top             =   4200
         Width           =   375
      End
      Begin VB.Label lblSPEED 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   2160
         TabIndex        =   38
         Top             =   4680
         Width           =   855
      End
      Begin VB.Label lblSP 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   720
         TabIndex        =   37
         Top             =   4560
         Width           =   495
      End
      Begin VB.Label lblDEF 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   2640
         TabIndex        =   36
         Top             =   3960
         Width           =   375
      End
      Begin VB.Label lblMAGI 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   2640
         TabIndex        =   35
         Top             =   4320
         Width           =   375
      End
      Begin VB.Label picNewCharAddChar 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   720
         TabIndex        =   34
         Top             =   5040
         Width           =   615
      End
      Begin VB.Label picNewCharCancel 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   2400
         TabIndex        =   33
         Top             =   5040
         Width           =   855
      End
   End
   Begin VB.Label picGameOptions 
      BackStyle       =   0  'Transparent
      Height          =   375
      Left            =   600
      TabIndex        =   45
      Top             =   4200
      Width           =   2775
   End
   Begin VB.Label picNewAccount 
      BackStyle       =   0  'Transparent
      Height          =   375
      Left            =   600
      TabIndex        =   24
      Top             =   2280
      Width           =   2655
   End
   Begin VB.Label picQuit 
      BackStyle       =   0  'Transparent
      Height          =   375
      Left            =   960
      TabIndex        =   17
      Top             =   4800
      Width           =   1935
   End
   Begin VB.Label picCredits 
      BackStyle       =   0  'Transparent
      Height          =   495
      Left            =   480
      TabIndex        =   16
      Top             =   840
      Width           =   2775
   End
   Begin VB.Label picIPConfig 
      BackStyle       =   0  'Transparent
      Height          =   375
      Left            =   240
      TabIndex        =   15
      Top             =   3480
      Width           =   3375
   End
   Begin VB.Label picLogin 
      BackStyle       =   0  'Transparent
      Height          =   375
      Left            =   600
      TabIndex        =   2
      Top             =   2880
      Width           =   2775
   End
End
Attribute VB_Name = "frmMainMenu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

' Check to make sure there are not 2 clients and Play Music!

Private Sub Form_Load()
    Dim FileName As String
    If App.PrevInstance = True Then
        MsgBox "Another Playerworlds Client is already running! Please run only one client at a time!", Error
    End If

    FileName = App.Path & DATA_PATH & "Data.dat"
    txtIP.Text = GameData.IP       ' GetVar(FileName, "IPCONFIG", "IP")
    txtPort.Text = GameData.Port   ' GetVar(FileName, "IPCONFIG", "PORT")
    txtEncKey.Text = Trim$(ENC_KEY)
    Me.Caption = GAME_NAME
    
    ' Used for Credits
    Dim result As Long
    With txtSpecial
        result = SetWindowLong(.hwnd, GWL_EXSTYLE, WS_EX_TRANSPARENT)
        .SelColor = QBColor(White)
        .SelAlignment = 2
        .SelText = "John Rognile" & vbNewLine & "Robin Perris" & vbNewLine & "Dmitry Bromberg" & vbNewLine & "Jon Petros" & vbNewLine & "Liam Stewart" & vbNewLine & "Chris Kremer" & vbNewLine & "Mr. Shannara" & vbNewLine & "PW Community" & vbNewLine & "MS Community"
    End With

End Sub

Private Sub Form_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call MoveForm(frmMainMenu)
End Sub

Private Sub mnuChars_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call MoveForm(frmMainMenu)
End Sub

Private Sub mnuCredits_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call MoveForm(frmMainMenu)
End Sub

Private Sub mnuIPConfig_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call MoveForm(frmMainMenu)
End Sub

Private Sub mnuLogin_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call MoveForm(frmMainMenu)
End Sub

Private Sub mnuNewAccount_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call MoveForm(frmMainMenu)
End Sub

Private Sub mnuNewCharacter_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call MoveForm(frmMainMenu)
End Sub

Private Sub picGameOptions_Click()
    'Game Options
End Sub

Private Sub picIPCancel_Click()
    mnuIPConfig.Visible = False
End Sub

Private Sub picIPConfig_Click()
    txtIP.Text = GameData.IP
    txtPort.Text = GameData.Port
    mnuIPConfig.Visible = True

On Error Resume Next
    txtIP.SetFocus
End Sub

Private Sub picIPSave_Click()
    Dim IP, Port As String
    Dim FileName As String
    Dim fErr As Integer
    Dim Texto As String

    IP = Trim$(txtIP.Text)
    Port = Val(Trim$(txtPort.Text))
    FileName = App.Path & DATA_PATH & "Data.dat"

    fErr = 0
    If fErr = 0 And Len(Trim$(IP)) = 0 Then
        fErr = 1
        Call MsgBox("Inform a correct IP.", vbCritical, GAME_NAME)
        Exit Sub
    End If
    If fErr = 0 And Port <= 0 Then
        fErr = 1
        Call MsgBox("Inform a correct Port.", vbCritical, GAME_NAME)
        Exit Sub
    End If
    If fErr = 0 Then
        GameData.IP = txtIP.Text
        GameData.Port = txtPort.Text
        Dim F  As Long
        F = FreeFile
        Open FileName For Binary As #F
        Put #F, , GameData
        Close #F
    End If
    mnuIPConfig.Visible = False
    Call TcpInit
End Sub

' Login Subs

Private Sub picLogin_Click()
    If GameData.SaveLogin = 1 Then
        chkSaveUser.Value = 1
        txtLoginName.Text = GameData.Username                                                     ' GetVar(FileName, "LOGIN", "LOGIN")
        txtLoginPassword.Text = Encryption_XOR_DecryptString(Trim$(GameData.Password), ENC_KEY)   ' Trim$(Encryption_XOR_DecryptString(GetVar(FileName, "LOGIN", "PASS"), ENC_KEY))
    End If
    ' txtLoginName.Text = GameData.Username
    ' txtLoginPassword.Text = Encryption_XOR_DecryptString(GameData.Password, ENC_KEY)
    mnuLogin.Visible = True
    
On Error Resume Next
    txtLoginName.SetFocus
End Sub

Private Sub picLoginConnect_Click()
    Dim FileName As String
    FileName = App.Path & DATA_PATH & "Data.dat"

    If chkSaveUser.Value = 1 Then
        GameData.SaveLogin = 1
        GameData.Username = txtLoginName.Text
        GameData.Password = Encryption_XOR_EncryptString(Trim$(txtLoginPassword.Text), ENC_KEY)
    ElseIf chkSaveUser.Value = 0 Then
        GameData.SaveLogin = 0
        GameData.Username = vbNullString
        GameData.Password = vbNullString
    End If

    Dim F As Long
    F = FreeFile
    Open FileName For Binary As #F
    Put #F, , GameData
    Close #F

    Call LoginConnect
End Sub

Private Sub txtLoginName_KeyPress(KeyAscii As Integer)
On Error Resume Next

    If KeyAscii = 13 Then
        txtLoginPassword.SetFocus
        KeyAscii = 0
    End If
End Sub

Private Sub txtLoginPassword_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        Call LoginConnect
        KeyAscii = 0
    End If
End Sub

Private Sub picLoginCancel_Click()
    mnuLogin.Visible = False
End Sub

' New Account Subs

Private Sub picNewAccount_Click()
    mnuNewAccount.Visible = True
On Error Resume Next
    txtNewAcctName.SetFocus
End Sub

Private Sub picNewAcctCancel_Click()
    mnuNewAccount.Visible = False
End Sub

Private Sub picNewAcctConnect_Click()
    Call NewAccountConnect
End Sub

' Credits Subs

Private Sub picCredits_Click()
    mnuCredits.Visible = True
End Sub

Private Sub picCreditsCancel_Click()
    mnuCredits.Visible = False
End Sub

' Delete Account Subs

Private Sub picDeleteAccount_Click()
' Dim YesNo As Long

' YesNo = MsgBox("You are on the path for a character deletion, are you sure you want to go through with this?", vbYesNo, GAME_NAME)
' If YesNo = vbYes Then
' frmDeleteAccount.Visible = True
' Me.Visible = False
' End If
End Sub

' Exit Game Subs

Private Sub picQuit_Click()
    Call StopMidi
    Call GameDestroy
End Sub

' New Character Subs

' The New Character Sprite Timer

Private Sub timerSprite_Timer()
' Call NewCharBltSprite(cmbClass.ListIndex)
End Sub

Private Sub optFemale_Click()
    Call NewCharBltSprite(cmbClass.ListIndex)
End Sub

Private Sub optMale_Click()
    Call NewCharBltSprite(cmbClass.ListIndex)
End Sub

Private Sub picNewCharAddChar_Click()
    Call AddCharClick
End Sub

Private Sub picNewCharCancel_Click()
    mnuChars.Visible = True
    mnuNewCharacter.Visible = False
End Sub

Private Sub cmbClass_Change()
    Call NewCharBltSprite(cmbClass.ListIndex)
    If Class(cmbClass.ListIndex).Sprite = Class(cmbClass.ListIndex).FSprite Then
        optMale.Value = True
        optMale.Visible = False
        optFemale.Value = False
        optFemale.Visible = False
    ElseIf Class(cmbClass.ListIndex).Sprite <> Class(cmbClass.ListIndex).FSprite Then
        optMale.Value = True
        optMale.Visible = True
        optFemale.Value = False
        optFemale.Visible = True
    End If
End Sub

Private Sub cmbClass_Click()
    lblHP.Caption = STR(Class(cmbClass.ListIndex).HP)
    lblMP.Caption = STR(Class(cmbClass.ListIndex).MP)
    lblSP.Caption = STR(Class(cmbClass.ListIndex).SP)

    lblSTR.Caption = STR(Class(cmbClass.ListIndex).STR)
    lblDEF.Caption = STR(Class(cmbClass.ListIndex).DEF)
    lblSPEED.Caption = STR(Class(cmbClass.ListIndex).speed)
    lblMAGI.Caption = STR(Class(cmbClass.ListIndex).MAGI)
    Call NewCharBltSprite(cmbClass.ListIndex)
End Sub

' Character Subs

Private Sub picUseChar_Click()
    Call StopMidi
    Call MenuState(MENU_STATE_USECHAR)
End Sub

Private Sub picNewChar_Click()
    Call MenuState(MENU_STATE_NEWCHAR)
End Sub

Private Sub picCharsCancel_Click()
    Call TcpDestroy
    mnuLogin.Visible = True
    mnuChars.Visible = False
End Sub

Private Sub picDelChar_Click()
    Dim Value As Long

    Value = MsgBox("Are you sure you wish to delete this character?", vbYesNo, GAME_NAME)
    If Value = vbYes Then
        Call MenuState(MENU_STATE_DELCHAR)
    End If
End Sub
