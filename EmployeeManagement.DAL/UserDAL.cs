using System;
using System.Data;
using System.Data.SqlClient;
using EmployeeManagement.BLL.Models;

namespace EmployeeManagement.DAL
{
    /// <summary>
    /// UserDAL - Data Access Layer for user authentication.
    /// Uses ADO.NET (SqlConnection, SqlCommand, SqlDataReader)
    /// to interact with the Users table via stored procedures.
    ///
    /// WHY: Keeps all authentication DB logic in one place,
    /// separating data access from business rules and UI.
    /// </summary>
    public class UserDAL
    {
        /// <summary>
        /// Validates login credentials against the database.
        /// Calls usp_UserLogin stored procedure.
        /// Returns a UserModel on success, or null on failure.
        /// </summary>
        /// <param name="username">The entered username.</param>
        /// <param name="passwordHash">SHA-256 hash of the entered password.</param>
        /// <returns>UserModel if valid, null if invalid.</returns>
        public UserModel Login(string username, string passwordHash)
        {
            UserModel user = null;

            try
            {
                // Using block ensures SqlConnection is disposed even on exception
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_UserLogin", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parameterized query - prevents SQL injection
                    cmd.Parameters.AddWithValue("@Username",     username);
                    cmd.Parameters.AddWithValue("@PasswordHash", passwordHash);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            user = new UserModel
                            {
                                UserId   = Convert.ToInt32(reader["UserId"]),
                                Username = reader["Username"].ToString(),
                                FullName = reader["FullName"].ToString(),
                                Email    = reader["Email"].ToString(),
                                Role     = reader["Role"].ToString(),
                                IsActive = Convert.ToBoolean(reader["IsActive"])
                            };
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                // Re-throw with context so BLL can handle/log appropriately
                throw new Exception("Database error during login: " + ex.Message, ex);
            }

            return user;
        }
    }
}
