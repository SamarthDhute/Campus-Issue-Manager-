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
public class AuditEventResponse {
    private UUID id;
    private UUID actorId;
    private String actorName;
    private String actorRole;
    private String entityType;
    private UUID entityId;
    private String eventType;
    private String actionSummary;
    private String beforeData;
    private String afterData;
    private String metadata;
    private String ipAddress;
    private OffsetDateTime createdAt;
}
