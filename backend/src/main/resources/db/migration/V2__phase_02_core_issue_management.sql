-- Smart Campus Issue Manager: Phase 02 Core Issue Management Schema

-- 1. Issues Table
CREATE TABLE IF NOT EXISTS issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_number VARCHAR(32) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    location VARCHAR(255) NOT NULL,
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    assigned_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'REPORTED',
    priority VARCHAR(16) NOT NULL DEFAULT 'MEDIUM',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_issues_requester ON issues(requester_id);
CREATE INDEX IF NOT EXISTS idx_issues_assigned_user ON issues(assigned_user_id);
CREATE INDEX IF NOT EXISTS idx_issues_assigned_team ON issues(assigned_team_id);
CREATE INDEX IF NOT EXISTS idx_issues_status ON issues(status);
CREATE INDEX IF NOT EXISTS idx_issues_category ON issues(category_id);
CREATE INDEX IF NOT EXISTS idx_issues_issue_number ON issues(issue_number);

-- 2. Issue Attachments Table
CREATE TABLE IF NOT EXISTS issue_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    storage_path VARCHAR(512) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    content_type VARCHAR(128) NOT NULL,
    size_bytes BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_attachments_issue ON issue_attachments(issue_id);

-- 3. Issue Timeline Events Table
CREATE TABLE IF NOT EXISTS issue_timeline_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    event_type VARCHAR(64) NOT NULL,
    actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    description TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_timeline_issue_id ON issue_timeline_events(issue_id);
CREATE INDEX IF NOT EXISTS idx_timeline_created_at ON issue_timeline_events(created_at);

-- 4. Initial Seed Data for Phase 2 Testing
DO $$
DECLARE
    org_id UUID;
    student_id UUID;
    operator_id UUID;
    team_lead_id UUID;
    water_cat_id UUID;
    electrical_cat_id UUID;
    it_cat_id UUID;
    facility_team_id UUID;
    electrical_team_id UUID;
    issue_1_id UUID;
    issue_2_id UUID;
BEGIN
    SELECT id INTO org_id FROM organizations LIMIT 1;
    SELECT id INTO student_id FROM users WHERE email = 'student@smartcampus.edu';
    SELECT id INTO operator_id FROM users WHERE email = 'operator@smartcampus.edu';
    SELECT id INTO team_lead_id FROM users WHERE email = 'teamlead@smartcampus.edu';
    
    SELECT id INTO water_cat_id FROM categories WHERE name = 'Water & Plumbing' LIMIT 1;
    SELECT id INTO electrical_cat_id FROM categories WHERE name = 'Electrical & Power' LIMIT 1;
    SELECT id INTO it_cat_id FROM categories WHERE name = 'Network & IT Support' LIMIT 1;

    SELECT id INTO facility_team_id FROM teams WHERE name = 'Hostel & Facility Maintenance' LIMIT 1;
    SELECT id INTO electrical_team_id FROM teams WHERE name = 'Electrical & Maintenance Team' LIMIT 1;

    IF student_id IS NOT NULL AND water_cat_id IS NOT NULL THEN
        -- Seed Issue 1: Water Leakage
        INSERT INTO issues (id, issue_number, title, description, category_id, location, requester_id, assigned_team_id, assigned_user_id, status, priority, created_at, updated_at)
        VALUES (
            gen_random_uuid(),
            'ISS-2026-0001',
            'Severe water leakage in Hostel Block B second floor washroom',
            'Continuous water dripping from the ceiling pipe causing wet floor and slipping hazard near Room 204.',
            water_cat_id,
            'Hostel Block B, 2nd Floor, Room 204 Washroom',
            student_id,
            facility_team_id,
            operator_id,
            'INVESTIGATED',
            'HIGH',
            CURRENT_TIMESTAMP - INTERVAL '2 days',
            CURRENT_TIMESTAMP - INTERVAL '1 hour'
        )
        RETURNING id INTO issue_1_id;

        -- Timeline for Issue 1
        INSERT INTO issue_timeline_events (issue_id, event_type, actor_id, description, created_at)
        VALUES
        (issue_1_id, 'CREATED', student_id, 'Issue reported by student Aarav Sharma', CURRENT_TIMESTAMP - INTERVAL '2 days'),
        (issue_1_id, 'ASSIGNED', team_lead_id, 'Assigned to Hostel & Facility Maintenance team and Operator Vikram Singh', CURRENT_TIMESTAMP - INTERVAL '1 day'),
        (issue_1_id, 'STATUS_CHANGED', operator_id, 'Status updated from ASSIGNED to INVESTIGATED. Pipe joint inspection completed.', CURRENT_TIMESTAMP - INTERVAL '1 hour');

        -- Seed Issue 2: Broken Projector
        IF electrical_cat_id IS NOT NULL THEN
            INSERT INTO issues (id, issue_number, title, description, category_id, location, requester_id, assigned_team_id, assigned_user_id, status, priority, created_at, updated_at)
            VALUES (
                gen_random_uuid(),
                'ISS-2026-0002',
                'Classroom 402 Ceiling Projector not powering on',
                'HDMI signal disconnects and power indicator is blinking red during lectures.',
                electrical_cat_id,
                'Academic Block 1, Classroom 402',
                student_id,
                electrical_team_id,
                NULL,
                'REPORTED',
                'MEDIUM',
                CURRENT_TIMESTAMP - INTERVAL '5 hours',
                CURRENT_TIMESTAMP - INTERVAL '5 hours'
            )
            RETURNING id INTO issue_2_id;

            -- Timeline for Issue 2
            INSERT INTO issue_timeline_events (issue_id, event_type, actor_id, description, created_at)
            VALUES
            (issue_2_id, 'CREATED', student_id, 'Issue reported by student Aarav Sharma', CURRENT_TIMESTAMP - INTERVAL '5 hours');
        END IF;
    END IF;
END $$;
