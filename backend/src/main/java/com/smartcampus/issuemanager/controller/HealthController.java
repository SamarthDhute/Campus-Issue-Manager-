package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.HealthResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.OffsetDateTime;

@RestController
@Tag(name = "Health", description = "System health check and welcome endpoints")
public class HealthController {

    @GetMapping(value = {"/", "/api/v1/health", "/health"})
    @Operation(summary = "Service Health & Info", description = "Returns operational status and metadata of the application service")
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
