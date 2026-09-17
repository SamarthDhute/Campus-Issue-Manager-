package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.AiAnalysisResponse;
import com.smartcampus.issuemanager.dto.AiDecisionRequest;
import com.smartcampus.issuemanager.dto.AiRecommendationResponse;
import com.smartcampus.issuemanager.dto.RelatedIssueResponse;

import java.util.List;
import java.util.UUID;

public interface AiCaseIntelligenceService {

    AiAnalysisResponse analyzeIssue(UUID issueId, UUID userId);

    AiAnalysisResponse getLatestAnalysis(UUID issueId);

    AiRecommendationResponse recordDecision(UUID issueId, UUID recommendationId, AiDecisionRequest request, UUID userId);

    List<RelatedIssueResponse> getRelatedIssues(UUID issueId);
}
