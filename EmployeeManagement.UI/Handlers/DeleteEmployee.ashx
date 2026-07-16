<%@ WebHandler Language="C#" Class="EmployeeManagement.UI.Handlers.DeleteEmployee" %>
using System;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Handlers
{
    /// <summary>
    /// DeleteEmployee.ashx - AJAX HTTP Handler for employee deletion.
    /// Called from the Delete button's onclick in EmployeeList.
    ///
    /// Usage: POST /Handlers/DeleteEmployee.ashx
    /// Body: {"employeeId": 5}
    /// Returns: {"success": true/false, "message": "..."}
    /// </summary>
    public class DeleteEmployee : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            // Only allow POST requests
            if (context.Request.HttpMethod != "POST")
            {
                context.Response.StatusCode = 405;
                context.Response.Write("{\"success\":false,\"message\":\"Method not allowed.\"}");
                return;
            }

            try
            {
                // Read JSON body
                string body       = new StreamReader(context.Request.InputStream).ReadToEnd();
                var    serializer = new JavaScriptSerializer();
                dynamic data      = serializer.Deserialize<dynamic>(body);

                int employeeId = data["employeeId"];
                if (employeeId <= 0)
                {
                    context.Response.Write("{\"success\":false,\"message\":\"Invalid employee ID.\"}");
                    return;
                }

                string performedBy = context.Session["Username"]?.ToString() ?? "system";
                var service  = new EmployeeService();
                var result   = service.DeleteEmployee(employeeId, performedBy);

                var response = serializer.Serialize(new
                {
                    success = result.Result > 0,
                    message = result.Message
                });
                context.Response.Write(response);
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "'") + "\"}");
            }
        }

        public bool IsReusable => false;
    }
}
