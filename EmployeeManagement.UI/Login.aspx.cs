using System;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using EmployeeManagement.BLL.Models;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI
{
    /// <summary>
    /// Login.aspx.cs - Code-behind for the Login page.
    ///
    /// WHY: Handles the POST action of the login form.
    /// On success: creates ASP.NET Session and forms auth cookie.
    /// On failure: shows an error message.
    /// Remember Me: Sets a persistent cookie for 30 days.
    /// Logout: Abandons session and clears auth cookie.
    /// </summary>
    public partial class Login : Page
    {
        private readonly UserService _userService = new UserService();

        protected void Page_Load(object sender, EventArgs e)
        {
            // If already logged in, redirect to dashboard
            if (Session["UserId"] != null)
            {
                Response.Redirect("~/Default.aspx", true);
                return;
            }

            // Handle logout action from query string
            string action = Request.QueryString["action"];
            if (!string.IsNullOrEmpty(action) && action == "logout")
            {
                PerformLogout();
                return;
            }

            // Handle session expired message
            string msg = Request.QueryString["msg"];
            if (!string.IsNullOrEmpty(msg) && msg == "session_expired")
            {
                ShowAlert("Your session has expired. Please login again.", "alert-warning");
            }

            // If Remember Me cookie exists, pre-fill the username
            if (!IsPostBack)
            {
                HttpCookie rememberCookie = Request.Cookies["EMS_RememberMe"];
                if (rememberCookie != null && !string.IsNullOrEmpty(rememberCookie["Username"]))
                {
                    txtUsername.Text   = rememberCookie["Username"];
                    chkRememberMe.Checked = true;
                }
            }
        }

        /// <summary>
        /// Handles the Login button click.
        /// Validates, authenticates, and creates session.
        /// </summary>
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            try
            {
                string username = txtUsername.Text.Trim();
                string password = txtPassword.Text.Trim();

                // Authenticate via BLL (which hashes password)
                UserModel user = _userService.Login(username, password);

                if (user != null && user.IsActive)
                {
                    // Store user info in session
                    Session["UserId"]       = user.UserId;
                    Session["Username"]     = user.Username;
                    Session["UserFullName"] = user.FullName;
                    Session["UserRole"]     = user.Role;

                    // Handle Remember Me
                    if (chkRememberMe.Checked)
                    {
                        // Set a 30-day cookie with the username
                        HttpCookie rememberCookie = new HttpCookie("EMS_RememberMe")
                        {
                            Expires = DateTime.Now.AddDays(30),
                            HttpOnly = true,
                            Secure   = Request.IsSecureConnection
                        };
                        rememberCookie["Username"] = username;
                        Response.Cookies.Add(rememberCookie);
                    }
                    else
                    {
                        // Remove Remember Me cookie if unchecked
                        HttpCookie removeCookie = new HttpCookie("EMS_RememberMe")
                        {
                            Expires = DateTime.Now.AddDays(-1)
                        };
                        Response.Cookies.Add(removeCookie);
                    }

                    // Forms authentication ticket (optional, for .ASPXAUTH compatibility)
                    FormsAuthentication.SetAuthCookie(username, chkRememberMe.Checked);

                    // Redirect to dashboard (or return URL if originally requested)
                    string returnUrl = Request.QueryString["ReturnUrl"];
                    if (!string.IsNullOrEmpty(returnUrl))
                        Response.Redirect(returnUrl, true);
                    else
                        Response.Redirect("~/Default.aspx", true);
                }
                else if (user != null && !user.IsActive)
                {
                    ShowAlert("Your account has been deactivated. Please contact your administrator.", "alert-warning");
                }
                else
                {
                    ShowAlert("Invalid username or password. Please try again.", "alert-danger");
                }
            }
            catch (Exception ex)
            {
                ShowAlert("An error occurred: " + ex.Message, "alert-danger");
            }
        }

        /// <summary>
        /// Performs logout by abandoning session and signing out of Forms Auth.
        /// </summary>
        private void PerformLogout()
        {
            Session.Abandon();
            FormsAuthentication.SignOut();

            // Clear auth cookie
            HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, "")
            {
                Expires = DateTime.Now.AddYears(-1)
            };
            Response.Cookies.Add(authCookie);

            Response.Redirect("~/Login.aspx", true);
        }

        /// <summary>
        /// Displays an alert message on the login form.
        /// </summary>
        private void ShowAlert(string message, string cssClass)
        {
            pnlAlert.Visible       = true;
            litAlert.Text          = message;
            divAlert.Attributes["class"] = "alert " + cssClass;
        }
    }
}
