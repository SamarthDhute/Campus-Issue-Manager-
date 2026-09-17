package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.SmartOperationsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Tag(name = "Smart Operations", description = "Workload dispatch, assignments, sub-tasks, investigations, internal notes and messaging APIs")
public class OperationsController {

    private final SmartOperationsService operationsService;

    @RequestMapping(value = "/issues/{id}/assignment-recommendation", method = {RequestMethod.GET, RequestMethod.POST})
    @Operation(summary = "Get intelligent operator assignment recommendation based on workload and skills")
    public ResponseEntity<AssignmentRecommendationResponse> getAssignmentRecommendation(@PathVariable UUID id) {
        AssignmentRecommendationResponse response = operationsService.recommendAssignment(id);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/issues/{id}/dispatch")
    @Operation(summary = "Assign or reassign an issue to an operator/team")
    public ResponseEntity<AssignmentResponse> assignIssue(
            @PathVariable UUID id,
            @Valid @RequestBody AssignmentRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        UUID userId = currentUser != null ? currentUser.getId() : null;
        AssignmentResponse response = operationsService.assignIssue(id, request, userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/issues/{id}/assignments")
    @Operation(summary = "Get full assignment and reassignment history for an issue")
    public ResponseEntity<List<AssignmentResponse>> getAssignmentHistory(@PathVariable UUID id) {
        List<AssignmentResponse> response = operationsService.getAssignmentHistory(id);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/issues/{id}/messages")
    @Operation(summary = "Send a public requester/staff message")
    public ResponseEntity<IssueMessageResponse> addMessage(
            @PathVariable UUID id,
            @Valid @RequestBody IssueMessageRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        UUID userId = currentUser != null ? currentUser.getId() : null;
        IssueMessageResponse response = operationsService.addMessage(id, request, userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/issues/{id}/messages")
    @Operation(summary = "Get communication messages for an issue")
    public ResponseEntity<List<IssueMessageResponse>> getMessages(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        UUID userId = currentUser != null ? currentUser.getId() : null;
        List<IssueMessageResponse> response = operationsService.getMessages(id, userId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/issues/{id}/internal-notes")
    @Operation(summary = "Add a private internal staff note (Staff only)")
    public ResponseEntity<InternalNoteResponse> addInternalNote(
            @PathVariable UUID id,
            @Valid @RequestBody InternalNoteRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        UUID userId = currentUser != null ? currentUser.getId() : null;
        InternalNoteResponse response = operationsService.addInternalNote(id, request, userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/issues/{id}/internal-notes")
    @Operation(summary = "Get private internal staff notes for an issue (Staff only)")
    public ResponseEntity<List<InternalNoteResponse>> getInternalNotes(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        UUID userId = currentUser != null ? currentUser.getId() : null;
        List<InternalNoteResponse> response = operationsService.getInternalNotes(id, userId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/issues/{id}/investigations")
    @Operation(summary = "Submit a field investigation report (Staff only)")
    public ResponseEntity<InvestigationResponse> createInvestigation(
            @PathVariable UUID id,
            @Valid @RequestBody InvestigationRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        UUID userId = currentUser != null ? currentUser.getId() : null;
        InvestigationResponse response = operationsService.createInvestigation(id, request, userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/issues/{id}/investigations")
    @Operation(summary = "Get field investigation reports for an issue")
    public ResponseEntity<List<InvestigationResponse>> getInvestigations(@PathVariable UUID id) {
        List<InvestigationResponse> response = operationsService.getInvestigations(id);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/issues/{id}/tasks")
    @Operation(summary = "Create an operational sub-task for an issue")
    public ResponseEntity<TaskResponse> createTask(
            @PathVariable UUID id,
            @Valid @RequestBody TaskCreateRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        UUID userId = currentUser != null ? currentUser.getId() : null;
        TaskResponse response = operationsService.createTask(id, request, userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/issues/{id}/tasks")
    @Operation(summary = "Get all sub-tasks for an issue")
    public ResponseEntity<List<TaskResponse>> getTasks(@PathVariable UUID id) {
        List<TaskResponse> response = operationsService.getTasks(id);
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/tasks/{taskId}")
    @Operation(summary = "Update status, assignee, or details of a sub-task")
    public ResponseEntity<TaskResponse> updateTask(
            @PathVariable UUID taskId,
            @Valid @RequestBody TaskUpdateRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        UUID userId = currentUser != null ? currentUser.getId() : null;
        TaskResponse response = operationsService.updateTask(taskId, request, userId);
        return ResponseEntity.ok(response);
    }
}
