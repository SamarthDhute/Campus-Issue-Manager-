package com.smartcampus.issuemanager.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "ai_analyses")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AiAnalysis {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "issue_id", nullable = false)
    private Issue issue;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    @Builder.Default
    private AiAnalysisStatus status = AiAnalysisStatus.COMPLETED;

    @Column(nullable = false, length = 64)
    @Builder.Default
    private String model = "gemini-1.5-flash";

    @Column(columnDefinition = "TEXT")
    private String summary;

    @Column(name = "missing_information", columnDefinition = "TEXT")
    private String missingInformation;

    @Column(precision = 5, scale = 4)
    @Builder.Default
    private BigDecimal confidence = new BigDecimal("0.8500");

    @OneToMany(mappedBy = "analysis", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<AiRecommendation> recommendations = new ArrayList<>();

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "completed_at")
    private OffsetDateTime completedAt;
}
