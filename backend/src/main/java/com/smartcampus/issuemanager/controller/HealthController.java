package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.HealthResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.OffsetDateTime;

@RestController
@RequestMapping("/api/v1/health")
@Tag(name = "Health", description = "System health check endpoint")
public class HealthController {

    @GetMapping
    @Operation(summary = "Service Health Check", description = "Returns operational status and metadata of the application service")
    public ResponseEntity<HealthResponse> checkHealth() {
        HealthResponse response = HealthResponse.builder()
            .status("UP")
            .service("Smart Campus Issue Manager API")
            .version("1.0.0")
            .timestamp(OffsetDateTime.now())
            .build();

        return ResponseEntity.ok(response);
    }
}
