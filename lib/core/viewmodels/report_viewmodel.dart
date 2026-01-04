import 'package:flutter/material.dart';
import 'package:cs_task_managment/core/models/report.dart';
import 'package:cs_task_managment/core/services/report_service.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Report> _reports = [];
  List<Report> get reports => _reports;

  Report? _currentReport;
  Report? get currentReport => _currentReport;

  Future<void> generateReport(String reportType, DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentReport = await _reportService.generateReport(reportType, startDate, endDate);
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      _reports = await _reportService.getReports();
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> generateComplaintSummaryReport(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentReport = await _reportService.generateComplaintSummaryReport(startDate, endDate);
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> generateEmployeePerformanceReport(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentReport = await _reportService.generateEmployeePerformanceReport(startDate, endDate);
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> generateCategoryAnalysisReport(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentReport = await _reportService.generateCategoryAnalysisReport(startDate, endDate);
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }
}
