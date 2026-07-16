using System;
using System.Web.UI;

namespace EmployeeManagement.UI
{
    /// <summary>
    /// ForgotPassword.aspx.cs - Forgot Password UI handler.
    /// In a real system, this would send a reset email.
    /// For this demo, it shows an informational message.
    /// </summary>
    public partial class ForgotPassword : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string username = txtUsername.Text.Trim();

            // In production: look up user, generate token, send email.
            // For demo: show a friendly message.
            pnlAlert.Visible = true;
            litAlert.Text    = $"Password reset instructions have been sent to the email registered for <strong>{username}</strong>. " +
                               "Please check your inbox. (Demo: contact your administrator.)";
            divAlert.Attributes["class"] = "alert alert-success";
        }
    }
}
