package com.smartcampus.issuemanager.service;

import com.smartcampus.issuemanager.dto.FeedbackResponse;
import com.smartcampus.issuemanager.dto.IssueResponse;
import com.smartcampus.issuemanager.dto.ReopenIssueRequest;
import com.smartcampus.issuemanager.dto.SubmitFeedbackRequest;

import java.util.UUID;

public interface FeedbackService {

    FeedbackResponse submitFeedback(UUID issueId, SubmitFeedbackRequest request, UUID currentUserId);

    IssueResponse reopenIssue(UUID issueId, ReopenIssueRequest request, UUID currentUserId);

    FeedbackResponse getFeedbackByIssueId(UUID issueId);
}
