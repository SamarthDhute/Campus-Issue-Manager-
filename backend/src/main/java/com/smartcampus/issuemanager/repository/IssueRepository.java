package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.Issue;
import com.smartcampus.issuemanager.entity.IssueStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface IssueRepository extends JpaRepository<Issue, UUID>, JpaSpecificationExecutor<Issue> {

    Optional<Issue> findByIssueNumber(String issueNumber);

    List<Issue> findByRequesterIdOrderByCreatedAtDesc(UUID requesterId);

    List<Issue> findByAssignedUserIdOrderByCreatedAtDesc(UUID assignedUserId);

    List<Issue> findByAssignedTeamIdOrderByCreatedAtDesc(UUID assignedTeamId);

    List<Issue> findByStatusOrderByCreatedAtDesc(IssueStatus status);

    @Query("SELECT COUNT(i) FROM Issue i WHERE i.issueNumber LIKE CONCAT('ISS-', :year, '-%')")
    long countByYear(@Param("year") String year);
}
