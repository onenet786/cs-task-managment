import 'package:flutter/material.dart';
import 'package:cs_task_managment/core/models/complaint.dart';
import 'package:cs_task_managment/core/services/complaint_service.dart';

class ComplaintViewModel extends ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Complaint> _myComplaints = [];
  List<Complaint> get myComplaints => _myComplaints;

  List<Complaint> _assignedComplaints = [];
  List<Complaint> get assignedComplaints => _assignedComplaints;

  List<Complaint> _allComplaints = [];
  List<Complaint> get allComplaints => _allComplaints;

  Complaint? _currentComplaint;
  Complaint? get currentComplaint => _currentComplaint;

  Future<void> createComplaint(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _complaintService.createComplaint(data);
      // Handle successful creation
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getMyComplaints(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _myComplaints = await _complaintService.getMyComplaints(userId);
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getAssignedComplaints(int employeeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _assignedComplaints = await _complaintService.getAssignedComplaints(employeeId);
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getAllComplaints() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allComplaints = await _complaintService.getAllComplaints();
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getComplaintById(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentComplaint = await _complaintService.getComplaintById(id);
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateComplaint(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _complaintService.updateComplaint(id, data);
      // Refresh complaint data if needed
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteComplaint(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _complaintService.deleteComplaint(id);
      // Remove from lists
      _myComplaints.removeWhere((c) => c.id == id);
      _assignedComplaints.removeWhere((c) => c.id == id);
      _allComplaints.removeWhere((c) => c.id == id);
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> assignComplaint(int complaintId, int employeeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _complaintService.assignComplaint(complaintId, employeeId);
      // Refresh data if needed
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsResolved(int complaintId, String resolutionNotes) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _complaintService.markAsResolved(complaintId, resolutionNotes);
      // Refresh data if needed
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsClosed(int complaintId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _complaintService.markAsClosed(complaintId);
      // Refresh data if needed
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }
}
