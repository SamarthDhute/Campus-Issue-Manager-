# Smart Campus Issue Manager --- Phase 1 SRS: Foundation

## 1. Purpose

This phase delivers **Foundation** as a connected part of the Smart
Campus Issue Manager. This document defines both product requirements
and development-oriented technical boundaries so the phase can be
implemented without guessing the intended architecture.

## 2. Objectives

-   Authentication and role recognition
-   Profile
-   Role-aware navigation
-   Organization/team/category foundation
-   Dashboard shell
-   Persistent data
-   Loading/empty/error states
-   Health endpoint

## 3. Scope

### In Scope

-   Authentication and role recognition
-   Profile
-   Role-aware navigation
-   Organization/team/category foundation
-   Dashboard shell
-   Persistent data
-   Loading/empty/error states
-   Health endpoint

### Out of Scope

Later-phase functionality must not be required to declare this phase
complete, but all earlier completed functionality must continue to work.

## 4. User Stories

-   As a requester, I want the feature to be simple and understandable.
-   As an operator, I want the feature to reduce manual work and
    preserve the issue story.
-   As a team lead/manager, I want role-appropriate visibility and
    intervention.
-   As an administrator, I want secure, traceable and configurable
    behavior.
-   As a developer, I want clear APIs, data structures, module
    boundaries and tests.

## 5. Functional Requirements

### FR-01 Authentication and role recognition`\n`{=tex}`\nThe `{=tex}system shall provide authentication and role recognition according to the product workflow, business rules and role permissions.

### FR-02 Profile`\n`{=tex}`\nThe `{=tex}system shall provide profile according to the product workflow, business rules and role permissions.

### FR-03 Role-aware navigation`\n`{=tex}`\nThe `{=tex}system shall provide role-aware navigation according to the product workflow, business rules and role permissions.

### FR-04 Organization/team/category foundation`\n`{=tex}`\nThe `{=tex}system shall provide organization/team/category foundation according to the product workflow, business rules and role permissions.

### FR-05 Dashboard shell`\n`{=tex}`\nThe `{=tex}system shall provide dashboard shell according to the product workflow, business rules and role permissions.

### FR-06 Persistent data`\n`{=tex}`\nThe `{=tex}system shall provide persistent data according to the product workflow, business rules and role permissions.

### FR-07 Loading/empty/error states`\n`{=tex}`\nThe `{=tex}system shall provide loading/empty/error states according to the product workflow, business rules and role permissions.

### FR-08 Health endpoint`\n`{=tex}`\nThe `{=tex}system shall provide health endpoint according to the product workflow, business rules and role permissions.

## 6. Technical Architecture

### 6.1 Selected Technology Stack

  Layer              Technology
  ------------------ ----------------------------------------
  Frontend           Flutter + Dart
  Backend            Java + Spring Boot
  API                REST / JSON
  Database           PostgreSQL on Supabase Cloud
  ORM                Spring Data JPA + Hibernate
  Migrations         Flyway
  Authentication     Spring Security + JWT / OAuth 2.0
  AI                 LLM API
  File Storage       Supabase Storage
  Notifications      Firebase Cloud Messaging (FCM) + Email
  API Docs           Springdoc OpenAPI / Swagger
  Backend Tests      JUnit + Mockito
  Frontend Tests     Flutter Test
  Containerization   Docker
  Version Control    Git + GitHub
  Configuration      Environment Variables

### 6.2 Runtime Architecture

``` text
Flutter App
    ↓
Spring Boot REST API
    ↓
Spring Data JPA / Hibernate
    ↓
Supabase Cloud PostgreSQL

Spring Boot
 ├── LLM API
 ├── Supabase Storage
 └── FCM / Email Service
```

Development uses a local Spring Boot server connected to Supabase Cloud.
A local PostgreSQL/Supabase installation is not required.

### 6.3 Backend Layering

``` text
Controller → Service → Repository → JPA/Hibernate → PostgreSQL
```

Supporting modules:

``` text
config/
security/
dto/
entity/
repository/
service/
mapper/
exception/
integration/
scheduler/
audit/
notification/
```

### 6.4 Frontend Layering

``` text
Screen/Widget
    ↓
State / Controller / ViewModel
    ↓
Repository / API Client
    ↓
Spring Boot REST API
```

### 6.5 Backend Folder Structure

``` text
backend/
└── src/
    ├── main/java/com/smartcampus/issuemanager/
    │   ├── config/
    │   ├── controller/
    │   ├── dto/
    │   ├── entity/
    │   ├── repository/
    │   ├── service/
    │   │   └── impl/
    │   ├── mapper/
    │   ├── exception/
    │   ├── security/
    │   ├── integration/
    │   │   ├── ai/
    │   │   ├── storage/
    │   │   └── notification/
    │   ├── scheduler/
    │   └── audit/
    └── resources/
        ├── db/migration/
        └── application.yml
```

### 6.6 Frontend Folder Structure

``` text
frontend/
└── lib/
    ├── core/
    │   ├── constants/
    │   ├── errors/
    │   ├── network/
    │   ├── routing/
    │   ├── storage/
    │   ├── theme/
    │   └── widgets/
    ├── features/
    │   ├── auth/
    │   ├── dashboard/
    │   ├── issues/
    │   ├── notifications/
    │   └── profile/
    └── main.dart
```

### 6.7 Database Conventions

