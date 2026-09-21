package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.IssueSlaResponse;
import com.smartcampus.issuemanager.entity.Issue;
import com.smartcampus.issuemanager.entity.IssueSla;
import com.smartcampus.issuemanager.entity.IssueStatus;

import java.util.UUID;

public interface SlaService {

    IssueSla initializeIssueSla(Issue issue);

    IssueSlaResponse getIssueSla(UUID issueId);

    void onIssueStatusChanged(Issue issue, IssueStatus oldStatus, IssueStatus newStatus);

    IssueSla evaluateAndRefreshSla(IssueSla sla);
}
