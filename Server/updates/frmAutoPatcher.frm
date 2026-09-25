VERSION 5.00
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
Begin VB.Form frmAutoPatcher 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Auto Patcher"
   ClientHeight    =   4305
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4575
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Moveable        =   0   'False
   ScaleHeight     =   4305
   ScaleWidth      =   4575
   StartUpPosition =   2  'CenterScreen
   Begin InetCtlsObjects.Inet iNet 
      Left            =   120
      Top             =   120
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "&Cancel"
      BeginProperty Font 
         Name            =   "MS Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   2400
      TabIndex        =   3
      Top             =   3840
      Width           =   2055
   End
   Begin VB.CommandButton cmdDone 
      Caption         =   "&Done"
      BeginProperty Font 
         Name            =   "MS Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   3840
      Width           =   2055
   End
   Begin VB.TextBox txtMain 
      BackColor       =   &H00000000&
      BeginProperty Font 
         Name            =   "MS Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H0000FFFF&
      Height          =   3255
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   120
      Width           =   4335
   End
   Begin VB.Label lblUpdate 
      Alignment       =   2  'Center
      BackColor       =   &H00C0C0C0&
      BorderStyle     =   1  'Fixed Single
      BeginProperty Font 
         Name            =   "MS Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   3480
      Width           =   4335
   End
End
Attribute VB_Name = "frmAutoPatcher"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'Block of declares to disable "X" box on title bar
Private Const MF_BYPOSITION = &H400
Private Const MF_REMOVE = &H1000
Private Declare Function DrawMenuBar Lib "user32" _
(ByVal hwnd As Long) As Long
Private Declare Function GetMenuItemCount Lib "user32" _
(ByVal hMenu As Long) As Long
Private Declare Function GetSystemMenu Lib "user32" _
(ByVal hwnd As Long, _
ByVal bRevert As Long) As Long
Private Declare Function RemoveMenu Lib "user32" _
(ByVal hMenu As Long, _
ByVal nPosition As Long, _
ByVal wFlags As Long) As Long
'--end block--


'---Local Declarations/Variables---

'Point to the web server and update.txt file that will
'hold your update information
Private Const WebAddress As String = "http://www.yoursite.com/files/update.txt"



'**** NO CHANGES BELOW NEEDED ****

'UDT that holds update information
Private Type UpdateData
    fPlacement As String 'Holds location to download too
    fDateFile As String 'Holds date file name to create
    fUpdateTime As String 'Holds date to compare
    fGetFile As String 'Web Address to download from
End Type

'UDT Array
Private uInfo() As UpdateData

Private Sub cmdCancel_Click()

'Terminate and unload
Unload Me
'Unload YourGame (Unload your games form as well)
End

End Sub

Private Sub cmdDone_Click()

'Unload the auto patcher and make starting form visible
Unload Me
'frmGame.Visible = True

End Sub
Private Sub Form_Load()
Dim hMenu As Long
Dim menuItemCount As Long

'Block of code to disable "X" box on title bar
hMenu = GetSystemMenu(Me.hwnd, 0)
If hMenu Then
menuItemCount = GetMenuItemCount(hMenu)
Call RemoveMenu(hMenu, menuItemCount - 1, _
MF_REMOVE Or MF_BYPOSITION)
Call RemoveMenu(hMenu, menuItemCount - 2, _
MF_REMOVE Or MF_BYPOSITION)
Call DrawMenuBar(Me.hwnd)
End If
'--End block--


cmdDone.Enabled = False 'Disable Done Button

'Make sure directorys exist if new install
VerifyDirectorys

Me.Show 'Show the Form

StartUpdate 'Start the update

End Sub
Private Sub txtMain_GotFocus()

'Change focus so the cursor doesn't block view
cmdCancel.SetFocus

End Sub

Private Function IsFile(inFile As String) As Boolean

'Function to check if a file exists
If Len(Dir$(inFile, vbNormal)) > 0 Then
    IsFile = True
    Exit Function
Else
    IsFile = False
    Exit Function
End If

End Function

Private Function IsDirectory(inDirectory As String) As Boolean

'Function to see if a directory exists
If Len(Dir$(inDirectory, vbDirectory)) > 0 Then
    IsDirectory = True
    Exit Function
Else
    IsDirectory = False
    Exit Function
End If

End Function

Private Sub VerifyDirectorys()

