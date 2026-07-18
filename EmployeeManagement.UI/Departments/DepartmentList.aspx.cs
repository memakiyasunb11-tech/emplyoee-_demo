using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using EmployeeManagement.DAL.Models;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Departments
{
    /// <summary>
    /// DepartmentList.aspx.cs - Department management code-behind.
    /// Handles loading the GridView, search, and Save/Delete via modal form.
    ///
    /// WHY: The Add/Edit modal is a Bootstrap modal on the SAME page.
    /// Save is done via ASP.NET postback from within the modal form.
    /// Delete is done via AJAX HttpHandler (Handlers/DeleteDepartment.ashx).
    /// </summary>
    public partial class DepartmentList : Page
    {
        private readonly DepartmentService _departmentService = new DepartmentService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDepartments();
            }
        }

        /// <summary>
        /// Loads all departments (with optional search) into GridView.
        /// </summary>
        private void LoadDepartments(string searchTerm = null)
        {
            try
            {
                DataTable dt = _departmentService.GetAllDepartments(searchTerm);
                gvDepartments.DataSource = dt;
                gvDepartments.DataBind();
                deptCount.InnerText = dt.Rows.Count.ToString();
            }
            catch (Exception ex)
            {
                ((SiteMaster)this.Master)?.ShowError("Error loading departments: " + ex.Message);
            }
        }

        /// <summary>
        /// Handles Search button click.
        /// </summary>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadDepartments(txtSearch.Text.Trim());
        }

        /// <summary>
        /// Handles Reset button click.
        /// </summary>
        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            LoadDepartments();
        }

        /// <summary>
        /// Saves (insert or update) a department from the modal form.
        /// Determines mode by hfDeptId value (0 = insert, else update).
        /// </summary>
        protected void btnSaveDept_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            try
            {
                var model = new DepartmentModel
                {
                    DepartmentId   = int.TryParse(hfDeptId.Value, out int id) ? id : 0,
                    DepartmentName = txtDepartmentName.Text.Trim(),
                    Description    = txtDeptDescription.Text.Trim(),
                    IsActive       = chkDeptActive.Checked
                };

                string performedBy = Session["Username"]?.ToString() ?? "system";
                (int Result, string Message) result;

                if (model.DepartmentId == 0)
                {
                    // INSERT mode
                    result = _departmentService.AddDepartment(model, performedBy);
                }
                else
                {
                    // UPDATE mode
                    result = _departmentService.UpdateDepartment(model, performedBy);
                }

                if (result.Result > 0)
                {
                    ((SiteMaster)this.Master)?.ShowSuccess(result.Message);
                    // Clear modal fields
                    ClearModalFields();
                }
                else
                {
                    ((SiteMaster)this.Master)?.ShowError(result.Message);
                }

                // Reload the grid
                LoadDepartments(txtSearch.Text.Trim());
            }
            catch (Exception ex)
            {
                ((SiteMaster)this.Master)?.ShowError("Error saving department: " + ex.Message);
            }
        }

        /// <summary>
        /// Handles delete via hidden LinkButton (server-side).
        /// NOTE: In this implementation, delete is primarily done via AJAX handler.
        /// This is a fallback for non-JS environments.
        /// </summary>
        protected void lbDeleteDept_Click(object sender, EventArgs e)
        {
            int deptId;
            if (!int.TryParse(hfDeleteDeptId.Value, out deptId) || deptId <= 0) return;

            try
            {
                string performedBy = Session["Username"]?.ToString() ?? "system";
                var result = _departmentService.DeleteDepartment(deptId, performedBy);

                if (result.Result > 0)
                    ((SiteMaster)this.Master)?.ShowSuccess(result.Message);
                else
                    ((SiteMaster)this.Master)?.ShowError(result.Message);

                LoadDepartments();
            }
            catch (Exception ex)
            {
                ((SiteMaster)this.Master)?.ShowError("Error deleting department: " + ex.Message);
            }
        }

        /// <summary>
        /// GridView RowCommand handler (for any inline commands).
        /// </summary>
        protected void gvDepartments_RowCommand(object sender, GridViewCommandEventArgs e) { }

        /// <summary>
        /// Clears the modal form fields after save.
        /// </summary>
        private void ClearModalFields()
        {
            hfDeptId.Value            = "0";
            txtDepartmentName.Text    = string.Empty;
            txtDeptDescription.Text   = string.Empty;
            chkDeptActive.Checked     = true;
        }
    }
}
