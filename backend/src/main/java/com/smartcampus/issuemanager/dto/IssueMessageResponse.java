package com.smartcampus.issuemanager.dto;

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
public class IssueMessageResponse {

    private UUID id;
    private UUID issueId;
    private UUID senderId;
    private String senderName;
    private String senderRole;
    private String messageType;
    private String body;
    private String visibility;
    private OffsetDateTime createdAt;
}
