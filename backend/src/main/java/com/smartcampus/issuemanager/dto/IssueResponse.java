package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.IssuePriority;
import com.smartcampus.issuemanager.entity.IssueStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class IssueResponse {

    private UUID id;
    private String issueNumber;
    private String title;
    private String description;
    
    private UUID categoryId;
    private String categoryName;

    private String location;

    private UUID requesterId;
    private String requesterName;
    private String requesterEmail;

    private UUID assignedTeamId;
    private String assignedTeamName;

    private UUID assignedUserId;
    private String assignedUserName;

    private IssueStatus status;
    private IssuePriority priority;

    private List<TimelineEventResponse> timeline;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;
}
