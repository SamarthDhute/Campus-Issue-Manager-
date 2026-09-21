package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.EvidenceResponse;
import com.smartcampus.issuemanager.dto.UploadEvidenceRequest;
import com.smartcampus.issuemanager.entity.EvidenceType;

import java.util.List;
import java.util.UUID;

public interface ResolutionEvidenceService {

    EvidenceResponse uploadEvidence(UUID issueId, UploadEvidenceRequest request, UUID currentUserId);

    List<EvidenceResponse> getEvidenceByIssueId(UUID issueId);

    List<EvidenceResponse> getEvidenceByIssueIdAndType(UUID issueId, EvidenceType evidenceType);
}
