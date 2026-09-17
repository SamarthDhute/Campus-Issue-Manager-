# 🏫 Smart Campus Issue Manager — Progress & System Architecture

**Project Repository**: `https://github.com/SamarthDhute/Campus-Issue-Manager-`  
**Current Active Branch**: `feature/phase-02-core-issue-management`  
**Current Status**: **Phase 1 (Foundation) & Phase 2 (Core Issue Management) 100% Completed, Verified & Pushed**

---

## 📌 Executive Summary

Smart Campus Issue Manager is an enterprise-grade, role-based campus facility and maintenance ticketing system designed for universities and institutes. It connects students, faculty, facility operators, team leads, and campus managers in a transparent, real-time lifecycle tracking workflow.

### Tech Stack:
- **Backend**: Java 22, Spring Boot 3.3.5, Spring Security (JWT), Spring Data JPA, Flyway Migration, PostgreSQL (Supabase pooler), Maven.
- **Frontend**: Flutter Web (CanvasKit / HTML), Provider State Management, Material 3 Custom AppTheme, Secure Storage, Responsive Multi-Role Views.
- **Testing**: JUnit 5, Mockito, MockMvc, Flutter Unit Tests.

---

## 🏗️ System Architecture & Layering

```
smart-campus-issue-manager/
├── backend/
│   ├── src/main/java/com/smartcampus/issuemanager/
│   │   ├── config/          # SecurityConfig, CorsConfig, OpenApiConfig, Seeder
│   │   ├── controller/      # AuthController, UserController, IssueController, CategoryController
│   │   ├── dto/             # Requests & Responses (Auth, Profile, Issue, Category, Timeline)
│   │   ├── entity/          # User, Organization, Role, Issue, IssueCategory, IssueTimeline, Team
│   │   ├── exception/       # GlobalExceptionHandler, ResourceNotFoundException, BadRequestException
│   │   ├── repository/      # UserRepository, IssueRepository, CategoryRepository, TimelineRepository...
│   │   ├── security/        # JwtTokenProvider, JwtAuthenticationFilter, UserPrincipal, CustomUserDetailsService
│   │   └── service/         # AuthService, UserService, IssueService, CategoryService (+ Impls)
│   └── src/main/resources/db/migration/
│       ├── V1__phase_01_foundation.sql
│       ├── V1_1__update_seed_user_passwords.sql
│       ├── V2__phase_02_core_issue_management.sql
│       └── V2_1__seed_phase_02_data.sql
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
            └── issues/       # CreateIssueScreen, IssueDetailScreen, IssueRepository, CategoryRepository, Providers
```

---

## 🔐 Seed User Credentials (Verified)

All accounts share the default password: **`Password@123`**

| Role | Email | Display Name | Permissions & Dashboard |
|---|---|---|---|
| **STUDENT** | `student@smartcampus.edu` | Aarav Sharma (Student) | Submit issues, view personal issue queue, confirm resolution |
| **OPERATOR** | `operator@smartcampus.edu` | Vikram Singh (Operator) | View assigned tasks, change status to Investigating / In Progress / Resolved |
| **TEAM_LEAD** | `teamlead@smartcampus.edu` | Priya Patel (Team Lead) | Workload overview, assign cases to operators, triage |
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
  - Role-aware Dashboard Shell with Bottom Navigation (Workspace + Profile Tab).

### ✅ Phase 2: Core Issue Management & Lifecycle
- **Database Schema (`V2`, `V2_1`)**:
  - `categories`: Default categories (Electrical, Plumbing & Water, Internet & Wi-Fi, Classroom Equipment, Hostel Amenities, Cleanliness & Waste).
  - `issues`: Issue numbering sequence (`ISS-YYYY-NNNN`), Priority (`LOW`, `MEDIUM`, `HIGH`, `URGENT`), Status (`REPORTED`, `TRIAGED`, `INVESTIGATING`, `ACTION_SCHEDULED`, `ACTION_IN_PROGRESS`, `RESOLVED_PENDING_CONFIRMATION`, `CLOSED`, `REOPENED`, `CANCELLED`).
  - `issue_timeline`: Immutable audit log tracking actor, previous status, new status, timestamp, and comments.
- **Backend Architecture**:
  - `IssueController`, `CategoryController` with `@AuthenticationPrincipal UserPrincipal`.
  - Transactional `IssueService` with automated issue number generator and timeline event recording.
  - Unit tests in `IssueControllerTest` (100% pass across 11 test suites).
- **Frontend Architecture**:
  - `CreateIssueScreen`: Full issue reporting form with category dropdown, title, description, location, and priority picker.
  - `IssueDetailScreen`: Comprehensive case details, timeline history widget, dynamic action toolbar for Operators/Managers/Requesters.
  - Role-specific Dashboard Queues:
    - **Student View**: Report Issue Hero Banner, Active/Resolved Stats, Recent Submissions list with Status chips.
    - **Operator View**: Assigned to Me, In Progress, Resolved Today, Actionable Work queue.
    - **Team Lead View**: Unassigned cases, Team Workload, Case triage.
    - **Manager View**: Campus stats, SLA compliance metric, Department health.

---

## 🛠️ Key Bug Fixes & Gotchas Solved

1. **`@AuthenticationPrincipal` Principal Type Resolution**:
   - **Root Cause**: `IssueController` previously expected JPA `User` entity, but `JwtAuthenticationFilter` sets `UserPrincipal`.
   - **Solution**: Changed controller injection to `UserPrincipal` and passed `currentUser.getId()` to service layer.
2. **Category Fallback UUID Integrity**:
   - Updated `CategoryRepository` fallback IDs to valid UUIDs matching the database seed keys (`c0000000-0000-0000-0000-000000000001` through `6`).
3. **Frontend Compile & Hot Restart Resolution**:
   - Standardized colors across `issue_detail_screen.dart` to `AppTheme`.
   - Added missing `patch` and `delete` methods to `ApiClient.dart`.

---

## 📋 Git Commit History (Feature Branch: `feature/phase-02-core-issue-management`)

```
753b26a fix(frontend): harmonize AppTheme in issue details and add patch/delete to ApiClient
3c98d37 fix(issue-management): resolve UserPrincipal auth injection in IssueController and update category fallback UUIDs
31fa837 test(frontend): add unit tests for issue models and widgets
a5a9cca feat(dashboard): connect live issue queues to student, operator, lead and manager dashboards
f23eb5e feat(ui): implement issue detail screen with lifecycle actions and timeline
7ccee56 feat(frontend): add issue data models, repository, providers, and reporting flow
e200b45 fix(backend): update CategoryRepository findByActiveTrue and service mapping
b1d2e30 test(issue): add unit tests for issue controller endpoints
1b90058 feat(issue): implement issue and category services with status engine and REST controllers
...
```

---

## 🔮 Upcoming Phases Roadmap

- **Phase 3: Media Attachments & Multi-Image Uploads**:
  - Image upload support for issue reporting (Supabase Storage bucket integration).
  - Image thumbnail grid and full-screen viewer in `IssueDetailScreen`.
- **Phase 4: Real-time Notifications & SLA Tracking**:
  - WebSocket / SSE push notifications for case assignment and status changes.
  - SLA countdown timers with automated escalation alerts for urgent cases.
- **Phase 5: Analytics, Heatmaps & PDF Export**:
  - Interactive campus issue heatmap.
  - Executive reporting and monthly maintenance summaries.
