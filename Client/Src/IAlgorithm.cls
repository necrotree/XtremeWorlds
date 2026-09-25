VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IAlgorithm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public Function ToString() As String

End Function
Public Function EncryptString(Text As String, Optional Key As String, _
        Optional OutputInHex As Boolean) As String

End Function

Public Function DecryptString(Text As String, Optional Key As String, _
        Optional IsTextInHex As Boolean) As String

End Function

Public Function EncryptFile(InFile As String, OutFile As String, _
        Overwrite As Boolean, Optional Key As String) As Boolean

End Function

Public Function DecryptFile(InFile As String, OutFile As String, _
        Overwrite As Boolean, Optional Key As String) As Boolean

End Function

Public Property Let Key(strKey As String)

End Property


Public Property Get Status() As Long

End Property

Public Property Let Status(lStatus As Long)

End Property
