package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.EvidenceType;
import com.smartcampus.issuemanager.entity.ResolutionEvidence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ResolutionEvidenceRepository extends JpaRepository<ResolutionEvidence, UUID> {
    List<ResolutionEvidence> findByIssueIdOrderByCreatedAtDesc(UUID issueId);
    List<ResolutionEvidence> findByIssueIdAndEvidenceTypeOrderByCreatedAtDesc(UUID issueId, EvidenceType evidenceType);
    long countByIssueIdAndEvidenceType(UUID issueId, EvidenceType evidenceType);
}
