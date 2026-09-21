package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.CreateEscalationRequest;
import com.smartcampus.issuemanager.dto.EscalationResponse;
import com.smartcampus.issuemanager.entity.Issue;
import com.smartcampus.issuemanager.entity.User;

import java.util.List;
import java.util.UUID;

public interface EscalationService {

    EscalationResponse createManualEscalation(UUID issueId, CreateEscalationRequest request, User user);

    void triggerAutoEscalation(Issue issue, Integer level, String reason);

    List<EscalationResponse> getEscalationsForIssue(UUID issueId);

    void resolveOpenEscalations(UUID issueId);
}
