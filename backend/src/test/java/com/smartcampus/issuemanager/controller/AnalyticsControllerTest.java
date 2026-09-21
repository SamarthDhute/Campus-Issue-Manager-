package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.security.JwtTokenProvider;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.AnalyticsService;
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
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class AnalyticsControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AnalyticsService analyticsService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    private UsernamePasswordAuthenticationToken auth;

    @BeforeEach
    void setUp() {
        UserPrincipal principal = new UserPrincipal(
                UUID.randomUUID(),
                "manager@smartcampus.edu",
                "password",
                "Dr. Suresh Mehta",
                Role.MANAGER,
                UUID.randomUUID(),
                List.of(new SimpleGrantedAuthority("ROLE_MANAGER"))
        );
        auth = new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());
    }

    @Test
    void testGetExecutiveOverview() throws Exception {
        ExecutiveMetricsResponse mockResponse = ExecutiveMetricsResponse.builder()
                .totalIssuesCount(42)
                .activeIssuesCount(12)
                .resolvedIssuesCount(30)
                .slaComplianceRate(BigDecimal.valueOf(96.5))
                .averageResolutionHours(BigDecimal.valueOf(3.5))
                .averageCsatRating(BigDecimal.valueOf(4.85))
                .build();

        when(analyticsService.getExecutiveOverview(anyString())).thenReturn(mockResponse);

        mockMvc.perform(get("/api/v1/analytics/overview")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalIssuesCount").value(42))
                .andExpect(jsonPath("$.activeIssuesCount").value(12))
                .andExpect(jsonPath("$.resolvedIssuesCount").value(30))
                .andExpect(jsonPath("$.slaComplianceRate").value(96.5));
    }

    @Test
    void testGetCategoryDistribution() throws Exception {
        CategoryDistributionResponse mockCat = CategoryDistributionResponse.builder()
                .categoryId(UUID.randomUUID())
                .categoryName("Electrical")
                .totalIssuesCount(15)
                .percentageShare(BigDecimal.valueOf(45.0))
                .build();

        when(analyticsService.getCategoryDistribution(anyString())).thenReturn(List.of(mockCat));

        mockMvc.perform(get("/api/v1/analytics/categories")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].categoryName").value("Electrical"))
                .andExpect(jsonPath("$[0].totalIssuesCount").value(15));
    }

    @Test
    void testGetLocationHotspots() throws Exception {
        LocationHotspotResponse mockHotspot = LocationHotspotResponse.builder()
                .locationName("MCA Computer Lab 2006")
                .buildingZone("Academic Wing B")
                .totalIncidentCount(8)
                .riskLevel("HIGH")
                .build();

        when(analyticsService.getLocationHotspots(anyString())).thenReturn(List.of(mockHotspot));

        mockMvc.perform(get("/api/v1/analytics/hotspots")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].locationName").value("MCA Computer Lab 2006"))
                .andExpect(jsonPath("$[0].riskLevel").value("HIGH"));
    }

    @Test
    void testGetOperatorLeaderboard() throws Exception {
        OperatorLeaderboardResponse mockLeader = OperatorLeaderboardResponse.builder()
                .operatorId(UUID.randomUUID())
                .name("Vikram Singh")
                .resolvedCount(14)
                .efficiencyBadge("Top Performer")
                .build();

        when(analyticsService.getOperatorLeaderboard(anyString())).thenReturn(List.of(mockLeader));

        mockMvc.perform(get("/api/v1/analytics/leaderboard")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].name").value("Vikram Singh"))
                .andExpect(jsonPath("$[0].efficiencyBadge").value("Top Performer"));
    }

    @Test
    void testGetSlaTrends() throws Exception {
        SlaTrendPointResponse point = SlaTrendPointResponse.builder()
                .dateLabel("Sep 20")
                .totalEvaluated(15)
                .compliantCount(14)
                .compliancePercentage(BigDecimal.valueOf(93.3))
                .build();

        when(analyticsService.getSlaTrends(anyString())).thenReturn(List.of(point));

        mockMvc.perform(get("/api/v1/analytics/sla-trends")
                        .with(authentication(auth))
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].dateLabel").value("Sep 20"))
                .andExpect(jsonPath("$[0].totalEvaluated").value(15));
    }
}
