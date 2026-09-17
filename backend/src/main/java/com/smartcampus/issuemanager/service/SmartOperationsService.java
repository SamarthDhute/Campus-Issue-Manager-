package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.*;

import java.util.List;
import java.util.UUID;

public interface SmartOperationsService {

    AssignmentRecommendationResponse recommendAssignment(UUID issueId);

    AssignmentResponse assignIssue(UUID issueId, AssignmentRequest request, UUID currentUserId);

    List<AssignmentResponse> getAssignmentHistory(UUID issueId);

    IssueMessageResponse addMessage(UUID issueId, IssueMessageRequest request, UUID currentUserId);

    List<IssueMessageResponse> getMessages(UUID issueId, UUID currentUserId);

    InternalNoteResponse addInternalNote(UUID issueId, InternalNoteRequest request, UUID currentUserId);

    List<InternalNoteResponse> getInternalNotes(UUID issueId, UUID currentUserId);

    InvestigationResponse createInvestigation(UUID issueId, InvestigationRequest request, UUID currentUserId);

    List<InvestigationResponse> getInvestigations(UUID issueId);

    TaskResponse createTask(UUID issueId, TaskCreateRequest request, UUID currentUserId);

    TaskResponse updateTask(UUID taskId, TaskUpdateRequest request, UUID currentUserId);

    List<TaskResponse> getTasks(UUID issueId);
}
