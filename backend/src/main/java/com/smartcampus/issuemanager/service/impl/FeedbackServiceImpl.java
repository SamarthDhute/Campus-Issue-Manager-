package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.FeedbackResponse;
import com.smartcampus.issuemanager.dto.IssueResponse;
import com.smartcampus.issuemanager.dto.ReopenIssueRequest;
import com.smartcampus.issuemanager.dto.SubmitFeedbackRequest;
import com.smartcampus.issuemanager.entity.*;
import com.smartcampus.issuemanager.exception.BadRequestException;
import com.smartcampus.issuemanager.exception.ResourceNotFoundException;
import com.smartcampus.issuemanager.repository.IssueFeedbackRepository;
import com.smartcampus.issuemanager.repository.IssueRepository;
import com.smartcampus.issuemanager.repository.IssueTimelineEventRepository;
import com.smartcampus.issuemanager.repository.UserRepository;
import com.smartcampus.issuemanager.service.FeedbackService;
import com.smartcampus.issuemanager.service.NotificationService;
import com.smartcampus.issuemanager.service.SlaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class FeedbackServiceImpl implements FeedbackService {

    private final IssueFeedbackRepository feedbackRepository;
    private final IssueRepository issueRepository;
    private final IssueTimelineEventRepository timelineEventRepository;
    private final UserRepository userRepository;
    private final SlaService slaService;
    private final NotificationService notificationService;

    @Override
    @Transactional
    public FeedbackResponse submitFeedback(UUID issueId, SubmitFeedbackRequest request, UUID currentUserId) {
        Issue issue = issueRepository.findById(issueId)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found with ID: " + issueId));

        User currentUser = userRepository.findById(currentUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + currentUserId));

        if (!issue.getRequester().getId().equals(currentUserId) &&
            currentUser.getRole() != Role.ADMIN && currentUser.getRole() != Role.MANAGER) {
            throw new BadRequestException("Only the issue requester can submit resolution feedback and sign off");
        }

        IssueFeedback feedback = feedbackRepository.findByIssueId(issueId)
                .orElse(IssueFeedback.builder().issue(issue).submittedBy(currentUser).build());

        feedback.setRating(request.getRating());
        feedback.setFeedbackText(request.getFeedbackText());
        feedback.setResolutionQuality(request.getResolutionQuality());
        feedback.setReopenedReason(null);

        IssueFeedback saved = feedbackRepository.save(feedback);

        IssueStatus oldStatus = issue.getStatus();
        issue.setStatus(IssueStatus.CLOSED);
        issueRepository.save(issue);

        // Record Milestone in SLA Service
        slaService.onIssueStatusChanged(issue, oldStatus, IssueStatus.CLOSED);

        // Audit timeline
        IssueTimelineEvent timelineEvent = IssueTimelineEvent.builder()
                .issue(issue)
                .actor(currentUser)
                .eventType(TimelineEventType.STATUS_CHANGED)
                .description("Resolution verified & confirmed by " + currentUser.getDisplayName() + ". Rating: " + request.getRating() + "/5 stars.")
                .build();
        timelineEventRepository.save(timelineEvent);

        // Notify assigned staff
        if (issue.getAssignedUser() != null) {
            notificationService.sendNotification(
                    issue.getAssignedUser(),
                    issue,
                    NotificationType.ISSUE_RESOLVED,
                    "Resolution Confirmed: " + issue.getIssueNumber(),
                    "Requester confirmed resolution with " + request.getRating() + "-star rating.",
                    NotificationChannel.IN_APP
            );
        }

        log.info("Issue {} closed with feedback {} stars by user {}", issue.getIssueNumber(), request.getRating(), currentUser.getEmail());
        return mapToResponse(saved);
    }

    @Override
    @Transactional
    public IssueResponse reopenIssue(UUID issueId, ReopenIssueRequest request, UUID currentUserId) {
        Issue issue = issueRepository.findById(issueId)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found with ID: " + issueId));

        User currentUser = userRepository.findById(currentUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + currentUserId));

        if (!issue.getRequester().getId().equals(currentUserId) &&
            currentUser.getRole() != Role.ADMIN && currentUser.getRole() != Role.MANAGER) {
            throw new BadRequestException("Only the issue requester can dispute and reopen this issue");
        }

        IssueFeedback feedback = feedbackRepository.findByIssueId(issueId)
                .orElse(IssueFeedback.builder().issue(issue).submittedBy(currentUser).rating(1).build());

        feedback.setReopenedReason(request.getReason());
        feedback.setResolutionQuality(ResolutionQuality.POOR);
        feedbackRepository.save(feedback);

        IssueStatus oldStatus = issue.getStatus();
        issue.setStatus(IssueStatus.REOPENED);
        Issue updated = issueRepository.save(issue);

        slaService.onIssueStatusChanged(issue, oldStatus, IssueStatus.REOPENED);

        // Audit timeline
        IssueTimelineEvent timelineEvent = IssueTimelineEvent.builder()
                .issue(issue)
                .actor(currentUser)
                .eventType(TimelineEventType.STATUS_CHANGED)
                .description("Issue disputed & reopened by " + currentUser.getDisplayName() + ". Reason: " + request.getReason())
                .build();
        timelineEventRepository.save(timelineEvent);

        // Notify assigned operator
        if (issue.getAssignedUser() != null) {
            notificationService.sendNotification(
                    issue.getAssignedUser(),
                    issue,
                    NotificationType.ESCALATION_TRIGGERED,
                    "Issue Reopened: " + issue.getIssueNumber(),
                    "Requester disputed resolution: " + request.getReason(),
                    NotificationChannel.IN_APP
            );
        }

        log.warn("Issue {} reopened by user {}. Reason: {}", issue.getIssueNumber(), currentUser.getEmail(), request.getReason());

        return IssueResponse.builder()
                .id(updated.getId())
                .issueNumber(updated.getIssueNumber())
                .title(updated.getTitle())
                .description(updated.getDescription())
                .categoryId(updated.getCategory() != null ? updated.getCategory().getId() : null)
                .categoryName(updated.getCategory() != null ? updated.getCategory().getName() : null)
                .location(updated.getLocation())
                .requesterId(updated.getRequester().getId())
                .requesterName(updated.getRequester().getDisplayName())
                .requesterEmail(updated.getRequester().getEmail())
                .assignedTeamId(updated.getAssignedTeam() != null ? updated.getAssignedTeam().getId() : null)
                .assignedTeamName(updated.getAssignedTeam() != null ? updated.getAssignedTeam().getName() : null)
                .assignedUserId(updated.getAssignedUser() != null ? updated.getAssignedUser().getId() : null)
                .assignedUserName(updated.getAssignedUser() != null ? updated.getAssignedUser().getDisplayName() : null)
                .status(updated.getStatus())
                .priority(updated.getPriority())
                .createdAt(updated.getCreatedAt())
                .updatedAt(updated.getUpdatedAt())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public FeedbackResponse getFeedbackByIssueId(UUID issueId) {
        return feedbackRepository.findByIssueId(issueId)
                .map(this::mapToResponse)
                .orElse(null);
    }

    private FeedbackResponse mapToResponse(IssueFeedback fb) {
        return FeedbackResponse.builder()
                .id(fb.getId())
                .issueId(fb.getIssue().getId())
                .submittedByUserId(fb.getSubmittedBy().getId())
                .submittedByName(fb.getSubmittedBy().getDisplayName())
                .rating(fb.getRating())
                .feedbackText(fb.getFeedbackText())
                .resolutionQuality(fb.getResolutionQuality())
                .reopenedReason(fb.getReopenedReason())
                .createdAt(fb.getCreatedAt())
                .build();
    }
}
