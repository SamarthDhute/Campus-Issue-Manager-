# Smart Campus Issue Manager --- Phase 3 SRS: AI Case Intelligence

## 1. Purpose

This phase delivers **AI Case Intelligence** as a connected part of the
Smart Campus Issue Manager. This document defines both product
requirements and development-oriented technical boundaries so the phase
can be implemented without guessing the intended architecture.

## 2. Objectives

-   Automatic AI case analysis
-   Automatic summarization
-   Category/priority recommendation
-   Missing information detection
-   Related/duplicate detection
-   Next-action recommendation
-   Uncertainty display
-   Human accept/edit/reject/override
-   AI failure handling
-   AI case memory

## 3. Scope

### In Scope

-   Automatic AI case analysis
-   Automatic summarization
-   Category/priority recommendation
-   Missing information detection
-   Related/duplicate detection
-   Next-action recommendation
-   Uncertainty display
-   Human accept/edit/reject/override
-   AI failure handling
-   AI case memory

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

### FR-01 Automatic AI case analysis`\n`{=tex}`\nThe `{=tex}system shall provide automatic ai case analysis according to the product workflow, business rules and role permissions.

### FR-02 Automatic summarization`\n`{=tex}`\nThe `{=tex}system shall provide automatic summarization according to the product workflow, business rules and role permissions.

### FR-03 Category/priority recommendation`\n`{=tex}`\nThe `{=tex}system shall provide category/priority recommendation according to the product workflow, business rules and role permissions.

### FR-04 Missing information detection`\n`{=tex}`\nThe `{=tex}system shall provide missing information detection according to the product workflow, business rules and role permissions.

### FR-05 Related/duplicate detection`\n`{=tex}`\nThe `{=tex}system shall provide related/duplicate detection according to the product workflow, business rules and role permissions.

### FR-06 Next-action recommendation`\n`{=tex}`\nThe `{=tex}system shall provide next-action recommendation according to the product workflow, business rules and role permissions.

### FR-07 Uncertainty display`\n`{=tex}`\nThe `{=tex}system shall provide uncertainty display according to the product workflow, business rules and role permissions.

### FR-08 Human accept/edit/reject/override`\n`{=tex}`\nThe `{=tex}system shall provide human accept/edit/reject/override according to the product workflow, business rules and role permissions.

### FR-09 AI failure handling`\n`{=tex}`\nThe `{=tex}system shall provide ai failure handling according to the product workflow, business rules and role permissions.

### FR-10 AI case memory`\n`{=tex}`\nThe `{=tex}system shall provide ai case memory according to the product workflow, business rules and role permissions.

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

-   `ai_analyses(id UUID PK, issue_id FK, status, model, summary, confidence, created_at, completed_at)`
-   `ai_recommendations(id UUID PK, ai_analysis_id FK, recommendation_type, value JSONB, confidence, explanation, decision, decided_by FK, decided_at)`
-   `issue_relationships(id UUID PK, issue_id FK, related_issue_id FK, relationship_type, confidence, confirmed_by FK, created_at)`
-   `ai_context_items(id UUID PK, issue_id FK, context_type, content JSONB, source_event_id FK, created_at)`

### Migration

Migration files live at:

``` text
backend/src/main/resources/db/migration/
```

Use:

``` text
V3__phase_03_ai_case_intelligence.sql
```

Migrations must be forward-only, reproducible from a clean database, and
compatible with previous phases.

## 8. API Contract

  ----------------------------------------------------------------------------------------------------------------------
  Method                  Endpoint                                                               Purpose
  ----------------------- ---------------------------------------------------------------------- -----------------------
  `POST`                  `/api/v1/issues/{id}/ai/analyze`                                       Start/retry analysis

  `GET`                   `/api/v1/issues/{id}/ai`                                               Get AI analysis

  `POST`                  `/api/v1/issues/{id}/ai/recommendations/{recommendationId}/decision`   Record human decision

  `GET`                   `/api/v1/issues/{id}/related`                                          Get related/duplicate
                                                                                                 candidates
  ----------------------------------------------------------------------------------------------------------------------

### API Rules

-   Version APIs under `/api/v1`.
-   Use DTOs instead of exposing JPA entities.
-   Validate input at the API boundary.
-   Enforce business rules in services.
-   Enforce authorization server-side.
-   Use appropriate HTTP status codes.
-   Return a consistent error structure.
-   Important state changes create timeline/audit events.

## 8. AI Processing Flow

``` text
Issue Created → AI Job → Collect Context → LLM Analysis
→ Validate Structured Output → Persist → Show Confidence
→ Human Accept/Edit/Reject/Override
```

AI output is never treated as a confirmed fact merely because an LLM
produced it.

## 10. Detailed Implementation

-   Hide provider-specific code behind an AI integration interface.
-   Run analysis asynchronously after issue creation or on retry.
-   Persist AI output separately from user-authored issue data.
-   Use structured output for summary, category, priority, missing
    information, related cases and next action.
-   Display confidence/uncertainty and clearly label AI-generated
    content.
-   Require human decisions for important recommendations.
-   On timeout/failure, mark AI unavailable and keep core issue
    operations working.

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

-   Structured AI parsing
-   AI timeout/failure
-   Low-confidence result
-   Human override
-   Duplicate candidates
-   Core workflow with AI unavailable

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

Phase 3 is complete only when the phase works end-to-end through Flutter
→ Spring Boot → Supabase Cloud, respects role permissions, persists
data, handles failures, has automated tests, and integrates with
previous phases.
