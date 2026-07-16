using System;

namespace EmployeeManagement.BLL.Models
{
    /// <summary>
    /// EmployeeModel - Business entity for complete Employee profile.
    /// Maps to the Employees table (with joined Department and Designation names).
    ///
    /// WHY: This model is the central data object of the application.
    /// It is used for display, insert, update, validation, and reporting.
    /// Having all fields in one model simplifies data binding to form controls.
    /// </summary>
    public class EmployeeModel
    {
        // ---- Identity ----
        public int       EmployeeId      { get; set; }
        public string    EmployeeCode    { get; set; }

        // ---- Personal ----
        public string    FirstName       { get; set; }
        public string    LastName        { get; set; }
        public string    FullName        { get; set; }   // Computed: FirstName + " " + LastName
        public string    Gender          { get; set; }
        public DateTime? DateOfBirth     { get; set; }
        public string    Email           { get; set; }
        public string    Mobile          { get; set; }

        // ---- Work ----
        public int       DepartmentId    { get; set; }
        public string    DepartmentName  { get; set; }
        public int       DesignationId   { get; set; }
        public string    DesignationName { get; set; }
        public decimal   Salary          { get; set; }
        public DateTime  JoiningDate     { get; set; }
        public int       Experience      { get; set; }  // in years

        // ---- Address ----
        public string    Address         { get; set; }
        public string    City            { get; set; }
        public string    State           { get; set; }
        public string    Country         { get; set; }
        public string    ZipCode         { get; set; }

        // ---- Status & Photo ----
        public bool      IsActive        { get; set; } = true;
        public string    Photo           { get; set; }  // Relative path e.g. "Images/Uploads/EMP-00001.jpg"

        // ---- Audit ----
        public DateTime  CreatedDate     { get; set; }
        public DateTime? UpdatedDate     { get; set; }

        // ---- Computed helper ----
        /// <summary>
        /// Returns the age of the employee based on DateOfBirth.
        /// </summary>
        public int Age
        {
            get
            {
                if (!DateOfBirth.HasValue) return 0;
                var today = DateTime.Today;
                var age   = today.Year - DateOfBirth.Value.Year;
                if (DateOfBirth.Value.Date > today.AddYears(-age)) age--;
                return age;
            }
        }

        /// <summary>
        /// Returns "Active" or "Inactive" string for display.
        /// </summary>
        public string StatusText => IsActive ? "Active" : "Inactive";

        /// <summary>
        /// Formatted salary for display (Indian currency style).
        /// </summary>
        public string SalaryFormatted => Salary.ToString("N2");
    }
}
