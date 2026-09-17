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
public class TaskUpdateRequest {

    private String title;
    private String description;
    private UUID ownerId;
    private TaskStatus status;
    private OffsetDateTime dueAt;
}
