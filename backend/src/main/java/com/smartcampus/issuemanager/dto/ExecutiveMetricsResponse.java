package com.smartcampus.issuemanager.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExecutiveMetricsResponse {

    private long totalIssuesCount;
    private long activeIssuesCount;
    private long resolvedIssuesCount;
    private long breachedIssuesCount;
    private long pendingApprovalCount;

    private BigDecimal slaComplianceRate; // e.g. 94.50%
    private BigDecimal averageResolutionHours; // MTTR
    private BigDecimal averageResponseHours; // MTTF
    private BigDecimal averageCsatRating; // e.g. 4.65 out of 5.0
    private long totalFeedbacksCount;

    private String resolutionEfficiencyTrend; // e.g. "+5.2% vs previous period"
    private String timeRange; // e.g. "30d"
}
