# 🏫 Smart Campus Issue Manager — Progress & System Architecture

**Project Repository**: `https://github.com/SamarthDhute/Campus-Issue-Manager-`  
**Current Active Branch**: `feature/phase-03-ai-case-intelligence`  
**Current Status**: **Phase 1, Phase 2 & Phase 3 (AI Case Intelligence) 100% Completed, Verified & Tested**

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
│   │   ├── controller/      # AuthController, UserController, IssueController, CategoryController, AiController
│   │   ├── dto/             # Auth, Profile, Issue, Category, Timeline, AiAnalysis, AiRecommendation, RelatedIssue
│   │   ├── entity/          # User, Organization, Role, Issue, Category, Timeline, AiAnalysis, AiRecommendation, IssueRelationship
│   │   ├── exception/       # GlobalExceptionHandler, ResourceNotFoundException, BadRequestException
│   │   ├── integration/ai/  # GeminiClient (Gemini Flash API + Heuristic engine)
│   │   ├── repository/      # UserRepository, IssueRepository, CategoryRepository, TimelineRepository, AiAnalysisRepository...
│   │   ├── security/        # JwtTokenProvider, JwtAuthenticationFilter, UserPrincipal, CustomUserDetailsService
│   │   └── service/         # AuthService, UserService, IssueService, CategoryService, AiCaseIntelligenceService (+ Impls)
│   └── src/main/resources/db/migration/
│       ├── V1__phase_01_foundation.sql
│       ├── V1_1__update_seed_user_passwords.sql
│       ├── V2__phase_02_core_issue_management.sql
│       └── V3__phase_03_ai_case_intelligence.sql
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
            └── issues/       # CreateIssueScreen, IssueDetailScreen, AiCaseIntelligenceCard, Repositories, Providers
