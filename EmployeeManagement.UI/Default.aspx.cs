using System;
using System.Data;
using System.Web.UI;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI
{
    /// <summary>
    /// Default.aspx.cs - Dashboard Code-Behind.
    ///
    /// WHY: Loads KPI stats (via EmployeeService -> DAL -> SQL SP),
    /// latest employees list, and recent audit activities.
    /// All data is fetched in Page_Load and bound to controls.
    /// </summary>
    public partial class Default : Page
    {
        private readonly EmployeeService _employeeService = new EmployeeService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardStats();
                LoadLatestEmployees();
                LoadRecentActivities();
            }
        }

        /// <summary>
        /// Loads the 7 KPI card numbers from the database.
        /// </summary>
        private void LoadDashboardStats()
        {
            try
            {
                DataRow stats = _employeeService.GetDashboardStats();

                if (stats != null)
                {
                    litTotalEmployees.Text    = stats["TotalEmployees"].ToString();
                    litMaleEmployees.Text     = stats["MaleEmployees"].ToString();
                    litFemaleEmployees.Text   = stats["FemaleEmployees"].ToString();
                    litDepartments.Text       = stats["TotalDepartments"].ToString();
                    litActiveEmployees.Text   = stats["ActiveEmployees"].ToString();
                    litInactiveEmployees.Text = stats["InactiveEmployees"].ToString();
                    litTodayJoining.Text      = stats["TodayJoining"].ToString();
                }
            }
            catch (Exception ex)
            {
                // Log error; don't crash the page - just show 0s
                System.Diagnostics.Debug.WriteLine("Dashboard stats error: " + ex.Message);
            }
        }

        /// <summary>
        /// Loads the 5 most recently added employees into the GridView.
        /// </summary>
        private void LoadLatestEmployees()
        {
            try
            {
                DataTable dt = _employeeService.GetLatestEmployees();
                gvLatestEmployees.DataSource = dt;
                gvLatestEmployees.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Latest employees error: " + ex.Message);
            }
        }

        /// <summary>
        /// Loads recent audit log entries into the Repeater.
        /// </summary>
        private void LoadRecentActivities()
        {
            try
            {
                DataTable dt = _employeeService.GetRecentActivities();

                if (dt.Rows.Count > 0)
                {
                    rptActivities.DataSource = dt;
                    rptActivities.DataBind();
                    pnlNoActivity.Visible = false;
                }
                else
                {
                    pnlNoActivity.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Recent activities error: " + ex.Message);
                pnlNoActivity.Visible = true;
            }
        }

        /// <summary>
        /// Helper: Returns the Bootstrap Icon class for an audit action type.
        /// Used in the ASPX Repeater inline code.
        /// </summary>
        protected string GetActivityIcon(string action)
        {
            switch (action?.ToUpper())
            {
                case "INSERT": return "bi-plus-circle-fill";
                case "UPDATE": return "bi-pencil-fill";
                case "DELETE": return "bi-trash3-fill";
                default:       return "bi-circle-fill";
            }
        }

        /// <summary>
        /// Helper: Returns initials from a full name (e.g., "John Doe" -> "JD").
        /// Used in the ASPX GridView for default avatar.
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
