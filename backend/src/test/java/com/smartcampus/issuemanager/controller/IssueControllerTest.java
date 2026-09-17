package com.smartcampus.issuemanager.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcampus.issuemanager.dto.CreateIssueRequest;
import com.smartcampus.issuemanager.dto.IssueResponse;
import com.smartcampus.issuemanager.dto.UpdateIssueStatusRequest;
import com.smartcampus.issuemanager.entity.IssuePriority;
import com.smartcampus.issuemanager.entity.IssueStatus;
import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.security.JwtTokenProvider;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.IssueService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class IssueControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private IssueService issueService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    private UserPrincipal testStudentPrincipal;
    private UsernamePasswordAuthenticationToken auth;
    private IssueResponse sampleIssueResponse;
    private UUID issueId;
    private UUID categoryId;
    private UUID userId;

    @BeforeEach
    void setUp() {
        issueId = UUID.randomUUID();
        categoryId = UUID.randomUUID();
        userId = UUID.randomUUID();

        testStudentPrincipal = new UserPrincipal(
                userId,
                "student@smartcampus.edu",
                "password",
                "Aarav Sharma",
                Role.STUDENT,
                UUID.randomUUID(),
                List.of(new SimpleGrantedAuthority("ROLE_STUDENT"))
        );

        auth = new UsernamePasswordAuthenticationToken(
                testStudentPrincipal,
                null,
                testStudentPrincipal.getAuthorities()
        );

        sampleIssueResponse = IssueResponse.builder()
                .id(issueId)
                .issueNumber("ISS-2026-0001")
                .title("Water Leakage in Hostel B")
                .description("Continuous water dripping from ceiling pipe")
                .categoryId(categoryId)
                .categoryName("Water & Plumbing")
                .location("Hostel Block B, Room 204")
                .requesterId(userId)
                .requesterName("Aarav Sharma")
                .requesterEmail("student@smartcampus.edu")
                .status(IssueStatus.REPORTED)
                .priority(IssuePriority.HIGH)
                .createdAt(OffsetDateTime.now())
                .updatedAt(OffsetDateTime.now())
                .build();
    }

    @Test
    void createIssue_Success() throws Exception {
        CreateIssueRequest request = CreateIssueRequest.builder()
                .title("Water Leakage in Hostel B")
                .description("Continuous water dripping from ceiling pipe")
                .categoryId(categoryId)
                .location("Hostel Block B, Room 204")
                .priority(IssuePriority.HIGH)
                .build();

        when(issueService.createIssue(any(CreateIssueRequest.class), eq(userId))).thenReturn(sampleIssueResponse);

        mockMvc.perform(post("/api/v1/issues")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.issueNumber").value("ISS-2026-0001"))
                .andExpect(jsonPath("$.title").value("Water Leakage in Hostel B"))
                .andExpect(jsonPath("$.status").value("REPORTED"));
    }

    @Test
    void getIssues_Success() throws Exception {
        when(issueService.getIssues(any(), any(), any(), any(), eq(userId)))
                .thenReturn(List.of(sampleIssueResponse));

        mockMvc.perform(get("/api/v1/issues")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].issueNumber").value("ISS-2026-0001"))
                .andExpect(jsonPath("$[0].priority").value("HIGH"));
    }

    @Test
    void getIssueById_Success() throws Exception {
        when(issueService.getIssueById(eq(issueId), eq(userId)))
                .thenReturn(sampleIssueResponse);

        mockMvc.perform(get("/api/v1/issues/" + issueId)
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(issueId.toString()))
                .andExpect(jsonPath("$.issueNumber").value("ISS-2026-0001"));
    }

    @Test
    void updateStatus_Success() throws Exception {
        UpdateIssueStatusRequest request = UpdateIssueStatusRequest.builder()
                .status(IssueStatus.UNDERSTOOD)
                .comment("Reviewing reported pipe leakage")
                .build();

        IssueResponse updated = sampleIssueResponse;
        updated.setStatus(IssueStatus.UNDERSTOOD);

        when(issueService.updateStatus(eq(issueId), any(UpdateIssueStatusRequest.class), eq(userId)))
                .thenReturn(updated);

        mockMvc.perform(patch("/api/v1/issues/" + issueId + "/status")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UNDERSTOOD"));
    }
}
