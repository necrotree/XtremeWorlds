Imports System
Imports System.IO
Imports System.Linq
Imports System.Reflection
Imports Eto.Drawing

Namespace XtremeWorlds.Client.UI
    Public NotInheritable Class AssetLoader
        Private Sub New()
        End Sub

        Public Shared Function LoadImage(relativePath As String) As Image
            If String.IsNullOrWhiteSpace(relativePath) Then Return Nothing

            ' First try the resource embedded in the shared Eto.Core assembly.
            Dim embedded = LoadEmbeddedImage(relativePath)
            If embedded IsNot Nothing Then Return embedded

            ' Also ship the image files physically with the application.  This
            ' makes development/debug builds robust even when a resource name is
            ' changed by the build system or another host assembly is used.
            Dim physical = LoadFileImage(relativePath)
            If physical IsNot Nothing Then Return physical

            Return Nothing
        End Function

        Private Shared Function LoadEmbeddedImage(relativePath As String) As Image
            Dim asm = GetType(AssetLoader).Assembly
            Dim normalizedPath = "Assets." & relativePath.Replace("/", ".").Replace("\", ".")

            Dim resourceName = asm.GetManifestResourceNames().FirstOrDefault(
                Function(n) String.Equals(n, normalizedPath, StringComparison.OrdinalIgnoreCase) OrElse
                            n.EndsWith("." & normalizedPath, StringComparison.OrdinalIgnoreCase))

            If resourceName Is Nothing Then Return Nothing

            Using stream = asm.GetManifestResourceStream(resourceName)
                If stream Is Nothing Then Return Nothing
                Return New Bitmap(stream)
            End Using
        End Function

        Private Shared Function LoadFileImage(relativePath As String) As Image
            Dim normalizedRelative = relativePath.Replace("/"c, Path.DirectorySeparatorChar).Replace("\"c, Path.DirectorySeparatorChar)
            Dim candidates = {
                Path.Combine(AppContext.BaseDirectory, "Assets", normalizedRelative),
                Path.Combine(AppContext.BaseDirectory, normalizedRelative),
                Path.Combine(Environment.CurrentDirectory, "Assets", normalizedRelative)
            }

            For Each candidate In candidates
                If File.Exists(candidate) Then
                    Using stream = File.OpenRead(candidate)
                        Return New Bitmap(stream)
                    End Using
                End If
            Next

            Return Nothing
        End Function

        Public Shared Function LoadIcon(relativePath As String) As Icon
            If String.IsNullOrWhiteSpace(relativePath) Then Return Nothing

            Dim asm = GetType(AssetLoader).Assembly
            Dim normalizedPath = "Assets." & relativePath.Replace("/", ".").Replace("\", ".")
            Dim resourceName = asm.GetManifestResourceNames().FirstOrDefault(
                Function(n) String.Equals(n, normalizedPath, StringComparison.OrdinalIgnoreCase) OrElse
                            n.EndsWith("." & normalizedPath, StringComparison.OrdinalIgnoreCase))

            If resourceName IsNot Nothing Then
                Using stream = asm.GetManifestResourceStream(resourceName)
                    If stream IsNot Nothing Then Return New Icon(stream)
                End Using
            End If

            Dim normalizedRelative = relativePath.Replace("/"c, Path.DirectorySeparatorChar).Replace("\"c, Path.DirectorySeparatorChar)
            Dim candidates = {
                Path.Combine(AppContext.BaseDirectory, "Assets", normalizedRelative),
                Path.Combine(AppContext.BaseDirectory, normalizedRelative),
                Path.Combine(Environment.CurrentDirectory, "Assets", normalizedRelative)
            }
            For Each candidate In candidates
                If File.Exists(candidate) Then Return New Icon(candidate)
            Next
            Return Nothing
        End Function
    End Class
End Namespace
