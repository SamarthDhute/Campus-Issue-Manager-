# Smart Campus Issue Manager --- Phase 6 SRS: Communication & Resolution

## 1. Purpose

This phase delivers **Communication & Resolution** as a connected part
of the Smart Campus Issue Manager. This document defines both product
requirements and development-oriented technical boundaries so the phase
can be implemented without guessing the intended architecture.

## 2. Objectives

-   AI communication drafts
-   Human review/edit
-   Send communication
-   Communication history
-   Resolution proposal
-   Resolution evidence
-   Requester confirmation/rejection
-   Reopening
-   Closure

## 3. Scope

### In Scope

-   AI communication drafts
-   Human review/edit
-   Send communication
-   Communication history
-   Resolution proposal
-   Resolution evidence
-   Requester confirmation/rejection
-   Reopening
-   Closure

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

### FR-01 AI communication drafts`\n`{=tex}`\nThe `{=tex}system shall provide ai communication drafts according to the product workflow, business rules and role permissions.

### FR-02 Human review/edit`\n`{=tex}`\nThe `{=tex}system shall provide human review/edit according to the product workflow, business rules and role permissions.

### FR-03 Send communication`\n`{=tex}`\nThe `{=tex}system shall provide send communication according to the product workflow, business rules and role permissions.

### FR-04 Communication history`\n`{=tex}`\nThe `{=tex}system shall provide communication history according to the product workflow, business rules and role permissions.

### FR-05 Resolution proposal`\n`{=tex}`\nThe `{=tex}system shall provide resolution proposal according to the product workflow, business rules and role permissions.

### FR-06 Resolution evidence`\n`{=tex}`\nThe `{=tex}system shall provide resolution evidence according to the product workflow, business rules and role permissions.

### FR-07 Requester confirmation/rejection`\n`{=tex}`\nThe `{=tex}system shall provide requester confirmation/rejection according to the product workflow, business rules and role permissions.

### FR-08 Reopening`\n`{=tex}`\nThe `{=tex}system shall provide reopening according to the product workflow, business rules and role permissions.

### FR-09 Closure`\n`{=tex}`\nThe `{=tex}system shall provide closure according to the product workflow, business rules and role permissions.

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

-   `resolution_proposals(id UUID PK, issue_id FK, proposed_by FK, summary, details, status, created_at, updated_at)`
-   `resolution_evidence(id UUID PK, resolution_id FK, storage_path, file_name, created_at)`
-   `resolution_confirmations(id UUID PK, resolution_id FK, requester_id FK, decision, feedback, decided_at)`

### Migration

Migration files live at:

``` text
backend/src/main/resources/db/migration/
```

Use:

``` text
V6__phase_06_communication_resolution.sql
```

Migrations must be forward-only, reproducible from a clean database, and
compatible with previous phases.

## 8. API Contract

  -----------------------------------------------------------------------------------------------------------
  Method                  Endpoint                                                    Purpose
  ----------------------- ----------------------------------------------------------- -----------------------
  `POST`                  `/api/v1/issues/{id}/communication-draft`                   Generate AI draft

  `POST`                  `/api/v1/issues/{id}/messages`                              Send approved message

  `POST`                  `/api/v1/issues/{id}/resolutions`                           Submit resolution

  `POST`                  `/api/v1/issues/{id}/resolutions/{resolutionId}/evidence`   Upload evidence

  `POST`                  `/api/v1/issues/{id}/resolutions/{resolutionId}/confirm`    Confirm resolution

  `POST`                  `/api/v1/issues/{id}/resolutions/{resolutionId}/reject`     Reject resolution

  `POST`                  `/api/v1/issues/{id}/reopen`                                Reopen issue
  -----------------------------------------------------------------------------------------------------------

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

-   Generate drafts through the existing AI integration abstraction.
-   Persist drafts separately and require operator review before
    sending.
-   Store sent messages with sender and visibility metadata.
-   Attach resolution evidence through Supabase Storage.
-   Allow requester confirmation/rejection with feedback.
-   Only an applicable confirmed resolution may transition an issue to
    CLOSED.
-   On rejection, return to an active state and preserve the failed
    attempt.

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

-   Draft failure
-   Human edit requirement
-   Message history
-   Resolution evidence
-   Confirmation/rejection
-   Reopen/close transition

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

Phase 6 is complete only when the phase works end-to-end through Flutter
→ Spring Boot → Supabase Cloud, respects role permissions, persists
data, handles failures, has automated tests, and integrates with
previous phases.
