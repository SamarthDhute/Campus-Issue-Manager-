package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.NotificationResponse;
import com.smartcampus.issuemanager.entity.Issue;
import com.smartcampus.issuemanager.entity.NotificationChannel;
import com.smartcampus.issuemanager.entity.NotificationType;
import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.entity.User;

import java.util.List;
import java.util.UUID;

public interface NotificationService {

    void sendNotification(User recipient, Issue issue, NotificationType type, String title, String body, NotificationChannel channel);

    void notifyRoleGroup(Role role, Issue issue, NotificationType type, String title, String body);

    List<NotificationResponse> getUserNotifications(UUID recipientId);

    long getUnreadCount(UUID recipientId);

    void markAsRead(UUID notificationId, UUID recipientId);

    void markAllAsRead(UUID recipientId);
}
