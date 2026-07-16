using System;
using System.Data;
using EmployeeManagement.BLL.Models;
using EmployeeManagement.DAL;

namespace EmployeeManagement.BLL.Services
{
    /// <summary>
    /// DepartmentService - Business Logic Layer for Department operations.
    ///
    /// WHY: Centralizes business rules like input sanitization,
    /// validation, and calling the DAL. The UI passes user input
    /// to this service and gets back clean results.
    /// </summary>
    public class DepartmentService
    {
        private readonly DepartmentDAL _departmentDAL;

        public DepartmentService()
        {
            _departmentDAL = new DepartmentDAL();
        }

        /// <summary>
        /// Retrieves all departments (optionally filtered by search term).
        /// Returns a DataTable for direct GridView binding.
        /// </summary>
        public DataTable GetAllDepartments(string searchTerm = null)
        {
            return _departmentDAL.GetAllDepartments(searchTerm);
        }

        /// <summary>
        /// Retrieves a single department by ID for editing.
        /// </summary>
        public DepartmentModel GetDepartmentById(int departmentId)
        {
            if (departmentId <= 0)
                throw new ArgumentException("Invalid department ID.");

            return _departmentDAL.GetDepartmentById(departmentId);
        }

        /// <summary>
        /// Validates and inserts a new department.
        /// Returns (Result, Message) tuple.
        /// </summary>
        public (int Result, string Message) AddDepartment(DepartmentModel model, string performedBy)
        {
            // Business rule: Name is required
            if (string.IsNullOrWhiteSpace(model.DepartmentName))
                return (-99, "Department name is required.");

            // Business rule: Max 100 chars
            if (model.DepartmentName.Trim().Length > 100)
                return (-99, "Department name cannot exceed 100 characters.");

            return _departmentDAL.InsertDepartment(model, performedBy);
        }

        /// <summary>
        /// Validates and updates an existing department.
        /// </summary>
        public (int Result, string Message) UpdateDepartment(DepartmentModel model, string performedBy)
        {
            if (model.DepartmentId <= 0)
                return (-99, "Invalid department ID.");

            if (string.IsNullOrWhiteSpace(model.DepartmentName))
                return (-99, "Department name is required.");

            return _departmentDAL.UpdateDepartment(model, performedBy);
        }

        /// <summary>
        /// Deletes a department (fails if employees are assigned).
        /// </summary>
        public (int Result, string Message) DeleteDepartment(int departmentId, string performedBy)
        {
            if (departmentId <= 0)
                return (-99, "Invalid department ID.");

            return _departmentDAL.DeleteDepartment(departmentId, performedBy);
        }

        /// <summary>
        /// Returns active departments for dropdown binding (e.g., in Employee form).
        /// </summary>
        public DataTable GetActiveDepartmentsForDropdown()
        {
            return _departmentDAL.GetActiveDepartmentsForDropdown();
        }
    }
}
