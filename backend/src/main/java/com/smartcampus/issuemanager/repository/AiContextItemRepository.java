package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.AiContextItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AiContextItemRepository extends JpaRepository<AiContextItem, UUID> {
    List<AiContextItem> findByIssueIdOrderByCreatedAtAsc(UUID issueId);
}
