package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.service.AnalyticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/analytics")
@RequiredArgsConstructor
@Tag(name = "Management & Operational Insights", description = "Campus analytics, MTTR, SLA compliance, location hotspots, and leadership KPIs")
@SecurityRequirement(name = "bearerAuth")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @GetMapping("/overview")
    @Operation(summary = "Get high-level executive KPIs and MTTR metrics")
    public ResponseEntity<ExecutiveMetricsResponse> getExecutiveOverview(
            @RequestParam(defaultValue = "30d") String timeRange) {
        return ResponseEntity.ok(analyticsService.getExecutiveOverview(timeRange));
    }

    @GetMapping("/categories")
    @Operation(summary = "Get category breakdown and issue volume share")
    public ResponseEntity<List<CategoryDistributionResponse>> getCategoryDistribution(
            @RequestParam(defaultValue = "30d") String timeRange) {
        return ResponseEntity.ok(analyticsService.getCategoryDistribution(timeRange));
    }

    @GetMapping("/hotspots")
    @Operation(summary = "Get campus location hotspots with recurring risk assessment")
    public ResponseEntity<List<LocationHotspotResponse>> getLocationHotspots(
            @RequestParam(defaultValue = "30d") String timeRange) {
        return ResponseEntity.ok(analyticsService.getLocationHotspots(timeRange));
    }

    @GetMapping("/leaderboard")
    @Operation(summary = "Get operator performance leaderboard and efficiency badges")
    public ResponseEntity<List<OperatorLeaderboardResponse>> getOperatorLeaderboard(
            @RequestParam(defaultValue = "30d") String timeRange) {
        return ResponseEntity.ok(analyticsService.getOperatorLeaderboard(timeRange));
    }

    @GetMapping("/sla-trends")
    @Operation(summary = "Get SLA compliance trends over time")
    public ResponseEntity<List<SlaTrendPointResponse>> getSlaTrends(
            @RequestParam(defaultValue = "30d") String timeRange) {
        return ResponseEntity.ok(analyticsService.getSlaTrends(timeRange));
    }
}
