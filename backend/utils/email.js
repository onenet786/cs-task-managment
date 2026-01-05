const nodemailer = require('nodemailer');
require('dotenv').config();

// Create transporter
const createTransporter = () => {
  return nodemailer.createTransporter({
    host: process.env.EMAIL_HOST || 'smtp.gmail.com',
    port: process.env.EMAIL_PORT || 587,
    secure: false, // true for 465, false for other ports
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });
};

// Generate verification code
const generateVerificationCode = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// Send verification email
const sendVerificationEmail = async (email, verificationCode) => {
  try {
    const transporter = createTransporter();
    
    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@taskmanagement.com',
      to: email,
      subject: 'Email Verification - Task Management System',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #333; margin: 0;">Task Management System</h1>
            <p style="color: #666; margin: 10px 0 0 0;">Email Verification</p>
          </div>
          
          <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
            <h2 style="color: #333; margin: 0 0 15px 0;">Verify Your Email Address</h2>
            <p style="color: #666; line-height: 1.6;">Thank you for registering with our Task Management System. To complete your registration, please use the verification code below:</p>
            
            <div style="background-color: #fff; border: 2px dashed #007bff; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0;">
              <h3 style="color: #007bff; font-size: 24px; margin: 0; letter-spacing: 3px; font-weight: bold;">${verificationCode}</h3>
              <p style="color: #666; margin: 10px 0 0 0; font-size: 14px;">Enter this code to verify your email</p>
            </div>
            
            <p style="color: #666; line-height: 1.6; margin-bottom: 0;">
              This code will expire in 10 minutes. If you didn't request this verification, please ignore this email.
            </p>
          </div>
          
          <div style="text-align: center; padding: 20px 0; border-top: 1px solid #eee;">
            <p style="color: #999; font-size: 12px; margin: 0;">
              This is an automated message from Task Management System. Please do not reply to this email.
            </p>
            <p style="color: #999; font-size: 12px; margin: 5px 0 0 0;">
              © 2024 Task Management System. All rights reserved.
            </p>
          </div>
        </div>
      `
    };

    await transporter.sendMail(mailOptions);
    console.log(`Verification email sent to: ${email}`);
    
  } catch (error) {
    console.error('Error sending verification email:', error);
    throw error;
  }
};

// Send password reset email
const sendPasswordResetEmail = async (email, resetToken) => {
  try {
    const transporter = createTransporter();
    const resetLink = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;
    
    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@taskmanagement.com',
      to: email,
      subject: 'Password Reset - Task Management System',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #333; margin: 0;">Task Management System</h1>
            <p style="color: #666; margin: 10px 0 0 0;">Password Reset</p>
          </div>
          
          <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
            <h2 style="color: #333; margin: 0 0 15px 0;">Reset Your Password</h2>
            <p style="color: #666; line-height: 1.6;">We received a request to reset the password for your account. Click the button below to reset your password:</p>
            
            <div style="text-align: center; margin: 30px 0;">
              <a href="${resetLink}" style="background-color: #007bff; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; font-weight: bold;">Reset Password</a>
            </div>
            
            <div style="background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 5px; padding: 15px; margin: 20px 0;">
              <p style="color: #856404; margin: 0; font-size: 14px;">
                <strong>Security Note:</strong> This link will expire in 1 hour. If you didn't request this password reset, please ignore this email and your password will remain unchanged.
              </p>
            </div>
            
            <p style="color: #666; line-height: 1.6;">
              If the button above doesn't work, copy and paste this link into your browser:<br>
              <a href="${resetLink}" style="color: #007bff; word-break: break-all;">${resetLink}</a>
            </p>
          </div>
          
          <div style="text-align: center; padding: 20px 0; border-top: 1px solid #eee;">
            <p style="color: #999; font-size: 12px; margin: 0;">
              This is an automated message from Task Management System. Please do not reply to this email.
            </p>
            <p style="color: #999; font-size: 12px; margin: 5px 0 0 0;">
              © 2024 Task Management System. All rights reserved.
            </p>
          </div>
        </div>
      `
    };

    await transporter.sendMail(mailOptions);
    console.log(`Password reset email sent to: ${email}`);
    
  } catch (error) {
    console.error('Error sending password reset email:', error);
    throw error;
  }
};

// Send complaint notification email
const sendComplaintNotificationEmail = async (email, complaintTitle, status, assignedEmployee) => {
  try {
    const transporter = createTransporter();
    
    const statusMessages = {
      'assigned': `Your complaint "${complaintTitle}" has been assigned to ${assignedEmployee}.`,
      'in_progress': `Your complaint "${complaintTitle}" is now being processed.`,
      'resolved': `Your complaint "${complaintTitle}" has been resolved.`,
      'closed': `Your complaint "${complaintTitle}" has been closed.`
    };

    const statusColors = {
      'assigned': '#17a2b8',
      'in_progress': '#ffc107',
      'resolved': '#28a745',
      'closed': '#6c757d'
    };
    
    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@taskmanagement.com',
      to: email,
      subject: `Complaint Update: ${complaintTitle}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #333; margin: 0;">Task Management System</h1>
            <p style="color: #666; margin: 10px 0 0 0;">Complaint Status Update</p>
          </div>
          
          <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
            <h2 style="color: #333; margin: 0 0 15px 0;">Status Update Notification</h2>
            
            <div style="background-color: ${statusColors[status] || '#007bff'}; color: white; padding: 15px; border-radius: 5px; margin: 20px 0; text-align: center;">
              <h3 style="margin: 0; text-transform: uppercase; letter-spacing: 1px;">${status.replace('_', ' ')}</h3>
            </div>
            
            <p style="color: #666; line-height: 1.6; margin-bottom: 20px;">
              ${statusMessages[status] || 'Your complaint status has been updated.'}
            </p>
            
            <div style="background-color: #fff; border: 1px solid #ddd; border-radius: 5px; padding: 15px;">
              <p style="margin: 0; color: #333;"><strong>Complaint:</strong> ${complaintTitle}</p>
              <p style="margin: 10px 0 0 0; color: #666; font-size: 14px;">You can view the full details in your dashboard.</p>
            </div>
          </div>
          
          <div style="text-align: center; padding: 20px 0; border-top: 1px solid #eee;">
            <p style="color: #999; font-size: 12px; margin: 0;">
              This is an automated message from Task Management System. Please do not reply to this email.
            </p>
            <p style="color: #999; font-size: 12px; margin: 5px 0 0 0;">
              © 2024 Task Management System. All rights reserved.
            </p>
          </div>
        </div>
      `
    };

    await transporter.sendMail(mailOptions);
    console.log(`Complaint notification email sent to: ${email}`);
    
  } catch (error) {
    console.error('Error sending complaint notification email:', error);
    throw error;
  }
};

// Test email configuration
const testEmailConfig = async () => {
  try {
    const transporter = createTransporter();
    await transporter.verify();
    console.log('✅ Email configuration is valid');
    return true;
  } catch (error) {
    console.error('❌ Email configuration error:', error.message);
    return false;
  }
};

module.exports = {
  generateVerificationCode,
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendComplaintNotificationEmail,
  testEmailConfig
};
