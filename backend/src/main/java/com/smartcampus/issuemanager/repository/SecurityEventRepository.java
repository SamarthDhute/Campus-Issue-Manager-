package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.SecurityEvent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SecurityEventRepository extends JpaRepository<SecurityEvent, UUID> {

    Page<SecurityEvent> findAllByOrderByCreatedAtDesc(Pageable pageable);

    List<SecurityEvent> findBySeverityOrderByCreatedAtDesc(String severity);

    Page<SecurityEvent> findByEventTypeOrderByCreatedAtDesc(String eventType, Pageable pageable);
}
