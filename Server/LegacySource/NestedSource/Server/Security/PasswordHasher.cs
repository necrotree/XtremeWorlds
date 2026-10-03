using System;
using System.Security.Cryptography;

namespace Server
{

    public static class PasswordHasher
    {
        private const int Iterations = 210000;
        private const int SaltLength = 16;
        private const int HashLength = 32;

        public static (string Hash, string Salt) Create(string password)
        {
            byte[] salt = RandomNumberGenerator.GetBytes(SaltLength);
            byte[] hash = Rfc2898DeriveBytes.Pbkdf2(password, salt, Iterations, HashAlgorithmName.SHA256, HashLength);
            return (Convert.ToBase64String(hash), Convert.ToBase64String(salt));
        }

        public static bool Verify(string password, string expectedHash, string saltText)
        {
            byte[] salt = Convert.FromBase64String(saltText);
            byte[] actual = Rfc2898DeriveBytes.Pbkdf2(password, salt, Iterations, HashAlgorithmName.SHA256, HashLength);
            return CryptographicOperations.FixedTimeEquals(actual, Convert.FromBase64String(expectedHash));
        }
    }
}