const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');
require('dotenv').config();

// Admin account details
const adminDetails = {
  name: 'System Admin',
  email: 'admin@taskmanagement.com',
  phone: '+1234567890',
  role: 'admin',
  password: 'admin123' // You can change this password
};

async function setupAdmin() {
  let connection;
  
  try {
    // Create database connection
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'task_management_db',
      port: process.env.DB_PORT || 3306
    });

    console.log('🔗 Connected to database');

    // Check if admin already exists
    const [existingUsers] = await connection.execute(
      'SELECT id FROM users WHERE email = ?',
      [adminDetails.email]
    );

    if (existingUsers.length > 0) {
      console.log('⚠️  Admin user already exists');
      
      // Update existing admin password
      const hashedPassword = await bcrypt.hash(adminDetails.password, 12);
      await connection.execute(
        'UPDATE users SET password = ?, is_email_verified = TRUE WHERE email = ?',
        [hashedPassword, adminDetails.email]
      );
      
      console.log('✅ Admin password updated successfully');
    } else {
      // Create new admin user
      const hashedPassword = await bcrypt.hash(adminDetails.password, 12);
      
      await connection.execute(
        'INSERT INTO users (name, email, phone, role, password, is_email_verified) VALUES (?, ?, ?, ?, ?, TRUE)',
        [adminDetails.name, adminDetails.email, adminDetails.phone, adminDetails.role, hashedPassword]
      );
      
      console.log('✅ Admin user created successfully');
    }

    console.log('\n🎉 Admin Account Details:');
    console.log(`📧 Email: ${adminDetails.email}`);
    console.log(`🔑 Password: ${adminDetails.password}`);
    console.log(`👤 Role: ${adminDetails.role}`);
    console.log('\n💡 You can now login with these credentials!');

  } catch (error) {
    console.error('❌ Error setting up admin:', error.message);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Database connection closed');
    }
  }
}

// Run the setup
setupAdmin();
