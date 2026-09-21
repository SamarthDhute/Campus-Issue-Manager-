package com.smartcampus.issuemanager.controller;

import com.smartcampus.issuemanager.dto.AttachmentResponse;
import com.smartcampus.issuemanager.entity.Role;
import com.smartcampus.issuemanager.security.JwtTokenProvider;
import com.smartcampus.issuemanager.security.UserPrincipal;
import com.smartcampus.issuemanager.service.AttachmentService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.mock.web.MockMultipartFile;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class AttachmentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AttachmentService attachmentService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    private UserPrincipal testUserPrincipal;
    private UsernamePasswordAuthenticationToken auth;
    private UUID issueId;
    private UUID userId;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
        issueId = UUID.randomUUID();

        testUserPrincipal = new UserPrincipal(
                userId,
                "student@smartcampus.edu",
                "Password@123",
                "Aarav Student",
                Role.STUDENT,
                UUID.randomUUID(),
                List.of(new SimpleGrantedAuthority("ROLE_STUDENT"))
        );
        auth = new UsernamePasswordAuthenticationToken(
                testUserPrincipal,
                null,
                testUserPrincipal.getAuthorities()
        );
    }

    @Test
    void testUploadAttachment() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "leakage.jpg",
                "image/jpeg",
                "test image content".getBytes()
        );

        AttachmentResponse response = AttachmentResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .uploadedByUserId(userId)
                .uploadedByName("Aarav Student")
                .fileName("leakage.jpg")
                .contentType("image/jpeg")
                .sizeBytes(18L)
                .fileUrl("/api/v1/files/sample_leakage.jpg")
                .createdAt(OffsetDateTime.now())
                .build();

        when(attachmentService.uploadAttachment(eq(issueId), any(), any(), eq(userId)))
                .thenReturn(response);

        mockMvc.perform(multipart("/api/v1/issues/{issueId}/attachments", issueId)
                        .file(file)
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.fileName").value("leakage.jpg"))
                .andExpect(jsonPath("$.fileUrl").value("/api/v1/files/sample_leakage.jpg"));
    }

    @Test
    void testGetAttachments() throws Exception {
        AttachmentResponse response = AttachmentResponse.builder()
                .id(UUID.randomUUID())
                .issueId(issueId)
                .fileName("leakage.jpg")
                .fileUrl("/api/v1/files/sample_leakage.jpg")
                .build();

        when(attachmentService.getAttachmentsByIssueId(issueId))
                .thenReturn(List.of(response));

        mockMvc.perform(get("/api/v1/issues/{issueId}/attachments", issueId)
                        .with(authentication(auth)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].fileName").value("leakage.jpg"));
    }
}
