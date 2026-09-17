package com.smartcampus.issuemanager.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcampus.issuemanager.dto.CreateEscalationRequest;
import com.smartcampus.issuemanager.dto.EscalationResponse;
import com.smartcampus.issuemanager.dto.IssueSlaResponse;
import com.smartcampus.issuemanager.dto.RiskEventResponse;
import com.smartcampus.issuemanager.entity.*;
import com.smartcampus.issuemanager.repository.UserRepository;
import com.smartcampus.issuemanager.security.JwtTokenProvider;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.EscalationService;
import com.smartcampus.issuemanager.service.RiskAssessmentService;
import com.smartcampus.issuemanager.service.SlaService;
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
import java.util.Optional;
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
public class SlaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private SlaService slaService;

    @MockBean
    private RiskAssessmentService riskAssessmentService;

    @MockBean
    private EscalationService escalationService;

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    private UserPrincipal testLeadPrincipal;
    private UsernamePasswordAuthenticationToken auth;
    private UUID issueId;
    private UUID userId;

    @BeforeEach
    void setUp() {
        issueId = UUID.randomUUID();
        userId = UUID.randomUUID();

        testLeadPrincipal = new UserPrincipal(
                userId,
                "teamlead@smartcampus.edu",
                "password",
                "Priya Patel",
                Role.TEAM_LEAD,
                UUID.randomUUID(),
                List.of(new SimpleGrantedAuthority("ROLE_TEAM_LEAD"))
        );

        auth = new UsernamePasswordAuthenticationToken(testLeadPrincipal, null, testLeadPrincipal.getAuthorities());
    }

    @Test
    void getIssueSla_Success() throws Exception {
        IssueSlaResponse response = IssueSlaResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .status(SlaStatus.ON_TRACK)
                .responseSecondsRemaining(1800L)
                .resolutionSecondsRemaining(14400L)
                .responseProgressPercentage(25.0)
                .resolutionProgressPercentage(10.0)
                .responseBreached(false)
                .resolutionBreached(false)
                .build();

        when(slaService.getIssueSla(issueId)).thenReturn(response);

        mockMvc.perform(get("/api/v1/issues/" + issueId + "/sla")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("ON_TRACK"))
                .andExpect(jsonPath("$.responseSecondsRemaining").value(1800))
                .andExpect(jsonPath("$.responseBreached").value(false));
    }

    @Test
    void getIssueRisks_Success() throws Exception {
        RiskEventResponse risk = RiskEventResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .riskType(RiskType.SLA_PROXIMITY)
                .severity(RiskSeverity.HIGH)
                .explanation("Resolution SLA approaching deadline")
                .active(true)
                .build();

        when(riskAssessmentService.getActiveRisksForIssue(issueId)).thenReturn(List.of(risk));

        mockMvc.perform(get("/api/v1/issues/" + issueId + "/risks")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].riskType").value("SLA_PROXIMITY"))
                .andExpect(jsonPath("$[0].severity").value("HIGH"));
    }

    @Test
    void getIssueEscalations_Success() throws Exception {
        EscalationResponse esc = EscalationResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .triggerType(EscalationTrigger.AUTO_SLA_BREACH)
                .level(1)
                .status(EscalationStatus.OPEN)
                .reason("Response SLA breached")
                .build();

        when(escalationService.getEscalationsForIssue(issueId)).thenReturn(List.of(esc));

        mockMvc.perform(get("/api/v1/issues/" + issueId + "/escalations")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].level").value(1))
                .andExpect(jsonPath("$[0].status").value("OPEN"));
    }

    @Test
    void createManualEscalation_Success() throws Exception {
        CreateEscalationRequest request = CreateEscalationRequest.builder()
                .level(1)
                .reason("Critical power failure requiring senior electrical team intervention")
                .build();

        User user = User.builder().id(userId).email("teamlead@smartcampus.edu").role(Role.TEAM_LEAD).displayName("Priya Patel").build();
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        EscalationResponse response = EscalationResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .triggerType(EscalationTrigger.MANUAL_STAFF_OVERRIDE)
                .level(1)
                .status(EscalationStatus.OPEN)
                .reason(request.getReason())
                .triggeredById(userId)
                .triggeredByName("Priya Patel")
                .triggeredByRole("TEAM_LEAD")
                .build();

        when(escalationService.createManualEscalation(eq(issueId), any(CreateEscalationRequest.class), any(User.class)))
                .thenReturn(response);

        mockMvc.perform(post("/api/v1/issues/" + issueId + "/escalations")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.level").value(1))
                .andExpect(jsonPath("$.triggeredByName").value("Priya Patel"));
    }
}
