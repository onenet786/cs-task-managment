// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
  reportType: json['reportType'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  totalComplaints: (json['totalComplaints'] as num).toInt(),
  pendingComplaints: (json['pendingComplaints'] as num).toInt(),
  resolvedComplaints: (json['resolvedComplaints'] as num).toInt(),
  closedComplaints: (json['closedComplaints'] as num).toInt(),
  averageResolutionTime: (json['averageResolutionTime'] as num).toDouble(),
  complaintsByCategory: Map<String, int>.from(
    json['complaintsByCategory'] as Map,
  ),
  complaintsByStatus: Map<String, int>.from(json['complaintsByStatus'] as Map),
  topComplaints: (json['topComplaints'] as List<dynamic>)
      .map((e) => ComplaintSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  employeePerformance: (json['employeePerformance'] as List<dynamic>)
      .map((e) => EmployeeSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
  'reportType': instance.reportType,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'totalComplaints': instance.totalComplaints,
  'pendingComplaints': instance.pendingComplaints,
  'resolvedComplaints': instance.resolvedComplaints,
  'closedComplaints': instance.closedComplaints,
  'averageResolutionTime': instance.averageResolutionTime,
  'complaintsByCategory': instance.complaintsByCategory,
  'complaintsByStatus': instance.complaintsByStatus,
  'topComplaints': instance.topComplaints,
  'employeePerformance': instance.employeePerformance,
};

ComplaintSummary _$ComplaintSummaryFromJson(Map<String, dynamic> json) =>
    ComplaintSummary(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$ComplaintSummaryToJson(ComplaintSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };

EmployeeSummary _$EmployeeSummaryFromJson(Map<String, dynamic> json) =>
    EmployeeSummary(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      totalAssigned: (json['totalAssigned'] as num).toInt(),
      totalResolved: (json['totalResolved'] as num).toInt(),
      totalClosed: (json['totalClosed'] as num).toInt(),
      averageResolutionTime: (json['averageResolutionTime'] as num).toDouble(),
      satisfactionRating: (json['satisfactionRating'] as num).toDouble(),
    );

Map<String, dynamic> _$EmployeeSummaryToJson(EmployeeSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'totalAssigned': instance.totalAssigned,
      'totalResolved': instance.totalResolved,
      'totalClosed': instance.totalClosed,
      'averageResolutionTime': instance.averageResolutionTime,
      'satisfactionRating': instance.satisfactionRating,
    };
