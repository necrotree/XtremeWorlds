VERSION 5.00
Object = "{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}#1.1#0"; "SHDOCVW.DLL"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form frmWeb 
   BackColor       =   &H00800000&
   Caption         =   "Web Browser"
   ClientHeight    =   10350
   ClientLeft      =   1785
   ClientTop       =   2220
   ClientWidth     =   13575
   LinkTopic       =   "Form1"
   ScaleHeight     =   690
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   905
   Visible         =   0   'False
   Begin MSComctlLib.ProgressBar barWeb 
      Height          =   255
      Left            =   10680
      TabIndex        =   6
      Top             =   360
      Width           =   1815
      _ExtentX        =   3201
      _ExtentY        =   450
      _Version        =   393216
      Appearance      =   1
   End
   Begin VB.CommandButton cmdRefresh 
      Caption         =   "Refresh"
      Height          =   375
      Left            =   2040
      TabIndex        =   4
      Top             =   240
      Width           =   735
   End
   Begin VB.CommandButton cmdGo 
      Caption         =   "Go"
      Height          =   375
      Left            =   9240
      TabIndex        =   3
      Top             =   240
      Width           =   495
   End
   Begin VB.ComboBox cmbnav 
      Height          =   315
      Left            =   2880
      TabIndex        =   2
      Text            =   "Type your URL Here..."
      Top             =   240
      Width           =   6255
   End
   Begin VB.CommandButton cmdForward 
      Caption         =   "Forward ->"
      Height          =   375
      Left            =   960
      TabIndex        =   1
      Top             =   240
      Width           =   975
   End
   Begin VB.CommandButton cmdback 
      Caption         =   "<- Back"
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   240
      Width           =   735
   End
   Begin SHDocVwCtl.WebBrowser web 
      Height          =   9375
      Left            =   120
      TabIndex        =   5
      Top             =   720
      Width           =   13335
      ExtentX         =   23521
      ExtentY         =   16536
      ViewMode        =   0
      Offline         =   0
      Silent          =   0
      RegisterAsBrowser=   1
      RegisterAsDropTarget=   1
      AutoArrange     =   0   'False
      NoClientEdge    =   0   'False
      AlignLeft       =   0   'False
      NoWebView       =   0   'False
      HideFileNames   =   0   'False
      SingleClick     =   0   'False
      SingleSelection =   0   'False
      NoFolders       =   0   'False
      Transparent     =   0   'False
      ViewID          =   "{0057D0E0-3573-11CF-AE69-08002B2E1262}"
      Location        =   ""
   End
End
Attribute VB_Name = "frmWeb"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private LoadPercent As Integer

Private Sub cmbnav_KeyPress(KeyAscii As Integer)
barWeb.Refresh
    If KeyAscii = vbKeyReturn Then
        If Mid(cmbnav.Text, 1, 3) = "www" Then
            web.Navigate ("http://" & Trim$(cmbnav.Text))
            cmbnav.AddItem Trim$("http://" & cmbnav.Text)
        Else
            web.Navigate (Trim$(cmbnav.Text))
            cmbnav.AddItem Trim$(cmbnav.Text)
        End If
        
        Me.Caption = Trim$(web.LocationName)
    End If
End Sub

Private Sub cmdback_Click()
    barWeb.Refresh
    web.GoBack
End Sub

Private Sub cmdForward_Click()
    barWeb.Refresh
    web.GoForward
    On Error GoTo Error
    
Error:
    Exit Sub
End Sub

Private Sub cmdGo_Click()
    barWeb.Refresh
    If Mid(cmbnav.Text, 1, 3) = "www" Then
        web.Navigate ("http://" & Trim$(cmbnav.Text))
        cmbnav.AddItem Trim$("http://" & cmbnav.Text)
    Else
        web.Navigate (Trim$(cmbnav.Text))
        cmbnav.AddItem Trim$(cmbnav.Text)
    End If
    
    Me.Caption = Trim$(web.LocationName)
End Sub

Private Sub cmdRefresh_Click()
    barWeb.Refresh
    web.Refresh
End Sub

Private Sub Form_Load()
    web.Navigate (Trim$(WEBSITE))
    Me.Caption = web.LocationName
    'txtLocation.text = webBrowser.LocationURL
End Sub

'Private Sub Form_Resize()
'    If Me.ScaleWidth < 507 Then Me.Width = 7725
'    If Me.ScaleHeight < 401 Then Me.Height = 6525
'    web.Width = Me.ScaleWidth - 16
'    web.Height = Me.ScaleHeight - 48
'    cmbnav.Width = Me.ScaleWidth - 266
'End Sub

Private Sub statusWeb_PanelClick(ByVal Panel As MSComctlLib.Panel)
    statusWeb.Object
End Sub

Private Sub Form_Resize()
    If Me.ScaleWidth < 905 Then Me.Width = 13665
    If Me.ScaleHeight < 690 Then Me.Height = 10830
    web.Width = Me.ScaleWidth - 16
    web.Height = Me.ScaleHeight - 65
'    cmbnav.Width = Me.ScaleWidth - 266
End Sub

Private Sub web_NavigateComplete2(ByVal pDisp As Object, URL As Variant)
    cmbnav.Text = Trim$(web.LocationURL)
    Me.Caption = Trim$(web.LocationName)
End Sub

Private Sub web_ProgressChange(ByVal Progress As Long, ByVal ProgressMax As Long)
    If Progress >= 1 And ProgressMax > 0 Then
        barWeb.max = ProgressMax
        barWeb.Value = Progress
        LoadPercent = (Progress / ProgressMax) * 100
    End If
End Sub
