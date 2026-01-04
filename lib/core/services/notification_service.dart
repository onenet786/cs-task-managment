import 'package:cs_task_managment/core/models/notification.dart';
import 'package:cs_task_managment/core/services/api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  Future<List<NotificationModel>> getNotifications(int userId) async {
    return await _apiService.getNotifications(userId);
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    await _apiService.markNotificationAsRead(notificationId);
  }

  Future<void> sendNotification(int userId, String title, String message, String type,
      {String? relatedId, String? relatedType}) async {
    await _apiService.sendNotification(userId, title, message, type,
        relatedId: relatedId, relatedType: relatedType);
  }

  Future<void> sendComplaintAssignedNotification(int employeeId, int complaintId, String complaintTitle) async {
    await sendNotification(
      employeeId,
      'New Complaint Assigned',
      'You have been assigned a new complaint: $complaintTitle',
      'assignment',
      relatedId: complaintId.toString(),
      relatedType: 'complaint',
    );
  }

  Future<void> sendComplaintResolvedNotification(int customerId, int complaintId, String complaintTitle) async {
    await sendNotification(
      customerId,
      'Complaint Resolved',
      'Your complaint "$complaintTitle" has been resolved',
      'status_update',
      relatedId: complaintId.toString(),
      relatedType: 'complaint',
    );
  }

  Future<void> sendComplaintStatusUpdateNotification(int userId, int complaintId, String complaintTitle, String status) async {
    await sendNotification(
      userId,
      'Complaint Status Updated',
      'Your complaint "$complaintTitle" status has been updated to: $status',
      'status_update',
      relatedId: complaintId.toString(),
      relatedType: 'complaint',
    );
  }
}
