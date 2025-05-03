-- Tạo database
CREATE DATABASE IF NOT EXISTS MyNewDatabase;

-- Chuyển sang sử dụng database vừa tạo
USE MyNewDatabase;

-- Tạo bảng mới
CREATE TABLE IF NOT EXISTS Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),  -- ID tự động tăng
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Email NVARCHAR(255),
    DateOfBirth DATE
);

-- Thêm dữ liệu mẫu vào bảng Users
INSERT INTO Users (FirstName, LastName, Email, DateOfBirth)
VALUES
    ('John', 'Doe', 'john.doe@example.com', '1985-10-15'),
    ('Jane', 'Smith', 'jane.smith@example.com', '1990-05-23'),
    ('Emily', 'Jones', 'emily.jones@example.com', '1988-07-30'),
    ('Michael', 'Brown', 'michael.brown@example.com', '1982-12-05');

-- Kiểm tra dữ liệu đã thêm vào bảng
SELECT * FROM Users;
