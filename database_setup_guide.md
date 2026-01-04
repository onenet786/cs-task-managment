# Database Setup Guide

## Quick Setup Steps

### 1. Install MySQL Server
Make sure you have MySQL server installed on your system.

### 2. Run the Database Script
```bash
mysql -u root -p < database_schema.sql
```

### 3. Configure Your Backend Connection
Update your backend server configuration with these database details:
- **Database Name**: `task_management_db`
- **Host**: `localhost`
- **Port**: `3306` (default)
- **Username**: `root` (or your MySQL username)
- **Password**: `your_password`

### 4. Database Connection String for Backend
```javascript
// Example for Node.js/Express
const dbConfig = {
  host: 'localhost',
  database: 'task_management_db',
  user: 'root',
  password: 'your_password',
  port: 3306
};
```

## Database Tables Created

### 1. **users** - User accounts
- Supports admin, employee, and customer roles
- Includes email verification status
- Password storage for authentication

### 2. **complaints** - Main complaint records
- Links customers to their complaints
- Tracks assignment to employees
- Manages complaint status and resolution

### 3. **notifications** - User notifications
- Different notification types
- Read/unread status tracking
- Links to related records

### 4. **complaint_comments** - Optional discussion feature
- Allows comments on complaints
- Tracks user interactions

## Sample Data Included
- 1 Admin user
- 2 Employee users  
- 2 Customer users

## Key Features
- ✅ Proper foreign key relationships
- ✅ Indexes for performance
- ✅ Timestamp tracking
- ✅ Status management
- ✅ Sample data for testing
- ✅ Stored procedures for common operations
- ✅ Views for simplified queries

## Next Steps
1. Run the SQL script
2. Update your backend database connection
3. Test the API endpoints
4. Verify Flutter app connects to your backend
