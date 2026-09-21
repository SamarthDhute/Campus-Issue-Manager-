package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.Assignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AssignmentRepository extends JpaRepository<Assignment, UUID> {

    List<Assignment> findByIssueIdOrderByAssignedAtDesc(UUID issueId);

    Optional<Assignment> findByIssueIdAndEndedAtIsNull(UUID issueId);

    List<Assignment> findByUserIdAndEndedAtIsNull(UUID userId);

    List<Assignment> findByUserId(UUID userId);
}
