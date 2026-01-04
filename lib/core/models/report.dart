import 'package:json_annotation/json_annotation.dart';

part 'report.g.dart';

@JsonSerializable()
class Report {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalComplaints;
  final int pendingComplaints;
  final int resolvedComplaints;
  final int closedComplaints;
  final double averageResolutionTime;
  final Map<String, int> complaintsByCategory;
  final Map<String, int> complaintsByStatus;
  final List<ComplaintSummary> topComplaints;
  final List<EmployeeSummary> employeePerformance;

  Report({
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.totalComplaints,
    required this.pendingComplaints,
    required this.resolvedComplaints,
    required this.closedComplaints,
    required this.averageResolutionTime,
    required this.complaintsByCategory,
    required this.complaintsByStatus,
    required this.topComplaints,
    required this.employeePerformance,
  });

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}

@JsonSerializable()
class ComplaintSummary {
  final int id;
  final String title;
  final String category;
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  ComplaintSummary({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ComplaintSummary.fromJson(Map<String, dynamic> json) => _$ComplaintSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ComplaintSummaryToJson(this);
}

@JsonSerializable()
class EmployeeSummary {
  final int id;
  final String name;
  final String email;
  final int totalAssigned;
  final int totalResolved;
  final int totalClosed;
  final double averageResolutionTime;
  final double satisfactionRating;

  EmployeeSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.totalAssigned,
    required this.totalResolved,
    required this.totalClosed,
    required this.averageResolutionTime,
    required this.satisfactionRating,
  });

  factory EmployeeSummary.fromJson(Map<String, dynamic> json) => _$EmployeeSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeSummaryToJson(this);
}
