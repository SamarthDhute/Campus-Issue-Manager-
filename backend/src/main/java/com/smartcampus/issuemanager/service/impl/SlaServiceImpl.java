package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.IssueSlaResponse;
import com.smartcampus.issuemanager.entity.*;
import com.smartcampus.issuemanager.exception.ResourceNotFoundException;
import com.smartcampus.issuemanager.repository.IssueRepository;
import com.smartcampus.issuemanager.repository.IssueSlaRepository;
import com.smartcampus.issuemanager.repository.SlaPolicyRepository;
import com.smartcampus.issuemanager.service.SlaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class SlaServiceImpl implements SlaService {

    private final SlaPolicyRepository slaPolicyRepository;
    private final IssueSlaRepository issueSlaRepository;
    private final IssueRepository issueRepository;

    @Override
    @Transactional
    public IssueSla initializeIssueSla(Issue issue) {
        log.info("Initializing SLA for issue: {} with priority: {}", issue.getIssueNumber(), issue.getPriority());

        Organization org = issue.getRequester() != null ? issue.getRequester().getOrganization() : null;
        
        Optional<SlaPolicy> policyOpt = Optional.empty();
        if (org != null) {
            if (issue.getCategory() != null) {
                policyOpt = slaPolicyRepository.findByOrganizationAndCategoryAndPriorityAndActiveTrue(
                        org, issue.getCategory(), issue.getPriority());
            }
            if (policyOpt.isEmpty()) {
                policyOpt = slaPolicyRepository.findByOrganizationAndCategoryIsNullAndPriorityAndActiveTrue(
                        org, issue.getPriority());
            }
        }

        int responseMins = 60;
        int resolutionMins = 480;

        if (policyOpt.isPresent()) {
            SlaPolicy policy = policyOpt.get();
            responseMins = policy.getResponseMinutes();
            resolutionMins = policy.getResolutionMinutes();
        } else {
            // Priority fallback defaults
            switch (issue.getPriority()) {
                case URGENT -> { responseMins = 15; resolutionMins = 120; }
                case HIGH -> { responseMins = 30; resolutionMins = 240; }
                case MEDIUM -> { responseMins = 60; resolutionMins = 480; }
                case LOW -> { responseMins = 120; resolutionMins = 1440; }
            }
        }

        OffsetDateTime now = OffsetDateTime.now();
        IssueSla issueSla = IssueSla.builder()
                .issue(issue)
                .slaPolicy(policyOpt.orElse(null))
                .responseDueAt(now.plusMinutes(responseMins))
                .resolutionDueAt(now.plusMinutes(resolutionMins))
                .status(SlaStatus.ON_TRACK)
                .build();

        return issueSlaRepository.save(issueSla);
    }

    @Override
    @Transactional
    public IssueSlaResponse getIssueSla(UUID issueId) {
        Issue issue = issueRepository.findById(issueId)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found: " + issueId));

        IssueSla sla = issueSlaRepository.findByIssueId(issueId)
                .orElseGet(() -> initializeIssueSla(issue));

        sla = evaluateAndRefreshSla(sla);

        return mapToResponse(sla);
    }

    @Override
    @Transactional
    public void onIssueStatusChanged(Issue issue, IssueStatus oldStatus, IssueStatus newStatus) {
        IssueSla sla = issueSlaRepository.findByIssueId(issue.getId()).orElse(null);
        if (sla == null) {
            sla = initializeIssueSla(issue);
        }

        OffsetDateTime now = OffsetDateTime.now();

        // Response milestone met on triage, assign, or investigation start
        if (sla.getResponseMetAt() == null && isResponseMilestoneStatus(newStatus)) {
            sla.setResponseMetAt(now);
            log.info("Issue {} response SLA met at {}", issue.getIssueNumber(), now);
        }

        // Resolution milestone met on proposed or closed
        if (isResolutionMilestoneStatus(newStatus)) {
            if (sla.getResolutionMetAt() == null) {
                sla.setResolutionMetAt(now);
                sla.setStatus(SlaStatus.MET);
                log.info("Issue {} resolution SLA met at {}", issue.getIssueNumber(), now);
            }
        } else if (newStatus == IssueStatus.REOPENED) {
            sla.setResolutionMetAt(null);
            sla.setStatus(SlaStatus.ON_TRACK);
            log.info("Issue {} reopened; resolution SLA clock resumed", issue.getIssueNumber());
        }

        evaluateAndRefreshSla(sla);
        issueSlaRepository.save(sla);
    }

    @Override
    @Transactional
    public IssueSla evaluateAndRefreshSla(IssueSla sla) {
        if (sla.getStatus() == SlaStatus.MET) {
            return sla;
        }

        OffsetDateTime now = OffsetDateTime.now();

        // Response breach check
        if (sla.getResponseMetAt() == null && now.isAfter(sla.getResponseDueAt())) {
            if (sla.getResponseBreachedAt() == null) {
                sla.setResponseBreachedAt(sla.getResponseDueAt());
            }
            sla.setStatus(SlaStatus.BREACHED_RESPONSE);
        }

        // Resolution breach check
        if (sla.getResolutionMetAt() == null && now.isAfter(sla.getResolutionDueAt())) {
            if (sla.getResolutionBreachedAt() == null) {
                sla.setResolutionBreachedAt(sla.getResolutionDueAt());
            }
            sla.setStatus(SlaStatus.BREACHED_RESOLUTION);
        }

        // Proximity / At-risk check (when < 25% time remains)
        if (sla.getStatus() == SlaStatus.ON_TRACK) {
            long totalSeconds = Duration.between(sla.getCreatedAt() != null ? sla.getCreatedAt() : now.minusHours(1), sla.getResolutionDueAt()).getSeconds();
            long remainingSeconds = Duration.between(now, sla.getResolutionDueAt()).getSeconds();

            if (totalSeconds > 0 && remainingSeconds > 0 && ((double) remainingSeconds / totalSeconds) < 0.25) {
                sla.setStatus(SlaStatus.AT_RISK);
            }
        }

        return issueSlaRepository.save(sla);
    }

    private boolean isResponseMilestoneStatus(IssueStatus status) {
        return status == IssueStatus.UNDERSTOOD ||
               status == IssueStatus.ASSIGNED ||
               status == IssueStatus.INVESTIGATING ||
               status == IssueStatus.INVESTIGATED ||
               status == IssueStatus.ACTION_SCHEDULED ||
               status == IssueStatus.ACTION_IN_PROGRESS ||
               status == IssueStatus.ACTION_TAKEN ||
               status == IssueStatus.RESOLUTION_PROPOSED ||
               status == IssueStatus.RESOLVED_PENDING_CONFIRMATION ||
               status == IssueStatus.CLOSED;
    }

    private boolean isResolutionMilestoneStatus(IssueStatus status) {
        return status == IssueStatus.RESOLVED_PENDING_CONFIRMATION ||
               status == IssueStatus.CLOSED;
    }

    private IssueSlaResponse mapToResponse(IssueSla sla) {
        OffsetDateTime now = OffsetDateTime.now();
        OffsetDateTime start = sla.getCreatedAt() != null ? sla.getCreatedAt() : now.minusMinutes(30);

        long responseSecondsRemaining = sla.getResponseMetAt() != null ? 0 :
                Math.max(0, Duration.between(now, sla.getResponseDueAt()).getSeconds());

        long resolutionSecondsRemaining = sla.getResolutionMetAt() != null ? 0 :
                Math.max(0, Duration.between(now, sla.getResolutionDueAt()).getSeconds());

        long totalResponseSeconds = Math.max(1, Duration.between(start, sla.getResponseDueAt()).getSeconds());
        long elapsedResponseSeconds = Math.max(0, Duration.between(start, sla.getResponseMetAt() != null ? sla.getResponseMetAt() : now).getSeconds());
        double responseProgress = Math.min(1.0, (double) elapsedResponseSeconds / totalResponseSeconds);

        long totalResolutionSeconds = Math.max(1, Duration.between(start, sla.getResolutionDueAt()).getSeconds());
        long elapsedResolutionSeconds = Math.max(0, Duration.between(start, sla.getResolutionMetAt() != null ? sla.getResolutionMetAt() : now).getSeconds());
        double resolutionProgress = Math.min(1.0, (double) elapsedResolutionSeconds / totalResolutionSeconds);

        return IssueSlaResponse.builder()
                .id(sla.getId())
                .issueId(sla.getIssue().getId())
                .responseDueAt(sla.getResponseDueAt())
                .resolutionDueAt(sla.getResolutionDueAt())
                .responseMetAt(sla.getResponseMetAt())
                .resolutionMetAt(sla.getResolutionMetAt())
                .responseBreachedAt(sla.getResponseBreachedAt())
                .resolutionBreachedAt(sla.getResolutionBreachedAt())
                .status(sla.getStatus())
                .responseSecondsRemaining(responseSecondsRemaining)
                .resolutionSecondsRemaining(resolutionSecondsRemaining)
                .responseProgressPercentage(responseProgress * 100.0)
                .resolutionProgressPercentage(resolutionProgress * 100.0)
                .responseBreached(sla.getResponseBreachedAt() != null || (sla.getResponseMetAt() == null && now.isAfter(sla.getResponseDueAt())))
                .resolutionBreached(sla.getResolutionBreachedAt() != null || (sla.getResolutionMetAt() == null && now.isAfter(sla.getResolutionDueAt())))
                .responseMet(sla.getResponseMetAt() != null)
                .resolutionMet(sla.getResolutionMetAt() != null)
                .build();
    }
}
