const express = require('express');
const { body, validationResult } = require('express-validator');
const jwt = require('jsonwebtoken');
const { executeQuery } = require('../config/database');

const router = express.Router();

// Authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      error: 'Access token required'
    });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({
        error: 'Invalid or expired token'
      });
    }
    req.user = user;
    next();
  });
};

// Role-based authorization middleware
const authorizeRoles = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }
    next();
  };
};

// Create new complaint
router.post('/', authenticateToken, [
  body('title').trim().isLength({ min: 5 }).withMessage('Title must be at least 5 characters'),
  body('description').trim().isLength({ min: 10 }).withMessage('Description must be at least 10 characters'),
  body('category').isIn(['Technical Issue', 'Billing Problem', 'Service Request', 'Product Issue', 'General Inquiry', 'Feedback', 'Other'])
    .withMessage('Invalid category')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { title, description, category, imageUrl } = req.body;

    // Get user details
    const users = await executeQuery(
      'SELECT id, name, email FROM users WHERE id = ?',
      [req.user.id]
    );

    if (users.length === 0) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    const user = users[0];

    // Create complaint
    const result = await executeQuery(
      `INSERT INTO complaints (customer_id, customer_name, customer_email, title, description, category, status, image_url) 
       VALUES (?, ?, ?, ?, ?, ?, 'pending', ?)`,
      [user.id, user.name, user.email, title, description, category, imageUrl || null]
    );

    // Get the created complaint
    const complaints = await executeQuery(
      `SELECT * FROM complaints WHERE id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      message: 'Complaint created successfully',
      complaint: complaints[0]
    });

  } catch (error) {
    console.error('Create complaint error:', error);
    res.status(500).json({
      error: 'Failed to create complaint',
      message: error.message
    });
  }
});

// Get complaints for current user
router.get('/user/:userId', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    // Check permissions (users can only see their own complaints)
    if (req.user.id !== userId && req.user.role !== 'admin') {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    const { page = 1, limit = 10, status, category } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT * FROM complaints WHERE customer_id = ?';
    let countQuery = 'SELECT COUNT(*) as total FROM complaints WHERE customer_id = ?';
    let values = [userId];

    // Add status filter
    if (status) {
      query += ' AND status = ?';
      countQuery += ' AND status = ?';
      values.push(status);
    }

    // Add category filter
    if (category) {
      query += ' AND category = ?';
      countQuery += ' AND category = ?';
      values.push(category);
    }

    // Add pagination
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    values.push(parseInt(limit), parseInt(offset));

    const complaints = await executeQuery(query, values);
    const countResult = await executeQuery(countQuery, values.slice(0, -2)); // Remove limit and offset
    const total = countResult[0].total;

    res.json({
      complaints,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    console.error('Get user complaints error:', error);
    res.status(500).json({
      error: 'Failed to get complaints',
      message: error.message
    });
  }
});

// Get complaints assigned to employee
router.get('/assigned/:employeeId', authenticateToken, async (req, res) => {
  try {
    const employeeId = parseInt(req.params.employeeId);

    // Check permissions (employees can only see their own assignments)
    if (req.user.id !== employeeId && req.user.role !== 'admin') {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    const { page = 1, limit = 10, status } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT * FROM complaints WHERE assigned_employee_id = ?';
    let countQuery = 'SELECT COUNT(*) as total FROM complaints WHERE assigned_employee_id = ?';
    let values = [employeeId];

    // Add status filter
    if (status) {
      query += ' AND status = ?';
      countQuery += ' AND status = ?';
      values.push(status);
    }

    // Add pagination
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    values.push(parseInt(limit), parseInt(offset));

    const complaints = await executeQuery(query, values);
    const countResult = await executeQuery(countQuery, values.slice(0, -2)); // Remove limit and offset
    const total = countResult[0].total;

    res.json({
      complaints,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    console.error('Get assigned complaints error:', error);
    res.status(500).json({
      error: 'Failed to get assigned complaints',
      message: error.message
    });
  }
});

// Get all complaints (admin only)
router.get('/', authenticateToken, authorizeRoles('admin'), async (req, res) => {
  try {
    const { page = 1, limit = 10, status, category, search } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT * FROM complaints WHERE 1=1';
    let countQuery = 'SELECT COUNT(*) as total FROM complaints WHERE 1=1';
    let values = [];

    // Add status filter
    if (status) {
      query += ' AND status = ?';
      countQuery += ' AND status = ?';
      values.push(status);
    }

    // Add category filter
    if (category) {
      query += ' AND category = ?';
      countQuery += ' AND category = ?';
      values.push(category);
    }

    // Add search filter
    if (search) {
      query += ' AND (title LIKE ? OR description LIKE ? OR customer_name LIKE ?)';
      countQuery += ' AND (title LIKE ? OR description LIKE ? OR customer_name LIKE ?)';
      const searchTerm = `%${search}%`;
      values.push(searchTerm, searchTerm, searchTerm);
    }

    // Add pagination
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    values.push(parseInt(limit), parseInt(offset));

    const complaints = await executeQuery(query, values);
    const countResult = await executeQuery(countQuery, values.slice(0, -2)); // Remove limit and offset
    const total = countResult[0].total;

    res.json({
      complaints,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    console.error('Get all complaints error:', error);
    res.status(500).json({
      error: 'Failed to get complaints',
      message: error.message
    });
  }
});

// Get complaint by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const complaintId = parseInt(req.params.id);

    const complaints = await executeQuery(
      'SELECT * FROM complaints WHERE id = ?',
      [complaintId]
    );

    if (complaints.length === 0) {
      return res.status(404).json({
        error: 'Complaint not found'
      });
    }

    const complaint = complaints[0];

    // Check permissions
    const canView = 
      req.user.role === 'admin' ||
      complaint.customer_id === req.user.id ||
      complaint.assigned_employee_id === req.user.id;

    if (!canView) {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    res.json(complaint);

  } catch (error) {
    console.error('Get complaint by ID error:', error);
    res.status(500).json({
      error: 'Failed to get complaint',
      message: error.message
    });
  }
});

// Update complaint status
router.put('/:id', authenticateToken, [
  body('status').optional().isIn(['pending', 'assigned', 'in_progress', 'resolved', 'closed'])
    .withMessage('Invalid status'),
  body('resolutionNotes').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const complaintId = parseInt(req.params.id);
    const { status, resolutionNotes } = req.body;

    // Check if complaint exists
    const complaints = await executeQuery(
      'SELECT * FROM complaints WHERE id = ?',
      [complaintId]
    );

    if (complaints.length === 0) {
      return res.status(404).json({
        error: 'Complaint not found'
      });
    }

    const complaint = complaints[0];

    // Check permissions
    const canUpdate = 
      req.user.role === 'admin' ||
      complaint.assigned_employee_id === req.user.id;

    if (!canUpdate) {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    // Build update query dynamically
    const updates = [];
    const values = [];

    if (status) {
      updates.push('status = ?');
      values.push(status);
      
      // Set resolved_at when status is resolved
      if (status === 'resolved') {
        updates.push('resolved_at = CURRENT_TIMESTAMP');
      }
    }

    if (resolutionNotes) {
      updates.push('resolution_notes = ?');
      values.push(resolutionNotes);
    }

    if (updates.length === 0) {
      return res.status(400).json({
        error: 'No valid fields to update'
      });
    }

    values.push(complaintId);

    const updateQuery = `UPDATE complaints SET ${updates.join(', ')}, updated_at = CURRENT_TIMESTAMP WHERE id = ?`;
    
    await executeQuery(updateQuery, values);

    // Get updated complaint
    const updatedComplaints = await executeQuery(
      'SELECT * FROM complaints WHERE id = ?',
      [complaintId]
    );

    res.json({
      message: 'Complaint updated successfully',
      complaint: updatedComplaints[0]
    });

  } catch (error) {
    console.error('Update complaint error:', error);
    res.status(500).json({
      error: 'Failed to update complaint',
      message: error.message
    });
  }
});

// Assign complaint to employee
router.post('/:complaintId/assign', authenticateToken, authorizeRoles('admin'), [
  body('employeeId').isInt().withMessage('Employee ID must be an integer')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const complaintId = parseInt(req.params.complaintId);
    const { employeeId } = req.body;

    // Check if complaint exists
    const complaints = await executeQuery(
      'SELECT * FROM complaints WHERE id = ?',
      [complaintId]
    );

    if (complaints.length === 0) {
      return res.status(404).json({
        error: 'Complaint not found'
      });
    }

    // Check if employee exists and has employee role
    const employees = await executeQuery(
      'SELECT id, name, email FROM users WHERE id = ? AND role = "employee"',
      [employeeId]
    );

    if (employees.length === 0) {
      return res.status(404).json({
        error: 'Employee not found'
      });
    }

    const employee = employees[0];

    // Update complaint assignment
    await executeQuery(
      `UPDATE complaints 
       SET assigned_employee_id = ?, assigned_employee_name = ?, assigned_employee_email = ?, 
           status = 'assigned', updated_at = CURRENT_TIMESTAMP 
       WHERE id = ?`,
      [employee.id, employee.name, employee.email, complaintId]
    );

    // Get updated complaint
    const updatedComplaints = await executeQuery(
      'SELECT * FROM complaints WHERE id = ?',
      [complaintId]
    );

    res.json({
      message: 'Complaint assigned successfully',
      complaint: updatedComplaints[0]
    });

  } catch (error) {
    console.error('Assign complaint error:', error);
    res.status(500).json({
      error: 'Failed to assign complaint',
      message: error.message
    });
  }
});

// Delete complaint
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const complaintId = parseInt(req.params.id);

    // Check if complaint exists
    const complaints = await executeQuery(
      'SELECT * FROM complaints WHERE id = ?',
      [complaintId]
    );

    if (complaints.length === 0) {
      return res.status(404).json({
        error: 'Complaint not found'
      });
    }

    const complaint = complaints[0];

    // Check permissions (customers can delete their own, admins can delete any)
    if (complaint.customer_id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    const result = await executeQuery(
      'DELETE FROM complaints WHERE id = ?',
      [complaintId]
    );

    res.json({
      message: 'Complaint deleted successfully'
    });

  } catch (error) {
    console.error('Delete complaint error:', error);
    res.status(500).json({
      error: 'Failed to delete complaint',
      message: error.message
    });
  }
});

module.exports = router;
