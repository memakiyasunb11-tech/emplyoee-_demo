using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using EmployeeManagement.DAL.Models;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Designations
{
    /// <summary>
    /// DesignationList.aspx.cs - Designation management code-behind.
    /// </summary>
    public partial class DesignationList : Page
    {
        private readonly DesignationService _designationService = new DesignationService();
        private readonly DepartmentService  _departmentService  = new DepartmentService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDepartmentFilter();
                LoadDesignations();
            }
        }

        private void LoadDepartmentFilter()
        {
            try
            {
                DataTable dt = _departmentService.GetActiveDepartmentsForDropdown();
                ddlFilterDept.DataSource     = dt;
                ddlFilterDept.DataTextField  = "DepartmentName";
                ddlFilterDept.DataValueField = "DepartmentId";
                ddlFilterDept.DataBind();
                ddlFilterDept.Items.Insert(0, new ListItem("All Departments", ""));

                // Also populate the modal department dropdown
                ddlDepartmentDesig.DataSource     = dt;
                ddlDepartmentDesig.DataTextField  = "DepartmentName";
                ddlDepartmentDesig.DataValueField = "DepartmentId";
                ddlDepartmentDesig.DataBind();
                ddlDepartmentDesig.Items.Insert(0, new ListItem("-- Select Department --", ""));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading departments: " + ex.Message);
            }
        }

        private void LoadDesignations()
        {
            try
            {
                string searchTerm = txtSearch.Text.Trim();
                int?   deptId     = string.IsNullOrEmpty(ddlFilterDept.SelectedValue)
                                    ? (int?)null
                                    : int.Parse(ddlFilterDept.SelectedValue);

                DataTable dt = _designationService.GetAllDesignations(
                    string.IsNullOrWhiteSpace(searchTerm) ? null : searchTerm, deptId);

                gvDesignations.DataSource = dt;
                gvDesignations.DataBind();
                desigCount.InnerText = dt.Rows.Count.ToString();
            }
            catch (Exception ex)
            {
                ((SiteMaster)this.Master)?.ShowError("Error loading designations: " + ex.Message);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e) => LoadDesignations();

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text              = string.Empty;
            ddlFilterDept.SelectedIndex = 0;
            LoadDesignations();
        }

        protected void btnSaveDesig_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            try
            {
                var model = new DesignationModel
                {
                    DesignationId   = int.TryParse(hfDesigId.Value, out int id) ? id : 0,
                    DesignationName = txtDesignationName.Text.Trim(),
                    DepartmentId    = int.TryParse(ddlDepartmentDesig.SelectedValue, out int deptId) ? deptId : 0,
                    Description     = txtDesigDescription.Text.Trim(),
                    IsActive        = chkDesigActive.Checked
                };

                string performedBy = Session["Username"]?.ToString() ?? "system";
                (int Result, string Message) result;

                if (model.DesignationId == 0)
                    result = _designationService.AddDesignation(model, performedBy);
                else
                    result = _designationService.UpdateDesignation(model, performedBy);

                if (result.Result > 0)
                    ((SiteMaster)this.Master)?.ShowSuccess(result.Message);
                else
                    ((SiteMaster)this.Master)?.ShowError(result.Message);

                hfDesigId.Value              = "0";
                txtDesignationName.Text      = string.Empty;
                txtDesigDescription.Text     = string.Empty;
                ddlDepartmentDesig.SelectedIndex = 0;
                chkDesigActive.Checked       = true;

                LoadDesignations();
            }
            catch (Exception ex)
            {
                ((SiteMaster)this.Master)?.ShowError("Error saving designation: " + ex.Message);
            }
        }

        protected void gvDesignations_RowCommand(object sender, GridViewCommandEventArgs e) { }
    }
}
