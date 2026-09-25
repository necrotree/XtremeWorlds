VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsNativePacket"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
     Option Explicit
    Private mBytes() As Byte
    Public Sub Assign(ByRef bytes() As Byte, ByVal count As Long)
        ReDim mBytes(0 To count - 1)
        WinDevLib.CopyMemory mBytes(0), bytes(LBound(bytes)), count
    End Sub
    Public Function Read() As Byte()
        Read = mBytes
    End Function
