-- =============================================
-- Enterprise Employee Management System
-- Database: EmployeeDB
-- Author: Senior .NET Architect
-- Created: 2024
-- Description: Complete database schema with
--              tables, indexes, foreign keys,
--              constraints, stored procedures,
--              and sample data.
-- =============================================

USE master;
GO

-- Drop database if it exists (for fresh setup)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'EmployeeDB')
BEGIN
    ALTER DATABASE EmployeeDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EmployeeDB;
END
GO

-- Create the EmployeeDB database
CREATE DATABASE EmployeeDB;
GO

USE EmployeeDB;
GO

-- =============================================
-- TABLE: Departments
-- Stores department information
-- =============================================
CREATE TABLE Departments
(
    DepartmentId    INT             IDENTITY(1,1)   NOT NULL,
    DepartmentName  NVARCHAR(100)   NOT NULL,
    Description     NVARCHAR(500)   NULL,
    IsActive        BIT             NOT NULL    DEFAULT(1),
    CreatedDate     DATETIME        NOT NULL    DEFAULT(GETDATE()),
    UpdatedDate     DATETIME        NULL,

    CONSTRAINT PK_Departments PRIMARY KEY CLUSTERED (DepartmentId ASC),
    CONSTRAINT UQ_Departments_Name UNIQUE (DepartmentName)
);
GO

-- =============================================
-- TABLE: Designations
-- Stores designation/job title information
-- linked to a department
-- =============================================
CREATE TABLE Designations
(
    DesignationId   INT             IDENTITY(1,1)   NOT NULL,
    DesignationName NVARCHAR(100)   NOT NULL,
    DepartmentId    INT             NOT NULL,
    Description     NVARCHAR(500)   NULL,
    IsActive        BIT             NOT NULL    DEFAULT(1),
    CreatedDate     DATETIME        NOT NULL    DEFAULT(GETDATE()),
    UpdatedDate     DATETIME        NULL,

    CONSTRAINT PK_Designations PRIMARY KEY CLUSTERED (DesignationId ASC),
    CONSTRAINT FK_Designations_Departments FOREIGN KEY (DepartmentId)
        REFERENCES Departments(DepartmentId),
    CONSTRAINT UQ_Designations_Name_Dept UNIQUE (DesignationName, DepartmentId)
);
GO

-- =============================================
-- TABLE: Employees
-- Stores complete employee profile data
-- =============================================
CREATE TABLE Employees
(
    EmployeeId      INT             IDENTITY(1,1)   NOT NULL,
    EmployeeCode    NVARCHAR(20)    NOT NULL,
    FirstName       NVARCHAR(50)    NOT NULL,
    LastName        NVARCHAR(50)    NOT NULL,
    Gender          NVARCHAR(10)    NOT NULL,
    DateOfBirth     DATE            NULL,
    Email           NVARCHAR(100)   NOT NULL,
    Mobile          NVARCHAR(15)    NOT NULL,
    DepartmentId    INT             NOT NULL,
    DesignationId   INT             NOT NULL,
    Salary          DECIMAL(18,2)   NOT NULL    DEFAULT(0),
    JoiningDate     DATE            NOT NULL,
    Experience      INT             NULL        DEFAULT(0),
    Address         NVARCHAR(200)   NULL,
    City            NVARCHAR(50)    NULL,
    State           NVARCHAR(50)    NULL,
    Country         NVARCHAR(50)    NULL,
    ZipCode         NVARCHAR(10)    NULL,
    IsActive        BIT             NOT NULL    DEFAULT(1),
    Photo           NVARCHAR(200)   NULL,
    CreatedDate     DATETIME        NOT NULL    DEFAULT(GETDATE()),
    UpdatedDate     DATETIME        NULL,

    CONSTRAINT PK_Employees PRIMARY KEY CLUSTERED (EmployeeId ASC),
    CONSTRAINT UQ_Employees_Code UNIQUE (EmployeeCode),
    CONSTRAINT UQ_Employees_Email UNIQUE (Email),
    CONSTRAINT UQ_Employees_Mobile UNIQUE (Mobile),
    CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentId)
        REFERENCES Departments(DepartmentId),
    CONSTRAINT FK_Employees_Designations FOREIGN KEY (DesignationId)
        REFERENCES Designations(DesignationId),
    CONSTRAINT CK_Employees_Gender CHECK (Gender IN ('Male', 'Female', 'Other')),
    CONSTRAINT CK_Employees_Salary CHECK (Salary >= 0)
);
GO

-- =============================================
-- TABLE: Users
-- Stores application login credentials
-- =============================================
CREATE TABLE Users
(
    UserId          INT             IDENTITY(1,1)   NOT NULL,
    Username        NVARCHAR(50)    NOT NULL,
    PasswordHash    NVARCHAR(256)   NOT NULL,
    FullName        NVARCHAR(100)   NULL,
    Email           NVARCHAR(100)   NULL,
    Role            NVARCHAR(20)    NOT NULL    DEFAULT('Admin'),
    IsActive        BIT             NOT NULL    DEFAULT(1),
    LastLoginDate   DATETIME        NULL,
    CreatedDate     DATETIME        NOT NULL    DEFAULT(GETDATE()),

    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UserId ASC),
    CONSTRAINT UQ_Users_Username UNIQUE (Username)
);
GO

