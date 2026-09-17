package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.entity.IssueStatus;
import com.smartcampus.issuemanager.entity.User;

import java.util.List;
import java.util.UUID;

public interface IssueService {

    IssueResponse createIssue(CreateIssueRequest request, User currentUser);

    List<IssueResponse> getIssues(IssueStatus status, UUID categoryId, Boolean myIssues, Boolean assignedToMe, User currentUser);

    IssueResponse getIssueById(UUID id, User currentUser);

    IssueResponse updateStatus(UUID id, UpdateIssueStatusRequest request, User currentUser);

    IssueResponse assignIssue(UUID id, AssignIssueRequest request, User currentUser);

    List<TimelineEventResponse> getIssueTimeline(UUID id, User currentUser);
}
