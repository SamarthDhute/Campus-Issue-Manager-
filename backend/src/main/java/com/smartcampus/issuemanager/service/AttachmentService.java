package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.AttachmentResponse;
import org.springframework.core.io.Resource;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

public interface AttachmentService {

    AttachmentResponse uploadAttachment(UUID issueId, UUID messageId, MultipartFile file, UUID currentUserId);

    List<AttachmentResponse> getAttachmentsByIssueId(UUID issueId);

    Resource loadFileAsResource(String fileName);
}
