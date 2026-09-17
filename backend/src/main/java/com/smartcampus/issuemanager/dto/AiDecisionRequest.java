package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.RecommendationDecision;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiDecisionRequest {
    @NotNull(message = "Decision is required")
    private RecommendationDecision decision; // ACCEPTED, REJECTED, OVERRIDDEN
    
    private String overrideValue;
    private String comments;
}
