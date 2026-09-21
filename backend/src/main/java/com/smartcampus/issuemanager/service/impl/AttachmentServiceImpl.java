package com.smartcampus.issuemanager.service.impl;

import com.smartcampus.issuemanager.dto.AttachmentResponse;
import com.smartcampus.issuemanager.entity.Issue;
import com.smartcampus.issuemanager.entity.IssueAttachment;
import com.smartcampus.issuemanager.entity.IssueMessage;
import com.smartcampus.issuemanager.entity.User;
import com.smartcampus.issuemanager.exception.BadRequestException;
import com.smartcampus.issuemanager.exception.ResourceNotFoundException;
import com.smartcampus.issuemanager.repository.IssueAttachmentRepository;
import com.smartcampus.issuemanager.repository.IssueMessageRepository;
import com.smartcampus.issuemanager.repository.IssueRepository;
import com.smartcampus.issuemanager.repository.UserRepository;
import com.smartcampus.issuemanager.service.AttachmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AttachmentServiceImpl implements AttachmentService {

    private final IssueAttachmentRepository attachmentRepository;
    private final IssueRepository issueRepository;
    private final IssueMessageRepository messageRepository;
    private final UserRepository userRepository;

    private final Path fileStorageLocation = Paths.get("uploads").toAbsolutePath().normalize();

    @Override
    @Transactional
    public AttachmentResponse uploadAttachment(UUID issueId, UUID messageId, MultipartFile file, UUID currentUserId) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("File cannot be empty");
        }

        Issue issue = issueRepository.findById(issueId)
                .orElseThrow(() -> new ResourceNotFoundException("Issue not found with ID: " + issueId));

        User currentUser = userRepository.findById(currentUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + currentUserId));

        IssueMessage message = null;
        if (messageId != null) {
            message = messageRepository.findById(messageId).orElse(null);
        }

        try {
            Files.createDirectories(this.fileStorageLocation);
        } catch (Exception ex) {
            throw new BadRequestException("Could not create upload directory");
        }

        String rawFileName = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        String fileExtension = "";
        int extIdx = rawFileName.lastIndexOf('.');
        if (extIdx > 0) {
            fileExtension = rawFileName.substring(extIdx);
        }

        String uniqueFileName = UUID.randomUUID() + "_" + rawFileName.replaceAll("[^a-zA-Z0-9.-]", "_");
        Path targetLocation = this.fileStorageLocation.resolve(uniqueFileName);

        try {
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException ex) {
            log.error("Failed to store file {}", rawFileName, ex);
            throw new BadRequestException("Failed to store file: " + rawFileName);
        }

        String fileUrl = "/api/v1/files/" + uniqueFileName;

        IssueAttachment attachment = IssueAttachment.builder()
                .issue(issue)
                .message(message)
                .uploadedBy(currentUser)
                .storagePath(targetLocation.toString())
                .fileName(rawFileName)
                .contentType(file.getContentType() != null ? file.getContentType() : "application/octet-stream")
                .sizeBytes(file.getSize())
                .thumbnailUrl(fileUrl)
                .build();

        IssueAttachment saved = attachmentRepository.save(attachment);
        log.info("Uploaded attachment {} for issue {}", saved.getId(), issue.getIssueNumber());

        return mapToResponse(saved, fileUrl);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AttachmentResponse> getAttachmentsByIssueId(UUID issueId) {
        return attachmentRepository.findByIssueIdOrderByCreatedAtDesc(issueId)
                .stream()
                .map(att -> {
                    String filename = Paths.get(att.getStoragePath()).getFileName().toString();
                    String url = "/api/v1/files/" + filename;
                    return mapToResponse(att, url);
                })
                .collect(Collectors.toList());
    }

    @Override
    public Resource loadFileAsResource(String fileName) {
        try {
            Path filePath = this.fileStorageLocation.resolve(fileName).normalize();
            Resource resource = new UrlResource(filePath.toUri());
            if (resource.exists()) {
                return resource;
            } else {
                throw new ResourceNotFoundException("File not found: " + fileName);
            }
        } catch (MalformedURLException ex) {
            throw new ResourceNotFoundException("File path is invalid: " + fileName);
        }
    }

    private AttachmentResponse mapToResponse(IssueAttachment att, String fileUrl) {
        return AttachmentResponse.builder()
                .id(att.getId())
                .issueId(att.getIssue().getId())
                .messageId(att.getMessage() != null ? att.getMessage().getId() : null)
                .uploadedByUserId(att.getUploadedBy() != null ? att.getUploadedBy().getId() : null)
                .uploadedByName(att.getUploadedBy() != null ? att.getUploadedBy().getDisplayName() : null)
                .storagePath(att.getStoragePath())
                .fileName(att.getFileName())
                .contentType(att.getContentType())
                .sizeBytes(att.getSizeBytes())
                .fileUrl(fileUrl)
                .thumbnailUrl(fileUrl)
                .createdAt(att.getCreatedAt())
                .build();
    }
}
