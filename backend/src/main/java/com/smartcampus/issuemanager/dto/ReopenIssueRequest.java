package com.smartcampus.issuemanager.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReopenIssueRequest {

    @NotBlank(message = "Reopening reason is required")
    @Size(min = 5, max = 2000, message = "Reason must be between 5 and 2000 characters")
    private String reason;
}