```

---

## 🔐 Seed User Credentials (Verified)

All accounts share the default password: **`Password@123`**

| Role | Email | Display Name | Permissions & Dashboard |
|---|---|---|---|
| **STUDENT** | `student@smartcampus.edu` | Aarav Sharma (Student) | Submit issues, view personal issue queue, confirm resolution |
| **OPERATOR** | `operator@smartcampus.edu` | Vikram Singh (Operator) | View assigned tasks, accept AI recommendations, change status |
| **TEAM_LEAD** | `teamlead@smartcampus.edu` | Priya Patel (Team Lead) | Workload overview, triage, accept AI priority, assign operators |
| **CAMPUS_MANAGER** | `manager@smartcampus.edu` | Dr. Suresh Mehta (Manager) | Campus-wide intelligence, SLA compliance, department health |
| **ADMIN** | `admin@smartcampus.edu` | System Administrator | Full tenant management, audit logs, system-wide overrides |

---

## 🚀 Completed Phases Breakdown

### ✅ Phase 1: Foundation, Auth & User Management
- **Database Schema**: Organizations, Users, Teams, Roles (`ADMIN`, `CAMPUS_MANAGER`, `TEAM_LEAD`, `FACULTY_STAFF`, `STUDENT`).
- **Spring Security & JWT**: Stateless token issuance (24h lifespan), custom `UserPrincipal`, BCrypt password hashing.
- **REST Endpoints**:
  - `POST /api/v1/auth/login`
  - `GET /api/v1/users/me`
  - `PUT /api/v1/users/me`
- **Frontend Core & Auth**:
  - Modern Login UI with Quick-Demo Role Switcher pills.
  - JWT token auto-storage in `SharedPreferences` / `FlutterSecureStorage`.
  - Global `AuthProvider` with automatic session restore.
  - Role-aware Dashboard Shell with Bottom Navigation.

### ✅ Phase 2: Core Issue Management & Lifecycle
- **Database Schema (`V2`)**:
  - `categories`: Default categories (Electrical, Plumbing & Water, Internet & Wi-Fi, Classroom Equipment, Hostel Amenities, Cleanliness & Waste).
  - `issues`: Issue numbering sequence (`ISS-YYYY-NNNN`), Priority (`LOW`, `MEDIUM`, `HIGH`, `URGENT`), Status transitions.
  - `issue_timeline`: Immutable audit log tracking actor, previous status, new status, timestamp, and comments.
- **Backend Architecture**:
  - `IssueController`, `CategoryController` with `@AuthenticationPrincipal UserPrincipal`.
  - Transactional `IssueService` with automated issue number generator and timeline event recording.
  - Unit tests in `IssueControllerTest` (100% pass across 11 test suites).
- **Frontend Architecture**:
  - `CreateIssueScreen`: Full issue reporting form with category dropdown, title, description, location, priority.
  - `IssueDetailScreen`: Comprehensive case details, timeline history widget, dynamic action toolbar.
  - Role-specific Dashboard Queues (Student, Operator, Lead, Manager).

### ✅ Phase 3: AI Case Intelligence & Human Decision Loop
- **Database Schema (`V3`)**:
  - `ai_analyses`: Issue analysis status, model name (`gemini-1.5-flash`), executive summary, missing information detector, confidence rating.
  - `ai_recommendations`: Priority recommendations, next-action guidance, confidence rating, explanation, decision status (`PENDING`, `ACCEPTED`, `REJECTED`, `OVERRIDDEN`), decider audit trail.
  - `issue_relationships`: Correlated & duplicate candidate identification with match confidence rating.
  - `ai_context_items`: Context memory snapshots fed into LLM analysis.
- **Backend Architecture**:
  - `GeminiClient`: Direct Google Gemini 1.5 Flash integration with resilient heuristic rule-engine fallback.
  - `AiCaseIntelligenceService`: Automated analysis generator, recommendation persister, duplicate correlation detector, and human decision recorder.
  - `AiController` endpoints:
    - `POST /api/v1/issues/{id}/ai/analyze`
    - `GET /api/v1/issues/{id}/ai`
    - `POST /api/v1/issues/{id}/ai/recommendations/{recommendationId}/decision`
    - `GET /api/v1/issues/{id}/related`
  - Automated MockMvc test suite in `AiControllerTest` (100% pass).
- **Frontend Architecture**:
  - `AiCaseIntelligenceCard`: Embedded into `IssueDetailScreen` with gradient icon header, real-time confidence pill, executive summary card, missing information caution alert, and one-click "Accept Priority" / "Dismiss" buttons.
  - Duplicate / Correlated Issue Warning Banner in case details.
  - `AiProvider` and `AiRepository` fully integrated with Flutter state tree.
  - Automated unit tests in `ai_models_test.dart` (100% pass).

---

## 🛠️ Key Bug Fixes & Gotchas Solved

1. **`@AuthenticationPrincipal` Principal Type Resolution**:
   - Resolved controller injection to `UserPrincipal` and passed `currentUser.getId()` to service layer.
2. **Category Fallback UUID Integrity**:
   - Updated `CategoryRepository` fallback IDs to valid UUIDs matching the database seed keys.
3. **AI Service Resilience**:
   - If `GEMINI_API_KEY` is not provided or network times out, the backend seamlessly falls back to a deterministic, heuristic rule-based AI engine to ensure 100% operational uptime.

---

## 🔮 Upcoming Phases Roadmap

- **Phase 4: Smart Operations & Workload Dispatch**:
  - Intelligent technician routing, workload balancing, operator shift tracking.
- **Phase 5: SLA Automation & Escalation**:
  - Real-time countdown timers, breach threshold alerts, auto-escalation engine.
- **Phase 6: Communication & Resolution**:
  - Requester feedback loops, in-app chat, resolution confirmation verification.
- **Phase 7: Management & Operational Insights**:
  - Heatmaps, root cause analytics, department performance metrics.
- **Phase 8: Trust, Audit & Production Readiness**:
  - Full audit logging, rate limiting, security hardening.
- **Phase 9: Final Validation & Demo**:
  - Full end-to-end integration demo and presentation mode.
