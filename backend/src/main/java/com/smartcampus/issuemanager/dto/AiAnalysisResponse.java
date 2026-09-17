package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.AiAnalysisStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiAnalysisResponse {
    private UUID id;
    private UUID issueId;
    private String issueNumber;
    private AiAnalysisStatus status;
    private String model;
    private String summary;
    private String missingInformation;
    private BigDecimal confidence;
    @Builder.Default
    private List<AiRecommendationResponse> recommendations = new ArrayList<>();
    private OffsetDateTime createdAt;
    private OffsetDateTime completedAt;
}
