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
public class SecurityEventResponse {
    private UUID id;
    private UUID actorId;
    private String actorEmail;
    private String eventType;
    private String severity;
    private String metadata;
    private String ipAddress;
    private OffsetDateTime createdAt;
}
