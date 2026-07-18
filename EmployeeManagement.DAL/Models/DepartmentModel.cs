using System;

namespace EmployeeManagement.DAL.Models
{
    /// <summary>
    /// DepartmentModel - Business entity for Department data.
    /// Maps to the Departments table in EmployeeDB.
    /// Used to pass data between DAL and Presentation Layer.
    /// </summary>
    public class DepartmentModel
    {
        public int       DepartmentId   { get; set; }
        public string    DepartmentName { get; set; }
        public string    Description    { get; set; }
        public bool      IsActive       { get; set; } = true;
        public int       EmployeeCount  { get; set; }
        public DateTime  CreatedDate    { get; set; }
        public DateTime? UpdatedDate    { get; set; }
    }
}
