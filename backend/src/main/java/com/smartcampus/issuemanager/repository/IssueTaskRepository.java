package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.IssueTask;
import com.smartcampus.issuemanager.entity.TaskStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface IssueTaskRepository extends JpaRepository<IssueTask, UUID> {

    List<IssueTask> findByIssueIdOrderByCreatedAtAsc(UUID issueId);

    List<IssueTask> findByIssueIdAndStatus(UUID issueId, TaskStatus status);

    List<IssueTask> findByOwnerIdOrderByCreatedAtDesc(UUID ownerId);
}
