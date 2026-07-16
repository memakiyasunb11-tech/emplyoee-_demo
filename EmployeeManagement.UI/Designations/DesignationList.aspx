<%@ Page Title="Designations" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="DesignationList.aspx.cs"
    Inherits="EmployeeManagement.UI.Designations.DesignationList" %>

<asp:Content ID="cTitle" ContentPlaceHolderID="cphPageTitle" runat="server">
    Designations
</asp:Content>

<asp:Content ID="cBreadcrumb" ContentPlaceHolderID="cphBreadcrumb" runat="server">
    <li class="breadcrumb-item active">Designations</li>
</asp:Content>

<asp:Content ID="cContent" ContentPlaceHolderID="cphContent" runat="server">

    <div class="page-header">
        <div>
            <h1 class="page-title"><i class="bi bi-briefcase-fill"></i> Designations</h1>
            <p class="page-subtitle">Manage job designations by department.</p>
        </div>
        <button type="button" class="btn btn-primary"
                data-bs-toggle="modal" data-bs-target="#modalDesignation"
                onclick="openAddDesigModal();">
            <i class="bi bi-plus-lg me-1"></i>Add Designation
        </button>
    </div>

    <!-- Search & Filter -->
    <div class="search-filter-bar">
        <div class="search-input-wrapper">
            <i class="bi bi-search"></i>
            <asp:TextBox ID="txtSearch" runat="server"
                CssClass="form-control" placeholder="Search designations..." />
        </div>
        <asp:DropDownList ID="ddlFilterDept" runat="server"
            CssClass="form-select" Style="max-width:200px;">
            <asp:ListItem Value="">All Departments</asp:ListItem>
        </asp:DropDownList>
        <asp:Button ID="btnSearch" runat="server" Text="Search"
            CssClass="btn btn-primary" OnClick="btnSearch_Click" />
        <asp:Button ID="btnReset" runat="server" Text="Reset"
            CssClass="btn btn-outline-primary" OnClick="btnReset_Click" />
    </div>

    <!-- Designation Table -->
    <div class="card">
        <div class="card-header">
            <h5 class="card-title">
                <i class="bi bi-table me-1"></i>All Designations
                <span class="badge bg-primary ms-2" id="desigCount" runat="server">0</span>
            </h5>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvDesignations" runat="server"
                CssClass="table" AutoGenerateColumns="false"
                GridLines="None" DataKeyNames="DesignationId"
                EmptyDataText="No designations found."
                OnRowCommand="gvDesignations_RowCommand">
                <Columns>
                    <asp:BoundField DataField="DesignationId"   HeaderText="#" />
                    <asp:BoundField DataField="DesignationName" HeaderText="Designation Name" />
                    <asp:BoundField DataField="DepartmentName"  HeaderText="Department" />
                    <asp:BoundField DataField="Description"     HeaderText="Description" />
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='badge <%# Convert.ToBoolean(Eval("IsActive")) ? "badge-active" : "badge-inactive" %>'>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="CreatedDate" HeaderText="Created"
                        DataFormatString="{0:dd MMM yyyy}" />
                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <button type="button" class="btn btn-edit btn-icon btn-sm"
                                    onclick="openEditDesigModal(<%# Eval("DesignationId") %>);">
                                <i class="bi bi-pencil-fill"></i>
                            </button>
                            <button type="button" class="btn btn-delete btn-icon btn-sm"
                                    onclick="confirmDelete(null,'Delete designation?',
                                        function(){ doDeleteDesignation(<%# Eval("DesignationId") %>); });">
                                <i class="bi bi-trash3-fill"></i>
                            </button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- ADD/EDIT DESIGNATION MODAL -->
    <div class="modal fade" id="modalDesignation" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="desigModalTitle">Add Designation</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="frmDesignation" runat="server">
                    <asp:HiddenField ID="hfDesigId" runat="server" Value="0" />
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Department <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlDepartmentDesig" runat="server"
                                CssClass="form-select">
                                <asp:ListItem Value="">-- Select Department --</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvDesigDept" runat="server"
                                ControlToValidate="ddlDepartmentDesig"
                                ErrorMessage="Please select a department."
                                CssClass="invalid-feedback d-block"
                                Display="Dynamic" ValidationGroup="DesigForm" />
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Designation Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtDesignationName" runat="server"
                                CssClass="form-control" placeholder="e.g. Software Engineer"
                                MaxLength="100" />
                            <asp:RequiredFieldValidator ID="rfvDesigName" runat="server"
                                ControlToValidate="txtDesignationName"
                                ErrorMessage="Designation name is required."
                                CssClass="invalid-feedback d-block"
                                Display="Dynamic" ValidationGroup="DesigForm" />
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Description</label>
                            <asp:TextBox ID="txtDesigDescription" runat="server"
                                CssClass="form-control" TextMode="MultiLine"
                                Rows="3" placeholder="Brief description..." MaxLength="500" />
                        </div>
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <asp:CheckBox ID="chkDesigActive" runat="server"
                                    CssClass="form-check-input" Checked="true" />
                                <label class="form-check-label">Active</label>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-primary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnSaveDesig" runat="server"
                            Text="Save Designation"
                            CssClass="btn btn-primary"
                            OnClick="btnSaveDesig_Click"
                            ValidationGroup="DesigForm" />
                    </div>
                </form>
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="cphScripts" runat="server">
<script>
    var desigModal;
    $(document).ready(function () {
        desigModal = new bootstrap.Modal(document.getElementById('modalDesignation'));
    });

    function openAddDesigModal() {
        $('#<%= hfDesigId.ClientID %>').val('0');
        $('#<%= txtDesignationName.ClientID %>').val('');
        $('#<%= txtDesigDescription.ClientID %>').val('');
        $('#<%= ddlDepartmentDesig.ClientID %>').val('');
        $('#<%= chkDesigActive.ClientID %>').prop('checked', true);
        $('#desigModalTitle').text('Add Designation');
        $('#<%= btnSaveDesig.ClientID %>').val('Save Designation');
    }

    function openEditDesigModal(desigId) {
        Loader.show();
        $.ajax({
            url: '/Handlers/GetDesignation.ashx',
            type: 'GET',
            data: { id: desigId },
            dataType: 'json',
            success: function (data) {
                Loader.hide();
                if (data) {
                    $('#<%= hfDesigId.ClientID %>').val(data.DesignationId);
                    $('#<%= ddlDepartmentDesig.ClientID %>').val(data.DepartmentId);
                    $('#<%= txtDesignationName.ClientID %>').val(data.DesignationName);
                    $('#<%= txtDesigDescription.ClientID %>').val(data.Description);
                    $('#<%= chkDesigActive.ClientID %>').prop('checked', data.IsActive);
                    $('#desigModalTitle').text('Edit Designation');
                    $('#<%= btnSaveDesig.ClientID %>').val('Update Designation');
                    desigModal.show();
                }
            },
            error: function () {
                Loader.hide();
                showToast('error', 'Failed to load designation.');
            }
        });
    }

    function doDeleteDesignation(desigId) {
        $.ajax({
            url: '/Handlers/DeleteDesignation.ashx',
            type: 'POST',
            data: JSON.stringify({ designationId: desigId }),
            contentType: 'application/json',
            success: function (data) {
                Loader.hide();
                if (data.success) {
                    showToast('success', 'Designation deleted.');
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
