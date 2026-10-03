Imports System.Security.Cryptography

Public Module PasswordHasher
    Private Const Iterations As Integer = 210000
    Private Const SaltLength As Integer = 16
    Private Const HashLength As Integer = 32

    Public Function Create(password As String) As (Hash As String, Salt As String)
        Dim salt = RandomNumberGenerator.GetBytes(SaltLength)
        Dim hash = Rfc2898DeriveBytes.Pbkdf2(password, salt, Iterations, HashAlgorithmName.SHA256, HashLength)
        Return (Convert.ToBase64String(hash), Convert.ToBase64String(salt))
    End Function

    Public Function Verify(password As String, expectedHash As String, saltText As String) As Boolean
        Dim salt = Convert.FromBase64String(saltText)
        Dim actual = Rfc2898DeriveBytes.Pbkdf2(password, salt, Iterations, HashAlgorithmName.SHA256, HashLength)
        Return CryptographicOperations.FixedTimeEquals(actual, Convert.FromBase64String(expectedHash))
    End Function
End Module
