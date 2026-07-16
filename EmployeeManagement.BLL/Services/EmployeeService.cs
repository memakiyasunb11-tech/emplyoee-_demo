using System;
using System.Data;
using System.Text.RegularExpressions;
using EmployeeManagement.BLL.Models;
using EmployeeManagement.DAL;

namespace EmployeeManagement.BLL.Services
{
    /// <summary>
    /// EmployeeService - Business Logic Layer for Employee operations.
    /// Contains all business rules: validation, duplicate checks,
    /// code generation, and delegates persistence to EmployeeDAL.
    ///
    /// WHY: Centralizes complex validation rules (email format,
    /// phone format, salary range, duplicate checks) so they
    /// are NOT scattered across ASPX code-behind files.
    /// </summary>
    public class EmployeeService
    {
        private readonly EmployeeDAL _employeeDAL;

        public EmployeeService()
        {
            _employeeDAL = new EmployeeDAL();
        }

        // ==========================================
        // READ OPERATIONS
        // ==========================================

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
            return _employeeDAL.GetAllEmployees(
                searchTerm, departmentId, designationId, gender,
                isActive, joiningFrom, joiningTo,
                sortColumn, sortOrder, pageNumber, pageSize);
        }

        public EmployeeModel GetEmployeeById(int employeeId)
        {
            if (employeeId <= 0)
                throw new ArgumentException("Invalid employee ID.");

            return _employeeDAL.GetEmployeeById(employeeId);
        }

        public string GenerateEmployeeCode()
        {
            return _employeeDAL.GenerateEmployeeCode();
        }

        public DataRow GetDashboardStats()
        {
            return _employeeDAL.GetDashboardStats();
        }

        public DataTable GetLatestEmployees()
        {
            return _employeeDAL.GetLatestEmployees();
        }

        public DataTable GetRecentActivities()
        {
            return _employeeDAL.GetRecentActivities();
        }

        public DataTable GetSalaryReport(int? departmentId = null)
        {
            return _employeeDAL.GetSalaryReport(departmentId);
        }

        // ==========================================
        // WRITE OPERATIONS WITH VALIDATION
        // ==========================================

        /// <summary>
        /// Validates and inserts a new employee.
        /// Returns (Result, Message) with validation errors or DB result.
        /// </summary>
        public (int Result, string Message) AddEmployee(EmployeeModel model, string performedBy)
        {
            // Run validation
            var validationResult = ValidateEmployee(model);
            if (validationResult.Result < 0)
                return validationResult;

            // Check for duplicate email
            if (_employeeDAL.IsEmailDuplicate(model.Email))
                return (-1, "Email address is already registered with another employee.");

            // Check for duplicate mobile
            if (_employeeDAL.IsMobileDuplicate(model.Mobile))
                return (-2, "Mobile number is already registered with another employee.");

            return _employeeDAL.InsertEmployee(model, performedBy);
        }

        /// <summary>
        /// Validates and updates an existing employee.
        /// </summary>
        public (int Result, string Message) UpdateEmployee(EmployeeModel model, string performedBy)
        {
            if (model.EmployeeId <= 0)
                return (-99, "Invalid employee ID.");

            // Run validation
            var validationResult = ValidateEmployee(model);
            if (validationResult.Result < 0)
                return validationResult;

            // Check for duplicate email (exclude current employee)
            if (_employeeDAL.IsEmailDuplicate(model.Email, model.EmployeeId))
                return (-1, "Email address is already registered with another employee.");

            // Check for duplicate mobile (exclude current employee)
            if (_employeeDAL.IsMobileDuplicate(model.Mobile, model.EmployeeId))
                return (-2, "Mobile number is already registered with another employee.");

            return _employeeDAL.UpdateEmployee(model, performedBy);
        }

        /// <summary>
        /// Deletes an employee by ID.
        /// </summary>
        public (int Result, string Message) DeleteEmployee(int employeeId, string performedBy)
        {
            if (employeeId <= 0)
                return (-99, "Invalid employee ID.");

            return _employeeDAL.DeleteEmployee(employeeId, performedBy);
        }

        /// <summary>
        /// Toggles employee active/inactive status.
        /// </summary>
        public (int Result, string Message) UpdateEmployeeStatus(int employeeId, bool isActive, string performedBy)
        {
            if (employeeId <= 0)
                return (-99, "Invalid employee ID.");

            return _employeeDAL.UpdateEmployeeStatus(employeeId, isActive, performedBy);
        }

        // ==========================================
        // DUPLICATE CHECK (called from AJAX)
        // ==========================================

        public bool IsEmailDuplicate(string email, int currentEmployeeId = 0)
        {
            if (string.IsNullOrWhiteSpace(email)) return false;
            return _employeeDAL.IsEmailDuplicate(email.Trim(), currentEmployeeId);
        }

        public bool IsMobileDuplicate(string mobile, int currentEmployeeId = 0)
        {
            if (string.IsNullOrWhiteSpace(mobile)) return false;
            return _employeeDAL.IsMobileDuplicate(mobile.Trim(), currentEmployeeId);
        }

        // ==========================================
        // PRIVATE VALIDATION
        // ==========================================

        /// <summary>
        /// Validates an EmployeeModel. Returns (-99, errorMessage) on failure,
        /// or (1, "Valid") on success.
        /// </summary>
        private (int Result, string Message) ValidateEmployee(EmployeeModel model)
        {
            if (string.IsNullOrWhiteSpace(model.FirstName))
                return (-99, "First name is required.");

            if (string.IsNullOrWhiteSpace(model.LastName))
                return (-99, "Last name is required.");

            if (string.IsNullOrWhiteSpace(model.Email))
                return (-99, "Email address is required.");

            // Email format validation using regex
            if (!IsValidEmail(model.Email))
                return (-99, "Please enter a valid email address.");

            if (string.IsNullOrWhiteSpace(model.Mobile))
                return (-99, "Mobile number is required.");

            // Phone: 10-15 digits
            if (!IsValidPhone(model.Mobile))
                return (-99, "Please enter a valid mobile number (10-15 digits).");

            if (model.DepartmentId <= 0)
                return (-99, "Please select a department.");

            if (model.DesignationId <= 0)
                return (-99, "Please select a designation.");

            if (model.Salary < 0)
                return (-99, "Salary cannot be negative.");

            if (model.Salary > 9999999)
                return (-99, "Salary value seems too high. Please verify.");

            if (model.JoiningDate == DateTime.MinValue)
                return (-99, "Please enter the joining date.");

            if (model.JoiningDate > DateTime.Today)
                return (-99, "Joining date cannot be in the future.");

            if (model.DateOfBirth.HasValue && model.DateOfBirth.Value >= DateTime.Today)
                return (-99, "Date of birth must be in the past.");

            if (model.DateOfBirth.HasValue && model.JoiningDate < model.DateOfBirth.Value)
                return (-99, "Joining date cannot be before date of birth.");

            if (string.IsNullOrWhiteSpace(model.Gender))
                return (-99, "Please select gender.");

            return (1, "Valid");
        }

        /// <summary>
        /// Validates email format using a standard regex pattern.
        /// </summary>
        private bool IsValidEmail(string email)
        {
            string pattern = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";
            return Regex.IsMatch(email.Trim(), pattern, RegexOptions.IgnoreCase);
        }

        /// <summary>
        /// Validates phone number: 10-15 digits, optionally starting with +.
        /// </summary>
        private bool IsValidPhone(string phone)
        {
            string pattern = @"^\+?[0-9]{10,15}$";
            return Regex.IsMatch(phone.Trim(), pattern);
        }
    }
}
