package com.smartcampus.issuemanager.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartcampus.issuemanager.dto.NotificationResponse;
import com.smartcampus.issuemanager.entity.NotificationChannel;
import com.smartcampus.issuemanager.entity.NotificationStatus;
import com.smartcampus.issuemanager.entity.NotificationType;
import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.security.JwtTokenProvider;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class NotificationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private NotificationService notificationService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    private UserPrincipal testStudentPrincipal;
    private UsernamePasswordAuthenticationToken auth;
    private UUID userId;
    private UUID notifId;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
        notifId = UUID.randomUUID();

        testStudentPrincipal = new UserPrincipal(
                userId,
                "student@smartcampus.edu",
                "password",
                "Aarav Sharma",
                Role.STUDENT,
                UUID.randomUUID(),
                List.of(new SimpleGrantedAuthority("ROLE_STUDENT"))
        );

        auth = new UsernamePasswordAuthenticationToken(testStudentPrincipal, null, testStudentPrincipal.getAuthorities());
    }

    @Test
    void getUserNotifications_Success() throws Exception {
        NotificationResponse response = NotificationResponse.builder()
                .id(notifId)
                .recipientId(userId)
                .notificationType(NotificationType.SLA_WARNING)
                .title("SLA Alert")
                .body("Your reported issue is under active investigation")
                .channel(NotificationChannel.IN_APP)
                .status(NotificationStatus.UNREAD)
                .createdAt(OffsetDateTime.now())
                .build();

        when(notificationService.getUserNotifications(userId)).thenReturn(List.of(response));

        mockMvc.perform(get("/api/v1/notifications")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("SLA Alert"))
                .andExpect(jsonPath("$[0].status").value("UNREAD"));
    }

    @Test
    void getUnreadCount_Success() throws Exception {
        when(notificationService.getUnreadCount(userId)).thenReturn(3L);

        mockMvc.perform(get("/api/v1/notifications/unread-count")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.unreadCount").value(3));
    }

    @Test
    void markAsRead_Success() throws Exception {
        doNothing().when(notificationService).markAsRead(notifId, userId);

        mockMvc.perform(patch("/api/v1/notifications/" + notifId + "/read")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Notification marked as read"));
    }

    @Test
    void markAllAsRead_Success() throws Exception {
        doNothing().when(notificationService).markAllAsRead(userId);

        mockMvc.perform(patch("/api/v1/notifications/read-all")
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("All notifications marked as read"));
    }
}
