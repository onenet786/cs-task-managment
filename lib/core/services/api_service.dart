import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cs_task_managment/core/models/user.dart';
import 'package:cs_task_managment/core/models/complaint.dart';
import 'package:cs_task_managment/core/models/notification.dart';
import 'package:cs_task_managment/core/models/report.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:3000/api'; // Your MySQL backend URL

  ApiService() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> get(String endpoint) async {
    try {
      final response = await _dio.get('$_baseUrl$endpoint');
      return response;
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<Response> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post('$_baseUrl$endpoint',
          data: jsonEncode(data));
      return response;
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<Response> put(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put('$_baseUrl$endpoint',
          data: jsonEncode(data));
      return response;
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete('$_baseUrl$endpoint');
      return response;
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  // Authentication Endpoints
  Future<User> login(String email, String password) async {
    final response = await post('/auth/login', {'email': email, 'password': password});
    return User.fromJson(response.data['user']);
  }

  Future<void> register(String name, String email, String phone, String password, String role) async {
    await post('/auth/register', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role
    });
  }

  Future<void> verifyEmail(String email, String code) async {
    await post('/auth/verify-email', {'email': email, 'code': code});
  }

  Future<void> sendVerificationCode(String email) async {
    await post('/auth/send-verification-code', {'email': email});
  }

  // User Endpoints
  Future<User> getCurrentUser() async {
    final response = await get('/users/me');
    return User.fromJson(response.data);
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await put('/users/$id', data);
  }

  // Complaint Endpoints
  Future<Complaint> createComplaint(Map<String, dynamic> data) async {
    final response = await post('/complaints', data);
    return Complaint.fromJson(response.data);
  }

  Future<List<Complaint>> getMyComplaints(int userId) async {
    final response = await get('/complaints/user/$userId');
    return response.data.map<Complaint>((e) => Complaint.fromJson(e)).toList();
  }

  Future<List<Complaint>> getAssignedComplaints(int employeeId) async {
    final response = await get('/complaints/assigned/$employeeId');
    return response.data.map<Complaint>((e) => Complaint.fromJson(e)).toList();
  }

  Future<List<Complaint>> getAllComplaints() async {
    final response = await get('/complaints');
    return response.data.map<Complaint>((e) => Complaint.fromJson(e)).toList();
  }

  Future<Complaint> getComplaintById(int id) async {
    final response = await get('/complaints/$id');
    return Complaint.fromJson(response.data);
  }

  Future<void> updateComplaint(int id, Map<String, dynamic> data) async {
    await put('/complaints/$id', data);
  }

  Future<void> deleteComplaint(int id) async {
    await delete('/complaints/$id');
  }

  // Assignment Endpoints
  Future<void> assignComplaint(int complaintId, int employeeId) async {
    await post('/complaints/$complaintId/assign', {'employeeId': employeeId});
  }

  // Notification Endpoints
  Future<List<NotificationModel>> getNotifications(int userId) async {
    final response = await get('/notifications/user/$userId');
    return response.data.map<NotificationModel>((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    await put('/notifications/$notificationId/read', {});
  }

  Future<void> sendNotification(int userId, String title, String message, String type, 
      {String? relatedId, String? relatedType}) async {
    await post('/notifications', {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'relatedId': relatedId,
      'relatedType': relatedType
    });
  }

  // Report Endpoints
  Future<Report> generateReport(String reportType, DateTime startDate, DateTime endDate) async {
    final response = await post('/reports', {
      'reportType': reportType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String()
    });
    return Report.fromJson(response.data);
  }

  Future<List<Report>> getReports() async {
    final response = await get('/reports');
    return response.data.map<Report>((e) => Report.fromJson(e)).toList();
  }
}
