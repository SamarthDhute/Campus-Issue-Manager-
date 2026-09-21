package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.RiskEvent;
import com.smartcampus.issuemanager.entity.RiskType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RiskEventRepository extends JpaRepository<RiskEvent, UUID> {

    List<RiskEvent> findByIssueIdOrderByDetectedAtDesc(UUID issueId);

    List<RiskEvent> findByIssueIdAndResolvedAtIsNull(UUID issueId);

    Optional<RiskEvent> findByIssueIdAndRiskTypeAndResolvedAtIsNull(UUID issueId, RiskType riskType);
}
