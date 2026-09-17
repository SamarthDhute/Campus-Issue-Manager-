package com.smartcampus.issuemanager.dto;

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
public class InvestigationResponse {

    private UUID id;
    private UUID issueId;
    private UUID investigatorId;
    private String investigatorName;
    private String investigatorRole;
    private String observations;
    private String actionsTaken;
    private String findings;
    private String followUp;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;
}
