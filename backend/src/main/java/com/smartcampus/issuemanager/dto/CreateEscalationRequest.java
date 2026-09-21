package com.smartcampus.issuemanager.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateEscalationRequest {

    @Min(1)
    @Max(3)
    @Builder.Default
    private Integer level = 1;

    @NotBlank(message = "Escalation reason is required")
    private String reason;
}
