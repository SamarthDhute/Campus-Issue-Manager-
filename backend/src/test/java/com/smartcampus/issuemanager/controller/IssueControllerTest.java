package com.smartcampus.issuemanager.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcampus.issuemanager.dto.CreateIssueRequest;
import com.smartcampus.issuemanager.dto.IssueResponse;
import com.smartcampus.issuemanager.dto.UpdateIssueStatusRequest;
import com.smartcampus.issuemanager.entity.IssuePriority;
import com.smartcampus.issuemanager.entity.IssueStatus;
import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.entity.User;
import com.smartcampus.issuemanager.security.JwtTokenProvider;
import com.smartcampus.issuemanager.service.IssueService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc(addFilters = false)
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

    private User testStudent;
    private IssueResponse sampleIssueResponse;
    private UUID issueId;
    private UUID categoryId;

    @BeforeEach
    void setUp() {
        issueId = UUID.randomUUID();
        categoryId = UUID.randomUUID();

        testStudent = User.builder()
                .id(UUID.randomUUID())
                .email("student@smartcampus.edu")
                .displayName("Aarav Sharma")
                .role(Role.STUDENT)
                .build();

        sampleIssueResponse = IssueResponse.builder()
                .id(issueId)
                .issueNumber("ISS-2026-0001")
                .title("Water Leakage in Hostel B")
                .description("Continuous water dripping from ceiling pipe")
                .categoryId(categoryId)
                .categoryName("Water & Plumbing")
                .location("Hostel Block B, Room 204")
                .requesterId(testStudent.getId())
                .requesterName(testStudent.getDisplayName())
                .requesterEmail(testStudent.getEmail())
                .status(IssueStatus.REPORTED)
                .priority(IssuePriority.HIGH)
                .createdAt(OffsetDateTime.now())
                .updatedAt(OffsetDateTime.now())
                .build();
    }

    @Test
    @WithMockUser(username = "student@smartcampus.edu", roles = {"STUDENT"})
    void createIssue_Success() throws Exception {
        CreateIssueRequest request = CreateIssueRequest.builder()
                .title("Water Leakage in Hostel B")
                .description("Continuous water dripping from ceiling pipe")
                .categoryId(categoryId)
                .location("Hostel Block B, Room 204")
                .priority(IssuePriority.HIGH)
                .build();

        when(issueService.createIssue(any(CreateIssueRequest.class), any())).thenReturn(sampleIssueResponse);

        mockMvc.perform(post("/api/v1/issues")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.issueNumber").value("ISS-2026-0001"))
                .andExpect(jsonPath("$.title").value("Water Leakage in Hostel B"))
                .andExpect(jsonPath("$.status").value("REPORTED"));
    }

    @Test
    @WithMockUser(username = "student@smartcampus.edu", roles = {"STUDENT"})
    void getIssues_Success() throws Exception {
        when(issueService.getIssues(any(), any(), any(), any(), any()))
                .thenReturn(List.of(sampleIssueResponse));

        mockMvc.perform(get("/api/v1/issues"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].issueNumber").value("ISS-2026-0001"))
                .andExpect(jsonPath("$[0].priority").value("HIGH"));
    }

    @Test
    @WithMockUser(username = "student@smartcampus.edu", roles = {"STUDENT"})
    void getIssueById_Success() throws Exception {
        when(issueService.getIssueById(eq(issueId), any()))
                .thenReturn(sampleIssueResponse);

        mockMvc.perform(get("/api/v1/issues/" + issueId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(issueId.toString()))
                .andExpect(jsonPath("$.issueNumber").value("ISS-2026-0001"));
    }

    @Test
    @WithMockUser(username = "operator@smartcampus.edu", roles = {"OPERATOR"})
    void updateStatus_Success() throws Exception {
        UpdateIssueStatusRequest request = UpdateIssueStatusRequest.builder()
                .status(IssueStatus.UNDERSTOOD)
                .comment("Reviewing reported pipe leakage")
                .build();

        IssueResponse updated = sampleIssueResponse;
        updated.setStatus(IssueStatus.UNDERSTOOD);

        when(issueService.updateStatus(eq(issueId), any(UpdateIssueStatusRequest.class), any()))
                .thenReturn(updated);

        mockMvc.perform(patch("/api/v1/issues/" + issueId + "/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UNDERSTOOD"));
    }
}
