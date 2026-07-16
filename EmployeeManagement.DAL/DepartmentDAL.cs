using System;
using System.Data;
using System.Data.SqlClient;
using EmployeeManagement.BLL.Models;

namespace EmployeeManagement.DAL
{
    /// <summary>
    /// DepartmentDAL - Data Access Layer for Department CRUD operations.
    /// Uses ADO.NET with Stored Procedures.
    ///
    /// WHY: Encapsulates all SQL operations for departments.
    /// The BLL calls this class; the BLL never writes raw SQL.
    /// SqlDataAdapter is used here to fill DataTable for list views
    /// (efficient for read-only grid binding in GridView).
    /// </summary>
    public class DepartmentDAL
    {
        /// <summary>
        /// Retrieves all departments with optional search term.
        /// Returns a DataTable for easy GridView binding.
        /// Uses SqlDataAdapter (fills a DataTable without a reader loop).
        /// </summary>
        public DataTable GetAllDepartments(string searchTerm = null)
        {
            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionManager.GetConnectionString()))
                using (SqlCommand cmd = new SqlCommand("usp_GetAllDepartments", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SearchTerm",
                        string.IsNullOrWhiteSpace(searchTerm) ? (object)DBNull.Value : searchTerm.Trim());

                    // SqlDataAdapter fills the DataTable without manually opening the connection
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error retrieving departments: " + ex.Message, ex);
            }

            return dt;
        }

        /// <summary>
        /// Retrieves a single department by its ID.
        /// Returns a DepartmentModel or null.
        /// </summary>
        public DepartmentModel GetDepartmentById(int departmentId)
        {
            DepartmentModel model = null;

            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_GetDepartmentById", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DepartmentId", departmentId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            model = new DepartmentModel
                            {
                                DepartmentId   = Convert.ToInt32(reader["DepartmentId"]),
                                DepartmentName = reader["DepartmentName"].ToString(),
                                Description    = reader["Description"].ToString(),
                                IsActive       = Convert.ToBoolean(reader["IsActive"]),
                                CreatedDate    = Convert.ToDateTime(reader["CreatedDate"]),
                                UpdatedDate    = reader["UpdatedDate"] == DBNull.Value
                                                    ? (DateTime?)null
                                                    : Convert.ToDateTime(reader["UpdatedDate"])
                            };
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error retrieving department: " + ex.Message, ex);
            }

            return model;
        }

        /// <summary>
        /// Inserts a new department. Returns result code and message.
        /// -1 = duplicate name; positive int = new DepartmentId.
        /// </summary>
        public (int Result, string Message) InsertDepartment(DepartmentModel model, string performedBy)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_InsertDepartment", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DepartmentName", model.DepartmentName.Trim());
                    cmd.Parameters.AddWithValue("@Description",
                        string.IsNullOrWhiteSpace(model.Description) ? (object)DBNull.Value : model.Description.Trim());
                    cmd.Parameters.AddWithValue("@IsActive",     model.IsActive);
                    cmd.Parameters.AddWithValue("@PerformedBy",  performedBy);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int result      = Convert.ToInt32(reader["Result"]);
                            string message  = reader["Message"].ToString();
                            return (result, message);
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error inserting department: " + ex.Message, ex);
            }

            return (0, "Unknown error.");
        }

        /// <summary>
        /// Updates an existing department. Returns result code and message.
        /// </summary>
        public (int Result, string Message) UpdateDepartment(DepartmentModel model, string performedBy)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_UpdateDepartment", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DepartmentId",   model.DepartmentId);
                    cmd.Parameters.AddWithValue("@DepartmentName", model.DepartmentName.Trim());
                    cmd.Parameters.AddWithValue("@Description",
                        string.IsNullOrWhiteSpace(model.Description) ? (object)DBNull.Value : model.Description.Trim());
                    cmd.Parameters.AddWithValue("@IsActive",    model.IsActive);
                    cmd.Parameters.AddWithValue("@PerformedBy", performedBy);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                            return (Convert.ToInt32(reader["Result"]), reader["Message"].ToString());
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error updating department: " + ex.Message, ex);
            }

            return (0, "Unknown error.");
        }

        /// <summary>
        /// Deletes a department. Returns result code and message.
        /// -1 = employees exist in this department.
        /// </summary>
        public (int Result, string Message) DeleteDepartment(int departmentId, string performedBy)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_DeleteDepartment", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DepartmentId", departmentId);
                    cmd.Parameters.AddWithValue("@PerformedBy",  performedBy);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                            return (Convert.ToInt32(reader["Result"]), reader["Message"].ToString());
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error deleting department: " + ex.Message, ex);
            }

            return (0, "Unknown error.");
        }

        /// <summary>
        /// Returns all active departments as a DataTable for dropdown binding.
        /// </summary>
        public DataTable GetActiveDepartmentsForDropdown()
        {
            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionManager.GetConnectionString()))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT DepartmentId, DepartmentName FROM Departments WHERE IsActive = 1 ORDER BY DepartmentName", conn))
                {
                    cmd.CommandType = CommandType.Text;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error retrieving departments for dropdown: " + ex.Message, ex);
            }

            return dt;
        }
    }
}
