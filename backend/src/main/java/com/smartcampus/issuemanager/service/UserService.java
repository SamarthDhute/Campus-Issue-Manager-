package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.UpdateProfileRequest;
import com.smartcampus.issuemanager.dto.UserProfileResponse;

import java.util.UUID;

public interface UserService {
    UserProfileResponse getCurrentUserProfile(UUID userId);
    UserProfileResponse updateCurrentUserProfile(UUID userId, UpdateProfileRequest request);
}
