package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.InternalNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface InternalNoteRepository extends JpaRepository<InternalNote, UUID> {

    List<InternalNote> findByIssueIdOrderByCreatedAtDesc(UUID issueId);
}
