package com.smartcampus.issuemanager.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "issue_relationships")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IssueRelationship {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "issue_id", nullable = false)
    private Issue issue;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "related_issue_id", nullable = false)
    private Issue relatedIssue;

    @Enumerated(EnumType.STRING)
    @Column(name = "relationship_type", nullable = false, length = 32)
    @Builder.Default
    private RelationshipType relationshipType = RelationshipType.DUPLICATE_CANDIDATE;

    @Column(nullable = false, precision = 5, scale = 4)
    @Builder.Default
    private BigDecimal confidence = new BigDecimal("0.8000");

    @Column(columnDefinition = "TEXT")
    private String explanation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "confirmed_by")
    private User confirmedBy;

    @Column(name = "confirmed_at")
    private OffsetDateTime confirmedAt;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;
}
