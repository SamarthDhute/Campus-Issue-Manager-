package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.AiRecommendation;
import com.smartcampus.issuemanager.entity.RecommendationDecision;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AiRecommendationRepository extends JpaRepository<AiRecommendation, UUID> {
    List<AiRecommendation> findByAnalysisId(UUID analysisId);
    List<AiRecommendation> findByIssueIdOrderByCreatedAtDesc(UUID issueId);
    List<AiRecommendation> findByIssueIdAndDecision(UUID issueId, RecommendationDecision decision);
}
