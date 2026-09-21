# 🏫 Smart Campus Issue Manager — Progress & System Architecture

**Project Repository**: `https://github.com/SamarthDhute/Campus-Issue-Manager`  
- **Current Active Branch**: `feature/phase-05-sla-automation`  
- **Current Status**: **Phases 1, 2, 3, 4 & 5 (SLA Automation & Escalations) 100% Completed, Verified & Tested**

---

## 📌 Executive Summary

Smart Campus Issue Manager is an enterprise-grade, role-based campus facility and maintenance ticketing system designed for universities and institutes. It connects students, faculty, facility operators, team leads, and campus managers in a transparent, real-time lifecycle tracking workflow.

### Tech Stack:
- **Backend**: Java 22, Spring Boot 3.3.5, Spring Security (JWT), Spring Data JPA, Flyway Migration, PostgreSQL (Supabase pooler), Maven.
- **Frontend**: Flutter Web (CanvasKit / HTML), Provider State Management, Material 3 Custom AppTheme, Secure Storage, Responsive Multi-Role Views.
- **AI Intelligence**: Google Gemini 1.5 Flash REST API Integration with Heuristic Fallback Engine for 100% operational uptime.
- **Testing**: JUnit 5, Mockito, MockMvc (30 Passing Test Suites), Flutter Unit Tests (24 Passing Suites).

---

## 🏗️ System Architecture & Layering

```
smart-campus-issue-manager/
├── backend/
│   ├── src/main/java/com/smartcampus/issuemanager/
│   │   ├── config/          # SecurityConfig, CorsConfig, OpenApiConfig, Seeder
│   │   ├── controller/      # AuthController, UserController, IssueController, CategoryController, AiController, OperationsController, SlaController, NotificationController
│   │   ├── dto/             # Auth, Profile, Issue, Category, Timeline, AiAnalysis, AiRecommendation, Assignment, Message, InternalNote, Investigation, Task, IssueSla, RiskEvent, Escalation, Notification
│   │   ├── entity/          # User, Organization, Role, Issue, Category, Timeline, AiAnalysis, AiRecommendation, Assignment, IssueMessage, InternalNote, Investigation, IssueTask, SlaPolicy, IssueSla, RiskEvent, Escalation, Notification
│   │   ├── exception/       # GlobalExceptionHandler, ResourceNotFoundException, BadRequestException
│   │   ├── integration/ai/  # GeminiClient (Gemini Flash API + Heuristic engine)
│   │   ├── repository/      # UserRepository, IssueRepository, CategoryRepository, AssignmentRepository, IssueMessageRepository, InternalNoteRepository, InvestigationRepository, IssueTaskRepository, SlaPolicyRepository, IssueSlaRepository, RiskEventRepository, EscalationRepository, NotificationRepository
│   │   ├── scheduler/       # SlaAutomationScheduler (Periodic cron evaluating burn rate, risk detection & auto-escalation)
│   │   ├── security/        # JwtTokenProvider, JwtAuthenticationFilter, UserPrincipal, CustomUserDetailsService
│   │   └── service/         # AuthService, UserService, IssueService, CategoryService, AiCaseIntelligenceService, SmartOperationsService, SlaService, RiskAssessmentService, EscalationService, NotificationService (+ Impls)
│   └── src/main/resources/db/migration/
│       ├── V1__phase_01_foundation.sql
│       ├── V1_1__update_seed_user_passwords.sql
│       ├── V2__phase_02_core_issue_management.sql
│       ├── V3__phase_03_ai_case_intelligence.sql
│       ├── V4__phase_04_smart_operations.sql
│       └── V5__phase_05_sla_automation.sql
└── frontend/
    └── lib/
        ├── core/
        │   ├── constants/    # AppConstants (API endpoints, Base URLs)
        │   ├── errors/       # AppException
        │   ├── network/      # ApiClient (GET, POST, PUT, PATCH, DELETE + JWT interceptor)
        │   ├── storage/      # SecureStorageService
        │   ├── theme/        # AppTheme (Curated enterprise palette & Material 3)
        │   └── widgets/      # CustomButton, CustomTextField, StatsCard
        └── features/
            ├── auth/         # LoginScreen, AuthRepository, AuthProvider, UserModel
            ├── dashboard/    # MainNavigationScreen, DashboardShell, StudentView, OperatorView, LeadView, ManagerView, ProfileTab
            ├── issues/       # CreateIssueScreen, IssueDetailScreen, AiCaseIntelligenceCard, Repositories, Providers
            ├── operations/   # SmartAssignmentCard, TasksChecklistWidget, InvestigationLogWidget, InternalNotesWidget, RequesterChatWidget, Providers, Repositories, Models
            └── sla/          # SlaCountdownCard, RiskSignalsCard, EscalationBannerWidget, ManualEscalateModal, NotificationsDrawer, NotificationBellAction, Providers, Repositories, Models
```

---

## 🔐 Seed User Credentials (Verified)

All accounts share the default password: **`Password@123`**

