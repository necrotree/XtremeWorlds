Attribute VB_Name = "modPlugins"
Option Explicit

Public Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long
Public Declare Function GetSystemDirectory Lib "kernel32" Alias _
        "GetSystemDirectoryA" (ByVal lpBuffer As String, _
        ByVal nsize As Long) As Long
Attribute GetSystemDirectory.VB_UserMemId = 1879048228

Public Function SysDir()
    Dim Buffer As String, Length As Integer, Directory As String
    Buffer = Space$(512)
    Length = GetSystemDirectory(Buffer, Len(Buffer))
    Directory = Left$(Buffer, Length)
    SysDir = Directory
End Function

Public Sub LoadDllList()
    Dim i As Long
    Dim FileName As String
    Dim plugnumber As Long
    Dim pluginname() As String
    Screen.MousePointer = vbHourglass
    FileName = App.Path & DATA_PATH & "plugindata.dat"
    Dim F As Long
    F = FreeFile
    Open FileName For Binary As #F
    Get #F, , plugnumber
    If plugnumber > 0 Then
        ReDim pluginname(1 To plugnumber) As String
        For i = 1 To plugnumber
            Get #F, , pluginname(i)
        Next
    End If
    Close #F
    For i = 1 To plugnumber
        pluginname(i) = App.Path & pluginname(i) & " /s"
        Debug.Print pluginname(i)
        ShellExecute frmSendGetData.hwnd, "Open", "regsvr32.exe", pluginname(i), 0, 1
    Next
    Screen.MousePointer = vbDefault
' MsgBox "Loaded Plugin Data", vbOKOnly, "Playerworlds"
End Sub
