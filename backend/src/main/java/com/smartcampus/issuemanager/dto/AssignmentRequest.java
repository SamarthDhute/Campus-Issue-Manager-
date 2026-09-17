package com.smartcampus.issuemanager.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AssignmentRequest {

    private UUID teamId;

    @NotNull(message = "User ID (technician) cannot be null")
    private UUID userId;

    private String assignmentType; // PRIMARY, SECONDARY, ESCALATED

    private String recommendationSource; // MANUAL, AI_RECOMMENDED, AUTO_DISPATCH

    private String reason;
}
