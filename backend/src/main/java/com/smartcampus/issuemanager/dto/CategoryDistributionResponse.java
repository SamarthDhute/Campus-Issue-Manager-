package com.smartcampus.issuemanager.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CategoryDistributionResponse {

    private UUID categoryId;
    private String categoryName;
    private long totalIssuesCount;
    private long activeCount;
    private long resolvedCount;
    private BigDecimal percentageShare;
    private String colorHex;
}
