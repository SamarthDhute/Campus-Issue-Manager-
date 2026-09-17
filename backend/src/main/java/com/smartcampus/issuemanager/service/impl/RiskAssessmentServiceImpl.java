package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.RiskEventResponse;
import com.smartcampus.issuemanager.entity.*;
import com.smartcampus.issuemanager.exception.ResourceNotFoundException;
import com.smartcampus.issuemanager.repository.IssueRepository;
import com.smartcampus.issuemanager.repository.IssueSlaRepository;
import com.smartcampus.issuemanager.repository.IssueTaskRepository;
import com.smartcampus.issuemanager.repository.RiskEventRepository;
import com.smartcampus.issuemanager.service.RiskAssessmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class RiskAssessmentServiceImpl implements RiskAssessmentService {

    private final RiskEventRepository riskEventRepository;
    private final IssueSlaRepository issueSlaRepository;
    private final IssueTaskRepository issueTaskRepository;
    private final IssueRepository issueRepository;

    @Override
    @Transactional
    public List<RiskEvent> evaluateIssueRisks(Issue issue) {
        List<RiskEvent> detected = new ArrayList<>();
        OffsetDateTime now = OffsetDateTime.now();

        // If issue is resolved or closed, resolve any existing risks
        if (issue.getStatus() == IssueStatus.RESOLVED_PENDING_CONFIRMATION ||
            issue.getStatus() == IssueStatus.CLOSED ||
            issue.getStatus() == IssueStatus.CANCELLED) {
            List<RiskEvent> activeRisks = riskEventRepository.findByIssueIdAndResolvedAtIsNull(issue.getId());
            for (RiskEvent re : activeRisks) {
                re.setResolvedAt(now);
                riskEventRepository.save(re);
            }
            return detected;
        }

        // 1. Check SLA Proximity / Breach
        Optional<IssueSla> slaOpt = issueSlaRepository.findByIssueId(issue.getId());
        if (slaOpt.isPresent()) {
            IssueSla sla = slaOpt.get();
            if (sla.getResolutionMetAt() == null) {
                long remainingSecs = Duration.between(now, sla.getResolutionDueAt()).getSeconds();
                if (remainingSecs <= 0) {
                    recordOrUpdateRisk(issue, RiskType.SLA_PROXIMITY, RiskSeverity.CRITICAL,
                            "Resolution SLA has been breached by " + Math.abs(remainingSecs / 60) + " minutes.", detected);
                } else if (remainingSecs < 1800) { // < 30 mins
                    recordOrUpdateRisk(issue, RiskType.SLA_PROXIMITY, RiskSeverity.HIGH,
                            "Resolution SLA approaching breach: only " + (remainingSecs / 60) + " minutes remaining.", detected);
                }
            }
        }

        // 2. Check Idle / Unassigned Delay
        if (issue.getAssignedUser() == null && (issue.getStatus() == IssueStatus.REPORTED || issue.getStatus() == IssueStatus.UNDERSTOOD)) {
            long unassignedMins = Duration.between(issue.getCreatedAt(), now).toMinutes();
            if (unassignedMins >= 30) {
                RiskSeverity severity = issue.getPriority() == IssuePriority.URGENT ? RiskSeverity.CRITICAL :
                                       issue.getPriority() == IssuePriority.HIGH ? RiskSeverity.HIGH : RiskSeverity.MEDIUM;
                recordOrUpdateRisk(issue, RiskType.IDLE_UNASSIGNED, severity,
                        "Issue has remained unassigned for " + unassignedMins + " minutes with " + issue.getPriority() + " priority.", detected);
            }
        } else if (issue.getAssignedUser() != null) {
            // If assigned, resolve IDLE_UNASSIGNED risk
            resolveRiskByType(issue.getId(), RiskType.IDLE_UNASSIGNED);
        }

        // 3. Check Blocked Sub-tasks
        List<IssueTask> tasks = issueTaskRepository.findByIssueIdOrderByCreatedAtAsc(issue.getId());
        if (!tasks.isEmpty()) {
            long pendingCount = tasks.stream().filter(t -> t.getStatus() != TaskStatus.COMPLETED).count();
            if (pendingCount > 0 && slaOpt.isPresent()) {
                IssueSla sla = slaOpt.get();
                long totalSecs = Duration.between(sla.getCreatedAt() != null ? sla.getCreatedAt() : issue.getCreatedAt(), sla.getResolutionDueAt()).getSeconds();
                long elapsedSecs = Duration.between(issue.getCreatedAt(), now).getSeconds();
                if (totalSecs > 0 && ((double) elapsedSecs / totalSecs) > 0.60) {
                    recordOrUpdateRisk(issue, RiskType.BLOCKED_SUBTASKS, RiskSeverity.HIGH,
                            pendingCount + " operational sub-tasks remain incomplete with over 60% SLA elapsed.", detected);
                }
            }
        }

        // 4. Stalled Urgent/High Priority Issue
        if ((issue.getPriority() == IssuePriority.URGENT || issue.getPriority() == IssuePriority.HIGH) &&
                issue.getStatus() == IssueStatus.INVESTIGATING) {
            long lastUpdateMins = Duration.between(issue.getUpdatedAt() != null ? issue.getUpdatedAt() : issue.getCreatedAt(), now).toMinutes();
            if (lastUpdateMins >= 60) {
                recordOrUpdateRisk(issue, RiskType.HIGH_PRIORITY_STALLED, RiskSeverity.HIGH,
                        "High priority case has had no progress update for " + lastUpdateMins + " minutes.", detected);
            }
        }

        return detected;
    }

    @Override
    @Transactional(readOnly = true)
    public List<RiskEventResponse> getActiveRisksForIssue(UUID issueId) {
        return riskEventRepository.findByIssueIdOrderByDetectedAtDesc(issueId).stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    @Transactional
    public void resolveRisk(UUID issueId, UUID riskEventId) {
        RiskEvent risk = riskEventRepository.findById(riskEventId)
                .orElseThrow(() -> new ResourceNotFoundException("Risk event not found: " + riskEventId));
        risk.setResolvedAt(OffsetDateTime.now());
        riskEventRepository.save(risk);
    }

    private void recordOrUpdateRisk(Issue issue, RiskType type, RiskSeverity severity, String explanation, List<RiskEvent> detected) {
        Optional<RiskEvent> existing = riskEventRepository.findByIssueIdAndRiskTypeAndResolvedAtIsNull(issue.getId(), type);
        RiskEvent event;
        if (existing.isPresent()) {
            event = existing.get();
            event.setSeverity(severity);
            event.setExplanation(explanation);
        } else {
            event = RiskEvent.builder()
                    .issue(issue)
                    .riskType(type)
                    .severity(severity)
                    .explanation(explanation)
                    .build();
        }
        RiskEvent saved = riskEventRepository.save(event);
        detected.add(saved);
    }

    private void resolveRiskByType(UUID issueId, RiskType type) {
        riskEventRepository.findByIssueIdAndRiskTypeAndResolvedAtIsNull(issueId, type).ifPresent(re -> {
            re.setResolvedAt(OffsetDateTime.now());
            riskEventRepository.save(re);
        });
    }

    private RiskEventResponse mapToResponse(RiskEvent re) {
        return RiskEventResponse.builder()
                .id(re.getId())
                .issueId(re.getIssue().getId())
                .riskType(re.getRiskType())
                .severity(re.getSeverity())
                .explanation(re.getExplanation())
                .detectedAt(re.getDetectedAt())
                .resolvedAt(re.getResolvedAt())
                .active(re.getResolvedAt() == null)
                .build();
    }
}
