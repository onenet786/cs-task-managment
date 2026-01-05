const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { executeQuery } = require('../config/database');
const { generateVerificationCode, sendVerificationEmail } = require('../utils/email');

const router = express.Router();

// Validation middleware
const validateRegistration = [
  body('name').trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('phone').isMobilePhone().withMessage('Please provide a valid phone number'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('role').isIn(['admin', 'employee', 'customer']).withMessage('Invalid role')
];

const validateLogin = [
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('password').notEmpty().withMessage('Password is required')
];

// Helper function to generate JWT
const generateToken = (user) => {
  return jwt.sign(
    { 
      id: user.id, 
      email: user.email, 
      role: user.role 
    },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

// Helper function to sanitize user data
const sanitizeUser = (user) => {
  const { password, ...sanitized } = user;
  return sanitized;
};

// Register new user
router.post('/register', validateRegistration, async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { name, email, phone, password, role } = req.body;

    // Check if user already exists
    const existingUser = await executeQuery(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existingUser.length > 0) {
      return res.status(409).json({
        error: 'User with this email already exists'
      });
    }

    // Hash password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Generate verification code
    const verificationCode = generateVerificationCode();
    
    // Insert user into database
    const result = await executeQuery(
      'INSERT INTO users (name, email, phone, role, password, is_email_verified) VALUES (?, ?, ?, ?, ?, ?)',
      [name, email, phone, role, hashedPassword, false]
    );

    // Store verification code (you might want to store this in a separate table or cache)
    console.log(`Verification code for ${email}: ${verificationCode}`);

    // Send verification email (optional)
    try {
      await sendVerificationEmail(email, verificationCode);
    } catch (emailError) {
      console.log('Email sending failed:', emailError.message);
    }

    // Get the created user
    const newUser = await executeQuery(
      'SELECT id, name, email, phone, role, is_email_verified, created_at FROM users WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({
      message: 'User registered successfully',
      user: sanitizeUser(newUser[0]),
      verificationCode: verificationCode // Remove this in production
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      error: 'Failed to register user',
      message: error.message
    });
  }
});

// Login user
router.post('/login', validateLogin, async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { email, password } = req.body;

    // Find user by email
    const users = await executeQuery(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({
        error: 'Invalid email or password'
      });
    }

    const user = users[0];

    // Check password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        error: 'Invalid email or password'
      });
    }

    // Generate JWT token
    const token = generateToken(user);

    res.json({
      message: 'Login successful',
      token,
      user: sanitizeUser(user)
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      error: 'Failed to login',
      message: error.message
    });
  }
});

// Send verification code
router.post('/send-verification-code', [
  body('email').isEmail().withMessage('Please provide a valid email')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { email } = req.body;

    // Check if user exists
    const users = await executeQuery(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    // Generate and send verification code
    const verificationCode = generateVerificationCode();
    console.log(`Verification code for ${email}: ${verificationCode}`);

    try {
      await sendVerificationEmail(email, verificationCode);
    } catch (emailError) {
      console.log('Email sending failed:', emailError.message);
    }

    res.json({
      message: 'Verification code sent successfully',
      verificationCode: verificationCode // Remove this in production
    });

  } catch (error) {
    console.error('Send verification code error:', error);
    res.status(500).json({
      error: 'Failed to send verification code',
      message: error.message
    });
  }
});

// Verify email with code
router.post('/verify-email', [
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('code').isLength({ min: 6, max: 6 }).withMessage('Verification code must be 6 digits')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { email, code } = req.body;

    // In a real implementation, you would store and verify the code properly
    // For now, we'll just mark the email as verified
    const result = await executeQuery(
      'UPDATE users SET is_email_verified = TRUE WHERE email = ?',
      [email]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    res.json({
      message: 'Email verified successfully'
    });

  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).json({
      error: 'Failed to verify email',
      message: error.message
    });
  }
});

// Get current user (requires authentication)
router.get('/me', async (req, res) => {
  try {
    // Extract token from header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Access token required'
      });
    }

    const token = authHeader.substring(7);
    
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Get user from database
    const users = await executeQuery(
      'SELECT id, name, email, phone, role, is_email_verified, created_at, updated_at FROM users WHERE id = ?',
      [decoded.id]
    );

    if (users.length === 0) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    res.json(users[0]);

  } catch (error) {
    console.error('Get current user error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Invalid token'
      });
    }
    
    res.status(500).json({
      error: 'Failed to get user information',
      message: error.message
    });
  }
});

module.exports = router;
