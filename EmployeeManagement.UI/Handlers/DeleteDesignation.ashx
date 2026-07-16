<%@ WebHandler Language="C#" Class="EmployeeManagement.UI.Handlers.DeleteDesignation" %>
using System;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Handlers
{
    /// <summary>
    /// DeleteDesignation.ashx - AJAX handler for designation deletion.
    /// Usage: POST {"designationId": 3}
    /// </summary>
    public class DeleteDesignation : IHttpHandler
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
                string body        = new StreamReader(context.Request.InputStream).ReadToEnd();
                var    serializer  = new JavaScriptSerializer();
                dynamic data       = serializer.Deserialize<dynamic>(body);

                int designationId  = data["designationId"];
                string performedBy = context.Session["Username"]?.ToString() ?? "system";

                var service = new DesignationService();
                var result  = service.DeleteDesignation(designationId, performedBy);

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
