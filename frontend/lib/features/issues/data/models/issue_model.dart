import 'timeline_event_model.dart';

class IssueModel {
  final String id;
  final String issueNumber;
  final String title;
  final String description;
  final String? categoryId;
  final String? categoryName;
  final String location;
  final String requesterId;
  final String requesterName;
  final String? requesterEmail;
  final String? assignedTeamId;
  final String? assignedTeamName;
  final String? assignedUserId;
  final String? assignedUserName;
  final String status;
  final String priority;
  final List<TimelineEventModel> timeline;
  final DateTime createdAt;
  final DateTime updatedAt;

  IssueModel({
    required this.id,
    required this.issueNumber,
    required this.title,
    required this.description,
    this.categoryId,
    this.categoryName,
    required this.location,
    required this.requesterId,
    required this.requesterName,
    this.requesterEmail,
    this.assignedTeamId,
    this.assignedTeamName,
    this.assignedUserId,
    this.assignedUserName,
    required this.status,
    required this.priority,
    required this.timeline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['id'] as String,
      issueNumber: json['issueNumber'] as String? ?? 'ISS-0000',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      location: json['location'] as String? ?? '',
      requesterId: json['requesterId'] as String? ?? '',
      requesterName: json['requesterName'] as String? ?? 'Student',
      requesterEmail: json['requesterEmail'] as String?,
      assignedTeamId: json['assignedTeamId'] as String?,
      assignedTeamName: json['assignedTeamName'] as String?,
      assignedUserId: json['assignedUserId'] as String?,
      assignedUserName: json['assignedUserName'] as String?,
      status: json['status'] as String? ?? 'REPORTED',
      priority: json['priority'] as String? ?? 'MEDIUM',
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) => TimelineEventModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issueNumber': issueNumber,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'location': location,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterEmail': requesterEmail,
      'assignedTeamId': assignedTeamId,
      'assignedTeamName': assignedTeamName,
      'assignedUserId': assignedUserId,
      'assignedUserName': assignedUserName,
      'status': status,
      'priority': priority,
      'timeline': timeline.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
