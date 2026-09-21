package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.EvidenceType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UploadEvidenceRequest {

    @NotNull(message = "Evidence type is required")
    private EvidenceType evidenceType;

    @NotBlank(message = "File URL or storage path is required")
    private String fileUrl;

    @NotBlank(message = "File name is required")
    private String fileName;

    private Long fileSize;

    private String mimeType;

    private String notes;
}
