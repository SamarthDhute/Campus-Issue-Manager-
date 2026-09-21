package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.CreateEscalationRequest;
import com.smartcampus.issuemanager.dto.EscalationResponse;
import com.smartcampus.issuemanager.dto.IssueSlaResponse;
import com.smartcampus.issuemanager.dto.RiskEventResponse;
import com.smartcampus.issuemanager.entity.User;
import com.smartcampus.issuemanager.repository.UserRepository;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.EscalationService;
import com.smartcampus.issuemanager.service.RiskAssessmentService;
import com.smartcampus.issuemanager.service.SlaService;
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
@RequestMapping("/api/v1/issues/{id}")
@RequiredArgsConstructor
@Tag(name = "SLA & Escalation", description = "Endpoints for SLA countdown, risk indicators, and multi-tier escalations")
public class SlaController {

    private final SlaService slaService;
    private final RiskAssessmentService riskAssessmentService;
    private final EscalationService escalationService;
    private final UserRepository userRepository;

    @GetMapping("/sla")
    @Operation(summary = "Get current SLA countdown, milestones, and breach status for an issue")
    public ResponseEntity<IssueSlaResponse> getIssueSla(@PathVariable UUID id) {
        IssueSlaResponse response = slaService.getIssueSla(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/risks")
    @Operation(summary = "Get active risk events and explanatory signals for an issue")
    public ResponseEntity<List<RiskEventResponse>> getIssueRisks(@PathVariable UUID id) {
        List<RiskEventResponse> response = riskAssessmentService.getActiveRisksForIssue(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/escalations")
    @Operation(summary = "Get full escalation history for an issue")
    public ResponseEntity<List<EscalationResponse>> getIssueEscalations(@PathVariable UUID id) {
        List<EscalationResponse> response = escalationService.getEscalationsForIssue(id);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/escalations")
    @Operation(summary = "Trigger a manual tier escalation for an issue")
    public ResponseEntity<EscalationResponse> createManualEscalation(
            @PathVariable UUID id,
            @Valid @RequestBody CreateEscalationRequest request,
            @AuthenticationPrincipal UserPrincipal principal) {
        User user = userRepository.findById(principal.getId()).orElse(null);
        EscalationResponse response = escalationService.createManualEscalation(id, request, user);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
