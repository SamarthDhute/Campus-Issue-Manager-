package com.smartcampus.issuemanager.mapper;

import com.smartcampus.issuemanager.dto.UserProfileResponse;
import com.smartcampus.issuemanager.entity.Team;
import com.smartcampus.issuemanager.entity.User;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;

@Component
public class UserMapper {

    public UserProfileResponse toProfileResponse(User user) {
        if (user == null) {
            return null;
        }

        List<String> teamNames = user.getTeams() != null
            ? user.getTeams().stream().map(Team::getName).sorted().toList()
            : Collections.emptyList();

        return UserProfileResponse.builder()
            .id(user.getId())
            .email(user.getEmail())
            .displayName(user.getDisplayName())
            .role(user.getRole())
            .organizationId(user.getOrganization() != null ? user.getOrganization().getId() : null)
            .organizationName(user.getOrganization() != null ? user.getOrganization().getName() : null)
            .teams(teamNames)
            .createdAt(user.getCreatedAt())
            .build();
    }
}
