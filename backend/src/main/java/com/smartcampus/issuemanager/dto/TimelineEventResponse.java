package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.TimelineEventType;
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
public class TimelineEventResponse {

    private UUID id;
    private TimelineEventType eventType;
    private UUID actorId;
    private String actorName;
    private String actorRole;
    private String description;
    private OffsetDateTime createdAt;
}
