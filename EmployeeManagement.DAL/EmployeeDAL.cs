using System;
using System.Data;
using System.Data.SqlClient;
using EmployeeManagement.DAL.Models;

namespace EmployeeManagement.DAL
{
    /// <summary>
    /// EmployeeDAL - Data Access Layer for Employee CRUD operations.
    /// The most complex DAL class - handles: insert, update, delete, view,
    /// search, filter, sort, pagination, status toggle, and duplicate checks.
    ///
    /// WHY: Isolates all employee-related SQL from UI and BLL.
    /// Uses OUTPUT parameter for pagination total records count.
    /// Uses SqlDataAdapter + DataSet for paginated grid results.
    /// </summary>
    public class EmployeeDAL
    {
        /// <summary>
        /// Gets a paginated, filtered, searchable, sortable list of employees.
        /// Returns a DataSet with:
        ///   Table[0] = Employee rows (current page)
        ///   The TotalRecords OUTPUT param is retrieved from SQL.
        /// </summary>
        public (DataTable Employees, int TotalRecords) GetAllEmployees(
            string searchTerm    = null,
            int?   departmentId  = null,
            int?   designationId = null,
            string gender        = null,
            bool?  isActive      = null,
            DateTime? joiningFrom = null,
            DateTime? joiningTo   = null,
            string sortColumn    = "CreatedDate",
            string sortOrder     = "DESC",
            int    pageNumber    = 1,
            int    pageSize      = 10)
        {
            DataTable dt           = new DataTable();
            int       totalRecords = 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionManager.GetConnectionString()))
                using (SqlCommand cmd = new SqlCommand("usp_GetAllEmployees", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Search and filter parameters
                    cmd.Parameters.AddWithValue("@SearchTerm",
                        string.IsNullOrWhiteSpace(searchTerm) ? (object)DBNull.Value : searchTerm.Trim());
                    cmd.Parameters.AddWithValue("@DepartmentId",
                        departmentId.HasValue ? (object)departmentId.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@DesignationId",
                        designationId.HasValue ? (object)designationId.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Gender",
                        string.IsNullOrWhiteSpace(gender) ? (object)DBNull.Value : gender.Trim());
                    cmd.Parameters.AddWithValue("@IsActive",
                        isActive.HasValue ? (object)isActive.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@JoiningFrom",
                        joiningFrom.HasValue ? (object)joiningFrom.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@JoiningTo",
                        joiningTo.HasValue ? (object)joiningTo.Value : DBNull.Value);

                    // Sort parameters
                    cmd.Parameters.AddWithValue("@SortColumn", sortColumn ?? "CreatedDate");
                    cmd.Parameters.AddWithValue("@SortOrder",  sortOrder ?? "DESC");

                    // Pagination parameters
                    cmd.Parameters.AddWithValue("@PageNumber", pageNumber);
                    cmd.Parameters.AddWithValue("@PageSize",   pageSize);

                    // OUTPUT parameter for total records count
                    SqlParameter totalParam = new SqlParameter("@TotalRecords", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    cmd.Parameters.Add(totalParam);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }

                    // Read output parameter after command execution
                    totalRecords = totalParam.Value != DBNull.Value
                                   ? Convert.ToInt32(totalParam.Value)
                                   : 0;
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error retrieving employees: " + ex.Message, ex);
            }

            return (dt, totalRecords);
        }

        /// <summary>
        /// Gets a single employee's complete profile by EmployeeId.
        /// </summary>
        public EmployeeModel GetEmployeeById(int employeeId)
        {
            EmployeeModel model = null;

            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_GetEmployeeById", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EmployeeId", employeeId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            model = MapReaderToEmployee(reader);
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error retrieving employee: " + ex.Message, ex);
            }

