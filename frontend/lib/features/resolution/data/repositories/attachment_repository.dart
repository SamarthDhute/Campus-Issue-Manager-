import 'package:smart_campus_issue_manager/core/network/api_client.dart';
import '../models/attachment_model.dart';

class AttachmentRepository {
  final ApiClient _apiClient;

  AttachmentRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<AttachmentModel> uploadAttachment({
    required String issueId,
    required List<int> fileBytes,
    required String fileName,
    String? messageId,
  }) async {
    final fields = <String, String>{};
    if (messageId != null) {
      fields['messageId'] = messageId;
    }

    final response = await _apiClient.uploadMultipart(
      '/issues/$issueId/attachments',
      fileBytes: fileBytes,
      filename: fileName,
      fields: fields.isNotEmpty ? fields : null,
    );

    return AttachmentModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<AttachmentModel>> getAttachments(String issueId) async {
    final response = await _apiClient.get('/issues/$issueId/attachments');
    if (response is List) {
      return response.map((item) => AttachmentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
