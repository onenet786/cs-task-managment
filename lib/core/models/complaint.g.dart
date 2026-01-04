// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Complaint _$ComplaintFromJson(Map<String, dynamic> json) => Complaint(
  id: (json['id'] as num).toInt(),
  customerId: (json['customerId'] as num).toInt(),
  customerName: json['customerName'] as String,
  customerEmail: json['customerEmail'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  status: json['status'] as String,
  assignedEmployeeId: (json['assignedEmployeeId'] as num?)?.toInt(),
  assignedEmployeeName: json['assignedEmployeeName'] as String?,
  assignedEmployeeEmail: json['assignedEmployeeEmail'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  resolutionNotes: json['resolutionNotes'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$ComplaintToJson(Complaint instance) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'customerName': instance.customerName,
  'customerEmail': instance.customerEmail,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'status': instance.status,
  'assignedEmployeeId': instance.assignedEmployeeId,
  'assignedEmployeeName': instance.assignedEmployeeName,
  'assignedEmployeeEmail': instance.assignedEmployeeEmail,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'resolutionNotes': instance.resolutionNotes,
  'imageUrl': instance.imageUrl,
};
