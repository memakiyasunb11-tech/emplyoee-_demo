using System;
using System.Data;
using EmployeeManagement.BLL.Models;
using EmployeeManagement.DAL;

namespace EmployeeManagement.BLL.Services
{
    /// <summary>
    /// DesignationService - Business Logic Layer for Designation operations.
    /// Delegates data operations to DesignationDAL after validation.
    /// </summary>
    public class DesignationService
    {
        private readonly DesignationDAL _designationDAL;

        public DesignationService()
        {
            _designationDAL = new DesignationDAL();
        }

        public DataTable GetAllDesignations(string searchTerm = null, int? departmentId = null)
        {
            return _designationDAL.GetAllDesignations(searchTerm, departmentId);
        }

        public DesignationModel GetDesignationById(int designationId)
        {
            if (designationId <= 0)
                throw new ArgumentException("Invalid designation ID.");

            return _designationDAL.GetDesignationById(designationId);
        }

        public DataTable GetDesignationsByDepartment(int departmentId)
        {
            if (departmentId <= 0)
                throw new ArgumentException("Invalid department ID.");

            return _designationDAL.GetDesignationsByDepartment(departmentId);
        }

        public (int Result, string Message) AddDesignation(DesignationModel model, string performedBy)
        {
            if (string.IsNullOrWhiteSpace(model.DesignationName))
                return (-99, "Designation name is required.");

            if (model.DepartmentId <= 0)
                return (-99, "Please select a department.");

            return _designationDAL.InsertDesignation(model, performedBy);
        }

        public (int Result, string Message) UpdateDesignation(DesignationModel model, string performedBy)
        {
            if (model.DesignationId <= 0)
                return (-99, "Invalid designation ID.");

            if (string.IsNullOrWhiteSpace(model.DesignationName))
                return (-99, "Designation name is required.");

            if (model.DepartmentId <= 0)
                return (-99, "Please select a department.");

            return _designationDAL.UpdateDesignation(model, performedBy);
        }

        public (int Result, string Message) DeleteDesignation(int designationId, string performedBy)
        {
            if (designationId <= 0)
                return (-99, "Invalid designation ID.");

            return _designationDAL.DeleteDesignation(designationId, performedBy);
        }
    }
}
