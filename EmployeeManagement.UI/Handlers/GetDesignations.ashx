<%@ WebHandler Language="C#" Class="EmployeeManagement.UI.Handlers.GetDesignations" %>
using System;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Handlers
{
    /// <summary>
    /// GetDesignations.ashx - AJAX HTTP Handler
    ///
    /// WHY: ASP.NET HTTP Handlers (.ashx) are lightweight and
    /// perfect for AJAX calls. They don't load a full page lifecycle.
    /// This handler returns designations for a given department
    /// as JSON, used by the cascading dropdown on the Employee Form.
    ///
    /// Usage: GET /Handlers/GetDesignations.ashx?departmentId=1
    /// Returns: [{"DesignationId":1,"DesignationName":"Software Engineer"}]
    /// </summary>
    public class GetDesignations : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            try
            {
                int departmentId;
                if (!int.TryParse(context.Request.QueryString["departmentId"], out departmentId) || departmentId <= 0)
                {
                    context.Response.Write("[]");
                    return;
                }

                var service = new DesignationService();
                DataTable dt = service.GetDesignationsByDepartment(departmentId);

                var list = new List<object>();
                foreach (DataRow row in dt.Rows)
                {
                    list.Add(new
                    {
                        DesignationId   = row["DesignationId"],
                        DesignationName = row["DesignationName"].ToString()
                    });
                }

                var json = new JavaScriptSerializer().Serialize(list);
                context.Response.Write(json);
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("{\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}");
            }
        }

        public bool IsReusable => false;
    }
}
