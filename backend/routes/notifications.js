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

// Get notifications for user
router.get('/user/:userId', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    // Check permissions (users can only see their own notifications)
    if (req.user.id !== userId && req.user.role !== 'admin') {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    const { page = 1, limit = 10, isRead, type } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT * FROM notifications WHERE user_id = ?';
    let countQuery = 'SELECT COUNT(*) as total FROM notifications WHERE user_id = ?';
    let values = [userId];

    // Add read status filter
    if (isRead !== undefined) {
      query += ' AND is_read = ?';
      countQuery += ' AND is_read = ?';
      values.push(isRead === 'true');
    }

    // Add type filter
    if (type) {
      query += ' AND type = ?';
      countQuery += ' AND type = ?';
      values.push(type);
    }

    // Add pagination
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    values.push(parseInt(limit), parseInt(offset));

    const notifications = await executeQuery(query, values);
    const countResult = await executeQuery(countQuery, values.slice(0, -2)); // Remove limit and offset
    const total = countResult[0].total;

    res.json({
      notifications,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    console.error('Get user notifications error:', error);
    res.status(500).json({
      error: 'Failed to get notifications',
      message: error.message
    });
  }
});

// Get all notifications (admin only)
router.get('/', authenticateToken, authorizeRoles('admin'), async (req, res) => {
  try {
    const { page = 1, limit = 10, userId, isRead, type, search } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT n.*, u.name as user_name, u.email as user_email FROM notifications n LEFT JOIN users u ON n.user_id = u.id WHERE 1=1';
    let countQuery = 'SELECT COUNT(*) as total FROM notifications WHERE 1=1';
    let values = [];

    // Add user filter
    if (userId) {
      query += ' AND user_id = ?';
      countQuery += ' AND user_id = ?';
      values.push(parseInt(userId));
    }

    // Add read status filter
    if (isRead !== undefined) {
      query += ' AND is_read = ?';
      countQuery += ' AND is_read = ?';
      values.push(isRead === 'true');
    }

    // Add type filter
    if (type) {
      query += ' AND type = ?';
      countQuery += ' AND type = ?';
      values.push(type);
    }

    // Add search filter
    if (search) {
      query += ' AND (title LIKE ? OR message LIKE ?)';
      countQuery += ' AND (title LIKE ? OR message LIKE ?)';
      const searchTerm = `%${search}%`;
      values.push(searchTerm, searchTerm);
    }

    // Add pagination
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    values.push(parseInt(limit), parseInt(offset));

    const notifications = await executeQuery(query, values);
    const countResult = await executeQuery(countQuery, values.slice(0, -2)); // Remove limit and offset
    const total = countResult[0].total;

    res.json({
      notifications,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    console.error('Get all notifications error:', error);
    res.status(500).json({
      error: 'Failed to get notifications',
      message: error.message
    });
  }
});

// Get notification by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const notificationId = parseInt(req.params.id);

    const notifications = await executeQuery(
      'SELECT * FROM notifications WHERE id = ?',
      [notificationId]
    );

    if (notifications.length === 0) {
      return res.status(404).json({
        error: 'Notification not found'
      });
    }

    const notification = notifications[0];

    // Check permissions (users can only see their own notifications)
    if (notification.user_id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    res.json(notification);

  } catch (error) {
    console.error('Get notification by ID error:', error);
    res.status(500).json({
      error: 'Failed to get notification',
      message: error.message
    });
  }
});

// Mark notification as read
router.put('/:id/read', authenticateToken, async (req, res) => {
  try {
    const notificationId = parseInt(req.params.id);

    // Check if notification exists
    const notifications = await executeQuery(
      'SELECT * FROM notifications WHERE id = ?',
      [notificationId]
    );

    if (notifications.length === 0) {
      return res.status(404).json({
        error: 'Notification not found'
      });
    }

    const notification = notifications[0];

    // Check permissions (users can only mark their own notifications)
    if (notification.user_id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    // Mark as read
    await executeQuery(
      'UPDATE notifications SET is_read = TRUE WHERE id = ?',
      [notificationId]
    );

    // Get updated notification
    const updatedNotifications = await executeQuery(
      'SELECT * FROM notifications WHERE id = ?',
      [notificationId]
    );

    res.json({
      message: 'Notification marked as read',
      notification: updatedNotifications[0]
    });

  } catch (error) {
    console.error('Mark notification as read error:', error);
    res.status(500).json({
      error: 'Failed to mark notification as read',
      message: error.message
    });
  }
});

// Send notification (admin or system)
router.post('/', authenticateToken, [
  body('userId').isInt().withMessage('User ID must be an integer'),
  body('title').trim().isLength({ min: 3 }).withMessage('Title must be at least 3 characters'),
  body('message').trim().isLength({ min: 5 }).withMessage('Message must be at least 5 characters'),
  body('type').isIn(['complaint', 'assignment', 'status_update', 'system'])
    .withMessage('Invalid notification type')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { userId, title, message, type, relatedId, relatedType } = req.body;

    // Check permissions (admin can send to any user, employees can send to customers they work with)
    if (req.user.role !== 'admin' && req.user.role !== 'employee') {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    // Verify user exists
    const users = await executeQuery(
      'SELECT id FROM users WHERE id = ?',
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    // Create notification
    const result = await executeQuery(
      `INSERT INTO notifications (user_id, title, message, type, is_read, related_id, related_type) 
       VALUES (?, ?, ?, ?, FALSE, ?, ?)`,
      [userId, title, message, type, relatedId || null, relatedType || null]
    );

    // Get the created notification
    const newNotifications = await executeQuery(
      'SELECT * FROM notifications WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({
      message: 'Notification sent successfully',
      notification: newNotifications[0]
    });

  } catch (error) {
    console.error('Send notification error:', error);
    res.status(500).json({
      error: 'Failed to send notification',
      message: error.message
    });
  }
});

// Mark all notifications as read for user
router.put('/user/:userId/read-all', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    // Check permissions (users can only mark their own notifications)
    if (req.user.id !== userId && req.user.role !== 'admin') {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    const result = await executeQuery(
      'UPDATE notifications SET is_read = TRUE WHERE user_id = ? AND is_read = FALSE',
      [userId]
    );

    res.json({
      message: 'All notifications marked as read',
      updatedCount: result.affectedRows
    });

  } catch (error) {
    console.error('Mark all notifications as read error:', error);
    res.status(500).json({
      error: 'Failed to mark notifications as read',
      message: error.message
    });
  }
});

// Delete notification
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const notificationId = parseInt(req.params.id);

    // Check if notification exists
    const notifications = await executeQuery(
      'SELECT * FROM notifications WHERE id = ?',
      [notificationId]
    );

    if (notifications.length === 0) {
      return res.status(404).json({
        error: 'Notification not found'
      });
    }

    const notification = notifications[0];

    // Check permissions (users can only delete their own notifications)
    if (notification.user_id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    const result = await executeQuery(
      'DELETE FROM notifications WHERE id = ?',
      [notificationId]
    );

    res.json({
      message: 'Notification deleted successfully'
    });

  } catch (error) {
    console.error('Delete notification error:', error);
    res.status(500).json({
      error: 'Failed to delete notification',
      message: error.message
    });
  }
});

// Get unread notification count
router.get('/user/:userId/unread-count', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    // Check permissions (users can only see their own count)
    if (req.user.id !== userId && req.user.role !== 'admin') {
      return res.status(403).json({
        error: 'Insufficient permissions'
      });
    }

    const countResult = await executeQuery(
      'SELECT COUNT(*) as unreadCount FROM notifications WHERE user_id = ? AND is_read = FALSE',
      [userId]
    );

    res.json({
      unreadCount: countResult[0].unreadCount
    });

  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({
      error: 'Failed to get unread count',
      message: error.message
    });
  }
});

module.exports = router;
