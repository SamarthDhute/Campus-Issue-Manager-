package com.smartcampus.issuemanager.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InvestigationRequest {

    @NotBlank(message = "Observations cannot be blank")
    private String observations;

    private String actionsTaken;

    private String findings;

    private String followUp;
}
