class AppConstants {
  // API Constants
  static const String baseUrl = 'http://localhost:3000/api';
  static const String apiTimeout = '30000';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';
  static const String roleCustomer = 'customer';

  // Complaint Statuses
  static const String statusPending = 'pending';
  static const String statusAssigned = 'assigned';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';
  static const String statusClosed = 'closed';

  // Complaint Categories
  static const List<String> complaintCategories = [
    'Technical Issue',
    'Billing Problem',
    'Service Request',
    'Product Issue',
    'General Inquiry',
    'Feedback',
    'Other',
  ];

  // Notification Types
  static const String notificationTypeComplaint = 'complaint';
  static const String notificationTypeAssignment = 'assignment';
  static const String notificationTypeStatusUpdate = 'status_update';
  static const String notificationTypeSystem = 'system';

  // Report Types
  static const String reportTypeComplaintSummary = 'complaint_summary';
  static const String reportTypeEmployeePerformance = 'employee_performance';
  static const String reportTypeCategoryAnalysis = 'category_analysis';

  // Storage Keys
  static const String storageUserKey = 'user';
  static const String storageTokenKey = 'token';

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 1000;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy hh:mm a';

  // Error Messages
  static const String errorEmailRequired = 'Email is required';
  static const String errorInvalidEmail = 'Please enter a valid email';
  static const String errorPasswordRequired = 'Password is required';
  static const String errorPasswordTooShort = 'Password must be at least 6 characters';
  static const String errorNameRequired = 'Name is required';
  static const String errorPhoneRequired = 'Phone is required';
  static const String errorTitleRequired = 'Title is required';
  static const String errorDescriptionRequired = 'Description is required';
  static const String errorCategoryRequired = 'Category is required';
}
