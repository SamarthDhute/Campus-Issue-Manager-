package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.UpdateProfileRequest;
import com.smartcampus.issuemanager.dto.UserProfileResponse;

import com.smartcampus.issuemanager.entity.Role;

import java.util.List;
import java.util.UUID;

public interface UserService {
    UserProfileResponse getCurrentUserProfile(UUID userId);
    UserProfileResponse updateCurrentUserProfile(UUID userId, UpdateProfileRequest request);
    List<UserProfileResponse> getUsers(Role role);
}
