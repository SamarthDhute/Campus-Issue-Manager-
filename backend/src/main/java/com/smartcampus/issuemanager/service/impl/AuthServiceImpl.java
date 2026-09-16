package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.AuthResponse;
import com.smartcampus.issuemanager.dto.LoginRequest;
import com.smartcampus.issuemanager.dto.UserProfileResponse;
import com.smartcampus.issuemanager.entity.User;
import com.smartcampus.issuemanager.mapper.UserMapper;
import com.smartcampus.issuemanager.repository.UserRepository;
import com.smartcampus.issuemanager.security.JwtTokenProvider;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final UserRepository userRepository;
    private final UserMapper userMapper;

    @Value("${app.jwt.expiration-ms:86400000}")
    private long jwtExpirationMs;

    @Override
    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();

        String jwt = tokenProvider.generateToken(userPrincipal);

        User user = userRepository.findById(userPrincipal.getId())
            .orElseThrow(() -> new IllegalStateException("Authenticated user not found in database"));

        UserProfileResponse profileResponse = userMapper.toProfileResponse(user);

        log.info("User {} successfully logged in with role {}", user.getEmail(), user.getRole());

        return AuthResponse.builder()
            .accessToken(jwt)
            .tokenType("Bearer")
            .expiresInMs(jwtExpirationMs)
            .user(profileResponse)
            .build();
    }
}
