-- Create Database if not exists
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RaceDayDB')
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

-- Drop foreign key constraints first or drop child tables first to avoid Msg 3726
IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
GO

-- 1. Roles Table
CREATE TABLE dbo.Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);

-- 2. Users Table (FirstName and LastName instead of FullName)
CREATE TABLE dbo.Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    PhoneNumber NVARCHAR(20) NULL,
    RoleId INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId) ON DELETE CASCADE
);

-- 3. Events Table
CREATE TABLE dbo.Events (
    EventId INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Location NVARCHAR(200) NOT NULL,
    EventDate DATETIME NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserId) REFERENCES dbo.Users(UserId)
);

-- 4. Categories Table
CREATE TABLE dbo.Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    EventId INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    DistanceKm DECIMAL(5,2) NOT NULL CHECK (DistanceKm > 0),
    EntryFee DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (EntryFee >= 0),
    StartTime DATETIME NOT NULL,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId) REFERENCES dbo.Events(EventId) ON DELETE CASCADE
);

-- 5. Enrolments Table
CREATE TABLE dbo.Enrolments (
    EnrolmentId INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId INT NOT NULL,
    CategoryId INT NOT NULL,
    BibNumber NVARCHAR(20) NOT NULL UNIQUE,
    EnrolledAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (ParticipantId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT UQ_Participant_Category UNIQUE (ParticipantId, CategoryId)
);

-- 6. Results Table
CREATE TABLE dbo.Results (
    ResultId INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId INT NOT NULL UNIQUE,
    FinishTime TIME NULL,
    OverallRank INT NULL,
    CategoryRank INT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Finished' CHECK (Status IN ('Finished', 'DNF', 'DNS', 'Disqualified')),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId) REFERENCES dbo.Enrolments(EnrolmentId) ON DELETE CASCADE
);
GO

-- Seed Roles
INSERT INTO dbo.Roles (RoleName) VALUES ('Organiser'), ('Participant');

-- Seed Users (Explicitly using FirstName, LastName)
INSERT INTO dbo.Users (FirstName, LastName, Email, PasswordHash, PhoneNumber, RoleId) VALUES 
('Sipho', 'Ndlovu', 'sipho@eventmasters.co.za', 'AQAAAAEAACcQAAAAEHASH1...', '0821112233', 1),
('Sarah', 'Jenkins', 'sarah@runningclub.co.za', 'AQAAAAEAACcQAAAAEHASH2...', '0834445566', 1),
('David', 'Mokoena', 'david.m@gmail.com', 'AQAAAAEAACcQAAAAEHASH3...', '0717778899', 2),
('Lindiwe', 'Zulu', 'lindiwe.z@gmail.com', 'AQAAAAEAACcQAAAAEHASH4...', '0790001122', 2);

-- Seed Events
INSERT INTO dbo.Events (OrganiserId, Title, Description, Location, EventDate) VALUES 
(1, 'Soweto Marathon', 'The iconic Peoples Race through Soweto township.', 'Soweto, Johannesburg', '2026-11-01 06:00:00'),
(1, 'Two Oceans Marathon', 'The world most beautiful marathon along coastal scenery.', 'Cape Town', '2026-04-18 05:30:00'),
(2, '947 Ride Joburg', 'South Africas premier annual cycling challenge.', 'FNB Stadium, Johannesburg', '2026-11-15 05:00:00');

-- Seed Categories
INSERT INTO dbo.Categories (EventId, CategoryName, DistanceKm, EntryFee, StartTime) VALUES 
(1, 'Soweto 10km Express', 10.00, 180.00, '2026-11-01 07:00:00'),
(1, 'Soweto 21km Half Marathon', 21.10, 280.00, '2026-11-01 06:30:00'),
(1, 'Soweto 42km Marathon', 42.20, 380.00, '2026-11-01 06:00:00'),
(2, 'Two Oceans 21km Half', 21.10, 320.00, '2026-04-18 06:00:00'),
(2, 'Two Oceans 56km Ultra', 56.00, 550.00, '2026-04-18 05:30:00'),
(3, '947 Ride Joburg 97km', 97.00, 650.00, '2026-11-15 05:30:00');

-- Seed Enrolments
INSERT INTO dbo.Enrolments (ParticipantId, CategoryId, BibNumber) VALUES 
(3, 2, 'BIB-1001'),
(4, 2, 'BIB-1002'),
(3, 4, 'BIB-5001');

-- Seed Results
INSERT INTO dbo.Results (EnrolmentId, FinishTime, OverallRank, CategoryRank, Status) VALUES 
(1, '01:42:15', 14, 3, 'Finished'),
(2, '02:05:30', 88, 12, 'Finished');
GO