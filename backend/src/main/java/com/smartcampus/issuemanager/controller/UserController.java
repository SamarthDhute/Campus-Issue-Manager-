package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.UpdateProfileRequest;
import com.smartcampus.issuemanager.dto.UserProfileResponse;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "Users", description = "User profile management endpoints")
@SecurityRequirement(name = "bearerAuth")
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    @Operation(summary = "Get Current User Profile", description = "Retrieves the authenticated user's profile, role, and organization info")
    public ResponseEntity<UserProfileResponse> getCurrentUser(@AuthenticationPrincipal UserPrincipal currentUser) {
        UserProfileResponse profile = userService.getCurrentUserProfile(currentUser.getId());
        return ResponseEntity.ok(profile);
    }

    @PutMapping("/me")
    @Operation(summary = "Update Current User Profile", description = "Updates editable profile fields (display name) for the authenticated user")
    public ResponseEntity<UserProfileResponse> updateCurrentUser(
        @AuthenticationPrincipal UserPrincipal currentUser,
        @Valid @RequestBody UpdateProfileRequest request
    ) {
        UserProfileResponse updatedProfile = userService.updateCurrentUserProfile(currentUser.getId(), request);
        return ResponseEntity.ok(updatedProfile);
    }

    @GetMapping
    @Operation(summary = "List users optionally filtered by role", description = "Returns users matching the given role (e.g. OPERATOR, TEAM_LEAD)")
    public ResponseEntity<java.util.List<UserProfileResponse>> getUsers(
        @RequestParam(required = false) com.smartcampus.issuemanager.entity.Role role
    ) {
        java.util.List<UserProfileResponse> users = userService.getUsers(role);
        return ResponseEntity.ok(users);
    }
}
