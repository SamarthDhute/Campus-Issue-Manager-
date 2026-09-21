import 'package:flutter/material.dart';
import '../data/models/attachment_model.dart';
import '../data/models/evidence_model.dart';
import '../data/models/feedback_model.dart';
import '../data/repositories/attachment_repository.dart';
import '../data/repositories/resolution_repository.dart';

class ResolutionProvider extends ChangeNotifier {
  final AttachmentRepository _attachmentRepository;
  final ResolutionRepository _resolutionRepository;

  List<AttachmentModel> _attachments = [];
  List<EvidenceModel> _evidenceList = [];
  FeedbackModel? _feedback;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  ResolutionProvider({
    AttachmentRepository? attachmentRepository,
    ResolutionRepository? resolutionRepository,
  })  : _attachmentRepository = attachmentRepository ?? AttachmentRepository(),
        _resolutionRepository = resolutionRepository ?? ResolutionRepository();

  List<AttachmentModel> get attachments => _attachments;
  List<EvidenceModel> get evidenceList => _evidenceList;
  FeedbackModel? get feedback => _feedback;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  List<EvidenceModel> get beforeRepairEvidence =>
      _evidenceList.where((e) => e.evidenceType == EvidenceType.beforeRepair).toList();

  List<EvidenceModel> get afterRepairEvidence =>
      _evidenceList.where((e) => e.evidenceType == EvidenceType.afterRepair).toList();

  Future<void> loadAllResolutionData(String issueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _attachmentRepository.getAttachments(issueId),
        _resolutionRepository.getEvidence(issueId),
        _resolutionRepository.getFeedback(issueId),
      ]);

      _attachments = results[0] as List<AttachmentModel>;
      _evidenceList = results[1] as List<EvidenceModel>;
      _feedback = results[2] as FeedbackModel?;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AttachmentModel?> uploadAttachment({
    required String issueId,
    required List<int> fileBytes,
    required String fileName,
    String? messageId,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uploaded = await _attachmentRepository.uploadAttachment(
        issueId: issueId,
        fileBytes: fileBytes,
        fileName: fileName,
        messageId: messageId,
      );
      _attachments.insert(0, uploaded);
      return uploaded;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<EvidenceModel?> uploadEvidence({
    required String issueId,
    required EvidenceType evidenceType,
    required String fileUrl,
    required String fileName,
    String? notes,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uploaded = await _resolutionRepository.uploadEvidence(
        issueId: issueId,
        evidenceType: evidenceType,
        fileUrl: fileUrl,
        fileName: fileName,
        notes: notes,
      );
      _evidenceList.insert(0, uploaded);
      return uploaded;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<EvidenceModel?> uploadEvidenceWithFile({
    required String issueId,
    required EvidenceType evidenceType,
    required List<int> fileBytes,
    required String fileName,
    String? notes,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final attachment = await _attachmentRepository.uploadAttachment(
        issueId: issueId,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      final uploaded = await _resolutionRepository.uploadEvidence(
        issueId: issueId,
        evidenceType: evidenceType,
        fileUrl: attachment.fileUrl,
        fileName: attachment.fileName,
        fileSize: attachment.sizeBytes,
        mimeType: attachment.contentType,
        notes: notes,
      );
      _evidenceList.insert(0, uploaded);
      return uploaded;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> submitFeedback({
    required String issueId,
    required int rating,
    String? feedbackText,
    ResolutionQuality resolutionQuality = ResolutionQuality.satisfied,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final submitted = await _resolutionRepository.submitFeedback(
        issueId: issueId,
        rating: rating,
        feedbackText: feedbackText,
        resolutionQuality: resolutionQuality,
      );
      _feedback = submitted;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reopenIssue({
    required String issueId,
    required String reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _resolutionRepository.reopenIssue(
        issueId: issueId,
        reason: reason,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
