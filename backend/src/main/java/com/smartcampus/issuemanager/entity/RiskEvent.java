package com.smartcampus.issuemanager.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "risk_events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RiskEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "issue_id", nullable = false)
    private Issue issue;

    @Enumerated(EnumType.STRING)
    @Column(name = "risk_type", nullable = false, length = 100)
    private RiskType riskType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    @Builder.Default
    private RiskSeverity severity = RiskSeverity.MEDIUM;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String explanation;

    @CreationTimestamp
    @Column(name = "detected_at", nullable = false, updatable = false)
    private OffsetDateTime detectedAt;

    @Column(name = "resolved_at")
    private OffsetDateTime resolvedAt;
}
