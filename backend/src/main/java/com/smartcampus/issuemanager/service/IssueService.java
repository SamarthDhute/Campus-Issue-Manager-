package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.entity.IssueStatus;

import java.util.List;
import java.util.UUID;

public interface IssueService {

    IssueResponse createIssue(CreateIssueRequest request, UUID currentUserId);

    List<IssueResponse> getIssues(IssueStatus status, UUID categoryId, Boolean myIssues, Boolean assignedToMe, UUID currentUserId);

    IssueResponse getIssueById(UUID id, UUID currentUserId);

    IssueResponse updateStatus(UUID id, UpdateIssueStatusRequest request, UUID currentUserId);

    IssueResponse assignIssue(UUID id, AssignIssueRequest request, UUID currentUserId);

    List<TimelineEventResponse> getIssueTimeline(UUID id, UUID currentUserId);
}
