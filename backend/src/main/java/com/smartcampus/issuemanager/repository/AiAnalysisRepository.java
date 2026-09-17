package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.AiAnalysis;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AiAnalysisRepository extends JpaRepository<AiAnalysis, UUID> {
    Optional<AiAnalysis> findTopByIssueIdOrderByCreatedAtDesc(UUID issueId);
    List<AiAnalysis> findByIssueIdOrderByCreatedAtDesc(UUID issueId);
}
