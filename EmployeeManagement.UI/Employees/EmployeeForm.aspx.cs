using System;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using EmployeeManagement.DAL.Models;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Employees
{
    /// <summary>
    /// EmployeeForm.aspx.cs - Code-behind for Add/Edit Employee form.
    ///
    /// WHY: This is a dual-purpose page:
    /// - Without ?id= : Add new employee mode
    /// - With ?id=N   : Edit existing employee mode
    /// It handles: photo upload, department/designation binding,
    /// employee code auto-generation, and calling BLL to save.
    /// </summary>
    public partial class EmployeeForm : Page
    {
        private readonly EmployeeService   _employeeService   = new EmployeeService();
        private readonly DepartmentService _departmentService = new DepartmentService();
        private readonly DesignationService _designationService = new DesignationService();

        // Exposed to ASPX JS to pre-select designation in edit mode
        public string EditDesignationId { get; private set; } = "";

        // Determine if we are in edit mode
        private bool IsEditMode => !string.IsNullOrEmpty(Request.QueryString["id"]) && Request.QueryString["id"] != "0";
        private int  EmployeeId  => IsEditMode ? Convert.ToInt32(Request.QueryString["id"]) : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDepartments();

                if (IsEditMode)
                {
                    // Edit mode: load existing employee data
                    SetPageTitleEditMode();
                    LoadEmployeeForEdit(EmployeeId);
                }
                else
                {
                    // Add mode: auto-generate employee code
                    txtEmployeeCode.Text = _employeeService.GenerateEmployeeCode();
                }
            }
        }

        /// <summary>
        /// Sets page title controls to Edit mode text.
        /// </summary>
        private void SetPageTitleEditMode()
        {
            litPageTitle.Text  = "Edit Employee";
            litFormTitle.Text  = "Edit Employee";
            litBreadcrumb.Text = "Edit Employee";
            btnSave.Text       = "Update Employee";
        }

        /// <summary>
        /// Populates the Department dropdown.
        /// Designations are loaded via AJAX on department change.
        /// </summary>
        private void LoadDepartments()
        {
            try
            {
                DataTable dt = _departmentService.GetActiveDepartmentsForDropdown();
                ddlDepartment.DataSource     = dt;
                ddlDepartment.DataTextField  = "DepartmentName";
                ddlDepartment.DataValueField = "DepartmentId";
                ddlDepartment.DataBind();
                ddlDepartment.Items.Insert(0, new ListItem("-- Select Department --", ""));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading departments: " + ex.Message);
            }
        }

        /// <summary>
        /// Loads employee data into form fields for editing.
        /// </summary>
        private void LoadEmployeeForEdit(int employeeId)
        {
            try
            {
                EmployeeModel emp = _employeeService.GetEmployeeById(employeeId);
                if (emp == null)
                {
                    Response.Redirect("EmployeeList.aspx", true);
                    return;
                }

                // Store ID in hidden field
                hfEmployeeId.Value    = emp.EmployeeId.ToString();
                hfExistingPhoto.Value = emp.Photo;
                EditDesignationId     = emp.DesignationId.ToString();

                // Personal
                txtEmployeeCode.Text = emp.EmployeeCode;
                txtFirstName.Text    = emp.FirstName;
                txtLastName.Text     = emp.LastName;
                ddlGender.SelectedValue = emp.Gender;
                txtDateOfBirth.Text  = emp.DateOfBirth.HasValue
                                       ? emp.DateOfBirth.Value.ToString("yyyy-MM-dd") : "";
                txtExperience.Text   = emp.Experience.ToString();

                // Contact
                txtEmail.Text  = emp.Email;
                txtMobile.Text = emp.Mobile;

                // Work
                ddlDepartment.SelectedValue  = emp.DepartmentId.ToString();
                // Designation loaded via JS/AJAX after page load
                txtSalary.Text     = emp.Salary.ToString("F2");
                txtJoiningDate.Text = emp.JoiningDate.ToString("yyyy-MM-dd");

                // Address
                txtAddress.Text = emp.Address;
                txtCity.Text    = emp.City;
                txtState.Text   = emp.State;
                txtCountry.Text = emp.Country;
                txtZipCode.Text = emp.ZipCode;

                // Status
                chkIsActive.Checked = emp.IsActive;

                // Existing photo
                if (!string.IsNullOrEmpty(emp.Photo))
                {
                    litExistingPhoto.Text = $"<img src='/Images/Uploads/{emp.Photo}' id='imgPhotoPreview' class='photo-preview' alt='Employee Photo' />";
                }
            }
            catch (Exception ex)
            {
                ((SiteMaster)this.Master)?.ShowError("Error loading employee: " + ex.Message);
            }
        }

        /// <summary>
        /// Save button click handler.
        /// Collects form data, uploads photo if provided,
        /// and calls BLL to insert or update.
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            try
            {
                // Build the employee model from form inputs
                var model = new EmployeeModel
                {
                    EmployeeId    = int.TryParse(hfEmployeeId.Value, out int empId) ? empId : 0,
                    EmployeeCode  = txtEmployeeCode.Text.Trim(),
                    FirstName     = txtFirstName.Text.Trim(),
                    LastName      = txtLastName.Text.Trim(),
                    Gender        = ddlGender.SelectedValue,
                    DateOfBirth   = string.IsNullOrWhiteSpace(txtDateOfBirth.Text)
                                    ? (DateTime?)null
                                    : DateTime.Parse(txtDateOfBirth.Text),
                    Email         = txtEmail.Text.Trim(),
                    Mobile        = txtMobile.Text.Trim(),
                    DepartmentId  = int.TryParse(ddlDepartment.SelectedValue, out int deptId) ? deptId : 0,
                    DesignationId = int.TryParse(ddlDesignation.SelectedValue, out int desigId) ? desigId : 0,
                    Salary        = decimal.TryParse(txtSalary.Text, out decimal sal) ? sal : 0,
                    JoiningDate   = DateTime.Parse(txtJoiningDate.Text),
                    Experience    = int.TryParse(txtExperience.Text, out int exp) ? exp : 0,
                    Address       = txtAddress.Text.Trim(),
                    City          = txtCity.Text.Trim(),
                    State         = txtState.Text.Trim(),
                    Country       = txtCountry.Text.Trim(),
                    ZipCode       = txtZipCode.Text.Trim(),
                    IsActive      = chkIsActive.Checked,
                    Photo         = hfExistingPhoto.Value  // Keep existing photo by default
                };

                // Handle photo upload
                string uploadedPhotoName = HandlePhotoUpload(model.EmployeeCode);
                if (!string.IsNullOrEmpty(uploadedPhotoName))
                {
                    model.Photo = uploadedPhotoName;
                }

                string performedBy = Session["Username"]?.ToString() ?? "system";
                (int Result, string Message) result;

                if (IsEditMode)
                {
                    result = _employeeService.UpdateEmployee(model, performedBy);
                }
                else
                {
                    result = _employeeService.AddEmployee(model, performedBy);
                }

                if (result.Result > 0)
                {
                    // Success: redirect to list with message in query string
                    Response.Redirect($"EmployeeList.aspx?msg=success&action={(IsEditMode ? "updated" : "added")}", true);
                }
                else
                {
                    ((SiteMaster)this.Master)?.ShowError(result.Message);
                }
            }
            catch (Exception ex)
            {
                ((SiteMaster)this.Master)?.ShowError("Error saving employee: " + ex.Message);
            }
        }

        /// <summary>
        /// Handles photo file upload. Validates type and size,
        /// saves to ~/Images/Uploads/, returns filename.
        /// Returns empty string if no file uploaded.
        /// </summary>
        private string HandlePhotoUpload(string employeeCode)
        {
            if (fuPhoto.HasFile)
            {
                // Validate file type
                string ext = Path.GetExtension(fuPhoto.FileName).ToLower();
                string[] allowed = { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
                if (Array.IndexOf(allowed, ext) < 0)
                {
                    ((SiteMaster)this.Master)?.ShowError("Invalid photo format. Allowed: JPG, PNG, GIF, WEBP.");
                    return null;
                }

                // Validate file size (max 2MB)
                int maxSizeKB = Convert.ToInt32(
                    System.Configuration.ConfigurationManager.AppSettings["MaxPhotoSizeKB"] ?? "2048");
                if (fuPhoto.FileBytes.Length > maxSizeKB * 1024)
                {
                    ((SiteMaster)this.Master)?.ShowError($"Photo size exceeds {maxSizeKB / 1024}MB limit.");
                    return null;
                }

                // Generate unique filename: EMP-00001_timestamp.jpg
                string fileName   = $"{employeeCode}_{DateTime.Now:yyyyMMddHHmmss}{ext}";
                string uploadPath = Server.MapPath("~/Images/Uploads/");

                // Create directory if it doesn't exist
                if (!Directory.Exists(uploadPath))
                    Directory.CreateDirectory(uploadPath);

                fuPhoto.SaveAs(Path.Combine(uploadPath, fileName));
                return fileName;
            }

            return string.Empty;
        }
    }
}
