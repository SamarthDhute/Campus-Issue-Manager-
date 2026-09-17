package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.Escalation;
import com.smartcampus.issuemanager.entity.EscalationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface EscalationRepository extends JpaRepository<Escalation, UUID> {

    List<Escalation> findByIssueIdOrderByTriggeredAtDesc(UUID issueId);

    List<Escalation> findByIssueIdAndStatus(UUID issueId, EscalationStatus status);

    Optional<Escalation> findFirstByIssueIdAndStatusOrderByLevelDesc(UUID issueId, EscalationStatus status);

    boolean existsByIssueIdAndLevelAndStatus(UUID issueId, Integer level, EscalationStatus status);
}
