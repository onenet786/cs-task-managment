-- ==========================================
-- Task Management System MySQL Database Schema
-- ==========================================

-- Create Database
CREATE DATABASE IF NOT EXISTS task_management_db;
USE task_management_db;

-- ==========================================
-- USERS TABLE
-- ==========================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50) NOT NULL,
    role ENUM('admin', 'employee', 'customer') NOT NULL DEFAULT 'customer',
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    password VARCHAR(255) NOT NULL, -- For authentication
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- ==========================================
-- COMPLAINTS TABLE
-- ==========================================
CREATE TABLE complaints (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category ENUM('Technical Issue', 'Billing Problem', 'Service Request', 
                  'Product Issue', 'General Inquiry', 'Feedback', 'Other') NOT NULL,
    status ENUM('pending', 'assigned', 'in_progress', 'resolved', 'closed') 
           NOT NULL DEFAULT 'pending',
    assigned_employee_id INT NULL,
    assigned_employee_name VARCHAR(255) NULL,
    assigned_employee_email VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    resolution_notes TEXT NULL,
    image_url VARCHAR(500) NULL,
    
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_employee_id) REFERENCES users(id) ON DELETE SET NULL,
    
    INDEX idx_customer_id (customer_id),
    INDEX idx_assigned_employee_id (assigned_employee_id),
    INDEX idx_status (status),
    INDEX idx_category (category),
    INDEX idx_created_at (created_at)
);

-- ==========================================
-- NOTIFICATIONS TABLE
-- ==========================================
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('complaint', 'assignment', 'status_update', 'system') NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    related_id VARCHAR(100) NULL,
    related_type VARCHAR(100) NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
);

-- ==========================================
-- COMMENTS TABLE (Optional - for complaint discussions)
-- ==========================================
CREATE TABLE complaint_comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    user_id INT NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    INDEX idx_complaint_id (complaint_id),
    INDEX idx_user_id (user_id)
);

-- ==========================================
-- SAMPLE DATA
-- ==========================================

-- Insert sample admin user
INSERT INTO users (name, email, phone, role, is_email_verified, password) VALUES 
('System Admin', 'admin@taskmanagement.com', '+1234567890', 'admin', TRUE, '$2b$10$encrypted_password_hash');

-- Insert sample employees
INSERT INTO users (name, email, phone, role, is_email_verified, password) VALUES 
('John Smith', 'john.smith@taskmanagement.com', '+1234567891', 'employee', TRUE, '$2b$10$encrypted_password_hash'),
('Sarah Johnson', 'sarah.johnson@taskmanagement.com', '+1234567892', 'employee', TRUE, '$2b$10$encrypted_password_hash');

-- Insert sample customers
INSERT INTO users (name, email, phone, role, is_email_verified, password) VALUES 
('Alice Brown', 'alice.brown@email.com', '+1234567893', 'customer', TRUE, '$2b$10$encrypted_password_hash'),
('Bob Wilson', 'bob.wilson@email.com', '+1234567894', 'customer', TRUE, '$2b$10$encrypted_password_hash');

-- ==========================================
-- STORED PROCEDURES (Optional)
-- ==========================================

DELIMITER //

-- Procedure to get complaints by status
CREATE PROCEDURE GetComplaintsByStatus(IN complaint_status VARCHAR(50))
BEGIN
    SELECT c.*, u.name as customer_name, u.email as customer_email,
           eu.name as assigned_employee_name, eu.email as assigned_employee_email
    FROM complaints c
    LEFT JOIN users u ON c.customer_id = u.id
    LEFT JOIN users eu ON c.assigned_employee_id = eu.id
    WHERE c.status = complaint_status
    ORDER BY c.created_at DESC;
END//

-- Procedure to get employee performance statistics
CREATE PROCEDURE GetEmployeePerformance(IN employee_id INT)
BEGIN
    SELECT 
        COUNT(c.id) as total_assigned,
        COUNT(CASE WHEN c.status = 'resolved' THEN 1 END) as total_resolved,
        COUNT(CASE WHEN c.status = 'closed' THEN 1 END) as total_closed,
        AVG(CASE WHEN c.resolved_at IS NOT NULL 
                 THEN TIMESTAMPDIFF(HOUR, c.created_at, c.resolved_at) 
                 END) as avg_resolution_hours
    FROM complaints c
    WHERE c.assigned_employee_id = employee_id;
END//

DELIMITER ;

-- ==========================================
-- VIEWS (Optional)
-- ==========================================

-- View for complaint summary
CREATE VIEW complaint_summary AS
SELECT 
    c.id,
    c.title,
    c.category,
    c.status,
    c.created_at,
    c.resolved_at,
    u.name as customer_name,
    u.email as customer_email,
    eu.name as assigned_employee_name,
    CASE 
        WHEN c.resolved_at IS NOT NULL 
        THEN TIMESTAMPDIFF(HOUR, c.created_at, c.resolved_at)
        ELSE NULL 
    END as resolution_hours
FROM complaints c
LEFT JOIN users u ON c.customer_id = u.id
LEFT JOIN users eu ON c.assigned_employee_id = eu.id;

-- View for employee workload
CREATE VIEW employee_workload AS
SELECT 
    u.id,
    u.name,
    u.email,
    COUNT(c.id) as total_assigned,
    COUNT(CASE WHEN c.status = 'pending' THEN 1 END) as pending_complaints,
    COUNT(CASE WHEN c.status = 'in_progress' THEN 1 END) as in_progress_complaints,
    COUNT(CASE WHEN c.status = 'resolved' THEN 1 END) as resolved_complaints
FROM users u
LEFT JOIN complaints c ON u.id = c.assigned_employee_id
WHERE u.role = 'employee'
GROUP BY u.id, u.name, u.email;
