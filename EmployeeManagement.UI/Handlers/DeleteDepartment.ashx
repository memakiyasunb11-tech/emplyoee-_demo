<%@ WebHandler Language="C#" Class="EmployeeManagement.UI.Handlers.DeleteDepartment" %>
using System;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Handlers
{
    /// <summary>
    /// DeleteDepartment.ashx - AJAX handler for department deletion.
    /// Usage: POST {"departmentId": 2}
    /// </summary>
    public class DeleteDepartment : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            if (context.Request.HttpMethod != "POST")
            {
                context.Response.StatusCode = 405;
                context.Response.Write("{\"success\":false,\"message\":\"Method not allowed.\"}");
                return;
            }

            try
            {
                string body       = new StreamReader(context.Request.InputStream).ReadToEnd();
                var    serializer = new JavaScriptSerializer();
                dynamic data      = serializer.Deserialize<dynamic>(body);

                int departmentId  = data["departmentId"];
                string performedBy = context.Session["Username"]?.ToString() ?? "system";

                var service  = new DepartmentService();
                var result   = service.DeleteDepartment(departmentId, performedBy);

                context.Response.Write(serializer.Serialize(new
                {
                    success = result.Result > 0,
                    message = result.Message
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":\"" + ex.Message.Replace("\"", "'") + "\"}");
            }
        }

        public bool IsReusable => false;
    }
}
