package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.EvidenceResponse;
import com.smartcampus.issuemanager.dto.UploadEvidenceRequest;
import com.smartcampus.issuemanager.entity.EvidenceType;
import com.smartcampus.issuemanager.entity.Issue;
import com.smartcampus.issuemanager.entity.ResolutionEvidence;
import com.smartcampus.issuemanager.entity.User;
import com.smartcampus.issuemanager.exception.ResourceNotFoundException;
import com.smartcampus.issuemanager.repository.IssueRepository;
import com.smartcampus.issuemanager.repository.ResolutionEvidenceRepository;
import com.smartcampus.issuemanager.repository.UserRepository;
import com.smartcampus.issuemanager.service.ResolutionEvidenceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ResolutionEvidenceServiceImpl implements ResolutionEvidenceService {

    private final ResolutionEvidenceRepository evidenceRepository;
    private final IssueRepository issueRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public EvidenceResponse uploadEvidence(UUID issueId, UploadEvidenceRequest request, UUID currentUserId) {
        Issue issue = issueRepository.findById(issueId)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found with ID: " + issueId));

        User currentUser = userRepository.findById(currentUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + currentUserId));

        ResolutionEvidence evidence = ResolutionEvidence.builder()
                .issue(issue)
                .uploadedBy(currentUser)
                .evidenceType(request.getEvidenceType())
                .fileUrl(request.getFileUrl())
                .fileName(request.getFileName())
                .fileSize(request.getFileSize() != null ? request.getFileSize() : 0L)
                .mimeType(request.getMimeType() != null ? request.getMimeType() : "image/jpeg")
                .notes(request.getNotes())
                .build();

        ResolutionEvidence saved = evidenceRepository.save(evidence);
        log.info("Saved resolution evidence {} ({}) for issue {}", saved.getId(), saved.getEvidenceType(), issue.getIssueNumber());

        return mapToResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EvidenceResponse> getEvidenceByIssueId(UUID issueId) {
        return evidenceRepository.findByIssueIdOrderByCreatedAtDesc(issueId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<EvidenceResponse> getEvidenceByIssueIdAndType(UUID issueId, EvidenceType evidenceType) {
        return evidenceRepository.findByIssueIdAndEvidenceTypeOrderByCreatedAtDesc(issueId, evidenceType)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private EvidenceResponse mapToResponse(ResolutionEvidence ev) {
        return EvidenceResponse.builder()
                .id(ev.getId())
                .issueId(ev.getIssue().getId())
                .uploadedByUserId(ev.getUploadedBy().getId())
                .uploadedByName(ev.getUploadedBy().getDisplayName())
                .evidenceType(ev.getEvidenceType())
                .fileUrl(ev.getFileUrl())
                .fileName(ev.getFileName())
                .fileSize(ev.getFileSize())
                .mimeType(ev.getMimeType())
                .notes(ev.getNotes())
                .createdAt(ev.getCreatedAt())
                .build();
    }
}
