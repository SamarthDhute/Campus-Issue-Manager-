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
public class AttachmentResponse {
    private UUID id;
    private UUID issueId;
    private UUID messageId;
    private UUID uploadedByUserId;
    private String uploadedByName;
    private String storagePath;
    private String fileName;
    private String contentType;
    private Long sizeBytes;
    private String fileUrl;
    private String thumbnailUrl;
    private OffsetDateTime createdAt;
}
