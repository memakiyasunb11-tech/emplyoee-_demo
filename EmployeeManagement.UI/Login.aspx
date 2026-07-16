<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs"
    Inherits="EmployeeManagement.UI.Login" %>
<!DOCTYPE html>
<!--
    Login.aspx - Authentication Page
    WHY: The Login page is the entry point of the application.
    It does NOT use the Master Page (no sidebar/topbar needed).
    It handles: username/password login, Remember Me cookie,
    Forgot Password link, and session creation on success.
-->
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login | Employee Management System</title>
    <meta name="description" content="Login to Enterprise Employee Management System" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
    <link rel="stylesheet" href="CSS/style.css" />
    <style>
        /* Password toggle button */
        .password-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            border: none;
            background: none;
            color: #64748b;
            cursor: pointer;
            padding: 0;
            font-size: 16px;
            z-index: 10;
        }
        .password-toggle:hover { color: #4f46e5; }
        .input-password-wrapper { position: relative; }
    </style>
</head>
<body class="login-page">

<div class="login-card">

    <!-- Logo -->
    <div class="login-logo">
        <i class="bi bi-people-fill text-white fs-3"></i>
    </div>

    <!-- Title -->
    <h1 class="login-title">Welcome Back!</h1>
    <p class="login-subtitle">Sign in to your account to continue</p>

    <!-- Error / Success Message -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="mb-3">
        <div class="alert" id="divAlert" runat="server">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <asp:Literal ID="litAlert" runat="server" />
        </div>
    </asp:Panel>

    <!-- Login Form -->
    <form id="loginForm" runat="server" class="login-form">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <!-- Username -->
        <div class="mb-3">
            <label for="txtUsername" class="form-label">
                <i class="bi bi-person-fill me-1 text-primary"></i>Username
            </label>
            <div class="input-group">
                <span class="input-group-text">
                    <i class="bi bi-person-fill text-primary"></i>
                </span>
                <asp:TextBox ID="txtUsername" runat="server"
                    CssClass="form-control"
                    placeholder="Enter your username"
                    MaxLength="50"
                    autocomplete="username" />
            </div>
            <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                ControlToValidate="txtUsername"
                ErrorMessage="Username is required."
                CssClass="invalid-feedback d-block"
                Display="Dynamic"
                ValidationGroup="Login" />
        </div>

        <!-- Password -->
        <div class="mb-3">
            <label for="txtPassword" class="form-label">
                <i class="bi bi-lock-fill me-1 text-primary"></i>Password
            </label>
            <div class="input-group">
                <span class="input-group-text">
                    <i class="bi bi-lock-fill text-primary"></i>
                </span>
                <div class="input-password-wrapper flex-grow-1">
                    <asp:TextBox ID="txtPassword" runat="server"
                        TextMode="Password"
                        CssClass="form-control"
                        placeholder="Enter your password"
                        MaxLength="50"
                        autocomplete="current-password" />
                    <button type="button" class="password-toggle" id="btnTogglePassword"
                            title="Show/hide password">
                        <i class="bi bi-eye-fill" id="iPasswordEye"></i>
                    </button>
                </div>
            </div>
            <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                ControlToValidate="txtPassword"
                ErrorMessage="Password is required."
                CssClass="invalid-feedback d-block"
                Display="Dynamic"
                ValidationGroup="Login" />
        </div>

        <!-- Remember Me + Forgot Password -->
        <div class="login-remember">
            <div class="form-check">
                <asp:CheckBox ID="chkRememberMe" runat="server" CssClass="form-check-input" />
                <label class="form-check-label" for="<%= chkRememberMe.ClientID %>">
                    Remember me
                </label>
            </div>
            <a href="ForgotPassword.aspx" class="login-forgot">Forgot password?</a>
        </div>

        <!-- Submit Button -->
        <asp:Button ID="btnLogin" runat="server"
            Text="Sign In"
            CssClass="btn btn-login"
            OnClick="btnLogin_Click"
            ValidationGroup="Login"
            UseSubmitBehavior="true" />

        <!-- Demo Credentials hint -->
        <div class="text-center mt-3">
            <small class="text-secondary">
                Demo: <strong>admin</strong> / <strong>Admin@123</strong>
            </small>
        </div>

    </form><!-- /loginForm -->

    <!-- Footer -->
    <div class="text-center mt-4">
        <small class="text-secondary">
            &copy; <%= DateTime.Now.Year %> Employee Management System. All rights reserved.
        </small>
    </div>

</div><!-- /login-card -->

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Password visibility toggle
    $('#btnTogglePassword').on('click', function () {
        var $pwdInput = $('#<%= txtPassword.ClientID %>');
        var $icon     = $('#iPasswordEye');

        if ($pwdInput.attr('type') === 'password') {
            $pwdInput.attr('type', 'text');
            $icon.removeClass('bi-eye-fill').addClass('bi-eye-slash-fill');
        } else {
            $pwdInput.attr('type', 'password');
            $icon.removeClass('bi-eye-slash-fill').addClass('bi-eye-fill');
        }
    });

    // Press Enter to submit
    $('#<%= txtPassword.ClientID %>').on('keypress', function (e) {
        if (e.which === 13) { $('#<%= btnLogin.ClientID %>').click(); }
    });
</script>

</body>
</html>
