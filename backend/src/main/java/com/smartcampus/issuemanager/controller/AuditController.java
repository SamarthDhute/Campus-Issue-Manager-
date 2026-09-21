package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.AuditEventResponse;
import com.smartcampus.issuemanager.dto.SecurityEventResponse;
import com.smartcampus.issuemanager.dto.SystemStatusResponse;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.AuditService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Tag(name = "Trust, Audit & System Health", description = "Immutable audit trails, human-in-the-loop decision tracking, and system health status")
public class AuditController {

    private final AuditService auditService;

    @GetMapping("/issues/{id}/audit")
    @Operation(summary = "Get authorized audit trail for an issue")
    public ResponseEntity<List<AuditEventResponse>> getIssueAuditTrail(
            @PathVariable("id") UUID issueId,
            @AuthenticationPrincipal UserPrincipal principal) {
        List<AuditEventResponse> trail = auditService.getIssueAuditTrail(issueId, principal);
        return ResponseEntity.ok(trail);
    }

    @GetMapping("/admin/audit")
    @Operation(summary = "Administrative system-wide audit search (Managers/Leads/Admins)")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN', 'TEAM_LEAD')")
    public ResponseEntity<Page<AuditEventResponse>> getSystemAuditLogs(
            @RequestParam(value = "entityType", required = false) String entityType,
            @RequestParam(value = "eventType", required = false) String eventType,
            @RequestParam(value = "actorId", required = false) UUID actorId,
            @PageableDefault(size = 20) Pageable pageable,
            @AuthenticationPrincipal UserPrincipal principal) {
        Page<AuditEventResponse> page = auditService.getSystemAuditLogs(entityType, eventType, actorId, pageable, principal);
        return ResponseEntity.ok(page);
    }

    @GetMapping("/admin/security-logs")
    @Operation(summary = "Administrative security and anomaly logs (Managers/Admins)")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<Page<SecurityEventResponse>> getSecurityLogs(
            @RequestParam(value = "severity", required = false) String severity,
            @RequestParam(value = "eventType", required = false) String eventType,
            @PageableDefault(size = 20) Pageable pageable,
            @AuthenticationPrincipal UserPrincipal principal) {
        Page<SecurityEventResponse> page = auditService.getSecurityLogs(severity, eventType, pageable, principal);
        return ResponseEntity.ok(page);
    }

    @GetMapping("/system/status")
    @Operation(summary = "System dependency health and diagnostic status")
    public ResponseEntity<SystemStatusResponse> getSystemStatus(
            @AuthenticationPrincipal UserPrincipal principal) {
        SystemStatusResponse status = auditService.getSystemStatus(principal);
        return ResponseEntity.ok(status);
    }
}
