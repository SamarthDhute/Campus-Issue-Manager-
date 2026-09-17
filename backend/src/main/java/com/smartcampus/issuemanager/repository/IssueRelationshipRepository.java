package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.IssueRelationship;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface IssueRelationshipRepository extends JpaRepository<IssueRelationship, UUID> {
    
    @Query("SELECT r FROM IssueRelationship r WHERE r.issue.id = :issueId OR r.relatedIssue.id = :issueId ORDER BY r.confidence DESC")
    List<IssueRelationship> findAllByIssueIdOrRelatedIssueId(@Param("issueId") UUID issueId);

    boolean existsByIssueIdAndRelatedIssueId(UUID issueId, UUID relatedIssueId);
}
