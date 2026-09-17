package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.IssuePriority;
import com.smartcampus.issuemanager.entity.IssueStatus;
import com.smartcampus.issuemanager.entity.RelationshipType;
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
public class RelatedIssueResponse {
    private UUID relationshipId;
    private UUID issueId;
    private String issueNumber;
    private String title;
    private String location;
    private String categoryName;
    private IssueStatus status;
    private IssuePriority priority;
    private RelationshipType relationshipType;
    private BigDecimal confidence;
    private String explanation;
    private OffsetDateTime createdAt;
}
