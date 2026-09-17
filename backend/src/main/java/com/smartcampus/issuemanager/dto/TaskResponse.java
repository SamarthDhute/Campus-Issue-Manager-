package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.TaskStatus;
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
public class TaskResponse {

    private UUID id;
    private UUID issueId;
    private String title;
    private String description;
    private UUID ownerId;
    private String ownerName;
    private String ownerEmail;
    private TaskStatus status;
    private OffsetDateTime dueAt;
    private OffsetDateTime completedAt;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;
}
