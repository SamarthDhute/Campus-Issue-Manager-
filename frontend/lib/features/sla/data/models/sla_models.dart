class IssueSlaModel {
  final String id;
  final String issueId;
  final DateTime? responseDueAt;
  final DateTime? resolutionDueAt;
  final DateTime? responseMetAt;
  final DateTime? resolutionMetAt;
  final DateTime? responseBreachedAt;
  final DateTime? resolutionBreachedAt;
  final String status;
  final int responseSecondsRemaining;
  final int resolutionSecondsRemaining;
  final double responseProgressPercentage;
  final double resolutionProgressPercentage;
  final bool responseBreached;
  final bool resolutionBreached;
  final bool responseMet;
  final bool resolutionMet;

  IssueSlaModel({
    required this.id,
    required this.issueId,
    this.responseDueAt,
    this.resolutionDueAt,
    this.responseMetAt,
    this.resolutionMetAt,
    this.responseBreachedAt,
    this.resolutionBreachedAt,
    required this.status,
    required this.responseSecondsRemaining,
    required this.resolutionSecondsRemaining,
    required this.responseProgressPercentage,
    required this.resolutionProgressPercentage,
    required this.responseBreached,
    required this.resolutionBreached,
    required this.responseMet,
    required this.resolutionMet,
  });

  factory IssueSlaModel.fromJson(Map<String, dynamic> json) {
    return IssueSlaModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      responseDueAt: json['responseDueAt'] != null
          ? DateTime.tryParse(json['responseDueAt'].toString())
          : null,
      resolutionDueAt: json['resolutionDueAt'] != null
          ? DateTime.tryParse(json['resolutionDueAt'].toString())
          : null,
      responseMetAt: json['responseMetAt'] != null
          ? DateTime.tryParse(json['responseMetAt'].toString())
          : null,
      resolutionMetAt: json['resolutionMetAt'] != null
          ? DateTime.tryParse(json['resolutionMetAt'].toString())
          : null,
      responseBreachedAt: json['responseBreachedAt'] != null
          ? DateTime.tryParse(json['responseBreachedAt'].toString())
          : null,
      resolutionBreachedAt: json['resolutionBreachedAt'] != null
          ? DateTime.tryParse(json['resolutionBreachedAt'].toString())
          : null,
      status: json['status'] as String? ?? 'ON_TRACK',
      responseSecondsRemaining: (json['responseSecondsRemaining'] as num?)?.toInt() ?? 0,
      resolutionSecondsRemaining: (json['resolutionSecondsRemaining'] as num?)?.toInt() ?? 0,
      responseProgressPercentage: (json['responseProgressPercentage'] as num?)?.toDouble() ?? 0.0,
      resolutionProgressPercentage: (json['resolutionProgressPercentage'] as num?)?.toDouble() ?? 0.0,
      responseBreached: json['responseBreached'] as bool? ?? false,
      resolutionBreached: json['resolutionBreached'] as bool? ?? false,
      responseMet: json['responseMet'] as bool? ?? false,
      resolutionMet: json['resolutionMet'] as bool? ?? false,
    );
  }
}

class RiskEventModel {
  final String id;
  final String issueId;
  final String riskType;
  final String severity;
  final String explanation;
  final DateTime? detectedAt;
  final DateTime? resolvedAt;
  final bool active;

  RiskEventModel({
    required this.id,
    required this.issueId,
    required this.riskType,
    required this.severity,
    required this.explanation,
    this.detectedAt,
    this.resolvedAt,
    required this.active,
  });

  factory RiskEventModel.fromJson(Map<String, dynamic> json) {
    return RiskEventModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      riskType: json['riskType'] as String? ?? '',
      severity: json['severity'] as String? ?? 'MEDIUM',
      explanation: json['explanation'] as String? ?? '',
      detectedAt: json['detectedAt'] != null
          ? DateTime.tryParse(json['detectedAt'].toString())
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'].toString())
          : null,
      active: json['active'] as bool? ?? true,
    );
  }
}

class EscalationModel {
  final String id;
  final String issueId;
  final String triggerType;
  final int level;
  final String status;
  final String reason;
  final String? triggeredById;
  final String triggeredByName;
  final String triggeredByRole;
  final DateTime? triggeredAt;
  final DateTime? resolvedAt;

  EscalationModel({
    required this.id,
    required this.issueId,
    required this.triggerType,
    required this.level,
    required this.status,
    required this.reason,
    this.triggeredById,
    required this.triggeredByName,
    required this.triggeredByRole,
    this.triggeredAt,
    this.resolvedAt,
  });

  factory EscalationModel.fromJson(Map<String, dynamic> json) {
    return EscalationModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      triggerType: json['triggerType'] as String? ?? 'MANUAL_STAFF_OVERRIDE',
      level: (json['level'] as num?)?.toInt() ?? 1,
      status: json['status'] as String? ?? 'OPEN',
      reason: json['reason'] as String? ?? '',
      triggeredById: json['triggeredById'] as String?,
      triggeredByName: json['triggeredByName'] as String? ?? 'System',
      triggeredByRole: json['triggeredByRole'] as String? ?? 'SYSTEM',
      triggeredAt: json['triggeredAt'] != null
          ? DateTime.tryParse(json['triggeredAt'].toString())
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'].toString())
          : null,
    );
  }
}

class NotificationModel {
  final String id;
  final String recipientId;
  final String? issueId;
  final String? issueNumber;
  final String notificationType;
  final String title;
  final String body;
  final String channel;
  final String status;
  final DateTime? sentAt;
  final DateTime? readAt;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    this.issueId,
    this.issueNumber,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.channel,
    required this.status,
    this.sentAt,
    this.readAt,
    this.createdAt,
  });

  bool get isUnread => status == 'UNREAD';

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      recipientId: json['recipientId'] as String? ?? '',
      issueId: json['issueId'] as String?,
      issueNumber: json['issueNumber'] as String?,
      notificationType: json['notificationType'] as String? ?? 'GENERAL',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      channel: json['channel'] as String? ?? 'IN_APP',
      status: json['status'] as String? ?? 'UNREAD',
      sentAt: json['sentAt'] != null
          ? DateTime.tryParse(json['sentAt'].toString())
          : null,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
