-- Smart Campus Issue Manager: Phase 05 SLA Automation, Risk Engine, Escalations & Notifications Schema

-- 1. SLA Policies Table
CREATE TABLE IF NOT EXISTS sla_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    priority VARCHAR(50) NOT NULL DEFAULT 'MEDIUM',
    response_minutes INT NOT NULL,
    resolution_minutes INT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sla_policies_org ON sla_policies(organization_id);
CREATE INDEX IF NOT EXISTS idx_sla_policies_category ON sla_policies(category_id);
CREATE INDEX IF NOT EXISTS idx_sla_policies_priority ON sla_policies(priority);
CREATE INDEX IF NOT EXISTS idx_sla_policies_active ON sla_policies(active);

-- 2. Issue SLA Tracking Table
CREATE TABLE IF NOT EXISTS issue_sla (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL UNIQUE REFERENCES issues(id) ON DELETE CASCADE,
    sla_policy_id UUID REFERENCES sla_policies(id) ON DELETE SET NULL,
    response_due_at TIMESTAMP WITH TIME ZONE NOT NULL,
    resolution_due_at TIMESTAMP WITH TIME ZONE NOT NULL,
    response_met_at TIMESTAMP WITH TIME ZONE,
    resolution_met_at TIMESTAMP WITH TIME ZONE,
    response_breached_at TIMESTAMP WITH TIME ZONE,
    resolution_breached_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) NOT NULL DEFAULT 'ON_TRACK',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_issue_sla_issue ON issue_sla(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_sla_status ON issue_sla(status);
CREATE INDEX IF NOT EXISTS idx_issue_sla_response_due ON issue_sla(response_due_at);
CREATE INDEX IF NOT EXISTS idx_issue_sla_resolution_due ON issue_sla(resolution_due_at);

-- 3. Risk Events Table (Proactive risk detection signals)
CREATE TABLE IF NOT EXISTS risk_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    risk_type VARCHAR(100) NOT NULL,
    severity VARCHAR(50) NOT NULL DEFAULT 'MEDIUM',
    explanation TEXT NOT NULL,
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_risk_events_issue ON risk_events(issue_id);
CREATE INDEX IF NOT EXISTS idx_risk_events_type ON risk_events(risk_type);
CREATE INDEX IF NOT EXISTS idx_risk_events_severity ON risk_events(severity);
CREATE INDEX IF NOT EXISTS idx_risk_events_detected_at ON risk_events(detected_at);

-- 4. Escalations Table (Multi-tier escalation lifecycle)
CREATE TABLE IF NOT EXISTS escalations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    trigger_type VARCHAR(100) NOT NULL,
    level INT NOT NULL DEFAULT 1,
    status VARCHAR(50) NOT NULL DEFAULT 'OPEN',
    reason TEXT NOT NULL,
    triggered_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    triggered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_escalations_issue ON escalations(issue_id);
CREATE INDEX IF NOT EXISTS idx_escalations_level ON escalations(level);
CREATE INDEX IF NOT EXISTS idx_escalations_status ON escalations(status);
CREATE INDEX IF NOT EXISTS idx_escalations_triggered_at ON escalations(triggered_at);

-- 5. Notifications Table (In-app and channel notifications)
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    notification_type VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    channel VARCHAR(50) NOT NULL DEFAULT 'IN_APP',
    status VARCHAR(50) NOT NULL DEFAULT 'UNREAD',
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON notifications(recipient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_status ON notifications(status);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_issue ON notifications(issue_id);

-- 6. Seed Default Organization SLA Policies
DO $$
DECLARE
    v_org_id UUID;
BEGIN
    SELECT id INTO v_org_id FROM organizations LIMIT 1;
    
    IF v_org_id IS NOT NULL THEN
        -- URGENT: 15 mins response, 2 hours (120 mins) resolution
        INSERT INTO sla_policies (organization_id, priority, response_minutes, resolution_minutes, active)
        VALUES (v_org_id, 'URGENT', 15, 120, TRUE);

        -- HIGH: 30 mins response, 4 hours (240 mins) resolution
        INSERT INTO sla_policies (organization_id, priority, response_minutes, resolution_minutes, active)
        VALUES (v_org_id, 'HIGH', 30, 240, TRUE);

        -- MEDIUM: 60 mins response, 8 hours (480 mins) resolution
        INSERT INTO sla_policies (organization_id, priority, response_minutes, resolution_minutes, active)
        VALUES (v_org_id, 'MEDIUM', 60, 480, TRUE);

        -- LOW: 120 mins response, 24 hours (1440 mins) resolution
        INSERT INTO sla_policies (organization_id, priority, response_minutes, resolution_minutes, active)
        VALUES (v_org_id, 'LOW', 120, 1440, TRUE);

        -- Auto-seed issue_sla for any existing issues
        INSERT INTO issue_sla (issue_id, response_due_at, resolution_due_at, status, created_at)
        SELECT 
            i.id,
            i.created_at + INTERVAL '60 minutes',
            i.created_at + INTERVAL '480 minutes',
            CASE 
                WHEN i.status IN ('RESOLVED_PENDING_CONFIRMATION', 'CLOSED') THEN 'MET'
                ELSE 'ON_TRACK'
            END,
            i.created_at
        FROM issues i
        WHERE NOT EXISTS (SELECT 1 FROM issue_sla s WHERE s.issue_id = i.id)
        ON CONFLICT (issue_id) DO NOTHING;
    END IF;
END $$;
