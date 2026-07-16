using System;
using System.Data;
using System.Data.SqlClient;
using EmployeeManagement.BLL.Models;

namespace EmployeeManagement.DAL
{
    /// <summary>
    /// DesignationDAL - Data Access Layer for Designation CRUD operations.
    /// Designations belong to Departments (parent-child relationship).
    ///
    /// WHY: Keeps all designation SQL operations encapsulated.
    /// Uses SqlDataReader for single-row reads (lightweight/efficient)
    /// and SqlDataAdapter for list reads (bulk/table operations).
    /// </summary>
    public class DesignationDAL
    {
        /// <summary>
        /// Retrieves all designations with optional search term and department filter.
        /// </summary>
        public DataTable GetAllDesignations(string searchTerm = null, int? departmentId = null)
        {
            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionManager.GetConnectionString()))
                using (SqlCommand cmd = new SqlCommand("usp_GetAllDesignations", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SearchTerm",
                        string.IsNullOrWhiteSpace(searchTerm) ? (object)DBNull.Value : searchTerm.Trim());
                    cmd.Parameters.AddWithValue("@DepartmentId",
                        departmentId.HasValue ? (object)departmentId.Value : DBNull.Value);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error retrieving designations: " + ex.Message, ex);
            }

            return dt;
        }

        /// <summary>
        /// Gets a single designation by ID. Returns DesignationModel or null.
        /// </summary>
        public DesignationModel GetDesignationById(int designationId)
        {
            DesignationModel model = null;

            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_GetDesignationById", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DesignationId", designationId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            model = new DesignationModel
                            {
                                DesignationId   = Convert.ToInt32(reader["DesignationId"]),
                                DesignationName = reader["DesignationName"].ToString(),
                                DepartmentId    = Convert.ToInt32(reader["DepartmentId"]),
                                DepartmentName  = reader["DepartmentName"].ToString(),
                                Description     = reader["Description"].ToString(),
                                IsActive        = Convert.ToBoolean(reader["IsActive"]),
                                CreatedDate     = Convert.ToDateTime(reader["CreatedDate"]),
                                UpdatedDate     = reader["UpdatedDate"] == DBNull.Value
                                                    ? (DateTime?)null
                                                    : Convert.ToDateTime(reader["UpdatedDate"])
                            };
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error retrieving designation: " + ex.Message, ex);
            }

            return model;
        }

        /// <summary>
        /// Gets all active designations for a specific department (for cascading dropdown).
        /// </summary>
        public DataTable GetDesignationsByDepartment(int departmentId)
        {
            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionManager.GetConnectionString()))
                using (SqlCommand cmd = new SqlCommand("usp_GetDesignationsByDept", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DepartmentId", departmentId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error retrieving designations by department: " + ex.Message, ex);
            }

            return dt;
        }

        /// <summary>
        /// Inserts a new designation. Returns (Result, Message).
        /// </summary>
        public (int Result, string Message) InsertDesignation(DesignationModel model, string performedBy)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_InsertDesignation", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DesignationName", model.DesignationName.Trim());
                    cmd.Parameters.AddWithValue("@DepartmentId",    model.DepartmentId);
                    cmd.Parameters.AddWithValue("@Description",
                        string.IsNullOrWhiteSpace(model.Description) ? (object)DBNull.Value : model.Description.Trim());
                    cmd.Parameters.AddWithValue("@IsActive",     model.IsActive);
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
                throw new Exception("Error inserting designation: " + ex.Message, ex);
            }

            return (0, "Unknown error.");
        }

        /// <summary>
        /// Updates an existing designation. Returns (Result, Message).
        /// </summary>
        public (int Result, string Message) UpdateDesignation(DesignationModel model, string performedBy)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_UpdateDesignation", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DesignationId",   model.DesignationId);
                    cmd.Parameters.AddWithValue("@DesignationName", model.DesignationName.Trim());
                    cmd.Parameters.AddWithValue("@DepartmentId",    model.DepartmentId);
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
                throw new Exception("Error updating designation: " + ex.Message, ex);
            }

            return (0, "Unknown error.");
        }

        /// <summary>
        /// Deletes a designation. Returns (Result, Message).
        /// -1 if employees are assigned.
        /// </summary>
        public (int Result, string Message) DeleteDesignation(int designationId, string performedBy)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_DeleteDesignation", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DesignationId", designationId);
                    cmd.Parameters.AddWithValue("@PerformedBy",   performedBy);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                            return (Convert.ToInt32(reader["Result"]), reader["Message"].ToString());
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error deleting designation: " + ex.Message, ex);
            }

            return (0, "Unknown error.");
        }
    }
}
