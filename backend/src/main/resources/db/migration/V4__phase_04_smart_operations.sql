-- Smart Campus Issue Manager: Phase 04 Smart Operations Schema

-- 1. Assignments Table (Tracks ownership and reassignment history)
CREATE TABLE IF NOT EXISTS assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    assignment_type VARCHAR(50) NOT NULL DEFAULT 'PRIMARY',
    recommendation_source VARCHAR(50) DEFAULT 'MANUAL',
    reason TEXT,
    assigned_by UUID REFERENCES users(id) ON DELETE SET NULL,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_assignments_issue ON assignments(issue_id);
CREATE INDEX IF NOT EXISTS idx_assignments_user ON assignments(user_id);
CREATE INDEX IF NOT EXISTS idx_assignments_team ON assignments(team_id);
CREATE INDEX IF NOT EXISTS idx_assignments_assigned_at ON assignments(assigned_at);

-- 2. Messages Table (Requester - Staff bidirectional communication)
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message_type VARCHAR(50) NOT NULL DEFAULT 'USER_MESSAGE',
    body TEXT NOT NULL,
    visibility VARCHAR(50) NOT NULL DEFAULT 'PUBLIC',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_messages_issue ON messages(issue_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);

-- 3. Internal Notes Table (Staff-only private notes)
CREATE TABLE IF NOT EXISTS internal_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_internal_notes_issue ON internal_notes(issue_id);
CREATE INDEX IF NOT EXISTS idx_internal_notes_author ON internal_notes(author_id);
CREATE INDEX IF NOT EXISTS idx_internal_notes_created_at ON internal_notes(created_at);

-- 4. Investigations Table (Field findings and technical observations)
CREATE TABLE IF NOT EXISTS investigations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    investigator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    observations TEXT NOT NULL,
    actions_taken TEXT,
    findings TEXT,
    follow_up TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_investigations_issue ON investigations(issue_id);
CREATE INDEX IF NOT EXISTS idx_investigations_investigator ON investigations(investigator_id);

-- 5. Tasks Table (Sub-tasks and operational checklist)
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    owner_id UUID REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    due_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_tasks_issue ON tasks(issue_id);
CREATE INDEX IF NOT EXISTS idx_tasks_owner ON tasks(owner_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);

-- 6. Task Evidence Table (Attachments / Proof for sub-tasks)
CREATE TABLE IF NOT EXISTS task_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    storage_path VARCHAR(500) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_task_evidence_task ON task_evidence(task_id);

-- 7. Seed Initial Smart Operations Data for Demo Issues
DO $$
DECLARE
    issue_1_id UUID;
    issue_2_id UUID;
    lead_id UUID;
    operator_id UUID;
    student_id UUID;
    plumbing_team_id UUID;
    electrical_team_id UUID;
    task_1_id UUID;
