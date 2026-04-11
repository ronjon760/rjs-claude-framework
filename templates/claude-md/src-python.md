# Source Directory

## Organization
- `routes/` or `views/` — Request handlers (thin wrappers, delegate to services)
- `services/` — Business logic layer
- `models/` — Data models and database access
- `utils/` — Shared helper functions
- `tests/` — Test files mirroring the source structure

## Rules
- Routes/views are thin wrappers — no business logic inline
- Services contain the real logic — they're testable without HTTP
- Models handle data access only — no business rules in queries
- Follow snake_case naming for files and functions, PascalCase for classes
