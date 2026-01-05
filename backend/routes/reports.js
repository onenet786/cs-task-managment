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

// Generate report
router.post('/', authenticateToken, authorizeRoles('admin'), [
  body('reportType').isIn(['complaint_summary', 'employee_performance', 'category_analysis'])
    .withMessage('Invalid report type'),
  body('startDate').isISO8601().withMessage('Invalid start date format'),
  body('endDate').isISO8601().withMessage('Invalid end date format')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { reportType, startDate, endDate } = req.body;

    let reportData = {};

    if (reportType === 'complaint_summary') {
      reportData = await generateComplaintSummary(startDate, endDate);
    } else if (reportType === 'employee_performance') {
      reportData = await generateEmployeePerformance(startDate, endDate);
    } else if (reportType === 'category_analysis') {
      reportData = await generateCategoryAnalysis(startDate, endDate);
    }

    const report = {
      reportType,
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      ...reportData
    };

    res.status(201).json(report);

  } catch (error) {
    console.error('Generate report error:', error);
    res.status(500).json({
      error: 'Failed to generate report',
      message: error.message
    });
  }
});

// Get all reports (admin only)
router.get('/', authenticateToken, authorizeRoles('admin'), async (req, res) => {
  try {
    const { page = 1, limit = 10, reportType } = req.query;
    const offset = (page - 1) * limit;

    // For now, we'll generate reports on the fly
    // In a real implementation, you might want to store reports in a database
    
    res.json({
      reports: [], // Would contain stored reports
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: 0,
        pages: 0
      },
      message: 'Reports are generated on demand. Use POST /api/reports to generate a new report.'
    });

  } catch (error) {
    console.error('Get reports error:', error);
    res.status(500).json({
      error: 'Failed to get reports',
      message: error.message
    });
  }
});

// Helper function to generate complaint summary report
async function generateComplaintSummary(startDate, endDate) {
  // Get total complaints in date range
  const totalComplaints = await executeQuery(
    `SELECT COUNT(*) as total FROM complaints 
     WHERE created_at BETWEEN ? AND ?`,
    [startDate, endDate]
  );

  // Get complaints by status
  const complaintsByStatus = await executeQuery(
    `SELECT status, COUNT(*) as count FROM complaints 
     WHERE created_at BETWEEN ? AND ? 
     GROUP BY status`,
    [startDate, endDate]
  );

  // Get complaints by category
  const complaintsByCategory = await executeQuery(
    `SELECT category, COUNT(*) as count FROM complaints 
     WHERE created_at BETWEEN ? AND ? 
     GROUP BY category`,
    [startDate, endDate]
  );

  // Calculate average resolution time
  const avgResolutionTime = await executeQuery(
    `SELECT AVG(TIMESTAMPDIFF(HOUR, created_at, resolved_at)) as avgHours
     FROM complaints 
     WHERE created_at BETWEEN ? AND ? 
     AND resolved_at IS NOT NULL`,
    [startDate, endDate]
  );

  // Get top complaints (most recently resolved or highest priority)
  const topComplaints = await executeQuery(
    `SELECT id, title, category, status, created_at, resolved_at
     FROM complaints 
     WHERE created_at BETWEEN ? AND ? 
     ORDER BY created_at DESC 
     LIMIT 5`,
    [startDate, endDate]
  );

  // Get status counts
  const statusCounts = {};
  const statusOrder = ['pending', 'assigned', 'in_progress', 'resolved', 'closed'];
  statusOrder.forEach(status => {
    const found = complaintsByStatus.find(item => item.status === status);
    statusCounts[status] = found ? found.count : 0;
  });

  // Get category counts
  const categoryCounts = {};
  complaintsByCategory.forEach(item => {
    categoryCounts[item.category] = item.count;
  });

  return {
    totalComplaints: totalComplaints[0].total,
    pendingComplaints: statusCounts.pending,
    resolvedComplaints: statusCounts.resolved,
    closedComplaints: statusCounts.closed,
    averageResolutionTime: avgResolutionTime[0].avgHours || 0,
    complaintsByCategory: categoryCounts,
    complaintsByStatus: statusCounts,
    topComplaints: topComplaints
  };
}

