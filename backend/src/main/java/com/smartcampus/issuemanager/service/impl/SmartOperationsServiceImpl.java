package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.*;
import com.smartcampus.issuemanager.entity.*;
import com.smartcampus.issuemanager.exception.BadRequestException;
import com.smartcampus.issuemanager.exception.ResourceNotFoundException;
import com.smartcampus.issuemanager.repository.*;
import com.smartcampus.issuemanager.service.SmartOperationsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SmartOperationsServiceImpl implements SmartOperationsService {

    private final IssueRepository issueRepository;
    private final UserRepository userRepository;
    private final TeamRepository teamRepository;
    private final AssignmentRepository assignmentRepository;
    private final IssueMessageRepository messageRepository;
    private final InternalNoteRepository internalNoteRepository;
    private final InvestigationRepository investigationRepository;
    private final IssueTaskRepository taskRepository;
    private final IssueTimelineEventRepository timelineEventRepository;

    @Override
    @Transactional(readOnly = true)
    public AssignmentRecommendationResponse recommendAssignment(UUID issueId) {
        Issue issue = getIssue(issueId);
        List<User> operators = userRepository.findAll().stream()
                .filter(u -> u.getRole() == Role.OPERATOR || u.getRole() == Role.TEAM_LEAD)
                .collect(Collectors.toList());

        if (operators.isEmpty()) {
            throw new ResourceNotFoundException("No operators or team leads available in system for assignment.");
        }

        List<Team> allTeams = teamRepository.findAll();
        String categoryName = issue.getCategory() != null ? issue.getCategory().getName().toLowerCase() : "";

        // Determine best matching team
        Team matchedTeam = allTeams.stream()
                .filter(t -> isTeamCategoryMatch(t.getName().toLowerCase(), categoryName))
                .findFirst()
                .orElse(allTeams.isEmpty() ? null : allTeams.get(0));

        // Evaluate each candidate's workload and score
        List<AssignmentRecommendationResponse.CandidateOperator> candidates = new ArrayList<>();

        for (User op : operators) {
            List<Assignment> activeAssignments = assignmentRepository.findByUserIdAndEndedAtIsNull(op.getId());
            int workload = activeAssignments.size();

            // Calculate matching score
            double baseScore = 0.85;
            if (matchedTeam != null && op.getTeams() != null && op.getTeams().contains(matchedTeam)) {
                baseScore = 0.95;
            }

            // Workload penalty (slight decrease per active task)
            double loadPenalty = Math.min(0.20, workload * 0.05);
            double finalScore = Math.max(0.60, baseScore - loadPenalty);

            String reason = String.format("Domain specialist with %d active assigned cases.", workload);

            candidates.add(AssignmentRecommendationResponse.CandidateOperator.builder()
                    .userId(op.getId())
                    .name(op.getDisplayName())
                    .email(op.getEmail())
                    .teamId(matchedTeam != null ? matchedTeam.getId() : null)
                    .teamName(matchedTeam != null ? matchedTeam.getName() : "General Facilities")
                    .activeTasksCount(workload)
                    .matchScore(BigDecimal.valueOf(finalScore).setScale(2, RoundingMode.HALF_UP))
                    .reason(reason)
                    .build());
        }

        // Sort by match score descending, then active tasks ascending
        candidates.sort(Comparator.comparing(AssignmentRecommendationResponse.CandidateOperator::getMatchScore).reversed()
                .thenComparing(AssignmentRecommendationResponse.CandidateOperator::getActiveTasksCount));

        AssignmentRecommendationResponse.CandidateOperator topCandidate = candidates.get(0);
        List<AssignmentRecommendationResponse.CandidateOperator> alternates = candidates.size() > 1
                ? candidates.subList(1, candidates.size())
                : Collections.emptyList();

        return AssignmentRecommendationResponse.builder()
                .issueId(issue.getId())
                .recommendedTeamId(topCandidate.getTeamId())
                .recommendedTeamName(topCandidate.getTeamName())
                .recommendedUserId(topCandidate.getUserId())
                .recommendedUserName(topCandidate.getName())
                .recommendedUserEmail(topCandidate.getEmail())
                .matchScore(topCandidate.getMatchScore())
                .rationale(String.format("Recommended %s based on specialized skill match for %s and optimized workload queue (%d active cases).",
                        topCandidate.getName(), issue.getCategory() != null ? issue.getCategory().getName() : "General", topCandidate.getActiveTasksCount()))
                .currentActiveWorkload(topCandidate.getActiveTasksCount())
                .alternateCandidates(alternates)
                .build();
    }

    private boolean isTeamCategoryMatch(String teamName, String categoryName) {
        if (categoryName.contains("plumb") || categoryName.contains("water")) {
            return teamName.contains("plumb") || teamName.contains("water");
        }
        if (categoryName.contains("electr") || categoryName.contains("power")) {
            return teamName.contains("electr") || teamName.contains("power");
        }
        if (categoryName.contains("internet") || categoryName.contains("wi-fi") || categoryName.contains("network")) {
            return teamName.contains("it") || teamName.contains("network");
        }
        if (categoryName.contains("hostel") || categoryName.contains("amenit")) {
            return teamName.contains("hostel") || teamName.contains("estate");
        }
        if (categoryName.contains("clean") || categoryName.contains("waste") || categoryName.contains("sanitat")) {
            return teamName.contains("sanitat") || teamName.contains("clean") || teamName.contains("housekeep");
        }
        return false;
    }

    @Override
    @Transactional
    public AssignmentResponse assignIssue(UUID issueId, AssignmentRequest request, UUID currentUserId) {
        Issue issue = getIssue(issueId);
        User currentUser = getUser(currentUserId);
        User targetUser = getUser(request.getUserId());

        Team team = null;
        if (request.getTeamId() != null) {
            team = teamRepository.findById(request.getTeamId()).orElse(null);
        }

        // End any active previous assignment
        assignmentRepository.findByIssueIdAndEndedAtIsNull(issueId).ifPresent(prev -> {
            prev.setEndedAt(OffsetDateTime.now());
            assignmentRepository.save(prev);
        });

        // Create new assignment record
        Assignment assignment = Assignment.builder()
                .issue(issue)
                .team(team)
                .user(targetUser)
                .assignmentType(request.getAssignmentType() != null ? request.getAssignmentType() : "PRIMARY")
                .recommendationSource(request.getRecommendationSource() != null ? request.getRecommendationSource() : "MANUAL")
                .reason(request.getReason())
                .assignedBy(currentUser)
                .build();

        Assignment savedAssignment = assignmentRepository.save(assignment);

        // Update Issue state
        issue.setAssignedUser(targetUser);
        if (team != null) {
            issue.setAssignedTeam(team);
        }
        if (issue.getStatus() == IssueStatus.REPORTED || issue.getStatus() == IssueStatus.UNDERSTOOD) {
            issue.setStatus(IssueStatus.ASSIGNED);
        }
        issueRepository.save(issue);

        // Record Timeline event
        IssueTimelineEvent timelineEvent = IssueTimelineEvent.builder()
                .issue(issue)
                .eventType(TimelineEventType.ASSIGNED)
                .actor(currentUser)
                .description(String.format("Assigned to %s (%s) by %s", targetUser.getDisplayName(), targetUser.getRole(), currentUser.getDisplayName()))
                .build();
        timelineEventRepository.save(timelineEvent);

        return mapToAssignmentResponse(savedAssignment);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AssignmentResponse> getAssignmentHistory(UUID issueId) {
        getIssue(issueId); // verify existence
        return assignmentRepository.findByIssueIdOrderByAssignedAtDesc(issueId).stream()
                .map(this::mapToAssignmentResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public IssueMessageResponse addMessage(UUID issueId, IssueMessageRequest request, UUID currentUserId) {
        Issue issue = getIssue(issueId);
        User sender = getUser(currentUserId);

        String messageType = request.getMessageType() != null && !request.getMessageType().isBlank()
                ? request.getMessageType()
                : (sender.getRole() == Role.STUDENT ? "USER_MESSAGE" : "OPERATOR_UPDATE");

        IssueMessage message = IssueMessage.builder()
                .issue(issue)
                .sender(sender)
                .messageType(messageType)
                .body(request.getBody().trim())
                .visibility("PUBLIC")
                .build();

        IssueMessage saved = messageRepository.save(message);
        return mapToMessageResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<IssueMessageResponse> getMessages(UUID issueId, UUID currentUserId) {
        getIssue(issueId);
        User user = getUser(currentUserId);

        List<IssueMessage> messages;
        if (user.getRole() == Role.STUDENT) {
            messages = messageRepository.findByIssueIdAndVisibilityOrderByCreatedAtAsc(issueId, "PUBLIC");
        } else {
            messages = messageRepository.findByIssueIdOrderByCreatedAtAsc(issueId);
        }

        return messages.stream().map(this::mapToMessageResponse).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public InternalNoteResponse addInternalNote(UUID issueId, InternalNoteRequest request, UUID currentUserId) {
        Issue issue = getIssue(issueId);
        User author = getUser(currentUserId);

        if (author.getRole() == Role.STUDENT) {
            throw new BadRequestException("Students are not permitted to add internal staff notes.");
        }

        InternalNote note = InternalNote.builder()
                .issue(issue)
                .author(author)
                .body(request.getBody().trim())
                .build();

        InternalNote saved = internalNoteRepository.save(note);
        return mapToInternalNoteResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<InternalNoteResponse> getInternalNotes(UUID issueId, UUID currentUserId) {
        getIssue(issueId);
        User user = getUser(currentUserId);

        if (user.getRole() == Role.STUDENT) {
            throw new BadRequestException("Students are not authorized to view internal staff notes.");
        }

        return internalNoteRepository.findByIssueIdOrderByCreatedAtDesc(issueId).stream()
                .map(this::mapToInternalNoteResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public InvestigationResponse createInvestigation(UUID issueId, InvestigationRequest request, UUID currentUserId) {
        Issue issue = getIssue(issueId);
        User investigator = getUser(currentUserId);

        if (investigator.getRole() == Role.STUDENT) {
            throw new BadRequestException("Students cannot log technical investigations.");
        }

        Investigation investigation = Investigation.builder()
                .issue(issue)
                .investigator(investigator)
                .observations(request.getObservations().trim())
                .actionsTaken(request.getActionsTaken() != null ? request.getActionsTaken().trim() : null)
                .findings(request.getFindings() != null ? request.getFindings().trim() : null)
                .followUp(request.getFollowUp() != null ? request.getFollowUp().trim() : null)
                .build();

        Investigation saved = investigationRepository.save(investigation);

        // Update issue status to INVESTIGATED if appropriate
        if (issue.getStatus() == IssueStatus.ASSIGNED || issue.getStatus() == IssueStatus.INVESTIGATING) {
            issue.setStatus(IssueStatus.INVESTIGATED);
            issueRepository.save(issue);
        }

        // Timeline event
        IssueTimelineEvent timelineEvent = IssueTimelineEvent.builder()
                .issue(issue)
                .eventType(TimelineEventType.STATUS_CHANGED)
                .actor(investigator)
                .description("Field investigation report submitted by " + investigator.getDisplayName())
                .build();
        timelineEventRepository.save(timelineEvent);

        return mapToInvestigationResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<InvestigationResponse> getInvestigations(UUID issueId) {
        getIssue(issueId);
        return investigationRepository.findByIssueIdOrderByCreatedAtDesc(issueId).stream()
                .map(this::mapToInvestigationResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public TaskResponse createTask(UUID issueId, TaskCreateRequest request, UUID currentUserId) {
        Issue issue = getIssue(issueId);
        User creator = getUser(currentUserId);

        User owner = null;
        if (request.getOwnerId() != null) {
            owner = getUser(request.getOwnerId());
        } else if (issue.getAssignedUser() != null) {
            owner = issue.getAssignedUser();
        } else {
            owner = creator;
        }

        IssueTask task = IssueTask.builder()
                .issue(issue)
                .title(request.getTitle().trim())
                .description(request.getDescription() != null ? request.getDescription().trim() : null)
                .owner(owner)
                .status(TaskStatus.PENDING)
                .dueAt(request.getDueAt())
                .build();

        IssueTask saved = taskRepository.save(task);
        return mapToTaskResponse(saved);
    }

    @Override
    @Transactional
    public TaskResponse updateTask(UUID taskId, TaskUpdateRequest request, UUID currentUserId) {
        IssueTask task = taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found with ID: " + taskId));

        if (request.getTitle() != null && !request.getTitle().isBlank()) {
            task.setTitle(request.getTitle().trim());
        }
        if (request.getDescription() != null) {
            task.setDescription(request.getDescription().trim());
        }
        if (request.getOwnerId() != null) {
            task.setOwner(getUser(request.getOwnerId()));
        }
        if (request.getDueAt() != null) {
            task.setDueAt(request.getDueAt());
        }
        if (request.getStatus() != null) {
            task.setStatus(request.getStatus());
            if (request.getStatus() == TaskStatus.COMPLETED) {
                task.setCompletedAt(OffsetDateTime.now());
            } else {
                task.setCompletedAt(null);
            }
        }

        IssueTask updated = taskRepository.save(task);
        return mapToTaskResponse(updated);
    }

    @Override
    @Transactional(readOnly = true)
    public List<TaskResponse> getTasks(UUID issueId) {
        getIssue(issueId);
        return taskRepository.findByIssueIdOrderByCreatedAtAsc(issueId).stream()
                .map(this::mapToTaskResponse)
                .collect(Collectors.toList());
    }

    // --- Helper & Mapping Methods ---

    private Issue getIssue(UUID issueId) {
        return issueRepository.findById(issueId)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found with ID: " + issueId));
    }

    private User getUser(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + userId));
    }

    private AssignmentResponse mapToAssignmentResponse(Assignment a) {
        return AssignmentResponse.builder()
                .id(a.getId())
                .issueId(a.getIssue().getId())
                .teamId(a.getTeam() != null ? a.getTeam().getId() : null)
                .teamName(a.getTeam() != null ? a.getTeam().getName() : null)
                .userId(a.getUser() != null ? a.getUser().getId() : null)
                .userName(a.getUser() != null ? a.getUser().getDisplayName() : null)
                .userEmail(a.getUser() != null ? a.getUser().getEmail() : null)
                .assignmentType(a.getAssignmentType())
                .recommendationSource(a.getRecommendationSource())
                .reason(a.getReason())
                .assignedById(a.getAssignedBy() != null ? a.getAssignedBy().getId() : null)
                .assignedByName(a.getAssignedBy() != null ? a.getAssignedBy().getDisplayName() : null)
                .assignedAt(a.getAssignedAt())
                .endedAt(a.getEndedAt())
                .active(a.getEndedAt() == null)
                .build();
    }

    private IssueMessageResponse mapToMessageResponse(IssueMessage m) {
        return IssueMessageResponse.builder()
                .id(m.getId())
                .issueId(m.getIssue().getId())
                .senderId(m.getSender().getId())
                .senderName(m.getSender().getDisplayName())
                .senderRole(m.getSender().getRole().name())
                .messageType(m.getMessageType())
                .body(m.getBody())
                .visibility(m.getVisibility())
                .createdAt(m.getCreatedAt())
                .build();
    }

    private InternalNoteResponse mapToInternalNoteResponse(InternalNote n) {
        return InternalNoteResponse.builder()
                .id(n.getId())
                .issueId(n.getIssue().getId())
                .authorId(n.getAuthor().getId())
                .authorName(n.getAuthor().getDisplayName())
                .authorRole(n.getAuthor().getRole().name())
                .body(n.getBody())
                .createdAt(n.getCreatedAt())
                .build();
    }

    private InvestigationResponse mapToInvestigationResponse(Investigation inv) {
        return InvestigationResponse.builder()
                .id(inv.getId())
                .issueId(inv.getIssue().getId())
                .investigatorId(inv.getInvestigator().getId())
                .investigatorName(inv.getInvestigator().getDisplayName())
                .investigatorRole(inv.getInvestigator().getRole().name())
                .observations(inv.getObservations())
                .actionsTaken(inv.getActionsTaken())
                .findings(inv.getFindings())
                .followUp(inv.getFollowUp())
                .createdAt(inv.getCreatedAt())
                .updatedAt(inv.getUpdatedAt())
                .build();
    }

    private TaskResponse mapToTaskResponse(IssueTask t) {
        return TaskResponse.builder()
                .id(t.getId())
                .issueId(t.getIssue().getId())
                .title(t.getTitle())
                .description(t.getDescription())
                .ownerId(t.getOwner() != null ? t.getOwner().getId() : null)
                .ownerName(t.getOwner() != null ? t.getOwner().getDisplayName() : null)
                .ownerEmail(t.getOwner() != null ? t.getOwner().getEmail() : null)
                .status(t.getStatus())
                .dueAt(t.getDueAt())
                .completedAt(t.getCompletedAt())
                .createdAt(t.getCreatedAt())
                .updatedAt(t.getUpdatedAt())
                .build();
    }
}
