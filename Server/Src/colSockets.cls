VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "colSockets"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Collection" ,"UserDefinedCollection"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit
' local variable to hold collection
Private mCol As Collection
Public Function Add(Optional sKey As String) As clsSocket
    ' create a new object
    Dim objNewMember As clsSocket
    Set objNewMember = New clsSocket

    ' set the properties passed into the method
    If Len(sKey) = 0 Then
        mCol.Add objNewMember
    Else
        mCol.Add objNewMember, sKey
    End If

    ' return the object created
    Set Add = objNewMember
    Set objNewMember = Nothing
End Function
Public Property Get Item(vntIndexKey As Variant) As clsSocket
Attribute Item.VB_UserMemId = 0
    Set Item = mCol(vntIndexKey)
End Property
Public Property Get Count() As Long
    Count = mCol.Count
End Property
Public Sub Remove(vntIndexKey As Variant)
Attribute Remove.VB_UserMemId = 1610809347
    Call mCol(vntIndexKey).Shutdown(SocketShutdownBoth)
    mCol(vntIndexKey).CloseSocket
    mCol.Remove vntIndexKey
End Sub
Public Property Get NewEnum() As IUnknown
    Set NewEnum = mCol.[_NewEnum]
End Property
Private Sub Class_Initialize()
Attribute Class_Initialize.VB_UserMemId = 1610809348
    ' creates the collection when this class is created
    Set mCol = New Collection
End Sub
Private Sub Class_Terminate()
Attribute Class_Terminate.VB_UserMemId = 1610809349
    ' destroys collection when this class is terminated
    Set mCol = Nothing
End Sub
