class TimelineEventModel {
  final String id;
  final String eventType;
  final String? actorId;
  final String actorName;
  final String actorRole;
  final String description;
  final DateTime createdAt;

  TimelineEventModel({
    required this.id,
    required this.eventType,
    this.actorId,
    required this.actorName,
    required this.actorRole,
    required this.description,
    required this.createdAt,
  });

  factory TimelineEventModel.fromJson(Map<String, dynamic> json) {
    return TimelineEventModel(
      id: json['id'] as String,
      eventType: json['eventType'] as String? ?? 'STATUS_CHANGED',
      actorId: json['actorId'] as String?,
      actorName: json['actorName'] as String? ?? 'System',
      actorRole: json['actorRole'] as String? ?? 'SYSTEM',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType,
      'actorId': actorId,
      'actorName': actorName,
      'actorRole': actorRole,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
