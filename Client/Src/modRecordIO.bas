Attribute VB_Name = "MyModule"

Public Sub EnsureDataFolders(ByVal root As String)
    Dim folder As Variant, path As String, attributes As Long
    For Each folder In Array("data", "maps", "music", "sfx", "gfx")
        path = root & "\" & CStr(folder)
        attributes = WinDevLib.GetFileAttributes(path)
        If attributes = -1 Then
            If WinDevLib.CreateDirectory(path, ByVal vbNullPtr) = 0 Then Err.Raise 75, "EnsureDataFolders", "Cannot create data directory: " & path
        ElseIf (attributes And WinDevLib.FILE_ATTRIBUTE_DIRECTORY) = 0 Then
            Err.Raise 75, "EnsureDataFolders", "Expected a directory: " & path
        End If
    Next folder
End Sub
