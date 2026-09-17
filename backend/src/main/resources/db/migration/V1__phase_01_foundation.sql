-- Smart Campus Issue Manager: Phase 01 Foundation Schema
-- Extension for UUID generation if not present
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Organizations
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Users
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index on email for fast lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_org ON users(organization_id);

-- 3. Teams
CREATE TABLE IF NOT EXISTS teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_teams_org ON teams(organization_id);

-- 4. User Teams (Junction)
CREATE TABLE IF NOT EXISTS user_teams (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, team_id)
);

-- 5. Categories
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_categories_org ON categories(organization_id);
CREATE INDEX IF NOT EXISTS idx_categories_active ON categories(active);

-- ==============================================================================
-- Default Seed Data for Foundation
-- Default Password for all seed accounts: Password@123
-- BCrypt Hash: $2a$10$wTfkQ7n4h8j.2L7x9Ckevu9tN0bYkXf0R4n.vH7Y/Y7ZqXgW1Q2qO
-- ==============================================================================

-- Insert Organization
INSERT INTO organizations (id, name, created_at, updated_at)
VALUES ('a0000000-0000-0000-0000-000000000001', 'Smart Campus Main University', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Insert Default Teams
INSERT INTO teams (id, organization_id, name, description, created_at, updated_at) VALUES
('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'IT & Infrastructure Support', 'Handles campus Wi-Fi, classroom tech, smart screens, and software', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'Campus Facilities & Maintenance', 'Handles civil structures, electrical circuits, and water plumbing', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'Hostel & Residential Services', 'Handles student residential rooms, messes, and amenities', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Insert Default Categories
INSERT INTO categories (id, organization_id, name, description, active, created_at, updated_at) VALUES
('c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Electrical', 'Power cuts, faulty switches, broken wiring, lighting failures', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('c0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'Plumbing & Water', 'Water leakages, tap damages, washroom drainage issues', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('c0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'Internet & Wi-Fi', 'Network disconnections, weak Wi-Fi, router failures', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('c0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000001', 'Classroom Equipment', 'Projectors, microphones, smart podiums, broken seating', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('c0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000001', 'Hostel Amenities', 'Water coolers, lift maintenance, common room equipment', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('c0000000-0000-0000-0000-000000000006', 'a0000000-0000-0000-0000-000000000001', 'Cleanliness & Waste', 'Housekeeping, waste bins, campus sanitation', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Insert Seed Users for all 5 roles
INSERT INTO users (id, email, password_hash, display_name, role, organization_id, created_at, updated_at) VALUES
('d0000000-0000-0000-0000-000000000001', 'admin@smartcampus.edu', '$2a$10$wTfkQ7n4h8j.2L7x9Ckevu9tN0bYkXf0R4n.vH7Y/Y7ZqXgW1Q2qO', 'System Administrator', 'ADMIN', 'a0000000-0000-0000-0000-000000000001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('d0000000-0000-0000-0000-000000000002', 'manager@smartcampus.edu', '$2a$10$wTfkQ7n4h8j.2L7x9Ckevu9tN0bYkXf0R4n.vH7Y/Y7ZqXgW1Q2qO', 'Campus Operations Manager', 'MANAGER', 'a0000000-0000-0000-0000-000000000001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('d0000000-0000-0000-0000-000000000003', 'teamlead@smartcampus.edu', '$2a$10$wTfkQ7n4h8j.2L7x9Ckevu9tN0bYkXf0R4n.vH7Y/Y7ZqXgW1Q2qO', 'Facilities Team Lead', 'TEAM_LEAD', 'a0000000-0000-0000-0000-000000000001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('d0000000-0000-0000-0000-000000000004', 'operator@smartcampus.edu', '$2a$10$wTfkQ7n4h8j.2L7x9Ckevu9tN0bYkXf0R4n.vH7Y/Y7ZqXgW1Q2qO', 'Maintenance Operator', 'OPERATOR', 'a0000000-0000-0000-0000-000000000001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('d0000000-0000-0000-0000-000000000005', 'student@smartcampus.edu', '$2a$10$wTfkQ7n4h8j.2L7x9Ckevu9tN0bYkXf0R4n.vH7Y/Y7ZqXgW1Q2qO', 'Aarav Sharma (Student)', 'STUDENT', 'a0000000-0000-0000-0000-000000000001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Map Staff to Teams
INSERT INTO user_teams (user_id, team_id) VALUES
('d0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000002'), -- Lead to Facilities
('d0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000002')  -- Operator to Facilities
ON CONFLICT DO NOTHING;
