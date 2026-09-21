package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.RiskEventResponse;
import com.smartcampus.issuemanager.entity.Issue;
import com.smartcampus.issuemanager.entity.RiskEvent;

import java.util.List;
import java.util.UUID;

public interface RiskAssessmentService {

    List<RiskEvent> evaluateIssueRisks(Issue issue);

    List<RiskEventResponse> getActiveRisksForIssue(UUID issueId);

    void resolveRisk(UUID issueId, UUID riskEventId);
}
