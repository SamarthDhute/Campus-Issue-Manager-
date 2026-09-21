package com.smartcampus.issuemanager.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SlaTrendPointResponse {

    private String dateLabel; // e.g. "Mon, Sep 15" or "Week 36"
    private long totalEvaluated;
    private long compliantCount;
    private long breachedCount;
    private BigDecimal compliancePercentage;
}