| Role | Email | Display Name | Permissions & Dashboard |
|---|---|---|---|
| **STUDENT** | `student@smartcampus.edu` | Aarav Sharma (Student) | Submit issues, view personal issue queue, chat with operators, confirm resolution |
| **OPERATOR** | `operator@smartcampus.edu` | Vikram Singh (Operator) | View assigned tasks, toggle sub-tasks, submit investigation reports, internal notes |
| **TEAM_LEAD** | `teamlead@smartcampus.edu` | Priya Patel (Team Lead) | Smart Dispatch recommendations, workload balancing, assignment overrides, staff notes |
| **CAMPUS_MANAGER** | `manager@smartcampus.edu` | Dr. Suresh Mehta (Manager) | Campus-wide intelligence, SLA compliance, department health, workload metrics |
| **ADMIN** | `admin@smartcampus.edu` | System Administrator | Full tenant management, audit logs, system-wide overrides |

---

## 🚀 Completed Phases Breakdown

### ✅ Phase 1: Foundation, Auth & User Management
- Database schema: Organizations, Users, Teams, Roles.
- Spring Security & stateless JWT issuance, BCrypt password hashing.
- REST Endpoints for Auth & Profile.
- Flutter Web login & role switcher shell.

### ✅ Phase 2: Core Issue Management & Lifecycle
- Database schema (`V2`): `categories`, `issues`, `issue_timeline`.
- Auto issue numbering (`ISS-YYYY-NNNN`), status state-machine.
- Flutter Issue reporting and details with immutable timeline.

### ✅ Phase 3: AI Case Intelligence & Human Decision Loop
- Database schema (`V3`): `ai_analyses`, `ai_recommendations`, `issue_relationships`, `ai_context_items`.
- Gemini 1.5 Flash + resilient heuristic fallback engine.
- Human decision loop for accepting/rejecting AI recommendations.

### ✅ Phase 4: Smart Operations & Workload Dispatch
- Database schema (`V4`): `assignments`, `messages`, `internal_notes`, `investigations`, `tasks`, `task_evidence`.
- Workload analysis recommendation algorithm calculating match score and active load penalties.
- Segmented 4-Tab Navigation inside `IssueDetailScreen`.

### ✅ Phase 5: SLA Automation, Risk Detection, Multi-Tier Escalations & Notifications Hub
- **Database Schema (`V5`)**:
  - `sla_policies`: Organization and category/priority-based SLA time limits (`response_minutes`, `resolution_minutes`).
  - `issue_sla`: Tracks `response_due_at`, `resolution_due_at`, `response_met_at`, `resolution_met_at`, `response_breached_at`, `resolution_breached_at`, `status`.
  - `risk_events`: Tracks detected anomalies (`risk_type`, `severity`, `explanation`, `detected_at`, `resolved_at`).
  - `escalations`: Tracks multi-tier escalations (`trigger_type`, `level`, `status`, `reason`, `triggered_by_user_id`, `triggered_at`).
  - `notifications`: In-app notification store (`recipient_id`, `issue_id`, `notification_type`, `title`, `body`, `channel`, `status`, `read_at`).
- **Backend Architecture**:
  - `SlaService`: Computes SLA targets, tracks milestone met times on status changes (`UNDERSTOOD`, `RESOLVED_PENDING_CONFIRMATION`, `CLOSED`).
  - `RiskAssessmentService`: Proactively evaluates SLA proximity, idle queue lag (>30m), blocked sub-tasks, stalled urgent cases.
  - `EscalationService`: Idempotent automated tier escalation and authorized manual escalation with timeline audit events.
  - `NotificationService`: Noise-controlled deduplicated notification dispatcher with unread badge counter and mark-as-read APIs.
  - `SlaAutomationScheduler`: Scheduled cron task running every 2 minutes for proactive SLA governance.
  - REST Endpoints: `/api/v1/issues/{id}/sla`, `/api/v1/issues/{id}/risks`, `/api/v1/issues/{id}/escalations`, `/api/v1/notifications`, `/api/v1/notifications/unread-count`, `/api/v1/notifications/{id}/read`, `/api/v1/notifications/read-all`.
  - Automated MockMvc Test Suite (`SlaControllerTest`, `NotificationControllerTest`): 30/30 test suites passing.
- **Frontend Architecture**:
  - `SlaCountdownCard`: Live ticking countdown timer for Response & Resolution targets with dynamic color coding and progress bar.
  - `RiskSignalsCard`: Visual explanation of operational bottlenecks and active risks.
  - `EscalationBannerWidget` & `ManualEscalateModal`: Multi-tier escalation status with staff escalation modal.
  - `NotificationsDrawer` & `NotificationBellAction`: AppBar notification bell with real-time unread badge and interactive drawer.
  - Automated unit test suite (`sla_models_test.dart`): 24/24 Flutter tests passing.

---

## 🔮 Upcoming Phases Roadmap

- **Phase 6: Communication & Resolution (Including Photo & Camera Evidence Suite)**:
  - Mobile Camera click & Gallery photo picker on issue creation & field repairs.
  - Requester feedback loops, resolution confirmation verification.
- **Phase 7: Management & Operational Insights**:
  - Heatmaps, root cause analytics, department performance metrics.
- **Phase 8: Trust, Audit & Production Readiness**:
  - Full audit logging, rate limiting, security hardening.
- **Phase 9: Final Validation & Demo**:
  - Full end-to-end integration demo and presentation mode.
