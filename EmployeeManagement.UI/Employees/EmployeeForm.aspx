<%@ Page Title="Employee Form" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="EmployeeForm.aspx.cs"
    Inherits="EmployeeManagement.UI.Employees.EmployeeForm" %>

<asp:Content ID="cTitle" ContentPlaceHolderID="cphPageTitle" runat="server">
    <asp:Literal ID="litPageTitle" runat="server">Add Employee</asp:Literal>
</asp:Content>

<asp:Content ID="cBreadcrumb" ContentPlaceHolderID="cphBreadcrumb" runat="server">
    <li class="breadcrumb-item">
        <a href="EmployeeList.aspx">Employees</a>
    </li>
    <li class="breadcrumb-item active">
        <asp:Literal ID="litBreadcrumb" runat="server">Add Employee</asp:Literal>
    </li>
</asp:Content>

<asp:Content ID="cContent" ContentPlaceHolderID="cphContent" runat="server">

    <!-- Page Header -->
    <div class="page-header">
        <div>
            <h1 class="page-title">
                <i class="bi bi-person-plus-fill"></i>
                <asp:Literal ID="litFormTitle" runat="server">Add New Employee</asp:Literal>
            </h1>
            <p class="page-subtitle">Fill in all required fields below.</p>
        </div>
        <a href="EmployeeList.aspx" class="btn btn-outline-primary">
            <i class="bi bi-arrow-left me-1"></i> Back to List
        </a>
    </div>

    <form id="frmEmployee" runat="server">
    <asp:HiddenField ID="hfEmployeeId" runat="server" Value="0" />
    <asp:HiddenField ID="hfExistingPhoto" runat="server" Value="" />

    <div class="row g-4">

        <!-- LEFT COLUMN: Photo + Employee Code -->
        <div class="col-lg-3">
            <div class="card">
                <div class="card-header">
                    <h6 class="card-title m-0"><i class="bi bi-camera-fill"></i> Profile Photo</h6>
                </div>
                <div class="card-body text-center">
                    <div class="photo-upload-container">
                        <img id="imgPhotoPreview"
                             src='<%= ResolveUrl("~/Images/default-avatar.png") %>'
                             class="photo-preview" alt="Employee Photo" />

                        <label class="photo-upload-label" for="<%= fuPhoto.ClientID %>">
                            <i class="bi bi-cloud-upload-fill"></i> Upload Photo
                        </label>
                        <asp:FileUpload ID="fuPhoto" runat="server" CssClass="d-none"
                            onchange="previewPhoto(this.id, 'imgPhotoPreview')" />

                        <small class="text-secondary text-center">
                            JPG, PNG, GIF up to 2MB
                        </small>

                        <asp:Literal ID="litExistingPhoto" runat="server" />
                    </div>
                </div>
            </div>

            <div class="card mt-3">
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label">
                            <i class="bi bi-hash me-1 text-primary"></i>Employee Code
                        </label>
                        <asp:TextBox ID="txtEmployeeCode" runat="server"
                            CssClass="form-control"
                            ReadOnly="true"
                            placeholder="Auto-generated" />
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Status</label>
                        <div class="form-check form-switch">
                            <asp:CheckBox ID="chkIsActive" runat="server"
                                CssClass="form-check-input"
                                Checked="true" />
                            <label class="form-check-label" for="<%= chkIsActive.ClientID %>">
                                Active Employee
                            </label>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- RIGHT COLUMN: All Form Fields -->
        <div class="col-lg-9">
            <div class="card">
                <div class="card-body">

                    <!-- SECTION: Personal Information -->
                    <div class="form-section-title">
                        <i class="bi bi-person-fill"></i> Personal Information
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label">First Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtFirstName" runat="server"
                                CssClass="form-control" placeholder="Enter first name" MaxLength="50" />
                            <asp:RequiredFieldValidator ID="rfvFirstName" runat="server"
                                ControlToValidate="txtFirstName"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> First name is required."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Last Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtLastName" runat="server"
                                CssClass="form-control" placeholder="Enter last name" MaxLength="50" />
                            <asp:RequiredFieldValidator ID="rfvLastName" runat="server"
                                ControlToValidate="txtLastName"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> Last name is required."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Gender <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">-- Select Gender --</asp:ListItem>
                                <asp:ListItem Value="Male">Male</asp:ListItem>
                                <asp:ListItem Value="Female">Female</asp:ListItem>
                                <asp:ListItem Value="Other">Other</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvGender" runat="server"
                                ControlToValidate="ddlGender"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> Please select gender."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Date of Birth</label>
                            <asp:TextBox ID="txtDateOfBirth" runat="server"
                                CssClass="form-control datepicker-dob"
                                placeholder="YYYY-MM-DD" MaxLength="10" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Experience (Years)</label>
                            <asp:TextBox ID="txtExperience" runat="server"
                                CssClass="form-control" TextMode="Number"
                                placeholder="0" />
                        </div>
                    </div>

                    <!-- SECTION: Contact Information -->
                    <div class="form-section-title">
                        <i class="bi bi-envelope-fill"></i> Contact Information
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Email Address <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtEmail" runat="server"
                                CssClass="form-control" TextMode="Email"
                                placeholder="email@company.com" MaxLength="100"
                                onblur="checkDuplicateEmail('<%= txtEmail.ClientID %>', '<%= hfEmployeeId.ClientID %>')" />
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                                ControlToValidate="txtEmail"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> Email is required."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                ControlToValidate="txtEmail"
                                ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> Enter a valid email address."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Mobile Number <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtMobile" runat="server"
                                CssClass="form-control" TextMode="Phone"
                                placeholder="9876543210" MaxLength="15"
                                onblur="checkDuplicateMobile('<%= txtMobile.ClientID %>', '<%= hfEmployeeId.ClientID %>')" />
                            <asp:RequiredFieldValidator ID="rfvMobile" runat="server"
                                ControlToValidate="txtMobile"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> Mobile number is required."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                            <asp:RegularExpressionValidator ID="revMobile" runat="server"
                                ControlToValidate="txtMobile"
                                ValidationExpression="^\+?[0-9]{10,15}$"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> Enter a valid mobile number (10-15 digits)."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                        </div>
                    </div>

                    <!-- SECTION: Work Information -->
                    <div class="form-section-title">
                        <i class="bi bi-briefcase-fill"></i> Work Information
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Department <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlDepartment" runat="server"
                                CssClass="form-select"
                                onchange="loadDesignations(this.value, '<%= ddlDesignation.ClientID %>', '')" >
                                <asp:ListItem Value="">-- Select Department --</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvDepartment" runat="server"
                                ControlToValidate="ddlDepartment"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> Please select a department."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Designation <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlDesignation" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">-- Select Designation --</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvDesignation" runat="server"
                                ControlToValidate="ddlDesignation"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> Please select a designation."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Salary (₹) <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtSalary" runat="server"
                                CssClass="form-control" TextMode="Number"
                                placeholder="0.00" />
                            <asp:RequiredFieldValidator ID="rfvSalary" runat="server"
                                ControlToValidate="txtSalary"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> Salary is required."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                            <asp:RangeValidator ID="rvSalary" runat="server"
                                ControlToValidate="txtSalary"
                                Type="Double" MinimumValue="0" MaximumValue="9999999"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> Enter a valid salary (0 - 9,999,999)."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Joining Date <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtJoiningDate" runat="server"
                                CssClass="form-control datepicker-joining"
                                placeholder="YYYY-MM-DD" MaxLength="10" />
                            <asp:RequiredFieldValidator ID="rfvJoiningDate" runat="server"
                                ControlToValidate="txtJoiningDate"
                                ErrorMessage="<i class='bi bi-exclamation-circle'></i> Joining date is required."
                                CssClass="invalid-feedback d-block" Display="Dynamic" ValidationGroup="EmpForm" />
                        </div>
                    </div>

                    <!-- SECTION: Address Information -->
                    <div class="form-section-title">
                        <i class="bi bi-geo-alt-fill"></i> Address Information
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-12">
                            <label class="form-label">Address</label>
                            <asp:TextBox ID="txtAddress" runat="server"
                                CssClass="form-control" TextMode="MultiLine"
                                Rows="2" placeholder="Street address" MaxLength="200" />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">City</label>
                            <asp:TextBox ID="txtCity" runat="server" CssClass="form-control"
                                placeholder="City" MaxLength="50" />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">State</label>
                            <asp:TextBox ID="txtState" runat="server" CssClass="form-control"
                                placeholder="State" MaxLength="50" />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Country</label>
                            <asp:TextBox ID="txtCountry" runat="server" CssClass="form-control"
                                placeholder="Country" MaxLength="50" />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Zip Code</label>
                            <asp:TextBox ID="txtZipCode" runat="server" CssClass="form-control"
                                placeholder="123456" MaxLength="10" />
                        </div>
                    </div>

                    <!-- ACTION BUTTONS -->
                    <hr class="my-3" />
                    <div class="d-flex justify-content-end gap-3">
                        <a href="EmployeeList.aspx" class="btn btn-outline-primary">
                            <i class="bi bi-x-circle me-1"></i>Cancel
                        </a>
                        <asp:Button ID="btnSave" runat="server"
                            Text="Save Employee"
                            CssClass="btn btn-primary"
                            OnClick="btnSave_Click"
                            ValidationGroup="EmpForm"
                            OnClientClick="return validateEmployeeForm();" />
                    </div>

                </div><!-- /card-body -->
            </div><!-- /card -->
        </div><!-- /col -->

    </div><!-- /row -->
    </form>

</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="cphScripts" runat="server">
<script>
    // Re-load designations for edit mode (if DepartmentId is pre-selected)
    $(document).ready(function () {
        var deptId  = $('#<%= ddlDepartment.ClientID %>').val();
        var desigId = '<%= EditDesignationId %>';

        if (deptId) {
            loadDesignations(deptId, '<%= ddlDesignation.ClientID %>', desigId);
        }
    });
</script>
</asp:Content>
