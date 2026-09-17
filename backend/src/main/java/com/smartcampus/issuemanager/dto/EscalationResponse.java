package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.EscalationStatus;
import com.smartcampus.issuemanager.entity.EscalationTrigger;
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
public class EscalationResponse {

    private UUID id;
    private UUID issueId;
    private EscalationTrigger triggerType;
    private Integer level;
    private EscalationStatus status;
    private String reason;
    private UUID triggeredById;
    private String triggeredByName;
    private String triggeredByRole;
    private OffsetDateTime triggeredAt;
    private OffsetDateTime resolvedAt;
}
