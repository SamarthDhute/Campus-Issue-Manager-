package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.IssueAttachment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface IssueAttachmentRepository extends JpaRepository<IssueAttachment, UUID> {
    List<IssueAttachment> findByIssueIdOrderByCreatedAtDesc(UUID issueId);
}
