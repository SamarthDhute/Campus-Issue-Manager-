package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.RecommendationDecision;
import com.smartcampus.issuemanager.entity.RecommendationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiRecommendationResponse {
    private UUID id;
    private UUID analysisId;
    private UUID issueId;
    private RecommendationType recommendationType;
    private String suggestedValue;
    private BigDecimal confidence;
    private String explanation;
    private RecommendationDecision decision;
    private UUID decidedById;
    private String decidedByName;
    private OffsetDateTime decidedAt;
    private OffsetDateTime createdAt;
}
