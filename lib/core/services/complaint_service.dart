import 'package:cs_task_managment/core/models/complaint.dart';
import 'package:cs_task_managment/core/services/api_service.dart';

class ComplaintService {
  final ApiService _apiService = ApiService();

  Future<Complaint> createComplaint(Map<String, dynamic> data) async {
    return await _apiService.createComplaint(data);
  }

  Future<List<Complaint>> getMyComplaints(int userId) async {
    return await _apiService.getMyComplaints(userId);
  }

  Future<List<Complaint>> getAssignedComplaints(int employeeId) async {
    return await _apiService.getAssignedComplaints(employeeId);
  }

  Future<List<Complaint>> getAllComplaints() async {
    return await _apiService.getAllComplaints();
  }

  Future<Complaint> getComplaintById(int id) async {
    return await _apiService.getComplaintById(id);
  }

  Future<void> updateComplaint(int id, Map<String, dynamic> data) async {
    await _apiService.updateComplaint(id, data);
  }

  Future<void> deleteComplaint(int id) async {
    await _apiService.deleteComplaint(id);
  }

  Future<void> assignComplaint(int complaintId, int employeeId) async {
    await _apiService.assignComplaint(complaintId, employeeId);
  }

  Future<void> markAsResolved(int complaintId, String resolutionNotes) async {
    await _apiService.updateComplaint(complaintId, {
      'status': 'resolved',
      'resolutionNotes': resolutionNotes,
      'resolvedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> markAsClosed(int complaintId) async {
    await _apiService.updateComplaint(complaintId, {
      'status': 'closed',
    });
  }
}
