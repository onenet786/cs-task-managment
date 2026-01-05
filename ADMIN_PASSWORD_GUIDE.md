# Admin Account Setup

## Quick Answer: Admin Password

**Email**: admin@taskmanagement.com  
**Password**: admin123

## How to Set Up the Admin Account

### Method 1: Using the Setup Script (Recommended)

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Make sure your database is running and configured:**
   - Update `.env` file with your MySQL credentials
   - Run the database schema: `mysql -u root -p < ../database_schema.sql`

3. **Run the admin setup script:**
   ```bash
   node setup_admin.js
   ```

4. **Login with:**
   - Email: admin@taskmanagement.com
   - Password: admin123

### Method 2: Manual Setup

If you prefer to create the admin account manually:

1. **Connect to your MySQL database:**
   ```bash
   mysql -u root -p task_management_db
   ```

2. **Create the admin user directly:**
   ```sql
   INSERT INTO users (name, email, phone, role, password, is_email_verified) 
   VALUES (
     'System Admin', 
     'admin@taskmanagement.com', 
     '+1234567890', 
     'admin', 
     '$2b$12$YourHashedPasswordHere', 
     TRUE
   );
   ```

## How to Generate a Password Hash

If you need to create your own password hash, you can use this Node.js script:

```javascript
const bcrypt = require('bcryptjs');

async function generateHash() {
  const password = 'admin123'; // Change this to your desired password
  const hash = await bcrypt.hash(password, 12);
  console.log('Password hash:', hash);
}

generateHash();
```

## Important Notes

1. **Change the default password** after first login for security
2. **Use a strong password** in production (at least 8 characters with mix of letters, numbers, symbols)
3. **The setup script handles password hashing automatically**
4. **Admin account has full system access** - keep credentials secure

## Troubleshooting

### "User already exists" Error
- The setup script will update the password if admin already exists
- This is normal behavior

### Database Connection Error
- Check your `.env` file has correct MySQL credentials
- Ensure MySQL server is running
- Verify database `task_management_db` exists

### Wrong Password Error
- Make sure you're using the exact email: admin@taskmanagement.com
- Check if password is exactly: admin123
- Try running the setup script again

## Security Best Practices

1. **Change default passwords** immediately
2. **Use environment variables** for sensitive data
3. **Enable SSL** for database connections in production
4. **Regular password updates** for admin accounts
5. **Use strong, unique passwords** for each account
