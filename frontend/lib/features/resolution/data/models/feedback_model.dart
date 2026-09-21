enum ResolutionQuality {
  poor,
  average,
  satisfied,
  excellent,
}

extension ResolutionQualityExtension on ResolutionQuality {
  String get value {
    switch (this) {
      case ResolutionQuality.poor:
        return 'POOR';
      case ResolutionQuality.average:
        return 'AVERAGE';
      case ResolutionQuality.satisfied:
        return 'SATISFIED';
      case ResolutionQuality.excellent:
        return 'EXCELLENT';
    }
  }

  String get label {
    switch (this) {
      case ResolutionQuality.poor:
        return 'Poor';
      case ResolutionQuality.average:
        return 'Average';
      case ResolutionQuality.satisfied:
        return 'Satisfied';
      case ResolutionQuality.excellent:
        return 'Excellent';
    }
  }

  static ResolutionQuality fromString(String? quality) {
    switch (quality?.toUpperCase()) {
      case 'POOR':
        return ResolutionQuality.poor;
      case 'AVERAGE':
        return ResolutionQuality.average;
      case 'EXCELLENT':
        return ResolutionQuality.excellent;
      default:
        return ResolutionQuality.satisfied;
    }
  }
}

class FeedbackModel {
  final String id;
  final String issueId;
  final String? submittedByUserId;
  final String? submittedByName;
  final int rating;
  final String? feedbackText;
  final ResolutionQuality resolutionQuality;
  final String? reopenedReason;
  final DateTime? createdAt;

  FeedbackModel({
    required this.id,
    required this.issueId,
    this.submittedByUserId,
    this.submittedByName,
    required this.rating,
    this.feedbackText,
    this.resolutionQuality = ResolutionQuality.satisfied,
    this.reopenedReason,
    this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      submittedByUserId: json['submittedByUserId'] as String?,
      submittedByName: json['submittedByName'] as String?,
      rating: json['rating'] as int? ?? 5,
      feedbackText: json['feedbackText'] as String?,
      resolutionQuality: ResolutionQualityExtension.fromString(json['resolutionQuality'] as String?),
      reopenedReason: json['reopenedReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issueId': issueId,
      'submittedByUserId': submittedByUserId,
      'submittedByName': submittedByName,
      'rating': rating,
      'feedbackText': feedbackText,
      'resolutionQuality': resolutionQuality.value,
      'reopenedReason': reopenedReason,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
