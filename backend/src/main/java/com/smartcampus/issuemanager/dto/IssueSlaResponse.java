package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.SlaStatus;
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
public class IssueSlaResponse {

    private UUID id;
    private UUID issueId;
    private OffsetDateTime responseDueAt;
    private OffsetDateTime resolutionDueAt;
    private OffsetDateTime responseMetAt;
    private OffsetDateTime resolutionMetAt;
    private OffsetDateTime responseBreachedAt;
    private OffsetDateTime resolutionBreachedAt;
    private SlaStatus status;
    private Long responseSecondsRemaining;
    private Long resolutionSecondsRemaining;
    private Double responseProgressPercentage;
    private Double resolutionProgressPercentage;
    private Boolean responseBreached;
    private Boolean resolutionBreached;
    private Boolean responseMet;
    private Boolean resolutionMet;
}
