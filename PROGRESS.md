# 🏫 Smart Campus Issue Manager — Progress & System Architecture

**Project Repository**: `https://github.com/SamarthDhute/Campus-Issue-Manager-`  
- **Current Active Branch**: `feature/phase-06-media-resolution-suite`  
- **Current Status**: **Phases 1, 2, 3, 4, 5 & 6 (Media Evidence & Resolution Suite) 100% Completed, Verified & Tested**

---

## 📌 Executive Summary

Smart Campus Issue Manager is an enterprise-grade, role-based campus facility and maintenance ticketing system designed for universities and institutes. It connects students, faculty, facility operators, team leads, and campus managers in a transparent, real-time lifecycle tracking workflow.

### Tech Stack:
- **Backend**: Java 22, Spring Boot 3.3.5, Spring Security (JWT), Spring Data JPA, Flyway Migration, PostgreSQL (Supabase pooler), Maven.
- **Frontend**: Flutter Web (CanvasKit / HTML), Provider State Management, Material 3 Custom AppTheme, Secure Storage, Responsive Multi-Role Views.
- **AI Intelligence**: Google Gemini 1.5 Flash REST API Integration with Heuristic Fallback Engine for 100% operational uptime.
- **Testing**: JUnit 5, Mockito, MockMvc (35 Passing Test Suites), Flutter Unit & Widget Tests (29 Passing Suites).

---

## 🏗️ System Architecture & Layering

```
smart-campus-issue-manager/
├── backend/
│   ├── src/main/java/com/smartcampus/issuemanager/
│   │   ├── config/          # SecurityConfig, CorsConfig, OpenApiConfig, Seeder
│   │   ├── controller/      # AuthController, UserController, IssueController, CategoryController, AiController, OperationsController, SlaController, NotificationController, AttachmentController, ResolutionController
│   │   ├── dto/             # Auth, Profile, Issue, Category, Timeline, AiAnalysis, AiRecommendation, Assignment, Message, InternalNote, Investigation, Task, IssueSla, RiskEvent, Escalation, Notification, AttachmentResponse, EvidenceResponse, FeedbackResponse, SubmitFeedbackRequest, ReopenIssueRequest, UploadEvidenceRequest
│   │   ├── entity/          # User, Organization, Role, Issue, Category, Timeline, AiAnalysis, AiRecommendation, Assignment, IssueMessage, InternalNote, Investigation, IssueTask, SlaPolicy, IssueSla, RiskEvent, Escalation, Notification, IssueAttachment, ResolutionEvidence, IssueFeedback, EvidenceType, ResolutionQuality
│   │   ├── exception/       # GlobalExceptionHandler, ResourceNotFoundException, BadRequestException
│   │   ├── integration/ai/  # GeminiClient (Gemini Flash API + Heuristic engine)
│   │   ├── repository/      # UserRepository, IssueRepository, CategoryRepository, AssignmentRepository, IssueMessageRepository, InternalNoteRepository, InvestigationRepository, IssueTaskRepository, SlaPolicyRepository, IssueSlaRepository, RiskEventRepository, EscalationRepository, NotificationRepository, IssueAttachmentRepository, ResolutionEvidenceRepository, IssueFeedbackRepository
│   │   ├── scheduler/       # SlaAutomationScheduler (Periodic cron evaluating burn rate, risk detection & auto-escalation)
│   │   ├── security/        # JwtTokenProvider, JwtAuthenticationFilter, UserPrincipal, CustomUserDetailsService
│   │   └── service/         # AuthService, UserService, IssueService, CategoryService, AiCaseIntelligenceService, SmartOperationsService, SlaService, RiskAssessmentService, EscalationService, NotificationService, AttachmentService, ResolutionEvidenceService, FeedbackService (+ Impls)
│   └── src/main/resources/db/migration/
│       ├── V1__phase_01_foundation.sql
│       ├── V1_1__update_seed_user_passwords.sql
│       ├── V2__phase_02_core_issue_management.sql
│       ├── V3__phase_03_ai_case_intelligence.sql
│       ├── V4__phase_04_smart_operations.sql
│       ├── V5__phase_05_sla_automation.sql
│       └── V6__phase_06_media_and_resolution.sql
└── frontend/
    └── lib/
        ├── core/
        │   ├── constants/    # AppConstants (API endpoints, Base URLs)
        │   ├── errors/       # AppException
        │   ├── network/      # ApiClient (GET, POST, PUT, PATCH, DELETE, uploadMultipart + JWT interceptor)
        │   ├── storage/      # SecureStorageService
        │   ├── theme/        # AppTheme (Curated enterprise palette & Material 3)
        │   └── widgets/      # CustomButton, CustomTextField, StatsCard
        └── features/
            ├── auth/         # LoginScreen, AuthRepository, AuthProvider, UserModel
            ├── dashboard/    # MainNavigationScreen, DashboardShell, StudentView, OperatorView, LeadView, ManagerView, ProfileTab
            ├── issues/       # CreateIssueScreen, IssueDetailScreen, AiCaseIntelligenceCard, Repositories, Providers
            ├── operations/   # SmartAssignmentCard, TasksChecklistWidget, InvestigationLogWidget, InternalNotesWidget, RequesterChatWidget, Providers, Repositories, Models
            ├── sla/          # SlaCountdownCard, RiskSignalsCard, EscalationBannerWidget, ManualEscalateModal, NotificationsDrawer, NotificationBellAction, Providers, Repositories, Models
            └── resolution/   # MediaAttachmentPicker, ResolutionEvidenceWidget, ResolutionVerificationCard, Providers, Repositories, Models
```

