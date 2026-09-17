package com.smartcampus.issuemanager.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.entity.TaskStatus;
import com.smartcampus.issuemanager.security.JwtTokenProvider;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.SmartOperationsService;
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

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class OperationsControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private SmartOperationsService operationsService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    private UserPrincipal testLeadPrincipal;
    private UsernamePasswordAuthenticationToken auth;
    private UUID issueId;
    private UUID userId;
    private UUID taskId;

    @BeforeEach
    void setUp() {
        issueId = UUID.randomUUID();
        userId = UUID.randomUUID();
        taskId = UUID.randomUUID();

        testLeadPrincipal = new UserPrincipal(
                userId,
                "teamlead@smartcampus.edu",
                "password",
                "Priya Patel",
                Role.TEAM_LEAD,
                UUID.randomUUID(),
                List.of(new SimpleGrantedAuthority("ROLE_TEAM_LEAD"))
        );

        auth = new UsernamePasswordAuthenticationToken(
                testLeadPrincipal,
                null,
                testLeadPrincipal.getAuthorities()
        );
    }

    @Test
    void getAssignmentRecommendation_Success() throws Exception {
        AssignmentRecommendationResponse response = AssignmentRecommendationResponse.builder()
                .issueId(issueId)
                .recommendedUserId(UUID.randomUUID())
                .recommendedUserName("Vikram Singh")
                .recommendedTeamName("Plumbing & Water Services")
                .matchScore(new BigDecimal("0.95"))
                .rationale("Top domain match with lowest active load")
                .currentActiveWorkload(1)
                .build();

        when(operationsService.recommendAssignment(eq(issueId))).thenReturn(response);

        mockMvc.perform(post("/api/v1/issues/" + issueId + "/assignment-recommendation")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.recommendedUserName").value("Vikram Singh"))
                .andExpect(jsonPath("$.matchScore").value(0.95))
                .andExpect(jsonPath("$.currentActiveWorkload").value(1));
    }

    @Test
    void assignIssue_Success() throws Exception {
        AssignmentRequest request = AssignmentRequest.builder()
                .userId(UUID.randomUUID())
                .assignmentType("PRIMARY")
                .recommendationSource("AI_RECOMMENDED")
                .reason("Direct assignment from recommendation")
                .build();

        AssignmentResponse response = AssignmentResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .userId(request.getUserId())
                .userName("Vikram Singh")
                .assignmentType("PRIMARY")
                .recommendationSource("AI_RECOMMENDED")
                .active(true)
                .assignedAt(OffsetDateTime.now())
                .build();

        when(operationsService.assignIssue(eq(issueId), any(AssignmentRequest.class), eq(userId)))
                .thenReturn(response);

        mockMvc.perform(post("/api/v1/issues/" + issueId + "/dispatch")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userName").value("Vikram Singh"))
                .andExpect(jsonPath("$.active").value(true));
    }

    @Test
    void getAssignmentHistory_Success() throws Exception {
        AssignmentResponse response = AssignmentResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .userName("Vikram Singh")
                .assignmentType("PRIMARY")
                .active(true)
                .build();

        when(operationsService.getAssignmentHistory(eq(issueId))).thenReturn(List.of(response));

        mockMvc.perform(get("/api/v1/issues/" + issueId + "/assignments")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].userName").value("Vikram Singh"));
    }

    @Test
    void addAndGetMessages_Success() throws Exception {
        IssueMessageRequest request = IssueMessageRequest.builder()
                .body("Valve replacement scheduled for tomorrow morning.")
                .build();

        IssueMessageResponse response = IssueMessageResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .senderName("Priya Patel")
                .senderRole("TEAM_LEAD")
                .messageType("OPERATOR_UPDATE")
                .body("Valve replacement scheduled for tomorrow morning.")
                .visibility("PUBLIC")
                .createdAt(OffsetDateTime.now())
                .build();

        when(operationsService.addMessage(eq(issueId), any(IssueMessageRequest.class), eq(userId)))
                .thenReturn(response);
        when(operationsService.getMessages(eq(issueId), eq(userId)))
                .thenReturn(List.of(response));

        mockMvc.perform(post("/api/v1/issues/" + issueId + "/messages")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.body").value("Valve replacement scheduled for tomorrow morning."));

        mockMvc.perform(get("/api/v1/issues/" + issueId + "/messages")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].senderName").value("Priya Patel"));
    }

    @Test
    void addAndGetInternalNotes_Success() throws Exception {
        InternalNoteRequest request = InternalNoteRequest.builder()
                .body("Requires supervisor sign-off on parts requisition.")
                .build();

        InternalNoteResponse response = InternalNoteResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .authorName("Priya Patel")
                .authorRole("TEAM_LEAD")
                .body("Requires supervisor sign-off on parts requisition.")
                .createdAt(OffsetDateTime.now())
                .build();

        when(operationsService.addInternalNote(eq(issueId), any(InternalNoteRequest.class), eq(userId)))
                .thenReturn(response);
        when(operationsService.getInternalNotes(eq(issueId), eq(userId)))
                .thenReturn(List.of(response));

        mockMvc.perform(post("/api/v1/issues/" + issueId + "/internal-notes")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.body").value("Requires supervisor sign-off on parts requisition."));

        mockMvc.perform(get("/api/v1/issues/" + issueId + "/internal-notes")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].authorRole").value("TEAM_LEAD"));
    }

    @Test
    void createAndGetInvestigation_Success() throws Exception {
        InvestigationRequest request = InvestigationRequest.builder()
                .observations("Moisture near electrical panel Room 204")
                .findings("Coupling leak caused slow drip")
                .actionsTaken("Tightened valve and sealed with waterproof tape")
                .followUp("Inspect tomorrow after heavy usage")
                .build();

        InvestigationResponse response = InvestigationResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .investigatorName("Priya Patel")
                .observations("Moisture near electrical panel Room 204")
                .findings("Coupling leak caused slow drip")
                .createdAt(OffsetDateTime.now())
                .build();

        when(operationsService.createInvestigation(eq(issueId), any(InvestigationRequest.class), eq(userId)))
                .thenReturn(response);
        when(operationsService.getInvestigations(eq(issueId))).thenReturn(List.of(response));

        mockMvc.perform(post("/api/v1/issues/" + issueId + "/investigations")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.observations").value("Moisture near electrical panel Room 204"));

        mockMvc.perform(get("/api/v1/issues/" + issueId + "/investigations")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].findings").value("Coupling leak caused slow drip"));
    }

    @Test
    void tasksWorkflow_Success() throws Exception {
        TaskCreateRequest createRequest = TaskCreateRequest.builder()
                .title("Replace washer seal")
                .description("Use 1/2 inch silicone washer")
                .build();

        TaskResponse taskResponse = TaskResponse.builder()
                .id(taskId)
                .issueId(issueId)
                .title("Replace washer seal")
                .status(TaskStatus.PENDING)
                .createdAt(OffsetDateTime.now())
                .build();

        when(operationsService.createTask(eq(issueId), any(TaskCreateRequest.class), eq(userId)))
                .thenReturn(taskResponse);
        when(operationsService.getTasks(eq(issueId))).thenReturn(List.of(taskResponse));

        mockMvc.perform(post("/api/v1/issues/" + issueId + "/tasks")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title").value("Replace washer seal"))
                .andExpect(jsonPath("$.status").value("PENDING"));

        mockMvc.perform(get("/api/v1/issues/" + issueId + "/tasks")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("Replace washer seal"));

        // Update task status to COMPLETED
        TaskUpdateRequest updateRequest = TaskUpdateRequest.builder()
                .status(TaskStatus.COMPLETED)
                .build();

        TaskResponse updatedTaskResponse = TaskResponse.builder()
                .id(taskId)
                .issueId(issueId)
                .title("Replace washer seal")
                .status(TaskStatus.COMPLETED)
                .completedAt(OffsetDateTime.now())
                .build();

        when(operationsService.updateTask(eq(taskId), any(TaskUpdateRequest.class), eq(userId)))
                .thenReturn(updatedTaskResponse);

        mockMvc.perform(patch("/api/v1/tasks/" + taskId)
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("COMPLETED"));
    }
}
