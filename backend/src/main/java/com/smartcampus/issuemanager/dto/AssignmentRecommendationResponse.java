package com.smartcampus.issuemanager.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AssignmentRecommendationResponse {

    private UUID issueId;
    private UUID recommendedTeamId;
    private String recommendedTeamName;
    private UUID recommendedUserId;
    private String recommendedUserName;
    private String recommendedUserEmail;
    private BigDecimal matchScore;
    private String rationale;
    private int currentActiveWorkload;
    private List<CandidateOperator> alternateCandidates;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CandidateOperator {
        private UUID userId;
        private String name;
        private String email;
        private UUID teamId;
        private String teamName;
        private int activeTasksCount;
        private BigDecimal matchScore;
        private String reason;
    }
}
