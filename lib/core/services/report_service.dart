import 'package:cs_task_managment/core/models/report.dart';
import 'package:cs_task_managment/core/services/api_service.dart';

class ReportService {
  final ApiService _apiService = ApiService();

  Future<Report> generateReport(String reportType, DateTime startDate, DateTime endDate) async {
    return await _apiService.generateReport(reportType, startDate, endDate);
  }

  Future<List<Report>> getReports() async {
    return await _apiService.getReports();
  }

  Future<Report> generateComplaintSummaryReport(DateTime startDate, DateTime endDate) async {
    return await generateReport('complaint_summary', startDate, endDate);
  }

  Future<Report> generateEmployeePerformanceReport(DateTime startDate, DateTime endDate) async {
    return await generateReport('employee_performance', startDate, endDate);
  }

  Future<Report> generateCategoryAnalysisReport(DateTime startDate, DateTime endDate) async {
    return await generateReport('category_analysis', startDate, endDate);
  }
}
