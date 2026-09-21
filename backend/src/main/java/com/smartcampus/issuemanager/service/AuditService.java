package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.AuditEventResponse;
import com.smartcampus.issuemanager.dto.SecurityEventResponse;
import com.smartcampus.issuemanager.dto.SystemStatusResponse;
import com.smartcampus.issuemanager.entity.User;
import com.smartcampus.issuemanager.security.UserPrincipal;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface AuditService {

    void logEvent(User actor, String entityType, UUID entityId, String eventType,
                  String actionSummary, String beforeData, String afterData, String metadata, String ipAddress);

    void logSecurityEvent(User actor, String actorEmail, String eventType,
                          String severity, String metadata, String ipAddress);

    List<AuditEventResponse> getIssueAuditTrail(UUID issueId, UserPrincipal principal);

    Page<AuditEventResponse> getSystemAuditLogs(String entityType, String eventType, UUID actorId, Pageable pageable, UserPrincipal principal);

    Page<SecurityEventResponse> getSecurityLogs(String severity, String eventType, Pageable pageable, UserPrincipal principal);

    SystemStatusResponse getSystemStatus(UserPrincipal principal);
}