-- =============================================
-- TABLE: AuditLogs
-- Tracks all Create/Update/Delete operations
-- for auditing and recent activity feed
-- =============================================
CREATE TABLE AuditLogs
(
    AuditId         INT             IDENTITY(1,1)   NOT NULL,
    TableName       NVARCHAR(50)    NOT NULL,
    RecordId        INT             NOT NULL,
    Action          NVARCHAR(20)    NOT NULL,  -- INSERT, UPDATE, DELETE
    Description     NVARCHAR(500)   NULL,
    PerformedBy     NVARCHAR(50)    NULL,
    PerformedDate   DATETIME        NOT NULL    DEFAULT(GETDATE()),

    CONSTRAINT PK_AuditLogs PRIMARY KEY CLUSTERED (AuditId ASC)
);
GO

-- =============================================
-- INDEXES
-- =============================================
CREATE NONCLUSTERED INDEX IX_Employees_DepartmentId ON Employees(DepartmentId);
CREATE NONCLUSTERED INDEX IX_Employees_DesignationId ON Employees(DesignationId);
CREATE NONCLUSTERED INDEX IX_Employees_IsActive ON Employees(IsActive);
CREATE NONCLUSTERED INDEX IX_Employees_JoiningDate ON Employees(JoiningDate);
CREATE NONCLUSTERED INDEX IX_Employees_Email ON Employees(Email);
CREATE NONCLUSTERED INDEX IX_Employees_Mobile ON Employees(Mobile);
CREATE NONCLUSTERED INDEX IX_Designations_DepartmentId ON Designations(DepartmentId);
CREATE NONCLUSTERED INDEX IX_AuditLogs_PerformedDate ON AuditLogs(PerformedDate DESC);
GO

-- =============================================
-- STORED PROCEDURE: usp_UserLogin
-- Validates user credentials for login
-- =============================================
CREATE PROCEDURE usp_UserLogin
    @Username       NVARCHAR(50),
    @PasswordHash   NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            UserId, Username, FullName, Email, Role, IsActive
        FROM Users
        WHERE Username = @Username
          AND PasswordHash = @PasswordHash
          AND IsActive = 1;

        -- Update last login date if user found
        IF @@ROWCOUNT > 0
        BEGIN
            UPDATE Users
            SET LastLoginDate = GETDATE()
            WHERE Username = @Username;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GetDashboardStats
-- Returns counts for dashboard KPI cards
-- =============================================
CREATE PROCEDURE usp_GetDashboardStats
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            (SELECT COUNT(*) FROM Employees)                                    AS TotalEmployees,
            (SELECT COUNT(*) FROM Employees WHERE Gender = 'Male')              AS MaleEmployees,
            (SELECT COUNT(*) FROM Employees WHERE Gender = 'Female')            AS FemaleEmployees,
            (SELECT COUNT(*) FROM Departments WHERE IsActive = 1)               AS TotalDepartments,
            (SELECT COUNT(*) FROM Employees WHERE IsActive = 1)                 AS ActiveEmployees,
            (SELECT COUNT(*) FROM Employees WHERE IsActive = 0)                 AS InactiveEmployees,
            (SELECT COUNT(*) FROM Employees WHERE CAST(JoiningDate AS DATE) = CAST(GETDATE() AS DATE)) AS TodayJoining;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GetLatestEmployees
-- Returns 5 most recently added employees
-- =============================================
CREATE PROCEDURE usp_GetLatestEmployees
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT TOP 5
            e.EmployeeId, e.EmployeeCode,
            e.FirstName + ' ' + e.LastName AS FullName,
            e.Email, e.Mobile,
            d.DepartmentName,
            des.DesignationName,
            e.JoiningDate, e.IsActive, e.Photo
        FROM Employees e
        INNER JOIN Departments d ON e.DepartmentId = d.DepartmentId
        INNER JOIN Designations des ON e.DesignationId = des.DesignationId
        ORDER BY e.CreatedDate DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GetRecentActivities
-- Returns 10 latest audit log entries
-- =============================================
CREATE PROCEDURE usp_GetRecentActivities
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT TOP 10
            AuditId, TableName, Action, Description,
            PerformedBy, PerformedDate
        FROM AuditLogs
        ORDER BY PerformedDate DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_InsertDepartment
