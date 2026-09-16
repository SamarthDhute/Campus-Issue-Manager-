package com.smartcampus.issuemanager.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcampus.issuemanager.dto.UpdateProfileRequest;
import com.smartcampus.issuemanager.dto.UserProfileResponse;
import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private UserService userService;

    @Test
    void getCurrentUser_WithoutAuth_ShouldReturnUnauthorized() throws Exception {
        mockMvc.perform(get("/api/v1/users/me")
                .contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void getCurrentUser_WithAuth_ShouldReturnProfile() throws Exception {
        UUID userId = UUID.randomUUID();
        UserPrincipal principal = new UserPrincipal(
            userId,
            "student@smartcampus.edu",
            "password",
            "Aarav Sharma",
            Role.STUDENT,
            UUID.randomUUID(),
            List.of(new SimpleGrantedAuthority("ROLE_STUDENT"))
        );

        UsernamePasswordAuthenticationToken auth =
            new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());

        UserProfileResponse response = UserProfileResponse.builder()
            .id(userId)
            .email("student@smartcampus.edu")
            .displayName("Aarav Sharma")
            .role(Role.STUDENT)
            .teams(List.of())
            .createdAt(OffsetDateTime.now())
            .build();

        when(userService.getCurrentUserProfile(userId)).thenReturn(response);

        mockMvc.perform(get("/api/v1/users/me")
                .with(authentication(auth))
                .contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.email").value("student@smartcampus.edu"))
            .andExpect(jsonPath("$.displayName").value("Aarav Sharma"))
            .andExpect(jsonPath("$.role").value("STUDENT"));
    }

    @Test
    void updateCurrentUser_WithValidData_ShouldReturnUpdatedProfile() throws Exception {
        UUID userId = UUID.randomUUID();
        UserPrincipal principal = new UserPrincipal(
            userId,
            "student@smartcampus.edu",
            "password",
            "Aarav Sharma",
            Role.STUDENT,
            UUID.randomUUID(),
            List.of(new SimpleGrantedAuthority("ROLE_STUDENT"))
        );

        UsernamePasswordAuthenticationToken auth =
            new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());

        UpdateProfileRequest request = UpdateProfileRequest.builder()
            .displayName("Aarav K. Sharma")
            .build();

        UserProfileResponse updatedResponse = UserProfileResponse.builder()
            .id(userId)
            .email("student@smartcampus.edu")
            .displayName("Aarav K. Sharma")
            .role(Role.STUDENT)
            .teams(List.of())
            .createdAt(OffsetDateTime.now())
            .build();

        when(userService.updateCurrentUserProfile(eq(userId), any(UpdateProfileRequest.class)))
            .thenReturn(updatedResponse);

        mockMvc.perform(put("/api/v1/users/me")
                .with(authentication(auth))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.displayName").value("Aarav K. Sharma"));
    }
}
