package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.entity.*;
import com.smartcampus.issuemanager.exception.BadRequestException;
import com.smartcampus.issuemanager.exception.ResourceNotFoundException;
import com.smartcampus.issuemanager.integration.ai.GeminiClient;
import com.smartcampus.issuemanager.repository.*;
import com.smartcampus.issuemanager.service.AiCaseIntelligenceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiCaseIntelligenceServiceImpl implements AiCaseIntelligenceService {

    private final IssueRepository issueRepository;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final AiAnalysisRepository aiAnalysisRepository;
    private final AiRecommendationRepository aiRecommendationRepository;
    private final IssueRelationshipRepository issueRelationshipRepository;
    private final IssueTimelineEventRepository timelineEventRepository;
    private final GeminiClient geminiClient;

    @Override
    @Transactional
    public AiAnalysisResponse analyzeIssue(UUID issueId, UUID userId) {
        Issue issue = issueRepository.findById(issueId)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found with ID: " + issueId));

        String categoryName = issue.getCategory() != null ? issue.getCategory().getName() : "General";

        GeminiClient.AiRawAnalysisResult rawResult = geminiClient.analyzeIssue(
                issue.getTitle(),
                issue.getDescription(),
                categoryName,
                issue.getLocation()
        );

        AiAnalysis analysis = AiAnalysis.builder()
                .issue(issue)
                .status(AiAnalysisStatus.COMPLETED)
                .model(rawResult.getModelUsed())
                .summary(rawResult.getSummary())
                .missingInformation(rawResult.getMissingInformation())
                .confidence(rawResult.getOverallConfidence())
                .completedAt(OffsetDateTime.now())
                .build();

        AiAnalysis savedAnalysis = aiAnalysisRepository.save(analysis);

        // 1. Priority Recommendation
        AiRecommendation priorityRec = AiRecommendation.builder()
                .analysis(savedAnalysis)
                .issue(issue)
                .recommendationType(RecommendationType.PRIORITY)
                .suggestedValue(rawResult.getRecommendedPriority())
                .confidence(rawResult.getPriorityConfidence())
                .explanation(rawResult.getPriorityExplanation())
                .decision(RecommendationDecision.PENDING)
                .build();
        aiRecommendationRepository.save(priorityRec);

        // 2. Next Action Recommendation
        AiRecommendation actionRec = AiRecommendation.builder()
                .analysis(savedAnalysis)
                .issue(issue)
                .recommendationType(RecommendationType.NEXT_ACTION)
                .suggestedValue(rawResult.getNextAction())
                .confidence(rawResult.getNextActionConfidence())
                .explanation("Recommended operational action based on facility triage rules.")
                .decision(RecommendationDecision.PENDING)
                .build();
        aiRecommendationRepository.save(actionRec);

        // 3. Detect duplicate / related candidates
        detectAndRecordRelationships(issue);

        // 4. Record Timeline event
        User actor = userId != null ? userRepository.findById(userId).orElse(null) : null;
        IssueTimelineEvent event = IssueTimelineEvent.builder()
                .issue(issue)
                .eventType(TimelineEventType.AI_ANALYZED)
                .actor(actor)
                .description("AI Case Intelligence analysis completed (" + rawResult.getModelUsed() + " with confidence " + rawResult.getOverallConfidence() + ")")
                .build();
        timelineEventRepository.save(event);

        return getLatestAnalysis(issueId);
    }

    @Override
    @Transactional(readOnly = true)
    public AiAnalysisResponse getLatestAnalysis(UUID issueId) {
        Issue issue = issueRepository.findById(issueId)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found with ID: " + issueId));

        AiAnalysis analysis = aiAnalysisRepository.findTopByIssueIdOrderByCreatedAtDesc(issueId)
                .orElseGet(() -> {
                    // Generate baseline analysis on demand if missing
                    GeminiClient.AiRawAnalysisResult raw = geminiClient.performHeuristicAnalysis(
                            issue.getTitle(),
                            issue.getDescription(),
                            issue.getCategory() != null ? issue.getCategory().getName() : "General",
                            issue.getLocation()
                    );
                    AiAnalysis generated = AiAnalysis.builder()
                            .issue(issue)
                            .status(AiAnalysisStatus.COMPLETED)
                            .model(raw.getModelUsed())
                            .summary(raw.getSummary())
                            .missingInformation(raw.getMissingInformation())
                            .confidence(raw.getOverallConfidence())
                            .completedAt(OffsetDateTime.now())
                            .build();
                    return aiAnalysisRepository.save(generated);
                });

        List<AiRecommendation> recs = aiRecommendationRepository.findByAnalysisId(analysis.getId());

        List<AiRecommendationResponse> recResponses = recs.stream()
                .map(this::mapRecommendation)
                .collect(Collectors.toList());

        return AiAnalysisResponse.builder()
                .id(analysis.getId())
                .issueId(issue.getId())
                .issueNumber(issue.getIssueNumber())
                .status(analysis.getStatus())
                .model(analysis.getModel())
                .summary(analysis.getSummary())
                .missingInformation(analysis.getMissingInformation())
                .confidence(analysis.getConfidence())
                .recommendations(recResponses)
                .createdAt(analysis.getCreatedAt())
                .completedAt(analysis.getCompletedAt())
                .build();
    }

    @Override
    @Transactional
    public AiRecommendationResponse recordDecision(UUID issueId, UUID recommendationId, AiDecisionRequest request, UUID userId) {
        AiRecommendation rec = aiRecommendationRepository.findById(recommendationId)
                .orElseThrow(() -> new ResourceNotFoundException("Recommendation not found with ID: " + recommendationId));

        if (!rec.getIssue().getId().equals(issueId)) {
            throw new BadRequestException("Recommendation does not belong to issue ID: " + issueId);
        }

        User decidedBy = userId != null ? userRepository.findById(userId).orElse(null) : null;

        rec.setDecision(request.getDecision());
        rec.setDecidedBy(decidedBy);
        rec.setDecidedAt(OffsetDateTime.now());

        Issue issue = rec.getIssue();

        if (request.getDecision() == RecommendationDecision.ACCEPTED) {
            if (rec.getRecommendationType() == RecommendationType.PRIORITY) {
                try {
                    IssuePriority newPriority = IssuePriority.valueOf(rec.getSuggestedValue().toUpperCase());
                    IssuePriority oldPriority = issue.getPriority();
                    issue.setPriority(newPriority);
                    issueRepository.save(issue);

                    String desc = "AI Recommended priority " + newPriority + " accepted by " +
                            (decidedBy != null ? decidedBy.getDisplayName() : "Staff");
                    IssueTimelineEvent event = IssueTimelineEvent.builder()
                            .issue(issue)
                            .eventType(TimelineEventType.STATUS_CHANGED)
                            .actor(decidedBy)
                            .description(desc)
                            .build();
                    timelineEventRepository.save(event);
                } catch (IllegalArgumentException e) {
                    log.warn("Could not parse priority enum from suggested value: {}", rec.getSuggestedValue());
                }
            }
        }

        AiRecommendation saved = aiRecommendationRepository.save(rec);
        return mapRecommendation(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<RelatedIssueResponse> getRelatedIssues(UUID issueId) {
        issueRepository.findById(issueId)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found with ID: " + issueId));

        List<IssueRelationship> relationships = issueRelationshipRepository.findAllByIssueIdOrRelatedIssueId(issueId);

        return relationships.stream().map(rel -> {
            Issue other = rel.getIssue().getId().equals(issueId) ? rel.getRelatedIssue() : rel.getIssue();
            return RelatedIssueResponse.builder()
                    .relationshipId(rel.getId())
                    .issueId(other.getId())
                    .issueNumber(other.getIssueNumber())
                    .title(other.getTitle())
                    .location(other.getLocation())
                    .categoryName(other.getCategory() != null ? other.getCategory().getName() : "General")
                    .status(other.getStatus())
                    .priority(other.getPriority())
                    .relationshipType(rel.getRelationshipType())
                    .confidence(rel.getConfidence())
                    .explanation(rel.getExplanation())
                    .createdAt(rel.getCreatedAt())
                    .build();
        }).collect(Collectors.toList());
    }

    private void detectAndRecordRelationships(Issue target) {
        List<Issue> allIssues = issueRepository.findAll();
        for (Issue existing : allIssues) {
            if (existing.getId().equals(target.getId())) continue;

            boolean sameCategory = target.getCategory() != null && existing.getCategory() != null &&
                    target.getCategory().getId().equals(existing.getCategory().getId());
            boolean sameLocation = target.getLocation() != null && existing.getLocation() != null &&
                    (target.getLocation().equalsIgnoreCase(existing.getLocation()) ||
                     target.getLocation().contains(existing.getLocation()) ||
                     existing.getLocation().contains(target.getLocation()));

            if (sameLocation && sameCategory) {
                if (!issueRelationshipRepository.existsByIssueIdAndRelatedIssueId(target.getId(), existing.getId()) &&
                    !issueRelationshipRepository.existsByIssueIdAndRelatedIssueId(existing.getId(), target.getId())) {
                    
                    IssueRelationship rel = IssueRelationship.builder()
                            .issue(target)
                            .relatedIssue(existing)
                            .relationshipType(RelationshipType.DUPLICATE_CANDIDATE)
                            .confidence(new BigDecimal("0.8800"))
                            .explanation("Potential duplicate or correlated incident reported at the same campus location under identical category.")
                            .build();
                    issueRelationshipRepository.save(rel);
                }
            }
        }
    }

    private AiRecommendationResponse mapRecommendation(AiRecommendation rec) {
        return AiRecommendationResponse.builder()
                .id(rec.getId())
                .analysisId(rec.getAnalysis().getId())
                .issueId(rec.getIssue().getId())
                .recommendationType(rec.getRecommendationType())
                .suggestedValue(rec.getSuggestedValue())
                .confidence(rec.getConfidence())
                .explanation(rec.getExplanation())
                .decision(rec.getDecision())
                .decidedById(rec.getDecidedBy() != null ? rec.getDecidedBy().getId() : null)
                .decidedByName(rec.getDecidedBy() != null ? rec.getDecidedBy().getDisplayName() : null)
                .decidedAt(rec.getDecidedAt())
                .createdAt(rec.getCreatedAt())
                .build();
    }
}
