package com.smartcampus.issuemanager.scheduler;

import com.smartcampus.issuemanager.entity.*;
import com.smartcampus.issuemanager.repository.IssueRepository;
import com.smartcampus.issuemanager.repository.IssueSlaRepository;
import com.smartcampus.issuemanager.service.EscalationService;
import com.smartcampus.issuemanager.service.NotificationService;
import com.smartcampus.issuemanager.service.RiskAssessmentService;
import com.smartcampus.issuemanager.service.SlaService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class SlaAutomationScheduler {

    private final IssueRepository issueRepository;
    private final IssueSlaRepository issueSlaRepository;
    private final SlaService slaService;
    private final RiskAssessmentService riskAssessmentService;
    private final EscalationService escalationService;
    private final NotificationService notificationService;

    /**
     * Runs every 2 minutes to inspect active issues, evaluate SLA burn rate,
     * detect risks, and trigger automated tier escalations and notifications.
     */
    @Scheduled(fixedDelayString = "${app.sla.scheduler-interval-ms:120000}", initialDelay = 15000)
    @Transactional
    public void runSlaAndRiskAutomation() {
        log.debug("Executing scheduled SLA & Risk Automation job...");

        List<Issue> activeIssues = issueRepository.findAll().stream()
                .filter(i -> i.getStatus() != IssueStatus.CLOSED &&
                             i.getStatus() != IssueStatus.CANCELLED &&
                             i.getStatus() != IssueStatus.RESOLVED_PENDING_CONFIRMATION)
                .toList();

        for (Issue issue : activeIssues) {
            try {
                // 1. Evaluate & Refresh SLA
                IssueSla sla = issueSlaRepository.findByIssueId(issue.getId())
                        .orElseGet(() -> slaService.initializeIssueSla(issue));
                sla = slaService.evaluateAndRefreshSla(sla);

                // 2. Evaluate Proactive Risks
                List<RiskEvent> risks = riskAssessmentService.evaluateIssueRisks(issue);

                // 3. Automated Escalation Logic
                if (sla.getStatus() == SlaStatus.BREACHED_RESPONSE) {
                    escalationService.triggerAutoEscalation(issue, 1,
                            "Response SLA deadline (" + sla.getResponseDueAt() + ") was breached without operator action.");
                } else if (sla.getStatus() == SlaStatus.BREACHED_RESOLUTION) {
                    escalationService.triggerAutoEscalation(issue, 2,
                            "Resolution SLA deadline (" + sla.getResolutionDueAt() + ") was breached.");
                } else if (sla.getStatus() == SlaStatus.AT_RISK) {
                    // Send notification to assigned user or Team Leads
                    if (issue.getAssignedUser() != null) {
                        notificationService.sendNotification(
                                issue.getAssignedUser(),
                                issue,
                                NotificationType.SLA_WARNING,
                                "⏳ SLA Warning: " + issue.getIssueNumber(),
                                "Less than 25% resolution time remains for issue: " + issue.getTitle(),
                                NotificationChannel.IN_APP
                        );
                    }
                }
            } catch (Exception e) {
                log.error("Error evaluating SLA/Risk for issue {}: {}", issue.getIssueNumber(), e.getMessage(), e);
            }
        }
    }
}
