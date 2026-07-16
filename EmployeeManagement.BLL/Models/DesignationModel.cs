using System;

namespace EmployeeManagement.BLL.Models
{
    /// <summary>
    /// DesignationModel - Business entity for Designation data.
    /// A designation belongs to exactly one Department.
    /// Maps to the Designations table in EmployeeDB.
    /// </summary>
    public class DesignationModel
    {
        public int       DesignationId   { get; set; }
        public string    DesignationName { get; set; }
        public int       DepartmentId    { get; set; }
        public string    DepartmentName  { get; set; }
        public string    Description     { get; set; }
        public bool      IsActive        { get; set; } = true;
        public DateTime  CreatedDate     { get; set; }
        public DateTime? UpdatedDate     { get; set; }
    }
}
