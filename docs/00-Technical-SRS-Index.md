# Smart Campus Issue Manager --- Technical SRS Index

This folder contains nine development-ready SRS documents. Each phase
combines product behavior with implementation guidance: architecture,
folder structure, APIs, database changes, migrations, validation,
security and testing.

## Architecture

``` text
Flutter → Spring Boot REST API → Service → Repository → JPA/Hibernate → Supabase Cloud PostgreSQL
                                      ├→ LLM API
                                      ├→ Supabase Storage
                                      └→ FCM / Email
```

## Repository Structure

``` text
Smart-Campus-Issue-Manager/
├── frontend/
├── backend/
├── docs/
│   └── SRS/
├── docker/
└── README.md
```

## Phase Order

``` text
01 Foundation
 ↓
02 Core Issue Management
 ↓
03 AI Case Intelligence
 ↓
04 Smart Operations
 ↓
05 SLA & Automation
 ↓
06 Communication & Resolution
 ↓
07 Management & Operational Insights
 ↓
08 Trust, Audit & Production Readiness
 ↓
09 Final Validation & Demo
```

## Required Automation Capabilities

1.  Automatic AI Case Analysis
2.  Automatic Case Summarization
3.  Automatic Missing Information Detection
4.  Automatic Related/Duplicate Case Detection
5.  Smart Assignment Recommendation
6.  Automatic SLA and Risk Detection
7.  Escalation Automation
8.  AI-Generated Communication
9.  Automated Notifications
10. Automatic Case Timeline and Audit Logging
11. AI-Powered Operational Insights

## Database

Supabase Cloud PostgreSQL is the selected database platform. Flyway owns
schema versioning. Local PostgreSQL/Supabase is not required for the
selected architecture.

## Engineering Rules

-   Controllers stay thin.
-   Services contain business rules.
-   Repositories contain persistence logic.
-   DTOs define API contracts.
-   Backend authorization is authoritative.
-   AI output is distinguishable from confirmed facts.
-   Core issue management continues if AI is unavailable.
-   Important actions are auditable.
-   No hardcoded business records.
-   Frontend uses centralized design tokens and reusable components.
