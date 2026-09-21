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
public class LocationHotspotResponse {

    private String locationName;
    private String buildingZone;
    private long totalIncidentCount;
    private long activeIncidentCount;
    private long resolvedIncidentCount;
    private String primaryCategory;
    private String riskLevel; // "HIGH", "MEDIUM", "LOW"
    private BigDecimal recurringRate; // Percentage of recurring issues
}
