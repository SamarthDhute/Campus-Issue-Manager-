package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.UpdateProfileRequest;
import com.smartcampus.issuemanager.dto.UserProfileResponse;
import com.smartcampus.issuemanager.entity.User;
import com.smartcampus.issuemanager.exception.ResourceNotFoundException;
import com.smartcampus.issuemanager.mapper.UserMapper;
import com.smartcampus.issuemanager.repository.UserRepository;
import com.smartcampus.issuemanager.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;

    @Override
    @Transactional(readOnly = true)
    public UserProfileResponse getCurrentUserProfile(UUID userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        return userMapper.toProfileResponse(user);
    }

    @Override
    @Transactional
    public UserProfileResponse updateCurrentUserProfile(UUID userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        user.setDisplayName(request.getDisplayName().trim());
        User updated = userRepository.save(user);

        log.info("User {} updated display name to: {}", user.getEmail(), updated.getDisplayName());

        return userMapper.toProfileResponse(updated);
    }

    @Override
    @Transactional(readOnly = true)
    public List<UserProfileResponse> getUsers(com.smartcampus.issuemanager.entity.Role role) {
        List<User> users = userRepository.findAll();
        if (role != null) {
            users = users.stream().filter(u -> u.getRole() == role).toList();
        }
        return users.stream().map(userMapper::toProfileResponse).toList();
    }
}
