class AuditEventModel {
  final String id;
  final String? actorId;
  final String actorName;
  final String actorRole;
  final String entityType;
  final String entityId;
  final String eventType;
  final String? actionSummary;
  final String? beforeData;
  final String? afterData;
  final String? metadata;
  final String? ipAddress;
  final DateTime createdAt;

  AuditEventModel({
    required this.id,
    this.actorId,
    required this.actorName,
    required this.actorRole,
    required this.entityType,
    required this.entityId,
    required this.eventType,
    this.actionSummary,
    this.beforeData,
    this.afterData,
    this.metadata,
    this.ipAddress,
    required this.createdAt,
  });

  factory AuditEventModel.fromJson(Map<String, dynamic> json) {
    return AuditEventModel(
      id: json['id'] as String? ?? '',
      actorId: json['actorId'] as String?,
      actorName: json['actorName'] as String? ?? 'System Automation',
      actorRole: json['actorRole'] as String? ?? 'SYSTEM',
      entityType: json['entityType'] as String? ?? 'ISSUE',
      entityId: json['entityId'] as String? ?? '',
      eventType: json['eventType'] as String? ?? 'EVENT',
      actionSummary: json['actionSummary'] as String?,
      beforeData: json['beforeData'] as String?,
      afterData: json['afterData'] as String?,
      metadata: json['metadata'] as String?,
      ipAddress: json['ipAddress'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class SecurityEventModel {
  final String id;
  final String? actorId;
  final String? actorEmail;
  final String eventType;
  final String severity;
  final String? metadata;
  final String? ipAddress;
  final DateTime createdAt;

  SecurityEventModel({
    required this.id,
    this.actorId,
    this.actorEmail,
    required this.eventType,
    required this.severity,
    this.metadata,
    this.ipAddress,
    required this.createdAt,
  });

  factory SecurityEventModel.fromJson(Map<String, dynamic> json) {
    return SecurityEventModel(
      id: json['id'] as String? ?? '',
      actorId: json['actorId'] as String?,
      actorEmail: json['actorEmail'] as String?,
      eventType: json['eventType'] as String? ?? 'EVENT',
      severity: json['severity'] as String? ?? 'INFO',
      metadata: json['metadata'] as String?,
      ipAddress: json['ipAddress'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class SystemStatusModel {
  final String status;
  final String environment;
  final String version;
  final int uptimeSeconds;
  final DateTime serverTime;
  final Map<String, dynamic> components;
  final Map<String, dynamic> metrics;

  SystemStatusModel({
    required this.status,
    required this.environment,
    required this.version,
    required this.uptimeSeconds,
    required this.serverTime,
    required this.components,
    required this.metrics,
  });

  factory SystemStatusModel.fromJson(Map<String, dynamic> json) {
    return SystemStatusModel(
      status: json['status'] as String? ?? 'UP',
      environment: json['environment'] as String? ?? 'production',
      version: json['version'] as String? ?? '1.0.0',
      uptimeSeconds: (json['uptimeSeconds'] as num?)?.toInt() ?? 0,
      serverTime: json['serverTime'] != null
          ? DateTime.tryParse(json['serverTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      components: (json['components'] as Map<String, dynamic>?) ?? {},
      metrics: (json['metrics'] as Map<String, dynamic>?) ?? {},
    );
  }
}
