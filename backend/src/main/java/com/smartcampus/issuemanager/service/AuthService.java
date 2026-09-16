package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.AuthResponse;
import com.smartcampus.issuemanager.dto.LoginRequest;

public interface AuthService {
    AuthResponse login(LoginRequest request);
}
