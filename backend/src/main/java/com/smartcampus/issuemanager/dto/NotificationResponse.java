package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.NotificationChannel;
import com.smartcampus.issuemanager.entity.NotificationStatus;
import com.smartcampus.issuemanager.entity.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {

    private UUID id;
    private UUID recipientId;
    private UUID issueId;
    private String issueNumber;
    private NotificationType notificationType;
    private String title;
    private String body;
    private NotificationChannel channel;
    private NotificationStatus status;
    private OffsetDateTime sentAt;
    private OffsetDateTime readAt;
    private OffsetDateTime createdAt;
}
