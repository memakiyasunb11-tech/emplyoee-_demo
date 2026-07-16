using System;
using System.Data;
using System.Web.UI;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Reports
{
    /// <summary>
    /// EmployeeReport.aspx.cs - Reports page code-behind.
    /// Generates Employee, Salary, and Department reports.
    /// Supports Excel export (client-side JS) and Print.
    /// </summary>
    public partial class EmployeeReport : Page
    {
        private readonly EmployeeService   _employeeService   = new EmployeeService();
        private readonly DepartmentService _departmentService = new DepartmentService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDepartmentDropdowns();
                LoadDepartmentReport();  // Auto-load department report
            }
        }

        private void LoadDepartmentDropdowns()
        {
            DataTable dt = _departmentService.GetActiveDepartmentsForDropdown();

            // Employee report filter
            ddlEmpDept.DataSource     = dt;
            ddlEmpDept.DataTextField  = "DepartmentName";
            ddlEmpDept.DataValueField = "DepartmentId";
            ddlEmpDept.DataBind();
            ddlEmpDept.Items.Insert(0, new System.Web.UI.WebControls.ListItem("All Departments", ""));

            // Salary report filter
            ddlSalaryDept.DataSource     = dt;
            ddlSalaryDept.DataTextField  = "DepartmentName";
            ddlSalaryDept.DataValueField = "DepartmentId";
            ddlSalaryDept.DataBind();
            ddlSalaryDept.Items.Insert(0, new System.Web.UI.WebControls.ListItem("All Departments", ""));
        }

        /// <summary>
        /// Generate Employee Report with filters.
        /// </summary>
        protected void btnGenerateEmpReport_Click(object sender, EventArgs e)
        {
            try
            {
                int?   deptId   = string.IsNullOrEmpty(ddlEmpDept.SelectedValue) ? (int?)null : int.Parse(ddlEmpDept.SelectedValue);
                string gender   = ddlEmpGender.SelectedValue;
                bool?  isActive = string.IsNullOrEmpty(ddlEmpStatus.SelectedValue) ? (bool?)null : ddlEmpStatus.SelectedValue == "1";

                var (employees, totalRecords) = _employeeService.GetAllEmployees(
                    departmentId: deptId,
                    gender:       string.IsNullOrWhiteSpace(gender) ? null : gender,
                    isActive:     isActive,
                    pageSize:     1000  // Large page size for report
                );

                gvEmpReport.DataSource = employees;
                gvEmpReport.DataBind();
            }
            catch (Exception ex)
            {
                ((SiteMaster)this.Master)?.ShowError("Error generating report: " + ex.Message);
            }
        }

        /// <summary>
        /// Generate Salary Report by department.
        /// </summary>
        protected void btnSalaryReport_Click(object sender, EventArgs e)
        {
            try
            {
                int? deptId = string.IsNullOrEmpty(ddlSalaryDept.SelectedValue)
                              ? (int?)null
                              : int.Parse(ddlSalaryDept.SelectedValue);

                DataTable dt = _employeeService.GetSalaryReport(deptId);
                gvSalaryReport.DataSource = dt;
                gvSalaryReport.DataBind();
            }
            catch (Exception ex)
            {
                ((SiteMaster)this.Master)?.ShowError("Error generating salary report: " + ex.Message);
            }
        }

        /// <summary>
        /// Auto-loads Department Report on page load.
        /// </summary>
        private void LoadDepartmentReport()
        {
            try
            {
                DataTable dt = _departmentService.GetAllDepartments();
                gvDeptReport.DataSource = dt;
                gvDeptReport.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading dept report: " + ex.Message);
            }
        }
    }
}
