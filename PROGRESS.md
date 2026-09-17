# 🏫 Smart Campus Issue Manager — Progress & System Architecture

**Project Repository**: `https://github.com/SamarthDhute/Campus-Issue-Manager-- **Current Active Branch**: `feature/phase-04-smart-operations`  
- **Current Status**: **Phase 1, Phase 2, Phase 3 & Phase 4 (Smart Operations) 100% Completed, Verified & Tested**

---

## 📌 Executive Summary

Smart Campus Issue Manager is an enterprise-grade, role-based campus facility and maintenance ticketing system designed for universities and institutes. It connects students, faculty, facility operators, team leads, and campus managers in a transparent, real-time lifecycle tracking workflow.

### Tech Stack:
- **Backend**: Java 22, Spring Boot 3.3.5, Spring Security (JWT), Spring Data JPA, Flyway Migration, PostgreSQL (Supabase pooler), Maven.
- **Frontend**: Flutter Web (CanvasKit / HTML), Provider State Management, Material 3 Custom AppTheme, Secure Storage, Responsive Multi-Role Views.
- **AI Intelligence**: Google Gemini 1.5 Flash REST API Integration with Heuristic Fallback Engine for 100% operational uptime.
- **Testing**: JUnit 5, Mockito, MockMvc, Flutter Unit Tests.

---

## 🏗️ System Architecture & Layering

```
smart-campus-issue-manager/
├── backend/
│   ├── src/main/java/com/smartcampus/issuemanager/
│   │   ├── config/          # SecurityConfig, CorsConfig, OpenApiConfig, Seeder
│   │   ├── controller/      # AuthController, UserController, IssueController, CategoryController, AiController, OperationsController
│   │   ├── dto/             # Auth, Profile, Issue, Category, Timeline, AiAnalysis, AiRecommendation, Assignment, Message, InternalNote, Investigation, Task
│   │   ├── entity/          # User, Organization, Role, Issue, Category, Timeline, AiAnalysis, AiRecommendation, Assignment, IssueMessage, InternalNote, Investigation, IssueTask
│   │   ├── exception/       # GlobalExceptionHandler, ResourceNotFoundException, BadRequestException
│   │   ├── integration/ai/  # GeminiClient (Gemini Flash API + Heuristic engine)
│   │   ├── repository/      # UserRepository, IssueRepository, CategoryRepository, AssignmentRepository, IssueMessageRepository, InternalNoteRepository, InvestigationRepository, IssueTaskRepository
│   │   ├── security/        # JwtTokenProvider, JwtAuthenticationFilter, UserPrincipal, CustomUserDetailsService
│   │   └── service/         # AuthService, UserService, IssueService, CategoryService, AiCaseIntelligenceService, SmartOperationsService (+ Impls)
│   └── src/main/resources/db/migration/
│       ├── V1__phase_01_foundation.sql
│       ├── V1_1__update_seed_user_passwords.sql
│       ├── V2__phase_02_core_issue_management.sql
│       ├── V3__phase_03_ai_case_intelligence.sql
│       └── V4__phase_04_smart_operations.sql
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
            ├── dashboard/    # MainNavigationScreen, StudentView, OperatorView, LeadView, ManagerView, ProfileTab
            ├── issues/       # CreateIssueScreen, IssueDetailScreen, AiCaseIntelligenceCard, Repositories, Providers
            └── operations/   # SmartAssignmentCard, TasksChecklistWidget, InvestigationLogWidget, InternalNotesWidget, RequesterChatWidget, Providers, Repositories, Models
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
- **Database Schema (`V4`)**:
  - `assignments`: Ownership lifecycle, recommendation source, reason, active duration.
  - `messages`: Public requester-operator communication thread.
  - `internal_notes`: Staff-only restricted notes thread.
  - `investigations`: Field observations, actions taken, root cause findings, follow-up.
  - `tasks` & `task_evidence`: Sub-tasks checklist with status (`PENDING`, `IN_PROGRESS`, `COMPLETED`), due dates, assignee ownership.
- **Backend Architecture**:
  - `SmartOperationsService` & `OperationsController` with 12 REST endpoints.
  - Workload analysis recommendation algorithm calculating match score and active load penalties.
  - Automated MockMvc test suite in `OperationsControllerTest` (100% pass across 22 test suites).
- **Frontend Architecture**:
  - `SmartAssignmentCard`: Workload score, domain match chip, alternate candidate picker, one-click dispatch.
  - `TasksChecklistWidget`: Dynamic sub-task creation, checkbox status toggle, linear progress bar.
  - `InvestigationLogWidget`: Technical field report submission and structured findings card.
  - `InternalNotesWidget`: Role-restricted staff-only discussions.
  - `RequesterChatWidget`: Chat bubble interface for student-operator collaboration.
  - Segmented 4-Tab Navigation inside `IssueDetailScreen`.
  - Automated unit tests in `operations_models_test.dart` (100% pass).

---

## 🔮 Upcoming Phases Roadmap

- **Phase 5: SLA Automation & Escalation**:
  - Real-time countdown timers, breach threshold alerts, auto-escalation engine.
- **Phase 6: Communication & Resolution**:
  - Requester feedback loops, resolution confirmation verification.
- **Phase 7: Management & Operational Insights**:
  - Heatmaps, root cause analytics, department performance metrics.
- **Phase 8: Trust, Audit & Production Readiness**:
  - Full audit logging, rate limiting, security hardening.
- **Phase 9: Final Validation & Demo**:
  - Full end-to-end integration demo and presentation mode.oot cause analytics, department performance metrics.
- **Phase 8: Trust, Audit & Production Readiness**:
  - Full audit logging, rate limiting, security hardening.
- **Phase 9: Final Validation & Demo**:
  - Full end-to-end integration demo and presentation mode.
