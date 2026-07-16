using System;
using System.Web;
using System.Web.UI;

namespace EmployeeManagement.UI
{
    /// <summary>
    /// Site.Master.cs - Code-behind for the Master Page.
    ///
    /// WHY: Provides shared functionality for ALL pages:
    /// - Session validation (redirect to login if expired)
    /// - Logged-in user info (name, initials, role)
    /// - Global message panel for success/error alerts
    /// </summary>
    public partial class SiteMaster : MasterPage
    {
        // ---- Public Properties for message panel ----
        public string MessageCssClass { get; set; } = "alert-info";
        public string MessageIcon     { get; set; } = "bi-info-circle-fill";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Enforce session: redirect to login if not authenticated
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Login.aspx?msg=session_expired", true);
                return;
            }

            // Prevent browser back-button access after logout
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
        }

        /// <summary>
        /// Returns the logged-in user's full name from session.
        /// </summary>
        public string GetLoggedInUserName()
        {
            return Session["UserFullName"]?.ToString() ?? "User";
        }

        /// <summary>
        /// Returns the logged-in user's role from session.
        /// </summary>
        public string GetUserRole()
        {
            return Session["UserRole"]?.ToString() ?? "Admin";
        }

        /// <summary>
        /// Returns the initials of the logged-in user (e.g., "JD" for "John Doe").
        /// Used in the sidebar avatar and topbar user button.
        /// </summary>
        public string GetUserInitials()
        {
            string fullName = GetLoggedInUserName();
            if (string.IsNullOrWhiteSpace(fullName)) return "U";

            var parts = fullName.Split(' ');
            if (parts.Length >= 2)
                return (parts[0][0].ToString() + parts[1][0].ToString()).ToUpper();
            else
                return fullName.Substring(0, Math.Min(2, fullName.Length)).ToUpper();
        }

        /// <summary>
        /// Shows a global success message in the alert panel.
        /// Called from content pages: Master.ShowSuccess("Saved!");
        /// </summary>
        public void ShowSuccess(string message)
        {
            pnlMessage.Visible = true;
            litMessage.Text    = message;
            MessageCssClass    = "alert-success";
            MessageIcon        = "bi-check-circle-fill";
        }

        /// <summary>
        /// Shows a global error message in the alert panel.
        /// </summary>
        public void ShowError(string message)
        {
            pnlMessage.Visible = true;
            litMessage.Text    = message;
            MessageCssClass    = "alert-danger";
            MessageIcon        = "bi-exclamation-triangle-fill";
        }

        /// <summary>
        /// Shows a global warning message in the alert panel.
        /// </summary>
        public void ShowWarning(string message)
        {
            pnlMessage.Visible = true;
            litMessage.Text    = message;
            MessageCssClass    = "alert-warning";
            MessageIcon        = "bi-exclamation-circle-fill";
        }
    }
}
