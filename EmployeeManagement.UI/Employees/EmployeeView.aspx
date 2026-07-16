<%@ Page Title="Employee Profile" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="EmployeeView.aspx.cs"
    Inherits="EmployeeManagement.UI.Employees.EmployeeView" %>

<asp:Content ID="cTitle" ContentPlaceHolderID="cphPageTitle" runat="server">
    Employee Profile
</asp:Content>

<asp:Content ID="cBreadcrumb" ContentPlaceHolderID="cphBreadcrumb" runat="server">
    <li class="breadcrumb-item"><a href="EmployeeList.aspx">Employees</a></li>
    <li class="breadcrumb-item active">Profile</li>
</asp:Content>

<asp:Content ID="cContent" ContentPlaceHolderID="cphContent" runat="server">

    <div class="page-header">
        <h1 class="page-title">
            <i class="bi bi-person-badge-fill"></i> Employee Profile
        </h1>
        <div class="d-flex gap-2">
            <asp:HyperLink ID="hlEdit" runat="server" CssClass="btn btn-primary">
                <i class="bi bi-pencil-fill me-1"></i>Edit
            </asp:HyperLink>
            <a href="EmployeeList.aspx" class="btn btn-outline-primary">
                <i class="bi bi-arrow-left me-1"></i>Back
            </a>
        </div>
    </div>

    <!-- Profile Header Card -->
    <div class="card">
        <div class="employee-profile-header">
            <asp:Image ID="imgPhoto" runat="server"
                CssClass="profile-photo-lg" AlternateText="Employee Photo"
                Visible="false" />
            <asp:Panel ID="pnlAvatar" runat="server" CssClass="profile-avatar-lg">
                <asp:Literal ID="litInitials" runat="server" />
            </asp:Panel>
            <div class="profile-info">
                <h2>
                    <asp:Literal ID="litFullName" runat="server" />
                </h2>
                <p>
                    <asp:Literal ID="litDesignation" runat="server" />
                    &nbsp;•&nbsp;
                    <asp:Literal ID="litDepartment" runat="server" />
                </p>
                <div class="d-flex gap-2 flex-wrap">
                    <span class="badge bg-white text-dark">
                        <i class="bi bi-hash me-1"></i>
                        <asp:Literal ID="litEmpCode" runat="server" />
                    </span>
                    <asp:Panel ID="pnlStatusBadge" runat="server">
                        <!-- Rendered from code-behind -->
                    </asp:Panel>
                </div>
            </div>
        </div>

        <!-- Detail Tabs -->
        <div class="card-body">
            <ul class="nav nav-tabs mb-4" id="profileTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" data-bs-toggle="tab"
                            data-bs-target="#tabPersonal" type="button">
                        <i class="bi bi-person-fill me-1"></i>Personal
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" data-bs-toggle="tab"
                            data-bs-target="#tabWork" type="button">
                        <i class="bi bi-briefcase-fill me-1"></i>Work
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" data-bs-toggle="tab"
                            data-bs-target="#tabAddress" type="button">
                        <i class="bi bi-geo-alt-fill me-1"></i>Address
                    </button>
                </li>
            </ul>

            <div class="tab-content" id="profileTabContent">

                <!-- Personal Info Tab -->
                <div class="tab-pane fade show active" id="tabPersonal" role="tabpanel">
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-person-fill"></i>Full Name</div>
                        <div class="profile-detail-value fw-600"><asp:Literal ID="litFullName2" runat="server" /></div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-gender-ambiguous"></i>Gender</div>
                        <div class="profile-detail-value"><asp:Literal ID="litGender" runat="server" /></div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-calendar-fill"></i>Date of Birth</div>
                        <div class="profile-detail-value"><asp:Literal ID="litDob" runat="server" /></div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-person-fill"></i>Age</div>
                        <div class="profile-detail-value"><asp:Literal ID="litAge" runat="server" /> years</div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-envelope-fill"></i>Email</div>
                        <div class="profile-detail-value">
                            <a href='mailto:<asp:Literal ID="litEmailLink" runat="server" />'>
                                <asp:Literal ID="litEmail" runat="server" />
                            </a>
                        </div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-phone-fill"></i>Mobile</div>
                        <div class="profile-detail-value"><asp:Literal ID="litMobile" runat="server" /></div>
                    </div>
                </div>

                <!-- Work Info Tab -->
                <div class="tab-pane fade" id="tabWork" role="tabpanel">
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-building-fill"></i>Department</div>
                        <div class="profile-detail-value fw-600"><asp:Literal ID="litDept2" runat="server" /></div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-briefcase-fill"></i>Designation</div>
                        <div class="profile-detail-value"><asp:Literal ID="litDesig2" runat="server" /></div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-currency-rupee"></i>Salary</div>
                        <div class="profile-detail-value fw-600 text-success">
                            ₹<asp:Literal ID="litSalary" runat="server" />
                        </div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-calendar-check-fill"></i>Joining Date</div>
                        <div class="profile-detail-value"><asp:Literal ID="litJoiningDate" runat="server" /></div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-award-fill"></i>Experience</div>
                        <div class="profile-detail-value"><asp:Literal ID="litExperience" runat="server" /> year(s)</div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-calendar-plus-fill"></i>Created</div>
                        <div class="profile-detail-value"><asp:Literal ID="litCreatedDate" runat="server" /></div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-calendar-check"></i>Last Updated</div>
                        <div class="profile-detail-value"><asp:Literal ID="litUpdatedDate" runat="server" /></div>
                    </div>
                </div>

                <!-- Address Info Tab -->
                <div class="tab-pane fade" id="tabAddress" role="tabpanel">
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-house-fill"></i>Address</div>
                        <div class="profile-detail-value"><asp:Literal ID="litAddress" runat="server" /></div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-geo-fill"></i>City</div>
                        <div class="profile-detail-value"><asp:Literal ID="litCity" runat="server" /></div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-map-fill"></i>State</div>
                        <div class="profile-detail-value"><asp:Literal ID="litState" runat="server" /></div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-globe-americas"></i>Country</div>
                        <div class="profile-detail-value"><asp:Literal ID="litCountry" runat="server" /></div>
                    </div>
                    <div class="profile-detail-row">
                        <div class="profile-detail-label"><i class="bi bi-mailbox-fill"></i>Zip Code</div>
                        <div class="profile-detail-value"><asp:Literal ID="litZipCode" runat="server" /></div>
                    </div>
                </div>

            </div>
        </div>
    </div>

</asp:Content>
