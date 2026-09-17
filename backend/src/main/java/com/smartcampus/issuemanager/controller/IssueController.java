package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.entity.IssueStatus;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.IssueService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
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
@RequestMapping("/api/v1/issues")
@RequiredArgsConstructor
@Tag(name = "Issue Management", description = "Core Issue Lifecycle APIs")
@SecurityRequirement(name = "bearerAuth")
public class IssueController {

    private final IssueService issueService;

    @PostMapping
    @Operation(summary = "Create a new campus issue")
    public ResponseEntity<IssueResponse> createIssue(
            @Valid @RequestBody CreateIssueRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        IssueResponse response = issueService.createIssue(request, currentUser.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    @Operation(summary = "List permitted issues with optional filters")
    public ResponseEntity<List<IssueResponse>> getIssues(
            @RequestParam(required = false) IssueStatus status,
            @RequestParam(required = false) UUID categoryId,
            @RequestParam(required = false) Boolean myIssues,
            @RequestParam(required = false) Boolean assignedToMe,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        List<IssueResponse> issues = issueService.getIssues(status, categoryId, myIssues, assignedToMe, currentUser.getId());
        return ResponseEntity.ok(issues);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get issue details by ID")
    public ResponseEntity<IssueResponse> getIssueById(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        IssueResponse response = issueService.getIssueById(id, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Update issue lifecycle status")
    public ResponseEntity<IssueResponse> updateStatus(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateIssueStatusRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        IssueResponse response = issueService.updateStatus(id, request, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/assign")
    @Operation(summary = "Assign or reassign issue to team / operator")
    public ResponseEntity<IssueResponse> assignIssue(
            @PathVariable UUID id,
            @RequestBody AssignIssueRequest request,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        IssueResponse response = issueService.assignIssue(id, request, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/timeline")
    @Operation(summary = "Get immutable timeline history of an issue")
    public ResponseEntity<List<TimelineEventResponse>> getIssueTimeline(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal currentUser) {
        List<TimelineEventResponse> timeline = issueService.getIssueTimeline(id, currentUser.getId());
        return ResponseEntity.ok(timeline);
    }
}
