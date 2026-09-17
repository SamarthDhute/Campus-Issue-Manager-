package com.smartcampus.issuemanager.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "issue_sla")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IssueSla {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "issue_id", nullable = false, unique = true)
    private Issue issue;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sla_policy_id")
    private SlaPolicy slaPolicy;

    @Column(name = "response_due_at", nullable = false)
    private OffsetDateTime responseDueAt;

    @Column(name = "resolution_due_at", nullable = false)
    private OffsetDateTime resolutionDueAt;

    @Column(name = "response_met_at")
    private OffsetDateTime responseMetAt;

    @Column(name = "resolution_met_at")
    private OffsetDateTime resolutionMetAt;

    @Column(name = "response_breached_at")
    private OffsetDateTime responseBreachedAt;

    @Column(name = "resolution_breached_at")
    private OffsetDateTime resolutionBreachedAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    @Builder.Default
    private SlaStatus status = SlaStatus.ON_TRACK;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;
}
