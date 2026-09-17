package com.smartcampus.issuemanager.dto;

import com.smartcampus.issuemanager.entity.IssuePriority;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateIssueRequest {

    @NotBlank(message = "Title is required")
    @Size(min = 5, max = 255, message = "Title must be between 5 and 255 characters")
    private String title;

    @NotBlank(message = "Description is required")
    @Size(min = 10, max = 5000, message = "Description must be between 10 and 5000 characters")
    private String description;

    @NotNull(message = "Category ID is required")
    private UUID categoryId;

    @NotBlank(message = "Location is required")
    @Size(min = 2, max = 255, message = "Location must be between 2 and 255 characters")
    private String location;

    @Builder.Default
    private IssuePriority priority = IssuePriority.MEDIUM;
}