BEGIN
    SELECT id INTO issue_1_id FROM issues WHERE issue_number = 'ISS-2026-0001' LIMIT 1;
    SELECT id INTO issue_2_id FROM issues WHERE issue_number = 'ISS-2026-0002' LIMIT 1;
    
    SELECT id INTO lead_id FROM users WHERE email = 'teamlead@smartcampus.edu' LIMIT 1;
    SELECT id INTO operator_id FROM users WHERE email = 'operator@smartcampus.edu' LIMIT 1;
    SELECT id INTO student_id FROM users WHERE email = 'student@smartcampus.edu' LIMIT 1;

    SELECT id INTO plumbing_team_id FROM teams WHERE name = 'Plumbing & Water Services' LIMIT 1;
    SELECT id INTO electrical_team_id FROM teams WHERE name = 'Electrical & Power Infrastructure' LIMIT 1;

    -- Seed for Issue 1 (Water Leakage)
    IF issue_1_id IS NOT NULL AND operator_id IS NOT NULL THEN
        -- Assignment Record
        INSERT INTO assignments (id, issue_id, team_id, user_id, assignment_type, recommendation_source, reason, assigned_by, assigned_at)
        VALUES (
            gen_random_uuid(),
            issue_1_id,
            plumbing_team_id,
            operator_id,
            'PRIMARY',
            'AI_RECOMMENDED',
            'Optimal match: Vikram Singh (Plumbing & Water specialist) with lowest active workload queue.',
            lead_id,
            CURRENT_TIMESTAMP - INTERVAL '1 day'
        );

        -- Internal Staff Note
        INSERT INTO internal_notes (id, issue_id, author_id, body, created_at)
        VALUES (
            gen_random_uuid(),
            issue_1_id,
            lead_id,
            'Prioritized due to ceiling water pooling near main hallway electrical conduits. Advised technician to verify shutoff valve before pipe replacement.',
            CURRENT_TIMESTAMP - INTERVAL '18 hours'
        );

        -- Requester Public Messages
        INSERT INTO messages (id, issue_id, sender_id, message_type, body, visibility, created_at)
        VALUES 
        (
            gen_random_uuid(),
            issue_1_id,
            operator_id,
            'OPERATOR_UPDATE',
            'Hello Aarav, I have inspected the second floor riser. A replacement rubber seal has been requisitioned from the central store.',
            'PUBLIC',
            CURRENT_TIMESTAMP - INTERVAL '12 hours'
        ),
        (
            gen_random_uuid(),
            issue_1_id,
            student_id,
            'USER_MESSAGE',
            'Thank you for the update! Please note the dripping is slightly heavier during morning hours (7-9 AM).',
            'PUBLIC',
            CURRENT_TIMESTAMP - INTERVAL '10 hours'
        );

        -- Field Investigation Report
        INSERT INTO investigations (id, issue_id, investigator_id, observations, actions_taken, findings, follow_up, created_at, updated_at)
        VALUES (
            gen_random_uuid(),
            issue_1_id,
            operator_id,
            'Observed moisture seepage around 2-inch PVC junction above Room 204 false ceiling tile.',
            'Turned off sub-zone valve B-2 temporarily, relieved line pressure, applied high-durability epoxy sealant compound.',
            'Vibration from 3rd floor washing machine drain caused thread slippage on the non-reinforced coupling.',
            'Schedule permanent brass sleeve installation during weekend facility maintenance window.',
            CURRENT_TIMESTAMP - INTERVAL '6 hours',
            CURRENT_TIMESTAMP - INTERVAL '6 hours'
        );

        -- Sub-tasks
        INSERT INTO tasks (id, issue_id, title, description, owner_id, status, due_at, completed_at, created_at)
        VALUES 
        (
            gen_random_uuid(),
            issue_1_id,
            'Isolate water supply valve for Block B East Wing',
            'Access riser room 200 and close gate valve #4.',
            operator_id,
            'COMPLETED',
            CURRENT_TIMESTAMP - INTERVAL '16 hours',
            CURRENT_TIMESTAMP - INTERVAL '15 hours',
            CURRENT_TIMESTAMP - INTERVAL '18 hours'
        ),
        (
            gen_random_uuid(),
            issue_1_id,
            'Apply waterproof silicone & pressure clamp',
            'Clean PVC surface and install reinforced pipe clamp.',
            operator_id,
            'COMPLETED',
            CURRENT_TIMESTAMP - INTERVAL '8 hours',
            CURRENT_TIMESTAMP - INTERVAL '7 hours',
            CURRENT_TIMESTAMP - INTERVAL '18 hours'
        ),
        (
            gen_random_uuid(),
            issue_1_id,
            'Pressure test and moisture level check 24h post-fix',
            'Verify no seepage and reinstall moisture-damaged ceiling tile.',
            operator_id,
            'IN_PROGRESS',
            CURRENT_TIMESTAMP + INTERVAL '12 hours',
            NULL,
            CURRENT_TIMESTAMP - INTERVAL '18 hours'
        );
    END IF;

    -- Seed for Issue 2 (Projector Failure)
    IF issue_2_id IS NOT NULL AND operator_id IS NOT NULL THEN
        INSERT INTO tasks (id, issue_id, title, description, owner_id, status, due_at, created_at)
        VALUES (
            gen_random_uuid(),
            issue_2_id,
            'Test HDMI signal and power circuit in Room 402',
            'Check ceiling drop box and AV wall plate using multimeter and test laptop.',
            operator_id,
            'PENDING',
            CURRENT_TIMESTAMP + INTERVAL '24 hours',
            CURRENT_TIMESTAMP - INTERVAL '4 hours'
        );
    END IF;
END $$;
