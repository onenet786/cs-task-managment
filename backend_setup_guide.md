# Backend Setup Guide

## Overview
This is a complete Node.js/Express backend server for your Task Management System that connects to your MySQL database and provides all the API endpoints your Flutter app needs.

## Prerequisites

### 1. MySQL Database
- Ensure your MySQL database is running
- Database name: `task_management_db` (created from `database_schema.sql`)
- Make sure you have the database credentials ready

### 2. Node.js
- Node.js version 16 or higher
- npm package manager

## Installation Steps

### 1. Install Dependencies
Navigate to the backend directory and install packages:
```bash
cd backend
npm install
```

### 2. Configure Environment Variables
Edit the `.env` file with your actual values:

```env
# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_actual_mysql_password
DB_NAME=task_management_db
DB_PORT=3306

# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production

# Email Configuration (Optional - for email notifications)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password
EMAIL_FROM=noreply@taskmanagement.com

# CORS Configuration
CORS_ORIGIN=http://localhost:3000,http://localhost:5173,http://localhost:8080
```

### 3. Start the Server

#### Development Mode (with auto-restart):
```bash
npm run dev
```

#### Production Mode:
```bash
npm start
```

## API Endpoints

### Authentication Endpoints
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/send-verification-code` - Send email verification
- `POST /api/auth/verify-email` - Verify email with code
- `GET /api/auth/me` - Get current user (requires token)

### User Management Endpoints
- `GET /api/users/me` - Get current user profile
- `PUT /api/users/:id` - Update user profile
- `PUT /api/users/:id/password` - Change password
- `GET /api/users` - Get all users (admin only)
- `GET /api/users/:id` - Get user by ID
- `DELETE /api/users/:id` - Delete user (admin only)

### Complaint Management Endpoints
- `POST /api/complaints` - Create new complaint
- `GET /api/complaints/user/:userId` - Get user's complaints
- `GET /api/complaints/assigned/:employeeId` - Get assigned complaints
- `GET /api/complaints` - Get all complaints (admin only)
- `GET /api/complaints/:id` - Get complaint by ID
- `PUT /api/complaints/:id` - Update complaint status
- `POST /api/complaints/:complaintId/assign` - Assign complaint to employee
- `DELETE /api/complaints/:id` - Delete complaint

### Notification Endpoints
- `GET /api/notifications/user/:userId` - Get user notifications
- `GET /api/notifications` - Get all notifications (admin only)
- `GET /api/notifications/:id` - Get notification by ID
- `PUT /api/notifications/:id/read` - Mark notification as read
- `POST /api/notifications` - Send notification
- `PUT /api/notifications/user/:userId/read-all` - Mark all as read
- `DELETE /api/notifications/:id` - Delete notification
- `GET /api/notifications/user/:userId/unread-count` - Get unread count

### Report Endpoints
- `POST /api/reports` - Generate report (admin only)
- `GET /api/reports` - Get all reports (admin only)
- `GET /api/reports/dashboard` - Get dashboard statistics (admin only)

## Testing the API

### 1. Health Check
```bash
curl http://localhost:3000/health
```

### 2. Register a Test User
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "+1234567890",
    "password": "password123",
    "role": "customer"
  }'
```

### 3. Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 4. Use the Token
Copy the `token` from the login response and use it in subsequent requests:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  http://localhost:3000/api/users/me
```

## Database Schema

The backend expects these tables in your MySQL database:

### Users Table
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50) NOT NULL,
    role ENUM('admin', 'employee', 'customer') NOT NULL,
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Complaints Table
```sql
CREATE TABLE complaints (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category ENUM(...) NOT NULL,
    status ENUM(...) NOT NULL DEFAULT 'pending',
    assigned_employee_id INT NULL,
    assigned_employee_name VARCHAR(255) NULL,
    assigned_employee_email VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    resolution_notes TEXT NULL,
    image_url VARCHAR(500) NULL
);
```

### Notifications Table
```sql
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM(...) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    related_id VARCHAR(100) NULL,
    related_type VARCHAR(100) NULL
);
```

## Security Features

- **JWT Authentication**: All endpoints require valid tokens
- **Role-based Access**: Admin, Employee, Customer roles with different permissions
- **Password Hashing**: Uses bcrypt with salt rounds
- **Input Validation**: Uses express-validator for all inputs
- **CORS Configuration**: Configured for your Flutter app
- **SQL Injection Prevention**: Uses parameterized queries

## Email Features

The backend includes email functionality for:
- Email verification codes
- Password reset links
- Complaint status notifications

To enable emails, configure the email settings in `.env` file.

## Error Handling

All endpoints return consistent error responses:
```json
{
  "error": "Error message",
  "details": ["Validation errors if any"]
}
```

## Troubleshooting

### Database Connection Issues
1. Check MySQL is running
2. Verify database credentials in `.env`
3. Ensure database `task_management_db` exists
4. Check if tables are created from `database_schema.sql`

### Port Already in Use
```bash
# Kill process on port 3000
npx kill-port 3000
```

### JWT Token Issues
1. Ensure `JWT_SECRET` is set in `.env`
2. Check token hasn't expired
3. Verify Authorization header format: `Bearer <token>`

### Email Issues
1. For Gmail, use App Passwords (not regular password)
2. Enable 2-factor authentication for Gmail
3. Check email configuration in `.env`

## Production Deployment

### Environment Variables
- Change `NODE_ENV=production`
- Use a strong `JWT_SECRET`
- Configure proper database credentials
- Set up proper email credentials

### Security Considerations
- Use HTTPS in production
- Implement rate limiting
- Set up proper CORS origins
- Use environment-specific database

## Flutter Integration

Your Flutter app should connect to:
- **Base URL**: `http://localhost:3000/api`
- **Headers**: `Authorization: Bearer <token>`
- **Content-Type**: `application/json`

The API responses match your Flutter data models exactly!
