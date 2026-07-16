using System;
using System.Configuration;
using System.Data.SqlClient;

namespace EmployeeManagement.DAL
{
    /// <summary>
    /// ConnectionManager - Data Access Layer Helper
    /// Provides a centralized method to get a valid,
    /// open SqlConnection using the connection string from Web.config.
    ///
    /// WHY: Centralizing connection creation avoids repetition,
    /// ensures the same config key is always used, and makes
    /// it easy to swap connection strings in one place.
    /// </summary>
    public static class ConnectionManager
    {
        // Read connection string from Web.config / App.config
        private static readonly string _connectionString =
            ConfigurationManager.ConnectionStrings["EmployeeDBConnection"]?.ConnectionString
            ?? throw new InvalidOperationException("Connection string 'EmployeeDBConnection' not found in configuration.");

        /// <summary>
        /// Returns an open SqlConnection.
        /// IMPORTANT: The caller is responsible for disposing the connection.
        /// Always use inside a 'using' block:
        ///   using (SqlConnection conn = ConnectionManager.GetConnection()) { ... }
        /// </summary>
        public static SqlConnection GetConnection()
        {
            SqlConnection connection = new SqlConnection(_connectionString);
            connection.Open();
            return connection;
        }

        /// <summary>
        /// Returns just the connection string (for SqlDataAdapter scenarios).
        /// </summary>
        public static string GetConnectionString()
        {
            return _connectionString;
        }
    }
}
