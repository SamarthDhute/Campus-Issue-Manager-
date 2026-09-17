package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.RiskSeverity;
import com.smartcampus.issuemanager.entity.RiskType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RiskEventResponse {

    private UUID id;
    private UUID issueId;
    private RiskType riskType;
    private RiskSeverity severity;
    private String explanation;
    private OffsetDateTime detectedAt;
    private OffsetDateTime resolvedAt;
    private boolean active;
}
