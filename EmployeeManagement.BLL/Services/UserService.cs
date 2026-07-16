using System;
using System.Security.Cryptography;
using System.Text;
using EmployeeManagement.BLL.Models;
using EmployeeManagement.DAL;

namespace EmployeeManagement.BLL.Services
{
    /// <summary>
    /// UserService - Business Logic Layer for Authentication.
    ///
    /// WHY: Handles password hashing (security), input validation,
    /// and calls the DAL. The UI (code-behind) never hashes passwords
    /// or touches SQL - that's the BLL's job.
    /// </summary>
    public class UserService
    {
        private readonly UserDAL _userDAL;

        public UserService()
        {
            _userDAL = new UserDAL();
        }

        /// <summary>
        /// Authenticates a user. Hashes the password using SHA-256
        /// before passing to DAL. Returns UserModel or null.
        /// </summary>
        /// <param name="username">The username entered on the login form.</param>
        /// <param name="password">The plain-text password entered on the login form.</param>
        /// <returns>UserModel on success, null on invalid credentials.</returns>
        public UserModel Login(string username, string password)
        {
            // Input validation
            if (string.IsNullOrWhiteSpace(username))
                throw new ArgumentException("Username is required.");
            if (string.IsNullOrWhiteSpace(password))
                throw new ArgumentException("Password is required.");

            // Hash the password using SHA-256 before DB comparison
            string passwordHash = ComputeSHA256Hash(password);

            return _userDAL.Login(username.Trim(), passwordHash);
        }

        /// <summary>
        /// Computes SHA-256 hash of a plain text string.
        /// Used for password storage and comparison.
        ///
        /// NOTE: In a production system, use BCrypt or PBKDF2
        /// with a salt for better security. SHA-256 is used here
        /// for simplicity in a demo environment.
        /// </summary>
        public static string ComputeSHA256Hash(string input)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] inputBytes  = Encoding.UTF8.GetBytes(input);
                byte[] hashBytes   = sha256.ComputeHash(inputBytes);

                // Convert to lowercase hex string
                StringBuilder sb = new StringBuilder();
                foreach (byte b in hashBytes)
                    sb.Append(b.ToString("x2"));

                return sb.ToString();
            }
        }
    }
}
