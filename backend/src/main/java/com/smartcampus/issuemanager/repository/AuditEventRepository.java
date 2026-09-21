package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.AuditEvent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AuditEventRepository extends JpaRepository<AuditEvent, UUID> {

    List<AuditEvent> findByEntityTypeAndEntityIdOrderByCreatedAtDesc(String entityType, UUID entityId);

    Page<AuditEvent> findAllByOrderByCreatedAtDesc(Pageable pageable);

    Page<AuditEvent> findByEntityTypeOrderByCreatedAtDesc(String entityType, Pageable pageable);

    Page<AuditEvent> findByEventTypeOrderByCreatedAtDesc(String eventType, Pageable pageable);

    Page<AuditEvent> findByActorIdOrderByCreatedAtDesc(UUID actorId, Pageable pageable);
}
