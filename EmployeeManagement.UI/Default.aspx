<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Default.aspx.cs"
    Inherits="EmployeeManagement.UI.Default" %>

<asp:Content ID="cTitle" ContentPlaceHolderID="cphPageTitle" runat="server">
    Dashboard
</asp:Content>

<asp:Content ID="cBreadcrumb" ContentPlaceHolderID="cphBreadcrumb" runat="server">
    <li class="breadcrumb-item active">Dashboard</li>
</asp:Content>

<asp:Content ID="cContent" ContentPlaceHolderID="cphContent" runat="server">

    <!-- Page Header -->
    <div class="page-header">
        <div>
            <h1 class="page-title">
                <i class="bi bi-grid-1x2-fill"></i> Dashboard
            </h1>
            <p class="page-subtitle">
                Welcome back, <strong><%= Session["UserFullName"] %></strong>!
                Here's what's happening today.
            </p>
        </div>
        <div>
            <span class="badge bg-light text-secondary border" style="font-size:12px;padding:8px 14px;">
                <i class="bi bi-calendar3 me-1"></i>
                <%= DateTime.Now.ToString("dddd, MMMM dd yyyy") %>
            </span>
        </div>
    </div>

    <!-- ============================================
         KPI STATS CARDS
         ============================================ -->
    <div class="stats-grid">

        <!-- Total Employees -->
        <div class="stat-card" style="--card-accent:#4f46e5;">
            <div class="stat-icon bg-indigo">
                <i class="bi bi-people-fill"></i>
            </div>
            <div class="stat-info">
                <div class="stat-value">
                    <asp:Literal ID="litTotalEmployees" runat="server">0</asp:Literal>
                </div>
                <div class="stat-label">Total Employees</div>
            </div>
        </div>

        <!-- Male Employees -->
        <div class="stat-card" style="--card-accent:#3b82f6;">
            <div class="stat-icon bg-blue">
                <i class="bi bi-gender-male"></i>
            </div>
            <div class="stat-info">
                <div class="stat-value">
                    <asp:Literal ID="litMaleEmployees" runat="server">0</asp:Literal>
                </div>
                <div class="stat-label">Male Employees</div>
            </div>
        </div>

        <!-- Female Employees -->
        <div class="stat-card" style="--card-accent:#ec4899;">
            <div class="stat-icon bg-pink">
                <i class="bi bi-gender-female"></i>
            </div>
            <div class="stat-info">
                <div class="stat-value">
                    <asp:Literal ID="litFemaleEmployees" runat="server">0</asp:Literal>
                </div>
                <div class="stat-label">Female Employees</div>
            </div>
        </div>

        <!-- Total Departments -->
        <div class="stat-card" style="--card-accent:#06b6d4;">
            <div class="stat-icon bg-cyan">
                <i class="bi bi-building-fill"></i>
            </div>
            <div class="stat-info">
                <div class="stat-value">
                    <asp:Literal ID="litDepartments" runat="server">0</asp:Literal>
                </div>
                <div class="stat-label">Departments</div>
            </div>
        </div>

        <!-- Active Employees -->
        <div class="stat-card" style="--card-accent:#10b981;">
            <div class="stat-icon bg-green">
                <i class="bi bi-person-check-fill"></i>
            </div>
            <div class="stat-info">
                <div class="stat-value">
                    <asp:Literal ID="litActiveEmployees" runat="server">0</asp:Literal>
                </div>
                <div class="stat-label">Active</div>
            </div>
        </div>

        <!-- Inactive Employees -->
        <div class="stat-card" style="--card-accent:#ef4444;">
            <div class="stat-icon bg-red">
                <i class="bi bi-person-x-fill"></i>
            </div>
            <div class="stat-info">
                <div class="stat-value">
                    <asp:Literal ID="litInactiveEmployees" runat="server">0</asp:Literal>
                </div>
                <div class="stat-label">Inactive</div>
            </div>
        </div>

        <!-- Today's Joining -->
        <div class="stat-card" style="--card-accent:#f59e0b;">
            <div class="stat-icon bg-orange">
                <i class="bi bi-calendar-plus-fill"></i>
            </div>
            <div class="stat-info">
                <div class="stat-value">
                    <asp:Literal ID="litTodayJoining" runat="server">0</asp:Literal>
                </div>
                <div class="stat-label">Today's Joining</div>
            </div>
        </div>

    </div><!-- /stats-grid -->

    <!-- ============================================
         LOWER SECTION: Latest Employees + Activities
         ============================================ -->
    <div class="row g-4">

        <!-- LATEST EMPLOYEES TABLE -->
        <div class="col-lg-7">
            <div class="card h-100">
                <div class="card-header">
                    <h5 class="card-title">
                        <i class="bi bi-person-lines-fill"></i> Latest Employees
                    </h5>
                    <a href="Employees/EmployeeList.aspx" class="btn btn-sm btn-outline-primary">
                        <i class="bi bi-arrow-right me-1"></i> View All
                    </a>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <asp:GridView ID="gvLatestEmployees" runat="server"
                            CssClass="table"
                            AutoGenerateColumns="false"
                            GridLines="None"
                            EmptyDataText="No employees found.">
                            <Columns>
                                <asp:TemplateField HeaderText="Employee">
                                    <ItemTemplate>
                                        <div class="employee-name-cell">
                                            <%# !string.IsNullOrEmpty(Eval("Photo")?.ToString())
                                                ? $"<img src='/Images/Uploads/{Eval("Photo")}' class='employee-photo-sm' alt='Photo' />"
                                                : $"<div class='employee-avatar-sm'>{GetInitials(Eval("FullName")?.ToString())}</div>" %>
                                            <div>
                                                <div class="employee-name-text"><%# Eval("FullName") %></div>
                                                <div class="employee-code-text"><%# Eval("EmployeeCode") %></div>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="DepartmentName" HeaderText="Department" />
                                <asp:BoundField DataField="DesignationName" HeaderText="Designation" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class="badge <%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>">
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="">
                                    <ItemTemplate>
                                        <a href='Employees/EmployeeView.aspx?id=<%# Eval("EmployeeId") %>'
                                           class="btn btn-view btn-icon btn-sm" title="View">
                                            <i class="bi bi-eye-fill"></i>
                                        </a>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>

        <!-- RECENT ACTIVITIES -->
        <div class="col-lg-5">
            <div class="card h-100">
                <div class="card-header">
                    <h5 class="card-title">
                        <i class="bi bi-activity"></i> Recent Activities
                    </h5>
                </div>
                <div class="card-body" style="overflow-y:auto;max-height:380px;">
                    <ul class="activity-feed">
                        <asp:Repeater ID="rptActivities" runat="server">
                            <ItemTemplate>
                                <li class="activity-item">
                                    <div class="activity-icon <%# Eval("Action")?.ToString().ToLower() %>">
                                        <i class="bi <%# GetActivityIcon(Eval("Action")?.ToString()) %>"></i>
                                    </div>
                                    <div class="flex-grow-1">
                                        <div class="activity-text"><%# Eval("Description") %></div>
                                        <div class="d-flex align-items-center gap-2 mt-1">
                                            <small class="text-secondary">
                                                <i class="bi bi-person me-1"></i><%# Eval("PerformedBy") %>
                                            </small>
                                            <small class="activity-time text-secondary"
                                                   data-datetime="<%# Eval("PerformedDate", "{0:yyyy-MM-ddTHH:mm:ss}") %>">
                                                <%# Eval("PerformedDate", "{0:dd MMM yyyy HH:mm}") %>
                                            </small>
                                        </div>
                                    </div>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ul>

                    <asp:Panel ID="pnlNoActivity" runat="server" Visible="false">
                        <div class="text-center text-secondary py-4">
                            <i class="bi bi-clock-history fs-2 d-block mb-2"></i>
                            No recent activities.
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>

    </div><!-- /row -->

</asp:Content>
