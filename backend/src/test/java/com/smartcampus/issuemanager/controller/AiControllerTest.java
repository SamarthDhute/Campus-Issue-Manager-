package com.smartcampus.issuemanager.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcampus.issuemanager.dto.AiAnalysisResponse;
import com.smartcampus.issuemanager.dto.AiDecisionRequest;
import com.smartcampus.issuemanager.dto.AiRecommendationResponse;
import com.smartcampus.issuemanager.dto.RelatedIssueResponse;
import com.smartcampus.issuemanager.entity.*;
import com.smartcampus.issuemanager.security.JwtTokenProvider;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.AiCaseIntelligenceService;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class AiControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AiCaseIntelligenceService aiService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    private UserPrincipal testOperatorPrincipal;
    private UsernamePasswordAuthenticationToken auth;
    private UUID issueId;
    private UUID recId;
    private UUID userId;
    private AiAnalysisResponse sampleAnalysis;
    private AiRecommendationResponse sampleRec;

    @BeforeEach
    void setUp() {
        issueId = UUID.randomUUID();
        recId = UUID.randomUUID();
        userId = UUID.randomUUID();

        testOperatorPrincipal = new UserPrincipal(
                userId,
                "operator@smartcampus.edu",
                "password",
                "Vikram Singh",
                Role.OPERATOR,
                UUID.randomUUID(),
                List.of(new SimpleGrantedAuthority("ROLE_OPERATOR"))
        );

        auth = new UsernamePasswordAuthenticationToken(
                testOperatorPrincipal,
                null,
                testOperatorPrincipal.getAuthorities()
        );

        sampleRec = AiRecommendationResponse.builder()
                .id(recId)
                .analysisId(UUID.randomUUID())
                .issueId(issueId)
                .recommendationType(RecommendationType.PRIORITY)
                .suggestedValue("HIGH")
                .confidence(new BigDecimal("0.9200"))
                .explanation("Active water leakage requires urgent intervention")
                .decision(RecommendationDecision.PENDING)
                .createdAt(OffsetDateTime.now())
                .build();

        sampleAnalysis = AiAnalysisResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .issueNumber("ISS-2026-0001")
                .status(AiAnalysisStatus.COMPLETED)
                .model("gemini-1.5-flash")
                .summary("Water leakage reported at Hostel Block B")
                .missingInformation("None")
                .confidence(new BigDecimal("0.9000"))
                .recommendations(List.of(sampleRec))
                .createdAt(OffsetDateTime.now())
                .completedAt(OffsetDateTime.now())
                .build();
    }

    @Test
    void getAnalysis_Success() throws Exception {
        when(aiService.getLatestAnalysis(eq(issueId))).thenReturn(sampleAnalysis);

        mockMvc.perform(get("/api/v1/issues/" + issueId + "/ai")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.issueNumber").value("ISS-2026-0001"))
                .andExpect(jsonPath("$.status").value("COMPLETED"))
                .andExpect(jsonPath("$.recommendations[0].suggestedValue").value("HIGH"));
    }

    @Test
    void triggerAnalysis_Success() throws Exception {
        when(aiService.analyzeIssue(eq(issueId), eq(userId))).thenReturn(sampleAnalysis);

        mockMvc.perform(post("/api/v1/issues/" + issueId + "/ai/analyze")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.summary").value("Water leakage reported at Hostel Block B"));
    }

    @Test
    void recordDecision_Success() throws Exception {
        AiDecisionRequest request = AiDecisionRequest.builder()
                .decision(RecommendationDecision.ACCEPTED)
                .comments("Confirmed by operator")
                .build();

        AiRecommendationResponse acceptedRec = sampleRec;
        acceptedRec.setDecision(RecommendationDecision.ACCEPTED);

        when(aiService.recordDecision(eq(issueId), eq(recId), any(AiDecisionRequest.class), eq(userId)))
                .thenReturn(acceptedRec);

        mockMvc.perform(post("/api/v1/issues/" + issueId + "/ai/recommendations/" + recId + "/decision")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.decision").value("ACCEPTED"));
    }

    @Test
    void getRelatedIssues_Success() throws Exception {
        RelatedIssueResponse related = RelatedIssueResponse.builder()
                .relationshipId(UUID.randomUUID())
                .issueId(UUID.randomUUID())
                .issueNumber("ISS-2026-0002")
                .title("Pipe drip in Room 204")
                .location("Hostel Block B")
                .categoryName("Water & Plumbing")
                .status(IssueStatus.REPORTED)
                .priority(IssuePriority.MEDIUM)
                .relationshipType(RelationshipType.DUPLICATE_CANDIDATE)
                .confidence(new BigDecimal("0.8500"))
                .explanation("Similar incident reported at same location")
                .createdAt(OffsetDateTime.now())
                .build();

        when(aiService.getRelatedIssues(eq(issueId))).thenReturn(List.of(related));

        mockMvc.perform(get("/api/v1/issues/" + issueId + "/related")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].issueNumber").value("ISS-2026-0002"))
                .andExpect(jsonPath("$[0].relationshipType").value("DUPLICATE_CANDIDATE"));
    }
}
