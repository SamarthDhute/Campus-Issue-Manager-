package com.smartcampus.issuemanager.repository;

import com.smartcampus.issuemanager.entity.Notification;
import com.smartcampus.issuemanager.entity.NotificationStatus;
import com.smartcampus.issuemanager.entity.NotificationType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    List<Notification> findByRecipientIdOrderByCreatedAtDesc(UUID recipientId);

    long countByRecipientIdAndStatus(UUID recipientId, NotificationStatus status);

    boolean existsByRecipientIdAndIssueIdAndNotificationTypeAndCreatedAtAfter(
            UUID recipientId, UUID issueId, NotificationType notificationType, OffsetDateTime afterTime);

    @Modifying
    @Query("UPDATE Notification n SET n.status = 'READ', n.readAt = :readAt WHERE n.recipient.id = :recipientId AND n.status = 'UNREAD'")
    int markAllAsRead(@Param("recipientId") UUID recipientId, @Param("readAt") OffsetDateTime readAt);
}
