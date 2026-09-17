class AssignmentModel {
  final String id;
  final String issueId;
  final String? teamId;
  final String? teamName;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String assignmentType;
  final String recommendationSource;
  final String? reason;
  final String? assignedById;
  final String? assignedByName;
  final DateTime? assignedAt;
  final DateTime? endedAt;
  final bool active;

  AssignmentModel({
    required this.id,
    required this.issueId,
    this.teamId,
    this.teamName,
    this.userId,
    this.userName,
    this.userEmail,
    required this.assignmentType,
    required this.recommendationSource,
    this.reason,
    this.assignedById,
    this.assignedByName,
    this.assignedAt,
    this.endedAt,
    required this.active,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      teamId: json['teamId'] as String?,
      teamName: json['teamName'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      assignmentType: json['assignmentType'] as String? ?? 'PRIMARY',
      recommendationSource: json['recommendationSource'] as String? ?? 'MANUAL',
      reason: json['reason'] as String?,
      assignedById: json['assignedById'] as String?,
      assignedByName: json['assignedByName'] as String?,
      assignedAt: json['assignedAt'] != null ? DateTime.tryParse(json['assignedAt'] as String) : null,
      endedAt: json['endedAt'] != null ? DateTime.tryParse(json['endedAt'] as String) : null,
      active: json['active'] as bool? ?? (json['endedAt'] == null),
    );
  }
}

class CandidateOperatorModel {
  final String userId;
  final String name;
  final String email;
  final String? teamId;
  final String teamName;
  final int activeTasksCount;
  final double matchScore;
  final String reason;

  CandidateOperatorModel({
    required this.userId,
    required this.name,
    required this.email,
    this.teamId,
    required this.teamName,
    required this.activeTasksCount,
    required this.matchScore,
    required this.reason,
  });

  factory CandidateOperatorModel.fromJson(Map<String, dynamic> json) {
    return CandidateOperatorModel(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      teamId: json['teamId'] as String?,
      teamName: json['teamName'] as String? ?? 'Facilities',
      activeTasksCount: (json['activeTasksCount'] as num?)?.toInt() ?? 0,
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0.85,
      reason: json['reason'] as String? ?? '',
    );
  }
}

class AssignmentRecommendationModel {
  final String issueId;
  final String? recommendedTeamId;
  final String recommendedTeamName;
  final String recommendedUserId;
  final String recommendedUserName;
  final String recommendedUserEmail;
  final double matchScore;
  final String rationale;
  final int currentActiveWorkload;
  final List<CandidateOperatorModel> alternateCandidates;

  AssignmentRecommendationModel({
    required this.issueId,
    this.recommendedTeamId,
    required this.recommendedTeamName,
    required this.recommendedUserId,
    required this.recommendedUserName,
    required this.recommendedUserEmail,
    required this.matchScore,
    required this.rationale,
    required this.currentActiveWorkload,
    this.alternateCandidates = const [],
  });

  factory AssignmentRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AssignmentRecommendationModel(
      issueId: json['issueId'] as String? ?? '',
      recommendedTeamId: json['recommendedTeamId'] as String?,
      recommendedTeamName: json['recommendedTeamName'] as String? ?? 'Facilities',
      recommendedUserId: json['recommendedUserId'] as String? ?? '',
      recommendedUserName: json['recommendedUserName'] as String? ?? 'Technician',
      recommendedUserEmail: json['recommendedUserEmail'] as String? ?? '',
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0.85,
      rationale: json['rationale'] as String? ?? '',
      currentActiveWorkload: (json['currentActiveWorkload'] as num?)?.toInt() ?? 0,
      alternateCandidates: (json['alternateCandidates'] as List<dynamic>?)
              ?.map((e) => CandidateOperatorModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class IssueMessageModel {
  final String id;
  final String issueId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String messageType;
  final String body;
  final String visibility;
  final DateTime? createdAt;

  IssueMessageModel({
    required this.id,
    required this.issueId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.messageType,
    required this.body,
    required this.visibility,
    this.createdAt,
  });

  factory IssueMessageModel.fromJson(Map<String, dynamic> json) {
    return IssueMessageModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? 'User',
      senderRole: json['senderRole'] as String? ?? 'STUDENT',
      messageType: json['messageType'] as String? ?? 'USER_MESSAGE',
      body: json['body'] as String? ?? '',
      visibility: json['visibility'] as String? ?? 'PUBLIC',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }
}

class InternalNoteModel {
  final String id;
  final String issueId;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String body;
  final DateTime? createdAt;

  InternalNoteModel({
    required this.id,
    required this.issueId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.body,
    this.createdAt,
  });

  factory InternalNoteModel.fromJson(Map<String, dynamic> json) {
    return InternalNoteModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? 'Staff',
      authorRole: json['authorRole'] as String? ?? 'OPERATOR',
      body: json['body'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }
}

class InvestigationModel {
  final String id;
  final String issueId;
  final String investigatorId;
  final String investigatorName;
  final String investigatorRole;
  final String observations;
  final String? actionsTaken;
  final String? findings;
  final String? followUp;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InvestigationModel({
    required this.id,
    required this.issueId,
    required this.investigatorId,
    required this.investigatorName,
    required this.investigatorRole,
    required this.observations,
    this.actionsTaken,
    this.findings,
    this.followUp,
    this.createdAt,
    this.updatedAt,
  });

  factory InvestigationModel.fromJson(Map<String, dynamic> json) {
    return InvestigationModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      investigatorId: json['investigatorId'] as String? ?? '',
      investigatorName: json['investigatorName'] as String? ?? 'Technician',
      investigatorRole: json['investigatorRole'] as String? ?? 'OPERATOR',
      observations: json['observations'] as String? ?? '',
      actionsTaken: json['actionsTaken'] as String?,
      findings: json['findings'] as String?,
      followUp: json['followUp'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
}

class IssueTaskModel {
  final String id;
  final String issueId;
  final String title;
  final String? description;
  final String? ownerId;
  final String? ownerName;
  final String? ownerEmail;
  final String status; // PENDING, IN_PROGRESS, COMPLETED, CANCELLED
  final DateTime? dueAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  IssueTaskModel({
    required this.id,
    required this.issueId,
    required this.title,
    this.description,
    this.ownerId,
    this.ownerName,
    this.ownerEmail,
    required this.status,
    this.dueAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isCompleted => status == 'COMPLETED';

  factory IssueTaskModel.fromJson(Map<String, dynamic> json) {
    return IssueTaskModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerEmail: json['ownerEmail'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      dueAt: json['dueAt'] != null ? DateTime.tryParse(json['dueAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
}
