package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.Investigation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface InvestigationRepository extends JpaRepository<Investigation, UUID> {

    List<Investigation> findByIssueIdOrderByCreatedAtDesc(UUID issueId);

    Optional<Investigation> findTopByIssueIdOrderByCreatedAtDesc(UUID issueId);
}
