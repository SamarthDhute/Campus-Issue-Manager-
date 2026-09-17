package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {

    private UUID id;
    private String email;
    private String displayName;
    private Role role;
    private UUID organizationId;
    private String organizationName;
    private List<String> teams;
    private OffsetDateTime createdAt;
}
