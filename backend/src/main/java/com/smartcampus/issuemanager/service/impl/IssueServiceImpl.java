package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.entity.*;
import com.smartcampus.issuemanager.exception.BadRequestException;
import com.smartcampus.issuemanager.exception.ResourceNotFoundException;
import com.smartcampus.issuemanager.repository.*;
import com.smartcampus.issuemanager.service.IssueService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class IssueServiceImpl implements IssueService {

    private final IssueRepository issueRepository;
    private final CategoryRepository categoryRepository;
    private final TeamRepository teamRepository;
    private final UserRepository userRepository;
    private final IssueTimelineEventRepository timelineEventRepository;

    @Override
    @Transactional
    public IssueResponse createIssue(CreateIssueRequest request, UUID currentUserId) {
        User currentUser = getUser(currentUserId);

        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found with ID: " + request.getCategoryId()));

        String issueNumber = generateIssueNumber();

        Issue issue = Issue.builder()
                .issueNumber(issueNumber)
                .title(request.getTitle().trim())
                .description(request.getDescription().trim())
                .category(category)
                .location(request.getLocation().trim())
                .requester(currentUser)
                .priority(request.getPriority() != null ? request.getPriority() : IssuePriority.MEDIUM)
                .status(IssueStatus.REPORTED)
                .build();

        Issue savedIssue = issueRepository.save(issue);

        // Record Initial Timeline Event
        IssueTimelineEvent timelineEvent = IssueTimelineEvent.builder()
                .issue(savedIssue)
                .eventType(TimelineEventType.CREATED)
                .actor(currentUser)
                .description("Issue reported by " + currentUser.getDisplayName() + " (" + currentUser.getRole() + ")")
                .build();
        timelineEventRepository.save(timelineEvent);

        return mapToResponse(savedIssue);
    }

    @Override
    @Transactional(readOnly = true)
    public List<IssueResponse> getIssues(IssueStatus status, UUID categoryId, Boolean myIssues, Boolean assignedToMe, UUID currentUserId) {
        User currentUser = getUser(currentUserId);
        List<Issue> issues;

        if (currentUser.getRole() == Role.STUDENT || Boolean.TRUE.equals(myIssues)) {
            issues = issueRepository.findByRequesterIdOrderByCreatedAtDesc(currentUser.getId());
        } else if (Boolean.TRUE.equals(assignedToMe) || currentUser.getRole() == Role.OPERATOR) {
            if (Boolean.TRUE.equals(assignedToMe)) {
                issues = issueRepository.findByAssignedUserIdOrderByCreatedAtDesc(currentUser.getId());
            } else {
                // Return all issues for operator to review queues
                issues = issueRepository.findAll();
                issues.sort(Comparator.comparing(Issue::getCreatedAt).reversed());
            }
        } else {
            issues = issueRepository.findAll();
            issues.sort(Comparator.comparing(Issue::getCreatedAt).reversed());
        }

        return issues.stream()
                .filter(i -> status == null || i.getStatus() == status)
                .filter(i -> categoryId == null || (i.getCategory() != null && i.getCategory().getId().equals(categoryId)))
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public IssueResponse getIssueById(UUID id, UUID currentUserId) {
        User currentUser = getUser(currentUserId);
        Issue issue = issueRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found with ID: " + id));

        // Requesters can only view their own issues unless staff
        if (currentUser.getRole() == Role.STUDENT && !issue.getRequester().getId().equals(currentUser.getId())) {
            throw new BadRequestException("Access denied: You are not authorized to view this issue");
        }

        return mapToResponse(issue);
    }

    @Override
    @Transactional
    public IssueResponse updateStatus(UUID id, UpdateIssueStatusRequest request, UUID currentUserId) {
        User currentUser = getUser(currentUserId);
        Issue issue = issueRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found with ID: " + id));

        validateStatusTransition(issue.getStatus(), request.getStatus(), currentUser.getRole());

        IssueStatus oldStatus = issue.getStatus();
        issue.setStatus(request.getStatus());
        Issue updatedIssue = issueRepository.save(issue);

        String desc = "Status updated from " + oldStatus + " to " + request.getStatus();
        if (request.getComment() != null && !request.getComment().trim().isEmpty()) {
            desc += ". Note: " + request.getComment().trim();
        }

        IssueTimelineEvent timelineEvent = IssueTimelineEvent.builder()
                .issue(updatedIssue)
                .eventType(TimelineEventType.STATUS_CHANGED)
                .actor(currentUser)
                .description(desc)
                .build();
        timelineEventRepository.save(timelineEvent);

        return mapToResponse(updatedIssue);
    }

    @Override
    @Transactional
    public IssueResponse assignIssue(UUID id, AssignIssueRequest request, UUID currentUserId) {
        User currentUser = getUser(currentUserId);
        Issue issue = issueRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found with ID: " + id));

        if (currentUser.getRole() == Role.STUDENT) {
            throw new BadRequestException("Students cannot assign or reassign issues");
        }

        Team assignedTeam = null;
        if (request.getAssignedTeamId() != null) {
            assignedTeam = teamRepository.findById(request.getAssignedTeamId())
                    .orElseThrow(() -> new ResourceNotFoundException("Team not found with ID: " + request.getAssignedTeamId()));
            issue.setAssignedTeam(assignedTeam);
        }

        User assignedUser = null;
        if (request.getAssignedUserId() != null) {
            assignedUser = userRepository.findById(request.getAssignedUserId())
                    .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + request.getAssignedUserId()));
            issue.setAssignedUser(assignedUser);
        }

        if (issue.getStatus() == IssueStatus.REPORTED || issue.getStatus() == IssueStatus.UNDERSTOOD) {
            issue.setStatus(IssueStatus.ASSIGNED);
        }

        Issue updatedIssue = issueRepository.save(issue);

        StringBuilder desc = new StringBuilder("Assigned by ").append(currentUser.getDisplayName());
        if (assignedTeam != null) {
            desc.append(" to Team: ").append(assignedTeam.getName());
        }
        if (assignedUser != null) {
            desc.append(" (Operator: ").append(assignedUser.getDisplayName()).append(")");
        }
        if (request.getComment() != null && !request.getComment().trim().isEmpty()) {
            desc.append(". Note: ").append(request.getComment().trim());
        }

        IssueTimelineEvent timelineEvent = IssueTimelineEvent.builder()
                .issue(updatedIssue)
                .eventType(TimelineEventType.ASSIGNED)
                .actor(currentUser)
                .description(desc.toString())
                .build();
        timelineEventRepository.save(timelineEvent);

        return mapToResponse(updatedIssue);
    }

    @Override
    @Transactional(readOnly = true)
    public List<TimelineEventResponse> getIssueTimeline(UUID id, UUID currentUserId) {
        // verify issue existence and permissions
        getIssueById(id, currentUserId);

        List<IssueTimelineEvent> events = timelineEventRepository.findByIssueIdOrderByCreatedAtDesc(id);
        return events.stream()
                .map(this::mapTimelineEvent)
                .collect(Collectors.toList());
    }

    private User getUser(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + userId));
    }

    private synchronized String generateIssueNumber() {
        String year = String.valueOf(LocalDate.now().getYear());
        long count = issueRepository.countByYear(year) + 1;
        return String.format("ISS-%s-%04d", year, count);
    }

    private void validateStatusTransition(IssueStatus current, IssueStatus next, Role actorRole) {
        if (current == next) return;

        // Requester permissions
        if (actorRole == Role.STUDENT) {
            if ((current == IssueStatus.RESOLUTION_PROPOSED || current == IssueStatus.RESOLVED_PENDING_CONFIRMATION) &&
                (next == IssueStatus.CONFIRMED || next == IssueStatus.CLOSED || next == IssueStatus.REOPENED)) {
                return;
            }
            if (next == IssueStatus.CANCELLED && current == IssueStatus.REPORTED) {
                return;
            }
            throw new BadRequestException("Students cannot transition issue status from " + current + " to " + next);
        }

        // Staff permissions (Operator, Team Lead, Campus Manager, Admin)
        boolean valid = switch (current) {
            case REPORTED -> next == IssueStatus.UNDERSTOOD || next == IssueStatus.INVESTIGATING || next == IssueStatus.INVESTIGATED || next == IssueStatus.ASSIGNED || next == IssueStatus.CANCELLED || next == IssueStatus.DUPLICATE || next == IssueStatus.WAITING_FOR_INFORMATION;
            case UNDERSTOOD -> next == IssueStatus.ASSIGNED || next == IssueStatus.INVESTIGATING || next == IssueStatus.INVESTIGATED || next == IssueStatus.DUPLICATE || next == IssueStatus.WAITING_FOR_INFORMATION;
            case ASSIGNED -> next == IssueStatus.INVESTIGATING || next == IssueStatus.INVESTIGATED || next == IssueStatus.ACTION_SCHEDULED || next == IssueStatus.ACTION_IN_PROGRESS || next == IssueStatus.ACTION_TAKEN || next == IssueStatus.ESCALATED || next == IssueStatus.WAITING_FOR_INFORMATION;
            case INVESTIGATING, INVESTIGATED -> next == IssueStatus.ACTION_SCHEDULED || next == IssueStatus.ACTION_IN_PROGRESS || next == IssueStatus.ACTION_TAKEN || next == IssueStatus.RESOLVED_PENDING_CONFIRMATION || next == IssueStatus.RESOLUTION_PROPOSED || next == IssueStatus.ESCALATED || next == IssueStatus.WAITING_FOR_INFORMATION;
            case ACTION_SCHEDULED -> next == IssueStatus.ACTION_IN_PROGRESS || next == IssueStatus.ACTION_TAKEN || next == IssueStatus.INVESTIGATING || next == IssueStatus.INVESTIGATED || next == IssueStatus.ESCALATED;
            case ACTION_IN_PROGRESS, ACTION_TAKEN -> next == IssueStatus.RESOLVED_PENDING_CONFIRMATION || next == IssueStatus.RESOLUTION_PROPOSED || next == IssueStatus.INVESTIGATING || next == IssueStatus.INVESTIGATED || next == IssueStatus.ESCALATED;
            case RESOLVED_PENDING_CONFIRMATION, RESOLUTION_PROPOSED -> next == IssueStatus.CONFIRMED || next == IssueStatus.CLOSED || next == IssueStatus.REOPENED || next == IssueStatus.INVESTIGATING;
            case CONFIRMED -> next == IssueStatus.CLOSED || next == IssueStatus.REOPENED;
            case CLOSED -> next == IssueStatus.REOPENED;
            case WAITING_FOR_INFORMATION -> next == IssueStatus.UNDERSTOOD || next == IssueStatus.INVESTIGATING || next == IssueStatus.INVESTIGATED || next == IssueStatus.ACTION_IN_PROGRESS || next == IssueStatus.ACTION_TAKEN;
            case ESCALATED -> next == IssueStatus.ASSIGNED || next == IssueStatus.INVESTIGATING || next == IssueStatus.INVESTIGATED || next == IssueStatus.ACTION_IN_PROGRESS || next == IssueStatus.ACTION_TAKEN;
            case REOPENED -> next == IssueStatus.ASSIGNED || next == IssueStatus.INVESTIGATING || next == IssueStatus.INVESTIGATED;
            case CANCELLED, DUPLICATE -> false;
        };

        if (!valid && actorRole != Role.ADMIN && actorRole != Role.CAMPUS_MANAGER && actorRole != Role.MANAGER) {
            throw new BadRequestException("Invalid state transition from " + current + " to " + next);
        }
    }

    private IssueResponse mapToResponse(Issue issue) {
        List<TimelineEventResponse> timeline = issue.getTimelineEvents() != null
                ? issue.getTimelineEvents().stream().map(this::mapTimelineEvent).collect(Collectors.toList())
                : Collections.emptyList();

        return IssueResponse.builder()
                .id(issue.getId())
                .issueNumber(issue.getIssueNumber())
                .title(issue.getTitle())
                .description(issue.getDescription())
                .categoryId(issue.getCategory() != null ? issue.getCategory().getId() : null)
                .categoryName(issue.getCategory() != null ? issue.getCategory().getName() : null)
                .location(issue.getLocation())
                .requesterId(issue.getRequester().getId())
                .requesterName(issue.getRequester().getDisplayName())
                .requesterEmail(issue.getRequester().getEmail())
                .assignedTeamId(issue.getAssignedTeam() != null ? issue.getAssignedTeam().getId() : null)
                .assignedTeamName(issue.getAssignedTeam() != null ? issue.getAssignedTeam().getName() : null)
                .assignedUserId(issue.getAssignedUser() != null ? issue.getAssignedUser().getId() : null)
                .assignedUserName(issue.getAssignedUser() != null ? issue.getAssignedUser().getDisplayName() : null)
                .status(issue.getStatus())
                .priority(issue.getPriority())
                .timeline(timeline)
                .createdAt(issue.getCreatedAt())
                .updatedAt(issue.getUpdatedAt())
                .build();
    }

    private TimelineEventResponse mapTimelineEvent(IssueTimelineEvent event) {
        return TimelineEventResponse.builder()
                .id(event.getId())
                .eventType(event.getEventType())
                .actorId(event.getActor() != null ? event.getActor().getId() : null)
                .actorName(event.getActor() != null ? event.getActor().getDisplayName() : "System")
                .actorRole(event.getActor() != null ? event.getActor().getRole().name() : "SYSTEM")
                .description(event.getDescription())
                .createdAt(event.getCreatedAt())
                .build();
    }
}
