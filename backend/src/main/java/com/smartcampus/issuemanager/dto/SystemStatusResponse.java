package com.smartcampus.issuemanager.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SystemStatusResponse {
    private String status; // UP, DEGRADED, DOWN
    private String environment;
    private String version;
    private long uptimeSeconds;
    private OffsetDateTime serverTime;
    private Map<String, Object> components; // database, aiEngine, storage, notifications
    private Map<String, Object> metrics; // activeConnections, memoryUsageMb
}