-   UUID primary keys.
-   Foreign keys for relationships.
-   `created_at` and `updated_at` on mutable records.
-   Controlled status/category values.
-   Important history is retained rather than erased by ordinary
    updates.
-   All schema changes use Flyway.
-   Database credentials and secrets come from environment variables.

## 7. Phase Database Changes

### Tables / Records

-   `users(id UUID PK, email, display_name, role, organization_id FK, created_at, updated_at)`
-   `organizations(id UUID PK, name, created_at, updated_at)`
-   `teams(id UUID PK, organization_id FK, name, description, created_at, updated_at)`
-   `user_teams(user_id FK, team_id FK, PRIMARY KEY(user_id, team_id))`
-   `categories(id UUID PK, organization_id FK, name, description, active, created_at, updated_at)`

### Migration

Migration files live at:

``` text
backend/src/main/resources/db/migration/
```

Use:

``` text
V1__phase_01_foundation.sql
```

Migrations must be forward-only, reproducible from a clean database, and
compatible with previous phases.

## 8. API Contract

  Method   Endpoint               Purpose
  -------- ---------------------- -------------------------------------
  `POST`   `/api/v1/auth/login`   Authenticate and issue access token
  `GET`    `/api/v1/users/me`     Get current profile
  `PUT`    `/api/v1/users/me`     Update profile
  `GET`    `/api/v1/health`       Service health

### API Rules

-   Version APIs under `/api/v1`.
-   Use DTOs instead of exposing JPA entities.
-   Validate input at the API boundary.
-   Enforce business rules in services.
-   Enforce authorization server-side.
-   Use appropriate HTTP status codes.
-   Return a consistent error structure.
-   Important state changes create timeline/audit events.

## 10. Detailed Implementation

-   Implement Spring Security authentication and JWT/OAuth integration.
-   Create role-based route/method authorization.
-   Persist users, organizations, teams and categories in Supabase
    Cloud.
-   Create the initial Flyway migration.
-   Build Flutter auth, session, route guards, role navigation and
    common UI states.
-   Keep URLs and secrets in environment configuration.

## 11. Validation Rules

-   Required fields are rejected when missing.
-   Controlled values are validated.
-   UUID/path IDs are existence-checked.
-   Text length limits are enforced.
-   Files are validated for supported type and size.
-   Authorization is checked before protected reads/writes.
-   State transitions are validated server-side.
-   Validation errors are actionable.

## 12. Error Handling

Handle: - Invalid input - Missing resources - Unauthorized/forbidden
access - Database failure - External-service timeout/failure - Duplicate
requests - Invalid state transitions - Partial operation failure

Use centralized Spring exception handling and a common Flutter API-error
mapping layer.

## 13. Frontend Implementation

Recommended feature structure:

``` text
features/<feature>/
├── data/
│   ├── models/
│   ├── api/
│   └── repositories/
├── domain/
│   └── entities/
└── presentation/
    ├── screens/
    ├── widgets/
    └── state/
```

UI requirements: - No inline styles. - Use centralized design
tokens/theme. - Reuse shared components. - No hardcoded business
records. - Provide loading, empty, error and success states. - Keep
role-specific screens behind authorization-aware routing.

## 14. Backend Implementation

Recommended feature structure:

``` text
<feature>/
├── controller/
├── dto/
├── entity/
├── repository/
├── service/
│   └── impl/
├── mapper/
└── exception/
```

External services remain isolated:

``` text
integration/
├── ai/
├── storage/
└── notification/
```

Controllers should be thin. Business rules belong in services. Database
access belongs in repositories.

## 15. Security & Authorization

-   Authentication is required for protected operations.
-   Role and resource authorization are enforced by the backend.
-   Ownership/team/organization scope is checked before access.
-   Requester-visible data and internal operational data remain
    separated.
-   Administrative access is not automatically inherited by
    operators/managers.
-   Secrets are never hardcoded or committed.

## 16. Testing Strategy

### Unit Tests

-   Login success/failure
-   Role authorization
-   Profile persistence
-   Flyway migration
-   Health endpoint
-   Flutter loading/empty/error states

### Integration Tests

-   Controller → service → repository.
-   Flyway migration and persistence.
-   Authorization boundaries.
-   External integration failure behavior where applicable.

### Frontend Tests

-   Rendering.
-   State transitions.
-   Form validation.
-   API success/loading/error states.
-   Role-aware navigation.

### Regression

All previous-phase acceptance criteria must remain passing.

## 17. Acceptance Criteria

-   Every in-scope feature works as a connected workflow.
-   Data persists in Supabase Cloud PostgreSQL.
-   APIs are documented and tested.
-   Flutter uses real APIs rather than hardcoded business data.
-   Backend permissions are enforced.
-   Loading/empty/error/success states work.
-   Important actions are traceable where applicable.
-   Phase tests pass.
-   Previous phases remain functional.

## 18. Deliverables

-   Flutter screens/state/data layers.
-   Spring Boot controllers, DTOs, services, repositories and
    integrations.
-   Flyway migration(s).
-   Supabase database changes.
-   API documentation.
-   Automated tests.
-   Environment example/configuration updates where required.
-   Connected end-to-end workflow.

## 19. Definition of Done

Phase 1 is complete only when the phase works end-to-end through Flutter
→ Spring Boot → Supabase Cloud, respects role permissions, persists
data, handles failures, has automated tests, and integrates with
previous phases.
