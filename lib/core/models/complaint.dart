import 'package:json_annotation/json_annotation.dart';

part 'complaint.g.dart';

@JsonSerializable()
class Complaint {
  final int id;
  final int customerId;
  final String customerName;
  final String customerEmail;
  final String title;
  final String description;
  final String category;
  final String status;
  final int? assignedEmployeeId;
  final String? assignedEmployeeName;
  final String? assignedEmployeeEmail;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final String? imageUrl;

  Complaint({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.assignedEmployeeId,
    this.assignedEmployeeName,
    this.assignedEmployeeEmail,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.resolutionNotes,
    this.imageUrl,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) => _$ComplaintFromJson(json);
  Map<String, dynamic> toJson() => _$ComplaintToJson(this);

  bool get isPending => status == 'pending';
  bool get isAssigned => status == 'assigned';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
}
