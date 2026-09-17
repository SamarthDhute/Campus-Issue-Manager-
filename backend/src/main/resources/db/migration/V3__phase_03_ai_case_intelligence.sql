-- Smart Campus Issue Manager: Phase 03 AI Case Intelligence Schema

-- 1. AI Analyses Table
CREATE TABLE IF NOT EXISTS ai_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    status VARCHAR(32) NOT NULL DEFAULT 'COMPLETED',
    model VARCHAR(64) NOT NULL DEFAULT 'gemini-1.5-flash',
    summary TEXT,
    missing_information TEXT,
    confidence NUMERIC(5, 4) DEFAULT 0.8500,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_ai_analyses_issue_id ON ai_analyses(issue_id);
CREATE INDEX IF NOT EXISTS idx_ai_analyses_created_at ON ai_analyses(created_at);

-- 2. AI Recommendations Table
CREATE TABLE IF NOT EXISTS ai_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ai_analysis_id UUID NOT NULL REFERENCES ai_analyses(id) ON DELETE CASCADE,
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(64) NOT NULL,
    suggested_value TEXT NOT NULL,
    confidence NUMERIC(5, 4) NOT NULL DEFAULT 0.8500,
    explanation TEXT,
    decision VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    decided_by UUID REFERENCES users(id) ON DELETE SET NULL,
    decided_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_ai_recommendations_analysis ON ai_recommendations(ai_analysis_id);
CREATE INDEX IF NOT EXISTS idx_ai_recommendations_issue ON ai_recommendations(issue_id);
CREATE INDEX IF NOT EXISTS idx_ai_recommendations_decision ON ai_recommendations(decision);

-- 3. Issue Relationships Table (Related / Duplicate detections)
CREATE TABLE IF NOT EXISTS issue_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    related_issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    relationship_type VARCHAR(32) NOT NULL DEFAULT 'DUPLICATE_CANDIDATE',
    confidence NUMERIC(5, 4) NOT NULL DEFAULT 0.8000,
    explanation TEXT,
    confirmed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    confirmed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_issue_relationships UNIQUE (issue_id, related_issue_id)
);

CREATE INDEX IF NOT EXISTS idx_issue_relationships_issue ON issue_relationships(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_relationships_related ON issue_relationships(related_issue_id);

-- 4. AI Context Items Table
CREATE TABLE IF NOT EXISTS ai_context_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    context_type VARCHAR(64) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_ai_context_issue ON ai_context_items(issue_id);

-- 5. Seed Initial AI Case Intelligence for Demo Issues
DO $$
DECLARE
    issue_1_id UUID;
    issue_2_id UUID;
    ai_1_id UUID;
    ai_2_id UUID;
BEGIN
    SELECT id INTO issue_1_id FROM issues WHERE issue_number = 'ISS-2026-0001' LIMIT 1;
    SELECT id INTO issue_2_id FROM issues WHERE issue_number = 'ISS-2026-0002' LIMIT 1;

    -- Seed AI Analysis for Issue 1 (Water Leak)
    IF issue_1_id IS NOT NULL THEN
        INSERT INTO ai_analyses (id, issue_id, status, model, summary, missing_information, confidence, created_at, completed_at)
        VALUES (
            gen_random_uuid(),
            issue_1_id,
            'COMPLETED',
            'gemini-1.5-flash',
            'Active water pipe leak on Hostel Block B 2nd floor ceiling creating safety and slipping hazards for residents.',
            'None. Specific room location (Room 204) and hazard severity provided.',
            0.9400,
            CURRENT_TIMESTAMP - INTERVAL '2 days',
            CURRENT_TIMESTAMP - INTERVAL '2 days'
        )
        RETURNING id INTO ai_1_id;

        INSERT INTO ai_recommendations (ai_analysis_id, issue_id, recommendation_type, suggested_value, confidence, explanation, decision)
        VALUES
        (ai_1_id, issue_1_id, 'PRIORITY', 'HIGH', 0.9400, 'Water leakage with active dripping ceiling near residential rooms poses structural and slipping risks.', 'ACCEPTED'),
        (ai_1_id, issue_1_id, 'NEXT_ACTION', 'Dispatch plumbing technician with pipe isolation valve key and sealant kit immediately.', 0.9200, 'Ceiling leak requires immediate water isolation to prevent floor flooding.', 'ACCEPTED');
    END IF;

    -- Seed AI Analysis for Issue 2 (Projector Failure)
    IF issue_2_id IS NOT NULL THEN
        INSERT INTO ai_analyses (id, issue_id, status, model, summary, missing_information, confidence, created_at, completed_at)
        VALUES (
            gen_random_uuid(),
            issue_2_id,
            'COMPLETED',
            'gemini-1.5-flash',
            'Ceiling projector in Academic Block Classroom 402 fails to display video with red error LED indicator.',
            'Specify whether lamp warning LED or power LED is flashing.',
            0.8800,
            CURRENT_TIMESTAMP - INTERVAL '5 hours',
            CURRENT_TIMESTAMP - INTERVAL '5 hours'
        )
        RETURNING id INTO ai_2_id;

        INSERT INTO ai_recommendations (ai_analysis_id, issue_id, recommendation_type, suggested_value, confidence, explanation, decision)
        VALUES
        (ai_2_id, issue_2_id, 'PRIORITY', 'MEDIUM', 0.8800, 'Classroom equipment failure during regular lecture hours disrupts scheduled classes.', 'PENDING'),
        (ai_2_id, issue_2_id, 'NEXT_ACTION', 'Assign AV/Electrical technician to test HDMI input cable and reset projector thermal sensor.', 0.8600, 'Red blinking indicator typically signifies thermal sensor lock or lamp failure.', 'PENDING');
    END IF;
END $$;
