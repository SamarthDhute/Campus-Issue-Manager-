package com.smartcampus.issuemanager.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OperatorLeaderboardResponse {

    private UUID operatorId;
    private String name;
    private String email;
    private String teamName;
    private long totalAssignedCount;
    private long resolvedCount;
    private long activeWorkloadCount;
    private BigDecimal averageResolutionHours;
    private BigDecimal csatRating; // e.g. 4.8 out of 5
    private BigDecimal slaComplianceRate; // e.g. 98.2%
    private String efficiencyBadge; // e.g. "Top Performer", "Speed Champion", "Consistent"
}