---

## 🔐 Seed User Credentials (Verified)

All accounts share the default password: **`Password@123`**

| Role | Email | Display Name | Permissions & Dashboard |
|---|---|---|---|
| **STUDENT** | `student@smartcampus.edu` | Aarav Sharma (Student) | Submit issues with photos, view personal issue queue, chat with operators, rate resolution & confirm/reopen |
| **OPERATOR** | `operator@smartcampus.edu` | Vikram Singh (Operator) | View assigned tasks, toggle sub-tasks, upload before/after evidence photos, submit investigation reports |
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
- Database Schema (`V5`): `sla_policies`, `issue_sla`, `risk_events`, `escalations`, `notifications`.
- Live countdown timers, proactive bottleneck detection, automated 2-minute SLA evaluation scheduler.
- Notifications drawer in AppBar with real-time unread counter.

### ✅ Phase 6: Communication, Media Evidence & Resolution Suite
- **Database Schema (`V6`)**:
  - `issue_attachments`: Multi-attachment store linked to tickets or chat messages with file URL, MIME type, thumbnail, and uploader.
  - `resolution_evidence`: Before & After repair photos, inspection reports, invoice receipts submitted by field engineers.
  - `issue_feedbacks`: Requester 1-5 star ratings, satisfaction level chips, feedback text, and dispute reopening reasons.
- **Backend Architecture**:
  - `AttachmentService` & `AttachmentController`: Multipart file upload with deduplicated filenames, validation, and `/api/v1/files/{filename}` static streaming.
  - `ResolutionEvidenceService`: Manages technical before/after repair evidence.
  - `FeedbackService` & `ResolutionController`: Handles requester sign-off (`/api/v1/issues/{id}/feedback`) to move ticket to `CLOSED` and SLA milestone completion, or dispute reopening (`/api/v1/issues/{id}/reopen`) back to `REOPENED` with audit events.
  - Automated MockMvc Test Suite (`AttachmentControllerTest`, `ResolutionControllerTest`): **35/35 backend tests passing**.
- **Frontend Architecture**:
  - `MediaAttachmentPicker`: Camera live capture (`ImageSource.camera`) and file/gallery picker (`ImageSource.gallery`) with animated thumbnail chips and removal.
  - `CreateIssueScreen`: Integrated photo picker allowing up to 5 photos during ticket submission.
  - `ResolutionEvidenceWidget`: Before vs After image comparison card with zoom full-screen preview.
  - `ResolutionVerificationCard`: Interactive 5-star rating selector, resolution quality choices, and "Confirm & Close" / "Dispute & Reopen" actions.
  - Automated Flutter Test Suite (`resolution_models_test.dart`, `media_picker_widget_test.dart`): **29/29 Flutter tests passing**.

---

## 🔮 Upcoming Phases Roadmap

- **Phase 7: Management & Operational Insights**:
  - Heatmaps, root cause analytics, department performance metrics.
- **Phase 8: Trust, Audit & Production Readiness**:
  - Full audit logging, rate limiting, security hardening.
- **Phase 9: Final Validation & Demo**:
  - Full end-to-end integration demo and presentation mode.
