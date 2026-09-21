enum EvidenceType {
  beforeRepair,
  afterRepair,
  receipt,
  inspection,
  other,
}

extension EvidenceTypeExtension on EvidenceType {
  String get value {
    switch (this) {
      case EvidenceType.beforeRepair:
        return 'BEFORE_REPAIR';
      case EvidenceType.afterRepair:
        return 'AFTER_REPAIR';
      case EvidenceType.receipt:
        return 'RECEIPT';
      case EvidenceType.inspection:
        return 'INSPECTION';
      case EvidenceType.other:
        return 'OTHER';
    }
  }

  String get label {
    switch (this) {
      case EvidenceType.beforeRepair:
        return 'Before Repair';
      case EvidenceType.afterRepair:
        return 'After Repair';
      case EvidenceType.receipt:
        return 'Receipt / Invoices';
      case EvidenceType.inspection:
        return 'Inspection Report';
      case EvidenceType.other:
        return 'General Evidence';
    }
  }

  static EvidenceType fromString(String? type) {
    switch (type?.toUpperCase()) {
      case 'BEFORE_REPAIR':
        return EvidenceType.beforeRepair;
      case 'AFTER_REPAIR':
        return EvidenceType.afterRepair;
      case 'RECEIPT':
        return EvidenceType.receipt;
      case 'INSPECTION':
        return EvidenceType.inspection;
      default:
        return EvidenceType.other;
    }
  }
}

class EvidenceModel {
  final String id;
  final String issueId;
  final String? uploadedByUserId;
  final String? uploadedByName;
  final EvidenceType evidenceType;
  final String fileUrl;
  final String fileName;
  final int? fileSize;
  final String? mimeType;
  final String? notes;
  final DateTime? createdAt;

  EvidenceModel({
    required this.id,
    required this.issueId,
    this.uploadedByUserId,
    this.uploadedByName,
    required this.evidenceType,
    required this.fileUrl,
    required this.fileName,
    this.fileSize,
    this.mimeType,
    this.notes,
    this.createdAt,
  });

  factory EvidenceModel.fromJson(Map<String, dynamic> json) {
    return EvidenceModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      uploadedByUserId: json['uploadedByUserId'] as String?,
      uploadedByName: json['uploadedByName'] as String?,
      evidenceType: EvidenceTypeExtension.fromString(json['evidenceType'] as String?),
      fileUrl: json['fileUrl'] as String? ?? '',
      fileName: json['fileName'] as String? ?? 'evidence',
      fileSize: json['fileSize'] as int?,
      mimeType: json['mimeType'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issueId': issueId,
      'uploadedByUserId': uploadedByUserId,
      'uploadedByName': uploadedByName,
      'evidenceType': evidenceType.value,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
