package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.AiAnalysisResponse;
import com.smartcampus.issuemanager.dto.AiDecisionRequest;
import com.smartcampus.issuemanager.dto.AiRecommendationResponse;
import com.smartcampus.issuemanager.dto.RelatedIssueResponse;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.AiCaseIntelligenceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/issues")
@RequiredArgsConstructor
@Tag(name = "AI Case Intelligence", description = "AI analysis, automated summarization, and human decision loop APIs")
public class AiController {

    private final AiCaseIntelligenceService aiService;

    @PostMapping("/{id}/ai/analyze")
    @Operation(summary = "Trigger or retry AI analysis for a specific issue")
    public ResponseEntity<AiAnalysisResponse> triggerAnalysis(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        UUID userId = currentUser != null ? currentUser.getId() : null;
        AiAnalysisResponse response = aiService.analyzeIssue(id, userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/ai")
    @Operation(summary = "Get latest AI analysis, summary and recommendations for an issue")
    public ResponseEntity<AiAnalysisResponse> getAnalysis(@PathVariable UUID id) {
        AiAnalysisResponse response = aiService.getLatestAnalysis(id);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/ai/recommendations/{recommendationId}/decision")
    @Operation(summary = "Record human accept/reject/override decision on an AI recommendation")
    public ResponseEntity<AiRecommendationResponse> recordDecision(
            @PathVariable UUID id,
            @PathVariable UUID recommendationId,
            @Valid @RequestBody AiDecisionRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        UUID userId = currentUser != null ? currentUser.getId() : null;
        AiRecommendationResponse response = aiService.recordDecision(id, recommendationId, request, userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/related")
    @Operation(summary = "Get related or duplicate issue candidates")
    public ResponseEntity<List<RelatedIssueResponse>> getRelatedIssues(@PathVariable UUID id) {
        List<RelatedIssueResponse> response = aiService.getRelatedIssues(id);
        return ResponseEntity.ok(response);
    }
}
