package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.ResolutionQuality;
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
public class FeedbackResponse {
    private UUID id;
    private UUID issueId;
    private UUID submittedByUserId;
    private String submittedByName;
    private Integer rating;
    private String feedbackText;
    private ResolutionQuality resolutionQuality;
    private String reopenedReason;
    private OffsetDateTime createdAt;
}
