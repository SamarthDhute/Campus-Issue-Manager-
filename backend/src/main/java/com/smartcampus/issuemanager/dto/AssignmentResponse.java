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
public class AssignmentResponse {

    private UUID id;
    private UUID issueId;
    private UUID teamId;
    private String teamName;
    private UUID userId;
    private String userName;
    private String userEmail;
    private String assignmentType;
    private String recommendationSource;
    private String reason;
    private UUID assignedById;
    private String assignedByName;
    private OffsetDateTime assignedAt;
    private OffsetDateTime endedAt;
    private boolean active;
}
