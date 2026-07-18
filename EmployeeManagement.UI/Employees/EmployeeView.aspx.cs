using System;
using System.Web.UI;
using EmployeeManagement.DAL.Models;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Employees
{
    /// <summary>
    /// EmployeeView.aspx.cs - Employee Profile view code-behind.
    /// Loads and displays a complete employee profile by ID.
    /// </summary>
    public partial class EmployeeView : Page
    {
        private readonly EmployeeService _employeeService = new EmployeeService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int empId;
                if (!int.TryParse(Request.QueryString["id"], out empId) || empId <= 0)
                {
                    Response.Redirect("EmployeeList.aspx", true);
                    return;
                }

                LoadEmployee(empId);
            }
        }

        private void LoadEmployee(int employeeId)
        {
            try
            {
                EmployeeModel emp = _employeeService.GetEmployeeById(employeeId);
                if (emp == null)
                {
                    Response.Redirect("EmployeeList.aspx", true);
                    return;
                }

                // Header
                litFullName.Text    = emp.FullName;
                litDesignation.Text = emp.DesignationName;
                litDepartment.Text  = emp.DepartmentName;
                litEmpCode.Text     = emp.EmployeeCode;
                litInitials.Text    = GetInitials(emp.FullName);

                // Photo
                if (!string.IsNullOrEmpty(emp.Photo))
                {
                    imgPhoto.ImageUrl = $"/Images/Uploads/{emp.Photo}";
                    imgPhoto.Visible  = true;
                    pnlAvatar.Visible = false;
                }

                // Status badge
                string badgeClass = emp.IsActive ? "badge-active" : "badge-inactive";
                string badgeText  = emp.IsActive ? "Active" : "Inactive";
                pnlStatusBadge.Controls.Add(
                    new System.Web.UI.LiteralControl(
                        $"<span class='badge {badgeClass}'>{badgeText}</span>"));

                // Edit link
                hlEdit.NavigateUrl = $"EmployeeForm.aspx?id={employeeId}";

                // Personal tab
                litFullName2.Text = emp.FullName;
                litGender.Text    = emp.Gender;
                litDob.Text       = emp.DateOfBirth.HasValue
                                    ? emp.DateOfBirth.Value.ToString("dd MMM yyyy") : "N/A";
                litAge.Text       = emp.Age > 0 ? emp.Age.ToString() : "N/A";
                litEmailLink.Text = emp.Email;
                litEmail.Text     = emp.Email;
                litMobile.Text    = emp.Mobile;

                // Work tab
                litDept2.Text        = emp.DepartmentName;
                litDesig2.Text       = emp.DesignationName;
                litSalary.Text       = emp.Salary.ToString("N2");
                litJoiningDate.Text  = emp.JoiningDate.ToString("dd MMM yyyy");
                litExperience.Text   = emp.Experience.ToString();
                litCreatedDate.Text  = emp.CreatedDate.ToString("dd MMM yyyy HH:mm");
                litUpdatedDate.Text  = emp.UpdatedDate.HasValue
                                       ? emp.UpdatedDate.Value.ToString("dd MMM yyyy HH:mm") : "N/A";

                // Address tab
                litAddress.Text = string.IsNullOrWhiteSpace(emp.Address) ? "N/A" : emp.Address;
                litCity.Text    = string.IsNullOrWhiteSpace(emp.City)    ? "N/A" : emp.City;
                litState.Text   = string.IsNullOrWhiteSpace(emp.State)   ? "N/A" : emp.State;
                litCountry.Text = string.IsNullOrWhiteSpace(emp.Country) ? "N/A" : emp.Country;
                litZipCode.Text = string.IsNullOrWhiteSpace(emp.ZipCode) ? "N/A" : emp.ZipCode;
            }
            catch (Exception ex)
            {
                ((SiteMaster)this.Master)?.ShowError("Error loading employee profile: " + ex.Message);
            }
        }

        private string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "?";
            var parts = fullName.Trim().Split(' ');
            return (parts.Length >= 2
                ? parts[0][0].ToString() + parts[1][0].ToString()
                : fullName.Substring(0, Math.Min(2, fullName.Length))).ToUpper();
        }
    }
}