'We verify all directorys are created so we don't get
'any errors if its a fresh install.  You can add whatever
'directorys you want such as \maps or \graphics.. ie..


'This MUST stay.  It is where the file information is
'held for each updated file so we don't update twice
If IsDirectory(App.Path & "\update") = False Then
    MkDir App.Path & "\update"
End If

'EXAMPLE OF MAPS DIRECTORY
If IsDirectory(App.Path & "\maps") = False Then
    MkDir App.Path & "\maps"
End If

End Sub
Private Sub StartUpdate()
On Error GoTo Failed 'Error Handler
Dim aCnt As Integer 'Loop counter
Dim UpdateString As String 'Holds the update information
'Used to split the information
Dim aSplit() As String, bSplit() As String
Dim UpdateByte() As Byte 'Holds the download
Dim tInt As Integer 'Holds value of split
Dim ff As Integer 'Used for FreeFile
Dim TempData As String 'Holds temporary date to compare

'Get the \update.txt file from the server
UpdateString = iNet.OpenURL(WebAddress, icString)

'Strip the NEWS TEXT off the string and display it
tInt = InStr(1, UpdateString, vbCrLf)

'Display the NEWS in the text box
txtMain.Text = Left$(UpdateString, tInt - 1)

'Strip the News Text off the string completely now
UpdateString = Mid$(UpdateString, tInt + Len(vbCrLf))

'Breaks down each update individually
aSplit = Split(UpdateString, vbCrLf)

'Dim the UDT array to hold exact amount of files to update
ReDim uInfo(UBound(aSplit) - 1)

'Create for/next to break up each file update
For aCnt = LBound(aSplit) To UBound(aSplit) - 1
'Breaks down each update individually and writes information
bSplit = Split(aSplit(aCnt), ", ")
    With uInfo(aCnt)
        .fPlacement = Trim$(bSplit(0))
        .fDateFile = Trim$(bSplit(1))
        .fUpdateTime = Trim$(bSplit(2))
        .fGetFile = Trim$(bSplit(3))
    End With
Next aCnt


'Here's the meat of the Updater

'For/Next loop to process each update individually
For aCnt = 0 To UBound(uInfo)
        
        'Check to see if the date file exists
        If IsFile(App.Path & "\update\" & uInfo(aCnt).fDateFile) = False Then
            ff = FreeFile
            
            'Write the time file
            Open App.Path & "\update\" & uInfo(aCnt).fDateFile For Output As #ff
                Write #ff, uInfo(aCnt).fUpdateTime
            Close #ff
            
            'Let user know we are download a file
            lblUpdate.Caption = "Downloading " & uInfo(aCnt).fPlacement & ", please wait..."
            
            'Let windows do what it needs to before we start
            DoEvents
            
            'Download File
            UpdateByte() = iNet.OpenURL(uInfo(aCnt).fGetFile, icByteArray)
            
            'Write file to location
            ff = FreeFile
            Open App.Path & uInfo(aCnt).fPlacement For Binary As #ff
                Put #ff, , UpdateByte()
            Close #ff
        
        
        Else 'If date file is found,  open and compare it.
        
            ff = FreeFile
            Open App.Path & "\update\" & uInfo(aCnt).fDateFile For Input As #ff
                Input #ff, TempData
            Close #ff
            
            'Now compare the dates
            If TempData <> uInfo(aCnt).fUpdateTime Then
            
            'Write the new time file
            Open App.Path & "\update\" & uInfo(aCnt).fDateFile For Output As #ff
                Write #ff, uInfo(aCnt).fUpdateTime
            Close #ff
            
            'Let user know we are download a file
            lblUpdate.Caption = "Downloading " & uInfo(aCnt).fPlacement & ", please wait..."
            
            'Let windows do what it needs to before we start
            DoEvents
            
            'Download File
            UpdateByte() = iNet.OpenURL(uInfo(aCnt).fGetFile, icByteArray)
            
            'Write file to location
            ff = FreeFile
            Open App.Path & uInfo(aCnt).fPlacement For Binary As #ff
                Put #ff, , UpdateByte()
            Close #ff
        End If
    End If
            
Next aCnt

'Let user know were done
lblUpdate.Caption = "Finished..."

'Enable the DONE button
cmdDone.Enabled = True


Exit Sub

Failed:
MsgBox "Update Failed, Shutting Down.", , "Update Failed"
Unload Me
'Unload GameForm 'Change This
End

End Sub
