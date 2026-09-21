package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.entity.EvidenceType;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.FeedbackService;
import com.smartcampus.issuemanager.service.ResolutionEvidenceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/issues/{issueId}")
@RequiredArgsConstructor
public class ResolutionController {

    private final ResolutionEvidenceService evidenceService;
    private final FeedbackService feedbackService;

    @PostMapping("/evidence")
    public ResponseEntity<EvidenceResponse> uploadEvidence(
            @PathVariable UUID issueId,
            @Valid @RequestBody UploadEvidenceRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {

        EvidenceResponse response = evidenceService.uploadEvidence(issueId, request, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/evidence")
    public ResponseEntity<List<EvidenceResponse>> getEvidence(
            @PathVariable UUID issueId,
            @RequestParam(value = "type", required = false) EvidenceType type) {

        if (type != null) {
            return ResponseEntity.ok(evidenceService.getEvidenceByIssueIdAndType(issueId, type));
        }
        return ResponseEntity.ok(evidenceService.getEvidenceByIssueId(issueId));
    }

    @PostMapping("/feedback")
    public ResponseEntity<FeedbackResponse> submitFeedback(
            @PathVariable UUID issueId,
            @Valid @RequestBody SubmitFeedbackRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {

        FeedbackResponse response = feedbackService.submitFeedback(issueId, request, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/reopen")
    public ResponseEntity<IssueResponse> reopenIssue(
            @PathVariable UUID issueId,
            @Valid @RequestBody ReopenIssueRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {

        IssueResponse response = feedbackService.reopenIssue(issueId, request, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/feedback")
    public ResponseEntity<FeedbackResponse> getFeedback(@PathVariable UUID issueId) {
        FeedbackResponse response = feedbackService.getFeedbackByIssueId(issueId);
        if (response == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(response);
    }
}
