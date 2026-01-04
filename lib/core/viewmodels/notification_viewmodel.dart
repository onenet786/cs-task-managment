import 'package:flutter/material.dart';
import 'package:cs_task_managment/core/models/notification.dart';
import 'package:cs_task_managment/core/services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  Future<void> getNotifications(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications(userId);
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationService.markNotificationAsRead(notificationId);
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true,
          createdAt: _notifications[index].createdAt,
          relatedId: _notifications[index].relatedId,
          relatedType: _notifications[index].relatedType,
        );
      }
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendNotification(int userId, String title, String message, String type,
      {String? relatedId, String? relatedType}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationService.sendNotification(userId, title, message, type,
          relatedId: relatedId, relatedType: relatedType);
      // Refresh notifications if needed
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendComplaintAssignedNotification(int employeeId, int complaintId, String complaintTitle) async {
    await _notificationService.sendComplaintAssignedNotification(employeeId, complaintId, complaintTitle);
  }

  Future<void> sendComplaintResolvedNotification(int customerId, int complaintId, String complaintTitle) async {
    await _notificationService.sendComplaintResolvedNotification(customerId, complaintId, complaintTitle);
  }

  Future<void> sendComplaintStatusUpdateNotification(int userId, int complaintId, String complaintTitle, String status) async {
    await _notificationService.sendComplaintStatusUpdateNotification(userId, complaintId, complaintTitle, status);
  }

  int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }
}
