-- ====================================================================
-- Phase 6: Communication, Media Evidence & Resolution Suite Migration
-- ====================================================================

-- 1. Extend issue_attachments if needed
ALTER TABLE issue_attachments ADD COLUMN IF NOT EXISTS message_id UUID REFERENCES messages(id) ON DELETE SET NULL;
ALTER TABLE issue_attachments ADD COLUMN IF NOT EXISTS uploaded_by_user_id UUID REFERENCES users(id);
ALTER TABLE issue_attachments ADD COLUMN IF NOT EXISTS thumbnail_url VARCHAR(1000);

CREATE INDEX IF NOT EXISTS idx_issue_attachments_message_id ON issue_attachments(message_id);

-- 2. Resolution Evidence (Before/After photos & technical proof from field staff)
CREATE TABLE IF NOT EXISTS resolution_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    uploaded_by_user_id UUID NOT NULL REFERENCES users(id),
    evidence_type VARCHAR(50) NOT NULL DEFAULT 'AFTER_REPAIR', -- BEFORE_REPAIR, AFTER_REPAIR, RECEIPT, INSPECTION, OTHER
    file_url VARCHAR(1000) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size BIGINT DEFAULT 0,
    mime_type VARCHAR(100) DEFAULT 'image/jpeg',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_resolution_evidence_issue_id ON resolution_evidence(issue_id);
CREATE INDEX IF NOT EXISTS idx_resolution_evidence_type ON resolution_evidence(evidence_type);

-- 3. Issue Feedbacks (Requester ratings, satisfaction scores, reopening reasons)
CREATE TABLE IF NOT EXISTS issue_feedbacks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL UNIQUE REFERENCES issues(id) ON DELETE CASCADE,
    submitted_by_user_id UUID NOT NULL REFERENCES users(id),
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    feedback_text TEXT,
    resolution_quality VARCHAR(50) DEFAULT 'SATISFIED', -- POOR, AVERAGE, SATISFIED, EXCELLENT
    reopened_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_issue_feedbacks_issue_id ON issue_feedbacks(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_feedbacks_rating ON issue_feedbacks(rating);
