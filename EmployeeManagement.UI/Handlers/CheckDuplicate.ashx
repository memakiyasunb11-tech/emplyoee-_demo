<%@ WebHandler Language="C#" Class="EmployeeManagement.UI.Handlers.CheckDuplicate" %>
using System;
using System.Web;
using System.Web.Script.Serialization;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Handlers
{
    /// <summary>
    /// CheckDuplicate.ashx - AJAX HTTP Handler for duplicate validation.
    /// Called on blur of Email and Mobile fields on the Employee form.
    ///
    /// Usage: GET /Handlers/CheckDuplicate.ashx?type=email&value=test@test.com&id=0
    ///        GET /Handlers/CheckDuplicate.ashx?type=mobile&value=9876543210&id=0
    /// Returns: {"isDuplicate": true/false}
    /// </summary>
    public class CheckDuplicate : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            try
            {
                string type  = context.Request.QueryString["type"];
                string value = context.Request.QueryString["value"]?.Trim();
                int    id    = int.TryParse(context.Request.QueryString["id"], out int empId) ? empId : 0;

                if (string.IsNullOrWhiteSpace(value))
                {
                    context.Response.Write("{\"isDuplicate\":false}");
                    return;
                }

                var service     = new EmployeeService();
                bool isDuplicate;

                if (type == "email")
                    isDuplicate = service.IsEmailDuplicate(value, id);
                else if (type == "mobile")
                    isDuplicate = service.IsMobileDuplicate(value, id);
                else
                {
                    context.Response.Write("{\"isDuplicate\":false}");
                    return;
                }

                var result = new JavaScriptSerializer().Serialize(new { isDuplicate });
                context.Response.Write(result);
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("{\"isDuplicate\":false,\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}");
            }
        }

        public bool IsReusable => false;
    }
}
