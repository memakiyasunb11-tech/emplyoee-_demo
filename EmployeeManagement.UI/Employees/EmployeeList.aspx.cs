using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Employees
{
    /// <summary>
    /// EmployeeList.aspx.cs - Code-behind for the Employee List page.
    ///
    /// WHY: Handles server-side logic for:
    /// - Loading employees with pagination, sorting, and filtering
    /// - Building the pagination repeater model
    /// - Responding to sort column clicks (via hidden link button)
    /// - Responding to search/filter button
    /// </summary>
    public partial class EmployeeList : Page
    {
        private readonly EmployeeService     _employeeService     = new EmployeeService();
        private readonly DepartmentService   _departmentService   = new DepartmentService();

        // Page size: number of records per page
        private const int PAGE_SIZE = 10;

        // Exposed to ASPX for pager Repeater
        public int CurrentPage { get; private set; } = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDepartmentFilter();
                LoadEmployees();
            }
        }

        /// <summary>
        /// Fills the department filter dropdown.
        /// </summary>
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
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading dept filter: " + ex.Message);
            }
        }

        /// <summary>
        /// Loads employees with current search/filter/sort/page state.
        /// Updates the GridView, pagination controls, and count labels.
        /// </summary>
        private void LoadEmployees()
        {
            try
            {
                // Read current page from hidden field
                int page;
                CurrentPage = int.TryParse(hfCurrentPage.Value, out page) ? page : 1;

                // Build filter parameters
                string searchTerm  = txtSearch.Text.Trim();
                int?   deptId      = string.IsNullOrEmpty(ddlFilterDept.SelectedValue)   ? (int?)null : int.Parse(ddlFilterDept.SelectedValue);
                string gender      = ddlFilterGender.SelectedValue;
                bool?  isActive    = string.IsNullOrEmpty(ddlFilterStatus.SelectedValue) ? (bool?)null : ddlFilterStatus.SelectedValue == "1";

                string sortCol   = hfSortColumn.Value;
                string sortOrder = hfSortOrder.Value;

                var (employees, totalRecords) = _employeeService.GetAllEmployees(
                    searchTerm:   string.IsNullOrWhiteSpace(searchTerm) ? null : searchTerm,
                    departmentId: deptId,
                    gender:       string.IsNullOrWhiteSpace(gender) ? null : gender,
                    isActive:     isActive,
                    sortColumn:   sortCol,
                    sortOrder:    sortOrder,
                    pageNumber:   CurrentPage,
                    pageSize:     PAGE_SIZE
                );

                // Bind GridView
                gvEmployees.DataSource = employees;
                gvEmployees.DataBind();

                // Update header badge count
                totalCount.InnerText = totalRecords.ToString();

                // Update pagination info labels
                int from  = totalRecords == 0 ? 0 : (CurrentPage - 1) * PAGE_SIZE + 1;
                int to    = Math.Min(CurrentPage * PAGE_SIZE, totalRecords);
                litPageFrom.Text  = from.ToString();
                litPageTo.Text    = to.ToString();
                litPageTotal.Text = totalRecords.ToString();

                // Build pager
                BuildPager(totalRecords);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading employees: " + ex.Message);
                ((SiteMaster)this.Master)?.ShowError("Error loading employees: " + ex.Message);
            }
        }

        /// <summary>
        /// Builds the pagination repeater data.
        /// Creates Previous, page numbers, and Next items.
        /// </summary>
        private void BuildPager(int totalRecords)
        {
            int totalPages = (int)Math.Ceiling((double)totalRecords / PAGE_SIZE);
            if (totalPages <= 1)
            {
                rptPager.Visible = false;
                return;
            }
            rptPager.Visible = true;

            var pages = new List<dynamic>();

            // Previous button
            pages.Add(new { PageNumber = CurrentPage - 1, Text = "‹", IsEnabled = CurrentPage > 1 });

            // Page numbers (show max 5 around current)
            int start = Math.Max(1, CurrentPage - 2);
            int end   = Math.Min(totalPages, CurrentPage + 2);
            for (int i = start; i <= end; i++)
            {
                pages.Add(new { PageNumber = i, Text = i.ToString(), IsEnabled = true });
            }

            // Next button
            pages.Add(new { PageNumber = CurrentPage + 1, Text = "›", IsEnabled = CurrentPage < totalPages });

            rptPager.DataSource = pages;
            rptPager.DataBind();
        }

        /// <summary>
        /// Handles page navigation from the pager Repeater.
        /// </summary>
        protected void rptPager_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Page")
            {
                int page = Convert.ToInt32(e.CommandArgument);
                if (page >= 1)
                {
                    hfCurrentPage.Value = page.ToString();
                    LoadEmployees();
                }
            }
        }

        /// <summary>
        /// Handles Search button click.
        /// Resets to page 1 and reloads.
        /// </summary>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            hfCurrentPage.Value = "1";
            LoadEmployees();
        }

        /// <summary>
        /// Handles Reset button click.
        /// Clears all filters and reloads.
        /// </summary>
        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text              = string.Empty;
            ddlFilterDept.SelectedIndex = 0;
            ddlFilterGender.SelectedIndex = 0;
            ddlFilterStatus.SelectedIndex = 0;
            hfCurrentPage.Value           = "1";
            hfSortColumn.Value            = "CreatedDate";
            hfSortOrder.Value             = "DESC";
            LoadEmployees();
        }

        /// <summary>
        /// Handles sort column click (via hidden LinkButton).
        /// </summary>
        protected void lbSort_Click(object sender, EventArgs e)
        {
            hfCurrentPage.Value = "1";
            LoadEmployees();
        }

        /// <summary>
        /// Handles GridView RowCommand (e.g., Delete from command column).
        /// </summary>
        protected void gvEmployees_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Actions handled via AJAX / client-side JS (doDeleteEmployee)
        }

        /// <summary>
        /// Returns initials for the employee avatar in the GridView.
        /// </summary>
        protected string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "?";
            var parts = fullName.Trim().Split(' ');
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[1][0].ToString()).ToUpper();
            return fullName.Substring(0, Math.Min(2, fullName.Length)).ToUpper();
        }
    }
}
