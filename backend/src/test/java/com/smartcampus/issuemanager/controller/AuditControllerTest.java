package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.AuditEventResponse;
import com.smartcampus.issuemanager.dto.SecurityEventResponse;
import com.smartcampus.issuemanager.dto.SystemStatusResponse;
import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.security.JwtTokenProvider;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.AuditService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class AuditControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AuditService auditService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    private UsernamePasswordAuthenticationToken auth;
    private UUID testIssueId;

    @BeforeEach
    void setUp() {
        testIssueId = UUID.randomUUID();
        UserPrincipal principal = new UserPrincipal(
                UUID.randomUUID(),
                "manager@smartcampus.edu",
                "password",
                "Campus Operations Manager",
                Role.MANAGER,
                UUID.randomUUID(),
                List.of(new SimpleGrantedAuthority("ROLE_MANAGER"))
        );
        auth = new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());
    }

    @Test
    void testGetIssueAuditTrail_Success() throws Exception {
        AuditEventResponse auditEvent = AuditEventResponse.builder()
                .id(UUID.randomUUID())
                .entityType("ISSUE")
                .entityId(testIssueId)
                .eventType("STATUS_TRANSITION")
                .actionSummary("Status changed from REPORTED to IN_PROGRESS")
                .actorName("Campus Operations Manager")
                .actorRole("MANAGER")
                .createdAt(OffsetDateTime.now())
                .build();

        when(auditService.getIssueAuditTrail(eq(testIssueId), any(UserPrincipal.class)))
                .thenReturn(List.of(auditEvent));

        mockMvc.perform(get("/api/v1/issues/{id}/audit", testIssueId)
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].eventType").value("STATUS_TRANSITION"))
                .andExpect(jsonPath("$[0].actionSummary").value("Status changed from REPORTED to IN_PROGRESS"));
    }

    @Test
    void testGetSystemAuditLogs_Success() throws Exception {
        AuditEventResponse auditEvent = AuditEventResponse.builder()
                .id(UUID.randomUUID())
                .entityType("ISSUE")
                .eventType("ISSUE_CREATED")
                .actionSummary("Issue created")
                .actorName("Campus Operations Manager")
                .createdAt(OffsetDateTime.now())
                .build();

        when(auditService.getSystemAuditLogs(any(), any(), any(), any(Pageable.class), any(UserPrincipal.class)))
                .thenReturn(new PageImpl<>(List.of(auditEvent)));

        mockMvc.perform(get("/api/v1/admin/audit")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].eventType").value("ISSUE_CREATED"));
    }

    @Test
    void testGetSecurityLogs_Success() throws Exception {
        SecurityEventResponse secEvent = SecurityEventResponse.builder()
                .id(UUID.randomUUID())
                .eventType("AUTH_FAILURE")
                .severity("WARN")
                .actorEmail("unknown@smartcampus.edu")
                .ipAddress("127.0.0.1")
                .createdAt(OffsetDateTime.now())
                .build();

        when(auditService.getSecurityLogs(any(), any(), any(Pageable.class), any(UserPrincipal.class)))
                .thenReturn(new PageImpl<>(List.of(secEvent)));

        mockMvc.perform(get("/api/v1/admin/security-logs")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].severity").value("WARN"));
    }

    @Test
    void testGetSystemStatus_Success() throws Exception {
        SystemStatusResponse sysStatus = SystemStatusResponse.builder()
                .status("UP")
                .environment("production-ready")
                .version("1.0.0")
                .uptimeSeconds(300L)
                .serverTime(OffsetDateTime.now())
                .components(Map.of(
                        "database", Map.of("status", "UP", "details", "Connected"),
                        "aiEngine", Map.of("status", "UP", "mode", "GEMINI_1_5_FLASH")
                ))
                .metrics(Map.of("usedMemoryMb", 64L, "maxMemoryMb", 1024L))
                .build();

        when(auditService.getSystemStatus(any(UserPrincipal.class)))
                .thenReturn(sysStatus);

        mockMvc.perform(get("/api/v1/system/status")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"))
                .andExpect(jsonPath("$.environment").value("production-ready"))
                .andExpect(jsonPath("$.components.database.status").value("UP"));
    }

    @Test
    void testGetSystemStatus_UnauthorizedWithoutAuth() throws Exception {
        mockMvc.perform(get("/api/v1/system/status")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isUnauthorized());
    }
}
