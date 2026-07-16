<%@ WebHandler Language="C#" Class="EmployeeManagement.UI.Handlers.GetDesignation" %>
using System;
using System.Web;
using System.Web.Script.Serialization;
using EmployeeManagement.BLL.Models;
using EmployeeManagement.BLL.Services;

namespace EmployeeManagement.UI.Handlers
{
    /// <summary>
    /// GetDesignation.ashx - AJAX handler for single designation fetch (for edit modal).
    /// Usage: GET /Handlers/GetDesignation.ashx?id=3
    /// </summary>
    public class GetDesignation : IHttpHandler
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

                var service = new DesignationService();
                DesignationModel model = service.GetDesignationById(id);

                if (model == null)
                {
                    context.Response.StatusCode = 404;
                    context.Response.Write("{\"error\":\"Not found.\"}");
                    return;
                }

                var result = new JavaScriptSerializer().Serialize(new
                {
                    model.DesignationId,
                    model.DesignationName,
                    model.DepartmentId,
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
