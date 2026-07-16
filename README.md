# 🏢 Enterprise Employee Management System

A **production-ready** Enterprise Employee Management System built using:

- **ASP.NET Web Forms** (.NET Framework 4.8)
- **C#** with 3-Tier Architecture (UI / BLL / DAL)
- **ADO.NET** (No Entity Framework) — SqlConnection, SqlCommand, SqlDataReader, SqlDataAdapter
- **SQL Server** with Stored Procedures
- **Bootstrap 5** + jQuery + SweetAlert2 + Flatpickr

---

## 📁 Project Structure

```
EmployeeManagement/
│
├── EmployeeManagement.sln           ← Visual Studio Solution
│
├── Database/
│   └── EmployeeDB_Schema.sql        ← Complete DB setup script
│
├── EmployeeManagement.UI/           ← Presentation Layer (Web App)
│   ├── Web.config                   ← Connection string & config
│   ├── Site.Master / .cs            ← Master page (sidebar + topbar)
│   ├── Login.aspx / .cs             ← Login with Remember Me
│   ├── ForgotPassword.aspx / .cs    ← Forgot password UI
│   ├── Default.aspx / .cs           ← Dashboard (7 KPI cards)
│   ├── Employees/
│   │   ├── EmployeeList.aspx / .cs  ← List + Search + Filter + Sort + Pagination
│   │   ├── EmployeeForm.aspx / .cs  ← Add/Edit with photo upload
│   │   └── EmployeeView.aspx / .cs  ← Employee profile view
│   ├── Departments/
│   │   └── DepartmentList.aspx / .cs
│   ├── Designations/
│   │   └── DesignationList.aspx / .cs
│   ├── Reports/
│   │   └── EmployeeReport.aspx / .cs ← 3 report types + Excel + Print
│   ├── Handlers/                    ← AJAX HTTP Handlers (.ashx)
│   │   ├── GetDesignations.ashx     ← Cascading dropdown
│   │   ├── CheckDuplicate.ashx      ← Real-time email/mobile check
│   │   ├── DeleteEmployee.ashx
│   │   ├── DeleteDepartment.ashx
│   │   ├── DeleteDesignation.ashx
│   │   ├── GetDepartment.ashx
│   │   ├── GetDesignation.ashx
│   │   └── UpdateStatus.ashx
│   ├── CSS/style.css                ← Custom styles (1000+ lines)
│   ├── JS/app.js                    ← jQuery + AJAX + SweetAlert2
│   └── Images/Uploads/              ← Employee photo uploads
│
├── EmployeeManagement.BLL/          ← Business Logic Layer
│   ├── Models/
│   │   ├── UserModel.cs
│   │   ├── DepartmentModel.cs
│   │   ├── DesignationModel.cs
│   │   └── EmployeeModel.cs
│   └── Services/
│       ├── UserService.cs           ← SHA-256 password hashing
│       ├── DepartmentService.cs
│       ├── DesignationService.cs
│       └── EmployeeService.cs       ← Full validation logic
│
└── EmployeeManagement.DAL/          ← Data Access Layer
    ├── ConnectionManager.cs         ← Centralized connection factory
    ├── UserDAL.cs
    ├── DepartmentDAL.cs
    ├── DesignationDAL.cs
    └── EmployeeDAL.cs               ← Full CRUD + pagination + filters
```

---

## 🚀 Getting Started

### 1. Setup Database

1. Open **SQL Server Management Studio (SSMS)**
2. Open `Database/EmployeeDB_Schema.sql`
3. Execute the script — it will create `EmployeeDB` with all tables, stored procedures, and sample data

### 2. Configure Connection String

Edit `EmployeeManagement.UI/Web.config`:
```xml
<add name="EmployeeDBConnection"
     connectionString="Server=YOUR_SERVER;Database=EmployeeDB;Integrated Security=True;" />
```
Replace `YOUR_SERVER` with your SQL Server instance (e.g., `localhost`, `.\SQLEXPRESS`, `(localdb)\MSSQLLocalDB`).

### 3. Open in Visual Studio

1. Open `EmployeeManagement.sln` in **Visual Studio 2019/2022**
2. Right-click `EmployeeManagement.UI` → Set as Startup Project
3. Press **F5** to run

### 4. Login

| Username | Password |
|----------|----------|
| `admin`  | `Admin@123` |
| `hrmanager` | `Admin@123` |

---

## ✨ Features

| Module | Features |
|--------|----------|
| **Authentication** | Login, Logout, Remember Me, Session Management, Forgot Password UI |
| **Dashboard** | 7 KPI Cards, Latest Employees, Recent Audit Activities |
| **Employees** | Full CRUD, Photo Upload, Auto Code, Search, Filter, Sort, Pagination, Status Toggle |
| **Departments** | CRUD via Bootstrap Modal, Search, Employee Count |
| **Designations** | CRUD via Bootstrap Modal, Department-linked Cascading Dropdown |
| **Reports** | Employee, Salary, Department Reports with Excel Export & Print |
| **Validation** | Required, Email, Phone, Salary, Duplicate Email, Duplicate Mobile (AJAX) |
| **AJAX** | Live Search, Cascading Dropdown, Delete, Status Toggle, Duplicate Check |
| **UI** | Responsive Sidebar, Bootstrap 5, SweetAlert2, Flatpickr, Dark Sidebar Theme |

---

## 🔒 Security Notes

- Passwords stored as SHA-256 hash (upgrade to BCrypt/PBKDF2 for production)
- Parameterized queries prevent SQL injection
- Session-based authentication with Forms Auth
- Authorization blocks unauthenticated access to all pages

---

## 📦 Technologies

| Technology | Version |
|-----------|---------|
| ASP.NET Web Forms | .NET 4.8 |
| Bootstrap | 5.3.2 |
| jQuery | 3.7.1 |
| SweetAlert2 | 11.x |
| Flatpickr | Latest |
| Bootstrap Icons | 1.11.3 |
| SQL Server | 2016+ |

---

## 📜 Database Tables

| Table | Purpose |
|-------|---------|
| `Users` | Application login credentials |
| `Departments` | Company departments |
| `Designations` | Job titles (linked to departments) |
| `Employees` | Employee profiles |
| `AuditLogs` | All CRUD activity log |

---

© 2024 Enterprise Employee Management System. Built with ❤️ using ASP.NET Web Forms & ADO.NET.
