package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.NotificationResponse;
import com.smartcampus.issuemanager.entity.*;
import com.smartcampus.issuemanager.exception.ResourceNotFoundException;
import com.smartcampus.issuemanager.repository.NotificationRepository;
import com.smartcampus.issuemanager.repository.UserRepository;
import com.smartcampus.issuemanager.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public void sendNotification(User recipient, Issue issue, NotificationType type, String title, String body, NotificationChannel channel) {
        if (recipient == null) return;

        // Noise control: deduplicate within 15 mins window for same issue & type
        if (issue != null) {
            OffsetDateTime cooldownCutoff = OffsetDateTime.now().minusMinutes(15);
            boolean recentExists = notificationRepository.existsByRecipientIdAndIssueIdAndNotificationTypeAndCreatedAtAfter(
                    recipient.getId(), issue.getId(), type, cooldownCutoff);
            if (recentExists) {
                log.info("Throttled duplicate notification {} for user {}", type, recipient.getEmail());
                return;
            }
        }

        Notification notification = Notification.builder()
                .recipient(recipient)
                .issue(issue)
                .notificationType(type)
                .title(title)
                .body(body)
                .channel(channel != null ? channel : NotificationChannel.IN_APP)
                .status(NotificationStatus.UNREAD)
                .build();

        notificationRepository.save(notification);
        log.info("Dispatched notification [{}] to {}: {}", type, recipient.getEmail(), title);
    }

    @Override
    @Transactional
    public void notifyRoleGroup(Role role, Issue issue, NotificationType type, String title, String body) {
        List<User> users = userRepository.findByRole(role);
        for (User user : users) {
            sendNotification(user, issue, type, title, body, NotificationChannel.IN_APP);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificationResponse> getUserNotifications(UUID recipientId) {
        return notificationRepository.findByRecipientIdOrderByCreatedAtDesc(recipientId).stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public long getUnreadCount(UUID recipientId) {
        return notificationRepository.countByRecipientIdAndStatus(recipientId, NotificationStatus.UNREAD);
    }

    @Override
    @Transactional
    public void markAsRead(UUID notificationId, UUID recipientId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification not found: " + notificationId));

        if (!notification.getRecipient().getId().equals(recipientId)) {
            throw new IllegalArgumentException("Cannot mark another user's notification as read");
        }

        notification.setStatus(NotificationStatus.READ);
        notification.setReadAt(OffsetDateTime.now());
        notificationRepository.save(notification);
    }

    @Override
    @Transactional
    public void markAllAsRead(UUID recipientId) {
        notificationRepository.markAllAsRead(recipientId, OffsetDateTime.now());
    }

    private NotificationResponse mapToResponse(Notification n) {
        return NotificationResponse.builder()
                .id(n.getId())
                .recipientId(n.getRecipient().getId())
                .issueId(n.getIssue() != null ? n.getIssue().getId() : null)
                .issueNumber(n.getIssue() != null ? n.getIssue().getIssueNumber() : null)
                .notificationType(n.getNotificationType())
                .title(n.getTitle())
                .body(n.getBody())
                .channel(n.getChannel())
                .status(n.getStatus())
                .sentAt(n.getSentAt())
                .readAt(n.getReadAt())
                .createdAt(n.getCreatedAt())
                .build();
    }
}
