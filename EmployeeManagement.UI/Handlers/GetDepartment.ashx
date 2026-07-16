<%@ WebHandler Language="C#" Class="EmployeeManagement.UI.Handlers.GetDepartment" %>
using System;
using System.Web;
using System.Web.Script.Serialization;
using EmployeeManagement.BLL.Models;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Handlers
{
    /// <summary>
    /// GetDepartment.ashx - AJAX handler to fetch a single department for editing.
    /// Called when Edit button is clicked in DepartmentList to populate the modal.
    ///
    /// Usage: GET /Handlers/GetDepartment.ashx?id=2
    /// Returns: {"DepartmentId":2,"DepartmentName":"HR","Description":"...","IsActive":true}
    /// </summary>
    public class GetDepartment : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            try
            {
                int id;
                if (!int.TryParse(context.Request.QueryString["id"], out id) || id <= 0)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write("{\"error\":\"Invalid ID.\"}");
                    return;
                }

                var service = new DepartmentService();
                DepartmentModel model = service.GetDepartmentById(id);

                if (model == null)
                {
                    context.Response.StatusCode = 404;
                    context.Response.Write("{\"error\":\"Not found.\"}");
                    return;
                }

                var result = new JavaScriptSerializer().Serialize(new
                {
                    model.DepartmentId,
                    model.DepartmentName,
                    Description = model.Description ?? "",
                    model.IsActive
                });

                context.Response.Write(result);
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