-- =============================================
CREATE PROCEDURE usp_InsertDepartment
    @DepartmentName NVARCHAR(100),
    @Description    NVARCHAR(500),
    @IsActive       BIT,
    @PerformedBy    NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check for duplicate name
        IF EXISTS (SELECT 1 FROM Departments WHERE DepartmentName = @DepartmentName)
        BEGIN
            SELECT -1 AS Result, 'Department name already exists.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO Departments (DepartmentName, Description, IsActive, CreatedDate)
        VALUES (@DepartmentName, @Description, @IsActive, GETDATE());

        DECLARE @NewId INT = SCOPE_IDENTITY();

        INSERT INTO AuditLogs (TableName, RecordId, Action, Description, PerformedBy)
        VALUES ('Departments', @NewId, 'INSERT',
                'Added department: ' + @DepartmentName, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @NewId AS Result, 'Department added successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_UpdateDepartment
-- =============================================
CREATE PROCEDURE usp_UpdateDepartment
    @DepartmentId   INT,
    @DepartmentName NVARCHAR(100),
    @Description    NVARCHAR(500),
    @IsActive       BIT,
    @PerformedBy    NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM Departments WHERE DepartmentName = @DepartmentName AND DepartmentId <> @DepartmentId)
        BEGIN
            SELECT -1 AS Result, 'Department name already exists.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE Departments
        SET DepartmentName = @DepartmentName,
            Description    = @Description,
            IsActive       = @IsActive,
            UpdatedDate    = GETDATE()
        WHERE DepartmentId = @DepartmentId;

        INSERT INTO AuditLogs (TableName, RecordId, Action, Description, PerformedBy)
        VALUES ('Departments', @DepartmentId, 'UPDATE',
                'Updated department: ' + @DepartmentName, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @DepartmentId AS Result, 'Department updated successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_DeleteDepartment
-- =============================================
CREATE PROCEDURE usp_DeleteDepartment
    @DepartmentId   INT,
    @PerformedBy    NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Prevent delete if employees exist in this department
        IF EXISTS (SELECT 1 FROM Employees WHERE DepartmentId = @DepartmentId)
        BEGIN
            SELECT -1 AS Result, 'Cannot delete department. Employees are assigned to it.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @DeptName NVARCHAR(100);
        SELECT @DeptName = DepartmentName FROM Departments WHERE DepartmentId = @DepartmentId;

        DELETE FROM Departments WHERE DepartmentId = @DepartmentId;

        INSERT INTO AuditLogs (TableName, RecordId, Action, Description, PerformedBy)
        VALUES ('Departments', @DepartmentId, 'DELETE',
                'Deleted department: ' + ISNULL(@DeptName, ''), @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @DepartmentId AS Result, 'Department deleted successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GetAllDepartments
-- =============================================
CREATE PROCEDURE usp_GetAllDepartments
    @SearchTerm NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            d.DepartmentId,
            d.DepartmentName,
            d.Description,
            d.IsActive,
            d.CreatedDate,
            d.UpdatedDate,
            (SELECT COUNT(*) FROM Employees e WHERE e.DepartmentId = d.DepartmentId) AS EmployeeCount
        FROM Departments d
        WHERE (@SearchTerm IS NULL
               OR d.DepartmentName LIKE '%' + @SearchTerm + '%'
               OR d.Description LIKE '%' + @SearchTerm + '%')
        ORDER BY d.DepartmentName ASC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GetDepartmentById
-- =============================================
CREATE PROCEDURE usp_GetDepartmentById
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DepartmentId, DepartmentName, Description, IsActive, CreatedDate, UpdatedDate
    FROM Departments
    WHERE DepartmentId = @DepartmentId;
END
GO

-- =============================================
-- STORED PROCEDURE: usp_InsertDesignation
-- =============================================
CREATE PROCEDURE usp_InsertDesignation
    @DesignationName    NVARCHAR(100),
    @DepartmentId       INT,
    @Description        NVARCHAR(500),
    @IsActive           BIT,
    @PerformedBy        NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM Designations WHERE DesignationName = @DesignationName AND DepartmentId = @DepartmentId)
        BEGIN
            SELECT -1 AS Result, 'Designation already exists for this department.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO Designations (DesignationName, DepartmentId, Description, IsActive, CreatedDate)
        VALUES (@DesignationName, @DepartmentId, @Description, @IsActive, GETDATE());

        DECLARE @NewId INT = SCOPE_IDENTITY();

        INSERT INTO AuditLogs (TableName, RecordId, Action, Description, PerformedBy)
        VALUES ('Designations', @NewId, 'INSERT',
                'Added designation: ' + @DesignationName, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @NewId AS Result, 'Designation added successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_UpdateDesignation
-- =============================================
CREATE PROCEDURE usp_UpdateDesignation
    @DesignationId      INT,
    @DesignationName    NVARCHAR(100),
    @DepartmentId       INT,
    @Description        NVARCHAR(500),
    @IsActive           BIT,
    @PerformedBy        NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM Designations
                   WHERE DesignationName = @DesignationName
                     AND DepartmentId = @DepartmentId
                     AND DesignationId <> @DesignationId)
        BEGIN
            SELECT -1 AS Result, 'Designation already exists for this department.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE Designations
        SET DesignationName = @DesignationName,
            DepartmentId    = @DepartmentId,
            Description     = @Description,
            IsActive        = @IsActive,
            UpdatedDate     = GETDATE()
        WHERE DesignationId = @DesignationId;

        INSERT INTO AuditLogs (TableName, RecordId, Action, Description, PerformedBy)
        VALUES ('Designations', @DesignationId, 'UPDATE',
                'Updated designation: ' + @DesignationName, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @DesignationId AS Result, 'Designation updated successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_DeleteDesignation
-- =============================================
CREATE PROCEDURE usp_DeleteDesignation
    @DesignationId  INT,
    @PerformedBy    NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM Employees WHERE DesignationId = @DesignationId)
        BEGIN
            SELECT -1 AS Result, 'Cannot delete designation. Employees are assigned to it.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @DesigName NVARCHAR(100);
        SELECT @DesigName = DesignationName FROM Designations WHERE DesignationId = @DesignationId;

        DELETE FROM Designations WHERE DesignationId = @DesignationId;

        INSERT INTO AuditLogs (TableName, RecordId, Action, Description, PerformedBy)
        VALUES ('Designations', @DesignationId, 'DELETE',
                'Deleted designation: ' + ISNULL(@DesigName, ''), @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @DesignationId AS Result, 'Designation deleted successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GetAllDesignations
-- =============================================
CREATE PROCEDURE usp_GetAllDesignations
    @SearchTerm     NVARCHAR(100) = NULL,
    @DepartmentId   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            des.DesignationId,
            des.DesignationName,
            des.DepartmentId,
            d.DepartmentName,
            des.Description,
            des.IsActive,
            des.CreatedDate,
            des.UpdatedDate
        FROM Designations des
        INNER JOIN Departments d ON des.DepartmentId = d.DepartmentId
        WHERE (@SearchTerm IS NULL
               OR des.DesignationName LIKE '%' + @SearchTerm + '%')
          AND (@DepartmentId IS NULL OR des.DepartmentId = @DepartmentId)
        ORDER BY d.DepartmentName, des.DesignationName ASC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GetDesignationById
-- =============================================
CREATE PROCEDURE usp_GetDesignationById
    @DesignationId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT des.DesignationId, des.DesignationName, des.DepartmentId,
           d.DepartmentName, des.Description, des.IsActive,
           des.CreatedDate, des.UpdatedDate
    FROM Designations des
    INNER JOIN Departments d ON des.DepartmentId = d.DepartmentId
    WHERE des.DesignationId = @DesignationId;
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GetDesignationsByDept
-- Returns designations for a given department
-- =============================================
CREATE PROCEDURE usp_GetDesignationsByDept
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DesignationId, DesignationName
    FROM Designations
    WHERE DepartmentId = @DepartmentId AND IsActive = 1
    ORDER BY DesignationName ASC;
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GenerateEmployeeCode
-- Auto-generates a unique employee code e.g. EMP-00001
-- =============================================
CREATE PROCEDURE usp_GenerateEmployeeCode
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MaxCode INT;
    SELECT @MaxCode = ISNULL(MAX(CAST(SUBSTRING(EmployeeCode, 5, LEN(EmployeeCode)) AS INT)), 0)
    FROM Employees
    WHERE EmployeeCode LIKE 'EMP-%';

    SELECT 'EMP-' + RIGHT('00000' + CAST(@MaxCode + 1 AS VARCHAR), 5) AS EmployeeCode;
END
GO

-- =============================================
-- STORED PROCEDURE: usp_InsertEmployee
-- =============================================
CREATE PROCEDURE usp_InsertEmployee
    @EmployeeCode   NVARCHAR(20),
    @FirstName      NVARCHAR(50),
    @LastName       NVARCHAR(50),
    @Gender         NVARCHAR(10),
    @DateOfBirth    DATE,
    @Email          NVARCHAR(100),
    @Mobile         NVARCHAR(15),
    @DepartmentId   INT,
    @DesignationId  INT,
    @Salary         DECIMAL(18,2),
    @JoiningDate    DATE,
    @Experience     INT,
    @Address        NVARCHAR(200),
    @City           NVARCHAR(50),
    @State          NVARCHAR(50),
    @Country        NVARCHAR(50),
    @ZipCode        NVARCHAR(10),
    @IsActive       BIT,
    @Photo          NVARCHAR(200),
    @PerformedBy    NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Duplicate email check
        IF EXISTS (SELECT 1 FROM Employees WHERE Email = @Email)
        BEGIN
            SELECT -1 AS Result, 'Email address already exists.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Duplicate mobile check
        IF EXISTS (SELECT 1 FROM Employees WHERE Mobile = @Mobile)
        BEGIN
            SELECT -2 AS Result, 'Mobile number already exists.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO Employees
        (
            EmployeeCode, FirstName, LastName, Gender, DateOfBirth,
            Email, Mobile, DepartmentId, DesignationId, Salary,
            JoiningDate, Experience, Address, City, State, Country,
            ZipCode, IsActive, Photo, CreatedDate
        )
        VALUES
        (
            @EmployeeCode, @FirstName, @LastName, @Gender, @DateOfBirth,
            @Email, @Mobile, @DepartmentId, @DesignationId, @Salary,
            @JoiningDate, @Experience, @Address, @City, @State, @Country,
            @ZipCode, @IsActive, @Photo, GETDATE()
        );

        DECLARE @NewId INT = SCOPE_IDENTITY();

        INSERT INTO AuditLogs (TableName, RecordId, Action, Description, PerformedBy)
        VALUES ('Employees', @NewId, 'INSERT',
                'Added employee: ' + @FirstName + ' ' + @LastName + ' (' + @EmployeeCode + ')',
                @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @NewId AS Result, 'Employee registered successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_UpdateEmployee
-- =============================================
CREATE PROCEDURE usp_UpdateEmployee
    @EmployeeId     INT,
    @FirstName      NVARCHAR(50),
    @LastName       NVARCHAR(50),
    @Gender         NVARCHAR(10),
    @DateOfBirth    DATE,
    @Email          NVARCHAR(100),
    @Mobile         NVARCHAR(15),
    @DepartmentId   INT,
    @DesignationId  INT,
    @Salary         DECIMAL(18,2),
    @JoiningDate    DATE,
    @Experience     INT,
    @Address        NVARCHAR(200),
    @City           NVARCHAR(50),
    @State          NVARCHAR(50),
    @Country        NVARCHAR(50),
    @ZipCode        NVARCHAR(10),
    @IsActive       BIT,
    @Photo          NVARCHAR(200),
    @PerformedBy    NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Duplicate email check (exclude current employee)
        IF EXISTS (SELECT 1 FROM Employees WHERE Email = @Email AND EmployeeId <> @EmployeeId)
        BEGIN
            SELECT -1 AS Result, 'Email address already in use by another employee.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Duplicate mobile check (exclude current employee)
        IF EXISTS (SELECT 1 FROM Employees WHERE Mobile = @Mobile AND EmployeeId <> @EmployeeId)
        BEGIN
            SELECT -2 AS Result, 'Mobile number already in use by another employee.' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE Employees
        SET
            FirstName       = @FirstName,
            LastName        = @LastName,
            Gender          = @Gender,
            DateOfBirth     = @DateOfBirth,
            Email           = @Email,
            Mobile          = @Mobile,
            DepartmentId    = @DepartmentId,
            DesignationId   = @DesignationId,
            Salary          = @Salary,
            JoiningDate     = @JoiningDate,
            Experience      = @Experience,
            Address         = @Address,
            City            = @City,
            State           = @State,
            Country         = @Country,
            ZipCode         = @ZipCode,
            IsActive        = @IsActive,
            Photo           = CASE WHEN @Photo IS NULL OR @Photo = '' THEN Photo ELSE @Photo END,
            UpdatedDate     = GETDATE()
        WHERE EmployeeId = @EmployeeId;

        INSERT INTO AuditLogs (TableName, RecordId, Action, Description, PerformedBy)
        VALUES ('Employees', @EmployeeId, 'UPDATE',
                'Updated employee: ' + @FirstName + ' ' + @LastName,
                @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @EmployeeId AS Result, 'Employee updated successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_DeleteEmployee
-- =============================================
CREATE PROCEDURE usp_DeleteEmployee
    @EmployeeId     INT,
    @PerformedBy    NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @EmpName NVARCHAR(101), @EmpCode NVARCHAR(20);
        SELECT @EmpName = FirstName + ' ' + LastName, @EmpCode = EmployeeCode
        FROM Employees WHERE EmployeeId = @EmployeeId;

        DELETE FROM Employees WHERE EmployeeId = @EmployeeId;

        INSERT INTO AuditLogs (TableName, RecordId, Action, Description, PerformedBy)
        VALUES ('Employees', @EmployeeId, 'DELETE',
                'Deleted employee: ' + ISNULL(@EmpName, '') + ' (' + ISNULL(@EmpCode, '') + ')',
                @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @EmployeeId AS Result, 'Employee deleted successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GetEmployeeById
-- =============================================
CREATE PROCEDURE usp_GetEmployeeById
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        e.EmployeeId, e.EmployeeCode, e.FirstName, e.LastName,
        e.FirstName + ' ' + e.LastName AS FullName,
        e.Gender, e.DateOfBirth, e.Email, e.Mobile,
        e.DepartmentId, d.DepartmentName,
        e.DesignationId, des.DesignationName,
        e.Salary, e.JoiningDate, e.Experience,
        e.Address, e.City, e.State, e.Country, e.ZipCode,
        e.IsActive, e.Photo, e.CreatedDate, e.UpdatedDate
    FROM Employees e
    INNER JOIN Departments d   ON e.DepartmentId   = d.DepartmentId
    INNER JOIN Designations des ON e.DesignationId = des.DesignationId
    WHERE e.EmployeeId = @EmployeeId;
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GetAllEmployees
-- Supports search, filter, sort, and pagination
-- =============================================
CREATE PROCEDURE usp_GetAllEmployees
    @SearchTerm     NVARCHAR(100)   = NULL,
    @DepartmentId   INT             = NULL,
    @DesignationId  INT             = NULL,
    @Gender         NVARCHAR(10)    = NULL,
    @IsActive       BIT             = NULL,
    @JoiningFrom    DATE            = NULL,
    @JoiningTo      DATE            = NULL,
    @SortColumn     NVARCHAR(50)    = 'CreatedDate',
    @SortOrder      NVARCHAR(4)     = 'DESC',
    @PageNumber     INT             = 1,
    @PageSize       INT             = 10,
    @TotalRecords   INT             OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Get total records for pagination
        SELECT @TotalRecords = COUNT(*)
        FROM Employees e
        INNER JOIN Departments d   ON e.DepartmentId   = d.DepartmentId
        INNER JOIN Designations des ON e.DesignationId = des.DesignationId
        WHERE
            (@SearchTerm IS NULL OR
             e.FirstName  LIKE '%' + @SearchTerm + '%' OR
             e.LastName   LIKE '%' + @SearchTerm + '%' OR
             e.Email      LIKE '%' + @SearchTerm + '%' OR
             e.Mobile     LIKE '%' + @SearchTerm + '%' OR
             e.EmployeeCode LIKE '%' + @SearchTerm + '%' OR
             d.DepartmentName LIKE '%' + @SearchTerm + '%' OR
             des.DesignationName LIKE '%' + @SearchTerm + '%')
          AND (@DepartmentId  IS NULL OR e.DepartmentId  = @DepartmentId)
          AND (@DesignationId IS NULL OR e.DesignationId = @DesignationId)
          AND (@Gender        IS NULL OR e.Gender        = @Gender)
          AND (@IsActive      IS NULL OR e.IsActive      = @IsActive)
          AND (@JoiningFrom   IS NULL OR e.JoiningDate   >= @JoiningFrom)
          AND (@JoiningTo     IS NULL OR e.JoiningDate   <= @JoiningTo);

        -- Paged result set with dynamic sort
        SELECT
            e.EmployeeId, e.EmployeeCode,
            e.FirstName, e.LastName,
            e.FirstName + ' ' + e.LastName AS FullName,
            e.Gender, e.DateOfBirth, e.Email, e.Mobile,
            e.DepartmentId, d.DepartmentName,
            e.DesignationId, des.DesignationName,
            e.Salary, e.JoiningDate, e.Experience,
            e.City, e.State, e.Country,
            e.IsActive, e.Photo, e.CreatedDate
        FROM Employees e
        INNER JOIN Departments d   ON e.DepartmentId   = d.DepartmentId
        INNER JOIN Designations des ON e.DesignationId = des.DesignationId
        WHERE
            (@SearchTerm IS NULL OR
             e.FirstName  LIKE '%' + @SearchTerm + '%' OR
             e.LastName   LIKE '%' + @SearchTerm + '%' OR
             e.Email      LIKE '%' + @SearchTerm + '%' OR
             e.Mobile     LIKE '%' + @SearchTerm + '%' OR
             e.EmployeeCode LIKE '%' + @SearchTerm + '%' OR
             d.DepartmentName LIKE '%' + @SearchTerm + '%' OR
             des.DesignationName LIKE '%' + @SearchTerm + '%')
          AND (@DepartmentId  IS NULL OR e.DepartmentId  = @DepartmentId)
          AND (@DesignationId IS NULL OR e.DesignationId = @DesignationId)
          AND (@Gender        IS NULL OR e.Gender        = @Gender)
          AND (@IsActive      IS NULL OR e.IsActive      = @IsActive)
          AND (@JoiningFrom   IS NULL OR e.JoiningDate   >= @JoiningFrom)
          AND (@JoiningTo     IS NULL OR e.JoiningDate   <= @JoiningTo)
        ORDER BY
            CASE WHEN @SortColumn = 'FullName'        AND @SortOrder = 'ASC'  THEN e.FirstName + ' ' + e.LastName END ASC,
            CASE WHEN @SortColumn = 'FullName'        AND @SortOrder = 'DESC' THEN e.FirstName + ' ' + e.LastName END DESC,
            CASE WHEN @SortColumn = 'EmployeeCode'    AND @SortOrder = 'ASC'  THEN e.EmployeeCode    END ASC,
            CASE WHEN @SortColumn = 'EmployeeCode'    AND @SortOrder = 'DESC' THEN e.EmployeeCode    END DESC,
            CASE WHEN @SortColumn = 'DepartmentName'  AND @SortOrder = 'ASC'  THEN d.DepartmentName  END ASC,
            CASE WHEN @SortColumn = 'DepartmentName'  AND @SortOrder = 'DESC' THEN d.DepartmentName  END DESC,
            CASE WHEN @SortColumn = 'Salary'          AND @SortOrder = 'ASC'  THEN e.Salary          END ASC,
            CASE WHEN @SortColumn = 'Salary'          AND @SortOrder = 'DESC' THEN e.Salary          END DESC,
            CASE WHEN @SortColumn = 'JoiningDate'     AND @SortOrder = 'ASC'  THEN e.JoiningDate     END ASC,
            CASE WHEN @SortColumn = 'JoiningDate'     AND @SortOrder = 'DESC' THEN e.JoiningDate     END DESC,
            CASE WHEN @SortColumn = 'CreatedDate'     AND @SortOrder = 'ASC'  THEN e.CreatedDate     END ASC,
            CASE WHEN @SortColumn = 'CreatedDate'     AND @SortOrder = 'DESC' THEN e.CreatedDate     END DESC
        OFFSET ((@PageNumber - 1) * @PageSize) ROWS
        FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURE: usp_CheckDuplicateEmail
-- =============================================
CREATE PROCEDURE usp_CheckDuplicateEmail
    @Email      NVARCHAR(100),
    @EmployeeId INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Employees WHERE Email = @Email AND EmployeeId <> @EmployeeId)
        SELECT 1 AS IsDuplicate;
    ELSE
        SELECT 0 AS IsDuplicate;
END
GO

-- =============================================
-- STORED PROCEDURE: usp_CheckDuplicateMobile
-- =============================================
CREATE PROCEDURE usp_CheckDuplicateMobile
    @Mobile     NVARCHAR(15),
    @EmployeeId INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Employees WHERE Mobile = @Mobile AND EmployeeId <> @EmployeeId)
        SELECT 1 AS IsDuplicate;
    ELSE
        SELECT 0 AS IsDuplicate;
END
GO

-- =============================================
-- STORED PROCEDURE: usp_GetSalaryReport
-- =============================================
CREATE PROCEDURE usp_GetSalaryReport
    @DepartmentId   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        d.DepartmentName,
        des.DesignationName,
        COUNT(e.EmployeeId)     AS EmployeeCount,
        MIN(e.Salary)           AS MinSalary,
        MAX(e.Salary)           AS MaxSalary,
        AVG(e.Salary)           AS AvgSalary,
        SUM(e.Salary)           AS TotalSalary
    FROM Employees e
    INNER JOIN Departments d    ON e.DepartmentId   = d.DepartmentId
    INNER JOIN Designations des ON e.DesignationId  = des.DesignationId
    WHERE e.IsActive = 1
      AND (@DepartmentId IS NULL OR e.DepartmentId = @DepartmentId)
    GROUP BY d.DepartmentName, des.DesignationName
    ORDER BY d.DepartmentName, des.DesignationName;
END
GO

-- =============================================
-- STORED PROCEDURE: usp_UpdateEmployeeStatus
-- =============================================
CREATE PROCEDURE usp_UpdateEmployeeStatus
    @EmployeeId     INT,
    @IsActive       BIT,
    @PerformedBy    NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Employees SET IsActive = @IsActive, UpdatedDate = GETDATE()
        WHERE EmployeeId = @EmployeeId;

        DECLARE @Status NVARCHAR(10) = CASE WHEN @IsActive = 1 THEN 'Activated' ELSE 'Deactivated' END;

        INSERT INTO AuditLogs (TableName, RecordId, Action, Description, PerformedBy)
        VALUES ('Employees', @EmployeeId, 'UPDATE',
                'Status changed to ' + @Status + ' for EmployeeId: ' + CAST(@EmployeeId AS VARCHAR),
                @PerformedBy);

        COMMIT TRANSACTION;
        SELECT 1 AS Result, 'Status updated successfully.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =============================================
-- SAMPLE DATA: Insert Departments
-- =============================================
INSERT INTO Departments (DepartmentName, Description, IsActive)
VALUES
    ('Information Technology', 'Handles all IT infrastructure and software development.', 1),
    ('Human Resources', 'Manages employee relations and recruitment.', 1),
    ('Finance', 'Manages financial records and accounting.', 1),
    ('Marketing', 'Handles marketing and brand management.', 1),
    ('Operations', 'Manages day-to-day operational activities.', 1),
    ('Sales', 'Drives revenue through sales activities.', 1),
    ('Administration', 'Handles administrative and support functions.', 1);
GO

-- =============================================
-- SAMPLE DATA: Insert Designations
-- =============================================
INSERT INTO Designations (DesignationName, DepartmentId, Description, IsActive)
VALUES
    ('Software Engineer',       1, 'Develops and maintains software applications.', 1),
    ('Senior Software Engineer',1, 'Senior-level software developer.', 1),
    ('Team Lead',               1, 'Leads the development team.', 1),
    ('Project Manager',         1, 'Manages software projects.', 1),
    ('HR Executive',            2, 'Handles HR activities.', 1),
    ('HR Manager',              2, 'Manages the HR department.', 1),
    ('Financial Analyst',       3, 'Analyzes financial data.', 1),
    ('Accountant',              3, 'Manages accounts and bookkeeping.', 1),
    ('Marketing Executive',     4, 'Executes marketing campaigns.', 1),
    ('Marketing Manager',       4, 'Manages marketing strategy.', 1),
    ('Operations Executive',    5, 'Manages operations tasks.', 1),
    ('Sales Executive',         6, 'Drives sales activities.', 1),
    ('Sales Manager',           6, 'Manages the sales team.', 1),
    ('Admin Executive',         7, 'Handles administrative tasks.', 1);
GO

-- =============================================
-- SAMPLE DATA: Insert Admin User
-- Password: Admin@123 (SHA-256 hash stored)
-- In production use a proper hashing library
-- Hash of "Admin@123" for demo purposes only
-- =============================================
INSERT INTO Users (Username, PasswordHash, FullName, Email, Role, IsActive)
VALUES
    ('admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'System Administrator', 'admin@company.com', 'Admin', 1),
    ('hrmanager', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'HR Manager', 'hr@company.com', 'HR', 1);
GO

-- =============================================
-- SAMPLE DATA: Insert Employees
-- =============================================
INSERT INTO Employees
(EmployeeCode, FirstName, LastName, Gender, DateOfBirth, Email, Mobile,
 DepartmentId, DesignationId, Salary, JoiningDate, Experience,
 Address, City, State, Country, ZipCode, IsActive)
VALUES
('EMP-00001','Arjun','Sharma','Male','1990-05-15','arjun.sharma@company.com','9876543210',1,2,75000,'2020-01-15',5,'123 MG Road','Bangalore','Karnataka','India','560001',1),
('EMP-00002','Priya','Patel','Female','1993-08-22','priya.patel@company.com','9876543211',2,5,45000,'2021-03-01',3,'45 Park Street','Mumbai','Maharashtra','India','400001',1),
('EMP-00003','Rahul','Kumar','Male','1988-11-30','rahul.kumar@company.com','9876543212',3,7,65000,'2019-06-10',7,'78 Civil Lines','Delhi','Delhi','India','110001',1),
('EMP-00004','Sneha','Reddy','Female','1995-02-14','sneha.reddy@company.com','9876543213',4,9,40000,'2022-07-20',2,'22 Banjara Hills','Hyderabad','Telangana','India','500034',1),
('EMP-00005','Vikram','Singh','Male','1987-09-05','vikram.singh@company.com','9876543214',1,3,95000,'2018-04-01',9,'67 Sector 15','Noida','Uttar Pradesh','India','201301',1),
('EMP-00006','Anjali','Nair','Female','1992-12-25','anjali.nair@company.com','9876543215',5,11,38000,'2021-11-15',4,'12 Marine Drive','Kochi','Kerala','India','682001',1),
('EMP-00007','Suresh','Iyer','Male','1985-07-17','suresh.iyer@company.com','9876543216',6,12,52000,'2017-09-01',11,'34 Anna Salai','Chennai','Tamil Nadu','India','600002',1),
('EMP-00008','Meera','Joshi','Female','1994-04-10','meera.joshi@company.com','9876543217',2,6,60000,'2020-08-20',5,'89 Relief Road','Ahmedabad','Gujarat','India','380001',1),
('EMP-00009','Ravi','Tiwari','Male','1991-01-28','ravi.tiwari@company.com','9876543218',1,1,55000,'2022-01-10',3,'45 Hazratganj','Lucknow','Uttar Pradesh','India','226001',1),
('EMP-00010','Kavya','Menon','Female','1996-06-18','kavya.menon@company.com','9876543219',7,14,35000,'2023-02-01',1,'78 MG Road','Pune','Maharashtra','India','411001',0);
GO

-- =============================================
-- SAMPLE DATA: Insert Audit Logs
-- =============================================
INSERT INTO AuditLogs (TableName, RecordId, Action, Description, PerformedBy)
VALUES
    ('Employees', 1, 'INSERT', 'Added employee: Arjun Sharma (EMP-00001)', 'admin'),
    ('Employees', 2, 'INSERT', 'Added employee: Priya Patel (EMP-00002)', 'admin'),
    ('Employees', 3, 'INSERT', 'Added employee: Rahul Kumar (EMP-00003)', 'admin'),
    ('Departments', 1, 'INSERT', 'Added department: Information Technology', 'admin'),
    ('Employees', 5, 'UPDATE', 'Updated employee: Vikram Singh', 'admin'),
    ('Employees', 10, 'UPDATE', 'Status changed to Deactivated for EmployeeId: 10', 'admin');
GO

PRINT 'EmployeeDB database created successfully with all tables, stored procedures, and sample data.';
GO
