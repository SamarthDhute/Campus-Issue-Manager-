package com.smartcampus.issuemanager.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.entity.EvidenceType;
import com.smartcampus.issuemanager.entity.IssueStatus;
import com.smartcampus.issuemanager.entity.ResolutionQuality;
import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.security.JwtTokenProvider;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.FeedbackService;
import com.smartcampus.issuemanager.service.ResolutionEvidenceService;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class ResolutionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private ResolutionEvidenceService evidenceService;

    @MockBean
    private FeedbackService feedbackService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    private UserPrincipal testUserPrincipal;
    private UsernamePasswordAuthenticationToken auth;
    private UUID issueId;
    private UUID userId;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
        issueId = UUID.randomUUID();

        testUserPrincipal = new UserPrincipal(
                userId,
                "student@smartcampus.edu",
                "Password@123",
                "Aarav Student",
                Role.STUDENT,
                UUID.randomUUID(),
                List.of(new SimpleGrantedAuthority("ROLE_STUDENT"))
        );
        auth = new UsernamePasswordAuthenticationToken(
                testUserPrincipal,
                null,
                testUserPrincipal.getAuthorities()
        );
    }

    @Test
    void testUploadEvidence() throws Exception {
        UploadEvidenceRequest request = UploadEvidenceRequest.builder()
                .evidenceType(EvidenceType.BEFORE_REPAIR)
                .fileUrl("/api/v1/files/before.jpg")
                .fileName("before.jpg")
                .notes("Pipe cracked before repair")
                .build();

        EvidenceResponse response = EvidenceResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .uploadedByUserId(userId)
                .uploadedByName("Aarav Student")
                .evidenceType(EvidenceType.BEFORE_REPAIR)
                .fileUrl("/api/v1/files/before.jpg")
                .fileName("before.jpg")
                .notes("Pipe cracked before repair")
                .createdAt(OffsetDateTime.now())
                .build();

        when(evidenceService.uploadEvidence(eq(issueId), any(UploadEvidenceRequest.class), eq(userId)))
                .thenReturn(response);

        mockMvc.perform(post("/api/v1/issues/{issueId}/evidence", issueId)
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.evidenceType").value("BEFORE_REPAIR"))
                .andExpect(jsonPath("$.fileUrl").value("/api/v1/files/before.jpg"));
    }

    @Test
    void testSubmitFeedback() throws Exception {
        SubmitFeedbackRequest request = SubmitFeedbackRequest.builder()
                .rating(5)
                .feedbackText("Great and quick repair work!")
                .resolutionQuality(ResolutionQuality.EXCELLENT)
                .build();

        FeedbackResponse response = FeedbackResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .submittedByUserId(userId)
                .submittedByName("Aarav Student")
                .rating(5)
                .feedbackText("Great and quick repair work!")
                .resolutionQuality(ResolutionQuality.EXCELLENT)
                .createdAt(OffsetDateTime.now())
                .build();

        when(feedbackService.submitFeedback(eq(issueId), any(SubmitFeedbackRequest.class), eq(userId)))
                .thenReturn(response);

        mockMvc.perform(post("/api/v1/issues/{issueId}/feedback", issueId)
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.rating").value(5))
                .andExpect(jsonPath("$.resolutionQuality").value("EXCELLENT"));
    }

    @Test
    void testReopenIssue() throws Exception {
        ReopenIssueRequest request = ReopenIssueRequest.builder()
                .reason("Water is still dripping from pipe")
                .build();

        IssueResponse response = IssueResponse.builder()
                .id(issueId)
                .issueNumber("ISS-2026-0001")
                .title("Water Leakage")
                .status(IssueStatus.REOPENED)
                .build();

        when(feedbackService.reopenIssue(eq(issueId), any(ReopenIssueRequest.class), eq(userId)))
                .thenReturn(response);

        mockMvc.perform(post("/api/v1/issues/{issueId}/reopen", issueId)
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("REOPENED"));
    }
}
