class AiAnalysisModel {
  final String id;
  final String issueId;
  final String? issueNumber;
  final String status;
  final String model;
  final String? summary;
  final String? missingInformation;
  final double confidence;
  final List<AiRecommendationModel> recommendations;
  final DateTime? createdAt;
  final DateTime? completedAt;

  AiAnalysisModel({
    required this.id,
    required this.issueId,
    this.issueNumber,
    required this.status,
    required this.model,
    this.summary,
    this.missingInformation,
    required this.confidence,
    this.recommendations = const [],
    this.createdAt,
    this.completedAt,
  });

  factory AiAnalysisModel.fromJson(Map<String, dynamic> json) {
    return AiAnalysisModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      issueNumber: json['issueNumber'] as String?,
      status: json['status'] as String? ?? 'COMPLETED',
      model: json['model'] as String? ?? 'gemini-1.5-flash',
      summary: json['summary'] as String?,
      missingInformation: json['missingInformation'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.85,
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => AiRecommendationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'] as String) : null,
    );
  }
}

class AiRecommendationModel {
  final String id;
  final String? analysisId;
  final String? issueId;
  final String recommendationType; // PRIORITY, NEXT_ACTION, CATEGORY
  final String suggestedValue;
  final double confidence;
  final String? explanation;
  final String decision; // PENDING, ACCEPTED, REJECTED, OVERRIDDEN
  final String? decidedById;
  final String? decidedByName;
  final DateTime? decidedAt;
  final DateTime? createdAt;

  AiRecommendationModel({
    required this.id,
    this.analysisId,
    this.issueId,
    required this.recommendationType,
    required this.suggestedValue,
    required this.confidence,
    this.explanation,
    required this.decision,
    this.decidedById,
    this.decidedByName,
    this.decidedAt,
    this.createdAt,
  });

  factory AiRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AiRecommendationModel(
      id: json['id'] as String? ?? '',
      analysisId: json['analysisId'] as String?,
      issueId: json['issueId'] as String?,
      recommendationType: json['recommendationType'] as String? ?? 'PRIORITY',
      suggestedValue: json['suggestedValue'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.85,
      explanation: json['explanation'] as String?,
      decision: json['decision'] as String? ?? 'PENDING',
      decidedById: json['decidedById'] as String?,
      decidedByName: json['decidedByName'] as String?,
      decidedAt: json['decidedAt'] != null ? DateTime.tryParse(json['decidedAt'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }
}

class RelatedIssueModel {
  final String relationshipId;
  final String issueId;
  final String issueNumber;
  final String title;
  final String location;
  final String categoryName;
  final String status;
  final String priority;
  final String relationshipType;
  final double confidence;
  final String? explanation;
  final DateTime? createdAt;

  RelatedIssueModel({
    required this.relationshipId,
    required this.issueId,
    required this.issueNumber,
    required this.title,
    required this.location,
    required this.categoryName,
    required this.status,
    required this.priority,
    required this.relationshipType,
    required this.confidence,
    this.explanation,
    this.createdAt,
  });

  factory RelatedIssueModel.fromJson(Map<String, dynamic> json) {
    return RelatedIssueModel(
      relationshipId: json['relationshipId'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      issueNumber: json['issueNumber'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      status: json['status'] as String? ?? 'REPORTED',
      priority: json['priority'] as String? ?? 'MEDIUM',
      relationshipType: json['relationshipType'] as String? ?? 'DUPLICATE_CANDIDATE',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.80,
      explanation: json['explanation'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }
}
