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
public class IssueMessageRequest {

    @NotBlank(message = "Message body cannot be blank")
    private String body;

    private String messageType; // USER_MESSAGE, OPERATOR_UPDATE, SYSTEM_ALERT
}