            return model;
        }

        /// <summary>
        /// Auto-generates the next employee code (e.g., EMP-00011).
        /// </summary>
        public string GenerateEmployeeCode()
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_GenerateEmployeeCode", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    object result = cmd.ExecuteScalar();
                    return result?.ToString() ?? "EMP-00001";
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error generating employee code: " + ex.Message, ex);
            }
        }

        /// <summary>
        /// Inserts a new employee. Returns (Result, Message).
        /// -1 = duplicate email, -2 = duplicate mobile, positive = EmployeeId.
        /// </summary>
        public (int Result, string Message) InsertEmployee(EmployeeModel model, string performedBy)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_InsertEmployee", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    AddEmployeeParameters(cmd, model);
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
                throw new Exception("Error inserting employee: " + ex.Message, ex);
            }

            return (0, "Unknown error.");
        }

        /// <summary>
        /// Updates an existing employee. Returns (Result, Message).
        /// </summary>
        public (int Result, string Message) UpdateEmployee(EmployeeModel model, string performedBy)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_UpdateEmployee", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EmployeeId", model.EmployeeId);
                    AddEmployeeParameters(cmd, model);
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
                throw new Exception("Error updating employee: " + ex.Message, ex);
            }

            return (0, "Unknown error.");
        }

        /// <summary>
        /// Deletes an employee. Returns (Result, Message).
        /// </summary>
        public (int Result, string Message) DeleteEmployee(int employeeId, string performedBy)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_DeleteEmployee", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EmployeeId",  employeeId);
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
                throw new Exception("Error deleting employee: " + ex.Message, ex);
            }

            return (0, "Unknown error.");
        }

        /// <summary>
        /// Toggles active/inactive status of an employee.
        /// </summary>
        public (int Result, string Message) UpdateEmployeeStatus(int employeeId, bool isActive, string performedBy)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_UpdateEmployeeStatus", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EmployeeId",  employeeId);
                    cmd.Parameters.AddWithValue("@IsActive",    isActive);
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
                throw new Exception("Error updating employee status: " + ex.Message, ex);
            }

            return (0, "Unknown error.");
        }

        /// <summary>
        /// Checks if an email is already in use by another employee.
        /// Returns true if duplicate.
        /// </summary>
        public bool IsEmailDuplicate(string email, int currentEmployeeId = 0)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_CheckDuplicateEmail", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Email",      email);
                    cmd.Parameters.AddWithValue("@EmployeeId", currentEmployeeId);

                    object result = cmd.ExecuteScalar();
                    return Convert.ToInt32(result) == 1;
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error checking duplicate email: " + ex.Message, ex);
            }
        }

        /// <summary>
        /// Checks if a mobile number is already in use by another employee.
        /// Returns true if duplicate.
        /// </summary>
        public bool IsMobileDuplicate(string mobile, int currentEmployeeId = 0)
        {
            try
            {
                using (SqlConnection conn = ConnectionManager.GetConnection())
                using (SqlCommand cmd = new SqlCommand("usp_CheckDuplicateMobile", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Mobile",     mobile);
                    cmd.Parameters.AddWithValue("@EmployeeId", currentEmployeeId);

                    object result = cmd.ExecuteScalar();
                    return Convert.ToInt32(result) == 1;
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error checking duplicate mobile: " + ex.Message, ex);
            }
        }

        /// <summary>
        /// Gets dashboard statistics (total, male, female, active, etc.).
        /// </summary>
        public DataRow GetDashboardStats()
        {
            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(ConnectionManager.GetConnectionString()))
                using (SqlCommand cmd = new SqlCommand("usp_GetDashboardStats", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
                return dt.Rows.Count > 0 ? dt.Rows[0] : null;
            }
            catch (SqlException ex)
            {
                throw new Exception("Error retrieving dashboard stats: " + ex.Message, ex);
            }
        }

        /// <summary>
        /// Gets the 5 latest employees for the dashboard.
        /// </summary>
        public DataTable GetLatestEmployees()
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionManager.GetConnectionString()))
                using (SqlCommand cmd = new SqlCommand("usp_GetLatestEmployees", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error retrieving latest employees: " + ex.Message, ex);
            }
            return dt;
        }

        /// <summary>
        /// Gets recent audit log entries for the dashboard activity feed.
        /// </summary>
        public DataTable GetRecentActivities()
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionManager.GetConnectionString()))
                using (SqlCommand cmd = new SqlCommand("usp_GetRecentActivities", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            catch (SqlException ex)
            {
                throw new Exception("Error retrieving recent activities: " + ex.Message, ex);
            }
            return dt;
        }

        /// <summary>
        /// Gets the salary report, grouped by department and designation.
        /// </summary>
        public DataTable GetSalaryReport(int? departmentId = null)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionManager.GetConnectionString()))
                using (SqlCommand cmd = new SqlCommand("usp_GetSalaryReport", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
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
                throw new Exception("Error retrieving salary report: " + ex.Message, ex);
            }
            return dt;
        }

        // ==========================================
        // PRIVATE HELPERS
        // ==========================================

        /// <summary>
        /// Maps a SqlDataReader row to an EmployeeModel.
        /// Reusable helper to avoid code duplication.
        /// </summary>
        private EmployeeModel MapReaderToEmployee(SqlDataReader reader)
        {
            return new EmployeeModel
            {
                EmployeeId      = Convert.ToInt32(reader["EmployeeId"]),
                EmployeeCode    = reader["EmployeeCode"].ToString(),
                FirstName       = reader["FirstName"].ToString(),
                LastName        = reader["LastName"].ToString(),
                FullName        = reader["FullName"].ToString(),
                Gender          = reader["Gender"].ToString(),
                DateOfBirth     = reader["DateOfBirth"] == DBNull.Value
                                    ? (DateTime?)null
                                    : Convert.ToDateTime(reader["DateOfBirth"]),
                Email           = reader["Email"].ToString(),
                Mobile          = reader["Mobile"].ToString(),
                DepartmentId    = Convert.ToInt32(reader["DepartmentId"]),
                DepartmentName  = reader["DepartmentName"].ToString(),
                DesignationId   = Convert.ToInt32(reader["DesignationId"]),
                DesignationName = reader["DesignationName"].ToString(),
                Salary          = Convert.ToDecimal(reader["Salary"]),
                JoiningDate     = Convert.ToDateTime(reader["JoiningDate"]),
                Experience      = reader["Experience"] == DBNull.Value
                                    ? 0
                                    : Convert.ToInt32(reader["Experience"]),
                Address         = reader["Address"].ToString(),
                City            = reader["City"].ToString(),
                State           = reader["State"].ToString(),
                Country         = reader["Country"].ToString(),
                ZipCode         = reader["ZipCode"].ToString(),
                IsActive        = Convert.ToBoolean(reader["IsActive"]),
                Photo           = reader["Photo"].ToString(),
                CreatedDate     = Convert.ToDateTime(reader["CreatedDate"]),
                UpdatedDate     = reader["UpdatedDate"] == DBNull.Value
                                    ? (DateTime?)null
                                    : Convert.ToDateTime(reader["UpdatedDate"])
            };
        }

        /// <summary>
        /// Adds common employee parameters to SqlCommand.
        /// Used by both InsertEmployee and UpdateEmployee to avoid duplication.
        /// </summary>
        private void AddEmployeeParameters(SqlCommand cmd, EmployeeModel model)
        {
            cmd.Parameters.AddWithValue("@EmployeeCode",  model.EmployeeCode);
            cmd.Parameters.AddWithValue("@FirstName",     model.FirstName.Trim());
            cmd.Parameters.AddWithValue("@LastName",      model.LastName.Trim());
            cmd.Parameters.AddWithValue("@Gender",        model.Gender);
            cmd.Parameters.AddWithValue("@DateOfBirth",
                model.DateOfBirth.HasValue ? (object)model.DateOfBirth.Value : DBNull.Value);
            cmd.Parameters.AddWithValue("@Email",         model.Email.Trim());
            cmd.Parameters.AddWithValue("@Mobile",        model.Mobile.Trim());
            cmd.Parameters.AddWithValue("@DepartmentId",  model.DepartmentId);
            cmd.Parameters.AddWithValue("@DesignationId", model.DesignationId);
            cmd.Parameters.AddWithValue("@Salary",        model.Salary);
            cmd.Parameters.AddWithValue("@JoiningDate",   model.JoiningDate);
            cmd.Parameters.AddWithValue("@Experience",    model.Experience);
            cmd.Parameters.AddWithValue("@Address",
                string.IsNullOrWhiteSpace(model.Address) ? (object)DBNull.Value : model.Address.Trim());
            cmd.Parameters.AddWithValue("@City",
                string.IsNullOrWhiteSpace(model.City) ? (object)DBNull.Value : model.City.Trim());
            cmd.Parameters.AddWithValue("@State",
                string.IsNullOrWhiteSpace(model.State) ? (object)DBNull.Value : model.State.Trim());
            cmd.Parameters.AddWithValue("@Country",
                string.IsNullOrWhiteSpace(model.Country) ? (object)DBNull.Value : model.Country.Trim());
            cmd.Parameters.AddWithValue("@ZipCode",
                string.IsNullOrWhiteSpace(model.ZipCode) ? (object)DBNull.Value : model.ZipCode.Trim());
            cmd.Parameters.AddWithValue("@IsActive",      model.IsActive);
            cmd.Parameters.AddWithValue("@Photo",
                string.IsNullOrWhiteSpace(model.Photo) ? (object)DBNull.Value : model.Photo.Trim());
        }
    }
}
