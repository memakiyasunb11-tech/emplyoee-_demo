using System;
using System.Web;
using System.Web.Security;
using System.Web.UI;

namespace EmployeeManagement.UI
{
    /// <summary>
    /// Global.asax.cs - Application lifecycle event handler.
    /// Handles Application_Start, Session_Start, and Error events.
    /// </summary>
    public class Global : HttpApplication
    {
        /// <summary>
        /// Fires once when the application first starts.
        /// Ideal for registering routes or warming up resources.
        /// </summary>
        protected void Application_Start(object sender, EventArgs e)
        {
            // Disable unobtrusive validation mode (avoids jquery ScriptResourceMapping requirement)
            ValidationSettings.UnobtrusiveValidationMode = UnobtrusiveValidationMode.None;

            // Register jQuery script resource mapping (used by WebForms validators)
            ScriptManager.ScriptResourceMapping.AddDefinition("jquery", new ScriptResourceDefinition
            {
                Path = "~/JS/jquery-3.7.1.min.js",
                DebugPath = "~/JS/jquery-3.7.1.min.js",
                CdnPath = "https://code.jquery.com/jquery-3.7.1.min.js",
                CdnDebugPath = "https://code.jquery.com/jquery-3.7.1.min.js"
            });
        }

        /// <summary>
        /// Fires at the start of each new user session.
        /// </summary>
        protected void Session_Start(object sender, EventArgs e)
        {
            // Session initialization
        }

        /// <summary>
        /// Fires at the start of each HTTP request.
        /// Checks session validity and redirects if expired.
        /// </summary>
        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            // Optional: Force HTTPS in production
            // if (!Request.IsSecureConnection && !Request.IsLocal)
            // {
            //     Response.Redirect("https://" + Request.ServerVariables["HTTP_HOST"] + Request.RawUrl);
            // }
        }

        /// <summary>
        /// Fires when an unhandled error occurs in the application.
        /// Logs the error for debugging purposes.
        /// </summary>
        protected void Application_Error(object sender, EventArgs e)
        {
            Exception ex = Server.GetLastError();
            if (ex != null)
            {
                // Log the error (in production, use a logging framework like NLog or Serilog)
                System.Diagnostics.Debug.WriteLine("Application Error: " + ex.Message);

                // Clear the error so the custom error page handles it
                // Server.ClearError();
                // Response.Redirect("~/Error.aspx");
            }
        }

        /// <summary>
        /// Fires when a session ends (timeout or explicit abandon).
        /// </summary>
        protected void Session_End(object sender, EventArgs e)
        {
            // Cleanup session resources if needed
        }

        /// <summary>
        /// Fires when the application shuts down.
        /// </summary>
        protected void Application_End(object sender, EventArgs e)
        {
            // Application teardown
        }
    }
}
