<%@ Page Title="Departments" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="DepartmentList.aspx.cs"
    Inherits="EmployeeManagement.UI.Departments.DepartmentList" %>

<asp:Content ID="cTitle" ContentPlaceHolderID="cphPageTitle" runat="server">
    Departments
</asp:Content>

<asp:Content ID="cBreadcrumb" ContentPlaceHolderID="cphBreadcrumb" runat="server">
    <li class="breadcrumb-item active">Departments</li>
</asp:Content>

<asp:Content ID="cContent" ContentPlaceHolderID="cphContent" runat="server">

    <div class="page-header">
        <div>
            <h1 class="page-title"><i class="bi bi-building-fill"></i> Departments</h1>
            <p class="page-subtitle">Manage company departments.</p>
        </div>
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalDepartment"
                onclick="openAddModal();">
            <i class="bi bi-plus-lg me-1"></i> Add Department
        </button>
    </div>

    <!-- Search Bar -->
    <div class="search-filter-bar">
        <div class="search-input-wrapper">
            <i class="bi bi-search"></i>
            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="form-control" placeholder="Search departments..." />
        </div>
        <asp:Button ID="btnSearch" runat="server" Text="Search"
            CssClass="btn btn-primary" OnClick="btnSearch_Click" />
        <asp:Button ID="btnReset" runat="server" Text="Reset"
            CssClass="btn btn-outline-primary" OnClick="btnReset_Click" />
    </div>

    <!-- Department Table Card -->
    <div class="card">
        <div class="card-header">
            <h5 class="card-title">
                <i class="bi bi-table me-1"></i>All Departments
                <span class="badge bg-primary ms-2" id="deptCount" runat="server">0</span>
            </h5>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvDepartments" runat="server"
                CssClass="table"
                AutoGenerateColumns="false"
                GridLines="None"
                DataKeyNames="DepartmentId"
                EmptyDataText="No departments found."
                OnRowCommand="gvDepartments_RowCommand">
                <Columns>
                    <asp:BoundField DataField="DepartmentId" HeaderText="#" />
                    <asp:BoundField DataField="DepartmentName" HeaderText="Department Name" />
                    <asp:BoundField DataField="Description"    HeaderText="Description" />
                    <asp:BoundField DataField="EmployeeCount"  HeaderText="Employees" />
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='badge <%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="CreatedDate" HeaderText="Created" DataFormatString="{0:dd MMM yyyy}" />
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <button type="button" class="btn btn-edit btn-icon btn-sm" title="Edit"
                                    onclick="openEditModal(<%# Eval("DepartmentId") %>);">
                                <i class="bi bi-pencil-fill"></i>
                            </button>
                            <button type="button" class="btn btn-delete btn-icon btn-sm" title="Delete"
                                    onclick="confirmDelete(null,'Delete department?',
                                        function(){ doDeleteDepartment(<%# Eval("DepartmentId") %>); });">
                                <i class="bi bi-trash3-fill"></i>
                            </button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- ============================================
         ADD / EDIT DEPARTMENT MODAL
         ============================================ -->
    <div class="modal fade" id="modalDepartment" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle">Add Department</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="frmDepartment" runat="server">
                    <asp:HiddenField ID="hfDeptId" runat="server" Value="0" />
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Department Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtDepartmentName" runat="server"
                                CssClass="form-control" placeholder="e.g. Information Technology"
                                MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvDeptName" runat="server"
                                ControlToValidate="txtDepartmentName"
                                ErrorMessage="Department name is required."
                                CssClass="invalid-feedback d-block" Display="Dynamic"
                                ValidationGroup="DeptForm" />
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Description</label>
                            <asp:TextBox ID="txtDeptDescription" runat="server"
                                CssClass="form-control" TextMode="MultiLine"
                                Rows="3" placeholder="Brief description..." MaxLength="500" />
                        </div>
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkDeptActive" runat="server"
                                    CssClass="form-check-input" Checked="true" />
                                <label class="form-check-label">Active</label>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-primary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnSaveDept" runat="server"
                            Text="Save Department"
                            CssClass="btn btn-primary"
                            OnClick="btnSaveDept_Click"
                            ValidationGroup="DeptForm" />
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Hidden asp:HiddenField for AJAX delete callback -->
    <asp:HiddenField ID="hfDeleteDeptId" runat="server" />
    <asp:LinkButton ID="lbDeleteDept" runat="server" Style="display:none;"
        OnClick="lbDeleteDept_Click" />

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="cphScripts" runat="server">
<script>
    var deptModal;

    $(document).ready(function () {
        deptModal = new bootstrap.Modal(document.getElementById('modalDepartment'));

        // Live search
        var timer;
        $('#<%= txtSearch.ClientID %>').on('input', function () {
            clearTimeout(timer);
            timer = setTimeout(function () {
                $('#<%= btnSearch.ClientID %>').click();
            }, 400);
        });
    });

    function openAddModal() {
        // Clear form
        $('#<%= hfDeptId.ClientID %>').val('0');
        $('#<%= txtDepartmentName.ClientID %>').val('');
        $('#<%= txtDeptDescription.ClientID %>').val('');
        $('#<%= chkDeptActive.ClientID %>').prop('checked', true);
        $('#modalTitle').text('Add Department');
        $('#<%= btnSaveDept.ClientID %>').val('Save Department');
    }

    function openEditModal(deptId) {
        Loader.show();
        $.ajax({
            url: '/Handlers/GetDepartment.ashx',
            type: 'GET',
            data: { id: deptId },
            dataType: 'json',
            success: function (data) {
                Loader.hide();
                if (data) {
                    $('#<%= hfDeptId.ClientID %>').val(data.DepartmentId);
                    $('#<%= txtDepartmentName.ClientID %>').val(data.DepartmentName);
                    $('#<%= txtDeptDescription.ClientID %>').val(data.Description);
                    $('#<%= chkDeptActive.ClientID %>').prop('checked', data.IsActive);
                    $('#modalTitle').text('Edit Department');
                    $('#<%= btnSaveDept.ClientID %>').val('Update Department');
                    deptModal.show();
                }
            },
            error: function () {
                Loader.hide();
                showToast('error', 'Failed to load department.');
            }
        });
    }

    function doDeleteDepartment(deptId) {
        $.ajax({
            url: '/Handlers/DeleteDepartment.ashx',
            type: 'POST',
            data: JSON.stringify({ departmentId: deptId }),
            contentType: 'application/json',
            success: function (data) {
                Loader.hide();
                if (data.success) {
                    showToast('success', 'Department deleted.');
                    setTimeout(function () { location.reload(); }, 1500);
                } else {
                    showToast('error', data.message);
                }
            },
            error: function () {
                Loader.hide();
                showToast('error', 'Error occurred.');
            }
        });
    }
</script>
</asp:Content>
