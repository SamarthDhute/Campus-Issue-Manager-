package com.smartcampus.issuemanager.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcampus.issuemanager.dto.AuthResponse;
import com.smartcampus.issuemanager.dto.LoginRequest;
import com.smartcampus.issuemanager.dto.UserProfileResponse;
import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.service.AuthService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthService authService;

    @Test
    void login_WithValidCredentials_ShouldReturnAuthResponse() throws Exception {
        UserProfileResponse userProfile = UserProfileResponse.builder()
            .id(UUID.randomUUID())
            .email("student@smartcampus.edu")
            .displayName("Aarav Sharma")
            .role(Role.STUDENT)
            .teams(List.of())
            .createdAt(OffsetDateTime.now())
            .build();

        AuthResponse authResponse = AuthResponse.builder()
            .accessToken("mock-jwt-token")
            .tokenType("Bearer")
            .expiresInMs(86400000)
            .user(userProfile)
            .build();

        when(authService.login(any(LoginRequest.class))).thenReturn(authResponse);

        LoginRequest request = LoginRequest.builder()
            .email("student@smartcampus.edu")
            .password("Password@123")
            .build();

        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.accessToken").value("mock-jwt-token"))
            .andExpect(jsonPath("$.tokenType").value("Bearer"))
            .andExpect(jsonPath("$.user.email").value("student@smartcampus.edu"))
            .andExpect(jsonPath("$.user.role").value("STUDENT"));
    }

    @Test
    void login_WithInvalidCredentials_ShouldReturnUnauthorized() throws Exception {
        when(authService.login(any(LoginRequest.class)))
            .thenThrow(new BadCredentialsException("Invalid email or password"));

        LoginRequest request = LoginRequest.builder()
            .email("student@smartcampus.edu")
            .password("WrongPassword")
            .build();

        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isUnauthorized())
            .andExpect(jsonPath("$.error").value("Unauthorized"));
    }

    @Test
    void login_WithMissingFields_ShouldReturnBadRequest() throws Exception {
        LoginRequest request = LoginRequest.builder()
            .email("")
            .password("")
            .build();

        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.error").value("Validation Error"))
            .andExpect(jsonPath("$.validationErrors.email").exists())
            .andExpect(jsonPath("$.validationErrors.password").exists());
    }
}
