package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.EvidenceType;
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
public class EvidenceResponse {
    private UUID id;
    private UUID issueId;
    private UUID uploadedByUserId;
    private String uploadedByName;
    private EvidenceType evidenceType;
    private String fileUrl;
    private String fileName;
    private Long fileSize;
    private String mimeType;
    private String notes;
    private OffsetDateTime createdAt;
}
