<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs"
    Inherits="EmployeeManagement.UI.ForgotPassword" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Forgot Password | EMS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
    <link rel="stylesheet" href="CSS/style.css" />
</head>
<body class="login-page">

<div class="login-card">
    <div class="login-logo">
        <i class="bi bi-lock-fill text-white fs-3"></i>
    </div>
    <h1 class="login-title">Forgot Password</h1>
    <p class="login-subtitle">Enter your username to reset your password</p>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="mb-3">
        <div class="alert" id="divAlert" runat="server">
            <asp:Literal ID="litAlert" runat="server" />
        </div>
    </asp:Panel>

    <form runat="server" class="login-form">
        <div class="mb-3">
            <label class="form-label">
                <i class="bi bi-person-fill me-1 text-primary"></i>Username
            </label>
            <div class="input-group">
                <span class="input-group-text">
                    <i class="bi bi-person-fill text-primary"></i>
                </span>
                <asp:TextBox ID="txtUsername" runat="server"
                    CssClass="form-control" placeholder="Enter your username" MaxLength="50" />
            </div>
            <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                ControlToValidate="txtUsername"
                ErrorMessage="Username is required."
                CssClass="invalid-feedback d-block"
                Display="Dynamic" ValidationGroup="ForgotPwd" />
        </div>

        <asp:Button ID="btnReset" runat="server"
            Text="Send Reset Instructions"
            CssClass="btn btn-login"
            OnClick="btnReset_Click"
            ValidationGroup="ForgotPwd" />

        <div class="text-center mt-3">
            <a href="Login.aspx" class="text-primary text-decoration-none fw-600">
                <i class="bi bi-arrow-left me-1"></i> Back to Login
            </a>
        </div>

        <div class="text-center mt-3">
            <small class="text-secondary">
                <i class="bi bi-info-circle me-1"></i>
                In this demo, contact your system administrator to reset your password.
            </small>
        </div>
    </form>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
