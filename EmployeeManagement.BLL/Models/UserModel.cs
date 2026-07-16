using System;

namespace EmployeeManagement.BLL.Models
{
    /// <summary>
    /// UserModel - Business entity representing an application user.
    /// Maps to the Users table in EmployeeDB.
    ///
    /// WHY: Provides a strongly-typed object to carry user data
    /// between the DAL and the Presentation Layer without
    /// exposing raw DataRow or DataTable objects to the UI.
    /// </summary>
    public class UserModel
    {
        public int      UserId        { get; set; }
        public string   Username      { get; set; }
        public string   PasswordHash  { get; set; }
        public string   FullName      { get; set; }
        public string   Email         { get; set; }
        public string   Role          { get; set; }
        public bool     IsActive      { get; set; }
        public DateTime? LastLoginDate { get; set; }
        public DateTime  CreatedDate  { get; set; }
    }
}
