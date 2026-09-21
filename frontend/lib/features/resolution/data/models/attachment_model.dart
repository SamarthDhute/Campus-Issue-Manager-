class AttachmentModel {
  final String id;
  final String issueId;
  final String? messageId;
  final String? uploadedByUserId;
  final String? uploadedByName;
  final String fileName;
  final String? contentType;
  final int? sizeBytes;
  final String fileUrl;
  final String? thumbnailUrl;
  final DateTime? createdAt;

  AttachmentModel({
    required this.id,
    required this.issueId,
    this.messageId,
    this.uploadedByUserId,
    this.uploadedByName,
    required this.fileName,
    this.contentType,
    this.sizeBytes,
    required this.fileUrl,
    this.thumbnailUrl,
    this.createdAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] as String? ?? '',
      issueId: json['issueId'] as String? ?? '',
      messageId: json['messageId'] as String?,
      uploadedByUserId: json['uploadedByUserId'] as String?,
      uploadedByName: json['uploadedByName'] as String?,
      fileName: json['fileName'] as String? ?? 'attachment',
      contentType: json['contentType'] as String?,
      sizeBytes: json['sizeBytes'] as int?,
      fileUrl: json['fileUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issueId': issueId,
      'messageId': messageId,
      'uploadedByUserId': uploadedByUserId,
      'uploadedByName': uploadedByName,
      'fileName': fileName,
      'contentType': contentType,
      'sizeBytes': sizeBytes,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
