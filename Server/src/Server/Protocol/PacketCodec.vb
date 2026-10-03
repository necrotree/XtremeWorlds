Imports System.Text

Public Module PacketCodec
    Public Const Separator As Char = ChrW(0)
    Public Const Terminator As Char = ChrW(1)

    Public Function Decode(bytes As ReadOnlySpan(Of Byte)) As String
        Return Encoding.UTF8.GetString(bytes).TrimEnd(Terminator)
    End Function

    Public Function SplitPacket(data As String) As String()
        Return data.TrimEnd(Terminator).Split(Separator)
    End Function

    Public Function Compose(command As String, ParamArray args As Object()) As String
        Dim parts As New List(Of String) From {command}
        For Each value In args
            parts.Add(If(value Is Nothing, String.Empty, Convert.ToString(value, Globalization.CultureInfo.InvariantCulture)))
        Next
        Return String.Join(Separator, parts) & Terminator
    End Function
End Module
