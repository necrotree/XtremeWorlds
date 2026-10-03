Imports System
Imports System.Threading
Imports System.Threading.Tasks

Module Program
    Public Async Function Main(args As String()) As Task(Of Integer)
        Console.Title = "XtremeWorlds Server (.NET)"
        Dim settings = ServerSettings.Load("appsettings.json")
        Using host As New ServerHost(settings)
            AddHandler Console.CancelKeyPress,
                Sub(sender, e)
                    e.Cancel = True
                    host.RequestStop()
                End Sub

            Try
                Await host.RunAsync(CancellationToken.None)
                Return 0
            Catch ex As Exception
                Console.Error.WriteLine(ex)
                Return 1
            End Try
        End Using
    End Function
End Module
