<%@ Page Title="Employee List" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="EmployeeList.aspx.cs"
    Inherits="EmployeeManagement.UI.Employees.EmployeeList" %>

<asp:Content ID="cTitle" ContentPlaceHolderID="cphPageTitle" runat="server">
    Employee List
</asp:Content>

<asp:Content ID="cBreadcrumb" ContentPlaceHolderID="cphBreadcrumb" runat="server">
    <li class="breadcrumb-item active">Employees</li>
</asp:Content>

<asp:Content ID="cContent" ContentPlaceHolderID="cphContent" runat="server">

    <!-- Page Header -->
    <div class="page-header">
        <div>
            <h1 class="page-title"><i class="bi bi-people-fill"></i> Employee List</h1>
            <p class="page-subtitle">Manage all employees in the system.</p>
        </div>
        <a href="EmployeeForm.aspx" class="btn btn-primary">
            <i class="bi bi-plus-lg me-1"></i> Add Employee
        </a>
    </div>

    <!-- Search & Filter Bar -->
    <div class="search-filter-bar">
        <!-- Live Search -->
        <div class="search-input-wrapper">
            <i class="bi bi-search"></i>
            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="form-control"
                placeholder="Search by name, email, code, department..."
                AutoPostBack="false" />
        </div>

        <!-- Department Filter -->
        <asp:DropDownList ID="ddlFilterDept" runat="server"
            CssClass="form-select" Style="max-width:180px;"
            AutoPostBack="false">
            <asp:ListItem Value="" Text="All Departments" />
        </asp:DropDownList>

        <!-- Gender Filter -->
        <asp:DropDownList ID="ddlFilterGender" runat="server"
            CssClass="form-select" Style="max-width:140px;"
            AutoPostBack="false">
            <asp:ListItem Value="" Text="All Genders" />
            <asp:ListItem Value="Male"   Text="Male" />
            <asp:ListItem Value="Female" Text="Female" />
            <asp:ListItem Value="Other"  Text="Other" />
        </asp:DropDownList>

        <!-- Status Filter -->
        <asp:DropDownList ID="ddlFilterStatus" runat="server"
            CssClass="form-select" Style="max-width:140px;"
            AutoPostBack="false">
            <asp:ListItem Value=""  Text="All Status" />
            <asp:ListItem Value="1" Text="Active" />
            <asp:ListItem Value="0" Text="Inactive" />
        </asp:DropDownList>

        <!-- Search Button -->
        <asp:Button ID="btnSearch" runat="server"
            Text="Search"
            CssClass="btn btn-primary"
            OnClick="btnSearch_Click" />

        <!-- Reset -->
        <asp:Button ID="btnReset" runat="server"
            Text="Reset"
            CssClass="btn btn-outline-primary"
            OnClick="btnReset_Click" />
    </div>

    <!-- Main Card -->
    <div class="card">
        <div class="card-header">
            <h5 class="card-title">
                <i class="bi bi-table me-1"></i> All Employees
                <span class="badge bg-primary ms-2" id="totalCount" runat="server">0</span>
            </h5>
            <div class="d-flex gap-2">
                <button type="button" class="btn btn-sm btn-export-excel"
                        onclick="exportToExcel('gvEmployees','EmployeeList');">
                    <i class="bi bi-file-earmark-excel-fill me-1"></i>Excel
                </button>
                <button type="button" class="btn btn-sm btn-print"
                        onclick="printTable('gvEmployees','Employee List');">
                    <i class="bi bi-printer-fill me-1"></i>Print
                </button>
            </div>
        </div>

        <!-- Employee Table -->
        <div class="table-responsive">
            <asp:GridView ID="gvEmployees" runat="server"
                CssClass="table"
                AutoGenerateColumns="false"
                GridLines="None"
                DataKeyNames="EmployeeId"
                EmptyDataText="No employees found. Click 'Add Employee' to get started."
                OnRowCommand="gvEmployees_RowCommand">

                <EmptyDataRowStyle CssClass="text-center text-secondary" />

                <Columns>

                    <!-- Photo + Name + Code -->
                    <asp:TemplateField HeaderText="Employee" SortExpression="FullName">
                        <HeaderTemplate>
                            <span onclick="sortByColumn('FullName')" style="cursor:pointer;">
                                Employee <i class="bi bi-arrow-down-up sort-icon"></i>
                            </span>
                        </HeaderTemplate>
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

                    <!-- Department -->
                    <asp:TemplateField HeaderText="Department" SortExpression="DepartmentName">
                        <HeaderTemplate>
                            <span onclick="sortByColumn('DepartmentName')" style="cursor:pointer;">
                                Department <i class="bi bi-arrow-down-up sort-icon"></i>
                            </span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <span><%# Eval("DepartmentName") %></span><br />
                            <small class="text-secondary"><%# Eval("DesignationName") %></small>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <!-- Email & Mobile -->
                    <asp:TemplateField HeaderText="Contact">
                        <ItemTemplate>
                            <div><i class="bi bi-envelope me-1 text-primary"></i><%# Eval("Email") %></div>
                            <div><i class="bi bi-phone me-1 text-primary"></i><%# Eval("Mobile") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <!-- Gender -->
                    <asp:TemplateField HeaderText="Gender">
                        <ItemTemplate>
                            <span class="badge <%# Eval("Gender")?.ToString() == "Male" ? "badge-male" : "badge-female" %>">
                                <i class="bi <%# Eval("Gender")?.ToString() == "Male" ? "bi-gender-male" : "bi-gender-female" %>"></i>
                                <%# Eval("Gender") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <!-- Salary -->
                    <asp:TemplateField HeaderText="Salary" SortExpression="Salary">
                        <HeaderTemplate>
                            <span onclick="sortByColumn('Salary')" style="cursor:pointer;">
                                Salary <i class="bi bi-arrow-down-up sort-icon"></i>
                            </span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            ₹<%# Convert.ToDecimal(Eval("Salary")).ToString("N0") %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <!-- Joining Date -->
                    <asp:TemplateField HeaderText="Joining" SortExpression="JoiningDate">
                        <HeaderTemplate>
                            <span onclick="sortByColumn('JoiningDate')" style="cursor:pointer;">
                                Joining <i class="bi bi-arrow-down-up sort-icon"></i>
                            </span>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <%# Convert.ToDateTime(Eval("JoiningDate")).ToString("dd MMM yyyy") %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <!-- Status -->
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span id='badge_<%# Eval("EmployeeId") %>'
                                  class='badge <%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <!-- Actions -->
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <!-- View -->
                            <a href='EmployeeView.aspx?id=<%# Eval("EmployeeId") %>'
                               class="btn btn-view btn-icon btn-sm" title="View Profile">
                                <i class="bi bi-eye-fill"></i>
                            </a>
                            <!-- Edit -->
                            <a href='EmployeeForm.aspx?id=<%# Eval("EmployeeId") %>'
                               class="btn btn-edit btn-icon btn-sm" title="Edit Employee">
                                <i class="bi bi-pencil-fill"></i>
                            </a>
                            <!-- Delete -->
                            <button type="button" class="btn btn-delete btn-icon btn-sm"
                                    title="Delete Employee"
                                    onclick="confirmDelete(null,'Delete <%# Eval("FullName") %>?',
                                        function(){ doDeleteEmployee(<%# Eval("EmployeeId") %>); });">
                                <i class="bi bi-trash3-fill"></i>
                            </button>
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>
            </asp:GridView>
        </div>

        <!-- Pagination -->
        <div class="pagination-container">
            <div class="pagination-info">
                Showing
                <asp:Literal ID="litPageFrom" runat="server">0</asp:Literal> –
                <asp:Literal ID="litPageTo"   runat="server">0</asp:Literal>
                of
                <asp:Literal ID="litPageTotal" runat="server">0</asp:Literal>
                employees
            </div>
            <nav>
                <ul class="pagination">
                    <asp:Repeater ID="rptPager" runat="server" OnItemCommand="rptPager_ItemCommand">
                        <ItemTemplate>
                            <li class='page-item <%# (int)Eval("PageNumber") == CurrentPage ? "active" : "" %>
                                               <%# (bool)Eval("IsEnabled") ? "" : "disabled" %>'>
                                <asp:LinkButton ID="lbPage" runat="server"
                                    CssClass="page-link"
                                    CommandName="Page"
                                    CommandArgument='<%# Eval("PageNumber") %>'>
                                    <%# Eval("Text") %>
                                </asp:LinkButton>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
            </nav>
        </div>

    </div><!-- /card -->

    <!-- Hidden fields for sort/pagination state -->
    <asp:HiddenField ID="hfSortColumn"  runat="server" Value="CreatedDate" />
    <asp:HiddenField ID="hfSortOrder"   runat="server" Value="DESC" />
    <asp:HiddenField ID="hfCurrentPage" runat="server" Value="1" />
    <asp:LinkButton  ID="lbSort"        runat="server" Style="display:none;" OnClick="lbSort_Click" />

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="cphScripts" runat="server">
<script>
    // Delete employee via AJAX call
    function doDeleteEmployee(employeeId) {
        $.ajax({
            url: '/Handlers/DeleteEmployee.ashx',
            type: 'POST',
            data: JSON.stringify({ employeeId: employeeId }),
            contentType: 'application/json',
            success: function (data) {
                Loader.hide();
                if (data.success) {
                    showToast('success', 'Employee deleted successfully.');
                    setTimeout(function () { location.reload(); }, 1500);
                } else {
                    showToast('error', data.message || 'Failed to delete employee.');
                }
            },
            error: function () {
                Loader.hide();
                showToast('error', 'Connection error. Please try again.');
            }
        });
    }

    // Live search with debounce
    $(document).ready(function () {
        var timer;
        $('#<%= txtSearch.ClientID %>').on('input', function () {
            clearTimeout(timer);
            timer = setTimeout(function () {
                $('#<%= btnSearch.ClientID %>').click();
            }, 400);
        });

        // Trigger search when filter dropdowns change
        $('#<%= ddlFilterDept.ClientID %>, #<%= ddlFilterGender.ClientID %>, #<%= ddlFilterStatus.ClientID %>').on('change', function () {
            $('#<%= btnSearch.ClientID %>').click();
        });
    });
</script>
</asp:Content>