// Helper function to generate employee performance report
async function generateEmployeePerformance(startDate, endDate) {
  // Get all employees
  const employees = await executeQuery(
    `SELECT id, name, email FROM users WHERE role = 'employee'`
  );

  const employeePerformance = [];

  for (const employee of employees) {
    // Get complaint statistics for this employee
    const stats = await executeQuery(
      `SELECT 
         COUNT(c.id) as totalAssigned,
         COUNT(CASE WHEN c.status = 'resolved' THEN 1 END) as totalResolved,
         COUNT(CASE WHEN c.status = 'closed' THEN 1 END) as totalClosed,
         AVG(CASE WHEN c.resolved_at IS NOT NULL 
              THEN TIMESTAMPDIFF(HOUR, c.created_at, c.resolved_at) 
              END) as avgResolutionHours
       FROM complaints c
       WHERE c.assigned_employee_id = ?
       AND c.created_at BETWEEN ? AND ?`,
      [employee.id, startDate, endDate]
    );

    const employeeStats = stats[0];
    
    // Calculate satisfaction rating (simplified calculation)
    let satisfactionRating = 0;
    if (employeeStats.totalAssigned > 0) {
      const resolutionRate = (employeeStats.totalResolved + employeeStats.totalClosed) / employeeStats.totalAssigned;
      satisfactionRating = Math.min(5.0, resolutionRate * 5.0); // Cap at 5.0
    }

    employeePerformance.push({
      id: employee.id,
      name: employee.name,
      email: employee.email,
      totalAssigned: employeeStats.totalAssigned,
      totalResolved: employeeStats.totalResolved,
      totalClosed: employeeStats.totalClosed,
      averageResolutionTime: employeeStats.avgResolutionHours || 0,
      satisfactionRating: Math.round(satisfactionRating * 100) / 100
    });
  }

  return {
    employeePerformance,
    reportGeneratedAt: new Date()
  };
}

// Helper function to generate category analysis report
async function generateCategoryAnalysis(startDate, endDate) {
  // Get all categories with their complaint counts
  const categoryAnalysis = await executeQuery(
    `SELECT 
       category,
       COUNT(*) as totalComplaints,
       COUNT(CASE WHEN status = 'resolved' THEN 1 END) as resolvedComplaints,
       COUNT(CASE WHEN status = 'closed' THEN 1 END) as closedComplaints,
       AVG(CASE WHEN resolved_at IS NOT NULL 
            THEN TIMESTAMPDIFF(HOUR, created_at, resolved_at) 
            END) as avgResolutionHours
     FROM complaints 
     WHERE created_at BETWEEN ? AND ? 
     GROUP BY category
     ORDER BY totalComplaints DESC`,
    [startDate, endDate]
  );

  // Calculate totals
  const totalComplaints = categoryAnalysis.reduce((sum, cat) => sum + cat.totalComplaints, 0);
  const totalResolved = categoryAnalysis.reduce((sum, cat) => sum + cat.resolvedComplaints + cat.closedComplaints, 0);

  return {
    totalComplaints,
    totalResolved,
    categoryBreakdown: categoryAnalysis,
    reportGeneratedAt: new Date()
  };
}

// Get dashboard statistics (for admin dashboard)
router.get('/dashboard', authenticateToken, authorizeRoles('admin'), async (req, res) => {
  try {
    const { period = '30' } = req.query; // days
    
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(period));

    // Get total complaints
    const totalComplaints = await executeQuery(
      'SELECT COUNT(*) as count FROM complaints WHERE created_at >= ?',
      [startDate.toISOString()]
    );

    // Get complaints by status
    const statusCounts = await executeQuery(
      `SELECT status, COUNT(*) as count 
       FROM complaints 
       WHERE created_at >= ? 
       GROUP BY status`,
      [startDate.toISOString()]
    );

    // Get total users
    const totalUsers = await executeQuery(
      'SELECT COUNT(*) as count FROM users'
    );

    // Get active employees
    const activeEmployees = await executeQuery(
      `SELECT COUNT(DISTINCT assigned_employee_id) as count 
       FROM complaints 
       WHERE assigned_employee_id IS NOT NULL 
       AND created_at >= ?`,
      [startDate.toISOString()]
    );

    // Get recent complaints
    const recentComplaints = await executeQuery(
      `SELECT c.*, u.name as customer_name 
       FROM complaints c
       LEFT JOIN users u ON c.customer_id = u.id
       ORDER BY c.created_at DESC 
       LIMIT 5`
    );

    // Format status counts
    const formattedStatusCounts = {};
    statusCounts.forEach(item => {
      formattedStatusCounts[item.status] = item.count;
    });

    res.json({
      overview: {
        totalComplaints: totalComplaints[0].count,
        totalUsers: totalUsers[0].count,
        activeEmployees: activeEmployees[0].count,
        period: `${period} days`
      },
      statusBreakdown: formattedStatusCounts,
      recentComplaints,
      lastUpdated: new Date()
    });

  } catch (error) {
    console.error('Get dashboard statistics error:', error);
    res.status(500).json({
      error: 'Failed to get dashboard statistics',
      message: error.message
    });
  }
});

module.exports = router;
