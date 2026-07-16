<%@ Page Title="Reports" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="EmployeeReport.aspx.cs"
    Inherits="EmployeeManagement.UI.Reports.EmployeeReport" %>

<asp:Content ID="cTitle" ContentPlaceHolderID="cphPageTitle" runat="server">
    Reports
</asp:Content>

<asp:Content ID="cBreadcrumb" ContentPlaceHolderID="cphBreadcrumb" runat="server">
    <li class="breadcrumb-item active">Reports</li>
</asp:Content>

<asp:Content ID="cContent" ContentPlaceHolderID="cphContent" runat="server">

    <div class="page-header">
        <h1 class="page-title"><i class="bi bi-file-earmark-bar-graph-fill"></i> Reports</h1>
    </div>

    <!-- Report Tabs -->
    <ul class="nav nav-tabs mb-4" id="reportTabs">
        <li class="nav-item">
            <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tabEmpReport">
                <i class="bi bi-people-fill me-1"></i>Employee Report
            </button>
        </li>
        <li class="nav-item">
            <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tabSalaryReport">
                <i class="bi bi-currency-rupee me-1"></i>Salary Report
            </button>
        </li>
        <li class="nav-item">
            <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tabDeptReport">
                <i class="bi bi-building-fill me-1"></i>Department Report
            </button>
        </li>
    </ul>

    <div class="tab-content">

        <!-- ==============================
             EMPLOYEE REPORT TAB
             ============================== -->
        <div class="tab-pane fade show active" id="tabEmpReport">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title"><i class="bi bi-people-fill"></i>Employee Report</h5>
                    <div class="report-toolbar">
                        <button onclick="exportToExcel('gvEmpReport','EmployeeReport');"
                                class="btn btn-sm btn-export-excel">
                            <i class="bi bi-file-earmark-excel-fill me-1"></i>Export Excel
                        </button>
                        <button onclick="printTable('gvEmpReport','Employee Report');"
                                class="btn btn-sm btn-print">
                            <i class="bi bi-printer-fill me-1"></i>Print
                        </button>
                    </div>
                </div>
                <div class="card-body">
                    <!-- Filters -->
                    <div class="row g-3 mb-3">
                        <div class="col-md-3">
                            <label class="form-label">Department</label>
                            <asp:DropDownList ID="ddlEmpDept" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">All Departments</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Gender</label>
                            <asp:DropDownList ID="ddlEmpGender" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">All Genders</asp:ListItem>
                                <asp:ListItem Value="Male">Male</asp:ListItem>
                                <asp:ListItem Value="Female">Female</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Status</label>
                            <asp:DropDownList ID="ddlEmpStatus" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">All</asp:ListItem>
                                <asp:ListItem Value="1">Active</asp:ListItem>
                                <asp:ListItem Value="0">Inactive</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3 d-flex align-items-end">
                            <asp:Button ID="btnGenerateEmpReport" runat="server"
                                Text="Generate Report"
                                CssClass="btn btn-primary w-100"
                                OnClick="btnGenerateEmpReport_Click" />
                        </div>
                    </div>
                    <div class="table-responsive">
                        <asp:GridView ID="gvEmpReport" runat="server"
                            CssClass="table" AutoGenerateColumns="false"
                            GridLines="None"
                            EmptyDataText="No data. Click Generate Report.">
                            <Columns>
                                <asp:BoundField DataField="EmployeeCode"    HeaderText="Code" />
                                <asp:BoundField DataField="FullName"        HeaderText="Name" />
                                <asp:BoundField DataField="Gender"          HeaderText="Gender" />
                                <asp:BoundField DataField="Email"           HeaderText="Email" />
                                <asp:BoundField DataField="Mobile"          HeaderText="Mobile" />
                                <asp:BoundField DataField="DepartmentName"  HeaderText="Department" />
                                <asp:BoundField DataField="DesignationName" HeaderText="Designation" />
                                <asp:TemplateField HeaderText="Salary">
                                    <ItemTemplate>₹<%# Convert.ToDecimal(Eval("Salary")).ToString("N0") %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="JoiningDate" HeaderText="Joining"
                                    DataFormatString="{0:dd MMM yyyy}" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='badge <%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>

        <!-- ==============================
             SALARY REPORT TAB
             ============================== -->
        <div class="tab-pane fade" id="tabSalaryReport">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title"><i class="bi bi-currency-rupee"></i>Salary Report</h5>
                    <div class="report-toolbar">
                        <button onclick="exportToExcel('gvSalaryReport','SalaryReport');"
                                class="btn btn-sm btn-export-excel">
                            <i class="bi bi-file-earmark-excel-fill me-1"></i>Export Excel
                        </button>
                        <button onclick="printTable('gvSalaryReport','Salary Report');"
                                class="btn btn-sm btn-print">
                            <i class="bi bi-printer-fill me-1"></i>Print
                        </button>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label">Filter by Department</label>
                            <asp:DropDownList ID="ddlSalaryDept" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">All Departments</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4 d-flex align-items-end">
                            <asp:Button ID="btnSalaryReport" runat="server"
                                Text="Generate Salary Report"
                                CssClass="btn btn-primary w-100"
                                OnClick="btnSalaryReport_Click" />
                        </div>
                    </div>
                    <div class="table-responsive">
                        <asp:GridView ID="gvSalaryReport" runat="server"
                            CssClass="table" AutoGenerateColumns="false"
                            GridLines="None"
                            EmptyDataText="No data. Click Generate Report.">
                            <Columns>
                                <asp:BoundField DataField="DepartmentName"  HeaderText="Department" />
                                <asp:BoundField DataField="DesignationName" HeaderText="Designation" />
                                <asp:BoundField DataField="EmployeeCount"   HeaderText="Employees" />
                                <asp:TemplateField HeaderText="Min Salary">
                                    <ItemTemplate>₹<%# Convert.ToDecimal(Eval("MinSalary")).ToString("N0") %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Max Salary">
                                    <ItemTemplate>₹<%# Convert.ToDecimal(Eval("MaxSalary")).ToString("N0") %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Avg Salary">
                                    <ItemTemplate>₹<%# Convert.ToDecimal(Eval("AvgSalary")).ToString("N0") %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Total Salary">
                                    <ItemTemplate><strong>₹<%# Convert.ToDecimal(Eval("TotalSalary")).ToString("N0") %></strong></ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>

        <!-- ==============================
             DEPARTMENT REPORT TAB
             ============================== -->
        <div class="tab-pane fade" id="tabDeptReport">
            <div class="card">
                <div class="card-header">
                    <h5 class="card-title"><i class="bi bi-building-fill"></i>Department Report</h5>
                    <div class="report-toolbar">
                        <button onclick="exportToExcel('gvDeptReport','DepartmentReport');"
                                class="btn btn-sm btn-export-excel">
                            <i class="bi bi-file-earmark-excel-fill me-1"></i>Export Excel
                        </button>
                        <button onclick="printTable('gvDeptReport','Department Report');"
                                class="btn btn-sm btn-print">
                            <i class="bi bi-printer-fill me-1"></i>Print
                        </button>
                    </div>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <asp:GridView ID="gvDeptReport" runat="server"
                            CssClass="table" AutoGenerateColumns="false"
                            GridLines="None"
                            EmptyDataText="No departments found.">
                            <Columns>
                                <asp:BoundField DataField="DepartmentId"   HeaderText="#" />
                                <asp:BoundField DataField="DepartmentName" HeaderText="Department Name" />
                                <asp:BoundField DataField="Description"    HeaderText="Description" />
                                <asp:BoundField DataField="EmployeeCount"  HeaderText="Total Employees" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='badge <%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="CreatedDate" HeaderText="Created"
                                    DataFormatString="{0:dd MMM yyyy}" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>

    </div><!-- /tab-content -->

</asp:Content>
