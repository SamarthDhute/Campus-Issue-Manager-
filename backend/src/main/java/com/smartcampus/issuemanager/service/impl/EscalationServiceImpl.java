package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.CreateEscalationRequest;
import com.smartcampus.issuemanager.dto.EscalationResponse;
import com.smartcampus.issuemanager.entity.*;
import com.smartcampus.issuemanager.exception.BadRequestException;
import com.smartcampus.issuemanager.exception.ResourceNotFoundException;
import com.smartcampus.issuemanager.repository.EscalationRepository;
import com.smartcampus.issuemanager.repository.IssueRepository;
import com.smartcampus.issuemanager.repository.IssueTimelineEventRepository;
import com.smartcampus.issuemanager.service.EscalationService;
import com.smartcampus.issuemanager.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class EscalationServiceImpl implements EscalationService {

    private final EscalationRepository escalationRepository;
    private final IssueRepository issueRepository;
    private final IssueTimelineEventRepository timelineEventRepository;
    private final NotificationService notificationService;

    @Override
    @Transactional
    public EscalationResponse createManualEscalation(UUID issueId, CreateEscalationRequest request, User user) {
        Issue issue = issueRepository.findById(issueId)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found: " + issueId));

        if (user.getRole() == Role.STUDENT) {
            throw new BadRequestException("Students cannot trigger operational staff escalations");
        }

        int level = request.getLevel() != null ? request.getLevel() : 1;

        Escalation escalation = Escalation.builder()
                .issue(issue)
                .triggerType(EscalationTrigger.MANUAL_STAFF_OVERRIDE)
                .level(level)
                .status(EscalationStatus.OPEN)
                .reason(request.getReason())
                .triggeredBy(user)
                .build();

        Escalation saved = escalationRepository.save(escalation);

        // Record in Timeline
        timelineEventRepository.save(IssueTimelineEvent.builder()
                .issue(issue)
                .actor(user)
                .eventType(TimelineEventType.ESCALATED)
                .description("Manual Level " + level + " Escalation triggered by " + user.getDisplayName() + ": " + request.getReason())
                .build());

        // Notify appropriate tier
        if (level == 1) {
            notificationService.notifyRoleGroup(Role.TEAM_LEAD, issue, NotificationType.ESCALATION_TRIGGERED,
                    "⚠️ Level 1 Escalation: " + issue.getIssueNumber(),
                    user.getDisplayName() + " escalated issue " + issue.getIssueNumber() + ": " + request.getReason());
        } else {
            notificationService.notifyRoleGroup(Role.MANAGER, issue, NotificationType.ESCALATION_TRIGGERED,
                    "🚨 Level " + level + " Critical Escalation: " + issue.getIssueNumber(),
                    user.getDisplayName() + " escalated issue " + issue.getIssueNumber() + " to Management: " + request.getReason());
        }

        log.info("Manual escalation created for issue {} at level {} by {}", issue.getIssueNumber(), level, user.getEmail());
        return mapToResponse(saved);
    }

    @Override
    @Transactional
    public void triggerAutoEscalation(Issue issue, Integer level, String reason) {
        // Idempotency: Do not duplicate open escalation of same level
        if (escalationRepository.existsByIssueIdAndLevelAndStatus(issue.getId(), level, EscalationStatus.OPEN)) {
            log.info("Issue {} already has an active open level {} escalation", issue.getIssueNumber(), level);
            return;
        }

        Escalation escalation = Escalation.builder()
                .issue(issue)
                .triggerType(EscalationTrigger.AUTO_SLA_BREACH)
                .level(level)
                .status(EscalationStatus.OPEN)
                .reason(reason)
                .build();

        escalationRepository.save(escalation);

        // Record in Timeline
        timelineEventRepository.save(IssueTimelineEvent.builder()
                .issue(issue)
                .actor(null)
                .eventType(TimelineEventType.ESCALATED)
                .description("Automated Level " + level + " SLA Escalation: " + reason)
                .build());

        // Notify Team Leads / Managers
        if (level == 1) {
            notificationService.notifyRoleGroup(Role.TEAM_LEAD, issue, NotificationType.ESCALATION_TRIGGERED,
                    "⚠️ Auto-Escalation (Tier 1): " + issue.getIssueNumber(),
                    "Issue " + issue.getIssueNumber() + " automatically escalated to Team Lead: " + reason);
        } else {
            notificationService.notifyRoleGroup(Role.MANAGER, issue, NotificationType.ESCALATION_TRIGGERED,
                    "🚨 Auto-Escalation (Tier 2): " + issue.getIssueNumber(),
                    "Issue " + issue.getIssueNumber() + " automatically escalated to Campus Manager: " + reason);
        }

        log.info("Auto-escalation triggered for issue {} at level {}: {}", issue.getIssueNumber(), level, reason);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EscalationResponse> getEscalationsForIssue(UUID issueId) {
        return escalationRepository.findByIssueIdOrderByTriggeredAtDesc(issueId).stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    @Transactional
    public void resolveOpenEscalations(UUID issueId) {
        List<Escalation> openEscalations = escalationRepository.findByIssueIdAndStatus(issueId, EscalationStatus.OPEN);
        OffsetDateTime now = OffsetDateTime.now();
        for (Escalation esc : openEscalations) {
            esc.setStatus(EscalationStatus.RESOLVED);
            esc.setResolvedAt(now);
            escalationRepository.save(esc);
        }
    }

    private EscalationResponse mapToResponse(Escalation esc) {
        return EscalationResponse.builder()
                .id(esc.getId())
                .issueId(esc.getIssue().getId())
                .triggerType(esc.getTriggerType())
                .level(esc.getLevel())
                .status(esc.getStatus())
                .reason(esc.getReason())
                .triggeredById(esc.getTriggeredBy() != null ? esc.getTriggeredBy().getId() : null)
                .triggeredByName(esc.getTriggeredBy() != null ? esc.getTriggeredBy().getDisplayName() : "System Automation")
                .triggeredByRole(esc.getTriggeredBy() != null ? esc.getTriggeredBy().getRole().name() : "SYSTEM")
                .triggeredAt(esc.getTriggeredAt())
                .resolvedAt(esc.getResolvedAt())
                .build();
    }
}
